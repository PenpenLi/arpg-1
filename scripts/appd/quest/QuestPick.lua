local QuestPick = class("QuestPick", AbstractQuest)

IQuestPick = QuestPick:new{}

function QuestPick:ctor()
	
end

function QuestPick:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestPick:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestPick:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestPick