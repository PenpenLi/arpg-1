InstanceKuafuXianfu = class("InstanceKuafuXianfu", InstanceInstBase)

InstanceKuafuXianfu.Name = "InstanceKuafuXianfu"
InstanceKuafuXianfu.exit_time = 20
InstanceKuafuXianfu.Time_Out_Fail_Callback = "timeoutCallback"
InstanceKuafuXianfu.broadcast_nogrid = 1

function InstanceKuafuXianfu:ctor(  )
	
end

--��ʼ���ű�����
function InstanceKuafuXianfu:OnInitScript()
	InstanceInstBase.OnInitScript(self) --���û���
	
	self:OnTaskStart()
	self:AddCountDown()
	
	-- bossˢ�¶�ʱ��
	mapLib.AddTimer(self.ptr, 'OnMonsterRefresh', 1000)
end

function InstanceKuafuXianfu:AddCountDown()
	local timestamp = os.time() + tb_kuafu_xianfu_base[ 1 ].cd
	self:SetMapStartTime(timestamp)
	self:AddTimeOutCallback("countdown", timestamp)
end

-- ����ʱ����
function InstanceKuafuXianfu:countdown()
	-- ����ˢ�¶�ʱ��
	mapLib.AddTimer(self.ptr, 'OnBuffRefresh', tb_kuafu_xianfu_base[ 1 ].interval * 1000)
end

-- ���ʽ��ʼ
function InstanceKuafuXianfu:OnTaskStart()
	local timestamp = os.time() +  tb_kuafu_xianfu_base[ 1 ].last + tb_kuafu_xianfu_base[ 1 ].cd
	-- ������ʱ��
	self:SetMapQuestEndTime(timestamp)
	-- ����ʱ�䳬ʱ�ص�
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- ˢ��boss
function InstanceKuafuXianfu:OnMonsterRefresh()
	if self:GetMapState() == self.STATE_FINISH then
		return false
	end
	
	local timestamp = os.time()
	for indx, bossInfo in pairs(tb_kuafu_xianfu_boss) do
		local info = bossInfo.bossTime
		local createBossTime = info[ 1 ] * 60 + info[ 2 ]
		if self:GetMapCreateTime() + createBossTime == timestamp then
			local pos = bossInfo.bossPos
			local entry = bossInfo.bossEntry
			local bossName = tb_creature_template[entry].name
			local creature = mapLib.AddCreature(self.ptr, {
					templateid = entry, x = pos[ 1 ], y = pos[ 2 ], 
					active_grid = true, alias_name = bossName, ainame = "AI_XianfuBoss", npcflag = {}
				}
			)
			local place = string.char(64+indx)
			local boxid = tb_kuafu_xianfu_base[ 1 ].boxid
			app:CallOptResult(self.ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_OCCUR, {bossName, place, tb_item_template[boxid].name})
			self:SetUInt32(KUAFU_XIANFU_FIELDS_INT_BOSS_INDX, indx)
			break
		end
	end
	
	return true
end

-- ˢ��buff
function InstanceKuafuXianfu:OnBuffRefresh()
	-- ����ˢ�´���
	local times = self:GetMapReserveValue1()
	if times < tb_kuafu_xianfu_base[ 1 ].times then
		self:SetMapReserveValue1(times+1)
	end
	
	-- ˢ�°�ԭ������ɾ��
	local allGameObjects = mapLib.GetAllGameObject(self.ptr)
	for _, gameobject in pairs(allGameObjects) do
		mapLib.RemoveWorldObject(self.ptr, gameobject)
	end
	
	-- ˢ���µ�
	local indice = GetRandomIndexTable(#tb_buff_xianfu, #tb_kuafu_xianfu_base[ 1 ].buffPos)
	for i = 1, #indice do
		local pos = tb_kuafu_xianfu_base[ 1 ].buffPos[ i ]
		local indx = indice[ i ]
		local entry = tb_buff_xianfu[indx].gameobject_id
		mapLib.AddGameObject(self.ptr, entry, pos[ 1 ], pos[ 2 ], GO_GEAR_STATUS_END)
	end
	
	return self:GetMapReserveValue1() < tb_kuafu_xianfu_base[ 1 ].times
end

-- ����ʧ���˳�
function InstanceKuafuXianfu:timeoutCallback()
	self:SyncResultToWeb()
	self:SetMapState(self.STATE_FINISH)
	return false
end

--������״̬�����仯ʱ�䴥��
function InstanceKuafuXianfu:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s���������
		local timestamp = os.time() + InstanceKuafuXianfu.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- �ж��Ƿ����˳�����
function InstanceKuafuXianfu:DoPlayerExitInstance(player)
	return 1	--����1�Ļ�Ϊ�����˳�������0�����˳�
end




--[[

// �ɸ��ᱦ �����Ϣ
enum KUAFU_XIANFU_PLAYER_INFO
{
	KUAFU_XIANFU_PLAYER_SHOW_INFO	= 0,									// 4��byte(byte0:��������, byte1:��ɱ����, byte2:��ɱBOSS����)
	KUAFU_XIANFU_PLAYER_SETTLEMENT	= KUAFU_XIANFU_PLAYER_SHOW_INFO + 1,	// ���ս��
	MAX_KUAFU_XIANFU_INT_COUNT,												// kuafu��������

	KUAFU_XIANFU_PLAYER_NAME		= 0,									//�������
	KUAFU_XIANFU_PLAYER_GUID		= KUAFU_XIANFU_PLAYER_NAME + 1,			//���guid
	MAX_KUAFU_XIANFU_STR_COUNT,
};

#define MAX_KUAFU_XIANFU_COUNT 10
// ����ɸ��ᱦƥ��
enum KUAFU_XIANFU_FIELDS 
{
	KUAFU_XIANFU_FIELDS_INT_INFO_START	= MAP_INT_FIELD_INSTANCE_TYPE + 1,														// ������ݿ�ʼ
	KUAFU_XIANFU_FIELDS_INT_INFO_END	= KUAFU_XIANFU_FIELDS_INT_INFO_START + MAX_KUAFU_XIANFU_COUNT * MAX_KUAFU_XIANFU_INT_COUNT,		// 3v3�ܹ�6����

	KUAFU_XIANFU_FIELDS_STR_INFO_START	= MAP_STR_REWARD + 1,																// �ַ������ݿ�ʼ
	KUAFU_XIANFU_FIELDS_STR_INFO_END	= KUAFU_XIANFU_FIELDS_STR_INFO_START + MAX_KUAFU_XIANFU_COUNT * MAX_KUAFU_XIANFU_STR_COUNT,	// �ַ������ݽ���
};

--]]

--��Ҽ����ͼ
function InstanceKuafuXianfu:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--�����˻�������ֱ�ӵ���ȥ
		local login_fd = serverConnList:getLogindFD()
		call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
		return
	end
	
	-- �����ظ�����
	if self:findIndexByName(playerInfo:GetName()) > -1 then
		local login_fd = serverConnList:getLogindFD()
		call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
		return
	end
	
	-- ��������
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	if emptyIndex > -1 then
		local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_INT_COUNT
		local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_STR_COUNT

		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_NAME, playerInfo:GetName())
		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_GUID, playerInfo:GetPlayerGuid())

		self:SetUInt32(intstart + KUAFU_XIANFU_PLAYER_SETTLEMENT,playerInfo:GetForce())
	end
end

-- ������ֶ�Ӧ��λ��, ''��ʾ������ѯ��λλ��
function InstanceKuafuXianfu:findIndexByName(name)
	name = name or ''
	local start = KUAFU_XIANFU_FIELDS_STR_INFO_START
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do
		if self:GetStr(start+KUAFU_XIANFU_PLAYER_NAME) == name then
			return i
		end
		start = start + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	return -1
end

--����Ҽ���󴥷�
function InstanceKuafuXianfu:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

function InstanceKuafuXianfu:DoIsFriendly(killer_ptr, target_ptr)
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	local targetInfo = UnitInfo:new{ptr = target_ptr}
	
	-- ֻ�й��ﲻ�ܹ�������
	local ret =  targetInfo:GetTypeID() == TYPEID_UNIT and killerInfo:GetTypeID() == TYPEID_UNIT
	if ret then
		return 1
	end
	return 0
end

--����������󴥷�()
function InstanceKuafuXianfu:OnPlayerDeath(player)
	-- ���״̬�Ѿ��ı�, ��ʹ����Ҳ���ٸ���ʱ��
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	
end

-- ͬ�����ݵ�������
function InstanceKuafuXianfu:SyncResultToWeb()
	local sendInfo = {}

	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START
	local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do

		
		intstart = intstart + MAX_KUAFU_XIANFU_INT_COUNT
		strstart = strstart + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	local retInfo = {}
	-- Ȼ��ͬ����web
	for _, info in pairs(sendInfo) do
		table.insert(retInfo, string.join(",", info))
	end
	
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/match_result"
	local data = {}
	-- ������3v3����ƥ�����Ϣ
	data.ret = string.join(";", retInfo)
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("response = %s", tostring(response))
	end)
end

-- �����
function InstanceKuafuXianfu:DoAfterRespawn(unit_ptr)
	local unitInfo = UnitInfo:new{ptr = unit_ptr}
	-- ���޵�buff
	unitLib.AddBuff(unit_ptr, BUFF_INVINCIBLE, unit_ptr, 1, 10)
	-- unitLib.AddBuff(unit_ptr, BUFF_INVISIBLE, unit_ptr, 1, MAX_BUFF_DURATION)
end

--[[
-- ����ܵ�ʵ���˺�(������ʾ��Ѫ)
function InstanceKuafuXianfu:OnPlayerHurt(killer, player, damage)
	local killerInfo = UnitInfo:new{ptr = killer}
	local targetInfo = UnitInfo:new{ptr = player}
	
	-- �������Ѫ��
	local indx = self:findIndexByName(targetInfo:GetName())
	local rate = math.floor((targetInfo:GetHealth() - damage) * 100 / targetInfo:GetMaxhealth())
	local intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
	self:SetByte(intStart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 1, rate)
	-- ��������˺�
	if damage > 0 then
		indx = self:findIndexByName(killerInfo:GetName())
		intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
		self:AddDouble(intStart + KUAFU_XIANFU_PLAYER_DAMAGE, damage)
	end
	
	return 0
end
--]]

function InstanceKuafuXianfu:OnPlayerKilled(player, killer)
	local killerInfo = UnitInfo:new{ptr = killer}
	local playerInfo = UnitInfo:new{ptr = player}
	
	-- ��ɱ�߼ӻ�ɱ��
	local indx1 = self:findIndexByName(killerInfo:GetName())
	local intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx1 * MAX_KUAFU_XIANFU_INT_COUNT
	self:AddByte(intStart + KUAFU_XIANFU_PLAYER_SETTLEMENT, 0, 1)
	
	-- ��ɱ���±�
	local indx2 = self:findIndexByName(playerInfo:GetName())
	
	-- ֪ͨ�����˻�ɱ��Ϣ
	local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do
		local player_guid = self:GetStr(strstart + KUAFU_XIANFU_PLAYER_GUID)
		local player = mapLib.GetPlayerByPlayerGuid(self.ptr, player_guid)
		if player then
			local playerInfo = UnitInfo:new {ptr = player}
			playerInfo:call_kuafu_3v3_kill_detail(indx1, indx2)
		end
		
		strstart = strstart + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	self:OnDropTreasure(playerInfo, killerInfo:GetPlayerGuid())
	
	return 0
end


function InstanceKuafuXianfu:OnDropTreasure(playerInfo, belongGuid, is_offline)
	belongGuid = belongGuid or ''
	is_offline = is_offline or false
	local indx = self:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
end

--������뿪ʱ����
function InstanceKuafuXianfu:OnLeavePlayer( player, is_offline)
	-- ����������˾Ͳ����д���
	if self:GetMapState() == self.STATE_FINISH then
		return
	end
	
	self:OnDropTreasure(UnitInfo:new{ptr = player})
end

--ʹ����Ϸ����֮ǰ
--����1�Ļ��ͼ���ʹ����Ϸ���󣬷���0�Ļ��Ͳ�ʹ��
function InstanceKuafuXianfu:OnBeforeUseGameObject(user, go, go_entryid, posX, posY)
	-- ����Ѿ����� �Ͳ��ܼ���
	if unitLib.HasBuff(user, BUFF_INVINCIBLE) then
		return 0
	end
	
	if Script_Gameobject_Pick_Check(user, go_entryid, posX, posY) then
		return 1
	end
	return 0
end

--ʹ����Ϸ����
--����1�Ļ��ɹ�ʹ����Ϸ���󣬷���0�Ļ�ʹ�ò��ɹ�
function InstanceKuafuXianfu:OnUseGameObject(user, go, go_entryid, posX, posY)
	-- �ж϶�Ӧ��������buff
	for _, obj in ipairs(tb_buff_xianfu) do
		if obj.gameobject_id == go_entryid then
			local effects = obj.type_effect
			for _, effect in pairs(effects) do
				local buffId = effect[ 1 ]
				local lv = effect[ 2 ]
				local duration = tb_buff_template[buffId].duration
				SpelladdBuff(user, buffId, user, lv, duration)
			end
			break
		end
	end
	
	-- ��Ҫɾ������
	mapLib.RemoveWorldObject(self.ptr, go)
	
	return 1	
end

-- ��õ��˵ĸ���ʱ��
function InstanceKuafuXianfu:GetSingleRespawnTime(player)
	return tb_kuafu_xianfu_base[ 1 ].seconds[ 1 ]
end

-- ��ͼ��Ҫ�����ʱҪ������
function InstanceKuafuXianfu:IsNeedTeleportWhileMapClear(player)
	local playerInfo = UnitInfo:new {ptr = player}
	local login_fd = serverConnList:getLogindFD()
	call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
	return 0
end





-------------------------�ɸ��ᱦboss---------------------------
AI_XianfuBoss = class("AI_XianfuBoss", AI_Base)
AI_XianfuBoss.ainame = "AI_XianfuBoss"

--����
function AI_XianfuBoss:JustDied( map_ptr,owner,killer_ptr )
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	local bossInfo = UnitInfo:new{ptr = owner}
	local playerInfo = UnitInfo:new{ptr = killer_ptr}
	
	local instanceInfo = InstanceKuafuXianfu:new{ptr = map_ptr}
	
	-- ��ʾ��ɱ����
	local indx = instanceInfo:GetUInt32(KUAFU_XIANFU_FIELDS_INT_BOSS_INDX)
	local boxes = tb_kuafu_xianfu_boss[indx].bossDrop[ 1 ]
	app:CallOptResult(map_ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_KILL, {bossInfo:GetName(), playerInfo:GetName(), boxes})
	
	
	--[[

	
	local instanceInfo = InstanceFieldBase:new{ptr = map_ptr}
	local mapid  = instanceInfo:GetMapId()
	local lineNo = instanceInfo:GetMapLineNo()
	local entry = bossInfo:GetEntry()
	
	globalValue:FieldBossDamageDeal(mapid, lineNo, 0)
	-- ����˺���ߵ�guid
	local guid = mapLib.GetMaxinumFieldBossDamage(map_ptr)
	-- ���BOSS�˺�
	mapLib.ClearFieldBossDamage(map_ptr)
	-- BOSS����
	globalValue:FieldBossKilled(mapid, lineNo, guid, playerInfo:GetName())
	local playerName = ToShowName(playerInfo:GetName())
	app:CallOptResult(instanceInfo.ptr, OPERTE_TYPE_FIELD_BOSS, FIELD_BOSS_OPERTE_BOSS_KILL, {tb_creature_template[entry].name, playerName, tb_gameobject_template[InstanceFieldBase.Treasure_Entry].name})
	
	-- �ӱ���
	local posx, posy = unitLib.GetPos(owner)
	instanceInfo:AddTreasure(posx, posy, 500)
	]]
	
	return 0
end

--����ս��Ʒ
function AI_XianfuBoss:LootAllot(owner, player, killer, drop_rate_multiples, boss_type, fcm)
	local playerInfo = UnitInfo:new{ptr = player}
	local player_guid = playerInfo:GetPlayerGuid()

	print("################ AI_XianfuBoss:LootAllot")
	local map_ptr = unitLib.GetMap(owner)
	local instanceInfo = InstanceKuafuXianfu:new{ptr = map_ptr}
	
	-- ���ɽ���
	local indx = instanceInfo:GetUInt32(KUAFU_XIANFU_FIELDS_INT_BOSS_INDX)
	local dropConfig = tb_kuafu_xianfu_boss[indx].bossDrop
	local boxes			= dropConfig[ 1 ]
	local protectTime	= dropConfig[ 2 ]
	local loot_entry 	= tb_kuafu_xianfu_base[ 1 ].boxid
	
	for i = 1, boxes do
		--ģ��,����,�����,����ʱ��,����ʱ��,ǿ���ȼ�
		--local drop_item_config = {entry, 1, 0, config.loot_exist_timer, protectTime, 0}		
		local count = 1
		AddLootGameObject(map_ptr, owner, player_guid, loot_entry, 0, fcm, config.loot_exist_timer, protectTime, 0)
	end
			
end


return InstanceKuafuXianfu