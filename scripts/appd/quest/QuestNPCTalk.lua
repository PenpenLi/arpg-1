local QuestNPCTalk = class("QuestNPCTalk", AbstractQuest)

IQuestNPCTalk = QuestNPCTalk:new{}

function QuestNPCTalk:ctor()
	
end

function QuestNPCTalk:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestNPCTalk:GetTargetValue(targetInfo)
	return 1
end

-- ���½���, ���Ŀ����ɷ���true
function QuestNPCTalk:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestNPCTalk