local QuestStrengthSuit = class("QuestStrengthSuit", AbstractQuest)

IQuestStrengthSuit = QuestStrengthSuit:new{}

function QuestStrengthSuit:ctor()
	
end

function QuestStrengthSuit:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestStrengthSuit:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestStrengthSuit:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestStrengthSuit