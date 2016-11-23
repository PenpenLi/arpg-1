
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------Э�飬���������Զ����ɣ������ֹ��Ķ�----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Packet = require 'util.packet'
local external_send = packet and packet.external_send

local Protocols = {}
---------------------------------------------
--����Ϊ���ӵ�״̬
STATUS_NEVER = 1
STATUS_AUTHED = 2
STATUS_LOGGEDIN = 4
STATUS_TRANSFER = 8

---------------------------------------------
--Э��ö��
MSG_NULL_ACTION		= 0	-- /*��Ч����*/	
MSG_PING_PONG		= 1	-- /*��������״̬*/	
CMSG_FORCED_INTO		= 2	-- /*�ߵ����ߵ�׼��ǿ�Ƶ�½*/	
CMSG_GET_SESSION		= 3	-- /*���Session����*/	
MSG_ROUTE_TRACE		= 4	-- /*���ط����ݰ�·�ɲ���*/	
CMSG_WRITE_CLIENT_LOG		= 5	-- /*��¼�ͻ�����־*/	
SMSG_OPERATION_FAILED		= 6	-- /*����ʧ��*/	
MSG_SYNC_MSTIME		= 7	-- /*ͬ��ʱ��*/	
SMSG_UD_OBJECT		= 8	-- /*�������*/	
CMSG_UD_CONTROL		= 9	-- /*������¿���Э��*/	
SMSG_UD_CONTROL_RESULT		= 10	-- /*������¿���Э����*/	
SMSG_GRID_UD_OBJECT		= 11	-- /*GRID�Ķ������*/	
SMSG_GRID_UD_OBJECT_2		= 12	-- /*GRID�Ķ������*/	
SMSG_LOGIN_QUEUE_INDEX		= 13	-- /*���߿ͻ��ˣ�Ŀǰ�Լ����ڵ�¼���еĵڼ�λ*/	
SMSG_KICKING_TYPE		= 14	-- /*����ԭ��*/	
CMSG_GET_CHARS_LIST		= 15	-- /*��ȡ��ɫ�б�*/	
SMSG_CHARS_LIST		= 16	-- /*��ɫ�б�*/	
CMSG_CHECK_NAME		= 17	-- /*��������Ƿ����ʹ��*/	
SMSG_CHECK_NAME_RESULT		= 18	-- /*������ֽ��*/	
CMSG_CHAR_CREATE		= 19	-- /*������ɫ*/	
SMSG_CHAR_CREATE_RESULT		= 20	-- /*��ɫ�������*/	
CMSG_DELETE_CHAR		= 21	-- /*ɾ����ɫ*/	
SMSG_DELETE_CHAR_RESULT		= 22	-- /*��ɫɾ�����*/	
CMSG_PLAYER_LOGIN		= 23	-- /*��ҵ�¼*/	
CMSG_PLAYER_LOGOUT		= 24	-- /*����˳�*/	
CMSG_REGULARISE_ACCOUNT		= 25	-- /*��ʱ�˺�ת����*/	
CMSG_CHAR_REMOTESTORE		= 26	-- /*��ɫ������Ϣ*/	
CMSG_CHAR_REMOTESTORE_STR		= 27	-- /*��ɫ������Ϣ*/	
CMSG_TELEPORT		= 28	-- /*���ͣ������C->S��mapid��������ɴ��͵�ID*/	
MSG_MOVE_STOP		= 29	-- /*ֹͣ�ƶ�*/	
MSG_UNIT_MOVE		= 30	-- /*unit�����ƶ�*/	
CMSG_USE_GAMEOBJECT		= 31	-- /*ʹ����Ϸ����*/	
CMSG_BAG_EXCHANGE_POS		= 32	-- /*��������-����λ��*/	
CMSG_BAG_DESTROY		= 33	-- /*��������-������Ʒ*/	
CMSG_BAG_ITEM_SPLIT		= 34	-- /*�ָ���Ʒ*/	
CMSG_BAG_ITEM_USER		= 35	-- /*ʹ����Ʒ*/	
SMSG_BAG_ITEM_COOLDOWN		= 36	-- /*�·���Ʒ��ȴ*/	
SMSG_GRID_UNIT_MOVE		= 37	-- /*grid�е�unit�ƶ�������*/	
SMSG_GRID_UNIT_MOVE_2		= 38	-- /*grid�е�unit�ƶ�������2*/	
CMSG_EXCHANGE_ITEM		= 39	-- /*�һ���Ʒ*/	
CMSG_BAG_EXTENSION		= 40	-- /*������չ*/	
CMSG_NPC_GET_GOODS_LIST		= 41	-- /*����NPC��Ʒ�б�*/	
SMSG_NPC_GOODS_LIST		= 42	-- /*Npc��Ʒ�б�*/	
CMSG_NPC_BUY		= 43	-- /*������Ʒ*/	
CMSG_NPC_SELL		= 44	-- /*������Ʒ*/	
CMSG_NPC_REPURCHASE		= 45	-- /*�ع���Ʒ*/	
CMSG_AVATAR_FASHION_ENABLE		= 46	-- /*ʱװ�Ƿ�����*/	
CMSG_QUESTHELP_TALK_OPTION		= 47	-- /*����Ի�ѡ��*/	
CMSG_TAXI_HELLO		= 48	-- /*��NPC�Ի���ô��͵��б�*/	
SMSG_TAXI_STATIONS_LIST		= 49	-- /*���ʹ��͵��б�*/	
CMSG_TAXI_SELECT_STATION		= 50	-- /*ѡ���͵�*/	
CMSG_GOSSIP_SELECT_OPTION		= 51	-- /*��NPC����ѡ��ѡ��*/	
CMSG_GOSSIP_HELLO		= 52	-- /*��NPC���Ļ�ȡѡ��*/	
SMSG_GOSSIP_MESSAGE		= 53	-- /*����������Ϣ��ѡ��*/	
CMSG_QUESTGIVER_STATUS_QUERY		= 54	-- /*���񷢲���״̬��ѯ*/	
SMSG_QUESTGIVER_STATUS		= 55	-- /*����NPC״̬*/	
MSG_QUERY_QUEST_STATUS		= 56	-- /*��ѯ����״̬*/	
CMSG_QUESTHELP_GET_CANACCEPT_LIST		= 57	-- /*�ɽ�����*/	
SMSG_QUESTHELP_CANACCEPT_LIST		= 58	-- /*�·��ɽ������б�*/	
SMSG_QUESTUPDATE_FAILD		= 59	-- /*����ʧ��*/	
SMSG_QUESTUPDATE_COMPLETE		= 60	-- /*�����������*/	
CMSG_QUESTLOG_REMOVE_QUEST		= 61	-- /*��������*/	
CMSG_QUESTGIVER_COMPLETE_QUEST		= 62	-- /*�������*/	
SMSG_QUESTHELP_NEXT		= 63	-- /*��������֪ͨ���������¸�����*/	
CMSG_QUESTHELP_COMPLETE		= 64	-- /*����ϵͳǿ���������*/	
SMSG_QUESTUPDATE_ACCEPT		= 65	-- /*��������ɹ�*/	
CMSG_QUESTHELP_UPDATE_STATUS		= 66	-- /*�����������_�±�����*/	
SMSG_QUESTGETTER_COMPLETE		= 67	-- /*���������*/	
CMSG_QUESTGIVER_ACCEPT_QUEST		= 68	-- /*������*/	
CMSG_QUESTUPDATE_USE_ITEM		= 69	-- /*����ʹ����Ʒ*/	
CMSG_QUESTHELP_QUERY_BOOK		= 70	-- /*��ѯ��������*/	
SMSG_QUESTHELP_BOOK_QUEST		= 71	-- /*�·��ɽ���������*/	
SMSG_USE_GAMEOBJECT_ACTION		= 72	-- /*���ʹ����Ϸ�����Ժ�Ķ���*/	
CMSG_SET_ATTACK_MODE		= 73	-- /*���ù���ģʽ*/	
MSG_SELECT_TARGET		= 74	-- /*ѡ��Ŀ��*/	
SMSG_COMBAT_STATE_UPDATE		= 75	-- /*����ս��*/	
SMSG_EXP_UPDATE		= 76	-- /*�������*/	
MSG_SPELL_START		= 77	-- /*�ͻ����ͷż���*/	
MSG_SPELL_STOP		= 78	-- /*ʩ��ֹͣ*/	
MSG_JUMP		= 79	-- /*��*/	
CMSG_RESURRECTION		= 80	-- /*����*/	
MSG_TRADE_REQUEST		= 81	-- /*���׷�������*/	
MSG_TRADE_REPLY		= 82	-- /*���������*/	
SMSG_TRADE_START		= 83	-- /*���׿�ʼ*/	
MSG_TRADE_DECIDE_ITEMS		= 84	-- /*����ȷ����Ʒ*/	
SMSG_TRADE_FINISH		= 85	-- /*�������*/	
MSG_TRADE_CANCEL		= 86	-- /*����ȡ��*/	
MSG_TRADE_READY		= 87	-- /*����׼����*/	
SMSG_CHAT_UNIT_TALK		= 88	-- /*���ｲ��*/	
MSG_CHAT_NEAR		= 89	-- /*�ͽ�����*/	
MSG_CHAT_WHISPER		= 90	-- /*˽��*/	
MSG_CHAT_FACTION		= 91	-- /*��Ӫ����*/	
MSG_CHAT_WORLD		= 92	-- /*����*/	
MSG_CHAT_HORN		= 93	-- /*����*/	
MSG_CHAT_NOTICE		= 94	-- /*����*/	
CMSG_QUERY_PLAYER_INFO		= 95	-- /*��ѯ�����Ϣ*/	
SMSG_QUERY_RESULT_UPDATE_OBJECT		= 96	-- /*��ѯ��Ϣ�������*/	
CMSG_RECEIVE_GIFT_PACKS		= 97	-- /*��ȡ���*/	
SMSG_MAP_UPDATE_OBJECT		= 98	-- /*��ͼ�������*/	
SMSG_FIGHTING_INFO_UPDATE_OBJECT		= 99	-- /*ս����Ϣbinlog*/	
SMSG_FIGHTING_INFO_UPDATE_OBJECT_2		= 100	-- /*ս����Ϣbinlog*/	
CMSG_INSTANCE_ENTER		= 101	-- /*���븱��*/	
CMSG_INSTANCE_NEXT_STATE		= 102	-- /*�����˷��͸���������һ�׶�ָ��*/	
CMSG_INSTANCE_EXIT		= 103	-- /*�����˳�*/	
CMSG_LIMIT_ACTIVITY_RECEIVE		= 104	-- /*��ʱ���ȡ*/	
SMSG_KILL_MAN		= 105	-- /*ɱ����~~��������*/	
SMSG_PLAYER_UPGRADE		= 106	-- /*�������*/	
CMSG_WAREHOUSE_SAVE_MONEY		= 107	-- /*�ֿ��Ǯ*/	
CMSG_WAREHOUSE_TAKE_MONEY		= 108	-- /*�ֿ�ȡǮ*/	
CMSG_USE_GOLD_OPT		= 109	-- /*ʹ��Ԫ������ĳ��*/	
CMSG_USE_SILVER_OPT		= 110	-- /*ʹ��ͭǮ����ĳ��*/	
SMSG_GM_RIGHTFLOAT		= 111	-- /*��̨����*/	
SMSG_DEL_GM_RIGHTFLOAT		= 112	-- /*ɾ��ĳ����̨����*/	
MSG_SYNC_MSTIME_APP		= 113	-- /*Ӧ�÷�ͬ��ʱ��*/	
CMSG_OPEN_WINDOW		= 114	-- /*��Ҵ�ĳ������*/	
CMSG_PLAYER_GAG		= 115	-- /*���Բ���*/	
CMSG_PLAYER_KICKING		= 116	-- /*���˲���*/	
SMSG_MERGE_SERVER_MSG		= 117	-- /*�Ϸ�֪ͨ*/	
CMSG_RANK_LIST_QUERY		= 118	-- /*��ȡ������Ϣ*/	
SMSG_RANK_LIST_QUERY_RESULT		= 119	-- /*�ͻ��˻�ȡ���а񷵻ؽ��*/	
CMSG_CLIENT_UPDATE_SCENED		= 120	-- /*�ͻ����ȸ�����ģ����ȡuint*/	
SMSG_NUM_LUA		= 121	-- /*��ֵ��*/	
CMSG_LOOT_SELECT		= 122	-- /*ս��Ʒʰȡ*/	
CMSG_GOBACK_TO_GAME_SERVER		= 123	-- /*֪ͨ��¼������Ҵ�����Ϸ��*/	
CMSG_WORLD_WAR_CS_PLAYER_INFO		= 124	-- /*�ͻ��˰ѱ�����Ա���ݴ���������*/	
SMSG_JOIN_OR_LEAVE_SERVER		= 125	-- /*��Ҽ�������뿪ĳ������*/	
MSG_WORLD_WAR_SC_PLAYER_INFO		= 126	-- /*�ͻ�����������Ա����*/	
MSG_CLIENTSUBSCRIPTION		= 127	-- /*�ͻ��˶�����Ϣ*/	
SMSG_LUA_SCRIPT		= 128	-- /*������·�lua�ű�*/	
CMSG_CHAR_UPDATE_INFO		= 129	-- /*��ɫ������Ϣ*/	
SMSG_NOTICE_WATCHER_MAP_INFO		= 130	-- /*֪ͨ�ͻ��˹۲��ߵ��ӽ�*/	
CMSG_MODIFY_WATCH		= 131	-- /*�ͻ��˶��Ķ�����Ϣ*/	
CMSG_KUAFU_CHUANSONG		= 132	-- /*�������*/	
CMSG_STRENGTH		= 139	-- /*ǿ��*/	
SMSG_STRENGTH_SUCCESS		= 140	-- /*ǿ���ɹ�*/	
CMSG_FORCEINTO		= 141	-- /*ǿ�ƽ���*/	
CMSG_CREATE_FACTION		= 142	-- /*��������*/	
CMSG_FACTION_UPGRADE		= 143	-- /*��������*/	
CMSG_FACTION_JOIN		= 144	-- /*����������*/	
CMSG_RAISE_BASE_SPELL		= 145	-- /*������������*/	
CMSG_UPGRADE_ANGER_SPELL		= 146	-- /*�������׷�ŭ����*/	
CMSG_RAISE_MOUNT		= 147	-- /*������������*/	
CMSG_UPGRADE_MOUNT		= 148	-- /*������������*/	
CMSG_UPGRADE_MOUNT_ONE_STEP		= 149	-- /*����һ����������*/	
CMSG_ILLUSION_MOUNT_ACTIVE		= 150	-- /*��������û�����*/	
CMSG_ILLUSION_MOUNT		= 151	-- /*����û�����*/	
CMSG_RIDE_MOUNT		= 152	-- /*�������*/	


---------------------------------------------------------------------
--/*����ṹ��*/

point_t = class('point_t')

function point_t:read( input )

	local ret
	ret,self.pos_x = input:readFloat() --/*����X*/

	if not ret then
		return ret
	end
	ret,self.pos_y = input:readFloat() --/*����Y*/

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
--/*���͵ص�ṹ��*/

taxi_menu_info_t = class('taxi_menu_info_t')

function taxi_menu_info_t:read( input )

	local ret
	ret,self.id = input:readI32() --/**/

	if not ret then
		return ret
	end
	ret,self.taxi_text = input:readUTFByLen(50)  --/*���͵ص�����*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.map_id = input:readU32() --/*��ͼID*/

	if not ret then
		return ret
	end
	ret,self.pos_x = input:readU16() --/*����X*/

	if not ret then
		return ret
	end
	ret,self.pos_y = input:readU16() --/*����Y*/

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
--/*��ҽ�ɫ����ѡ����Ϣ*/

char_create_info_t = class('char_create_info_t')

function char_create_info_t:read( input )

	local ret
	ret,self.name = input:readUTFByLen(50)  --/*����*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.faction = input:readByte() --/*��Ӫ*/

	if not ret then
		return ret
	end
	ret,self.gender = input:readByte() --/*�Ա�*/

	if not ret then
		return ret
	end
	ret,self.level = input:readU16() --/*�ȼ�*/

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
	ret,self.head_id = input:readU32() --/*ͷ��*/

	if not ret then
		return ret
	end
	ret,self.hair_id = input:readU32() --/*����ID*/

	if not ret then
		return ret
	end
	ret,self.race = input:readByte() --/*���壬������Ů������Щ*/

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
--/*����˵�*/

quest_option_t = class('quest_option_t')

function quest_option_t:read( input )

	local ret
	ret,self.quest_id = input:readU32() --/*����id*/

	if not ret then
		return ret
	end
	ret,self.quest_icon = input:readU32() --/*ͼ��*/

	if not ret then
		return ret
	end
	ret,self.quest_level = input:readU16() --/*����ȼ�*/

	if not ret then
		return ret
	end
	ret,self.quest_title = input:readUTFByLen(50)  --/*�������*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.flags = input:readU32() --/*��ʶ*/

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
--/*�ɽ�������Ϣ*/

quest_canaccept_info_t = class('quest_canaccept_info_t')

function quest_canaccept_info_t:read( input )

	local ret
	ret,self.quest_id = input:readU32() --/*����ID*/

	if not ret then
		return ret
	end
	ret,self.quest_type = input:readByte() --/*�������*/

	if not ret then
		return ret
	end
	ret,self.title = input:readUTFByLen(50)  --/*����*/

	if not ret then
		return ret
	end

	if not ret then
		return ret
	end
	ret,self.npc_id = input:readU32() --/*��������NPCģ��id*/

	if not ret then
		return ret
	end
	ret,self.quest_level = input:readU32() --/*����ȼ�*/

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
--/*����ѡ��ṹ��*/

gossip_menu_option_info_t = class('gossip_menu_option_info_t')

function gossip_menu_option_info_t:read( input )

	local ret
	ret,self.id = input:readI32() --/*id*/

	if not ret then
		return ret
	end
	ret,self.option_icon = input:readI32() --/*ѡ��iconͼ��*/

	if not ret then
		return ret
	end
	ret,self.option_title = input:readUTFByLen(200)  --/*ѡ���ı�*/

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
--/*��Ʒ��ȴ*/

item_cooldown_info_t = class('item_cooldown_info_t')

function item_cooldown_info_t:read( input )

	local ret
	ret,self.item = input:readU32() --/*��Ʒ����*/

	if not ret then
		return ret
	end
	ret,self.cooldown = input:readU32() --/*��ȴʱ��*/

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
--/*����״̬*/

quest_status_t = class('quest_status_t')

function quest_status_t:read( input )

	local ret
	ret,self.quest_id = input:readU16() --/*����ID*/

	if not ret then
		return ret
	end
	ret,self.status = input:readByte() --/*����״̬*/

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
--Э��򡢽��

-- /*��Ч����*/	
function Protocols.pack_null_action (  )
	local output = Packet.new(MSG_NULL_ACTION)
	return output
end

-- /*��Ч����*/	
function Protocols.call_null_action ( playerInfo )
	local output = Protocols.	pack_null_action (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��Ч����*/	
function Protocols.unpack_null_action (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��������״̬*/	
function Protocols.pack_ping_pong (  )
	local output = Packet.new(MSG_PING_PONG)
	return output
end

-- /*��������״̬*/	
function Protocols.call_ping_pong ( playerInfo )
	local output = Protocols.	pack_ping_pong (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������״̬*/	
function Protocols.unpack_ping_pong (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*�ߵ����ߵ�׼��ǿ�Ƶ�½*/	
function Protocols.pack_forced_into (  )
	local output = Packet.new(CMSG_FORCED_INTO)
	return output
end

-- /*�ߵ����ߵ�׼��ǿ�Ƶ�½*/	
function Protocols.call_forced_into ( playerInfo )
	local output = Protocols.	pack_forced_into (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ߵ����ߵ�׼��ǿ�Ƶ�½*/	
function Protocols.unpack_forced_into (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*���Session����*/	
function Protocols.pack_get_session ( sessionkey ,account ,version)
	local output = Packet.new(CMSG_GET_SESSION)
	output:writeUTF(sessionkey)
	output:writeUTF(account)
	output:writeUTF(version)
	return output
end

-- /*���Session����*/	
function Protocols.call_get_session ( playerInfo, sessionkey ,account ,version)
	local output = Protocols.	pack_get_session ( sessionkey ,account ,version)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���Session����*/	
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


-- /*���ط����ݰ�·�ɲ���*/	
function Protocols.pack_route_trace ( val)
	local output = Packet.new(MSG_ROUTE_TRACE)
	output:writeUTF(val)
	return output
end

-- /*���ط����ݰ�·�ɲ���*/	
function Protocols.call_route_trace ( playerInfo, val)
	local output = Protocols.	pack_route_trace ( val)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���ط����ݰ�·�ɲ���*/	
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


-- /*��¼�ͻ�����־*/	
function Protocols.pack_write_client_log ( type ,uid ,guid ,log)
	local output = Packet.new(CMSG_WRITE_CLIENT_LOG)
	output:writeU32(type)
	output:writeUTF(uid)
	output:writeUTF(guid)
	output:writeUTF(log)
	return output
end

-- /*��¼�ͻ�����־*/	
function Protocols.call_write_client_log ( playerInfo, type ,uid ,guid ,log)
	local output = Protocols.	pack_write_client_log ( type ,uid ,guid ,log)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��¼�ͻ�����־*/	
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


-- /*����ʧ��*/	
function Protocols.pack_operation_failed ( type ,reason ,data)
	local output = Packet.new(SMSG_OPERATION_FAILED)
	output:writeI16(type)
	output:writeI16(reason)
	output:writeUTF(data)
	return output
end

-- /*����ʧ��*/	
function Protocols.call_operation_failed ( playerInfo, type ,reason ,data)
	local output = Protocols.	pack_operation_failed ( type ,reason ,data)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ʧ��*/	
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


-- /*ͬ��ʱ��*/	
function Protocols.pack_sync_mstime ( mstime_now ,time_now ,open_time)
	local output = Packet.new(MSG_SYNC_MSTIME)
	output:writeU32(mstime_now)
	output:writeU32(time_now)
	output:writeU32(open_time)
	return output
end

-- /*ͬ��ʱ��*/	
function Protocols.call_sync_mstime ( playerInfo, mstime_now ,time_now ,open_time)
	local output = Protocols.	pack_sync_mstime ( mstime_now ,time_now ,open_time)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ͬ��ʱ��*/	
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


-- /*�������*/	
function Protocols.pack_ud_object (  )
	local output = Packet.new(SMSG_UD_OBJECT)
	return output
end

-- /*�������*/	
function Protocols.call_ud_object ( playerInfo )
	local output = Protocols.	pack_ud_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������*/	
function Protocols.unpack_ud_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*������¿���Э��*/	
function Protocols.pack_ud_control (  )
	local output = Packet.new(CMSG_UD_CONTROL)
	return output
end

-- /*������¿���Э��*/	
function Protocols.call_ud_control ( playerInfo )
	local output = Protocols.	pack_ud_control (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������¿���Э��*/	
function Protocols.unpack_ud_control (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*������¿���Э����*/	
function Protocols.pack_ud_control_result (  )
	local output = Packet.new(SMSG_UD_CONTROL_RESULT)
	return output
end

-- /*������¿���Э����*/	
function Protocols.call_ud_control_result ( playerInfo )
	local output = Protocols.	pack_ud_control_result (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������¿���Э����*/	
function Protocols.unpack_ud_control_result (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*GRID�Ķ������*/	
function Protocols.pack_grid_ud_object (  )
	local output = Packet.new(SMSG_GRID_UD_OBJECT)
	return output
end

-- /*GRID�Ķ������*/	
function Protocols.call_grid_ud_object ( playerInfo )
	local output = Protocols.	pack_grid_ud_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*GRID�Ķ������*/	
function Protocols.unpack_grid_ud_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*GRID�Ķ������*/	
function Protocols.pack_grid_ud_object_2 (  )
	local output = Packet.new(SMSG_GRID_UD_OBJECT_2)
	return output
end

-- /*GRID�Ķ������*/	
function Protocols.call_grid_ud_object_2 ( playerInfo )
	local output = Protocols.	pack_grid_ud_object_2 (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*GRID�Ķ������*/	
function Protocols.unpack_grid_ud_object_2 (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*���߿ͻ��ˣ�Ŀǰ�Լ����ڵ�¼���еĵڼ�λ*/	
function Protocols.pack_login_queue_index ( index)
	local output = Packet.new(SMSG_LOGIN_QUEUE_INDEX)
	output:writeU32(index)
	return output
end

-- /*���߿ͻ��ˣ�Ŀǰ�Լ����ڵ�¼���еĵڼ�λ*/	
function Protocols.call_login_queue_index ( playerInfo, index)
	local output = Protocols.	pack_login_queue_index ( index)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���߿ͻ��ˣ�Ŀǰ�Լ����ڵ�¼���еĵڼ�λ*/	
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


-- /*����ԭ��*/	
function Protocols.pack_kicking_type ( k_type)
	local output = Packet.new(SMSG_KICKING_TYPE)
	output:writeU32(k_type)
	return output
end

-- /*����ԭ��*/	
function Protocols.call_kicking_type ( playerInfo, k_type)
	local output = Protocols.	pack_kicking_type ( k_type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ԭ��*/	
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


-- /*��ȡ��ɫ�б�*/	
function Protocols.pack_get_chars_list (  )
	local output = Packet.new(CMSG_GET_CHARS_LIST)
	return output
end

-- /*��ȡ��ɫ�б�*/	
function Protocols.call_get_chars_list ( playerInfo )
	local output = Protocols.	pack_get_chars_list (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ȡ��ɫ�б�*/	
function Protocols.unpack_get_chars_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��ɫ�б�*/	
function Protocols.pack_chars_list ( list)
	local output = Packet.new(SMSG_CHARS_LIST)
	output:writeI16(#list)
	for i = 1,#list,1
	do
		list[i]:write(output)
	end
	return output
end

-- /*��ɫ�б�*/	
function Protocols.call_chars_list ( playerInfo, list)
	local output = Protocols.	pack_chars_list ( list)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ɫ�б�*/	
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


-- /*��������Ƿ����ʹ��*/	
function Protocols.pack_check_name ( name)
	local output = Packet.new(CMSG_CHECK_NAME)
	output:writeUTF(name)
	return output
end

-- /*��������Ƿ����ʹ��*/	
function Protocols.call_check_name ( playerInfo, name)
	local output = Protocols.	pack_check_name ( name)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������Ƿ����ʹ��*/	
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


-- /*������ֽ��*/	
function Protocols.pack_check_name_result ( result)
	local output = Packet.new(SMSG_CHECK_NAME_RESULT)
	output:writeByte(result)
	return output
end

-- /*������ֽ��*/	
function Protocols.call_check_name_result ( playerInfo, result)
	local output = Protocols.	pack_check_name_result ( result)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������ֽ��*/	
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


-- /*������ɫ*/	
function Protocols.pack_char_create ( info)
	local output = Packet.new(CMSG_CHAR_CREATE)
	info :write(output)
	return output
end

-- /*������ɫ*/	
function Protocols.call_char_create ( playerInfo, info)
	local output = Protocols.	pack_char_create ( info)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������ɫ*/	
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


-- /*��ɫ�������*/	
function Protocols.pack_char_create_result ( result)
	local output = Packet.new(SMSG_CHAR_CREATE_RESULT)
	output:writeByte(result)
	return output
end

-- /*��ɫ�������*/	
function Protocols.call_char_create_result ( playerInfo, result)
	local output = Protocols.	pack_char_create_result ( result)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ɫ�������*/	
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


-- /*ɾ����ɫ*/	
function Protocols.pack_delete_char ( id)
	local output = Packet.new(CMSG_DELETE_CHAR)
	output:writeU32(id)
	return output
end

-- /*ɾ����ɫ*/	
function Protocols.call_delete_char ( playerInfo, id)
	local output = Protocols.	pack_delete_char ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ɾ����ɫ*/	
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


-- /*��ɫɾ�����*/	
function Protocols.pack_delete_char_result ( result)
	local output = Packet.new(SMSG_DELETE_CHAR_RESULT)
	output:writeByte(result)
	return output
end

-- /*��ɫɾ�����*/	
function Protocols.call_delete_char_result ( playerInfo, result)
	local output = Protocols.	pack_delete_char_result ( result)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ɫɾ�����*/	
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


-- /*��ҵ�¼*/	
function Protocols.pack_player_login ( guid)
	local output = Packet.new(CMSG_PLAYER_LOGIN)
	output:writeUTF(guid)
	return output
end

-- /*��ҵ�¼*/	
function Protocols.call_player_login ( playerInfo, guid)
	local output = Protocols.	pack_player_login ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ҵ�¼*/	
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


-- /*����˳�*/	
function Protocols.pack_player_logout (  )
	local output = Packet.new(CMSG_PLAYER_LOGOUT)
	return output
end

-- /*����˳�*/	
function Protocols.call_player_logout ( playerInfo )
	local output = Protocols.	pack_player_logout (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����˳�*/	
function Protocols.unpack_player_logout (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��ʱ�˺�ת����*/	
function Protocols.pack_regularise_account ( uid)
	local output = Packet.new(CMSG_REGULARISE_ACCOUNT)
	output:writeUTF(uid)
	return output
end

-- /*��ʱ�˺�ת����*/	
function Protocols.call_regularise_account ( playerInfo, uid)
	local output = Protocols.	pack_regularise_account ( uid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ʱ�˺�ת����*/	
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


-- /*��ɫ������Ϣ*/	
function Protocols.pack_char_remotestore ( key ,value)
	local output = Packet.new(CMSG_CHAR_REMOTESTORE)
	output:writeU32(key)
	output:writeU32(value)
	return output
end

-- /*��ɫ������Ϣ*/	
function Protocols.call_char_remotestore ( playerInfo, key ,value)
	local output = Protocols.	pack_char_remotestore ( key ,value)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ɫ������Ϣ*/	
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


-- /*��ɫ������Ϣ*/	
function Protocols.pack_char_remotestore_str ( key ,value)
	local output = Packet.new(CMSG_CHAR_REMOTESTORE_STR)
	output:writeU32(key)
	output:writeUTF(value)
	return output
end

-- /*��ɫ������Ϣ*/	
function Protocols.call_char_remotestore_str ( playerInfo, key ,value)
	local output = Protocols.	pack_char_remotestore_str ( key ,value)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ɫ������Ϣ*/	
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


-- /*���ͣ������C->S��mapid��������ɴ��͵�ID*/	
function Protocols.pack_teleport ( intGuid)
	local output = Packet.new(CMSG_TELEPORT)
	output:writeU32(intGuid)
	return output
end

-- /*���ͣ������C->S��mapid��������ɴ��͵�ID*/	
function Protocols.call_teleport ( playerInfo, intGuid)
	local output = Protocols.	pack_teleport ( intGuid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���ͣ������C->S��mapid��������ɴ��͵�ID*/	
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


-- /*ֹͣ�ƶ�*/	
function Protocols.pack_move_stop ( guid ,pos_x ,pos_y)
	local output = Packet.new(MSG_MOVE_STOP)
	output:writeU32(guid)
	output:writeI16(pos_x)
	output:writeI16(pos_y)
	return output
end

-- /*ֹͣ�ƶ�*/	
function Protocols.call_move_stop ( playerInfo, guid ,pos_x ,pos_y)
	local output = Protocols.	pack_move_stop ( guid ,pos_x ,pos_y)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ֹͣ�ƶ�*/	
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


-- /*unit�����ƶ�*/	
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

-- /*unit�����ƶ�*/	
function Protocols.call_unit_move ( playerInfo, guid ,pos_x ,pos_y ,path)
	local output = Protocols.	pack_unit_move ( guid ,pos_x ,pos_y ,path)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*unit�����ƶ�*/	
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


-- /*ʹ����Ϸ����*/	
function Protocols.pack_use_gameobject ( target)
	local output = Packet.new(CMSG_USE_GAMEOBJECT)
	output:writeU32(target)
	return output
end

-- /*ʹ����Ϸ����*/	
function Protocols.call_use_gameobject ( playerInfo, target)
	local output = Protocols.	pack_use_gameobject ( target)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ʹ����Ϸ����*/	
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


-- /*��������-����λ��*/	
function Protocols.pack_bag_exchange_pos ( src_bag ,src_pos ,dst_bag ,dst_pos)
	local output = Packet.new(CMSG_BAG_EXCHANGE_POS)
	output:writeU32(src_bag)
	output:writeU32(src_pos)
	output:writeU32(dst_bag)
	output:writeU32(dst_pos)
	return output
end

-- /*��������-����λ��*/	
function Protocols.call_bag_exchange_pos ( playerInfo, src_bag ,src_pos ,dst_bag ,dst_pos)
	local output = Protocols.	pack_bag_exchange_pos ( src_bag ,src_pos ,dst_bag ,dst_pos)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������-����λ��*/	
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


-- /*��������-������Ʒ*/	
function Protocols.pack_bag_destroy ( item_guid ,num ,bag_id)
	local output = Packet.new(CMSG_BAG_DESTROY)
	output:writeUTF(item_guid)
	output:writeU32(num)
	output:writeU32(bag_id)
	return output
end

-- /*��������-������Ʒ*/	
function Protocols.call_bag_destroy ( playerInfo, item_guid ,num ,bag_id)
	local output = Protocols.	pack_bag_destroy ( item_guid ,num ,bag_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������-������Ʒ*/	
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


-- /*�ָ���Ʒ*/	
function Protocols.pack_bag_item_split ( bag_id ,src_pos ,count ,dst_pos ,dst_bag)
	local output = Packet.new(CMSG_BAG_ITEM_SPLIT)
	output:writeByte(bag_id)
	output:writeI16(src_pos)
	output:writeU32(count)
	output:writeI16(dst_pos)
	output:writeByte(dst_bag)
	return output
end

-- /*�ָ���Ʒ*/	
function Protocols.call_bag_item_split ( playerInfo, bag_id ,src_pos ,count ,dst_pos ,dst_bag)
	local output = Protocols.	pack_bag_item_split ( bag_id ,src_pos ,count ,dst_pos ,dst_bag)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ָ���Ʒ*/	
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


-- /*ʹ����Ʒ*/	
function Protocols.pack_bag_item_user ( item_guid ,count)
	local output = Packet.new(CMSG_BAG_ITEM_USER)
	output:writeUTF(item_guid)
	output:writeU32(count)
	return output
end

-- /*ʹ����Ʒ*/	
function Protocols.call_bag_item_user ( playerInfo, item_guid ,count)
	local output = Protocols.	pack_bag_item_user ( item_guid ,count)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ʹ����Ʒ*/	
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


-- /*�·���Ʒ��ȴ*/	
function Protocols.pack_bag_item_cooldown ( list)
	local output = Packet.new(SMSG_BAG_ITEM_COOLDOWN)
	output:writeI16(#list)
	for i = 1,#list,1
	do
		list[i]:write(output)
	end
	return output
end

-- /*�·���Ʒ��ȴ*/	
function Protocols.call_bag_item_cooldown ( playerInfo, list)
	local output = Protocols.	pack_bag_item_cooldown ( list)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�·���Ʒ��ȴ*/	
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


-- /*grid�е�unit�ƶ�������*/	
function Protocols.pack_grid_unit_move (  )
	local output = Packet.new(SMSG_GRID_UNIT_MOVE)
	return output
end

-- /*grid�е�unit�ƶ�������*/	
function Protocols.call_grid_unit_move ( playerInfo )
	local output = Protocols.	pack_grid_unit_move (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*grid�е�unit�ƶ�������*/	
function Protocols.unpack_grid_unit_move (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*grid�е�unit�ƶ�������2*/	
function Protocols.pack_grid_unit_move_2 (  )
	local output = Packet.new(SMSG_GRID_UNIT_MOVE_2)
	return output
end

-- /*grid�е�unit�ƶ�������2*/	
function Protocols.call_grid_unit_move_2 ( playerInfo )
	local output = Protocols.	pack_grid_unit_move_2 (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*grid�е�unit�ƶ�������2*/	
function Protocols.unpack_grid_unit_move_2 (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*�һ���Ʒ*/	
function Protocols.pack_exchange_item ( entry ,count ,tar_entry)
	local output = Packet.new(CMSG_EXCHANGE_ITEM)
	output:writeU32(entry)
	output:writeU32(count)
	output:writeU32(tar_entry)
	return output
end

-- /*�һ���Ʒ*/	
function Protocols.call_exchange_item ( playerInfo, entry ,count ,tar_entry)
	local output = Protocols.	pack_exchange_item ( entry ,count ,tar_entry)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�һ���Ʒ*/	
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


-- /*������չ*/	
function Protocols.pack_bag_extension ( bag_id ,extension_type ,bag_pos)
	local output = Packet.new(CMSG_BAG_EXTENSION)
	output:writeByte(bag_id)
	output:writeByte(extension_type)
	output:writeU32(bag_pos)
	return output
end

-- /*������չ*/	
function Protocols.call_bag_extension ( playerInfo, bag_id ,extension_type ,bag_pos)
	local output = Protocols.	pack_bag_extension ( bag_id ,extension_type ,bag_pos)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������չ*/	
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


-- /*����NPC��Ʒ�б�*/	
function Protocols.pack_npc_get_goods_list ( npc_id)
	local output = Packet.new(CMSG_NPC_GET_GOODS_LIST)
	output:writeU32(npc_id)
	return output
end

-- /*����NPC��Ʒ�б�*/	
function Protocols.call_npc_get_goods_list ( playerInfo, npc_id)
	local output = Protocols.	pack_npc_get_goods_list ( npc_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����NPC��Ʒ�б�*/	
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


-- /*Npc��Ʒ�б�*/	
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

-- /*Npc��Ʒ�б�*/	
function Protocols.call_npc_goods_list ( playerInfo, goods ,npc_id)
	local output = Protocols.	pack_npc_goods_list ( goods ,npc_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*Npc��Ʒ�б�*/	
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


-- /*������Ʒ*/	
function Protocols.pack_npc_buy ( id ,num ,npc_id ,do_use ,money_type)
	local output = Packet.new(CMSG_NPC_BUY)
	output:writeU32(id)
	output:writeU32(num)
	output:writeU32(npc_id)
	output:writeByte(do_use)
	output:writeByte(money_type)
	return output
end

-- /*������Ʒ*/	
function Protocols.call_npc_buy ( playerInfo, id ,num ,npc_id ,do_use ,money_type)
	local output = Protocols.	pack_npc_buy ( id ,num ,npc_id ,do_use ,money_type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������Ʒ*/	
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


-- /*������Ʒ*/	
function Protocols.pack_npc_sell ( npc_id ,item_guid ,num)
	local output = Packet.new(CMSG_NPC_SELL)
	output:writeU32(npc_id)
	output:writeUTF(item_guid)
	output:writeU32(num)
	return output
end

-- /*������Ʒ*/	
function Protocols.call_npc_sell ( playerInfo, npc_id ,item_guid ,num)
	local output = Protocols.	pack_npc_sell ( npc_id ,item_guid ,num)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������Ʒ*/	
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


-- /*�ع���Ʒ*/	
function Protocols.pack_npc_repurchase ( item_id)
	local output = Packet.new(CMSG_NPC_REPURCHASE)
	output:writeUTF(item_id)
	return output
end

-- /*�ع���Ʒ*/	
function Protocols.call_npc_repurchase ( playerInfo, item_id)
	local output = Protocols.	pack_npc_repurchase ( item_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ع���Ʒ*/	
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


-- /*ʱװ�Ƿ�����*/	
function Protocols.pack_avatar_fashion_enable ( pos)
	local output = Packet.new(CMSG_AVATAR_FASHION_ENABLE)
	output:writeByte(pos)
	return output
end

-- /*ʱװ�Ƿ�����*/	
function Protocols.call_avatar_fashion_enable ( playerInfo, pos)
	local output = Protocols.	pack_avatar_fashion_enable ( pos)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ʱװ�Ƿ�����*/	
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


-- /*����Ի�ѡ��*/	
function Protocols.pack_questhelp_talk_option ( quest_id ,option_id ,value0 ,value1)
	local output = Packet.new(CMSG_QUESTHELP_TALK_OPTION)
	output:writeU32(quest_id)
	output:writeU32(option_id)
	output:writeI32(value0)
	output:writeI32(value1)
	return output
end

-- /*����Ի�ѡ��*/	
function Protocols.call_questhelp_talk_option ( playerInfo, quest_id ,option_id ,value0 ,value1)
	local output = Protocols.	pack_questhelp_talk_option ( quest_id ,option_id ,value0 ,value1)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����Ի�ѡ��*/	
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


-- /*��NPC�Ի���ô��͵��б�*/	
function Protocols.pack_taxi_hello ( guid)
	local output = Packet.new(CMSG_TAXI_HELLO)
	output:writeU32(guid)
	return output
end

-- /*��NPC�Ի���ô��͵��б�*/	
function Protocols.call_taxi_hello ( playerInfo, guid)
	local output = Protocols.	pack_taxi_hello ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��NPC�Ի���ô��͵��б�*/	
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


-- /*���ʹ��͵��б�*/	
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

-- /*���ʹ��͵��б�*/	
function Protocols.call_taxi_stations_list ( playerInfo, npcid ,stations)
	local output = Protocols.	pack_taxi_stations_list ( npcid ,stations)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���ʹ��͵��б�*/	
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


-- /*ѡ���͵�*/	
function Protocols.pack_taxi_select_station ( station_id ,guid)
	local output = Packet.new(CMSG_TAXI_SELECT_STATION)
	output:writeU32(station_id)
	output:writeU32(guid)
	return output
end

-- /*ѡ���͵�*/	
function Protocols.call_taxi_select_station ( playerInfo, station_id ,guid)
	local output = Protocols.	pack_taxi_select_station ( station_id ,guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ѡ���͵�*/	
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


-- /*��NPC����ѡ��ѡ��*/	
function Protocols.pack_gossip_select_option ( option ,guid ,unknow)
	local output = Packet.new(CMSG_GOSSIP_SELECT_OPTION)
	output:writeU32(option)
	output:writeU32(guid)
	output:writeUTF(unknow)
	return output
end

-- /*��NPC����ѡ��ѡ��*/	
function Protocols.call_gossip_select_option ( playerInfo, option ,guid ,unknow)
	local output = Protocols.	pack_gossip_select_option ( option ,guid ,unknow)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��NPC����ѡ��ѡ��*/	
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


-- /*��NPC���Ļ�ȡѡ��*/	
function Protocols.pack_gossip_hello ( guid)
	local output = Packet.new(CMSG_GOSSIP_HELLO)
	output:writeU32(guid)
	return output
end

-- /*��NPC���Ļ�ȡѡ��*/	
function Protocols.call_gossip_hello ( playerInfo, guid)
	local output = Protocols.	pack_gossip_hello ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��NPC���Ļ�ȡѡ��*/	
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


-- /*����������Ϣ��ѡ��*/	
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

-- /*����������Ϣ��ѡ��*/	
function Protocols.call_gossip_message ( playerInfo, npcid ,npc_entry ,option_id ,option_text ,gossip_items)
	local output = Protocols.	pack_gossip_message ( npcid ,npc_entry ,option_id ,option_text ,gossip_items)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����������Ϣ��ѡ��*/	
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


-- /*���񷢲���״̬��ѯ*/	
function Protocols.pack_questgiver_status_query ( guid)
	local output = Packet.new(CMSG_QUESTGIVER_STATUS_QUERY)
	output:writeU32(guid)
	return output
end

-- /*���񷢲���״̬��ѯ*/	
function Protocols.call_questgiver_status_query ( playerInfo, guid)
	local output = Protocols.	pack_questgiver_status_query ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���񷢲���״̬��ѯ*/	
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


-- /*����NPC״̬*/	
function Protocols.pack_questgiver_status ( guid ,status)
	local output = Packet.new(SMSG_QUESTGIVER_STATUS)
	output:writeU32(guid)
	output:writeByte(status)
	return output
end

-- /*����NPC״̬*/	
function Protocols.call_questgiver_status ( playerInfo, guid ,status)
	local output = Protocols.	pack_questgiver_status ( guid ,status)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����NPC״̬*/	
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


-- /*��ѯ����״̬*/	
function Protocols.pack_query_quest_status ( quest_array)
	local output = Packet.new(MSG_QUERY_QUEST_STATUS)
	output:writeI16(#quest_array)
	for i = 1,#quest_array,1
	do
		quest_array[i]:write(output)
	end
	return output
end

-- /*��ѯ����״̬*/	
function Protocols.call_query_quest_status ( playerInfo, quest_array)
	local output = Protocols.	pack_query_quest_status ( quest_array)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ѯ����״̬*/	
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


-- /*�ɽ�����*/	
function Protocols.pack_questhelp_get_canaccept_list (  )
	local output = Packet.new(CMSG_QUESTHELP_GET_CANACCEPT_LIST)
	return output
end

-- /*�ɽ�����*/	
function Protocols.call_questhelp_get_canaccept_list ( playerInfo )
	local output = Protocols.	pack_questhelp_get_canaccept_list (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ɽ�����*/	
function Protocols.unpack_questhelp_get_canaccept_list (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*�·��ɽ������б�*/	
function Protocols.pack_questhelp_canaccept_list ( quests)
	local output = Packet.new(SMSG_QUESTHELP_CANACCEPT_LIST)
	output:writeI16(#quests)
	for i = 1,#quests,1
	do
					output:writeU32(quests[i])
			end
	return output
end

-- /*�·��ɽ������б�*/	
function Protocols.call_questhelp_canaccept_list ( playerInfo, quests)
	local output = Protocols.	pack_questhelp_canaccept_list ( quests)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�·��ɽ������б�*/	
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


-- /*����ʧ��*/	
function Protocols.pack_questupdate_faild ( reason)
	local output = Packet.new(SMSG_QUESTUPDATE_FAILD)
	output:writeByte(reason)
	return output
end

-- /*����ʧ��*/	
function Protocols.call_questupdate_faild ( playerInfo, reason)
	local output = Protocols.	pack_questupdate_faild ( reason)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ʧ��*/	
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


-- /*�����������*/	
function Protocols.pack_questupdate_complete ( quest_id)
	local output = Packet.new(SMSG_QUESTUPDATE_COMPLETE)
	output:writeU32(quest_id)
	return output
end

-- /*�����������*/	
function Protocols.call_questupdate_complete ( playerInfo, quest_id)
	local output = Protocols.	pack_questupdate_complete ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�����������*/	
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


-- /*��������*/	
function Protocols.pack_questlog_remove_quest ( slot ,reserve)
	local output = Packet.new(CMSG_QUESTLOG_REMOVE_QUEST)
	output:writeByte(slot)
	return output
end

-- /*��������*/	
function Protocols.call_questlog_remove_quest ( playerInfo, slot ,reserve)
	local output = Protocols.	pack_questlog_remove_quest ( slot ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������*/	
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


-- /*�������*/	
function Protocols.pack_questgiver_complete_quest ( guid ,quest_id ,reward)
	local output = Packet.new(CMSG_QUESTGIVER_COMPLETE_QUEST)
	output:writeU32(guid)
	output:writeU32(quest_id)
	output:writeByte(reward)
	return output
end

-- /*�������*/	
function Protocols.call_questgiver_complete_quest ( playerInfo, guid ,quest_id ,reward)
	local output = Protocols.	pack_questgiver_complete_quest ( guid ,quest_id ,reward)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������*/	
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


-- /*��������֪ͨ���������¸�����*/	
function Protocols.pack_questhelp_next ( current_id ,next_id ,guid)
	local output = Packet.new(SMSG_QUESTHELP_NEXT)
	output:writeU32(current_id)
	output:writeU32(next_id)
	output:writeU32(guid)
	return output
end

-- /*��������֪ͨ���������¸�����*/	
function Protocols.call_questhelp_next ( playerInfo, current_id ,next_id ,guid)
	local output = Protocols.	pack_questhelp_next ( current_id ,next_id ,guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������֪ͨ���������¸�����*/	
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


-- /*����ϵͳǿ���������*/	
function Protocols.pack_questhelp_complete ( quest_id ,quest_statue ,reserve)
	local output = Packet.new(CMSG_QUESTHELP_COMPLETE)
	output:writeU32(quest_id)
	output:writeByte(quest_statue)
	output:writeByte(reserve)
	return output
end

-- /*����ϵͳǿ���������*/	
function Protocols.call_questhelp_complete ( playerInfo, quest_id ,quest_statue ,reserve)
	local output = Protocols.	pack_questhelp_complete ( quest_id ,quest_statue ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ϵͳǿ���������*/	
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


-- /*��������ɹ�*/	
function Protocols.pack_questupdate_accept ( quest_id)
	local output = Packet.new(SMSG_QUESTUPDATE_ACCEPT)
	output:writeU32(quest_id)
	return output
end

-- /*��������ɹ�*/	
function Protocols.call_questupdate_accept ( playerInfo, quest_id)
	local output = Protocols.	pack_questupdate_accept ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������ɹ�*/	
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


-- /*�����������_�±�����*/	
function Protocols.pack_questhelp_update_status ( quest_id ,slot_id ,num)
	local output = Packet.new(CMSG_QUESTHELP_UPDATE_STATUS)
	output:writeU32(quest_id)
	output:writeU32(slot_id)
	output:writeU32(num)
	return output
end

-- /*�����������_�±�����*/	
function Protocols.call_questhelp_update_status ( playerInfo, quest_id ,slot_id ,num)
	local output = Protocols.	pack_questhelp_update_status ( quest_id ,slot_id ,num)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�����������_�±�����*/	
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


-- /*���������*/	
function Protocols.pack_questgetter_complete ( quest_id)
	local output = Packet.new(SMSG_QUESTGETTER_COMPLETE)
	output:writeU32(quest_id)
	return output
end

-- /*���������*/	
function Protocols.call_questgetter_complete ( playerInfo, quest_id)
	local output = Protocols.	pack_questgetter_complete ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���������*/	
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


-- /*������*/	
function Protocols.pack_questgiver_accept_quest ( npcid ,quest_id)
	local output = Packet.new(CMSG_QUESTGIVER_ACCEPT_QUEST)
	output:writeU32(npcid)
	output:writeU32(quest_id)
	return output
end

-- /*������*/	
function Protocols.call_questgiver_accept_quest ( playerInfo, npcid ,quest_id)
	local output = Protocols.	pack_questgiver_accept_quest ( npcid ,quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������*/	
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


-- /*����ʹ����Ʒ*/	
function Protocols.pack_questupdate_use_item ( item_id)
	local output = Packet.new(CMSG_QUESTUPDATE_USE_ITEM)
	output:writeU32(item_id)
	return output
end

-- /*����ʹ����Ʒ*/	
function Protocols.call_questupdate_use_item ( playerInfo, item_id)
	local output = Protocols.	pack_questupdate_use_item ( item_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ʹ����Ʒ*/	
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


-- /*��ѯ��������*/	
function Protocols.pack_questhelp_query_book ( dynasty)
	local output = Packet.new(CMSG_QUESTHELP_QUERY_BOOK)
	output:writeU32(dynasty)
	return output
end

-- /*��ѯ��������*/	
function Protocols.call_questhelp_query_book ( playerInfo, dynasty)
	local output = Protocols.	pack_questhelp_query_book ( dynasty)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ѯ��������*/	
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


-- /*�·��ɽ���������*/	
function Protocols.pack_questhelp_book_quest ( quest_id)
	local output = Packet.new(SMSG_QUESTHELP_BOOK_QUEST)
	output:writeU32(quest_id)
	return output
end

-- /*�·��ɽ���������*/	
function Protocols.call_questhelp_book_quest ( playerInfo, quest_id)
	local output = Protocols.	pack_questhelp_book_quest ( quest_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�·��ɽ���������*/	
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


-- /*���ʹ����Ϸ�����Ժ�Ķ���*/	
function Protocols.pack_use_gameobject_action ( player_id ,gameobject_id)
	local output = Packet.new(SMSG_USE_GAMEOBJECT_ACTION)
	output:writeU32(player_id)
	output:writeU32(gameobject_id)
	return output
end

-- /*���ʹ����Ϸ�����Ժ�Ķ���*/	
function Protocols.call_use_gameobject_action ( playerInfo, player_id ,gameobject_id)
	local output = Protocols.	pack_use_gameobject_action ( player_id ,gameobject_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���ʹ����Ϸ�����Ժ�Ķ���*/	
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


-- /*���ù���ģʽ*/	
function Protocols.pack_set_attack_mode ( mode ,reserve)
	local output = Packet.new(CMSG_SET_ATTACK_MODE)
	output:writeByte(mode)
	return output
end

-- /*���ù���ģʽ*/	
function Protocols.call_set_attack_mode ( playerInfo, mode ,reserve)
	local output = Protocols.	pack_set_attack_mode ( mode ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���ù���ģʽ*/	
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


-- /*ѡ��Ŀ��*/	
function Protocols.pack_select_target ( id)
	local output = Packet.new(MSG_SELECT_TARGET)
	output:writeU32(id)
	return output
end

-- /*ѡ��Ŀ��*/	
function Protocols.call_select_target ( playerInfo, id)
	local output = Protocols.	pack_select_target ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ѡ��Ŀ��*/	
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


-- /*����ս��*/	
function Protocols.pack_combat_state_update ( cur_state)
	local output = Packet.new(SMSG_COMBAT_STATE_UPDATE)
	output:writeByte(cur_state)
	return output
end

-- /*����ս��*/	
function Protocols.call_combat_state_update ( playerInfo, cur_state)
	local output = Protocols.	pack_combat_state_update ( cur_state)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ս��*/	
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


-- /*�������*/	
function Protocols.pack_exp_update ( exp ,type ,vip_exp)
	local output = Packet.new(SMSG_EXP_UPDATE)
	output:writeI32(exp)
	output:writeByte(type)
	output:writeI32(vip_exp)
	return output
end

-- /*�������*/	
function Protocols.call_exp_update ( playerInfo, exp ,type ,vip_exp)
	local output = Protocols.	pack_exp_update ( exp ,type ,vip_exp)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������*/	
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


-- /*�ͻ����ͷż���*/	
function Protocols.pack_spell_start ( spell_id ,target_pos_x ,target_pos_y ,caster ,target)
	local output = Packet.new(MSG_SPELL_START)
	output:writeU32(spell_id)
	output:writeI16(target_pos_x)
	output:writeI16(target_pos_y)
	output:writeU32(caster)
	output:writeU32(target)
	return output
end

-- /*�ͻ����ͷż���*/	
function Protocols.call_spell_start ( playerInfo, spell_id ,target_pos_x ,target_pos_y ,caster ,target)
	local output = Protocols.	pack_spell_start ( spell_id ,target_pos_x ,target_pos_y ,caster ,target)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͻ����ͷż���*/	
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


-- /*ʩ��ֹͣ*/	
function Protocols.pack_spell_stop ( guid)
	local output = Packet.new(MSG_SPELL_STOP)
	output:writeUTF(guid)
	return output
end

-- /*ʩ��ֹͣ*/	
function Protocols.call_spell_stop ( playerInfo, guid)
	local output = Protocols.	pack_spell_stop ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ʩ��ֹͣ*/	
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


-- /*��*/	
function Protocols.pack_jump ( guid ,pos_x ,pos_y)
	local output = Packet.new(MSG_JUMP)
	output:writeU32(guid)
	output:writeFloat(pos_x)
	output:writeFloat(pos_y)
	return output
end

-- /*��*/	
function Protocols.call_jump ( playerInfo, guid ,pos_x ,pos_y)
	local output = Protocols.	pack_jump ( guid ,pos_x ,pos_y)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��*/	
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


-- /*����*/	
function Protocols.pack_resurrection ( type ,reserve)
	local output = Packet.new(CMSG_RESURRECTION)
	output:writeByte(type)
	return output
end

-- /*����*/	
function Protocols.call_resurrection ( playerInfo, type ,reserve)
	local output = Protocols.	pack_resurrection ( type ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����*/	
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


-- /*���׷�������*/	
function Protocols.pack_trade_request ( guid)
	local output = Packet.new(MSG_TRADE_REQUEST)
	output:writeUTF(guid)
	return output
end

-- /*���׷�������*/	
function Protocols.call_trade_request ( playerInfo, guid)
	local output = Protocols.	pack_trade_request ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���׷�������*/	
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


-- /*���������*/	
function Protocols.pack_trade_reply ( guid ,reply)
	local output = Packet.new(MSG_TRADE_REPLY)
	output:writeUTF(guid)
	output:writeByte(reply)
	return output
end

-- /*���������*/	
function Protocols.call_trade_reply ( playerInfo, guid ,reply)
	local output = Protocols.	pack_trade_reply ( guid ,reply)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���������*/	
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


-- /*���׿�ʼ*/	
function Protocols.pack_trade_start ( guid)
	local output = Packet.new(SMSG_TRADE_START)
	output:writeUTF(guid)
	return output
end

-- /*���׿�ʼ*/	
function Protocols.call_trade_start ( playerInfo, guid)
	local output = Protocols.	pack_trade_start ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���׿�ʼ*/	
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


-- /*����ȷ����Ʒ*/	
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

-- /*����ȷ����Ʒ*/	
function Protocols.call_trade_decide_items ( playerInfo, items ,gold_ingot ,silver)
	local output = Protocols.	pack_trade_decide_items ( items ,gold_ingot ,silver)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ȷ����Ʒ*/	
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


-- /*�������*/	
function Protocols.pack_trade_finish (  )
	local output = Packet.new(SMSG_TRADE_FINISH)
	return output
end

-- /*�������*/	
function Protocols.call_trade_finish ( playerInfo )
	local output = Protocols.	pack_trade_finish (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������*/	
function Protocols.unpack_trade_finish (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*����ȡ��*/	
function Protocols.pack_trade_cancel (  )
	local output = Packet.new(MSG_TRADE_CANCEL)
	return output
end

-- /*����ȡ��*/	
function Protocols.call_trade_cancel ( playerInfo )
	local output = Protocols.	pack_trade_cancel (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����ȡ��*/	
function Protocols.unpack_trade_cancel (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*����׼����*/	
function Protocols.pack_trade_ready (  )
	local output = Packet.new(MSG_TRADE_READY)
	return output
end

-- /*����׼����*/	
function Protocols.call_trade_ready ( playerInfo )
	local output = Protocols.	pack_trade_ready (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����׼����*/	
function Protocols.unpack_trade_ready (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*���ｲ��*/	
function Protocols.pack_chat_unit_talk ( guid ,content ,say)
	local output = Packet.new(SMSG_CHAT_UNIT_TALK)
	output:writeU32(guid)
	output:writeU32(content)
	output:writeUTF(say)
	return output
end

-- /*���ｲ��*/	
function Protocols.call_chat_unit_talk ( playerInfo, guid ,content ,say)
	local output = Protocols.	pack_chat_unit_talk ( guid ,content ,say)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���ｲ��*/	
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


-- /*�ͽ�����*/	
function Protocols.pack_chat_near ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_NEAR)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*�ͽ�����*/	
function Protocols.call_chat_near ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_near ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͽ�����*/	
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


-- /*˽��*/	
function Protocols.pack_chat_whisper ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_WHISPER)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*˽��*/	
function Protocols.call_chat_whisper ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_whisper ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*˽��*/	
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


-- /*��Ӫ����*/	
function Protocols.pack_chat_faction ( guid ,name ,content ,faction)
	local output = Packet.new(MSG_CHAT_FACTION)
	output:writeUTF(guid)
	output:writeUTF(name)
	output:writeUTF(content)
	output:writeByte(faction)
	return output
end

-- /*��Ӫ����*/	
function Protocols.call_chat_faction ( playerInfo, guid ,name ,content ,faction)
	local output = Protocols.	pack_chat_faction ( guid ,name ,content ,faction)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��Ӫ����*/	
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


-- /*����*/	
function Protocols.pack_chat_world ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_WORLD)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*����*/	
function Protocols.call_chat_world ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_world ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����*/	
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


-- /*����*/	
function Protocols.pack_chat_horn ( guid ,faction ,name ,content)
	local output = Packet.new(MSG_CHAT_HORN)
	output:writeUTF(guid)
	output:writeByte(faction)
	output:writeUTF(name)
	output:writeUTF(content)
	return output
end

-- /*����*/	
function Protocols.call_chat_horn ( playerInfo, guid ,faction ,name ,content)
	local output = Protocols.	pack_chat_horn ( guid ,faction ,name ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����*/	
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


-- /*����*/	
function Protocols.pack_chat_notice ( id ,content ,data)
	local output = Packet.new(MSG_CHAT_NOTICE)
	output:writeU32(id)
	output:writeUTF(content)
	output:writeUTF(data)
	return output
end

-- /*����*/	
function Protocols.call_chat_notice ( playerInfo, id ,content ,data)
	local output = Protocols.	pack_chat_notice ( id ,content ,data)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����*/	
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


-- /*��ѯ�����Ϣ*/	
function Protocols.pack_query_player_info ( guid ,flag ,callback_id)
	local output = Packet.new(CMSG_QUERY_PLAYER_INFO)
	output:writeUTF(guid)
	output:writeU32(flag)
	output:writeU32(callback_id)
	return output
end

-- /*��ѯ�����Ϣ*/	
function Protocols.call_query_player_info ( playerInfo, guid ,flag ,callback_id)
	local output = Protocols.	pack_query_player_info ( guid ,flag ,callback_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ѯ�����Ϣ*/	
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


-- /*��ѯ��Ϣ�������*/	
function Protocols.pack_query_result_update_object (  )
	local output = Packet.new(SMSG_QUERY_RESULT_UPDATE_OBJECT)
	return output
end

-- /*��ѯ��Ϣ�������*/	
function Protocols.call_query_result_update_object ( playerInfo )
	local output = Protocols.	pack_query_result_update_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ѯ��Ϣ�������*/	
function Protocols.unpack_query_result_update_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��ȡ���*/	
function Protocols.pack_receive_gift_packs (  )
	local output = Packet.new(CMSG_RECEIVE_GIFT_PACKS)
	return output
end

-- /*��ȡ���*/	
function Protocols.call_receive_gift_packs ( playerInfo )
	local output = Protocols.	pack_receive_gift_packs (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ȡ���*/	
function Protocols.unpack_receive_gift_packs (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��ͼ�������*/	
function Protocols.pack_map_update_object (  )
	local output = Packet.new(SMSG_MAP_UPDATE_OBJECT)
	return output
end

-- /*��ͼ�������*/	
function Protocols.call_map_update_object ( playerInfo )
	local output = Protocols.	pack_map_update_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ͼ�������*/	
function Protocols.unpack_map_update_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*ս����Ϣbinlog*/	
function Protocols.pack_fighting_info_update_object (  )
	local output = Packet.new(SMSG_FIGHTING_INFO_UPDATE_OBJECT)
	return output
end

-- /*ս����Ϣbinlog*/	
function Protocols.call_fighting_info_update_object ( playerInfo )
	local output = Protocols.	pack_fighting_info_update_object (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ս����Ϣbinlog*/	
function Protocols.unpack_fighting_info_update_object (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*ս����Ϣbinlog*/	
function Protocols.pack_fighting_info_update_object_2 (  )
	local output = Packet.new(SMSG_FIGHTING_INFO_UPDATE_OBJECT_2)
	return output
end

-- /*ս����Ϣbinlog*/	
function Protocols.call_fighting_info_update_object_2 ( playerInfo )
	local output = Protocols.	pack_fighting_info_update_object_2 (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ս����Ϣbinlog*/	
function Protocols.unpack_fighting_info_update_object_2 (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*���븱��*/	
function Protocols.pack_instance_enter ( instance_id)
	local output = Packet.new(CMSG_INSTANCE_ENTER)
	output:writeU32(instance_id)
	return output
end

-- /*���븱��*/	
function Protocols.call_instance_enter ( playerInfo, instance_id)
	local output = Protocols.	pack_instance_enter ( instance_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���븱��*/	
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


-- /*�����˷��͸���������һ�׶�ָ��*/	
function Protocols.pack_instance_next_state ( level ,param)
	local output = Packet.new(CMSG_INSTANCE_NEXT_STATE)
	output:writeI16(level)
	output:writeU32(param)
	return output
end

-- /*�����˷��͸���������һ�׶�ָ��*/	
function Protocols.call_instance_next_state ( playerInfo, level ,param)
	local output = Protocols.	pack_instance_next_state ( level ,param)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�����˷��͸���������һ�׶�ָ��*/	
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


-- /*�����˳�*/	
function Protocols.pack_instance_exit ( reserve)
	local output = Packet.new(CMSG_INSTANCE_EXIT)
	output:writeU32(reserve)
	return output
end

-- /*�����˳�*/	
function Protocols.call_instance_exit ( playerInfo, reserve)
	local output = Protocols.	pack_instance_exit ( reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�����˳�*/	
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


-- /*��ʱ���ȡ*/	
function Protocols.pack_limit_activity_receive ( id ,type)
	local output = Packet.new(CMSG_LIMIT_ACTIVITY_RECEIVE)
	output:writeU32(id)
	output:writeU32(type)
	return output
end

-- /*��ʱ���ȡ*/	
function Protocols.call_limit_activity_receive ( playerInfo, id ,type)
	local output = Protocols.	pack_limit_activity_receive ( id ,type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ʱ���ȡ*/	
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


-- /*ɱ����~~��������*/	
function Protocols.pack_kill_man ( killer ,killer_name ,victim ,victim_name)
	local output = Packet.new(SMSG_KILL_MAN)
	output:writeUTF(killer)
	output:writeUTF(killer_name)
	output:writeUTF(victim)
	output:writeUTF(victim_name)
	return output
end

-- /*ɱ����~~��������*/	
function Protocols.call_kill_man ( playerInfo, killer ,killer_name ,victim ,victim_name)
	local output = Protocols.	pack_kill_man ( killer ,killer_name ,victim ,victim_name)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ɱ����~~��������*/	
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


-- /*�������*/	
function Protocols.pack_player_upgrade ( guid)
	local output = Packet.new(SMSG_PLAYER_UPGRADE)
	output:writeU32(guid)
	return output
end

-- /*�������*/	
function Protocols.call_player_upgrade ( playerInfo, guid)
	local output = Protocols.	pack_player_upgrade ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������*/	
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


-- /*�ֿ��Ǯ*/	
function Protocols.pack_warehouse_save_money ( money ,money_gold ,money_bills)
	local output = Packet.new(CMSG_WAREHOUSE_SAVE_MONEY)
	output:writeI32(money)
	output:writeI32(money_gold)
	output:writeI32(money_bills)
	return output
end

-- /*�ֿ��Ǯ*/	
function Protocols.call_warehouse_save_money ( playerInfo, money ,money_gold ,money_bills)
	local output = Protocols.	pack_warehouse_save_money ( money ,money_gold ,money_bills)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ֿ��Ǯ*/	
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


-- /*�ֿ�ȡǮ*/	
function Protocols.pack_warehouse_take_money ( money ,money_gold ,money_bills)
	local output = Packet.new(CMSG_WAREHOUSE_TAKE_MONEY)
	output:writeI32(money)
	output:writeI32(money_gold)
	output:writeI32(money_bills)
	return output
end

-- /*�ֿ�ȡǮ*/	
function Protocols.call_warehouse_take_money ( playerInfo, money ,money_gold ,money_bills)
	local output = Protocols.	pack_warehouse_take_money ( money ,money_gold ,money_bills)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ֿ�ȡǮ*/	
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


-- /*ʹ��Ԫ������ĳ��*/	
function Protocols.pack_use_gold_opt ( type ,param)
	local output = Packet.new(CMSG_USE_GOLD_OPT)
	output:writeByte(type)
	output:writeUTF(param)
	return output
end

-- /*ʹ��Ԫ������ĳ��*/	
function Protocols.call_use_gold_opt ( playerInfo, type ,param)
	local output = Protocols.	pack_use_gold_opt ( type ,param)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ʹ��Ԫ������ĳ��*/	
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


-- /*ʹ��ͭǮ����ĳ��*/	
function Protocols.pack_use_silver_opt ( type)
	local output = Packet.new(CMSG_USE_SILVER_OPT)
	output:writeByte(type)
	return output
end

-- /*ʹ��ͭǮ����ĳ��*/	
function Protocols.call_use_silver_opt ( playerInfo, type)
	local output = Protocols.	pack_use_silver_opt ( type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ʹ��ͭǮ����ĳ��*/	
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


-- /*��̨����*/	
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

-- /*��̨����*/	
function Protocols.call_gm_rightfloat ( playerInfo, id ,end_time ,zone1 ,zone2 ,zone3 ,subject ,content ,link ,mode)
	local output = Protocols.	pack_gm_rightfloat ( id ,end_time ,zone1 ,zone2 ,zone3 ,subject ,content ,link ,mode)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��̨����*/	
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


-- /*ɾ��ĳ����̨����*/	
function Protocols.pack_del_gm_rightfloat ( id)
	local output = Packet.new(SMSG_DEL_GM_RIGHTFLOAT)
	output:writeU32(id)
	return output
end

-- /*ɾ��ĳ����̨����*/	
function Protocols.call_del_gm_rightfloat ( playerInfo, id)
	local output = Protocols.	pack_del_gm_rightfloat ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ɾ��ĳ����̨����*/	
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


-- /*Ӧ�÷�ͬ��ʱ��*/	
function Protocols.pack_sync_mstime_app ( mstime_now ,time_now ,open_time)
	local output = Packet.new(MSG_SYNC_MSTIME_APP)
	output:writeU32(mstime_now)
	output:writeU32(time_now)
	output:writeU32(open_time)
	return output
end

-- /*Ӧ�÷�ͬ��ʱ��*/	
function Protocols.call_sync_mstime_app ( playerInfo, mstime_now ,time_now ,open_time)
	local output = Protocols.	pack_sync_mstime_app ( mstime_now ,time_now ,open_time)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*Ӧ�÷�ͬ��ʱ��*/	
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


-- /*��Ҵ�ĳ������*/	
function Protocols.pack_open_window ( window_type)
	local output = Packet.new(CMSG_OPEN_WINDOW)
	output:writeU32(window_type)
	return output
end

-- /*��Ҵ�ĳ������*/	
function Protocols.call_open_window ( playerInfo, window_type)
	local output = Protocols.	pack_open_window ( window_type)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��Ҵ�ĳ������*/	
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


-- /*���Բ���*/	
function Protocols.pack_player_gag ( player_id ,end_time ,content)
	local output = Packet.new(CMSG_PLAYER_GAG)
	output:writeUTF(player_id)
	output:writeU32(end_time)
	output:writeUTF(content)
	return output
end

-- /*���Բ���*/	
function Protocols.call_player_gag ( playerInfo, player_id ,end_time ,content)
	local output = Protocols.	pack_player_gag ( player_id ,end_time ,content)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���Բ���*/	
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


-- /*���˲���*/	
function Protocols.pack_player_kicking ( player_id)
	local output = Packet.new(CMSG_PLAYER_KICKING)
	output:writeUTF(player_id)
	return output
end

-- /*���˲���*/	
function Protocols.call_player_kicking ( playerInfo, player_id)
	local output = Protocols.	pack_player_kicking ( player_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*���˲���*/	
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


-- /*�Ϸ�֪ͨ*/	
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

-- /*�Ϸ�֪ͨ*/	
function Protocols.call_merge_server_msg ( playerInfo, merge_host ,merge_port ,merge_key ,merge_type ,reserve ,reserve2)
	local output = Protocols.	pack_merge_server_msg ( merge_host ,merge_port ,merge_key ,merge_type ,reserve ,reserve2)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�Ϸ�֪ͨ*/	
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


-- /*��ȡ������Ϣ*/	
function Protocols.pack_rank_list_query ( call_back_id ,rank_list_type ,start_index ,end_index)
	local output = Packet.new(CMSG_RANK_LIST_QUERY)
	output:writeU32(call_back_id)
	output:writeByte(rank_list_type)
	output:writeI16(start_index)
	output:writeI16(end_index)
	return output
end

-- /*��ȡ������Ϣ*/	
function Protocols.call_rank_list_query ( playerInfo, call_back_id ,rank_list_type ,start_index ,end_index)
	local output = Protocols.	pack_rank_list_query ( call_back_id ,rank_list_type ,start_index ,end_index)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ȡ������Ϣ*/	
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


-- /*�ͻ��˻�ȡ���а񷵻ؽ��*/	
function Protocols.pack_rank_list_query_result (  )
	local output = Packet.new(SMSG_RANK_LIST_QUERY_RESULT)
	return output
end

-- /*�ͻ��˻�ȡ���а񷵻ؽ��*/	
function Protocols.call_rank_list_query_result ( playerInfo )
	local output = Protocols.	pack_rank_list_query_result (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͻ��˻�ȡ���а񷵻ؽ��*/	
function Protocols.unpack_rank_list_query_result (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*�ͻ����ȸ�����ģ����ȡuint*/	
function Protocols.pack_client_update_scened (  )
	local output = Packet.new(CMSG_CLIENT_UPDATE_SCENED)
	return output
end

-- /*�ͻ����ȸ�����ģ����ȡuint*/	
function Protocols.call_client_update_scened ( playerInfo )
	local output = Protocols.	pack_client_update_scened (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͻ����ȸ�����ģ����ȡuint*/	
function Protocols.unpack_client_update_scened (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��ֵ��*/	
function Protocols.pack_num_lua (  )
	local output = Packet.new(SMSG_NUM_LUA)
	return output
end

-- /*��ֵ��*/	
function Protocols.call_num_lua ( playerInfo )
	local output = Protocols.	pack_num_lua (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ֵ��*/	
function Protocols.unpack_num_lua (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*ս��Ʒʰȡ*/	
function Protocols.pack_loot_select ( x ,y)
	local output = Packet.new(CMSG_LOOT_SELECT)
	output:writeI16(x)
	output:writeI16(y)
	return output
end

-- /*ս��Ʒʰȡ*/	
function Protocols.call_loot_select ( playerInfo, x ,y)
	local output = Protocols.	pack_loot_select ( x ,y)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ս��Ʒʰȡ*/	
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


-- /*֪ͨ��¼������Ҵ�����Ϸ��*/	
function Protocols.pack_goback_to_game_server (  )
	local output = Packet.new(CMSG_GOBACK_TO_GAME_SERVER)
	return output
end

-- /*֪ͨ��¼������Ҵ�����Ϸ��*/	
function Protocols.call_goback_to_game_server ( playerInfo )
	local output = Protocols.	pack_goback_to_game_server (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*֪ͨ��¼������Ҵ�����Ϸ��*/	
function Protocols.unpack_goback_to_game_server (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*�ͻ��˰ѱ�����Ա���ݴ���������*/	
function Protocols.pack_world_war_CS_player_info (  )
	local output = Packet.new(CMSG_WORLD_WAR_CS_PLAYER_INFO)
	return output
end

-- /*�ͻ��˰ѱ�����Ա���ݴ���������*/	
function Protocols.call_world_war_CS_player_info ( playerInfo )
	local output = Protocols.	pack_world_war_CS_player_info (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͻ��˰ѱ�����Ա���ݴ���������*/	
function Protocols.unpack_world_war_CS_player_info (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��Ҽ�������뿪ĳ������*/	
function Protocols.pack_join_or_leave_server ( join_or_leave ,server_type ,server_pid ,server_fd ,time)
	local output = Packet.new(SMSG_JOIN_OR_LEAVE_SERVER)
	output:writeByte(join_or_leave)
	output:writeByte(server_type)
	output:writeU32(server_pid)
	output:writeU32(server_fd)
	output:writeU32(time)
	return output
end

-- /*��Ҽ�������뿪ĳ������*/	
function Protocols.call_join_or_leave_server ( playerInfo, join_or_leave ,server_type ,server_pid ,server_fd ,time)
	local output = Protocols.	pack_join_or_leave_server ( join_or_leave ,server_type ,server_pid ,server_fd ,time)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��Ҽ�������뿪ĳ������*/	
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


-- /*�ͻ�����������Ա����*/	
function Protocols.pack_world_war_SC_player_info (  )
	local output = Packet.new(MSG_WORLD_WAR_SC_PLAYER_INFO)
	return output
end

-- /*�ͻ�����������Ա����*/	
function Protocols.call_world_war_SC_player_info ( playerInfo )
	local output = Protocols.	pack_world_war_SC_player_info (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͻ�����������Ա����*/	
function Protocols.unpack_world_war_SC_player_info (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*�ͻ��˶�����Ϣ*/	
function Protocols.pack_clientSubscription ( guid)
	local output = Packet.new(MSG_CLIENTSUBSCRIPTION)
	output:writeU32(guid)
	return output
end

-- /*�ͻ��˶�����Ϣ*/	
function Protocols.call_clientSubscription ( playerInfo, guid)
	local output = Protocols.	pack_clientSubscription ( guid)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͻ��˶�����Ϣ*/	
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


-- /*������·�lua�ű�*/	
function Protocols.pack_lua_script (  )
	local output = Packet.new(SMSG_LUA_SCRIPT)
	return output
end

-- /*������·�lua�ű�*/	
function Protocols.call_lua_script ( playerInfo )
	local output = Protocols.	pack_lua_script (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������·�lua�ű�*/	
function Protocols.unpack_lua_script (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��ɫ������Ϣ*/	
function Protocols.pack_char_update_info ( info)
	local output = Packet.new(CMSG_CHAR_UPDATE_INFO)
	info :write(output)
	return output
end

-- /*��ɫ������Ϣ*/	
function Protocols.call_char_update_info ( playerInfo, info)
	local output = Protocols.	pack_char_update_info ( info)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��ɫ������Ϣ*/	
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


-- /*֪ͨ�ͻ��˹۲��ߵ��ӽ�*/	
function Protocols.pack_notice_watcher_map_info ( wather_guid ,map_id ,instance_id)
	local output = Packet.new(SMSG_NOTICE_WATCHER_MAP_INFO)
	output:writeUTF(wather_guid)
	output:writeU32(map_id)
	output:writeU32(instance_id)
	return output
end

-- /*֪ͨ�ͻ��˹۲��ߵ��ӽ�*/	
function Protocols.call_notice_watcher_map_info ( playerInfo, wather_guid ,map_id ,instance_id)
	local output = Protocols.	pack_notice_watcher_map_info ( wather_guid ,map_id ,instance_id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*֪ͨ�ͻ��˹۲��ߵ��ӽ�*/	
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


-- /*�ͻ��˶��Ķ�����Ϣ*/	
function Protocols.pack_modify_watch ( opt ,cid ,key)
	local output = Packet.new(CMSG_MODIFY_WATCH)
	output:writeByte(opt)
	output:writeU32(cid)
	output:writeUTF(key)
	return output
end

-- /*�ͻ��˶��Ķ�����Ϣ*/	
function Protocols.call_modify_watch ( playerInfo, opt ,cid ,key)
	local output = Protocols.	pack_modify_watch ( opt ,cid ,key)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�ͻ��˶��Ķ�����Ϣ*/	
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


-- /*�������*/	
function Protocols.pack_kuafu_chuansong ( str_data ,watcher_guid ,reserve)
	local output = Packet.new(CMSG_KUAFU_CHUANSONG)
	output:writeUTF(str_data)
	output:writeUTF(watcher_guid)
	output:writeU32(reserve)
	return output
end

-- /*�������*/	
function Protocols.call_kuafu_chuansong ( playerInfo, str_data ,watcher_guid ,reserve)
	local output = Protocols.	pack_kuafu_chuansong ( str_data ,watcher_guid ,reserve)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������*/	
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


-- /*ǿ��*/	
function Protocols.pack_strength ( part)
	local output = Packet.new(CMSG_STRENGTH)
	output:writeByte(part)
	return output
end

-- /*ǿ��*/	
function Protocols.call_strength ( playerInfo, part)
	local output = Protocols.	pack_strength ( part)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ǿ��*/	
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


-- /*ǿ���ɹ�*/	
function Protocols.pack_strength_success ( level)
	local output = Packet.new(SMSG_STRENGTH_SUCCESS)
	output:writeI16(level)
	return output
end

-- /*ǿ���ɹ�*/	
function Protocols.call_strength_success ( playerInfo, level)
	local output = Protocols.	pack_strength_success ( level)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ǿ���ɹ�*/	
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


-- /*ǿ�ƽ���*/	
function Protocols.pack_forceInto (  )
	local output = Packet.new(CMSG_FORCEINTO)
	return output
end

-- /*ǿ�ƽ���*/	
function Protocols.call_forceInto ( playerInfo )
	local output = Protocols.	pack_forceInto (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*ǿ�ƽ���*/	
function Protocols.unpack_forceInto (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��������*/	
function Protocols.pack_create_faction ( name)
	local output = Packet.new(CMSG_CREATE_FACTION)
	output:writeUTF(name)
	return output
end

-- /*��������*/	
function Protocols.call_create_faction ( playerInfo, name)
	local output = Protocols.	pack_create_faction ( name)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������*/	
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


-- /*��������*/	
function Protocols.pack_faction_upgrade (  )
	local output = Packet.new(CMSG_FACTION_UPGRADE)
	return output
end

-- /*��������*/	
function Protocols.call_faction_upgrade ( playerInfo )
	local output = Protocols.	pack_faction_upgrade (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������*/	
function Protocols.unpack_faction_upgrade (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*����������*/	
function Protocols.pack_faction_join ( id)
	local output = Packet.new(CMSG_FACTION_JOIN)
	output:writeUTF(id)
	return output
end

-- /*����������*/	
function Protocols.call_faction_join ( playerInfo, id)
	local output = Protocols.	pack_faction_join ( id)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����������*/	
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


-- /*������������*/	
function Protocols.pack_raise_base_spell ( spellId)
	local output = Packet.new(CMSG_RAISE_BASE_SPELL)
	output:writeI16(spellId)
	return output
end

-- /*������������*/	
function Protocols.call_raise_base_spell ( playerInfo, spellId)
	local output = Protocols.	pack_raise_base_spell ( spellId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������������*/	
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


-- /*�������׷�ŭ����*/	
function Protocols.pack_upgrade_anger_spell ( spellId)
	local output = Packet.new(CMSG_UPGRADE_ANGER_SPELL)
	output:writeI16(spellId)
	return output
end

-- /*�������׷�ŭ����*/	
function Protocols.call_upgrade_anger_spell ( playerInfo, spellId)
	local output = Protocols.	pack_upgrade_anger_spell ( spellId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������׷�ŭ����*/	
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


-- /*������������*/	
function Protocols.pack_raise_mount (  )
	local output = Packet.new(CMSG_RAISE_MOUNT)
	return output
end

-- /*������������*/	
function Protocols.call_raise_mount ( playerInfo )
	local output = Protocols.	pack_raise_mount (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������������*/	
function Protocols.unpack_raise_mount (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*������������*/	
function Protocols.pack_upgrade_mount (  )
	local output = Packet.new(CMSG_UPGRADE_MOUNT)
	return output
end

-- /*������������*/	
function Protocols.call_upgrade_mount ( playerInfo )
	local output = Protocols.	pack_upgrade_mount (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*������������*/	
function Protocols.unpack_upgrade_mount (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*����һ����������*/	
function Protocols.pack_upgrade_mount_one_step (  )
	local output = Packet.new(CMSG_UPGRADE_MOUNT_ONE_STEP)
	return output
end

-- /*����һ����������*/	
function Protocols.call_upgrade_mount_one_step ( playerInfo )
	local output = Protocols.	pack_upgrade_mount_one_step (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����һ����������*/	
function Protocols.unpack_upgrade_mount_one_step (pkt)
	local input = Packet.new(nil, pkt)
	local param_table = {}
	local ret

	return true,{}
	

end


-- /*��������û�����*/	
function Protocols.pack_illusion_mount_active ( illuId)
	local output = Packet.new(CMSG_ILLUSION_MOUNT_ACTIVE)
	output:writeI16(illuId)
	return output
end

-- /*��������û�����*/	
function Protocols.call_illusion_mount_active ( playerInfo, illuId)
	local output = Protocols.	pack_illusion_mount_active ( illuId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*��������û�����*/	
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


-- /*����û�����*/	
function Protocols.pack_illusion_mount ( illuId)
	local output = Packet.new(CMSG_ILLUSION_MOUNT)
	output:writeI16(illuId)
	return output
end

-- /*����û�����*/	
function Protocols.call_illusion_mount ( playerInfo, illuId)
	local output = Protocols.	pack_illusion_mount ( illuId)
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*����û�����*/	
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


-- /*�������*/	
function Protocols.pack_ride_mount (  )
	local output = Packet.new(CMSG_RIDE_MOUNT)
	return output
end

-- /*�������*/	
function Protocols.call_ride_mount ( playerInfo )
	local output = Protocols.	pack_ride_mount (  )
	playerInfo:SendPacket(output)
	output:delete()
end

-- /*�������*/	
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