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
	-- ����generalid
	self:parseGeneralId()
	
	self:OnInitMapTime()
	self:AddCountDown()
end

-- ���ʽ��ʼ
function InstanceKuafuGroup:OnInitMapTime()
	local id = self:GetHard()
	local timestamp = os.time() + tb_group_instance_base[ id ].startcd + tb_group_instance_base[ id ].time
	-- ������ʱ��
	self:SetMapQuestEndTime(timestamp)
	-- ����ʱ�䳬ʱ�ص�
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

function InstanceKuafuGroup:AddCountDown()
	local id = self:GetHard()
	local timestamp = os.time() + tb_group_instance_base[ id ].startcd
	self:SetMapStartTime(timestamp)
	self:AddTimeOutCallback("TryToNextPart", timestamp)
end

function InstanceKuafuGroup:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local params = string.split(generalId, '|')
	local hard = tonumber(params[ 2 ])
	self:SetHard(hard)
end

function InstanceKuafuGroup:TryToNextPart()
	local part = self:GetPart()
	local id = self:GetHard()
	local len = #tb_group_instance_base[id].monster
	if part >= len then	
		-- �������
		self:SetMapState(self.STATE_FINISH)
		
		return
	end
	
	self:OnMonsterRefresh()
end

-- �����ȸ���ʱ����
function InstanceKuafuGroup:AfterProcessUpdate(player)
	-- �жϸ����Ƿ�
	if self:CheckQuestAfterTargetUpdate() then
		self:AddUInt32(KUAFU_GROUP_INSTANCE_FIELDS_PART, 1)
		self:TryToNextPart()
	end
end

function InstanceKuafuGroup:SetHard(hard)
	self:SetUInt32(KUAFU_GROUP_INSTANCE_FIELDS_HARD, hard)
end

function InstanceKuafuGroup:GetHard()
	return self:GetUInt32(KUAFU_GROUP_INSTANCE_FIELDS_HARD)
end

function InstanceKuafuGroup:GetPart()
	return self:GetUInt32(KUAFU_GROUP_INSTANCE_FIELDS_PART)
end

-- ˢ��boss
function InstanceKuafuGroup:OnMonsterRefresh()
	local id = self:GetHard()
	local part = self:GetPart()
	
	local entry = tb_group_instance_base[id].monster[part+1]
	local cnt = tb_group_instance_base[id].monsternum[part+1]
	local pos = tb_group_instance_base[id].monsterPos[part+1]
	
	local offs = 2
	local width = offs * 2 + 1
	local grids = width * width
	
	-- ���Ͻǵ������
	local lx = pos[ 1 ] - offs
	local ly = pos[ 2 ] - offs
	
	local config = tb_creature_template[entry]
	local idTable = GetRandomIndexTable(grids, cnt)
	for _, indx in pairs(idTable) do
		local id = indx - 1
		local offx = id % width
		local offy = id / width
		local bornX = lx + offx
		local bornY = ly + offy
		
		local creature = mapLib.AddCreature(self.ptr, {
			templateid = entry, x = bornX, y = bornY,
			active_grid = true, ainame = config.ainame, npcflag = {}
		})
	end
	
	-- ˢ������
	local mapQuest = tb_group_instance_base[id].quests[part+1]
	-- �Ӹ�������
	InstanceInstBase.OnAddQuests(self, {mapQuest})
end

-- ����ʧ���˳�
function InstanceKuafuGroup:timeoutCallback()
	self:SetMapState(self.STATE_FAIL)
end

--������״̬�����仯ʱ�䴥��
function InstanceKuafuGroup:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		self:SyncResultToWeb()
		--10s���������
		local timestamp = os.time() + self.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- �ж��Ƿ����˳�����
function InstanceKuafuGroup:DoPlayerExitInstance(player)
	-- ֱ�ӻ�ԭ��
	local playerInfo = UnitInfo:new {ptr = player}
	local login_fd = serverConnList:getLogindFD()
	call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
	return 0	--����1�Ļ�Ϊ�����˳�������0�����˳�
end

--��Ҽ����ͼ
function InstanceKuafuGroup:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
	end
	
	-- �����ظ�����
	if self:findIndexByName(playerInfo:GetName()) > -1 then
		local login_fd = serverConnList:getLogindFD()
		call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
		return
	end
	
	--[[
	local id = self:GetHard()
	-- д����
	local config = tb_group_instance_base[id]
		
	local itemKeys = config.passRewardId
	local itemVals = config.passRewardCnt
	if not playerInfo:isGroupInstanceClearFlag(id) then
		itemKeys = config.fpRewardId
		itemVals = config.fpRewardCnt
	end
	
	local rewardDict = {}
	for i = 1, #itemKeys do
		local itemId = itemKeys[ i ]
		local count  = itemVals[ i ]
		table.insert(rewardDict, itemId..":"..count)
	end
	--]]
	
	-- ��������
	local emptyIndex = self:findIndexByName()
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		local strstart = KUAFU_GROUP_INSTANCE_STR_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_STR_COUNT
		
		--self:SetStr(strstart + KUAFU_GROUP_INSTANCE_PLAYER_REWARDS, string.join(",", rewardDict))
		self:SetStr(strstart + KUAFU_GROUP_INSTANCE_PLAYER_NAME, playerInfo:GetName())
		self:SetStr(strstart + KUAFU_GROUP_INSTANCE_PLAYER_GUID, playerInfo:GetPlayerGuid())
		
		self:SetByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0, 0)
	end
end

--������뿪ʱ����
function InstanceKuafuGroup:OnLeavePlayer( player, is_offline)
	local unitInfo = UnitInfo:new{ptr = player}

	-- ����������˾Ͳ����д���
	if self:GetMapState() ~= self.STATE_START then
		return
	end

	-- ���û���� �Ǿͽ���
	local persons = mapLib.GetPlayersCounts(self.ptr)
	if persons == 0 then
		self:SetMapState(self.STATE_FAIL)
	end
end

-- ������ֶ�Ӧ��λ��, ''��ʾ������ѯ��λλ��
function InstanceKuafuGroup:findIndexByName(name)
	name = name or ''
	local start = KUAFU_GROUP_INSTANCE_STR_FIELDS_PLAYER_INFO_START
	for i = 0, MAX_GROUP_INSTANCE_PLAYER_COUNT - 1 do
		if self:GetStr(start + KUAFU_GROUP_INSTANCE_PLAYER_NAME) == name then
			return i
		end
		start = start + MAX_KUAFU_GROUP_INSTANCE_PLAYER_STR_COUNT
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
	
	local playerInfo = UnitInfo:new {ptr = player}
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		self:AddByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0, 1)
		local times = self:GetByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0)
		local mapid = self:GetMapId()
		local waitTimeList = tb_map[mapid].rebornWaitTime
		if times > #waitTimeList then
			times = #waitTimeList
		end
		local sec = waitTimeList[times]
		self:SetUInt32(intstart + KUAFU_GROUP_INSTANCE_PLAYER_REBRON_CD, os.time() + sec)
	end
	
	self:OnSendDeathInfo(playerInfo, '', '')
end

-- ͬ�����ݵ�������
function InstanceKuafuGroup:SyncResultToWeb()
	if self:GetMapState() ~= self.STATE_FINISH then
		return
	end
	
	local url = string.format("%s%s/match_result", globalGameConfig:GetExtWebInterface(), InstanceKuafuGroup.sub)
	local data = {}
	
	local sendInfo = {}
	local allPlayers = mapLib.GetAllPlayer(self.ptr)
	for _, player_ptr in pairs(allPlayers) do
		table.insert(sendInfo, GetPlayerGuid(player_ptr))
	end
	
	data.ret = string.join('|', sendInfo)..';'..self:GetHard()
	data.open_time = 1
	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@result = ", data.ret)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("response = %s", tostring(response))
	end)
end

function InstanceKuafuGroup:GetCostTimeCD(playerInfo)
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		return self:GetUInt32(intstart + KUAFU_GROUP_INSTANCE_PLAYER_REBRON_CD)
	end
	
	return 0
end

function InstanceKuafuGroup:DoIsMate(killer_ptr, target_ptr)
	if killer_ptr and target_ptr and GetUnitTypeID(killer_ptr) == TYPEID_PLAYER and GetUnitTypeID(target_ptr) == TYPEID_PLAYER then
		return true
	end
	return false
end

-- ��ȡ��������
function InstanceKuafuGroup:GetDeadTimes(playerInfo)
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		local times = self:GetByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0)
		return times
	end
	
	return 99999999
end


-- ��ͼ��Ҫ�����ʱҪ������
function InstanceKuafuGroup:IsNeedTeleportWhileMapClear(player)
	local playerInfo = UnitInfo:new {ptr = player}
	local login_fd = serverConnList:getLogindFD()
	call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
	return 0
end


AI_GroupMonster = class("AI_GroupMonster", AI_Base)
AI_GroupMonster.ainame = "AI_GroupMonster"
--����
function AI_GroupMonster:JustDied( map_ptr,owner,killer_ptr )	
	-- ���ж��ǲ���VIP����	
	local mapid = mapLib.GetMapID(map_ptr)
	if tb_map[mapid].inst_sub_type ~= 12 then
		return
	end
	
	local instanceInfo = InstanceKuafuGroup:new{ptr = map_ptr}
	
	-- ���ʱ�䵽��ʧ���� ��ʹ�����ɱ��BOSS��û��
	if instanceInfo:GetMapState() ~= instanceInfo.STATE_START then
		return
	end
	
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	-- ����ɱ�ֽ���
	local ownerInfo = UnitInfo:new {ptr = owner}
	local entry = ownerInfo:GetEntry()
	local updated = instanceInfo:OneMonsterKilled(entry)
	
	-- ���½���
	if updated then
		instanceInfo:AfterProcessUpdate(killer_ptr)
	end
	
	return 0
end

AI_GroupBoss = class("AI_GroupBoss", AI_GroupMonster)
AI_GroupBoss.ainame = "AI_GroupBoss"

return InstanceKuafuGroup