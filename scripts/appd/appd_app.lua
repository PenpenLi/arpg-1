require('util.functions')
local protocols = require('share.protocols')

local AppdApp = class('AppdApp',require('util.app_base'))

function AppdApp:ctor( )
	super(self)
	--对象管理器最重要了
	self.objMgr = require('appd.appd_obj_manager').new()

	--应用服开启http监听
	self.http = require('appd.http').new()

	--后台公告
	self.gmNotice = require('appd.gm_notice').new()
	
	--新版数据库接口
	local isPkServer = globalGameConfig:IsPKServer()
	if not isPkServer then
		self.dbAccess = require('appd.appd_mongo_db').new(getCXXGlobalPtr('MongoWrap'),getCXXGlobalPtr('AsyncMongoDB'))
	else
	end

	--1s一次的心跳
	self.cron:every(1,function ( )
		--后台公告心跳
		self.gmNotice:update()
	end)
	
	self:InitCorn()
	
	-- 3v3组队信息 team_guid:{player_guid1, player_guid2, player_guid3}
	self.world_3v3_team_dict = {}
	-- 3v3组队中个人所在的队伍 player_guid:team_guid
	self.world_3v3_player_team = {}
	-- 正在匹配的跨服信息
	self.kuafu_dict = {}
	-------------------------------------------
	-- 跨服排行榜信息
	self.kuafu_rank = {}
end

-- 设置正在进行的跨服操作类型
function AppdApp:SetMatchingKuafuType(player_guid, kuafu_type)
	self.kuafu_dict[player_guid] = kuafu_type
end

-- 获得正在进行的跨服操作类型
function AppdApp:GetMatchingKuafuType(player_guid)
	return self.kuafu_dict[player_guid]
end

-- 是否正在进行指定跨服类型操作
function AppdApp:IsKuafuTypeMatching(player_guid, kuafu_type)
	return self.kuafu_dict[player_guid] and self.kuafu_dict[player_guid] % 65536 == kuafu_type 
end

-- 是否在进行跨服操作
function AppdApp:IsInKuafuTypeMatching(player_guid)
	return self.kuafu_dict[player_guid]
end

-- 获得跨服对应的参数数据
function AppdApp:GetKuafuTypeMatchingArg(player_guid)
	return math.floor(self.kuafu_dict[player_guid] / 65536)
end

function AppdApp:update( diff )
	if self.http then
		--奔跑吧,http服务
		self.http:update()
	end
	--update函数被子类重写了,只好手工再调用
	self.super.update(self, diff)
end

-- 定时器初始化
function AppdApp:InitCorn()
	--如果是pk服，下面的都不需要了
	if(globalGameConfig:IsPKServer())then
		return
	end
	
	--0点更新活动定时器
	self.cron:addCron("更新限时活动",'0 0 * * *',function() GetTodayLimitActivityVersion() end)
	
	--0点重置
	self.cron:addCron("0点重置",'0 0 * * *',function() 
		self.objMgr:foreachAllPlayer(function(player)	
			player:DoResetDaily()
		end)
		self:RankReward()
		self.objMgr:foreachAllFaction(function(faction)
			faction:ResetFaction()
		end)
	end)
	
	-- 每周重置
	self.cron:addCron("每周重置",'0 0 * * 1',function() 
		Rank3v3kuafuWeek()
	end)
	
	-- 野外boss马上刷新通知
	local fbconfig = tb_map_field_boss_time[ 1 ]
		
	for _, timeInfo in pairs(fbconfig.time) do
		local H = timeInfo[ 1 ]
		local M = timeInfo[ 2 ]
		
		self:InitFieldBossCorn(H, M, fbconfig.noticestarttime, fbconfig.noticebosstime)
	end
	
	-- 世界BOSS
	local wbconfig = tb_worldboss_time[ 1 ]
	self:InitWorldBossCorn(wbconfig.time[ 1 ], wbconfig.time[ 2 ], wbconfig.enrolllast, wbconfig.time_last, wbconfig.notice)
	
	--每隔5s检测下失效物品
	self.cron:every("失效物品检测",5,function()
		self.objMgr:foreachAllPlayer(function(player)	
			local itemMgr = player:getItemMgr()
			if itemMgr then itemMgr:delFailTimeItem() end
		end)		
	end)
	--每隔5min刷新好友信息
	self.cron:every("好友信息刷新",300,function()
		self.objMgr:foreachAllPlayer(function(player)	
			player:RefreshFriendInfo()
		end)
	end)

	--每隔6s检测下失效幻化
	self.cron:every("失效幻化检测", 6,function()
		self.objMgr:foreachAllPlayer(function(player)	
			player:OnRemoveExpireIllusion()
		end)
	end)
	
	--每隔7s检测下失效神兵
	self.cron:every("失效神兵检测", 7,function()
		self.objMgr:foreachAllPlayer(function(player)
			player:OnRemoveExpireDivine()
		end)
	end)

	-- 每个1800秒刷新排行榜信息
	self.cron:every("刷新排行榜信息", 1800,function()
		OnUpdateRankList()
	end)
	
	--每隔60s检测下失效称号
	self.cron:every("刷新排行榜信息", 60,function()
		self.objMgr:foreachAllPlayer(function(player)
			player:removeExpireTitle()
		end)
	end)

	--每隔3s查询匹配情况
	self.cron:every("查询跨服匹配", 1, function()
		self.objMgr:foreachAllPlayer(function(player)
			player:QueryKuafuMatchInfo()
		end)
	end)
	
	--每隔3600s更新跨服排行榜
	self.cron:every("更新跨服排行", 3600, function()
		UpdateKuafuRank()
	end)
end

-- 全服野外BOSS定时器初始化
function AppdApp:InitFieldBossCorn(H, M, startTime, bossTime)
	
	-- 刷新BOSS
	local crontab_str = string.format("%d %d * * *", M, H)
	outFmtInfo("============================born boss crontab_str = %s", crontab_str)
	self.cron:addCron("通知全服野外BOSS刷新", crontab_str, function() 
		-- 通知场景服刷BOSS
		self:CallOptResult(OPERTE_TYPE_FIELD_BOSS, FIELD_BOSS_OPERTE_OCCUR, {startTime})
		NoticeScene(APPD_SCENED_REBORN_FIELD_BOSS)
	end)	
				
	-- 即将开始通知
	local TH, TM = self:ModifyTimeMinutes(H, M, -startTime)
	local crontab_str1 = string.format("%d %d * * *", TM, TH)
	outFmtInfo("------------------------------startTime crontab_str = %s", crontab_str1)
	self.cron:addCron("通知全服野外BOSS将要开启", crontab_str1, function() 
		-- 通知场景服 清理前一个BOSS的数据
		NoticeScene(APPD_SCENED_CLEAR_FIELD_BOSS)
		
		self:CallOptResult(OPERTE_TYPE_FIELD_BOSS, FIELD_BOSS_OPERTE_WILL_START, {startTime})
	end)
	
	-- 即将刷新通知
	TH, TM = self:ModifyTimeMinutes(H, M, -bossTime)
	local crontab_str2 = string.format("%d %d * * *", TM, TH)
	outFmtInfo("+++++++++++++++++++++++++bossTime crontab_str = %s", crontab_str2)
	self.cron:addCron("通知全服野外BOSS将要刷新", crontab_str2, function() 
		self:CallOptResult(OPERTE_TYPE_FIELD_BOSS, FIELD_BOSS_OPERTE_WILL_OCCUR, {bossTime})
	end)
end


