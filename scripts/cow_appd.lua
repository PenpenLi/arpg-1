--先载入一些常量
require("const")
outString('load cow_appd.lua')
outString(__SCRIPTS_ROOT__..'cow_appd.lua')

outString('load share.global_manager')
require('share.global_manager')

outString('load template')
require("template/appd_init")
require("template/conditions")

require("util/utils")

outString('load share.tick_name script')
require("share/tick_name")

-------------------------------------------------------------------------------
--配置文件信息
config = {
	----背包配置信息
	bag_init_size_main			= 35,		--主包裹初始化大小
	bag_init_size_equip			= 40,		--装备包裹初始化大小
	bag_init_size_storage		= 140,		--仓库初始化大小
	bag_init_size_repurchase	= 20,		--回购包裹初始化大小
	bag_init_size_system		= 42,		--系统包裹初始化大小
	bag_init_size_stall			= 10,		--摊位包裹初始化大小
	
	bag_max_size_main			= 280,		--主包裹最大容量
	bag_max_size_storage		= 280,		--仓库最大容量
	bag_extension_count			= 7	,		--包裹一次扩展的格子数
	bag_extension_material		= 22,		--包裹扩展的消耗材料模版
	max_mail_item_count			= 4	,		--邮件附件最大个数

	player_max_level = 100,					--玩家最大等级
	
	player_chat_world_level		= 30,		--玩家世界频道最低等级发言
	player_chat_whisper_level	= 30,		--私聊最低等级限时

	update_firend_info_interval = 20,		--更新玩家好友资料间隔
	update_detection_player_info = 10,		--轮询玩家数据间隔

	faction_create_level 			= 30,		--玩家创建帮派的最低等级要求
	faction_join_level 				= 30,		--玩家加入帮派的最低等级要求
	faction_create_need_item		= 411,		--创建帮派需要的物品ID
	faction_create_max				= 3,		--帮派创建最多个数
	update_faction_player_info		= 20,		--帮派信息更新心跳
	
	laba_use_vip_level = 3,					-- 喇叭使用需要VIP等级
	laba_use_need_money = 10,				-- 喇叭使用需要元宝数
	rank_list_work_interval = 1,			-- 排行榜工作间隔，毫秒
	
	group_join_level				= 20,		--玩家加入队伍的最低等级要求
	
	update_online_playerinfo_interval = 60,	--更新在线玩家信息间隔
	--游戏服命令表
	external_router_map = {
		CMSG_BAG_EXCHANGE_POS,
		CMSG_BAG_DESTROY,
		CMSG_BAG_ITEM_SPLIT,
		CMSG_BAG_ITEM_USER,
		CMSG_EXCHANGE_ITEM,
		CMSG_BAG_EXTENSION,
		CMSG_NPC_REPURCHASE,
		CMSG_NPC_GET_GOODS_LIST,
		CMSG_STORE_BUY,
		CMSG_NPC_SELL,
		MSG_CHAT_HORN,
		CMSG_AVATAR_FASHION_ENABLE,
		CMSG_RECEIVE_GIFT_PACKS,		
		CMSG_LIMIT_ACTIVITY_RECEIVE,
		CMSG_RANK_LIST_QUERY,
		CMSG_QUERY_PLAYER_INFO,--查询玩家信息
		MSG_CHAT_WHISPER,--私聊*/
		MSG_CHAT_WORLD,
		MSG_CHAT_NOTICE,
		CMSG_CHAR_REMOTESTORE,
		CMSG_CHAR_REMOTESTORE_STR,
		CMSG_USE_GOLD_OPT,--使用元宝做些什么*/
		CMSG_USE_SILVER_OPT,--使用铜钱做些什么*/
		CMSG_WAREHOUSE_SAVE_MONEY,	--仓库存钱
		CMSG_WAREHOUSE_TAKE_MONEY,	--仓库取钱
		MSG_SYNC_MSTIME_APP,
		CMSG_OPEN_WINDOW,
		CMSG_GOLD_RESPAWN,			--元宝复活
		CMSG_MALL_BUY,
		CMSG_STRENGTH,
		CMSG_CREATE_FACTION,
		CMSG_FACTION_UPGRADE,
		CMSG_FACTION_JOIN,
		CMSG_RAISE_BASE_SPELL,
		CMSG_UPGRADE_ANGER_SPELL,
		CMSG_RAISE_MOUNT,
		CMSG_UPGRADE_MOUNT,
		CMSG_UPGRADE_MOUNT_ONE_STEP,
		CMSG_ILLUSION_MOUNT_ACTIVE,
		CMSG_ILLUSION_MOUNT,
		CMSG_GEM,
		CMSG_DIVINE_ACTIVE,
		CMSG_DIVINE_UPLEV,
		CMSG_DIVINE_SWITCH,
		CMSG_SWEEP_VIP_INSTANCE,
		CMSG_HANG_UP,				-- /*进行挂机*/	
		CMSG_HANG_UP_SETTING,		-- /*进行挂机设置*/
		CMSG_SWEEP_TRIAL_INSTANCE,
		CMSG_RESET_TRIAL_INSTANCE,
		CMSG_SOCIAL_ADD_FRIEND,
		CMSG_SOCIAL_SUREADD_FRIEND,
		CMSG_SOCIAL_GIFT_FRIEND,
		CMSG_SOCIAL_RECOMMEND_FRIEND,
		CMSG_SOCIAL_REVENGE_ENEMY,
		CMSG_SOCIAL_DEL_FRIEND

	},
	--pk服命令表
	pk_external_router_map = {
		MSG_CHAT_WORLD,			
	},
}

