local QuestJoinFactionActivity = class("QuestJoinFactionActivity", AbstractQuest)

IQuestJoinFactionActivity = QuestJoinFactionActivity:new{}

function QuestJoinFactionActivity:ctor()
	
end

function QuestJoinFactionActivity:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestJoinFactionActivity:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestJoinFactionActivity:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestJoinFactionActivity