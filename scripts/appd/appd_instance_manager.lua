local protocols = require('share.protocols')

local AppInstanceMgr = class("AppInstanceMgr", BinLogObject)

function AppInstanceMgr:ctor()
	
end

function AppInstanceMgr:checkIfCanEnterVIP(id, hard)

	local config = tb_map_vip[id]

	-- 判断VIP是否满足条件
	local player = self:getOwner()
	if not player:isVIP(config.vip) then
		outFmtError("vip level not satisfy")
		return
	end
	
	if not self:isEnoughForceByHard(id, hard, player:GetForce()) then
		outFmtError("no force to enter hard = %s", hard)
		return
	end
	
	-- 判断进入次数是否足够
	-- 每个信息4个byte[0:通关难度,1:当前难度,2:挑战次数,3:购买次数]
	
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local times = self:GetByte(indx, 2)
	local x 	= config.x
	local y 	= config.y
	local mapid = config.mapid
	
	if times == config.times then
		outFmtError("try time is not fit for mapid %d", mapid)
		return
	end
	
	self:AddByte(indx, 2, 1)
	
	local gerneralId = string.format("%d:%s:%d_%d:%s", id, hard, times, getMsTime(), player:GetGuid())
	
	-- 发起传送
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, gerneralId)
end

-- 通关难度
function AppInstanceMgr:passVipInstance(id, hard)
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local cmp = self:GetByte(indx, 1)
	local max = cmp
	
	if max < hard then
		max = hard
	end
	
	if max > cmp then
		outFmtInfo("vip instance passed, id = %d, hard = %d ", id, hard)
		self:SetByte(indx, 1, max)
	end
end

function AppInstanceMgr:isEnoughForceByHard(id, hard, force)
	hard = tonumber(hard)
	local config = tb_map_vip[id]
	return force >= config.forces[hard]
end

-- 一键扫荡VIP
function AppInstanceMgr:sweepVIPInstance(id, hard)

	local dict = {}
	local dropIdTable = tb_map_vip[id].rewards[hard]
	
	DoRandomDropTable(dropIdTable, dict)
	
	local itemDict = {}
	for entry, count in pairs(dict) do
		table.insert(itemDict, {entry, count})
	end
	
	local playerInfo = self:getOwner()
	playerInfo:AppdAddItems(itemDict, MONEY_CHANGE_VIP_INSTANCE_REWARD, LOG_ITEM_OPER_TYPE_VIP_INSTANCE_REWARD)
	
	-- 扫荡的结果发送
	local list = Change_To_Item_Reward_Info(dict, true)
	playerInfo:call_sweep_instance_reward (INSTANCE_SUB_TYPE_VIP, 0, 0, 0, list)
end

-------------------------------资源副本------------------------------
function AppInstanceMgr:checkIfCanEnterResInstance(id)
	
	outFmtDebug("appd enter res %d",id)
	local config = tb_instance_res[id]
	
	
	local player = self:getOwner()
	
	
	-- 判断进入次数是否足够
	-- 每个信息4个byte[0:挑战次数,1:预留,2:预留,3:预留]
	
	local indx = INSTANCE_INT_FIELD_RES_START + id - 1
	local times = self:GetByte(indx, 0)
	local mapid = config.mapid
	
	local allTime = config.times
	local vip = player:GetVIP()
	if vip > 0 then
		allTime = allTime + tb_vip_base[vip].instance
	end
	--local viptimes = tb_vip_base
	
	outFmtDebug("times %d ,mapID %d",times,mapid)
	--判断次数
	if times >= allTime then
		outFmtError("try time is not fit for mapid %d", mapid)
		return
	end
	--判断等级
	local lev = player:GetLevel()
	if lev < config.limLev then
		outFmtError("res instance Limit lev %d", lev)
		return
	end
	
	local x 	= config.x
	local y 	= config.y
	
	self:AddByte(indx, 0, 1)

	player:AddActiveItem(1)
	
	local gerneralId = string.format("%d:%d:%s", id, getMsTime(), player:GetGuid())
	
	outFmtDebug("gerneralId %s",gerneralId)
	
	-- 发起传送
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, gerneralId)
	
	local questMgr = player:getQuestMgr()
	questMgr:OnUpdate(QUEST_TARGET_TYPE_RESOURCE_INSTANCE, {mapid})
end


-- 通关资源副本
function AppInstanceMgr:passResInstance(id)
	--outFmtDebug("ton guan zi yuan fu ben %d *************************************",id)
	local idx =  INSTANCE_INT_FIELD_RES_START + id - 1
	local pas = self:GetByte(idx,1)
	if pas == 0 then
		self:SetByte(idx,1,1)
	end
end

-- 扫荡资源副本
function AppInstanceMgr:sweepResInstance(id)
	--print("AppInstanceMgr:sweepResInstance")
	local baseIdx =  INSTANCE_INT_FIELD_RES_START + id - 1
	local pas = self:GetByte(baseIdx,1)
	if pas == 1 then
		--print("begin sao dang")
		
		--tb_instance_reward
		local baseconfig = tb_instance_res[id]
		local times = self:GetByte(baseIdx, 0)
		
		local allTime = baseconfig.times
		local player = self:getOwner()
		local vip = player:GetVIP()
		if vip > 0 then
			allTime = allTime + tb_vip_base[vip].instance
		end
		
		--判断次数
		if times >= allTime then
			outFmtError("try time is not fit for mapid  %d",times)
			return
		end
		
		local playerInfo = self:getOwner()
		local idx = id * 100 + playerInfo:GetLevel()
		local config = tb_instance_reward[idx]
		local tab = {}
		table.insert(tab,config.basereward[1])
		local randomReward = config.randomreward
		local rewardIdx = randInt(1, #randomReward)
		table.insert(tab,randomReward[rewardIdx])
		table.insert(tab,config.reward[1])
		
		local list = {}
		
		for _,v in ipairs(tab) do
			--奖励通知
			local stru = item_reward_info_t .new()
			stru.item_id	= v[1]
			stru.num 		= v[2]
			table.insert(list, stru)
		end
		
		playerInfo:PlayerAddItems(tab,MONEY_CHANGE_VIP_INSTANCE_SWEEP,LOG_ITEM_OPER_TYPE_INSTANCE_SWEEP)
		
		--添加次数
		self:AddByte(baseIdx, 0, 1)
		
		player:AddActiveItem(1)
		
		protocols.call_sweep_instance_reward ( player, INSTANCE_SUB_TYPE_RES, id, 0, 0, list)
		
	else
		outFmtDebug("not first res instance")
	end
end

-- 重置试炼塔
function AppInstanceMgr:resetTrialInstance()
	
end

-- 副本每日重置
function AppInstanceMgr:instanceDailyReset()
	-- 重置VIP副本
	for i = INSTANCE_INT_FIELD_VIP_START, INSTANCE_INT_FIELD_VIP_END-1 do
		local id = i - INSTANCE_INT_FIELD_VIP_START + 1
		self:SetByte(i, 2, 0)
		self:SetByte(i, 3, 0)
	end
	
	-- 重置资源副本
	for i = INSTANCE_INT_FIELD_RES_START,INSTANCE_INT_FIELD_RES_END-1 do
		self:SetByte(i,0,0)
	end
end

-------------------------------活动------------------------------
--设置活动次数
function AppInstanceMgr:setActiveNum(id,num)
	self:SetUInt32(INSTANCE_INT_FIELD_ACTIVE_START + id - 1,num)
end

function AppInstanceMgr:getActiveNum(id)
	return self:GetUInt32(INSTANCE_INT_FIELD_ACTIVE_START + id - 1)
end

--增加活跃度
function AppInstanceMgr:addActivity(num)
	self:AddUInt32(INSTANCE_INT_FIELD_ACTIVE,num)
end

--获取总活跃度
function AppInstanceMgr:getActivity()
	return self:GetUInt32(INSTANCE_INT_FIELD_ACTIVE)
end

function AppInstanceMgr:hasGetActivityReward(offset)
	return self:GetBit(INSTANCE_INT_FIELD_ACTIVE_REWARD,offset)
end

function AppInstanceMgr:SetActivityReward(offset)
	self:SetBit(INSTANCE_INT_FIELD_ACTIVE_REWARD,offset)
end

-------------------------------活动end------------------------------

-------------------------------竞技------------------------------
--3v3已参加次数
function AppInstanceMgr:get3v3EnterTimes()
	return self:GetUInt16(INSTANCE_INT_FIELD_3V3_TIMES,0)
end

--增加3v3参加次数
function AppInstanceMgr:add3v3EnterTimes()
	self:AddUInt16(INSTANCE_INT_FIELD_3V3_TIMES,0,1)
end

function AppInstanceMgr:set3v3EnterTimes(num)
	self:SetUInt16(INSTANCE_INT_FIELD_3V3_TIMES,0,num)
end

--3v3已购买次数
function AppInstanceMgr:get3v3BuyTimes()
	return self:GetUInt16(INSTANCE_INT_FIELD_3V3_TIMES,1)
end

function AppInstanceMgr:add3v3BuyTimes(num)
	self:AddUInt16(INSTANCE_INT_FIELD_3V3_TIMES,1,num)
end

--获取3v3每日奖励状态
function AppInstanceMgr:get3v3DayReward(id)
	return self:GetByte(INSTANCE_INT_FIELD_3V3_DAY_REWARD,id-1)
end

--设置3v3每日奖励状态
function AppInstanceMgr:set3v3DayReward(id)
	return self:SetByte(INSTANCE_INT_FIELD_3V3_DAY_REWARD,id-1,1)
end

--获取3v3段位奖励时间戳
function AppInstanceMgr:get3v3SegmentTime()
	return self:GetUInt32(INSTANCE_INT_FIELD_3V3_SEGMENT_TIME)
end

--设置3v3段位奖励时间戳
function AppInstanceMgr:set3v3SegmentTime(time)
	return self:SetUInt32(INSTANCE_INT_FIELD_3V3_SEGMENT_TIME,time)
end

-------------------------------竞技end------------------------------


-------------------------------斗剑台------------------------------
--斗剑台已参加次数
function AppInstanceMgr:getDoujianEnterTimes()
	return self:GetUInt16(INSTANCE_INT_FIELD_DOUJIAN_TIMES,0)
end

--增加斗剑台参加次数
function AppInstanceMgr:addDoujianEnterTimes()
	self:AddUInt16(INSTANCE_INT_FIELD_DOUJIAN_TIMES,0,1)
end
--设置斗剑台参加次数
function AppInstanceMgr:setDoujianEnterTimes(num)
	self:SetUInt16(INSTANCE_INT_FIELD_DOUJIAN_TIMES,0,num)
end

--斗剑台已购买次数
function AppInstanceMgr:getDoujianBuyTimes()
	return self:GetUInt16(INSTANCE_INT_FIELD_DOUJIAN_TIMES,1)
end
--增加斗剑台已购买次数
function AppInstanceMgr:addDoujianBuyTimes(num)
	self:AddUInt16(INSTANCE_INT_FIELD_DOUJIAN_TIMES,1,num)
end

--斗剑台CD时间戳
function AppInstanceMgr:getDoujianCD()
	return self:GetUInt32(INSTANCE_INT_FIELD_DOUJIAN_FIGHT_CD)
end

--设置斗剑台CD时间戳
function AppInstanceMgr:setDoujianCD(time)
	self:SetUInt32(INSTANCE_INT_FIELD_DOUJIAN_FIGHT_CD,time)
end


--设置斗剑台首胜状态
function AppInstanceMgr:setDoujianFirstRank(rank)
	
	for i,v in ipairs(tb_doujiantai_first) do
		if rank <= v.rank then
			if not self:GetBit(INSTANCE_INT_FIELD_DOUJIAN_FIRST_GET,i) then
				self:SetBit(INSTANCE_INT_FIELD_DOUJIAN_FIRST_GET,i)
			end
			
		end
	end
	
end

function AppInstanceMgr:getDoujianFirstRank(id)
	return self:GetBit(INSTANCE_INT_FIELD_DOUJIAN_FIRST_GET,id)
end

--斗剑台历史最高名次
function AppInstanceMgr:setDoujianMaxRank(rank)
	local cur = self:GetUInt32(INSTANCE_INT_FIELD_DOUJIAN_MAX_RANK)
	if cur == 0 or cur > rank then
		self:SetUInt32(INSTANCE_INT_FIELD_DOUJIAN_MAX_RANK,rank)
	end
	
end
--斗剑台首胜奖励领取状态
function AppInstanceMgr:getDoujianFirstReward(id)
	return self:GetBit(INSTANCE_INT_FIELD_DOUJIAN_FIRST_REWARD,id)
end
--获取斗剑台首胜奖励领取状态
function AppInstanceMgr:setDoujianFirstReward(id)
	self:SetBit(INSTANCE_INT_FIELD_DOUJIAN_FIRST_REWARD,id)
end

--设置斗剑台连胜
function AppInstanceMgr:setDoujianCombatWin(tf)
	if tf then
		self:AddUInt16(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,1,1)
		local cur = self:GetUInt16(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,1)
		if self:GetUInt16(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,0) < cur then
			self:SetUInt16(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,0,cur)
		end
	else
		self:SetUInt16(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,1,0)
	end
end
--获取斗剑台连胜
function AppInstanceMgr:getDoujianCombatWin()
	return self:GetUInt16(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,0)
end

-- 获取当前连胜
function AppInstanceMgr:getDoujianCurrCombatWin()
	return self:GetUInt16(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,1)
end

--斗剑台首胜奖励领取状态
function AppInstanceMgr:getDoujianCombatWinReward(id)
	return self:GetBit(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN_REWARD,id)
end
--获取斗剑台首胜奖励领取状态
function AppInstanceMgr:setDoujianCombatWinReward(id)
	self:SetBit(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN_REWARD,id)
end
--斗剑台每日重置
function AppInstanceMgr:dayDoujianReset()
	self:SetUInt32(INSTANCE_INT_FIELD_DOUJIAN_TIMES,0)
	self:SetUInt32(INSTANCE_INT_FIELD_DOUJIAN_FIGHT_CD,0)
	self:SetUInt32(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN,0)
	self:SetUInt32(INSTANCE_INT_FIELD_DOUJIAN_COMBATWIN_REWARD,0)
end
-------------------------------斗剑台end------------------------------


-----------------------------------仙府夺宝----------------------------
--重置每天的挑战次数
function AppInstanceMgr:ResetXianfuDayTimes()
	self:SetXianfuDayTimes(0)
end

-- 限制挑战次数
function AppInstanceMgr:SetXianfuDayTimes(val)
	return self:SetUInt32(INSTANCE_INT_FIELD_XIANFU_DAY_TIMES, val)
end

-- 检测挑战次数是否足够
function AppInstanceMgr:CheckXianfuDayTimes()
	local target = tb_kuafu_xianfu_base[ 1 ].dailytimes
	local used = self:GetUInt32(INSTANCE_INT_FIELD_XIANFU_DAY_TIMES)
	return used < target
end

-- 增加完成的挑战次数
function AppInstanceMgr:AddXianfuDayTimes()
	self:AddUInt32(INSTANCE_INT_FIELD_XIANFU_DAY_TIMES, 1)
end

-----------------------------------------------------------------------


---------------------------------斗剑台--------------------------------

--- 斗剑台挑战记录
function AppInstanceMgr:AddDoujiantaiRecord(record)
	local cursor = self:GetUInt32(INSTANCE_INT_FIELD_DOUJIANTAI_CURSOR)
	self:SetStr(cursor + INSTANCE_STR_FIELD_DOUJIANTAI_RECORD_START, record)
	cursor = cursor + 1
	if cursor >= MAX_DOUJIANTAI_RECORD_COUNT then
		cursor = 0
	end
	self:SetUInt32(INSTANCE_INT_FIELD_DOUJIANTAI_CURSOR, cursor)
end

-- 名次掉了以后重新随机对手
function AppInstanceMgr:RefreshEnemysAfterRankChanged()
	local playerInfo = self:getOwner()
	local ranges = self:GetCurrRanges()
	local myrank = playerInfo:GetDoujiantaiRank()
	
	if myrank == 0 then
		myrank = MAX_DOUJIANTAI_RANK_COUNT + 1
	end
	
	local exists = {}
	for i = INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_S, INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_E-1 do
		local rank = self:GetUInt32(i)
		--print("RefreshEnemysAfterRankChanged", i, rank)
		if rank > 0 then
			local vist = false
			-- 判断是否在随机区间内
			for j = 1, #ranges do
				local range = ranges[ j ]
				local l = myrank - range[ 2 ]
				local r = myrank - range[ 1 ]
				if l <= rank and rank <= r then
					exists[ j ] = 1
					vist = true
					break
				end
			end
			
			if not vist then
				self:SetUInt32(i, 0)
			end
		end
	end

	--print("RefreshEnemysAfterRankChanged*************************")
	-- 给空的随机
	for j = 1, #ranges do
		if not exists[ j ] then
			local range = ranges[ j ]
			local l = myrank - range[ 2 ]
			local r = myrank - range[ 1 ]
			local rank = randInt(l, r)
			
			local emptyIndx = self:GetEmptyIndx()
			if rank > 0 and emptyIndx >= 0 then
				self:SetUInt32(emptyIndx, rank)
			end
		end
	end
end

function AppInstanceMgr:GetEmptyIndx()
	for i = INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_S, INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_E-1 do
		local rank = self:GetUInt32(i)
		if rank == 0 then
			return i
		end
	end
	
	return -1
end

function AppInstanceMgr:GetEnemyRank(indx)
	return self:GetUInt32(INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_S + indx)
end

function AppInstanceMgr:GetEnemyRankList()
	local dict = {}
	for i = INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_S, INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_E-1 do
		local rank = self:GetUInt32(i)
		if rank > 0 then
			table.insert(dict, rank)
		end
	end
	
	return dict
end

function AppInstanceMgr:GetCurrRanges()
	local playerInfo = self:getOwner()
	local rank = playerInfo:GetDoujiantaiRank()
	local indx = #tb_doujiantai_fight_range
	
	for i = 1, #tb_doujiantai_fight_range do
		local config = tb_doujiantai_fight_range[i]
		if config.ra <= rank and rank <= config.rb then
			indx = i
			break
		end
	end
	
	return tb_doujiantai_fight_range[indx].chooseRange
end


-- 击败了排名rank的, 以后在需要随机
function AppInstanceMgr:OnbeatRank(rank)
	for i = INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_S, INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_E-1 do
		--print("OnbeatRank ", i, self:GetUInt32(i), rank)
		if self:GetUInt32(i) == rank then
			self:SetUInt32(i, 0)
		end
	end
	--print("RefreshEnemysAfterRankChanged")
	self:RefreshEnemysAfterRankChanged()
end

-- 每天选择对手
function AppInstanceMgr:RefreshEnemy()
	local ranges = self:GetCurrRanges()
	local dict = {}
	-- INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY1
	for _, range in pairs(ranges) do
		local rank = self:RandomEnemy(range)
		if rank > 0 then
			table.insert(dict, rank)
		end
	end
	
	
	for i = INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_S, INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_E-1 do
		self:SetUInt32(i, 0)
	end
	
	for i = 1, #dict do
		self:SetUInt32(INSTANCE_INT_FIELD_DOUJIANTAI_ENEMY_S+i-1, dict[ i ])
	end
end

-- 区间内选择对手
-- 0: 表示找不到人
function AppInstanceMgr:RandomEnemy(range)
	local playerInfo = self:getOwner()
	local rank = playerInfo:GetDoujiantaiRank()
	if rank == 0 then
		rank = MAX_DOUJIANTAI_RANK_COUNT + 1
	end
	
	local l = rank - range[ 2 ]
	local r = rank - range[ 1 ]
		
	return randInt(l, r)
end


function AppInstanceMgr:checkIfCanEnterMassBoss(id)
	local config = tb_mass_boss_info[ id ]
	local player = self:getOwner()
	
	-- 判断等级是否足够
	if player:GetLevel() < config.permitLevel then
		outFmtError("no level to enter id = %s", id)
		return
	end
	
	-- 次数是否足够
	if not player:costMassBossTimes() then
		return
	end

	local x 	= config.enterPos[ 1 ]
	local y 	= config.enterPos[ 2 ]
	local mapid = config.mapId
	
	-- 发起传送
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, ''..id)
end


-- 获得玩家guid
function AppInstanceMgr:getPlayerGuid()
	--物品管理器guid转玩家guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--获得副本管理器的拥有者
function AppInstanceMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end

return AppInstanceMgr