--先载入一些常量
require("const")
outString('main script file is loading')
outString(__SCRIPTS_ROOT__..'tea_robotd.lua')

outString('util.functions is loading')
require('util.functions')

outString('operation_info.lua is loading')
require("template.operation_info")

config = {
	war_server_optcode ={
		CMSG_FORCED_INTO,
		CMSG_GET_SESSION,
		CMSG_WORLD_WAR_CS_PLAYER_INFO,
		
		MSG_UNIT_MOVE,
		MSG_MOVE_STOP,
		MSG_SPELL_START,
		MSG_SPELL_STOP,
		MSG_SELECT_TARGET,
		CMSG_SET_ATTACK_MODE,
		MSG_USE_GAMEOBJECT,
		CMSG_GOSSIP_HELLO,
		CMSG_GOSSIP_SELECT_OPTION,
		CMSG_RESURRECTION,
		CMSG_INSTANCE_EXIT,
		MSG_INSTANCE_READY,
		CMSG_INSTANCE_NEXT_STATE,
		MSG_QUERY_QUEST_STATUS,
		CMSG_STOP_HUNG_UP,--停止挂机*/
		MSG_BEGIN_TO_GATHER,				--开始采集
		MSG_SIT_SYSTEM,						--打坐
		MSG_HOOKING_OPERATION,				--挂机操作
		CMSG_LOOT_SELECT,
		CMSG_BACKTO_GBT,
		MSG_GM2PK_ATTR,
		MSG_GM_PK_PIPELINE,
		CMSG_PET_CALL,	
		CMSG_WATCHER_PLAYER,
		CMSG_GET_SEAWAR_SORT,				--海战排行榜
	},
}


app = require("robotd.robotd_app").new()

guidMgr = require 'share.guid_manager'

function ___OUT_DEBUG_INFO__()
	outString("out debug info")
	app:OutDebugInfo()
end

