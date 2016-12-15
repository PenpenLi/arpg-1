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

-- ����ʧ���˳�
function InstanceInstBase:instanceFail()
	local state = self.STATE_FAIL
	if self:CheckQuestAfterTimeOut() then
		state = self.STATE_FINISH
	end
	self:SetMapState(state)
end

-- ׼���˳�
function InstanceInstBase:prepareToLeave()
	mapLib.ExitInstance(self.ptr)
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

-- ����ʱ�䵽���Ժ��������Ƿ����
function InstanceInstBase:CheckQuestAfterTimeOut()
	--[[
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		if self:GetByte(i, 0) == 0 then
			return i
		end
	end
	]]
	
	return false
end

-- һ�����ﱻ���ɱ��
function InstanceInstBase:OneMonsterKilled(entry)
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		if self:GetByte(i, 0) == INSTANCE_QUEST_TYPE_KILL_MONSTER and self:GetUInt16(i, 1) == entry then
			local indx = (i - MAP_INT_FIELD_QUESTS_START) / 2
			local prev = self:GetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx)
			self:SetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx, prev + 1)
			return
		end
	end
end

--���ӻ�ɱ��������
function InstanceInstBase:OnAddKillMonsterQuest(quest)
	assert(#quest == 3)
	
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


--����Ҽ���󴥷�
function InstanceInstBase:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- �����޸�ģʽ
	playerInfo:ChangeToPeaceModeAfterTeleport()
end

return InstanceInstBase