--校验协议注册是否有效
CheckRouterMap(config.external_router_map)
CheckRouterMap(config.pk_external_router_map)

require('appd.__init')
app = require('appd.appd_app'):new()

--返回开服后几天的时间戳
function DoHowLongKaiFuTime(val)
	local time_table = globalGameConfig:GetKaiFuShiJian()
	local time_diff = time_table%86400
	time_table = time_table - time_diff - TIME_ZONE_HOUR*3600
	local last_time = time_table + 86400*val - 1
	return last_time
end

--获取开服后第几天
function DoKaiFuDay()
	local days = math.floor((os.time() - globalGameConfig:GetKaiFuShiJian()) / (24*3600)) + 1
	return days
end

--合服后，应用服需要做的事情
function AppdMergeSomething()
	--TODO:由于合了一服就会执行一次,所以通过定时器延迟触发节约性能
	--推送功能必须重新注册一下
	app.http.register_state = 0
	
	-- 解散军团了
	app.objMgr:foreachAllFaction(function(faction)
		faction:AllFactionPlayerQuit()
		local faction_events_guid = faction:getFactionEventsGuid()
		app.objMgr:callRemoveObject(faction:GetGuid())
		app.objMgr:callRemoveObject(faction_events_guid)
	end)
end

--服务器重启后需要loadDB的数据
function StartServerLoadDB()
	
	-- app.dbAccess = {}
	-- --如果有子类接口
	-- if app.__clsDbAccess then
		-- app.__clsDbAccess.extend(app.dbAccess, {})
	-- end
	--//初始化限时活动
	InitLimitActivityConfig()
	GetTodayLimitActivityVersion()
	
	if(not app.dbAccess )then
		app.dbAccess = {}
	end
	app.dbAccess.server_name = globalGameConfig:GetOriginServerName()
	app.dbAccess.trade_data = {}
	app.dbAccess.trade_buy_data = {}
	app.dbAccess:loadTempStallItemData()
	app.dbAccess:loadTempTradeBuyItemData()
end

--服务器重启后需要loadDB的数据
function CloseServerSaveDB()
	--武将排行榜
	--WJForceRank:SaveDB()
	--武将装备排行榜
	--WJItemRank:SaveDB()
end

-- 存储机器人私聊信息
SYS_WHISPER_INFO = {}
function DoAddRobotSysWhisper(player, sys_type)	
	if player:GetLevel() < 40 then		-- 玩家等级小于40级，则不会收到系统私聊信息
		return
	end
	local cur_tm = os.time() + 3
	if SYS_WHISPER_INFO[cur_tm] == nil then
		SYS_WHISPER_INFO[cur_tm] = {}
	end
	table.insert(SYS_WHISPER_INFO[cur_tm], {player:GetGuid(), sys_type})
end

-- 设置挖宝时间
function DoSetWaBaoTime()
	-- 给全服在线玩家一张藏宝图
	--遍历所有玩家
	app.objMgr:foreachAllPlayer(function(player)
		local num = player:GetPlayerWaBaoNum()
		if(num < 5)then
			player:SetPlayerWaBaoNum(num + 1)
		end
	end)
	--发送公告
	onSendNotice(18)	
end
