local security = require("base/Security")

InstanceKuafuGroup = class("InstanceKuafuGroup", InstanceInstBase)

InstanceKuafuGroup.Name = "InstanceKuafuGroup"
InstanceKuafuGroup.exit_time = 20
InstanceKuafuGroup.Time_Out_Fail_Callback = "timeoutCallback"
--InstanceKuafuGroup.broadcast_nogrid = 1
InstanceKuafuGroup.sub = "group_instance"

function InstanceKuafuGroup:ctor(  )
	
end

--��ʼ���ű�����
function InstanceKuafuGroup:OnInitScript()
	InstanceInstBase.OnInitScript(self) --���û���
	
	-- self:OnTaskStart()
	-- self:AddCountDown()
	
	-- bossˢ�¶�ʱ��
	-- mapLib.DelTimer(self.ptr, 'OnMonsterRefresh')
	-- mapLib.AddTimer(self.ptr, 'OnMonsterRefresh', 1000)
	
	-- self:OnInitBossInfo()
	
	-- ����generalid
	self:parseGeneralId()
end

function InstanceKuafuGroup:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local params = string.split(generalId, '|')
	local hard = tonumber(params[ 2 ])
	self:SetHard(hard)
end

function InstanceKuafuGroup:SetHard(hard)
	self:SetUInt32(KUAFU_XIANFU_FIELDS_HARD, hard)
end

function InstanceKuafuGroup:GetHard()
	return self:GetUInt32(KUAFU_XIANFU_FIELDS_HARD)
end

-- ��ʼ��boss����
function InstanceKuafuGroup:OnInitBossInfo ()
	local timestamp = os.time()	
	local intstart = KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START
	for indx, bossInfo in ipairs(tb_kuafu_xianfu_boss) do
		local info = bossInfo.bossTime
		local createBossTime = info[ 1 ] * 60 + info[ 2 ]
		local bornTime = self:GetMapCreateTime() + createBossTime
		local entry = bossInfo.bossEntry
		
		self:SetUInt16(intstart + KUAFU_XIANFU_BOSS_SHOW_INFO, 0, entry)
		self:SetUInt32(intstart + KUAFU_XIANFU_BOSS_BORN_TIME, bornTime)
		
		intstart = intstart + MAX_KUAFU_XIANFU_BOSS_INT_COUNT
	end
end

-- 
function InstanceKuafuGroup:GetBinlogIndxByEntry (entry)
	
	local intstart = KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START
	for i = 1, MAX_KUAFU_XIANFU_BOSS_COUNT do
		if entry == self:GetUInt16(intstart + KUAFU_XIANFU_BOSS_SHOW_INFO, 0) then
			return i
		end
		intstart = intstart + MAX_KUAFU_XIANFU_BOSS_INT_COUNT
	end
	
	return 0
end

-- ��ʾС��ͼ��Ϣ
function InstanceKuafuGroup:SendMiniMapInfo()
	
	local playerPos = {}
	local allPlayers = mapLib.GetAllPlayer(self.ptr)
	for _, player in pairs(allPlayers) do
		local x, y = unitLib.GetPos(player)
		local guid = binLogLib.GetStr(player, BINLOG_STRING_FIELD_GUID)
		table.insert(playerPos, {guid, x, y})
	end
	
	local creaturePos = {}
	local allCreatures = mapLib.GetAllCreature(self.ptr)
	for _, creature in pairs(allCreatures) do
		local x, y = unitLib.GetPos(creature)
		local entry = binLogLib.GetUInt16(creature, UNIT_FIELD_UINT16_0, 0)
		table.insert(creaturePos, {entry, x, y})
	end
	
	local gameObjectPos = {}
	local allGameobjects = mapLib.GetAllGameObject(self.ptr)
	for _, gameObject in pairs(allGameobjects) do
		local x, y = unitLib.GetPos(gameObject)
		local entry = binLogLib.GetUInt16(gameObject, UNIT_FIELD_UINT16_0, 0)
		table.insert(gameObjectPos, {entry, x, y})
	end
	
	for _, player in pairs(allPlayers) do
		local playerInfo = UnitInfo:new {ptr = player}
		playerInfo:call_kuafu_xianfu_minimap_info_in_custom(playerPos, creaturePos, gameObjectPos)
	end
end

function InstanceKuafuGroup:AddCountDown()
	local timestamp = os.time() + tb_kuafu_xianfu_base[ 1 ].cd
	self:SetMapStartTime(timestamp)
	self:AddTimeOutCallback("countdown", timestamp)
end

-- ����ʱ����
function InstanceKuafuGroup:countdown()
	-- ����ˢ�¶�ʱ��
	-- mapLib.AddTimer(self.ptr, 'OnBuffRefresh', tb_kuafu_xianfu_base[ 1 ].interval * 1000)
end

-- ���ʽ��ʼ
function InstanceKuafuGroup:OnTaskStart()
	local timestamp = os.time() +  tb_kuafu_xianfu_base[ 1 ].last + tb_kuafu_xianfu_base[ 1 ].cd
	-- ������ʱ��
	self:SetMapQuestEndTime(timestamp)
	-- ����ʱ�䳬ʱ�ص�
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- ˢ��boss
function InstanceKuafuGroup:OnMonsterRefresh()
	if self:GetMapState() == self.STATE_FINISH then
		return false
	end
	
	local timestamp = os.time()
	for indx, bossInfo in pairs(tb_kuafu_xianfu_boss) do
		local info = bossInfo.bossTime
		local createBossTime = info[ 1 ] * 60 + info[ 2 ]
		
		if self:GetMapCreateTime() + createBossTime <= timestamp then
			local bossintstart = KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START + MAX_KUAFU_XIANFU_BOSS_INT_COUNT * (indx - 1)
			local activeInfo = self:GetUInt32(bossintstart + KUAFU_XIANFU_BOSS_BORN_INFO)
			if activeInfo == 0 then
				self:SetUInt32(bossintstart + KUAFU_XIANFU_BOSS_BORN_INFO, 1)
				outFmtDebug("created indx = %d",  indx)
				local pos = bossInfo.bossPos
				local entry = bossInfo.bossEntry
				local bossName = tb_creature_template[entry].name
				local creature = mapLib.AddCreature(self.ptr, {
						templateid = entry, x = pos[ 1 ], y = pos[ 2 ], 
						active_grid = true, alias_name = bossName, ainame = "AI_GroupBoss", npcflag = {}
					}
				)
				-- ��ʶΪboss��
				local creatureInfo = UnitInfo:new{ptr = creature}
				creatureInfo:SetUnitFlags(UNIT_FIELD_FLAGS_IS_BOSS_CREATURE)
				
				local place = string.char(64+indx)
				
				self:SetUInt16(bossintstart + KUAFU_XIANFU_BOSS_SHOW_INFO, 1, 1)
				local boxid = self:GetBoxid()
				app:CallOptResult(self.ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_OCCUR, {bossName, place, tb_item_template[boxid].name})
			end
		end
	end
	
	-- ˢ��
	self:SendMiniMapInfo()
	
	return true
end

-- ˢ��buff
function InstanceKuafuGroup:OnBuffRefresh()
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
function InstanceKuafuGroup:timeoutCallback()
	self:SyncResultToWeb()
	self:SetMapState(self.STATE_FINISH)
	return false
end

--������״̬�����仯ʱ�䴥��
function InstanceKuafuGroup:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s���������
		local timestamp = os.time() + InstanceKuafuGroup.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- �ж��Ƿ����˳�����
function InstanceKuafuGroup:DoPlayerExitInstance(player)
	return 1	--����1�Ļ�Ϊ�����˳�������0�����˳�
end

--��Ҽ����ͼ
function InstanceKuafuGroup:OnJoinPlayer(player)
	
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
	local emptyIndex = self:findIndexByName()
	if emptyIndex > -1 then
		local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_INT_COUNT
		local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_STR_COUNT

		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_NAME, playerInfo:GetName())
		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_GUID, playerInfo:GetPlayerGuid())

		self:SetDouble(intstart + KUAFU_XIANFU_PLAYER_SETTLEMENT,playerInfo:GetForce())
	end
end

-- ������ֶ�Ӧ��λ��, ''��ʾ������ѯ��λλ��
function InstanceKuafuGroup:findIndexByName(name)
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
function InstanceKuafuGroup:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

--����������󴥷�()
function InstanceKuafuGroup:OnPlayerDeath(player)
	-- ���״̬�Ѿ��ı�, ��ʹ����Ҳ���ٸ���ʱ��
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	
end


--[[

// �ɸ��ᱦ �����Ϣ
enum KUAFU_XIANFU_PLAYER_INFO
{
	KUAFU_XIANFU_PLAYER_SHOW_INFO		= 0,										// 4��byte(byte0:��������, byte1:��ɱ����, byte2:��ɱBOSS����)
	KUAFU_XIANFU_PLAYER_MONEY			= KUAFU_XIANFU_PLAYER_SHOW_INFO + 1,		// Ԫ������
	KUAFU_XIANFU_PLAYER_MONEY_CHANGED	= KUAFU_XIANFU_PLAYER_MONEY + 2,			// Ԫ���ı�ֵ
	KUAFU_XIANFU_PLAYER_SETTLEMENT		= KUAFU_XIANFU_PLAYER_MONEY_CHANGED + 2,	// ���ս��
	MAX_KUAFU_XIANFU_INT_COUNT,														// kuafu��������

	KUAFU_XIANFU_PLAYER_NAME		= 0,									//�������
	KUAFU_XIANFU_PLAYER_GUID		= KUAFU_XIANFU_PLAYER_NAME + 1,			//���guid
	MAX_KUAFU_XIANFU_STR_COUNT,
};


--]]

-- ͬ�����ݵ�������
function InstanceKuafuGroup:SyncResultToWeb()
	local sendInfo = {}

	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START
	local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START
	local loot_entry = self:GetBoxid()
	
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do
		local player_guid = self:GetStr(strstart + KUAFU_XIANFU_PLAYER_GUID)
		if string.len(player_guid) > 0 then
			local reward = {}
			local hard = self:GetHard()
			for _, info in pairs(tb_kuafu_xianfu_condition[hard].joinReward) do
				table.insert(reward, info[ 1 ]..","..info[ 2 ])
			end
			local count   = self:GetByte  (intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 0)
			if count > 0 then
				table.insert(reward, loot_entry..","..count)
				outFmtDebug(" player %s has %d", player_guid, count)
			end
			table.insert(sendInfo, {player_guid, string.join(",", reward)})
		end
		
		intstart = intstart + MAX_KUAFU_XIANFU_INT_COUNT
		strstart = strstart + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	local retInfo = {}
	-- Ȼ��ͬ����web
	for _, info in pairs(sendInfo) do
		table.insert(retInfo, string.join("|", info))
	end
	
	local url = string.format("%s%s/match_result", globalGameConfig:GetExtWebInterface(), InstanceKuafuGroup.sub)
	local data = {}
	data.ret = string.join(";", retInfo)
	data.open_time = 1
	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@result = ", data.ret)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("response = %s", tostring(response))
	end)
end

-- �����
function InstanceKuafuGroup:DoAfterRespawn(unit_ptr)
	local unitInfo = UnitInfo:new{ptr = unit_ptr}
	-- ���޵�buff
	unitLib.AddBuff(unit_ptr, BUFF_INVINCIBLE, unit_ptr, 1, 3)
	
	local unitInfo = UnitInfo:new {ptr = unit_ptr}
	if unitInfo:GetTypeID() == TYPEID_PLAYER then
		-- ������� �˳����
		if unitInfo:GetUseRespawnMapId() > 0 then
			if unitInfo:GetUseRespawnMapId() ~= self:GetMapId() then
				self:IsNeedTeleportWhileMapClear(unit_ptr)
			end
		else
			-- �����������
			local a = GetRandomIndexTable(#tb_kuafu_xianfu_base[ 1 ].respawnPos, 1)
			local pos = tb_kuafu_xianfu_base[ 1 ].respawnPos[a[ 1 ]]
			local offsetX = randInt(-1, 1)
			local offsetY = randInt(-1, 1)
			
			local toMapId = self:GetMapId()
			local toX = pos[ 1 ] + offsetX
			local toY = pos[ 2 ] + offsetY
			local lineNo = self:GetMapLineNo()
			local generalId	= self:GetMapGeneralId()
			playerLib.Teleport(unit_ptr, toMapId, toX, toY, lineNo, generalId)
		end
		unitInfo:SetUseRespawnMapId(0)
	end
end

function InstanceKuafuGroup:OnPlayerKilled(player, killer)
	local killerInfo = UnitInfo:new{ptr = killer}
	local playerInfo = UnitInfo:new{ptr = player}
	
	-- ��ɱ�߼ӻ�ɱ��
	local indx1 = self:findIndexByName(killerInfo:GetName())
	local intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx1 * MAX_KUAFU_XIANFU_INT_COUNT
	self:AddKillCount(intStart)
	
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
	
	-- ������������
	self:AddPlayerKilledCount(playerInfo)
	
	-- �������� ��������еĻ�
	self:OnDropTreasure(playerInfo, killerInfo)
	
	return 0
end

-- ����ұ�����ɱ��
function InstanceKuafuGroup:OnPlayerKilledByMonster(player, killer)
	local killerInfo = UnitInfo:new{ptr = killer}
	local playerInfo = UnitInfo:new{ptr = player}
	
	-- ������������
	self:AddPlayerKilledCount(playerInfo)
	
	-- �������� ��������еĻ�
	self:OnDropTreasure(playerInfo, killerInfo)
	
	return 0
end

function InstanceKuafuGroup:OnSendDeathInfo(playerInfo, deathname ,killername ,params)
	-- ����Ұ�������سǵ���ʱ
	playerInfo:call_field_death_cooldown(DEAD_PLACE_TYPE_XIANFU, deathname, killername, params, tb_kuafu_xianfu_base[ 1 ].seconds)
end


function InstanceKuafuGroup:OnDropTreasure(playerInfo, killerInfo, is_offline)
	local belongGuid = ''
	if killerInfo and killerInfo:GetTypeID() == TYPEID_PLAYER then
		belongGuid = playerInfo:GetPlayerGuid()
	end
	is_offline = is_offline or false
	local indx = self:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
	
	local protectTime = 5
	local has = self:GetByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 0)
	local count = has
	if not is_offline then
		-- �ж���������� �������
		for k, v in pairs(tb_kuafu_xianfu_killed_drop) do
			if v.ownRange[ 1 ] <= has and has <= v.ownRange[ 2 ] then
				local rand = randInt(1, 10000)
				if rand <= v.rate then
					count = math.min(v.drop, has)
					protectTime = v.protect
				end
				break
			end
		end
		
		self:OnSendDeathInfo(playerInfo, playerInfo:GetName() ,killerInfo:GetName(), string.format("%d", count))			
		if count > 0 then				
			app:CallOptResult(self.ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_KILL, {playerInfo:GetName(), killerInfo:GetName(), count})
		end
	end
	
	if count > 0 then
		local loot_entry = self:GetBoxid()
		for i = 1, count do
			--ģ��,����,�����,����ʱ��,����ʱ��,ǿ���ȼ�
			--local drop_item_config = {entry, 1, 0, 1800, protectTime, 0}		
			AddLootGameObject(self.ptr, playerInfo.ptr, belongGuid, loot_entry, 1, 0, InstanceKuafuGroup.BOX_EXIST_TIME, protectTime, 0)
		end
		
		self:SubByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 0, count)
		-- ͬ����u����
		playerInfo:SubXianfuBoxCount(count)
	end
end

--������뿪ʱ����
function InstanceKuafuGroup:OnLeavePlayer( player, is_offline)
	local unitInfo = UnitInfo:new{ptr = player}
	-- �ش�Ԫ����Ϣ
	self:OnRestoreGold(unitInfo)
	
	-- ����������˾Ͳ����д���
	if self:GetMapState() == self.STATE_FINISH then
		return
	end
	
	self:OnDropTreasure(unitInfo, nil, true)
	-- ���û���� �Ǿͽ���
	local persons = mapLib.GetPlayersCounts(self.ptr)
	if persons == 0 then
		self:SyncResultToWeb()
		self:SetMapState(self.STATE_FINISH)
	end
end

-- �ش�Ԫ����Ϣ
function InstanceKuafuGroup:OnRestoreGold(unitInfo)
	local url = string.format("%s%s/kuafu_restore", globalGameConfig:GetExtWebInterface(), InstanceKuafuGroup.sub)
	local binindx = self:findIndexByName(unitInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + binindx * MAX_KUAFU_XIANFU_INT_COUNT
	local data = {}
	data.player_guid = unitInfo:GetPlayerGuid()
	data.changed = self:GetDouble(intstart + KUAFU_XIANFU_PLAYER_MONEY_CHANGED)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
	end)
end

--ʹ����Ϸ����֮ǰ
--����1�Ļ��ͼ���ʹ����Ϸ���󣬷���0�Ļ��Ͳ�ʹ��
function InstanceKuafuGroup:OnBeforeUseGameObject(user, go, go_entryid, posX, posY)
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
function InstanceKuafuGroup:OnUseGameObject(user, go, go_entryid, posX, posY)
	-- �ж϶�Ӧ��������buff
	for _, obj in ipairs(tb_buff_xianfu) do
		if obj.gameobject_id == go_entryid then
			local effects = obj.type_effect
			for _, effect in pairs(effects) do
				local buffId = effect[ 1 ]
				local lv = effect[ 2 ]
				local duration = tb_buff_template[buffId].duration
				--SpelladdBuff(user, buffId, user, lv, duration)
			end
			break
		end
	end
	
	-- ��Ҫɾ������
	mapLib.RemoveWorldObject(self.ptr, go)
	
	return 1	
end

-- ��õ��˵ĸ���ʱ��
function InstanceKuafuGroup:GetSingleRespawnTime(player)
	return tb_kuafu_xianfu_base[ 1 ].seconds
end

-- ��ͼ��Ҫ�����ʱҪ������
function InstanceKuafuGroup:IsNeedTeleportWhileMapClear(player)
	local playerInfo = UnitInfo:new {ptr = player}
	local login_fd = serverConnList:getLogindFD()
	call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
	return 0
end


-- �ж�ս��Ʒ�Ƿ���Ҫ���͵�������
function InstanceKuafuGroup:OnCheckIfSendToAppdAfterLootSelect(player, entry, count)
	local playerInfo = UnitInfo:new {ptr = player}
	local binindx = self:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + binindx * MAX_KUAFU_XIANFU_INT_COUNT
	
	self:AddByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 0, count)
	
	outFmtDebug("======== guid = %s,  binindx = %d, picked one , now = %d", playerInfo:GetPlayerGuid(), binindx, self:GetByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 0))
	
	-- ͬ����u����
	playerInfo:AddXianfuBoxCount(count)
	
	return 0
end

-- �ж��Ƿ�Ǯ��Ԫ������
function InstanceKuafuGroup:OnCheckIfCanCostRespawn(player)
	
	local unitInfo = UnitInfo:new {ptr = player}
	if unitInfo:IsAlive() then
		return
	end
	
	-- ��������
	local times = unitInfo:GetXianfuDeathCount()
	local cost = tb_kuafu_xianfu_base[ 1 ].gold * times
	
	local binindx = self:findIndexByName(unitInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + binindx * MAX_KUAFU_XIANFU_INT_COUNT
	local total = self:GetDouble(intstart + KUAFU_XIANFU_PLAYER_MONEY)
	local used = self:GetDouble(intstart + KUAFU_XIANFU_PLAYER_MONEY_CHANGED)
	
	-- Ǯ����
	if used + cost > total then
		return
	end
	self:SubDouble(intstart + KUAFU_XIANFU_PLAYER_MONEY_CHANGED, cost)
	
	-- ���Ǯ���� ��ȥ
	self:OnCostRespawn(unitInfo)
end
	
-- ��Ԫ������
function InstanceKuafuGroup:OnCostRespawn(unitInfo)
	if not unitInfo:IsAlive() then
		local mapid = self:GetMapId()
		unitInfo:SetUseRespawnMapId(mapid)
		unitLib.Respawn(unitInfo.ptr, RESURRPCTION_HUANHUNDAN, 100)	--ԭ�ظ���
	end
end

function InstanceKuafuGroup:OnRandomRespawn(unitInfo)
	if not unitInfo:IsAlive() then
		unitInfo:SetUseRespawnMapId(0)
		unitLib.Respawn(unitInfo.ptr, RESURRPCTION_HUANHUNDAN, 100)	--ԭ�ظ���
	end
end


-- ͬ��Ǯ
function InstanceKuafuGroup:OnSyncMoney(player_guid, binindx)
	local url = string.format("%s%s/sync_money", globalGameConfig:GetExtWebInterface(), InstanceKuafuGroup.sub)
	local data = {}
	data.player_guid = player_guid
	data.isPk = 1
	
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		
		outFmtDebug(response)
		local dict = nil
		security.call(
			--try block
			function()
				dict = json.decode(response)
			end
		)
		
		if dict then
			if dict.ret == 0 then
				local gold = dict.gold
				local changed = dict.changed
				local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + binindx * MAX_KUAFU_XIANFU_INT_COUNT
				self:SetDouble(intstart + KUAFU_XIANFU_PLAYER_MONEY, gold)
				self:SetDouble(intstart + KUAFU_XIANFU_PLAYER_MONEY_CHANGED, changed)
			end
		end
	end)
end


function InstanceKuafuGroup:AddKillCount(intstart)
	self:AddByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 1, 1)
	self:AddByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 3, 1)
end

function InstanceKuafuGroup:AddPlayerKilledCount(playerInfo)
	local indx = self:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
	self:SetByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 3, 0)
	playerInfo:AddXianfuDeathCount()
end



-------------------------�ɸ��ᱦboss---------------------------
AI_GroupBoss = class("AI_GroupBoss", AI_Base)
AI_GroupBoss.ainame = "AI_GroupBoss"

--����
function AI_GroupBoss:JustDied( map_ptr,owner,killer_ptr )
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	local bossInfo = UnitInfo:new{ptr = owner}
	local playerInfo = UnitInfo:new{ptr = killer_ptr}
	
	local instanceInfo = InstanceKuafuGroup:new{ptr = map_ptr}
	
	return 0
end

return InstanceKuafuGroup