-- 世界BOSS
function AppdApp:InitWorldBossCorn(sh, sm, enrollLast, time_last, noticeTime)
	noticeTime = noticeTime or 1
	
	local M, H
	H, M = sh, sm
	-- BOSS报名时间
	local crontab_str = string.format("%d %d * * *", M, H)
	outFmtInfo("WWWWWWWWWWWWWWWWWWWWWWWWWWorld boss enroll crontab_str = %s", crontab_str)
	self.cron:addCron("通知全服世界BOSS开始报名", crontab_str, function()		
		OnEnrollWorldBoss()
		-- 通知全服世界BOSS开始报名
		self:CallOptResult(OPERTE_TYPE_WORLD_BOSS, WORLD_BOSS_OPERTE_ENROLL, {})
	end)
	
	-- 世界BOSS即将开始
	H, M = self:ModifyTimeMinutes(sh, sm, -noticeTime)
	crontab_str = string.format("%d %d * * *", M, H)
	outFmtInfo("WWWWWWWWWWWWWWWWWWWWWWWWWWorld boss will start crontab_str = %s", crontab_str)
	self.cron:addCron("通知全服世界BOSS即将开启", crontab_str, function() 
		self:CallOptResult(OPERTE_TYPE_WORLD_BOSS, WORLD_BOSS_OPERTE_WILL_START, {})
	end)
	

	-- BOSS挑战时间
	H, M = self:ModifyTimeMinutes(sh, sm, enrollLast)
	crontab_str = string.format("%d %d * * *", M, H)
	outFmtInfo("WWWWWWWWWWWWWWWWWWWWWWWWWWorld boss fight crontab_str = %s", crontab_str)
	self.cron:addCron("通知全服世界BOSS挑战", crontab_str, function() 
		-- 分配
		local playerDict, roomInfo = ArrangeWorldBossRoom()
		-- 通知场景服 进行初始化
		NoticeScene(APPD_SCENED_FIGHT_WORLD_BOSS, #playerDict)
		-- 进行传送
		DoWorldBossTeleport(playerDict, roomInfo)
		
		-- 通知全服世界BOSS挑战 分好房间, 把所有报名的人传送进去
		outFmtInfo("InitWorldBossCorn fight===============================")
	end)
	
	-- BOSS结束时间
	H, M = self:ModifyTimeMinutes(sh, sm, time_last)
	crontab_str = string.format("%d %d * * *", M, H)
	outFmtInfo("WWWWWWWWWWWWWWWWWWWWWWWWWWorld boss endddddddddddddddd crontab_str = %s", crontab_str)
	self.cron:addCron("通知全服世界BOSS结束", crontab_str, function() 
		-- 通知场景服 BOSS结束
		NoticeScene(APPD_SCENED_WORLD_BOSS_END)
		-- 通知全服世界BOSS挑战 分好房间, 把所有报名的人传送进去
		outFmtInfo("InitWorldBossCorn end*****************************===============================")
	end)
	
end

-- 分钟数改变后的实际时间
function AppdApp:ModifyTimeMinutes(H, M, addM)
	if(addM > 60 or addM < -60) then
		return H, M
	end
	M = M + addM
	if M < 0 then
		M = M + 60
		H = H - 1
		if H < 0 then
			H = 23
		end
	elseif M > 60 then
		M = M - 60
		H = H + 1
		if H > 23 then
			H = 0
		end
	end
	
	return H, M
end
-- 每日排行榜奖励
function AppdApp:RankReward()
	
	--RANK_TYPE_FACTION
	--FIXME
	local ranktype = {RANK_TYPE_POWER,RANK_TYPE_LEVEL,RANK_TYPE_MONEY,RANK_TYPE_DIVINE,RANK_TYPE_MOUNT}
	
	for _,rt in ipairs(ranktype) do
		local tab = GetRankGuidTable(rt)
		for k,v in ipairs(tab) do
			local idx = (10 + i)*65536 + k
			local config = tb_mail[idx]
			
			if config then
				local desc = config.desc
				local name = config.name
				local giftType = config.source
				AddGiftPacksData(v,0,giftType,os.time(),os.time() + 86400*30, name, desc, config.items, "系统")
			end
		end
	end
	
	
	
end


-- 通知场景服做某些事
function NoticeScene(typ, data, str)
	data = data or 0
	str = str or ""
	
	serverConnList:forEachScenedFD(function (fd)
		call_scened_appd_to_send_do_something(fd, "", typ, data, str)
	end)
	
end


--全服发送通知包
function AppdApp:CallOptResult(typ, reason, data)
	if type(data) == 'table' then
		data = string.join('|', data)
	else
		data = tostring(data) or ''
	end	
	local pkt = protocols.pack_operation_failed(typ, reason, data)
	self:Broadcast(pkt)
	pkt:delete()
end

--发公告
function AppdApp:SendNotice( id, content, data )
	local data = data or ""
	local content = content or ""
	local pkt = protocols.pack_chat_notice(id, content, data)
	self:Broadcast(pkt)
	pkt:delete()
end

--广播包
function AppdApp:Broadcast(pkt)
	self.objMgr:foreachAllPlayer(function(player)
		player:SendPacket(pkt)
	end)
end

return AppdApp
