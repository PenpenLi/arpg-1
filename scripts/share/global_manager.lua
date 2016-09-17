outString('load util.BinLogObject')
BinLogObject = BinLogObject or require("util.BinLogObject")

local globalMgr = {}

globalMgr.GLOBAL_SERVER_CONNN_LIST_GUID	= "G.serverconnlist"	--//内部服务器列表
globalMgr.GLOBAL_MAP_INSTANCE_LIST_GUID	= "G.mapInstanceList"	--//地图实例列表
globalMgr.GLOBAL_OBJ_GUID				= "G.globalvalue"		--//全局对象
globalMgr.GLOBAL_GAME_CONFIG			= "G.gameconfig"		--//游戏配置
globalMgr.GLOBAL_CLIENT_GAME_CONFIG		= "G.ClientGameConfig"	--//客户端配置信息
globalMgr.GLOBAL_GUID_MANAGER_GUID		= "G.guidmanager"		--//guid管理数据
globalMgr.GLOBAL_RANK_INFO				= "G.rankinfo"			--//排行榜数据
globalMgr.GLOBAL_RANK_INFO_RASK_POOL	= "G.rankinforaskpool"	--//排行榜任务池
globalMgr.GLOBAL_RIGHT_FLOAT_GUID		= "G.rightfloat"		--//弹窗公告
globalMgr.GLOBAL_NOTICE_MESSAGE			= "G.noticemessage"		--//公告消息
globalMgr.GLOBAL_COUNTER				= "G.counter"			--//计数器，各种世界数量计数
globalMgr.GLOBAL_SAVE_TO_DB				= "G.SaveToDbGuidList"	--//本轮要保存到数据库的所有玩家

outString('load share.serverconnlist script')
ServerConnList = require("share.serverconnlist")
serverConnList = ServerConnList:new {ptr = objects.get(globalMgr.GLOBAL_SERVER_CONNN_LIST_GUID)}

--全局变量
outString('load share.global_value script')
GlobalValue = require("share.global_value")
globalValue = GlobalValue:new {ptr = objects.get(globalMgr.GLOBAL_OBJ_GUID) }

--获得游戏配置
outString('load share.global_game_config script')
GlobalGameConfig = require("share.global_game_config")
globalGameConfig = GlobalGameConfig:new {ptr = objects.get(globalMgr.GLOBAL_GAME_CONFIG)}

--计数器，各种世界数量计数
outString('load share.global_counter script')
GlobalCounter = require("share.global_counter")
globalCounter = GlobalCounter:new {ptr = objects.get(globalMgr.GLOBAL_COUNTER)}

--公告
outString('load share.global_notice_message script')
GlobalNoticeMessage = require("share.global_notice_message")
globalNoticeMessage = GlobalNoticeMessage:new {ptr = objects.get(globalMgr.GLOBAL_NOTICE_MESSAGE)}

--获取弹窗公告
outString('开始载入弹窗公告脚本')
GlobalRightFloat = require("share.global_rightfloat")
globalRightFloat = GlobalRightFloat:new {ptr = objects.get(globalMgr.GLOBAL_RIGHT_FLOAT_GUID)}

--guid管理器
outString('load share.guidmanager script')
GuidManager = require("share.guid_manager")
guidMgr = GuidManager:new {ptr = objects.get(globalMgr.GLOBAL_GUID_MANAGER_GUID)}


--用于對象管理器引用
globalMgr[globalMgr.GLOBAL_SERVER_CONNN_LIST_GUID] = serverConnList
globalMgr[globalMgr.GLOBAL_OBJ_GUID] = globalValue
globalMgr[globalMgr.GLOBAL_GAME_CONFIG] = globalGameConfig
globalMgr[globalMgr.GLOBAL_COUNTER] = globalCounter
globalMgr[globalMgr.GLOBAL_NOTICE_MESSAGE] = globalNoticeMessage
globalMgr[globalMgr.GLOBAL_RIGHT_FLOAT_GUID] = globalRightFloat
globalMgr[globalMgr.GLOBAL_GUID_MANAGER_GUID] = guidMgr


return globalMgr
