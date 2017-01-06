InstanceInstBase = class("InstanceInstBase", Instance_base)

InstanceInstBase.Name = "InstanceInstBase"

InstanceInstBase.Time_Out_Fail_Callback = "instanceFail"

InstanceInstBase.Leave_Callback = "prepareToLeave"

function InstanceInstBase:ctor(  )
	
end

--��ʼ���ű�����
function InstanceInstBase:OnInitScript(  )
	Instance_base.OnInitScript(self) --���û���
end


-- �˳�����ʱ����׼���˳�
function InstanceInstBase:prepareToLeave()
	mapLib.ExitInstance(self.ptr)
end


-- ����ʧ���˳�
function InstanceInstBase:instanceFail()
	local state = self.STATE_FAIL
	if self:CheckQuestAfterTargetUpdate() then
		state = self.STATE_FINISH
	end
	self:SetMapState(state)
end

--��������
function InstanceInstBase:OnAddQuests(questTable)
	for _, quest in pairs(questTable) do
		local instQuestType = quest[ 1 ]
		if Quest_Func_Table[instQuestType] then
			Quest_Func_Table[instQuestType](self, quest)
		end
	end
end

-- ��������λ��
function InstanceInstBase:GetEmptySlot()
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		if self:GetByte(i, 0) == 0 then
			return i
		end
	end
	
	return -1
end


----------------------------------------�������� ------------------------------------------
--���ӻ�ɱ��������
function InstanceInstBase:OnAddKillMonsterQuest(quest)
	if(#quest ~= 3) then
		return
	end
	
	local indx = self:GetEmptySlot()
	
	if indx < 0 then
		return
	end
	
	self:SetByte(indx, 0, quest[ 1 ])
	self:SetByte(indx, 1, quest[ 2 ])
	self:SetUInt16(indx, 1, quest[ 3 ])
end

--�����ռ���Ʒ����
function InstanceInstBase:OnAddPickItemQuest(quest)
	
end

--���Ӽ����������
function InstanceInstBase:OnAddActiveMachineQuest(quest)
	
end

--�����ػ�NPC����
function InstanceInstBase:OnAddProtectNPCQuest(quest)
	
end

--���ӻ���NPC����
function InstanceInstBase:OnAddEscortNPCQuest(quest)
	
end

--���ӷ�������
function InstanceInstBase:OnAddDefenseQuest(quest)
	
end

--���Ӵ�������
function InstanceInstBase:OnAddBreakThroughQuest(quest)
	
end



--[[
 = 1	-- ��ɱ����
 = 2	-- �ռ���Ʒ
 = 3	-- �������
 = 4	-- �ػ�NPC
 = 5	-- ����NPC
 = 6	-- ����
 = 7	-- ����
]]
Quest_Func_Table = {}
Quest_Func_Table[INSTANCE_QUEST_TYPE_KILL_MONSTER]	= InstanceInstBase.OnAddKillMonsterQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_PICK_ITEM]		= InstanceInstBase.OnAddPickItemQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_ACTIVE_MACHINE]= InstanceInstBase.OnAddActiveMachineQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_PROTECT_NPC]	= InstanceInstBase.OnAddProtectNPCQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_ESCORT_NPC]	= InstanceInstBase.OnAddEscortNPCQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_DEFENSE]		= InstanceInstBase.OnAddDefenseQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_BREAK_THROUGH]	= InstanceInstBase.OnAddBreakThroughQuest


----------------------------------------������ȸ������ ------------------------------------------

-- һ�����ﱻ���ɱ��
function InstanceInstBase:OneMonsterKilled(entry)
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		if self:GetByte(i, 0) == INSTANCE_QUEST_TYPE_KILL_MONSTER and self:IsFitForQuest(self:GetUInt16(i, 1), entry) then
			local indx = (i - MAP_INT_FIELD_QUESTS_START) / 2
			local prev = self:GetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx)
			self:SetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx, prev + 1)
			return true
		end
	end
	
	return false
end

-- �Ƿ������������
function InstanceInstBase:IsFitForQuest(dest, entry)
	return dest == entry or dest == 0 and tb_creature_template[entry].monster_type == 0
end


-- ���м���TODO


----------------------------------------������������� ------------------------------------------

-- ����ʱ�䵽���Ժ���߽��ȸ��º��������Ƿ����
function InstanceInstBase:CheckQuestAfterTargetUpdate(isTimeout)	
	isTimeout = isTimeout or 0
	
	local ret = true
	
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		local targetType = self:GetByte(i, 0)
		if targetType > 0 then
			if Quest_Check_Func_Table[targetType] then
				local vist = Quest_Check_Func_Table[targetType](self, i-MAP_INT_FIELD_QUESTS_START, isTimeout)
				if not vist then ret = false end
			end
		end
	end
	
	return ret
end

--����ɱ��������
function InstanceInstBase:OnCheckKillMonsterQuest(indx, isTimeout)
	local offset = MAP_INT_FIELD_QUESTS_START + indx * 2
	local process = self:GetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx)
	local target = self:GetByte(offset, 1)
	
	return process >= target
end

--����ռ���Ʒ����
function InstanceInstBase:OnCheckPickItemQuest(indx, isTimeout)
	return false
end

--��鼤���������
function InstanceInstBase:OnCheckActiveMachineQuest(indx, isTimeout)
	return false
end

--����ػ�NPC����
function InstanceInstBase:OnCheckProtectNPCQuest(indx, isTimeout)
	return false
end

--��黤��NPC����
function InstanceInstBase:OnCheckEscortNPCQuest(indx, isTimeout)
	return false
end

--����������
function InstanceInstBase:OnCheckDefenseQuest(indx, isTimeout)
	return false
end

--��鴳������
function InstanceInstBase:OnCheckBreakThroughQuest(indx, isTimeout)
	return false
end

--[[
 = 1	-- ��ɱ����
 = 2	-- �ռ���Ʒ
 = 3	-- �������
 = 4	-- �ػ�NPC
 = 5	-- ����NPC
 = 6	-- ����
 = 7	-- ����
]]
Quest_Check_Func_Table = {}
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_KILL_MONSTER]	= InstanceInstBase.OnCheckKillMonsterQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_PICK_ITEM]		= InstanceInstBase.OnCheckPickItemQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_ACTIVE_MACHINE]= InstanceInstBase.OnCheckActiveMachineQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_PROTECT_NPC]	= InstanceInstBase.OnCheckProtectNPCQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_ESCORT_NPC]	= InstanceInstBase.OnCheckEscortNPCQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_DEFENSE]		= InstanceInstBase.OnCheckDefenseQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_BREAK_THROUGH]	= InstanceInstBase.OnCheckBreakThroughQuest


--����������󴥷�()
function InstanceInstBase:OnPlayerDeath(player)
	local playerInfo = UnitInfo:new{ptr = player}	
	local timestamp = os.time() + 10
	self:AddTimeOutCallback(self.Leave_Callback, timestamp)
end

-------------------------------------------------------------------------------------------

--����Ҽ���󴥷�
function InstanceInstBase:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- �����޸�ģʽ
	playerInfo:ChangeToPeaceModeAfterTeleport()
end

return InstanceInstBase