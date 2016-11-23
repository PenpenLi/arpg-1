
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------协议，本代码是自动生成，请勿手工改动----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Packet = require 'util.packet'
local external_send = packet and packet.external_send

local Protocols = {}
---------------------------------------------
--以下为连接的状态
STATUS_NEVER = 1
STATUS_AUTHED = 2
STATUS_LOGGEDIN = 4
STATUS_TRANSFER = 8

---------------------------------------------
--协议枚举
MSG_NULL_ACTION		= 0	-- /*无效动作*/	
MSG_PING_PONG		= 1	-- /*测试连接状态*/	
CMSG_FORCED_INTO		= 2	-- /*踢掉在线的准备强制登陆*/	
CMSG_GET_SESSION		= 3	-- /*获得Session对象*/	
MSG_ROUTE_TRACE		= 4	-- /*网关服数据包路由测试*/	
CMSG_WRITE_CLIENT_LOG		= 5	-- /*记录客户端日志*/	
SMSG_OPERATION_FAILED		= 6	-- /*操作失败*/	
MSG_SYNC_MSTIME		= 7	-- /*同步时间*/	
SMSG_UD_OBJECT		= 8	-- /*对象更新*/	
CMSG_UD_CONTROL		= 9	-- /*对象更新控制协议*/	
SMSG_UD_CONTROL_RESULT		= 10	-- /*对象更新控制协议结果*/	
SMSG_GRID_UD_OBJECT		= 11	-- /*GRID的对象更新*/	
SMSG_GRID_UD_OBJECT_2		= 12	-- /*GRID的对象更新*/	
SMSG_LOGIN_QUEUE_INDEX		= 13	-- /*告诉客户端，目前自己排在登录队列的第几位*/	
SMSG_KICKING_TYPE		= 14	-- /*踢人原因*/	
CMSG_GET_CHARS_LIST		= 15	-- /*获取角色列表*/	
SMSG_CHARS_LIST		= 16	-- /*角色列表*/	
CMSG_CHECK_NAME		= 17	-- /*检查名字是否可以使用*/	
SMSG_CHECK_NAME_RESULT		= 18	-- /*检查名字结果*/	
CMSG_CHAR_CREATE		= 19	-- /*创建角色*/	
SMSG_CHAR_CREATE_RESULT		= 20	-- /*角色创建结果*/	
CMSG_DELETE_CHAR		= 21	-- /*删除角色*/	
SMSG_DELETE_CHAR_RESULT		= 22	-- /*角色删除结果*/	
CMSG_PLAYER_LOGIN		= 23	-- /*玩家登录*/	
CMSG_PLAYER_LOGOUT		= 24	-- /*玩家退出*/	
CMSG_REGULARISE_ACCOUNT		= 25	-- /*临时账号转正规*/	
CMSG_CHAR_REMOTESTORE		= 26	-- /*角色配置信息*/	
CMSG_CHAR_REMOTESTORE_STR		= 27	-- /*角色配置信息*/	
CMSG_TELEPORT		= 28	-- /*传送，如果是C->S，mapid变量请填成传送点ID*/	
MSG_MOVE_STOP		= 29	-- /*停止移动*/	
MSG_UNIT_MOVE		= 30	-- /*unit对象移动*/	
CMSG_USE_GAMEOBJECT		= 31	-- /*使用游戏对象*/	
CMSG_BAG_EXCHANGE_POS		= 32	-- /*包裹操作-交换位置*/	
CMSG_BAG_DESTROY		= 33	-- /*包裹操作-销毁物品*/	
CMSG_BAG_ITEM_SPLIT		= 34	-- /*分割物品*/	
CMSG_BAG_ITEM_USER		= 35	-- /*使用物品*/	
SMSG_BAG_ITEM_COOLDOWN		= 36	-- /*下发物品冷却*/	
SMSG_GRID_UNIT_MOVE		= 37	-- /*grid中的unit移动整体打包*/	
SMSG_GRID_UNIT_MOVE_2		= 38	-- /*grid中的unit移动整体打包2*/	
CMSG_EXCHANGE_ITEM		= 39	-- /*兑换物品*/	
CMSG_BAG_EXTENSION		= 40	-- /*背包扩展*/	
CMSG_NPC_GET_GOODS_LIST		= 41	-- /*请求NPC商品列表*/	
SMSG_NPC_GOODS_LIST		= 42	-- /*Npc商品列表*/	
CMSG_NPC_BUY		= 43	-- /*购买商品*/	
CMSG_NPC_SELL		= 44	-- /*出售物品*/	
CMSG_NPC_REPURCHASE		= 45	-- /*回购物品*/	
CMSG_AVATAR_FASHION_ENABLE		= 46	-- /*时装是否启用*/	
CMSG_QUESTHELP_TALK_OPTION		= 47	-- /*任务对话选项*/	
CMSG_TAXI_HELLO		= 48	-- /*与NPC对话获得传送点列表*/	
SMSG_TAXI_STATIONS_LIST		= 49	-- /*发送传送点列表*/	
CMSG_TAXI_SELECT_STATION		= 50	-- /*选择传送点*/	
CMSG_GOSSIP_SELECT_OPTION		= 51	-- /*与NPC交流选择选项*/	
CMSG_GOSSIP_HELLO		= 52	-- /*与NPC闲聊获取选项*/	
SMSG_GOSSIP_MESSAGE		= 53	-- /*发送闲聊信息和选项*/	
CMSG_QUESTGIVER_STATUS_QUERY		= 54	-- /*任务发布者状态查询*/	
SMSG_QUESTGIVER_STATUS		= 55	-- /*任务NPC状态*/	
MSG_QUERY_QUEST_STATUS		= 56	-- /*查询任务状态*/	
CMSG_QUESTHELP_GET_CANACCEPT_LIST		= 57	-- /*可接任务*/	
SMSG_QUESTHELP_CANACCEPT_LIST		= 58	-- /*下发可接任务列表*/	
SMSG_QUESTUPDATE_FAILD		= 59	-- /*任务失败*/	
SMSG_QUESTUPDATE_COMPLETE		= 60	-- /*任务条件完成*/	
CMSG_QUESTLOG_REMOVE_QUEST		= 61	-- /*放弃任务*/	
CMSG_QUESTGIVER_COMPLETE_QUEST		= 62	-- /*完成任务*/	
SMSG_QUESTHELP_NEXT		= 63	-- /*完成任务后通知任务链的下个任务*/	
CMSG_QUESTHELP_COMPLETE		= 64	-- /*任务系统强制完成任务*/	
SMSG_QUESTUPDATE_ACCEPT		= 65	-- /*接受任务成功*/	
CMSG_QUESTHELP_UPDATE_STATUS		= 66	-- /*更新任务进度_下标数量*/	
SMSG_QUESTGETTER_COMPLETE		= 67	-- /*任务已完成*/	
CMSG_QUESTGIVER_ACCEPT_QUEST		= 68	-- /*接任务*/	
CMSG_QUESTUPDATE_USE_ITEM		= 69	-- /*任务使用物品*/	
CMSG_QUESTHELP_QUERY_BOOK		= 70	-- /*查询天书任务*/	
SMSG_QUESTHELP_BOOK_QUEST		= 71	-- /*下发可接天书任务*/	
SMSG_USE_GAMEOBJECT_ACTION		= 72	-- /*玩家使用游戏对象以后的动作*/	
CMSG_SET_ATTACK_MODE		= 73	-- /*设置攻击模式*/	
MSG_SELECT_TARGET		= 74	-- /*选择目标*/	
SMSG_COMBAT_STATE_UPDATE		= 75	-- /*进入战斗*/	
SMSG_EXP_UPDATE		= 76	-- /*经验更新*/	
MSG_SPELL_START		= 77	-- /*客户端释放技能*/	
MSG_SPELL_STOP		= 78	-- /*施法停止*/	
MSG_JUMP		= 79	-- /*跳*/	
CMSG_RESURRECTION		= 80	-- /*复活*/	
MSG_TRADE_REQUEST		= 81	-- /*交易发出请求*/	
MSG_TRADE_REPLY		= 82	-- /*交易请求答复*/	
SMSG_TRADE_START		= 83	-- /*交易开始*/	
MSG_TRADE_DECIDE_ITEMS		= 84	-- /*交易确认物品*/	
SMSG_TRADE_FINISH		= 85	-- /*交易完成*/	
MSG_TRADE_CANCEL		= 86	-- /*交易取消*/	
MSG_TRADE_READY		= 87	-- /*交易准备好*/	
SMSG_CHAT_UNIT_TALK		= 88	-- /*生物讲话*/	
MSG_CHAT_NEAR		= 89	-- /*就近聊天*/	
MSG_CHAT_WHISPER		= 90	-- /*私聊*/	
MSG_CHAT_FACTION		= 91	-- /*阵营聊天*/	
MSG_CHAT_WORLD		= 92	-- /*世界*/	
MSG_CHAT_HORN		= 93	-- /*喇叭*/	
MSG_CHAT_NOTICE		= 94	-- /*公告*/	
CMSG_QUERY_PLAYER_INFO		= 95	-- /*查询玩家信息*/	
SMSG_QUERY_RESULT_UPDATE_OBJECT		= 96	-- /*查询信息对象更新*/	
CMSG_RECEIVE_GIFT_PACKS		= 97	-- /*领取礼包*/	
SMSG_MAP_UPDATE_OBJECT		= 98	-- /*地图对象更新*/	
SMSG_FIGHTING_INFO_UPDATE_OBJECT		= 99	-- /*战斗信息binlog*/	
SMSG_FIGHTING_INFO_UPDATE_OBJECT_2		= 100	-- /*战斗信息binlog*/	
CMSG_INSTANCE_ENTER		= 101	-- /*进入副本*/	
CMSG_INSTANCE_NEXT_STATE		= 102	-- /*向服务端发送副本进入下一阶段指令*/	
CMSG_INSTANCE_EXIT		= 103	-- /*副本退出*/	
CMSG_LIMIT_ACTIVITY_RECEIVE		= 104	-- /*限时活动领取*/	
SMSG_KILL_MAN		= 105	-- /*杀人啦~~！！！！*/	
SMSG_PLAYER_UPGRADE		= 106	-- /*玩家升级*/	
CMSG_WAREHOUSE_SAVE_MONEY		= 107	-- /*仓库存钱*/	
CMSG_WAREHOUSE_TAKE_MONEY		= 108	-- /*仓库取钱*/	
CMSG_USE_GOLD_OPT		= 109	-- /*使用元宝操作某事*/	
CMSG_USE_SILVER_OPT		= 110	-- /*使用铜钱操作某事*/	
SMSG_GM_RIGHTFLOAT		= 111	-- /*后台弹窗*/	
SMSG_DEL_GM_RIGHTFLOAT		= 112	-- /*删除某条后台弹窗*/	
MSG_SYNC_MSTIME_APP		= 113	-- /*应用服同步时间*/	
CMSG_OPEN_WINDOW		= 114	-- /*玩家打开某个窗口*/	
CMSG_PLAYER_GAG		= 115	-- /*禁言操作*/	
CMSG_PLAYER_KICKING		= 116	-- /*踢人操作*/	
SMSG_MERGE_SERVER_MSG		= 117	-- /*合服通知*/	
CMSG_RANK_LIST_QUERY		= 118	-- /*获取排行信息*/	
SMSG_RANK_LIST_QUERY_RESULT		= 119	-- /*客户端获取排行榜返回结果*/	
CMSG_CLIENT_UPDATE_SCENED		= 120	-- /*客户端热更场景模块后获取uint*/	
SMSG_NUM_LUA		= 121	-- /*数值包*/	
CMSG_LOOT_SELECT		= 122	-- /*战利品拾取*/	
CMSG_GOBACK_TO_GAME_SERVER		= 123	-- /*通知登录服把玩家传回游戏服*/	
CMSG_WORLD_WAR_CS_PLAYER_INFO		= 124	-- /*客户端把比赛人员数据传给比赛服*/	
SMSG_JOIN_OR_LEAVE_SERVER		= 125	-- /*玩家加入或者离开某服务器*/	
MSG_WORLD_WAR_SC_PLAYER_INFO		= 126	-- /*客户端请求跨服人员数据*/	
MSG_CLIENTSUBSCRIPTION		= 127	-- /*客户端订阅信息*/	
SMSG_LUA_SCRIPT		= 128	-- /*服务端下发lua脚本*/	
CMSG_CHAR_UPDATE_INFO		= 129	-- /*角色更改信息*/	
SMSG_NOTICE_WATCHER_MAP_INFO		= 130	-- /*通知客户端观察者的视角*/	
CMSG_MODIFY_WATCH		= 131	-- /*客户端订阅对象信息*/	
CMSG_KUAFU_CHUANSONG		= 132	-- /*跨服传送*/	
CMSG_STRENGTH		= 139	-- /*强化*/	
SMSG_STRENGTH_SUCCESS		= 140	-- /*强化成功*/	
CMSG_FORCEINTO		= 141	-- /*强制进入*/	
CMSG_CREATE_FACTION		= 142	-- /*创建帮派*/	
CMSG_FACTION_UPGRADE		= 143	-- /*升级帮派*/	
CMSG_FACTION_JOIN		= 144	-- /*申请加入帮派*/	
CMSG_RAISE_BASE_SPELL		= 145	-- /*申请升级技能*/	
CMSG_UPGRADE_ANGER_SPELL		= 146	-- /*申请升阶愤怒技能*/	
CMSG_RAISE_MOUNT		= 147	-- /*申请升级坐骑*/	
CMSG_UPGRADE_MOUNT		= 148	-- /*申请升阶坐骑*/	
CMSG_UPGRADE_MOUNT_ONE_STEP		= 149	-- /*申请一键升阶坐骑*/	
CMSG_ILLUSION_MOUNT_ACTIVE		= 150	-- /*申请解锁幻化坐骑*/	
CMSG_ILLUSION_MOUNT		= 151	-- /*申请幻化坐骑*/	
CMSG_RIDE_MOUNT		= 152	-- /*申请骑乘*/	


---------------------------------------------------------------------
--/*坐标结构体*/

point_t = class('point_t')

function point_t:read( input )

	local ret
	ret,self.pos_x = input:readFloat() --/*坐标X*/

	if not ret then
		return ret
	end
	ret,self.pos_y = input:readFloat() --/*坐标Y*/

	if not ret then
		return ret
	end

	return input
end

function point_t:write( output )
	if(self.pos_x == nil)then
		self.pos_x = 0
	end
	output:writeFloat(self.pos_x)
	
	if(self.pos_y == nil)then
		self.pos_y = 0
	end
	output:writeFloat(self.pos_y)
	
	return output
end

---------------------------------------------------------------------
--/*传送地点结构体*/

taxi_menu_info_t = class('taxi_menu_info_t')

function taxi_menu_info_t:read( input )

	local ret
	ret,self.id = input:readI32() --/**/

	if not ret then
		return ret
	end
	ret,self.taxi_text = input:readUTFByLen(50)  --/*传送地点名称*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.map_id = input:readU32() --/*地图ID*/

	if not ret then
		return ret
	end
	ret,self.pos_x = input:readU16() --/*坐标X*/

	if not ret then
		return ret
	end
	ret,self.pos_y = input:readU16() --/*坐标Y*/

	if not ret then
		return ret
	end

	return input
end

function taxi_menu_info_t:write( output )
	if(self.id == nil)then
		self.id = 0
	end
	output:writeI32(self.id)
	
	if(self.taxi_text == nil)then
		self.taxi_text = ''
	end
	output:writeUTFByLen(self.taxi_text , 50 ) 
	
	if(self.map_id == nil)then
		self.map_id = 0
	end
	output:writeU32(self.map_id)
	
	if(self.pos_x == nil)then
		self.pos_x = 0
	end
	output:writeI16(self.pos_x)
	
	if(self.pos_y == nil)then
		self.pos_y = 0
	end
	output:writeI16(self.pos_y)
	
	return output
end

---------------------------------------------------------------------
--/*玩家角色创建选择信息*/

char_create_info_t = class('char_create_info_t')

function char_create_info_t:read( input )

	local ret
	ret,self.name = input:readUTFByLen(50)  --/*名称*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.faction = input:readByte() --/*阵营*/

	if not ret then
		return ret
	end
	ret,self.gender = input:readByte() --/*性别*/

	if not ret then
		return ret
	end
	ret,self.level = input:readU16() --/*等级*/

	if not ret then
		return ret
	end
	ret,self.guid = input:readUTFByLen(50)  --/**/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.head_id = input:readU32() --/*头像*/

	if not ret then
		return ret
	end
	ret,self.hair_id = input:readU32() --/*发型ID*/

	if not ret then
		return ret
	end
	ret,self.race = input:readByte() --/*种族，猛男美女萝莉那些*/

	if not ret then
		return ret
	end

	return input
end

function char_create_info_t:write( output )
	if(self.name == nil)then
		self.name = ''
	end
	output:writeUTFByLen(self.name , 50 ) 
	
	if(self.faction == nil)then
		self.faction = 0
	end
	output:writeByte(self.faction)
	
	if(self.gender == nil)then
		self.gender = 0
	end
	output:writeByte(self.gender)
	
	if(self.level == nil)then
		self.level = 0
	end
	output:writeI16(self.level)
	
	if(self.guid == nil)then
		self.guid = ''
	end
	output:writeUTFByLen(self.guid , 50 ) 
	
	if(self.head_id == nil)then
		self.head_id = 0
	end
	output:writeU32(self.head_id)
	
	if(self.hair_id == nil)then
		self.hair_id = 0
	end
	output:writeU32(self.hair_id)
	
	if(self.race == nil)then
		self.race = 0
	end
	output:writeByte(self.race)
	
	return output
end

---------------------------------------------------------------------
--/*任务菜单*/

quest_option_t = class('quest_option_t')

function quest_option_t:read( input )

	local ret
	ret,self.quest_id = input:readU32() --/*任务id*/

	if not ret then
		return ret
	end
	ret,self.quest_icon = input:readU32() --/*图标*/

	if not ret then
		return ret
	end
	ret,self.quest_level = input:readU16() --/*任务等级*/

	if not ret then
		return ret
	end
	ret,self.quest_title = input:readUTFByLen(50)  --/*任务标题*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.flags = input:readU32() --/*标识*/

	if not ret then
		return ret
	end

	return input
end

function quest_option_t:write( output )
	if(self.quest_id == nil)then
		self.quest_id = 0
	end
	output:writeU32(self.quest_id)
	
	if(self.quest_icon == nil)then
		self.quest_icon = 0
	end
	output:writeU32(self.quest_icon)
	
	if(self.quest_level == nil)then
		self.quest_level = 0
	end
	output:writeI16(self.quest_level)
	
	if(self.quest_title == nil)then
		self.quest_title = ''
	end
	output:writeUTFByLen(self.quest_title , 50 ) 
	
	if(self.flags == nil)then
		self.flags = 0
	end
	output:writeU32(self.flags)
	
	return output
end

---------------------------------------------------------------------
--/*可接任务信息*/

quest_canaccept_info_t = class('quest_canaccept_info_t')

function quest_canaccept_info_t:read( input )

	local ret
	ret,self.quest_id = input:readU32() --/*任务ID*/

	if not ret then
		return ret
	end
	ret,self.quest_type = input:readByte() --/*任务类别*/

	if not ret then
		return ret
	end
	ret,self.title = input:readUTFByLen(50)  --/*标题*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.npc_id = input:readU32() --/*接受任务NPC模板id*/

	if not ret then
		return ret
	end
	ret,self.quest_level = input:readU32() --/*任务等级*/

	if not ret then
		return ret
	end

	return input
end

function quest_canaccept_info_t:write( output )
	if(self.quest_id == nil)then
		self.quest_id = 0
	end
	output:writeU32(self.quest_id)
	
	if(self.quest_type == nil)then
		self.quest_type = 0
	end
	output:writeByte(self.quest_type)
	
	if(self.title == nil)then
		self.title = ''
	end
	output:writeUTFByLen(self.title , 50 ) 
	
	if(self.npc_id == nil)then
		self.npc_id = 0
	end
	output:writeU32(self.npc_id)
	
	if(self.quest_level == nil)then
		self.quest_level = 0
	end
	output:writeU32(self.quest_level)
	
	return output
end

---------------------------------------------------------------------
--/*闲聊选项结构体*/

gossip_menu_option_info_t = class('gossip_menu_option_info_t')

function gossip_menu_option_info_t:read( input )

	local ret
	ret,self.id = input:readI32() --/*id*/

	if not ret then
		return ret
	end
	ret,self.option_icon = input:readI32() --/*选项icon图标*/

	if not ret then
		return ret
	end
	ret,self.option_title = input:readUTFByLen(200)  --/*选项文本*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end

	return input
end

function gossip_menu_option_info_t:write( output )
	if(self.id == nil)then
		self.id = 0
	end
	output:writeI32(self.id)
	
	if(self.option_icon == nil)then
		self.option_icon = 0
	end
	output:writeI32(self.option_icon)
	
	if(self.option_title == nil)then
		self.option_title = ''
	end
	output:writeUTFByLen(self.option_title , 200 ) 
	
	return output
end

---------------------------------------------------------------------
--/*物品冷却*/

item_cooldown_info_t = class('item_cooldown_info_t')

function item_cooldown_info_t:read( input )

	local ret
	ret,self.item = input:readU32() --/*物品摸版*/

	if not ret then
		return ret
	end
	ret,self.cooldown = input:readU32() --/*冷却时间*/

	if not ret then
		return ret
	end

	return input
end

function item_cooldown_info_t:write( output )
	if(self.item == nil)then
		self.item = 0
	end
	output:writeU32(self.item)
	
	if(self.cooldown == nil)then
		self.cooldown = 0
	end
	output:writeU32(self.cooldown)
	
	return output
end

---------------------------------------------------------------------
--/*任务状态*/

quest_status_t = class('quest_status_t')

function quest_status_t:read( input )

	local ret
	ret,self.quest_id = input:readU16() --/*任务ID*/

	if not ret then
		return ret
	end
	ret,self.status = input:readByte() --/*任务状态*/

	if not ret then
		return ret
	end

	return input
end

function quest_status_t:write( output )
	if(self.quest_id == nil)then
		self.quest_id = 0
	end
	output:writeI16(self.quest_id)
	
	if(self.status == nil)then
		self.status = 0
	end
	output:writeByte(self.status)
	
	return output
end


---------------------------------------------
--协议打、解包

-- /*无效动作*/	
function Protocols.pack_null_action (  )
	local output = Packet.new(MSG_NULL_ACTION)
	return output
end

-- /*无效动作*/	
function Protocols.call_null_action ( playerInfo )
	local output = Protocols.	pack_null_action (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*无效动作*/	
function Protocols.unpack_null_action (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*测试连接状态*/	
function Protocols.pack_ping_pong (  )
	local output = Packet.new(MSG_PING_PONG)
	return output
end

-- /*测试连接状态*/	
function Protocols.call_ping_pong ( playerInfo )
	local output = Protocols.	pack_ping_pong (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*测试连接状态*/	
function Protocols.unpack_ping_pong (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*踢掉在线的准备强制登陆*/	
function Protocols.pack_forced_into (  )
	local output = Packet.new(CMSG_FORCED_INTO)
	return output
end

-- /*踢掉在线的准备强制登陆*/	
function Protocols.call_forced_into ( playerInfo )
	local output = Protocols.	pack_forced_into (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*踢掉在线的准备强制登陆*/	
function Protocols.unpack_forced_into (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*获得Session对象*/	
function Protocols.pack_get_session ( sessionkey ,account ,version)
	local output = Packet.new(CMSG_GET_SESSION)
	output:writeUTF(sessionkey)
	output:writeUTF(account)
	output:writeUTF(version)
	return output
end

-- /*获得Session对象*/	
function Protocols.call_get_session ( playerInfo, sessionkey ,account ,version)
	local output = Protocols.	pack_get_session ( sessionkey ,account ,version)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*获得Session对象*/	
function Protocols.unpack_get_session (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.sessionkey = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.account = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.version = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*网关服数据包路由测试*/	
function Protocols.pack_route_trace ( val)
	local output = Packet.new(MSG_ROUTE_TRACE)
	output:writeUTF(val)
	return output
end

-- /*网关服数据包路由测试*/	
function Protocols.call_route_trace ( playerInfo, val)
	local output = Protocols.	pack_route_trace ( val)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*网关服数据包路由测试*/	
function Protocols.unpack_route_trace (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.val = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*记录客户端日志*/	
function Protocols.pack_write_client_log ( type ,uid ,guid ,log)
	local output = Packet.new(CMSG_WRITE_CLIENT_LOG)
	output:writeU32(type)
	output:writeUTF(uid)
	output:writeUTF(guid)
	output:writeUTF(log)
	return output
end

-- /*记录客户端日志*/	
function Protocols.call_write_client_log ( playerInfo, type ,uid ,guid ,log)
	local output = Protocols.	pack_write_client_log ( type ,uid ,guid ,log)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*记录客户端日志*/	
function Protocols.unpack_write_client_log (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.type = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.uid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.log = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*操作失败*/	
function Protocols.pack_operation_failed ( type ,reason ,data)
	local output = Packet.new(SMSG_OPERATION_FAILED)
	output:writeI16(type)
	output:writeI16(reason)
	output:writeUTF(data)
	return output
end

-- /*操作失败*/	
function Protocols.call_operation_failed ( playerInfo, type ,reason ,data)
	local output = Protocols.	pack_operation_failed ( type ,reason ,data)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*操作失败*/	
function Protocols.unpack_operation_failed (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.type = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.reason = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.data = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*同步时间*/	
function Protocols.pack_sync_mstime ( mstime_now ,time_now ,open_time)
	local output = Packet.new(MSG_SYNC_MSTIME)
	output:writeU32(mstime_now)
	output:writeU32(time_now)
	output:writeU32(open_time)
	return output
end

-- /*同步时间*/	
function Protocols.call_sync_mstime ( playerInfo, mstime_now ,time_now ,open_time)
	local output = Protocols.	pack_sync_mstime ( mstime_now ,time_now ,open_time)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*同步时间*/	
function Protocols.unpack_sync_mstime (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.mstime_now = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.time_now = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.open_time = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*对象更新*/	
function Protocols.pack_ud_object (  )
	local output = Packet.new(SMSG_UD_OBJECT)
	return output
end

-- /*对象更新*/	
function Protocols.call_ud_object ( playerInfo )
	local output = Protocols.	pack_ud_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*对象更新*/	
function Protocols.unpack_ud_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*对象更新控制协议*/	
function Protocols.pack_ud_control (  )
	local output = Packet.new(CMSG_UD_CONTROL)
	return output
end

-- /*对象更新控制协议*/	
function Protocols.call_ud_control ( playerInfo )
	local output = Protocols.	pack_ud_control (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*对象更新控制协议*/	
function Protocols.unpack_ud_control (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*对象更新控制协议结果*/	
function Protocols.pack_ud_control_result (  )
	local output = Packet.new(SMSG_UD_CONTROL_RESULT)
	return output
end

-- /*对象更新控制协议结果*/	
function Protocols.call_ud_control_result ( playerInfo )
	local output = Protocols.	pack_ud_control_result (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*对象更新控制协议结果*/	
function Protocols.unpack_ud_control_result (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*GRID的对象更新*/	
function Protocols.pack_grid_ud_object (  )
	local output = Packet.new(SMSG_GRID_UD_OBJECT)
	return output
end

-- /*GRID的对象更新*/	
function Protocols.call_grid_ud_object ( playerInfo )
	local output = Protocols.	pack_grid_ud_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*GRID的对象更新*/	
function Protocols.unpack_grid_ud_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*GRID的对象更新*/	
function Protocols.pack_grid_ud_object_2 (  )
	local output = Packet.new(SMSG_GRID_UD_OBJECT_2)
	return output
end

-- /*GRID的对象更新*/	
function Protocols.call_grid_ud_object_2 ( playerInfo )
	local output = Protocols.	pack_grid_ud_object_2 (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*GRID的对象更新*/	
function Protocols.unpack_grid_ud_object_2 (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*告诉客户端，目前自己排在登录队列的第几位*/	
function Protocols.pack_login_queue_index ( index)
	local output = Packet.new(SMSG_LOGIN_QUEUE_INDEX)
	output:writeU32(index)
	return output
end

-- /*告诉客户端，目前自己排在登录队列的第几位*/	
function Protocols.call_login_queue_index ( playerInfo, index)
	local output = Protocols.	pack_login_queue_index ( index)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*告诉客户端，目前自己排在登录队列的第几位*/	
function Protocols.unpack_login_queue_index (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.index = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*踢人原因*/	
function Protocols.pack_kicking_type ( k_type)
	local output = Packet.new(SMSG_KICKING_TYPE)
	output:writeU32(k_type)
	return output
end

-- /*踢人原因*/	
function Protocols.call_kicking_type ( playerInfo, k_type)
	local output = Protocols.	pack_kicking_type ( k_type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*踢人原因*/	
function Protocols.unpack_kicking_type (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.k_type = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*获取角色列表*/	
function Protocols.pack_get_chars_list (  )
	local output = Packet.new(CMSG_GET_CHARS_LIST)
	return output
end

-- /*获取角色列表*/	
function Protocols.call_get_chars_list ( playerInfo )
	local output = Protocols.	pack_get_chars_list (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*获取角色列表*/	
function Protocols.unpack_get_chars_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*角色列表*/	
function Protocols.pack_chars_list ( list)
	local output = Packet.new(SMSG_CHARS_LIST)
	output:writeI16(#list)
	for i = 1,#list,1
	do
		list[i]:write(output)
	end
	return output
end

-- /*角色列表*/	
function Protocols.call_chars_list ( playerInfo, list)
	local output = Protocols.	pack_chars_list ( list)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*角色列表*/	
function Protocols.unpack_chars_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,len = input:readU16()
	if not ret then
		return false
	end
	param_table.list = {}
	for i = 1,len,1
	do
		local stru = char_create_info_t .new()
		if(stru:read(input)==false)then
			return false
		end
		table.insert(param_table.list,stru)
	end

	return true,param_table	

end


-- /*检查名字是否可以使用*/	
function Protocols.pack_check_name ( name)
	local output = Packet.new(CMSG_CHECK_NAME)
	output:writeUTF(name)
	return output
end

-- /*检查名字是否可以使用*/	
function Protocols.call_check_name ( playerInfo, name)
	local output = Protocols.	pack_check_name ( name)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*检查名字是否可以使用*/	
function Protocols.unpack_check_name (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.name = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*检查名字结果*/	
function Protocols.pack_check_name_result ( result)
	local output = Packet.new(SMSG_CHECK_NAME_RESULT)
	output:writeByte(result)
	return output
end

-- /*检查名字结果*/	
function Protocols.call_check_name_result ( playerInfo, result)
	local output = Protocols.	pack_check_name_result ( result)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*检查名字结果*/	
function Protocols.unpack_check_name_result (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.result = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*创建角色*/	
function Protocols.pack_char_create ( info)
	local output = Packet.new(CMSG_CHAR_CREATE)
	info :write(output)
	return output
end

-- /*创建角色*/	
function Protocols.call_char_create ( playerInfo, info)
	local output = Protocols.	pack_char_create ( info)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*创建角色*/	
function Protocols.unpack_char_create (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	param_table.info = char_create_info_t .new()
	if(param_table.info :read(input)==false)then
		return false
	end

	return true,param_table	

end


-- /*角色创建结果*/	
function Protocols.pack_char_create_result ( result)
	local output = Packet.new(SMSG_CHAR_CREATE_RESULT)
	output:writeByte(result)
	return output
end

-- /*角色创建结果*/	
function Protocols.call_char_create_result ( playerInfo, result)
	local output = Protocols.	pack_char_create_result ( result)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*角色创建结果*/	
function Protocols.unpack_char_create_result (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.result = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*删除角色*/	
function Protocols.pack_delete_char ( id)
	local output = Packet.new(CMSG_DELETE_CHAR)
	output:writeU32(id)
	return output
end

-- /*删除角色*/	
function Protocols.call_delete_char ( playerInfo, id)
	local output = Protocols.	pack_delete_char ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*删除角色*/	
function Protocols.unpack_delete_char (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*角色删除结果*/	
function Protocols.pack_delete_char_result ( result)
	local output = Packet.new(SMSG_DELETE_CHAR_RESULT)
	output:writeByte(result)
	return output
end

-- /*角色删除结果*/	
function Protocols.call_delete_char_result ( playerInfo, result)
	local output = Protocols.	pack_delete_char_result ( result)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*角色删除结果*/	
function Protocols.unpack_delete_char_result (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.result = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*玩家登录*/	
function Protocols.pack_player_login ( guid)
	local output = Packet.new(CMSG_PLAYER_LOGIN)
	output:writeUTF(guid)
	return output
end

-- /*玩家登录*/	
function Protocols.call_player_login ( playerInfo, guid)
	local output = Protocols.	pack_player_login ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*玩家登录*/	
function Protocols.unpack_player_login (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*玩家退出*/	
function Protocols.pack_player_logout (  )
	local output = Packet.new(CMSG_PLAYER_LOGOUT)
	return output
end

-- /*玩家退出*/	
function Protocols.call_player_logout ( playerInfo )
	local output = Protocols.	pack_player_logout (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*玩家退出*/	
function Protocols.unpack_player_logout (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*临时账号转正规*/	
function Protocols.pack_regularise_account ( uid)
	local output = Packet.new(CMSG_REGULARISE_ACCOUNT)
	output:writeUTF(uid)
	return output
end

-- /*临时账号转正规*/	
function Protocols.call_regularise_account ( playerInfo, uid)
	local output = Protocols.	pack_regularise_account ( uid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*临时账号转正规*/	
function Protocols.unpack_regularise_account (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.uid = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*角色配置信息*/	
function Protocols.pack_char_remotestore ( key ,value)
	local output = Packet.new(CMSG_CHAR_REMOTESTORE)
	output:writeU32(key)
	output:writeU32(value)
	return output
end

-- /*角色配置信息*/	
function Protocols.call_char_remotestore ( playerInfo, key ,value)
	local output = Protocols.	pack_char_remotestore ( key ,value)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*角色配置信息*/	
function Protocols.unpack_char_remotestore (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.key = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.value = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*角色配置信息*/	
function Protocols.pack_char_remotestore_str ( key ,value)
	local output = Packet.new(CMSG_CHAR_REMOTESTORE_STR)
	output:writeU32(key)
	output:writeUTF(value)
	return output
end

-- /*角色配置信息*/	
function Protocols.call_char_remotestore_str ( playerInfo, key ,value)
	local output = Protocols.	pack_char_remotestore_str ( key ,value)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*角色配置信息*/	
function Protocols.unpack_char_remotestore_str (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.key = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.value = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*传送，如果是C->S，mapid变量请填成传送点ID*/	
function Protocols.pack_teleport ( intGuid)
	local output = Packet.new(CMSG_TELEPORT)
	output:writeU32(intGuid)
	return output
end

-- /*传送，如果是C->S，mapid变量请填成传送点ID*/	
function Protocols.call_teleport ( playerInfo, intGuid)
	local output = Protocols.	pack_teleport ( intGuid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*传送，如果是C->S，mapid变量请填成传送点ID*/	
function Protocols.unpack_teleport (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.intGuid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*停止移动*/	
function Protocols.pack_move_stop ( guid ,pos_x ,pos_y)
	local output = Packet.new(MSG_MOVE_STOP)
	output:writeU32(guid)
	output:writeI16(pos_x)
	output:writeI16(pos_y)
	return output
end

-- /*停止移动*/	
function Protocols.call_move_stop ( playerInfo, guid ,pos_x ,pos_y)
	local output = Protocols.	pack_move_stop ( guid ,pos_x ,pos_y)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*停止移动*/	
function Protocols.unpack_move_stop (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.pos_x = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.pos_y = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*unit对象移动*/	
function Protocols.pack_unit_move ( guid ,pos_x ,pos_y ,path)
	local output = Packet.new(MSG_UNIT_MOVE)
	output:writeU32(guid)
	output:writeI16(pos_x)
	output:writeI16(pos_y)
	output:writeI16(#path)
	for i = 1,#path,1
	do
					output:writeByte(path[i])
			end
	return output
end

-- /*unit对象移动*/	
function Protocols.call_unit_move ( playerInfo, guid ,pos_x ,pos_y ,path)
	local output = Protocols.	pack_unit_move ( guid ,pos_x ,pos_y ,path)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*unit对象移动*/	
function Protocols.unpack_unit_move (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.pos_x = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.pos_y = input:readU16()
	if not ret then
		return false
	end
	param_table.path = {}
	ret,len = input:readU16()
	if not ret then
		return false
	end
	
	for i = 1,len,1
	do
					ret,param_table.path[i] = input:readByte()
				if not ret then
			return false
		end
	end

	return true,param_table	

end


-- /*使用游戏对象*/	
function Protocols.pack_use_gameobject ( target)
	local output = Packet.new(CMSG_USE_GAMEOBJECT)
	output:writeU32(target)
	return output
end

-- /*使用游戏对象*/	
function Protocols.call_use_gameobject ( playerInfo, target)
	local output = Protocols.	pack_use_gameobject ( target)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*使用游戏对象*/	
function Protocols.unpack_use_gameobject (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.target = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*包裹操作-交换位置*/	
function Protocols.pack_bag_exchange_pos ( src_bag ,src_pos ,dst_bag ,dst_pos)
	local output = Packet.new(CMSG_BAG_EXCHANGE_POS)
	output:writeU32(src_bag)
	output:writeU32(src_pos)
	output:writeU32(dst_bag)
	output:writeU32(dst_pos)
	return output
end

-- /*包裹操作-交换位置*/	
function Protocols.call_bag_exchange_pos ( playerInfo, src_bag ,src_pos ,dst_bag ,dst_pos)
	local output = Protocols.	pack_bag_exchange_pos ( src_bag ,src_pos ,dst_bag ,dst_pos)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*包裹操作-交换位置*/	
function Protocols.unpack_bag_exchange_pos (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.src_bag = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.src_pos = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.dst_bag = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.dst_pos = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*包裹操作-销毁物品*/	
function Protocols.pack_bag_destroy ( item_guid ,num ,bag_id)
	local output = Packet.new(CMSG_BAG_DESTROY)
	output:writeUTF(item_guid)
	output:writeU32(num)
	output:writeU32(bag_id)
	return output
end

-- /*包裹操作-销毁物品*/	
function Protocols.call_bag_destroy ( playerInfo, item_guid ,num ,bag_id)
	local output = Protocols.	pack_bag_destroy ( item_guid ,num ,bag_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*包裹操作-销毁物品*/	
function Protocols.unpack_bag_destroy (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.item_guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.num = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.bag_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*分割物品*/	
function Protocols.pack_bag_item_split ( bag_id ,src_pos ,count ,dst_pos ,dst_bag)
	local output = Packet.new(CMSG_BAG_ITEM_SPLIT)
	output:writeByte(bag_id)
	output:writeI16(src_pos)
	output:writeU32(count)
	output:writeI16(dst_pos)
	output:writeByte(dst_bag)
	return output
end

-- /*分割物品*/	
function Protocols.call_bag_item_split ( playerInfo, bag_id ,src_pos ,count ,dst_pos ,dst_bag)
	local output = Protocols.	pack_bag_item_split ( bag_id ,src_pos ,count ,dst_pos ,dst_bag)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*分割物品*/	
function Protocols.unpack_bag_item_split (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.bag_id = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.src_pos = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.count = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.dst_pos = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.dst_bag = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*使用物品*/	
function Protocols.pack_bag_item_user ( item_guid ,count)
	local output = Packet.new(CMSG_BAG_ITEM_USER)
	output:writeUTF(item_guid)
	output:writeU32(count)
	return output
end

-- /*使用物品*/	
function Protocols.call_bag_item_user ( playerInfo, item_guid ,count)
	local output = Protocols.	pack_bag_item_user ( item_guid ,count)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*使用物品*/	
function Protocols.unpack_bag_item_user (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.item_guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.count = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*下发物品冷却*/	
function Protocols.pack_bag_item_cooldown ( list)
	local output = Packet.new(SMSG_BAG_ITEM_COOLDOWN)
	output:writeI16(#list)
	for i = 1,#list,1
	do
		list[i]:write(output)
	end
	return output
end

-- /*下发物品冷却*/	
function Protocols.call_bag_item_cooldown ( playerInfo, list)
	local output = Protocols.	pack_bag_item_cooldown ( list)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*下发物品冷却*/	
function Protocols.unpack_bag_item_cooldown (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,len = input:readU16()
	if not ret then
		return false
	end
	param_table.list = {}
	for i = 1,len,1
	do
		local stru = item_cooldown_info_t .new()
		if(stru:read(input)==false)then
			return false
		end
		table.insert(param_table.list,stru)
	end

	return true,param_table	

end


-- /*grid中的unit移动整体打包*/	
function Protocols.pack_grid_unit_move (  )
	local output = Packet.new(SMSG_GRID_UNIT_MOVE)
	return output
end

-- /*grid中的unit移动整体打包*/	
function Protocols.call_grid_unit_move ( playerInfo )
	local output = Protocols.	pack_grid_unit_move (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*grid中的unit移动整体打包*/	
function Protocols.unpack_grid_unit_move (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*grid中的unit移动整体打包2*/	
function Protocols.pack_grid_unit_move_2 (  )
	local output = Packet.new(SMSG_GRID_UNIT_MOVE_2)
	return output
end

-- /*grid中的unit移动整体打包2*/	
function Protocols.call_grid_unit_move_2 ( playerInfo )
	local output = Protocols.	pack_grid_unit_move_2 (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*grid中的unit移动整体打包2*/	
function Protocols.unpack_grid_unit_move_2 (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*兑换物品*/	
function Protocols.pack_exchange_item ( entry ,count ,tar_entry)
	local output = Packet.new(CMSG_EXCHANGE_ITEM)
	output:writeU32(entry)
	output:writeU32(count)
	output:writeU32(tar_entry)
	return output
end

-- /*兑换物品*/	
function Protocols.call_exchange_item ( playerInfo, entry ,count ,tar_entry)
	local output = Protocols.	pack_exchange_item ( entry ,count ,tar_entry)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*兑换物品*/	
function Protocols.unpack_exchange_item (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.entry = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.count = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.tar_entry = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*背包扩展*/	
function Protocols.pack_bag_extension ( bag_id ,extension_type ,bag_pos)
	local output = Packet.new(CMSG_BAG_EXTENSION)
	output:writeByte(bag_id)
	output:writeByte(extension_type)
	output:writeU32(bag_pos)
	return output
end

-- /*背包扩展*/	
function Protocols.call_bag_extension ( playerInfo, bag_id ,extension_type ,bag_pos)
	local output = Protocols.	pack_bag_extension ( bag_id ,extension_type ,bag_pos)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*背包扩展*/	
function Protocols.unpack_bag_extension (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.bag_id = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.extension_type = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.bag_pos = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*请求NPC商品列表*/	
function Protocols.pack_npc_get_goods_list ( npc_id)
	local output = Packet.new(CMSG_NPC_GET_GOODS_LIST)
	output:writeU32(npc_id)
	return output
end

-- /*请求NPC商品列表*/	
function Protocols.call_npc_get_goods_list ( playerInfo, npc_id)
	local output = Protocols.	pack_npc_get_goods_list ( npc_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*请求NPC商品列表*/	
function Protocols.unpack_npc_get_goods_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.npc_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*Npc商品列表*/	
function Protocols.pack_npc_goods_list ( goods ,npc_id)
	local output = Packet.new(SMSG_NPC_GOODS_LIST)
	output:writeI16(#goods)
	for i = 1,#goods,1
	do
					output:writeU32(goods[i])
			end
	output:writeU32(npc_id)
	return output
end

-- /*Npc商品列表*/	
function Protocols.call_npc_goods_list ( playerInfo, goods ,npc_id)
	local output = Protocols.	pack_npc_goods_list ( goods ,npc_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*Npc商品列表*/	
function Protocols.unpack_npc_goods_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	param_table.goods = {}
	ret,len = input:readU16()
	if not ret then
		return false
	end
	
	for i = 1,len,1
	do
					ret,param_table.goods[i] = input:readU32()
				if not ret then
			return false
		end
	end
	ret,param_table.npc_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*购买商品*/	
function Protocols.pack_npc_buy ( id ,num ,npc_id ,do_use ,money_type)
	local output = Packet.new(CMSG_NPC_BUY)
	output:writeU32(id)
	output:writeU32(num)
	output:writeU32(npc_id)
	output:writeByte(do_use)
	output:writeByte(money_type)
	return output
end

-- /*购买商品*/	
function Protocols.call_npc_buy ( playerInfo, id ,num ,npc_id ,do_use ,money_type)
	local output = Protocols.	pack_npc_buy ( id ,num ,npc_id ,do_use ,money_type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*购买商品*/	
function Protocols.unpack_npc_buy (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.num = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.npc_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.do_use = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.money_type = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*出售物品*/	
function Protocols.pack_npc_sell ( npc_id ,item_guid ,num)
	local output = Packet.new(CMSG_NPC_SELL)
	output:writeU32(npc_id)
	output:writeUTF(item_guid)
	output:writeU32(num)
	return output
end

-- /*出售物品*/	
function Protocols.call_npc_sell ( playerInfo, npc_id ,item_guid ,num)
	local output = Protocols.	pack_npc_sell ( npc_id ,item_guid ,num)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*出售物品*/	
function Protocols.unpack_npc_sell (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.npc_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.item_guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.num = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*回购物品*/	
function Protocols.pack_npc_repurchase ( item_id)
	local output = Packet.new(CMSG_NPC_REPURCHASE)
	output:writeUTF(item_id)
	return output
end

-- /*回购物品*/	
function Protocols.call_npc_repurchase ( playerInfo, item_id)
	local output = Protocols.	pack_npc_repurchase ( item_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*回购物品*/	
function Protocols.unpack_npc_repurchase (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.item_id = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*时装是否启用*/	
function Protocols.pack_avatar_fashion_enable ( pos)
	local output = Packet.new(CMSG_AVATAR_FASHION_ENABLE)
	output:writeByte(pos)
	return output
end

-- /*时装是否启用*/	
function Protocols.call_avatar_fashion_enable ( playerInfo, pos)
	local output = Protocols.	pack_avatar_fashion_enable ( pos)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*时装是否启用*/	
function Protocols.unpack_avatar_fashion_enable (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.pos = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*任务对话选项*/	
function Protocols.pack_questhelp_talk_option ( quest_id ,option_id ,value0 ,value1)
	local output = Packet.new(CMSG_QUESTHELP_TALK_OPTION)
	output:writeU32(quest_id)
	output:writeU32(option_id)
	output:writeI32(value0)
	output:writeI32(value1)
	return output
end

-- /*任务对话选项*/	
function Protocols.call_questhelp_talk_option ( playerInfo, quest_id ,option_id ,value0 ,value1)
	local output = Protocols.	pack_questhelp_talk_option ( quest_id ,option_id ,value0 ,value1)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务对话选项*/	
function Protocols.unpack_questhelp_talk_option (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.option_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.value0 = input:readI32()
	if not ret then
		return false
	end	
	ret,param_table.value1 = input:readI32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*与NPC对话获得传送点列表*/	
function Protocols.pack_taxi_hello ( guid)
	local output = Packet.new(CMSG_TAXI_HELLO)
	output:writeU32(guid)
	return output
end

-- /*与NPC对话获得传送点列表*/	
function Protocols.call_taxi_hello ( playerInfo, guid)
	local output = Protocols.	pack_taxi_hello ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*与NPC对话获得传送点列表*/	
function Protocols.unpack_taxi_hello (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*发送传送点列表*/	
function Protocols.pack_taxi_stations_list ( npcid ,stations)
	local output = Packet.new(SMSG_TAXI_STATIONS_LIST)
	output:writeU32(npcid)
	output:writeI16(#stations)
	for i = 1,#stations,1
	do
		stations[i]:write(output)
	end
	return output
end

-- /*发送传送点列表*/	
function Protocols.call_taxi_stations_list ( playerInfo, npcid ,stations)
	local output = Protocols.	pack_taxi_stations_list ( npcid ,stations)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*发送传送点列表*/	
function Protocols.unpack_taxi_stations_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.npcid = input:readU32()
	if not ret then
		return false
	end	
	ret,len = input:readU16()
	if not ret then
		return false
	end
	param_table.stations = {}
	for i = 1,len,1
	do
		local stru = taxi_menu_info_t .new()
		if(stru:read(input)==false)then
			return false
		end
		table.insert(param_table.stations,stru)
	end

	return true,param_table	

end


-- /*选择传送点*/	
function Protocols.pack_taxi_select_station ( station_id ,guid)
	local output = Packet.new(CMSG_TAXI_SELECT_STATION)
	output:writeU32(station_id)
	output:writeU32(guid)
	return output
end

-- /*选择传送点*/	
function Protocols.call_taxi_select_station ( playerInfo, station_id ,guid)
	local output = Protocols.	pack_taxi_select_station ( station_id ,guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*选择传送点*/	
function Protocols.unpack_taxi_select_station (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.station_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*与NPC交流选择选项*/	
function Protocols.pack_gossip_select_option ( option ,guid ,unknow)
	local output = Packet.new(CMSG_GOSSIP_SELECT_OPTION)
	output:writeU32(option)
	output:writeU32(guid)
	output:writeUTF(unknow)
	return output
end

-- /*与NPC交流选择选项*/	
function Protocols.call_gossip_select_option ( playerInfo, option ,guid ,unknow)
	local output = Protocols.	pack_gossip_select_option ( option ,guid ,unknow)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*与NPC交流选择选项*/	
function Protocols.unpack_gossip_select_option (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.option = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.unknow = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*与NPC闲聊获取选项*/	
function Protocols.pack_gossip_hello ( guid)
	local output = Packet.new(CMSG_GOSSIP_HELLO)
	output:writeU32(guid)
	return output
end

-- /*与NPC闲聊获取选项*/	
function Protocols.call_gossip_hello ( playerInfo, guid)
	local output = Protocols.	pack_gossip_hello ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*与NPC闲聊获取选项*/	
function Protocols.unpack_gossip_hello (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*发送闲聊信息和选项*/	
function Protocols.pack_gossip_message ( npcid ,npc_entry ,option_id ,option_text ,gossip_items)
	local output = Packet.new(SMSG_GOSSIP_MESSAGE)
	output:writeU32(npcid)
	output:writeU32(npc_entry)
	output:writeU32(option_id)
	output:writeUTF(option_text)
	output:writeI16(#gossip_items)
	for i = 1,#gossip_items,1
	do
		gossip_items[i]:write(output)
	end
	return output
end

-- /*发送闲聊信息和选项*/	
function Protocols.call_gossip_message ( playerInfo, npcid ,npc_entry ,option_id ,option_text ,gossip_items)
	local output = Protocols.	pack_gossip_message ( npcid ,npc_entry ,option_id ,option_text ,gossip_items)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*发送闲聊信息和选项*/	
function Protocols.unpack_gossip_message (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.npcid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.npc_entry = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.option_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.option_text = input:readUTF()
	if not ret then
		return false
	end	
	ret,len = input:readU16()
	if not ret then
		return false
	end
	param_table.gossip_items = {}
	for i = 1,len,1
	do
		local stru = gossip_menu_option_info_t .new()
		if(stru:read(input)==false)then
			return false
		end
		table.insert(param_table.gossip_items,stru)
	end

	return true,param_table	

end


-- /*任务发布者状态查询*/	
function Protocols.pack_questgiver_status_query ( guid)
	local output = Packet.new(CMSG_QUESTGIVER_STATUS_QUERY)
	output:writeU32(guid)
	return output
end

-- /*任务发布者状态查询*/	
function Protocols.call_questgiver_status_query ( playerInfo, guid)
	local output = Protocols.	pack_questgiver_status_query ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务发布者状态查询*/	
function Protocols.unpack_questgiver_status_query (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*任务NPC状态*/	
function Protocols.pack_questgiver_status ( guid ,status)
	local output = Packet.new(SMSG_QUESTGIVER_STATUS)
	output:writeU32(guid)
	output:writeByte(status)
	return output
end

-- /*任务NPC状态*/	
function Protocols.call_questgiver_status ( playerInfo, guid ,status)
	local output = Protocols.	pack_questgiver_status ( guid ,status)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务NPC状态*/	
function Protocols.unpack_questgiver_status (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.status = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*查询任务状态*/	
function Protocols.pack_query_quest_status ( quest_array)
	local output = Packet.new(MSG_QUERY_QUEST_STATUS)
	output:writeI16(#quest_array)
	for i = 1,#quest_array,1
	do
		quest_array[i]:write(output)
	end
	return output
end

-- /*查询任务状态*/	
function Protocols.call_query_quest_status ( playerInfo, quest_array)
	local output = Protocols.	pack_query_quest_status ( quest_array)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*查询任务状态*/	
function Protocols.unpack_query_quest_status (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,len = input:readU16()
	if not ret then
		return false
	end
	param_table.quest_array = {}
	for i = 1,len,1
	do
		local stru = quest_status_t .new()
		if(stru:read(input)==false)then
			return false
		end
		table.insert(param_table.quest_array,stru)
	end

	return true,param_table	

end


-- /*可接任务*/	
function Protocols.pack_questhelp_get_canaccept_list (  )
	local output = Packet.new(CMSG_QUESTHELP_GET_CANACCEPT_LIST)
	return output
end

-- /*可接任务*/	
function Protocols.call_questhelp_get_canaccept_list ( playerInfo )
	local output = Protocols.	pack_questhelp_get_canaccept_list (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*可接任务*/	
function Protocols.unpack_questhelp_get_canaccept_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*下发可接任务列表*/	
function Protocols.pack_questhelp_canaccept_list ( quests)
	local output = Packet.new(SMSG_QUESTHELP_CANACCEPT_LIST)
	output:writeI16(#quests)
	for i = 1,#quests,1
	do
					output:writeU32(quests[i])
			end
	return output
end

-- /*下发可接任务列表*/	
function Protocols.call_questhelp_canaccept_list ( playerInfo, quests)
	local output = Protocols.	pack_questhelp_canaccept_list ( quests)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*下发可接任务列表*/	
function Protocols.unpack_questhelp_canaccept_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	param_table.quests = {}
	ret,len = input:readU16()
	if not ret then
		return false
	end
	
	for i = 1,len,1
	do
					ret,param_table.quests[i] = input:readU32()
				if not ret then
			return false
		end
	end

	return true,param_table	

end


-- /*任务失败*/	
function Protocols.pack_questupdate_faild ( reason)
	local output = Packet.new(SMSG_QUESTUPDATE_FAILD)
	output:writeByte(reason)
	return output
end

-- /*任务失败*/	
function Protocols.call_questupdate_faild ( playerInfo, reason)
	local output = Protocols.	pack_questupdate_faild ( reason)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务失败*/	
function Protocols.unpack_questupdate_faild (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.reason = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*任务条件完成*/	
function Protocols.pack_questupdate_complete ( quest_id)
	local output = Packet.new(SMSG_QUESTUPDATE_COMPLETE)
	output:writeU32(quest_id)
	return output
end

-- /*任务条件完成*/	
function Protocols.call_questupdate_complete ( playerInfo, quest_id)
	local output = Protocols.	pack_questupdate_complete ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务条件完成*/	
function Protocols.unpack_questupdate_complete (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*放弃任务*/	
function Protocols.pack_questlog_remove_quest ( slot ,reserve)
	local output = Packet.new(CMSG_QUESTLOG_REMOVE_QUEST)
	output:writeByte(slot)
	return output
end

-- /*放弃任务*/	
function Protocols.call_questlog_remove_quest ( playerInfo, slot ,reserve)
	local output = Protocols.	pack_questlog_remove_quest ( slot ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*放弃任务*/	
function Protocols.unpack_questlog_remove_quest (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.slot = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*完成任务*/	
function Protocols.pack_questgiver_complete_quest ( guid ,quest_id ,reward)
	local output = Packet.new(CMSG_QUESTGIVER_COMPLETE_QUEST)
	output:writeU32(guid)
	output:writeU32(quest_id)
	output:writeByte(reward)
	return output
end

-- /*完成任务*/	
function Protocols.call_questgiver_complete_quest ( playerInfo, guid ,quest_id ,reward)
	local output = Protocols.	pack_questgiver_complete_quest ( guid ,quest_id ,reward)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*完成任务*/	
function Protocols.unpack_questgiver_complete_quest (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.reward = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*完成任务后通知任务链的下个任务*/	
function Protocols.pack_questhelp_next ( current_id ,next_id ,guid)
	local output = Packet.new(SMSG_QUESTHELP_NEXT)
	output:writeU32(current_id)
	output:writeU32(next_id)
	output:writeU32(guid)
	return output
end

-- /*完成任务后通知任务链的下个任务*/	
function Protocols.call_questhelp_next ( playerInfo, current_id ,next_id ,guid)
	local output = Protocols.	pack_questhelp_next ( current_id ,next_id ,guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*完成任务后通知任务链的下个任务*/	
function Protocols.unpack_questhelp_next (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.current_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.next_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*任务系统强制完成任务*/	
function Protocols.pack_questhelp_complete ( quest_id ,quest_statue ,reserve)
	local output = Packet.new(CMSG_QUESTHELP_COMPLETE)
	output:writeU32(quest_id)
	output:writeByte(quest_statue)
	output:writeByte(reserve)
	return output
end

-- /*任务系统强制完成任务*/	
function Protocols.call_questhelp_complete ( playerInfo, quest_id ,quest_statue ,reserve)
	local output = Protocols.	pack_questhelp_complete ( quest_id ,quest_statue ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务系统强制完成任务*/	
function Protocols.unpack_questhelp_complete (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.quest_statue = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.reserve = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*接受任务成功*/	
function Protocols.pack_questupdate_accept ( quest_id)
	local output = Packet.new(SMSG_QUESTUPDATE_ACCEPT)
	output:writeU32(quest_id)
	return output
end

-- /*接受任务成功*/	
function Protocols.call_questupdate_accept ( playerInfo, quest_id)
	local output = Protocols.	pack_questupdate_accept ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*接受任务成功*/	
function Protocols.unpack_questupdate_accept (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*更新任务进度_下标数量*/	
function Protocols.pack_questhelp_update_status ( quest_id ,slot_id ,num)
	local output = Packet.new(CMSG_QUESTHELP_UPDATE_STATUS)
	output:writeU32(quest_id)
	output:writeU32(slot_id)
	output:writeU32(num)
	return output
end

-- /*更新任务进度_下标数量*/	
function Protocols.call_questhelp_update_status ( playerInfo, quest_id ,slot_id ,num)
	local output = Protocols.	pack_questhelp_update_status ( quest_id ,slot_id ,num)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*更新任务进度_下标数量*/	
function Protocols.unpack_questhelp_update_status (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.slot_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.num = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*任务已完成*/	
function Protocols.pack_questgetter_complete ( quest_id)
	local output = Packet.new(SMSG_QUESTGETTER_COMPLETE)
	output:writeU32(quest_id)
	return output
end

-- /*任务已完成*/	
function Protocols.call_questgetter_complete ( playerInfo, quest_id)
	local output = Protocols.	pack_questgetter_complete ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务已完成*/	
function Protocols.unpack_questgetter_complete (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*接任务*/	
function Protocols.pack_questgiver_accept_quest ( npcid ,quest_id)
	local output = Packet.new(CMSG_QUESTGIVER_ACCEPT_QUEST)
	output:writeU32(npcid)
	output:writeU32(quest_id)
	return output
end

-- /*接任务*/	
function Protocols.call_questgiver_accept_quest ( playerInfo, npcid ,quest_id)
	local output = Protocols.	pack_questgiver_accept_quest ( npcid ,quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*接任务*/	
function Protocols.unpack_questgiver_accept_quest (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.npcid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*任务使用物品*/	
function Protocols.pack_questupdate_use_item ( item_id)
	local output = Packet.new(CMSG_QUESTUPDATE_USE_ITEM)
	output:writeU32(item_id)
	return output
end

-- /*任务使用物品*/	
function Protocols.call_questupdate_use_item ( playerInfo, item_id)
	local output = Protocols.	pack_questupdate_use_item ( item_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*任务使用物品*/	
function Protocols.unpack_questupdate_use_item (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.item_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*查询天书任务*/	
function Protocols.pack_questhelp_query_book ( dynasty)
	local output = Packet.new(CMSG_QUESTHELP_QUERY_BOOK)
	output:writeU32(dynasty)
	return output
end

-- /*查询天书任务*/	
function Protocols.call_questhelp_query_book ( playerInfo, dynasty)
	local output = Protocols.	pack_questhelp_query_book ( dynasty)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*查询天书任务*/	
function Protocols.unpack_questhelp_query_book (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.dynasty = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*下发可接天书任务*/	
function Protocols.pack_questhelp_book_quest ( quest_id)
	local output = Packet.new(SMSG_QUESTHELP_BOOK_QUEST)
	output:writeU32(quest_id)
	return output
end

-- /*下发可接天书任务*/	
function Protocols.call_questhelp_book_quest ( playerInfo, quest_id)
	local output = Protocols.	pack_questhelp_book_quest ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*下发可接天书任务*/	
function Protocols.unpack_questhelp_book_quest (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.quest_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*玩家使用游戏对象以后的动作*/	
function Protocols.pack_use_gameobject_action ( player_id ,gameobject_id)
	local output = Packet.new(SMSG_USE_GAMEOBJECT_ACTION)
	output:writeU32(player_id)
	output:writeU32(gameobject_id)
	return output
end

-- /*玩家使用游戏对象以后的动作*/	
function Protocols.call_use_gameobject_action ( playerInfo, player_id ,gameobject_id)
	local output = Protocols.	pack_use_gameobject_action ( player_id ,gameobject_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*玩家使用游戏对象以后的动作*/	
function Protocols.unpack_use_gameobject_action (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.player_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.gameobject_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*设置攻击模式*/	
function Protocols.pack_set_attack_mode ( mode ,reserve)
	local output = Packet.new(CMSG_SET_ATTACK_MODE)
	output:writeByte(mode)
	return output
end

-- /*设置攻击模式*/	
function Protocols.call_set_attack_mode ( playerInfo, mode ,reserve)
	local output = Protocols.	pack_set_attack_mode ( mode ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*设置攻击模式*/	
function Protocols.unpack_set_attack_mode (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.mode = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*选择目标*/	
function Protocols.pack_select_target ( id)
	local output = Packet.new(MSG_SELECT_TARGET)
	output:writeU32(id)
	return output
end

-- /*选择目标*/	
function Protocols.call_select_target ( playerInfo, id)
	local output = Protocols.	pack_select_target ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*选择目标*/	
function Protocols.unpack_select_target (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*进入战斗*/	
function Protocols.pack_combat_state_update ( cur_state)
	local output = Packet.new(SMSG_COMBAT_STATE_UPDATE)
	output:writeByte(cur_state)
	return output
end

-- /*进入战斗*/	
function Protocols.call_combat_state_update ( playerInfo, cur_state)
	local output = Protocols.	pack_combat_state_update ( cur_state)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*进入战斗*/	
function Protocols.unpack_combat_state_update (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.cur_state = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*经验更新*/	
function Protocols.pack_exp_update ( exp ,type ,vip_exp)
	local output = Packet.new(SMSG_EXP_UPDATE)
	output:writeI32(exp)
	output:writeByte(type)
	output:writeI32(vip_exp)
	return output
end

-- /*经验更新*/	
function Protocols.call_exp_update ( playerInfo, exp ,type ,vip_exp)
	local output = Protocols.	pack_exp_update ( exp ,type ,vip_exp)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*经验更新*/	
function Protocols.unpack_exp_update (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.exp = input:readI32()
	if not ret then
		return false
	end	
	ret,param_table.type = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.vip_exp = input:readI32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*客户端释放技能*/	
function Protocols.pack_spell_start ( spell_id ,target_pos_x ,target_pos_y ,caster ,target)
	local output = Packet.new(MSG_SPELL_START)
	output:writeU32(spell_id)
	output:writeI16(target_pos_x)
	output:writeI16(target_pos_y)
	output:writeU32(caster)
	output:writeU32(target)
	return output
end

-- /*客户端释放技能*/	
function Protocols.call_spell_start ( playerInfo, spell_id ,target_pos_x ,target_pos_y ,caster ,target)
	local output = Protocols.	pack_spell_start ( spell_id ,target_pos_x ,target_pos_y ,caster ,target)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*客户端释放技能*/	
function Protocols.unpack_spell_start (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.spell_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.target_pos_x = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.target_pos_y = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.caster = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.target = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*施法停止*/	
function Protocols.pack_spell_stop ( guid)
	local output = Packet.new(MSG_SPELL_STOP)
	output:writeUTF(guid)
	return output
end

-- /*施法停止*/	
function Protocols.call_spell_stop ( playerInfo, guid)
	local output = Protocols.	pack_spell_stop ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*施法停止*/	
function Protocols.unpack_spell_stop (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*跳*/	
function Protocols.pack_jump ( guid ,pos_x ,pos_y)
	local output = Packet.new(MSG_JUMP)
	output:writeU32(guid)
	output:writeFloat(pos_x)
	output:writeFloat(pos_y)
	return output
end

-- /*跳*/	
function Protocols.call_jump ( playerInfo, guid ,pos_x ,pos_y)
	local output = Protocols.	pack_jump ( guid ,pos_x ,pos_y)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*跳*/	
function Protocols.unpack_jump (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.pos_x = input:readFloat()
	if not ret then
		return false
	end
	ret,param_table.pos_y = input:readFloat()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*复活*/	
function Protocols.pack_resurrection ( type ,reserve)
	local output = Packet.new(CMSG_RESURRECTION)
	output:writeByte(type)
	return output
end

-- /*复活*/	
function Protocols.call_resurrection ( playerInfo, type ,reserve)
	local output = Protocols.	pack_resurrection ( type ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*复活*/	
function Protocols.unpack_resurrection (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.type = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*交易发出请求*/	
function Protocols.pack_trade_request ( guid)
	local output = Packet.new(MSG_TRADE_REQUEST)
	output:writeUTF(guid)
	return output
end

-- /*交易发出请求*/	
function Protocols.call_trade_request ( playerInfo, guid)
	local output = Protocols.	pack_trade_request ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*交易发出请求*/	
function Protocols.unpack_trade_request (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*交易请求答复*/	
function Protocols.pack_trade_reply ( guid ,reply)
	local output = Packet.new(MSG_TRADE_REPLY)
	output:writeUTF(guid)
	output:writeByte(reply)
	return output
end

-- /*交易请求答复*/	
function Protocols.call_trade_reply ( playerInfo, guid ,reply)
	local output = Protocols.	pack_trade_reply ( guid ,reply)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*交易请求答复*/	
function Protocols.unpack_trade_reply (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.reply = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*交易开始*/	
function Protocols.pack_trade_start ( guid)
	local output = Packet.new(SMSG_TRADE_START)
	output:writeUTF(guid)
	return output
end

-- /*交易开始*/	
function Protocols.call_trade_start ( playerInfo, guid)
	local output = Protocols.	pack_trade_start ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*交易开始*/	
function Protocols.unpack_trade_start (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*交易确认物品*/	
function Protocols.pack_trade_decide_items ( items ,gold_ingot ,silver)
	local output = Packet.new(MSG_TRADE_DECIDE_ITEMS)
	output:writeI16(items)
	for i = 1,#items,1
	do
		output:writeUTF(items[i])
	end
	output:writeI32(gold_ingot)
	output:writeI32(silver)
	return output
end

-- /*交易确认物品*/	
function Protocols.call_trade_decide_items ( playerInfo, items ,gold_ingot ,silver)
	local output = Protocols.	pack_trade_decide_items ( items ,gold_ingot ,silver)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*交易确认物品*/	
function Protocols.unpack_trade_decide_items (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,len = input:readU16()
	if not ret then
		return false
	end
	param_table.items = {}
	for i = 1,len,1
	do
		ret, str = input:readUTF()
		if not ret then
			return false
		end		
		table.insert(param_table.items,str)
	end
	ret,param_table.gold_ingot = input:readI32()
	if not ret then
		return false
	end	
	ret,param_table.silver = input:readI32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*交易完成*/	
function Protocols.pack_trade_finish (  )
	local output = Packet.new(SMSG_TRADE_FINISH)
	return output
end

-- /*交易完成*/	
function Protocols.call_trade_finish ( playerInfo )
	local output = Protocols.	pack_trade_finish (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*交易完成*/	
function Protocols.unpack_trade_finish (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*交易取消*/	
function Protocols.pack_trade_cancel (  )
	local output = Packet.new(MSG_TRADE_CANCEL)
	return output
end

-- /*交易取消*/	
function Protocols.call_trade_cancel ( playerInfo )
	local output = Protocols.	pack_trade_cancel (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*交易取消*/	
function Protocols.unpack_trade_cancel (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*交易准备好*/	
function Protocols.pack_trade_ready (  )
	local output = Packet.new(MSG_TRADE_READY)
	return output
end

-- /*交易准备好*/	
function Protocols.call_trade_ready ( playerInfo )
	local output = Protocols.	pack_trade_ready (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*交易准备好*/	
function Protocols.unpack_trade_ready (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*生物讲话*/	
function Protocols.pack_chat_unit_talk ( guid ,content ,say)
	local output = Packet.new(SMSG_CHAT_UNIT_TALK)
	output:writeU32(guid)
	output:writeU32(content)
	output:writeUTF(say)
	return output
end

-- /*生物讲话*/	
function Protocols.call_chat_unit_talk ( playerInfo, guid ,content ,say)
	local output = Protocols.	pack_chat_unit_talk ( guid ,content ,say)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*生物讲话*/	
function Protocols.unpack_chat_unit_talk (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.say = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*就近聊天*/	
function Protocols.pack_chat_near ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_NEAR)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*就近聊天*/	
function Protocols.call_chat_near ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_near ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*就近聊天*/	
function Protocols.unpack_chat_near (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.faction = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.name = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*私聊*/	
function Protocols.pack_chat_whisper ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_WHISPER)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*私聊*/	
function Protocols.call_chat_whisper ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_whisper ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*私聊*/	
function Protocols.unpack_chat_whisper (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.faction = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.name = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*阵营聊天*/	
function Protocols.pack_chat_faction ( guid ,name ,content ,faction)
	local output = Packet.new(MSG_CHAT_FACTION)
	output:writeUTF(guid)
	output:writeUTF(name)
	output:writeUTF(content)
	output:writeByte(faction)
	return output
end

-- /*阵营聊天*/	
function Protocols.call_chat_faction ( playerInfo, guid ,name ,content ,faction)
	local output = Protocols.	pack_chat_faction ( guid ,name ,content ,faction)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*阵营聊天*/	
function Protocols.unpack_chat_faction (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.name = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.faction = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*世界*/	
function Protocols.pack_chat_world ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_WORLD)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*世界*/	
function Protocols.call_chat_world ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_world ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*世界*/	
function Protocols.unpack_chat_world (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.faction = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.name = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*喇叭*/	
function Protocols.pack_chat_horn ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_HORN)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*喇叭*/	
function Protocols.call_chat_horn ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_horn ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*喇叭*/	
function Protocols.unpack_chat_horn (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.faction = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.name = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*公告*/	
function Protocols.pack_chat_notice ( id ,content ,data)
	local output = Packet.new(MSG_CHAT_NOTICE)
	output:writeU32(id)
	output:writeUTF(content)
	output:writeUTF(data)
	return output
end

-- /*公告*/	
function Protocols.call_chat_notice ( playerInfo, id ,content ,data)
	local output = Protocols.	pack_chat_notice ( id ,content ,data)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*公告*/	
function Protocols.unpack_chat_notice (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.data = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*查询玩家信息*/	
function Protocols.pack_query_player_info ( guid ,flag ,callback_id)
	local output = Packet.new(CMSG_QUERY_PLAYER_INFO)
	output:writeUTF(guid)
	output:writeU32(flag)
	output:writeU32(callback_id)
	return output
end

-- /*查询玩家信息*/	
function Protocols.call_query_player_info ( playerInfo, guid ,flag ,callback_id)
	local output = Protocols.	pack_query_player_info ( guid ,flag ,callback_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*查询玩家信息*/	
function Protocols.unpack_query_player_info (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.flag = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.callback_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*查询信息对象更新*/	
function Protocols.pack_query_result_update_object (  )
	local output = Packet.new(SMSG_QUERY_RESULT_UPDATE_OBJECT)
	return output
end

-- /*查询信息对象更新*/	
function Protocols.call_query_result_update_object ( playerInfo )
	local output = Protocols.	pack_query_result_update_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*查询信息对象更新*/	
function Protocols.unpack_query_result_update_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*领取礼包*/	
function Protocols.pack_receive_gift_packs (  )
	local output = Packet.new(CMSG_RECEIVE_GIFT_PACKS)
	return output
end

-- /*领取礼包*/	
function Protocols.call_receive_gift_packs ( playerInfo )
	local output = Protocols.	pack_receive_gift_packs (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*领取礼包*/	
function Protocols.unpack_receive_gift_packs (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*地图对象更新*/	
function Protocols.pack_map_update_object (  )
	local output = Packet.new(SMSG_MAP_UPDATE_OBJECT)
	return output
end

-- /*地图对象更新*/	
function Protocols.call_map_update_object ( playerInfo )
	local output = Protocols.	pack_map_update_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*地图对象更新*/	
function Protocols.unpack_map_update_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*战斗信息binlog*/	
function Protocols.pack_fighting_info_update_object (  )
	local output = Packet.new(SMSG_FIGHTING_INFO_UPDATE_OBJECT)
	return output
end

-- /*战斗信息binlog*/	
function Protocols.call_fighting_info_update_object ( playerInfo )
	local output = Protocols.	pack_fighting_info_update_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*战斗信息binlog*/	
function Protocols.unpack_fighting_info_update_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*战斗信息binlog*/	
function Protocols.pack_fighting_info_update_object_2 (  )
	local output = Packet.new(SMSG_FIGHTING_INFO_UPDATE_OBJECT_2)
	return output
end

-- /*战斗信息binlog*/	
function Protocols.call_fighting_info_update_object_2 ( playerInfo )
	local output = Protocols.	pack_fighting_info_update_object_2 (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*战斗信息binlog*/	
function Protocols.unpack_fighting_info_update_object_2 (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*进入副本*/	
function Protocols.pack_instance_enter ( instance_id)
	local output = Packet.new(CMSG_INSTANCE_ENTER)
	output:writeU32(instance_id)
	return output
end

-- /*进入副本*/	
function Protocols.call_instance_enter ( playerInfo, instance_id)
	local output = Protocols.	pack_instance_enter ( instance_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*进入副本*/	
function Protocols.unpack_instance_enter (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.instance_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*向服务端发送副本进入下一阶段指令*/	
function Protocols.pack_instance_next_state ( level ,param)
	local output = Packet.new(CMSG_INSTANCE_NEXT_STATE)
	output:writeI16(level)
	output:writeU32(param)
	return output
end

-- /*向服务端发送副本进入下一阶段指令*/	
function Protocols.call_instance_next_state ( playerInfo, level ,param)
	local output = Protocols.	pack_instance_next_state ( level ,param)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*向服务端发送副本进入下一阶段指令*/	
function Protocols.unpack_instance_next_state (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.level = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.param = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*副本退出*/	
function Protocols.pack_instance_exit ( reserve)
	local output = Packet.new(CMSG_INSTANCE_EXIT)
	output:writeU32(reserve)
	return output
end

-- /*副本退出*/	
function Protocols.call_instance_exit ( playerInfo, reserve)
	local output = Protocols.	pack_instance_exit ( reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*副本退出*/	
function Protocols.unpack_instance_exit (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.reserve = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*限时活动领取*/	
function Protocols.pack_limit_activity_receive ( id ,type)
	local output = Packet.new(CMSG_LIMIT_ACTIVITY_RECEIVE)
	output:writeU32(id)
	output:writeU32(type)
	return output
end

-- /*限时活动领取*/	
function Protocols.call_limit_activity_receive ( playerInfo, id ,type)
	local output = Protocols.	pack_limit_activity_receive ( id ,type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*限时活动领取*/	
function Protocols.unpack_limit_activity_receive (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.type = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*杀人啦~~！！！！*/	
function Protocols.pack_kill_man ( killer ,killer_name ,victim ,victim_name)
	local output = Packet.new(SMSG_KILL_MAN)
	output:writeUTF(killer)
	output:writeUTF(killer_name)
	output:writeUTF(victim)
	output:writeUTF(victim_name)
	return output
end

-- /*杀人啦~~！！！！*/	
function Protocols.call_kill_man ( playerInfo, killer ,killer_name ,victim ,victim_name)
	local output = Protocols.	pack_kill_man ( killer ,killer_name ,victim ,victim_name)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*杀人啦~~！！！！*/	
function Protocols.unpack_kill_man (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.killer = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.killer_name = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.victim = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.victim_name = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*玩家升级*/	
function Protocols.pack_player_upgrade ( guid)
	local output = Packet.new(SMSG_PLAYER_UPGRADE)
	output:writeU32(guid)
	return output
end

-- /*玩家升级*/	
function Protocols.call_player_upgrade ( playerInfo, guid)
	local output = Protocols.	pack_player_upgrade ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*玩家升级*/	
function Protocols.unpack_player_upgrade (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*仓库存钱*/	
function Protocols.pack_warehouse_save_money ( money ,money_gold ,money_bills)
	local output = Packet.new(CMSG_WAREHOUSE_SAVE_MONEY)
	output:writeI32(money)
	output:writeI32(money_gold)
	output:writeI32(money_bills)
	return output
end

-- /*仓库存钱*/	
function Protocols.call_warehouse_save_money ( playerInfo, money ,money_gold ,money_bills)
	local output = Protocols.	pack_warehouse_save_money ( money ,money_gold ,money_bills)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*仓库存钱*/	
function Protocols.unpack_warehouse_save_money (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.money = input:readI32()
	if not ret then
		return false
	end	
	ret,param_table.money_gold = input:readI32()
	if not ret then
		return false
	end	
	ret,param_table.money_bills = input:readI32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*仓库取钱*/	
function Protocols.pack_warehouse_take_money ( money ,money_gold ,money_bills)
	local output = Packet.new(CMSG_WAREHOUSE_TAKE_MONEY)
	output:writeI32(money)
	output:writeI32(money_gold)
	output:writeI32(money_bills)
	return output
end

-- /*仓库取钱*/	
function Protocols.call_warehouse_take_money ( playerInfo, money ,money_gold ,money_bills)
	local output = Protocols.	pack_warehouse_take_money ( money ,money_gold ,money_bills)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*仓库取钱*/	
function Protocols.unpack_warehouse_take_money (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.money = input:readI32()
	if not ret then
		return false
	end	
	ret,param_table.money_gold = input:readI32()
	if not ret then
		return false
	end	
	ret,param_table.money_bills = input:readI32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*使用元宝操作某事*/	
function Protocols.pack_use_gold_opt ( type ,param)
	local output = Packet.new(CMSG_USE_GOLD_OPT)
	output:writeByte(type)
	output:writeUTF(param)
	return output
end

-- /*使用元宝操作某事*/	
function Protocols.call_use_gold_opt ( playerInfo, type ,param)
	local output = Protocols.	pack_use_gold_opt ( type ,param)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*使用元宝操作某事*/	
function Protocols.unpack_use_gold_opt (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.type = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.param = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*使用铜钱操作某事*/	
function Protocols.pack_use_silver_opt ( type)
	local output = Packet.new(CMSG_USE_SILVER_OPT)
	output:writeByte(type)
	return output
end

-- /*使用铜钱操作某事*/	
function Protocols.call_use_silver_opt ( playerInfo, type)
	local output = Protocols.	pack_use_silver_opt ( type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*使用铜钱操作某事*/	
function Protocols.unpack_use_silver_opt (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.type = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*后台弹窗*/	
function Protocols.pack_gm_rightfloat ( id ,end_time ,zone1 ,zone2 ,zone3 ,subject ,content ,link ,mode)
	local output = Packet.new(SMSG_GM_RIGHTFLOAT)
	output:writeU32(id)
	output:writeU32(end_time)
	output:writeU32(zone1)
	output:writeU32(zone2)
	output:writeU32(zone3)
	output:writeUTF(subject)
	output:writeUTF(content)
	output:writeUTF(link)
	output:writeByte(mode)
	return output
end

-- /*后台弹窗*/	
function Protocols.call_gm_rightfloat ( playerInfo, id ,end_time ,zone1 ,zone2 ,zone3 ,subject ,content ,link ,mode)
	local output = Protocols.	pack_gm_rightfloat ( id ,end_time ,zone1 ,zone2 ,zone3 ,subject ,content ,link ,mode)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*后台弹窗*/	
function Protocols.unpack_gm_rightfloat (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.end_time = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.zone1 = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.zone2 = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.zone3 = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.subject = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.link = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.mode = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*删除某条后台弹窗*/	
function Protocols.pack_del_gm_rightfloat ( id)
	local output = Packet.new(SMSG_DEL_GM_RIGHTFLOAT)
	output:writeU32(id)
	return output
end

-- /*删除某条后台弹窗*/	
function Protocols.call_del_gm_rightfloat ( playerInfo, id)
	local output = Protocols.	pack_del_gm_rightfloat ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*删除某条后台弹窗*/	
function Protocols.unpack_del_gm_rightfloat (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*应用服同步时间*/	
function Protocols.pack_sync_mstime_app ( mstime_now ,time_now ,open_time)
	local output = Packet.new(MSG_SYNC_MSTIME_APP)
	output:writeU32(mstime_now)
	output:writeU32(time_now)
	output:writeU32(open_time)
	return output
end

-- /*应用服同步时间*/	
function Protocols.call_sync_mstime_app ( playerInfo, mstime_now ,time_now ,open_time)
	local output = Protocols.	pack_sync_mstime_app ( mstime_now ,time_now ,open_time)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*应用服同步时间*/	
function Protocols.unpack_sync_mstime_app (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.mstime_now = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.time_now = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.open_time = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*玩家打开某个窗口*/	
function Protocols.pack_open_window ( window_type)
	local output = Packet.new(CMSG_OPEN_WINDOW)
	output:writeU32(window_type)
	return output
end

-- /*玩家打开某个窗口*/	
function Protocols.call_open_window ( playerInfo, window_type)
	local output = Protocols.	pack_open_window ( window_type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*玩家打开某个窗口*/	
function Protocols.unpack_open_window (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.window_type = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*禁言操作*/	
function Protocols.pack_player_gag ( player_id ,end_time ,content)
	local output = Packet.new(CMSG_PLAYER_GAG)
	output:writeUTF(player_id)
	output:writeU32(end_time)
	output:writeUTF(content)
	return output
end

-- /*禁言操作*/	
function Protocols.call_player_gag ( playerInfo, player_id ,end_time ,content)
	local output = Protocols.	pack_player_gag ( player_id ,end_time ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*禁言操作*/	
function Protocols.unpack_player_gag (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.player_id = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.end_time = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.content = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*踢人操作*/	
function Protocols.pack_player_kicking ( player_id)
	local output = Packet.new(CMSG_PLAYER_KICKING)
	output:writeUTF(player_id)
	return output
end

-- /*踢人操作*/	
function Protocols.call_player_kicking ( playerInfo, player_id)
	local output = Protocols.	pack_player_kicking ( player_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*踢人操作*/	
function Protocols.unpack_player_kicking (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.player_id = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*合服通知*/	
function Protocols.pack_merge_server_msg ( merge_host ,merge_port ,merge_key ,merge_type ,reserve ,reserve2)
	local output = Packet.new(SMSG_MERGE_SERVER_MSG)
	output:writeUTF(merge_host)
	output:writeU32(merge_port)
	output:writeUTF(merge_key)
	output:writeU32(merge_type)
	output:writeU32(reserve)
	output:writeU32(reserve2)
	return output
end

-- /*合服通知*/	
function Protocols.call_merge_server_msg ( playerInfo, merge_host ,merge_port ,merge_key ,merge_type ,reserve ,reserve2)
	local output = Protocols.	pack_merge_server_msg ( merge_host ,merge_port ,merge_key ,merge_type ,reserve ,reserve2)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*合服通知*/	
function Protocols.unpack_merge_server_msg (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.merge_host = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.merge_port = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.merge_key = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.merge_type = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.reserve = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.reserve2 = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*获取排行信息*/	
function Protocols.pack_rank_list_query ( call_back_id ,rank_list_type ,start_index ,end_index)
	local output = Packet.new(CMSG_RANK_LIST_QUERY)
	output:writeU32(call_back_id)
	output:writeByte(rank_list_type)
	output:writeI16(start_index)
	output:writeI16(end_index)
	return output
end

-- /*获取排行信息*/	
function Protocols.call_rank_list_query ( playerInfo, call_back_id ,rank_list_type ,start_index ,end_index)
	local output = Protocols.	pack_rank_list_query ( call_back_id ,rank_list_type ,start_index ,end_index)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*获取排行信息*/	
function Protocols.unpack_rank_list_query (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.call_back_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.rank_list_type = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.start_index = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.end_index = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*客户端获取排行榜返回结果*/	
function Protocols.pack_rank_list_query_result (  )
	local output = Packet.new(SMSG_RANK_LIST_QUERY_RESULT)
	return output
end

-- /*客户端获取排行榜返回结果*/	
function Protocols.call_rank_list_query_result ( playerInfo )
	local output = Protocols.	pack_rank_list_query_result (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*客户端获取排行榜返回结果*/	
function Protocols.unpack_rank_list_query_result (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*客户端热更场景模块后获取uint*/	
function Protocols.pack_client_update_scened (  )
	local output = Packet.new(CMSG_CLIENT_UPDATE_SCENED)
	return output
end

-- /*客户端热更场景模块后获取uint*/	
function Protocols.call_client_update_scened ( playerInfo )
	local output = Protocols.	pack_client_update_scened (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*客户端热更场景模块后获取uint*/	
function Protocols.unpack_client_update_scened (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*数值包*/	
function Protocols.pack_num_lua (  )
	local output = Packet.new(SMSG_NUM_LUA)
	return output
end

-- /*数值包*/	
function Protocols.call_num_lua ( playerInfo )
	local output = Protocols.	pack_num_lua (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*数值包*/	
function Protocols.unpack_num_lua (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*战利品拾取*/	
function Protocols.pack_loot_select ( x ,y)
	local output = Packet.new(CMSG_LOOT_SELECT)
	output:writeI16(x)
	output:writeI16(y)
	return output
end

-- /*战利品拾取*/	
function Protocols.call_loot_select ( playerInfo, x ,y)
	local output = Protocols.	pack_loot_select ( x ,y)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*战利品拾取*/	
function Protocols.unpack_loot_select (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.x = input:readU16()
	if not ret then
		return false
	end
	ret,param_table.y = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*通知登录服把玩家传回游戏服*/	
function Protocols.pack_goback_to_game_server (  )
	local output = Packet.new(CMSG_GOBACK_TO_GAME_SERVER)
	return output
end

-- /*通知登录服把玩家传回游戏服*/	
function Protocols.call_goback_to_game_server ( playerInfo )
	local output = Protocols.	pack_goback_to_game_server (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*通知登录服把玩家传回游戏服*/	
function Protocols.unpack_goback_to_game_server (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*客户端把比赛人员数据传给比赛服*/	
function Protocols.pack_world_war_CS_player_info (  )
	local output = Packet.new(CMSG_WORLD_WAR_CS_PLAYER_INFO)
	return output
end

-- /*客户端把比赛人员数据传给比赛服*/	
function Protocols.call_world_war_CS_player_info ( playerInfo )
	local output = Protocols.	pack_world_war_CS_player_info (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*客户端把比赛人员数据传给比赛服*/	
function Protocols.unpack_world_war_CS_player_info (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*玩家加入或者离开某服务器*/	
function Protocols.pack_join_or_leave_server ( join_or_leave ,server_type ,server_pid ,server_fd ,time)
	local output = Packet.new(SMSG_JOIN_OR_LEAVE_SERVER)
	output:writeByte(join_or_leave)
	output:writeByte(server_type)
	output:writeU32(server_pid)
	output:writeU32(server_fd)
	output:writeU32(time)
	return output
end

-- /*玩家加入或者离开某服务器*/	
function Protocols.call_join_or_leave_server ( playerInfo, join_or_leave ,server_type ,server_pid ,server_fd ,time)
	local output = Protocols.	pack_join_or_leave_server ( join_or_leave ,server_type ,server_pid ,server_fd ,time)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*玩家加入或者离开某服务器*/	
function Protocols.unpack_join_or_leave_server (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.join_or_leave = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.server_type = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.server_pid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.server_fd = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.time = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*客户端请求跨服人员数据*/	
function Protocols.pack_world_war_SC_player_info (  )
	local output = Packet.new(MSG_WORLD_WAR_SC_PLAYER_INFO)
	return output
end

-- /*客户端请求跨服人员数据*/	
function Protocols.call_world_war_SC_player_info ( playerInfo )
	local output = Protocols.	pack_world_war_SC_player_info (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*客户端请求跨服人员数据*/	
function Protocols.unpack_world_war_SC_player_info (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*客户端订阅信息*/	
function Protocols.pack_clientSubscription ( guid)
	local output = Packet.new(MSG_CLIENTSUBSCRIPTION)
	output:writeU32(guid)
	return output
end

-- /*客户端订阅信息*/	
function Protocols.call_clientSubscription ( playerInfo, guid)
	local output = Protocols.	pack_clientSubscription ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*客户端订阅信息*/	
function Protocols.unpack_clientSubscription (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.guid = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*服务端下发lua脚本*/	
function Protocols.pack_lua_script (  )
	local output = Packet.new(SMSG_LUA_SCRIPT)
	return output
end

-- /*服务端下发lua脚本*/	
function Protocols.call_lua_script ( playerInfo )
	local output = Protocols.	pack_lua_script (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*服务端下发lua脚本*/	
function Protocols.unpack_lua_script (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*角色更改信息*/	
function Protocols.pack_char_update_info ( info)
	local output = Packet.new(CMSG_CHAR_UPDATE_INFO)
	info :write(output)
	return output
end

-- /*角色更改信息*/	
function Protocols.call_char_update_info ( playerInfo, info)
	local output = Protocols.	pack_char_update_info ( info)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*角色更改信息*/	
function Protocols.unpack_char_update_info (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	param_table.info = char_create_info_t .new()
	if(param_table.info :read(input)==false)then
		return false
	end

	return true,param_table	

end


-- /*通知客户端观察者的视角*/	
function Protocols.pack_notice_watcher_map_info ( wather_guid ,map_id ,instance_id)
	local output = Packet.new(SMSG_NOTICE_WATCHER_MAP_INFO)
	output:writeUTF(wather_guid)
	output:writeU32(map_id)
	output:writeU32(instance_id)
	return output
end

-- /*通知客户端观察者的视角*/	
function Protocols.call_notice_watcher_map_info ( playerInfo, wather_guid ,map_id ,instance_id)
	local output = Protocols.	pack_notice_watcher_map_info ( wather_guid ,map_id ,instance_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*通知客户端观察者的视角*/	
function Protocols.unpack_notice_watcher_map_info (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.wather_guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.map_id = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.instance_id = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*客户端订阅对象信息*/	
function Protocols.pack_modify_watch ( opt ,cid ,key)
	local output = Packet.new(CMSG_MODIFY_WATCH)
	output:writeByte(opt)
	output:writeU32(cid)
	output:writeUTF(key)
	return output
end

-- /*客户端订阅对象信息*/	
function Protocols.call_modify_watch ( playerInfo, opt ,cid ,key)
	local output = Protocols.	pack_modify_watch ( opt ,cid ,key)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*客户端订阅对象信息*/	
function Protocols.unpack_modify_watch (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.opt = input:readByte()
	if not ret then
		return false
	end
	ret,param_table.cid = input:readU32()
	if not ret then
		return false
	end	
	ret,param_table.key = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*跨服传送*/	
function Protocols.pack_kuafu_chuansong ( str_data ,watcher_guid ,reserve)
	local output = Packet.new(CMSG_KUAFU_CHUANSONG)
	output:writeUTF(str_data)
	output:writeUTF(watcher_guid)
	output:writeU32(reserve)
	return output
end

-- /*跨服传送*/	
function Protocols.call_kuafu_chuansong ( playerInfo, str_data ,watcher_guid ,reserve)
	local output = Protocols.	pack_kuafu_chuansong ( str_data ,watcher_guid ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*跨服传送*/	
function Protocols.unpack_kuafu_chuansong (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.str_data = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.watcher_guid = input:readUTF()
	if not ret then
		return false
	end	
	ret,param_table.reserve = input:readU32()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*强化*/	
function Protocols.pack_strength ( part)
	local output = Packet.new(CMSG_STRENGTH)
	output:writeByte(part)
	return output
end

-- /*强化*/	
function Protocols.call_strength ( playerInfo, part)
	local output = Protocols.	pack_strength ( part)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*强化*/	
function Protocols.unpack_strength (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.part = input:readByte()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*强化成功*/	
function Protocols.pack_strength_success ( level)
	local output = Packet.new(SMSG_STRENGTH_SUCCESS)
	output:writeI16(level)
	return output
end

-- /*强化成功*/	
function Protocols.call_strength_success ( playerInfo, level)
	local output = Protocols.	pack_strength_success ( level)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*强化成功*/	
function Protocols.unpack_strength_success (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.level = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*强制进入*/	
function Protocols.pack_forceInto (  )
	local output = Packet.new(CMSG_FORCEINTO)
	return output
end

-- /*强制进入*/	
function Protocols.call_forceInto ( playerInfo )
	local output = Protocols.	pack_forceInto (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*强制进入*/	
function Protocols.unpack_forceInto (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*创建帮派*/	
function Protocols.pack_create_faction ( name)
	local output = Packet.new(CMSG_CREATE_FACTION)
	output:writeUTF(name)
	return output
end

-- /*创建帮派*/	
function Protocols.call_create_faction ( playerInfo, name)
	local output = Protocols.	pack_create_faction ( name)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*创建帮派*/	
function Protocols.unpack_create_faction (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.name = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*升级帮派*/	
function Protocols.pack_faction_upgrade (  )
	local output = Packet.new(CMSG_FACTION_UPGRADE)
	return output
end

-- /*升级帮派*/	
function Protocols.call_faction_upgrade ( playerInfo )
	local output = Protocols.	pack_faction_upgrade (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*升级帮派*/	
function Protocols.unpack_faction_upgrade (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*申请加入帮派*/	
function Protocols.pack_faction_join ( id)
	local output = Packet.new(CMSG_FACTION_JOIN)
	output:writeUTF(id)
	return output
end

-- /*申请加入帮派*/	
function Protocols.call_faction_join ( playerInfo, id)
	local output = Protocols.	pack_faction_join ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请加入帮派*/	
function Protocols.unpack_faction_join (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.id = input:readUTF()
	if not ret then
		return false
	end	

	return true,param_table	

end


-- /*申请升级技能*/	
function Protocols.pack_raise_base_spell ( spellId)
	local output = Packet.new(CMSG_RAISE_BASE_SPELL)
	output:writeI16(spellId)
	return output
end

-- /*申请升级技能*/	
function Protocols.call_raise_base_spell ( playerInfo, spellId)
	local output = Protocols.	pack_raise_base_spell ( spellId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请升级技能*/	
function Protocols.unpack_raise_base_spell (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.spellId = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*申请升阶愤怒技能*/	
function Protocols.pack_upgrade_anger_spell ( spellId)
	local output = Packet.new(CMSG_UPGRADE_ANGER_SPELL)
	output:writeI16(spellId)
	return output
end

-- /*申请升阶愤怒技能*/	
function Protocols.call_upgrade_anger_spell ( playerInfo, spellId)
	local output = Protocols.	pack_upgrade_anger_spell ( spellId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请升阶愤怒技能*/	
function Protocols.unpack_upgrade_anger_spell (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.spellId = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*申请升级坐骑*/	
function Protocols.pack_raise_mount (  )
	local output = Packet.new(CMSG_RAISE_MOUNT)
	return output
end

-- /*申请升级坐骑*/	
function Protocols.call_raise_mount ( playerInfo )
	local output = Protocols.	pack_raise_mount (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请升级坐骑*/	
function Protocols.unpack_raise_mount (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*申请升阶坐骑*/	
function Protocols.pack_upgrade_mount (  )
	local output = Packet.new(CMSG_UPGRADE_MOUNT)
	return output
end

-- /*申请升阶坐骑*/	
function Protocols.call_upgrade_mount ( playerInfo )
	local output = Protocols.	pack_upgrade_mount (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请升阶坐骑*/	
function Protocols.unpack_upgrade_mount (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*申请一键升阶坐骑*/	
function Protocols.pack_upgrade_mount_one_step (  )
	local output = Packet.new(CMSG_UPGRADE_MOUNT_ONE_STEP)
	return output
end

-- /*申请一键升阶坐骑*/	
function Protocols.call_upgrade_mount_one_step ( playerInfo )
	local output = Protocols.	pack_upgrade_mount_one_step (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请一键升阶坐骑*/	
function Protocols.unpack_upgrade_mount_one_step (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*申请解锁幻化坐骑*/	
function Protocols.pack_illusion_mount_active ( illuId)
	local output = Packet.new(CMSG_ILLUSION_MOUNT_ACTIVE)
	output:writeI16(illuId)
	return output
end

-- /*申请解锁幻化坐骑*/	
function Protocols.call_illusion_mount_active ( playerInfo, illuId)
	local output = Protocols.	pack_illusion_mount_active ( illuId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请解锁幻化坐骑*/	
function Protocols.unpack_illusion_mount_active (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.illuId = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*申请幻化坐骑*/	
function Protocols.pack_illusion_mount ( illuId)
	local output = Packet.new(CMSG_ILLUSION_MOUNT)
	output:writeI16(illuId)
	return output
end

-- /*申请幻化坐骑*/	
function Protocols.call_illusion_mount ( playerInfo, illuId)
	local output = Protocols.	pack_illusion_mount ( illuId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请幻化坐骑*/	
function Protocols.unpack_illusion_mount (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret
	ret,param_table.illuId = input:readU16()
	if not ret then
		return false
	end

	return true,param_table	

end


-- /*申请骑乘*/	
function Protocols.pack_ride_mount (  )
	local output = Packet.new(CMSG_RIDE_MOUNT)
	return output
end

-- /*申请骑乘*/	
function Protocols.call_ride_mount ( playerInfo )
	local output = Protocols.	pack_ride_mount (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*申请骑乘*/	
function Protocols.unpack_ride_mount (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end



function Protocols:SendPacket(pkt)
	external_send(self.ptr_player_data or self.ptr, pkt.ptr)
end

function Protocols:extend(playerInfo)
	playerInfo.SendPacket = self.SendPacket
	playerInfo.call_null_action = self.call_null_action
	playerInfo.call_ping_pong = self.call_ping_pong
	playerInfo.call_forced_into = self.call_forced_into
	playerInfo.call_get_session = self.call_get_session
	playerInfo.call_route_trace = self.call_route_trace
	playerInfo.call_write_client_log = self.call_write_client_log
	playerInfo.call_operation_failed = self.call_operation_failed
	playerInfo.call_sync_mstime = self.call_sync_mstime
	playerInfo.call_ud_object = self.call_ud_object
	playerInfo.call_ud_control = self.call_ud_control
	playerInfo.call_ud_control_result = self.call_ud_control_result
	playerInfo.call_grid_ud_object = self.call_grid_ud_object
	playerInfo.call_grid_ud_object_2 = self.call_grid_ud_object_2
	playerInfo.call_login_queue_index = self.call_login_queue_index
	playerInfo.call_kicking_type = self.call_kicking_type
	playerInfo.call_get_chars_list = self.call_get_chars_list
	playerInfo.call_chars_list = self.call_chars_list
	playerInfo.call_check_name = self.call_check_name
	playerInfo.call_check_name_result = self.call_check_name_result
	playerInfo.call_char_create = self.call_char_create
	playerInfo.call_char_create_result = self.call_char_create_result
	playerInfo.call_delete_char = self.call_delete_char
	playerInfo.call_delete_char_result = self.call_delete_char_result
	playerInfo.call_player_login = self.call_player_login
	playerInfo.call_player_logout = self.call_player_logout
	playerInfo.call_regularise_account = self.call_regularise_account
	playerInfo.call_char_remotestore = self.call_char_remotestore
	playerInfo.call_char_remotestore_str = self.call_char_remotestore_str
	playerInfo.call_teleport = self.call_teleport
	playerInfo.call_move_stop = self.call_move_stop
	playerInfo.call_unit_move = self.call_unit_move
	playerInfo.call_use_gameobject = self.call_use_gameobject
	playerInfo.call_bag_exchange_pos = self.call_bag_exchange_pos
	playerInfo.call_bag_destroy = self.call_bag_destroy
	playerInfo.call_bag_item_split = self.call_bag_item_split
	playerInfo.call_bag_item_user = self.call_bag_item_user
	playerInfo.call_bag_item_cooldown = self.call_bag_item_cooldown
	playerInfo.call_grid_unit_move = self.call_grid_unit_move
	playerInfo.call_grid_unit_move_2 = self.call_grid_unit_move_2
	playerInfo.call_exchange_item = self.call_exchange_item
	playerInfo.call_bag_extension = self.call_bag_extension
	playerInfo.call_npc_get_goods_list = self.call_npc_get_goods_list
	playerInfo.call_npc_goods_list = self.call_npc_goods_list
	playerInfo.call_npc_buy = self.call_npc_buy
	playerInfo.call_npc_sell = self.call_npc_sell
	playerInfo.call_npc_repurchase = self.call_npc_repurchase
	playerInfo.call_avatar_fashion_enable = self.call_avatar_fashion_enable
	playerInfo.call_questhelp_talk_option = self.call_questhelp_talk_option
	playerInfo.call_taxi_hello = self.call_taxi_hello
	playerInfo.call_taxi_stations_list = self.call_taxi_stations_list
	playerInfo.call_taxi_select_station = self.call_taxi_select_station
	playerInfo.call_gossip_select_option = self.call_gossip_select_option
	playerInfo.call_gossip_hello = self.call_gossip_hello
	playerInfo.call_gossip_message = self.call_gossip_message
	playerInfo.call_questgiver_status_query = self.call_questgiver_status_query
	playerInfo.call_questgiver_status = self.call_questgiver_status
	playerInfo.call_query_quest_status = self.call_query_quest_status
	playerInfo.call_questhelp_get_canaccept_list = self.call_questhelp_get_canaccept_list
	playerInfo.call_questhelp_canaccept_list = self.call_questhelp_canaccept_list
	playerInfo.call_questupdate_faild = self.call_questupdate_faild
	playerInfo.call_questupdate_complete = self.call_questupdate_complete
	playerInfo.call_questlog_remove_quest = self.call_questlog_remove_quest
	playerInfo.call_questgiver_complete_quest = self.call_questgiver_complete_quest
	playerInfo.call_questhelp_next = self.call_questhelp_next
	playerInfo.call_questhelp_complete = self.call_questhelp_complete
	playerInfo.call_questupdate_accept = self.call_questupdate_accept
	playerInfo.call_questhelp_update_status = self.call_questhelp_update_status
	playerInfo.call_questgetter_complete = self.call_questgetter_complete
	playerInfo.call_questgiver_accept_quest = self.call_questgiver_accept_quest
	playerInfo.call_questupdate_use_item = self.call_questupdate_use_item
	playerInfo.call_questhelp_query_book = self.call_questhelp_query_book
	playerInfo.call_questhelp_book_quest = self.call_questhelp_book_quest
	playerInfo.call_use_gameobject_action = self.call_use_gameobject_action
	playerInfo.call_set_attack_mode = self.call_set_attack_mode
	playerInfo.call_select_target = self.call_select_target
	playerInfo.call_combat_state_update = self.call_combat_state_update
	playerInfo.call_exp_update = self.call_exp_update
	playerInfo.call_spell_start = self.call_spell_start
	playerInfo.call_spell_stop = self.call_spell_stop
	playerInfo.call_jump = self.call_jump
	playerInfo.call_resurrection = self.call_resurrection
	playerInfo.call_trade_request = self.call_trade_request
	playerInfo.call_trade_reply = self.call_trade_reply
	playerInfo.call_trade_start = self.call_trade_start
	playerInfo.call_trade_decide_items = self.call_trade_decide_items
	playerInfo.call_trade_finish = self.call_trade_finish
	playerInfo.call_trade_cancel = self.call_trade_cancel
	playerInfo.call_trade_ready = self.call_trade_ready
	playerInfo.call_chat_unit_talk = self.call_chat_unit_talk
	playerInfo.call_chat_near = self.call_chat_near
	playerInfo.call_chat_whisper = self.call_chat_whisper
	playerInfo.call_chat_faction = self.call_chat_faction
	playerInfo.call_chat_world = self.call_chat_world
	playerInfo.call_chat_horn = self.call_chat_horn
	playerInfo.call_chat_notice = self.call_chat_notice
	playerInfo.call_query_player_info = self.call_query_player_info
	playerInfo.call_query_result_update_object = self.call_query_result_update_object
	playerInfo.call_receive_gift_packs = self.call_receive_gift_packs
	playerInfo.call_map_update_object = self.call_map_update_object
	playerInfo.call_fighting_info_update_object = self.call_fighting_info_update_object
	playerInfo.call_fighting_info_update_object_2 = self.call_fighting_info_update_object_2
	playerInfo.call_instance_enter = self.call_instance_enter
	playerInfo.call_instance_next_state = self.call_instance_next_state
	playerInfo.call_instance_exit = self.call_instance_exit
	playerInfo.call_limit_activity_receive = self.call_limit_activity_receive
	playerInfo.call_kill_man = self.call_kill_man
	playerInfo.call_player_upgrade = self.call_player_upgrade
	playerInfo.call_warehouse_save_money = self.call_warehouse_save_money
	playerInfo.call_warehouse_take_money = self.call_warehouse_take_money
	playerInfo.call_use_gold_opt = self.call_use_gold_opt
	playerInfo.call_use_silver_opt = self.call_use_silver_opt
	playerInfo.call_gm_rightfloat = self.call_gm_rightfloat
	playerInfo.call_del_gm_rightfloat = self.call_del_gm_rightfloat
	playerInfo.call_sync_mstime_app = self.call_sync_mstime_app
	playerInfo.call_open_window = self.call_open_window
	playerInfo.call_player_gag = self.call_player_gag
	playerInfo.call_player_kicking = self.call_player_kicking
	playerInfo.call_merge_server_msg = self.call_merge_server_msg
	playerInfo.call_rank_list_query = self.call_rank_list_query
	playerInfo.call_rank_list_query_result = self.call_rank_list_query_result
	playerInfo.call_client_update_scened = self.call_client_update_scened
	playerInfo.call_num_lua = self.call_num_lua
	playerInfo.call_loot_select = self.call_loot_select
	playerInfo.call_goback_to_game_server = self.call_goback_to_game_server
	playerInfo.call_world_war_CS_player_info = self.call_world_war_CS_player_info
	playerInfo.call_join_or_leave_server = self.call_join_or_leave_server
	playerInfo.call_world_war_SC_player_info = self.call_world_war_SC_player_info
	playerInfo.call_clientSubscription = self.call_clientSubscription
	playerInfo.call_lua_script = self.call_lua_script
	playerInfo.call_char_update_info = self.call_char_update_info
	playerInfo.call_notice_watcher_map_info = self.call_notice_watcher_map_info
	playerInfo.call_modify_watch = self.call_modify_watch
	playerInfo.call_kuafu_chuansong = self.call_kuafu_chuansong
	playerInfo.call_strength = self.call_strength
	playerInfo.call_strength_success = self.call_strength_success
	playerInfo.call_forceInto = self.call_forceInto
	playerInfo.call_create_faction = self.call_create_faction
	playerInfo.call_faction_upgrade = self.call_faction_upgrade
	playerInfo.call_faction_join = self.call_faction_join
	playerInfo.call_raise_base_spell = self.call_raise_base_spell
	playerInfo.call_upgrade_anger_spell = self.call_upgrade_anger_spell
	playerInfo.call_raise_mount = self.call_raise_mount
	playerInfo.call_upgrade_mount = self.call_upgrade_mount
	playerInfo.call_upgrade_mount_one_step = self.call_upgrade_mount_one_step
	playerInfo.call_illusion_mount_active = self.call_illusion_mount_active
	playerInfo.call_illusion_mount = self.call_illusion_mount
	playerInfo.call_ride_mount = self.call_ride_mount
end

local unpack_handler = {

[MSG_NULL_ACTION] =  Protocols.unpack_null_action,
[MSG_PING_PONG] =  Protocols.unpack_ping_pong,
[CMSG_FORCED_INTO] =  Protocols.unpack_forced_into,
[CMSG_GET_SESSION] =  Protocols.unpack_get_session,
[MSG_ROUTE_TRACE] =  Protocols.unpack_route_trace,
[CMSG_WRITE_CLIENT_LOG] =  Protocols.unpack_write_client_log,
[SMSG_OPERATION_FAILED] =  Protocols.unpack_operation_failed,
[MSG_SYNC_MSTIME] =  Protocols.unpack_sync_mstime,
[SMSG_UD_OBJECT] =  Protocols.unpack_ud_object,
[CMSG_UD_CONTROL] =  Protocols.unpack_ud_control,
[SMSG_UD_CONTROL_RESULT] =  Protocols.unpack_ud_control_result,
[SMSG_GRID_UD_OBJECT] =  Protocols.unpack_grid_ud_object,
[SMSG_GRID_UD_OBJECT_2] =  Protocols.unpack_grid_ud_object_2,
[SMSG_LOGIN_QUEUE_INDEX] =  Protocols.unpack_login_queue_index,
[SMSG_KICKING_TYPE] =  Protocols.unpack_kicking_type,
[CMSG_GET_CHARS_LIST] =  Protocols.unpack_get_chars_list,
[SMSG_CHARS_LIST] =  Protocols.unpack_chars_list,
[CMSG_CHECK_NAME] =  Protocols.unpack_check_name,
[SMSG_CHECK_NAME_RESULT] =  Protocols.unpack_check_name_result,
[CMSG_CHAR_CREATE] =  Protocols.unpack_char_create,
[SMSG_CHAR_CREATE_RESULT] =  Protocols.unpack_char_create_result,
[CMSG_DELETE_CHAR] =  Protocols.unpack_delete_char,
[SMSG_DELETE_CHAR_RESULT] =  Protocols.unpack_delete_char_result,
[CMSG_PLAYER_LOGIN] =  Protocols.unpack_player_login,
[CMSG_PLAYER_LOGOUT] =  Protocols.unpack_player_logout,
[CMSG_REGULARISE_ACCOUNT] =  Protocols.unpack_regularise_account,
[CMSG_CHAR_REMOTESTORE] =  Protocols.unpack_char_remotestore,
[CMSG_CHAR_REMOTESTORE_STR] =  Protocols.unpack_char_remotestore_str,
[CMSG_TELEPORT] =  Protocols.unpack_teleport,
[MSG_MOVE_STOP] =  Protocols.unpack_move_stop,
[MSG_UNIT_MOVE] =  Protocols.unpack_unit_move,
[CMSG_USE_GAMEOBJECT] =  Protocols.unpack_use_gameobject,
[CMSG_BAG_EXCHANGE_POS] =  Protocols.unpack_bag_exchange_pos,
[CMSG_BAG_DESTROY] =  Protocols.unpack_bag_destroy,
[CMSG_BAG_ITEM_SPLIT] =  Protocols.unpack_bag_item_split,
[CMSG_BAG_ITEM_USER] =  Protocols.unpack_bag_item_user,
[SMSG_BAG_ITEM_COOLDOWN] =  Protocols.unpack_bag_item_cooldown,
[SMSG_GRID_UNIT_MOVE] =  Protocols.unpack_grid_unit_move,
[SMSG_GRID_UNIT_MOVE_2] =  Protocols.unpack_grid_unit_move_2,
[CMSG_EXCHANGE_ITEM] =  Protocols.unpack_exchange_item,
[CMSG_BAG_EXTENSION] =  Protocols.unpack_bag_extension,
[CMSG_NPC_GET_GOODS_LIST] =  Protocols.unpack_npc_get_goods_list,
[SMSG_NPC_GOODS_LIST] =  Protocols.unpack_npc_goods_list,
[CMSG_NPC_BUY] =  Protocols.unpack_npc_buy,
[CMSG_NPC_SELL] =  Protocols.unpack_npc_sell,
[CMSG_NPC_REPURCHASE] =  Protocols.unpack_npc_repurchase,
[CMSG_AVATAR_FASHION_ENABLE] =  Protocols.unpack_avatar_fashion_enable,
[CMSG_QUESTHELP_TALK_OPTION] =  Protocols.unpack_questhelp_talk_option,
[CMSG_TAXI_HELLO] =  Protocols.unpack_taxi_hello,
[SMSG_TAXI_STATIONS_LIST] =  Protocols.unpack_taxi_stations_list,
[CMSG_TAXI_SELECT_STATION] =  Protocols.unpack_taxi_select_station,
[CMSG_GOSSIP_SELECT_OPTION] =  Protocols.unpack_gossip_select_option,
[CMSG_GOSSIP_HELLO] =  Protocols.unpack_gossip_hello,
[SMSG_GOSSIP_MESSAGE] =  Protocols.unpack_gossip_message,
[CMSG_QUESTGIVER_STATUS_QUERY] =  Protocols.unpack_questgiver_status_query,
[SMSG_QUESTGIVER_STATUS] =  Protocols.unpack_questgiver_status,
[MSG_QUERY_QUEST_STATUS] =  Protocols.unpack_query_quest_status,
[CMSG_QUESTHELP_GET_CANACCEPT_LIST] =  Protocols.unpack_questhelp_get_canaccept_list,
[SMSG_QUESTHELP_CANACCEPT_LIST] =  Protocols.unpack_questhelp_canaccept_list,
[SMSG_QUESTUPDATE_FAILD] =  Protocols.unpack_questupdate_faild,
[SMSG_QUESTUPDATE_COMPLETE] =  Protocols.unpack_questupdate_complete,
[CMSG_QUESTLOG_REMOVE_QUEST] =  Protocols.unpack_questlog_remove_quest,
[CMSG_QUESTGIVER_COMPLETE_QUEST] =  Protocols.unpack_questgiver_complete_quest,
[SMSG_QUESTHELP_NEXT] =  Protocols.unpack_questhelp_next,
[CMSG_QUESTHELP_COMPLETE] =  Protocols.unpack_questhelp_complete,
[SMSG_QUESTUPDATE_ACCEPT] =  Protocols.unpack_questupdate_accept,
[CMSG_QUESTHELP_UPDATE_STATUS] =  Protocols.unpack_questhelp_update_status,
[SMSG_QUESTGETTER_COMPLETE] =  Protocols.unpack_questgetter_complete,
[CMSG_QUESTGIVER_ACCEPT_QUEST] =  Protocols.unpack_questgiver_accept_quest,
[CMSG_QUESTUPDATE_USE_ITEM] =  Protocols.unpack_questupdate_use_item,
[CMSG_QUESTHELP_QUERY_BOOK] =  Protocols.unpack_questhelp_query_book,
[SMSG_QUESTHELP_BOOK_QUEST] =  Protocols.unpack_questhelp_book_quest,
[SMSG_USE_GAMEOBJECT_ACTION] =  Protocols.unpack_use_gameobject_action,
[CMSG_SET_ATTACK_MODE] =  Protocols.unpack_set_attack_mode,
[MSG_SELECT_TARGET] =  Protocols.unpack_select_target,
[SMSG_COMBAT_STATE_UPDATE] =  Protocols.unpack_combat_state_update,
[SMSG_EXP_UPDATE] =  Protocols.unpack_exp_update,
[MSG_SPELL_START] =  Protocols.unpack_spell_start,
[MSG_SPELL_STOP] =  Protocols.unpack_spell_stop,
[MSG_JUMP] =  Protocols.unpack_jump,
[CMSG_RESURRECTION] =  Protocols.unpack_resurrection,
[MSG_TRADE_REQUEST] =  Protocols.unpack_trade_request,
[MSG_TRADE_REPLY] =  Protocols.unpack_trade_reply,
[SMSG_TRADE_START] =  Protocols.unpack_trade_start,
[MSG_TRADE_DECIDE_ITEMS] =  Protocols.unpack_trade_decide_items,
[SMSG_TRADE_FINISH] =  Protocols.unpack_trade_finish,
[MSG_TRADE_CANCEL] =  Protocols.unpack_trade_cancel,
[MSG_TRADE_READY] =  Protocols.unpack_trade_ready,
[SMSG_CHAT_UNIT_TALK] =  Protocols.unpack_chat_unit_talk,
[MSG_CHAT_NEAR] =  Protocols.unpack_chat_near,
[MSG_CHAT_WHISPER] =  Protocols.unpack_chat_whisper,
[MSG_CHAT_FACTION] =  Protocols.unpack_chat_faction,
[MSG_CHAT_WORLD] =  Protocols.unpack_chat_world,
[MSG_CHAT_HORN] =  Protocols.unpack_chat_horn,
[MSG_CHAT_NOTICE] =  Protocols.unpack_chat_notice,
[CMSG_QUERY_PLAYER_INFO] =  Protocols.unpack_query_player_info,
[SMSG_QUERY_RESULT_UPDATE_OBJECT] =  Protocols.unpack_query_result_update_object,
[CMSG_RECEIVE_GIFT_PACKS] =  Protocols.unpack_receive_gift_packs,
[SMSG_MAP_UPDATE_OBJECT] =  Protocols.unpack_map_update_object,
[SMSG_FIGHTING_INFO_UPDATE_OBJECT] =  Protocols.unpack_fighting_info_update_object,
[SMSG_FIGHTING_INFO_UPDATE_OBJECT_2] =  Protocols.unpack_fighting_info_update_object_2,
[CMSG_INSTANCE_ENTER] =  Protocols.unpack_instance_enter,
[CMSG_INSTANCE_NEXT_STATE] =  Protocols.unpack_instance_next_state,
[CMSG_INSTANCE_EXIT] =  Protocols.unpack_instance_exit,
[CMSG_LIMIT_ACTIVITY_RECEIVE] =  Protocols.unpack_limit_activity_receive,
[SMSG_KILL_MAN] =  Protocols.unpack_kill_man,
[SMSG_PLAYER_UPGRADE] =  Protocols.unpack_player_upgrade,
[CMSG_WAREHOUSE_SAVE_MONEY] =  Protocols.unpack_warehouse_save_money,
[CMSG_WAREHOUSE_TAKE_MONEY] =  Protocols.unpack_warehouse_take_money,
[CMSG_USE_GOLD_OPT] =  Protocols.unpack_use_gold_opt,
[CMSG_USE_SILVER_OPT] =  Protocols.unpack_use_silver_opt,
[SMSG_GM_RIGHTFLOAT] =  Protocols.unpack_gm_rightfloat,
[SMSG_DEL_GM_RIGHTFLOAT] =  Protocols.unpack_del_gm_rightfloat,
[MSG_SYNC_MSTIME_APP] =  Protocols.unpack_sync_mstime_app,
[CMSG_OPEN_WINDOW] =  Protocols.unpack_open_window,
[CMSG_PLAYER_GAG] =  Protocols.unpack_player_gag,
[CMSG_PLAYER_KICKING] =  Protocols.unpack_player_kicking,
[SMSG_MERGE_SERVER_MSG] =  Protocols.unpack_merge_server_msg,
[CMSG_RANK_LIST_QUERY] =  Protocols.unpack_rank_list_query,
[SMSG_RANK_LIST_QUERY_RESULT] =  Protocols.unpack_rank_list_query_result,
[CMSG_CLIENT_UPDATE_SCENED] =  Protocols.unpack_client_update_scened,
[SMSG_NUM_LUA] =  Protocols.unpack_num_lua,
[CMSG_LOOT_SELECT] =  Protocols.unpack_loot_select,
[CMSG_GOBACK_TO_GAME_SERVER] =  Protocols.unpack_goback_to_game_server,
[CMSG_WORLD_WAR_CS_PLAYER_INFO] =  Protocols.unpack_world_war_CS_player_info,
[SMSG_JOIN_OR_LEAVE_SERVER] =  Protocols.unpack_join_or_leave_server,
[MSG_WORLD_WAR_SC_PLAYER_INFO] =  Protocols.unpack_world_war_SC_player_info,
[MSG_CLIENTSUBSCRIPTION] =  Protocols.unpack_clientSubscription,
[SMSG_LUA_SCRIPT] =  Protocols.unpack_lua_script,
[CMSG_CHAR_UPDATE_INFO] =  Protocols.unpack_char_update_info,
[SMSG_NOTICE_WATCHER_MAP_INFO] =  Protocols.unpack_notice_watcher_map_info,
[CMSG_MODIFY_WATCH] =  Protocols.unpack_modify_watch,
[CMSG_KUAFU_CHUANSONG] =  Protocols.unpack_kuafu_chuansong,
[CMSG_STRENGTH] =  Protocols.unpack_strength,
[SMSG_STRENGTH_SUCCESS] =  Protocols.unpack_strength_success,
[CMSG_FORCEINTO] =  Protocols.unpack_forceInto,
[CMSG_CREATE_FACTION] =  Protocols.unpack_create_faction,
[CMSG_FACTION_UPGRADE] =  Protocols.unpack_faction_upgrade,
[CMSG_FACTION_JOIN] =  Protocols.unpack_faction_join,
[CMSG_RAISE_BASE_SPELL] =  Protocols.unpack_raise_base_spell,
[CMSG_UPGRADE_ANGER_SPELL] =  Protocols.unpack_upgrade_anger_spell,
[CMSG_RAISE_MOUNT] =  Protocols.unpack_raise_mount,
[CMSG_UPGRADE_MOUNT] =  Protocols.unpack_upgrade_mount,
[CMSG_UPGRADE_MOUNT_ONE_STEP] =  Protocols.unpack_upgrade_mount_one_step,
[CMSG_ILLUSION_MOUNT_ACTIVE] =  Protocols.unpack_illusion_mount_active,
[CMSG_ILLUSION_MOUNT] =  Protocols.unpack_illusion_mount,
[CMSG_RIDE_MOUNT] =  Protocols.unpack_ride_mount,

}

function Protocols.unpack_packet(opcode,pkt)
	return unpack_handler[opcode](pkt)
end

return Protocols