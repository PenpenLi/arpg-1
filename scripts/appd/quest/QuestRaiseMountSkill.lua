local QuestRaiseMountSkill = class("QuestRaiseMountSkill", AbstractQuest)

IQuestRaiseMountSkill = QuestRaiseMountSkill:new{}

function QuestRaiseMountSkill:ctor()
	
end

function QuestRaiseMountSkill:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestRaiseMountSkill:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestRaiseMountSkill:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestRaiseMountSkill