InstanceXianfuTest = class("InstanceXianfuTest", InstanceInstBase)

InstanceXianfuTest.Name = "InstanceXianfuTest"
InstanceXianfuTest.exit_time = 10
InstanceXianfuTest.Time_Out_Fail_Callback = "timeoutCallback"
InstanceXianfuTest.dummys = 9

InstanceXianfuTest.BOX_EXIST_TIME = 1800

function InstanceXianfuTest:ctor(  )
	
end

--��ʼ���ű�����
function InstanceXianfuTest:OnInitScript()
	InstanceInstBase.OnInitScript(self) --���û���
	
	self:OnTaskStart()
	self:AddCountDown()
	
	-- bossˢ�¶�ʱ��
	mapLib.DelTimer(self.ptr, 'OnMonsterRefresh')
	mapLib.AddTimer(self.ptr, 'OnMonsterRefresh', 1000)
	
	self:OnInitBossInfo()
	
	-- ����generalid
	self:parseGeneralId()
end

function InstanceXianfuTest:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local hard = 1
	self:SetHard(hard)
end

function InstanceXianfuTest:SetHard(hard)
	self:SetUInt32(KUAFU_XIANFU_FIELDS_HARD, hard)
end


function InstanceXianfuTest:GetHard()
	return self:GetUInt32(KUAFU_XIANFU_FIELDS_HARD)
end


function InstanceXianfuTest:AddDummyCount()
	self:AddUInt32(XIANFU_TEST_DUMMY_COUNT, 1)
end

function InstanceXianfuTest:IsDummyEnough()
	return self:GetDummyCount() >= self.dummys
end

function InstanceXianfuTest:GetDummyCount()
	return self:GetUInt32(XIANFU_TEST_DUMMY_COUNT)
end



function InstanceXianfuTest:GetBoxid()
	local hard = self:GetHard()
	return tb_kuafu_xianfu_condition[hard].boxid
end

-- ��ʼ��boss����
function InstanceXianfuTest:OnInitBossInfo ()
	local timestamp = os.time()	
	local intstart = KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START
	for indx, bossInfo in ipairs(tb_kuafu_xianfu_tst_boss) do
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
function InstanceXianfuTest:GetBinlogIndxByEntry (entry)
	
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
function InstanceXianfuTest:SendMiniMapInfo()
	
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

function InstanceXianfuTest:AddCountDown()
	local timestamp = os.time() + tb_kuafu_xianfu_tst_base[ 1 ].cd
	self:SetMapStartTime(timestamp)
	mapLib.AddTimer(self.ptr, 'OnDummyRefresh', 500)
end

-- ˢ�¼���
function InstanceXianfuTest:OnDummyRefresh()
	-- �жϼ�������
	if self:IsDummyEnough() then
		return false
	end
	
	self:AddDummyCount()
	local id = self:GetDummyCount()
	
	local dummyInfo = tb_kuafu_xianfu_tst_dummy[ id ]
	local config = {}
	config.name   = dummyInfo.name
	config.gender = dummyInfo.gender
	config.level  = dummyInfo.level
	config.attrs  = dummyInfo.attrs
	config.weapon = dummyInfo.weapon
	config.avatar = dummyInfo.avatar
	config.divine = dummyInfo.divine
	config.spells = dummyInfo.spells
	config.passivespells = dummyInfo.passivespells
	config.force  = dummyInfo.force
	config.vip    = dummyInfo.vip
	config.reverse1 = 0
	config.reverse2 = 0
	config.reverse3 = 0
	config.reverse4 = 0
	config.reverse5 = 0
	
	
	local pos = tb_kuafu_xianfu_tst_base[ 1 ].bornPos[ 1 ]
	local offsetX = randInt(-5, 5)
	local offsetY = randInt(-5, 5)
	
	local image = self:GetImageInfo(config)
	self:AddImageBody(image, pos[ 1 ] + offsetX, pos[ 2 ] + offsetY, "AI_XianfuDummy", nil, tb_kuafu_xianfu_tst_base[ 1 ].seconds, nil)
	
	-- ��������
	local emptyIndex = self:findIndexByName()
	if emptyIndex > -1 then
		local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_INT_COUNT
		local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_STR_COUNT

		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_NAME, config.name)
		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_GUID, config.name)

		self:SetDouble(intstart + KUAFU_XIANFU_PLAYER_SETTLEMENT, config.force)
	end
	
	return true
end

-- ���ʽ��ʼ
function InstanceXianfuTest:OnTaskStart()
	local timestamp = os.time() +  tb_kuafu_xianfu_tst_base[ 1 ].last + tb_kuafu_xianfu_tst_base[ 1 ].cd
	-- ������ʱ��
	self:SetMapQuestEndTime(timestamp)
	-- ����ʱ�䳬ʱ�ص�
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- ˢ��boss
function InstanceXianfuTest:OnMonsterRefresh()
	if self:GetMapState() == self.STATE_FINISH then
		return false
	end
	
	local timestamp = os.time()
	for indx, bossInfo in pairs(tb_kuafu_xianfu_tst_boss) do
		local info = bossInfo.bossTime
		local createBossTime = info[ 1 ] * 60 + info[ 2 ]
		
		if self:GetMapCreateTime() + createBossTime <= timestamp then
			local bossintstart = KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START + MAX_KUAFU_XIANFU_BOSS_INT_COUNT * (indx - 1)
			local activeInfo = self:GetUInt32(bossintstart + KUAFU_XIANFU_BOSS_BORN_INFO)
			if activeInfo == 0 then
				-- ��ù����б�
				local dummys = mapLib.GetAllCreature(self.ptr)
				
				self:SetUInt32(bossintstart + KUAFU_XIANFU_BOSS_BORN_INFO, 1)
				local pos = bossInfo.bossPos
				local entry = bossInfo.bossEntry
				local bossName = tb_creature_template[entry].name
				local creature = mapLib.AddCreature(self.ptr, {
						templateid = entry, x = pos[ 1 ], y = pos[ 2 ], 
						active_grid = true, alias_name = bossName, ainame = "AI_XianfuTestBoss", npcflag = {}
					}
				)
				-- ��ʶΪboss��
				local creatureInfo = UnitInfo:new{ptr = creature}
				creatureInfo:SetUnitFlags(UNIT_FIELD_FLAGS_IS_FIELD_BOSS_CREATURE)
				
				local place = string.char(64+indx)
				
				self:SetUInt16(bossintstart + KUAFU_XIANFU_BOSS_SHOW_INFO, 1, 1)
				local boxid = self:GetBoxid()
				app:CallOptResult(self.ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_OCCUR, {bossName, place, tb_item_template[boxid].name})
				
				-- ���ó��
				for _, dummy_ptr in ipairs(dummys) do
					creatureLib.ModifyThreat(dummy_ptr, creature, 999999)
				end
			end
		end
	end
	
	-- ˢ��
	self:SendMiniMapInfo()
	
	return true
end

-- ����ʧ���˳�
function InstanceXianfuTest:timeoutCallback()
	-- ��ý���
	self:SetMapState(self.STATE_FINISH)
	return false
end

--������״̬�����仯ʱ�䴥��
function InstanceXianfuTest:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s���������
		local timestamp = os.time() + InstanceXianfuTest.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- �ж��Ƿ����˳�����
function InstanceXianfuTest:DoPlayerExitInstance(player)
	return 1	--����1�Ļ�Ϊ�����˳�������0�����˳�
end

--��Ҽ����ͼ
function InstanceXianfuTest:OnJoinPlayer(player)
	
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
function InstanceXianfuTest:findIndexByName(name)
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
function InstanceXianfuTest:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

function InstanceXianfuTest:DoIsFriendly(killer_ptr, target_ptr)
	-- ��ǰ��ͼ���ڵ���ʱ�� ���� ���ǿ�ʼ״̬
	if self:GetMapStartTime() > os.time() or self:GetMapState() ~= self.STATE_START then
		return 1
	end
	return 0
end

--����������󴥷�()
function InstanceXianfuTest:OnPlayerDeath(player)
	-- ���״̬�Ѿ��ı�, ��ʹ����Ҳ���ٸ���ʱ��
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	
end

-- �����
function InstanceXianfuTest:DoAfterRespawn(unit_ptr)
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
			self:FindAPlaceToRespawn(unit_ptr)
		end
		unitInfo:SetUseRespawnMapId(0)
	else
		self:FindAPlaceToRespawn(unit_ptr, true)
	end
end

function InstanceXianfuTest:FindAPlaceToRespawn(unit_ptr, isDummy)
	isDummy = isDummy or false
	-- �����������
	local a = GetRandomIndexTable(#tb_kuafu_xianfu_tst_base[ 1 ].respawnPos, 1)
	local pos = tb_kuafu_xianfu_tst_base[ 1 ].respawnPos[a[ 1 ]]
	local offsetX = 0
	local offsetY = 0
	
	local toX = pos[ 1 ] + offsetX
	local toY = pos[ 2 ] + offsetY
	
	if not isDummy then
		local toMapId = self:GetMapId()
		local lineNo = self:GetMapLineNo()
		local generalId	= self:GetMapGeneralId()
		playerLib.Teleport(unit_ptr, toMapId, toX, toY, lineNo, generalId)
	else
		unitLib.SetPos(unit_ptr, toX, toY, true)
	end
end

function InstanceXianfuTest:OnPlayerKilled(player, killer)
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
function InstanceXianfuTest:OnPlayerKilledByMonster(player, killer)
	local killerInfo = UnitInfo:new{ptr = killer}
	local playerInfo = UnitInfo:new{ptr = player}
	
	-- ��BOSSɱ��
	if killerInfo:GetUnitFlags(UNIT_FIELD_FLAGS_IS_FIELD_BOSS_CREATURE) then
		-- ������������
		self:AddPlayerKilledCount(playerInfo)
		
		-- �������� ��������еĻ�
		self:OnDropTreasure(playerInfo, killerInfo)
	else
		-- ������ɱ��
		self:OnPlayerKilled(player, killer)
	end
	
	return 0
end

function InstanceXianfuTest:OnSendDeathInfo(playerInfo, deathname ,killername ,params)
	-- �Ǽ��˵Ĳ���
	if playerInfo:GetTypeID() ~= TYPEID_PLAYER then
		return
	end
	-- ����Ұ�������سǵ���ʱ
	playerInfo:call_field_death_cooldown(DEAD_PLACE_TYPE_XIANFU, deathname, killername, params, tb_kuafu_xianfu_tst_base[ 1 ].seconds)
end


function InstanceXianfuTest:OnDropTreasure(playerInfo, killerInfo, is_offline)
	local belongGuid = ''
	if killerInfo and killerInfo:GetTypeID() == TYPEID_PLAYER and playerInfo:GetTypeID() == TYPEID_PLAYER then
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
		for k, v in pairs(tb_kuafu_xianfu_tst_killed_drop) do
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
			AddLootGameObject(self.ptr, playerInfo.ptr, belongGuid, loot_entry, 1, 0, InstanceXianfuTest.BOX_EXIST_TIME, protectTime, 0)
		end
		
		self:SubByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 0, count)
		-- ͬ����u����
		playerInfo:SubXianfuBoxCount(count)
	end
end

--������뿪ʱ����
function InstanceXianfuTest:OnLeavePlayer( player, is_offline)
	local unitInfo = UnitInfo:new{ptr = player}
	
	-- ����������˾Ͳ����д���
	if self:GetMapState() == self.STATE_FINISH then
		return
	end
	
	self:OnDropTreasure(unitInfo, nil, true)
	-- ���û���� �Ǿͽ���
	local persons = mapLib.GetPlayersCounts(self.ptr)
	if persons == 0 then
		self:SetMapState(self.STATE_FINISH)
	end
end

--ʹ����Ϸ����֮ǰ
--����1�Ļ��ͼ���ʹ����Ϸ���󣬷���0�Ļ��Ͳ�ʹ��
function InstanceXianfuTest:OnBeforeUseGameObject(user, go, go_entryid, posX, posY)
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
function InstanceXianfuTest:OnUseGameObject(user, go, go_entryid, posX, posY)
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
function InstanceXianfuTest:GetSingleRespawnTime(player)
	return tb_kuafu_xianfu_tst_base[ 1 ].seconds
end

-- ��ͼ��Ҫ�����ʱҪ������
function InstanceXianfuTest:IsNeedTeleportWhileMapClear(player)
	return 1
end


-- �ж�ս��Ʒ�Ƿ���Ҫ���͵�������
function InstanceXianfuTest:OnCheckIfSendToAppdAfterLootSelect(player, entry, count)
	local playerInfo = UnitInfo:new {ptr = player}
	local binindx = self:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + binindx * MAX_KUAFU_XIANFU_INT_COUNT
	
	self:AddByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 0, 1)
	
	-- ͬ����u����
	playerInfo:AddXianfuBoxCount(count)
	
	return 0
end

-- �ж��Ƿ�Ǯ��Ԫ������
function InstanceXianfuTest:OnCheckIfCanCostRespawn(player)
	
	local unitInfo = UnitInfo:new {ptr = player}
	if unitInfo:IsAlive() then
		return
	end
	
	self:OnCostRespawn(unitInfo)
end
	
-- ��Ԫ������
function InstanceXianfuTest:OnCostRespawn(unitInfo)
	if not unitInfo:IsAlive() then
		local mapid = self:GetMapId()
		unitInfo:SetUseRespawnMapId(mapid)
		unitLib.Respawn(unitInfo.ptr, RESURRPCTION_HUANHUNDAN, 100)	--ԭ�ظ���
	end
end

function InstanceXianfuTest:OnRandomRespawn(unitInfo)
	if not unitInfo:IsAlive() then
		unitInfo:SetUseRespawnMapId(0)
		unitLib.Respawn(unitInfo.ptr, RESURRPCTION_HUANHUNDAN, 100)	--ԭ�ظ���
	end
end

--[[
KUAFU_XIANFU_PLAYER_SHOW_INFO = 6	--  4��byte(byte0:��������, byte1:��ɱ����, byte2:��ɱBOSS����,byte3:��ɱ����)
--]]

function InstanceXianfuTest:AddKillCount(intstart)
	self:AddByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 1, 1)
	self:AddByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 3, 1)
end

function InstanceXianfuTest:AddPlayerKilledCount(playerInfo)
	local indx = self:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
	self:SetByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 3, 0)
	playerInfo:AddXianfuDeathCount()
end

---------------------------�ɸ��ᱦ����-------------------------
AI_XianfuDummy = class("AI_XianfuDummy", AI_Base)
AI_XianfuDummy.ainame = "AI_XianfuDummy"

--����
function AI_XianfuDummy:JustDied( map_ptr,owner,killer_ptr )
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	local dummyInfo = UnitInfo:new{ptr = owner}
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	
	local instanceInfo = InstanceXianfuTest:new{ptr = map_ptr}
	
	----------------------------------------------------------------------------------
	-- ��ɱ�߼ӻ�ɱ��
	local indx1 = instanceInfo:findIndexByName(killerInfo:GetName())
	local intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx1 * MAX_KUAFU_XIANFU_INT_COUNT
	instanceInfo:AddKillCount(intStart)
	
	-- ��ɱ���±�
	local indx2 = instanceInfo:findIndexByName(dummyInfo:GetName())
	
	-- ֪ͨ�����˻�ɱ��Ϣ
	local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do
		local player_guid = instanceInfo:GetStr(strstart + KUAFU_XIANFU_PLAYER_GUID)
		local player = mapLib.GetPlayerByPlayerGuid(map_ptr, player_guid)
		if player then
			local playerInfo = UnitInfo:new {ptr = player}
			playerInfo:call_kuafu_3v3_kill_detail(indx1, indx2)
		end
		
		strstart = strstart + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	-- ������������
	instanceInfo:AddPlayerKilledCount(dummyInfo)
	
	-- �������� ��������еĻ�
	instanceInfo:OnDropTreasure(dummyInfo, killerInfo)
	
	return 0
end



-------------------------�ɸ��ᱦboss---------------------------
AI_XianfuTestBoss = class("AI_XianfuTestBoss", AI_Base)
AI_XianfuTestBoss.ainame = "AI_XianfuTestBoss"

--����
function AI_XianfuTestBoss:JustDied( map_ptr,owner,killer_ptr )
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	local bossInfo = UnitInfo:new{ptr = owner}
	local playerInfo = UnitInfo:new{ptr = killer_ptr}
	
	local instanceInfo = InstanceXianfuTest:new{ptr = map_ptr}
	
	-- ��ʾ��ɱ����
	local entry = bossInfo:GetEntry()
	local indx = instanceInfo:GetBinlogIndxByEntry (entry)
	local boxes = tb_kuafu_xianfu_tst_boss[indx].bossDrop[ 1 ]
	app:CallOptResult(map_ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_KILL, {bossInfo:GetName(), playerInfo:GetName(), boxes})
	
	
	-- ��ɱboss����
	local binindx = instanceInfo:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + binindx * MAX_KUAFU_XIANFU_INT_COUNT
	instanceInfo:AddByte(intstart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 2, 1)
	
	-- ����boss��Ϣ
	local bossintstart = KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START + MAX_KUAFU_XIANFU_BOSS_INT_COUNT * (indx - 1)
	instanceInfo:SetUInt16(bossintstart + KUAFU_XIANFU_BOSS_SHOW_INFO, 1, 2)
	

	local dropConfig = tb_kuafu_xianfu_tst_boss[indx].bossDrop
	local boxes			= dropConfig[ 1 ]
	local protectTime	= dropConfig[ 2 ]
	local loot_entry 	= instanceInfo:GetBoxid()
	
	local dummyPick = tb_kuafu_xianfu_tst_boss[ 1 ].dummpy_pick
	
	local player_guid = ''
	for i = 1, boxes-dummyPick do
		--ģ��,����,�����,����ʱ��,����ʱ��,ǿ���ȼ�
		--local drop_item_config = {entry, 1, 0, 1800, protectTime, 0}		
		AddLootGameObject(map_ptr, owner, player_guid, loot_entry, 1, fcm, InstanceXianfuTest.BOX_EXIST_TIME, protectTime, 0)
	end
	
	local dummys = mapLib.GetAllCreature(map_ptr)
	for i, dummy in ipairs(dummys) do
		if binLogLib.GetBit(dummy, UNIT_FIELD_FLAGS, UNIT_FIELD_FLAGS_IS_FIELD_BOSS_CREATURE) then
			table.remove(dummys, i)
			break
		end
	end
	
	local mins = math.min(#dummys, dummyPick)
	local indice = GetRandomIndexTable(#dummys, mins)
	for _, indx in ipairs(indice) do
		local dummy_ptr = dummys[indx]
		instanceInfo:OnCheckIfSendToAppdAfterLootSelect(dummy_ptr, loot_entry, 1)
	end
	
	return 0
end

return InstanceXianfuTest