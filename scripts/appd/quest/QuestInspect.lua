local QuestInspect = class("QuestInspect", AbstractQuest)

IQuestInspect = QuestInspect:new{}

function QuestInspect:ctor()
	
end

function QuestInspect:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestInspect:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestInspect:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestInspect