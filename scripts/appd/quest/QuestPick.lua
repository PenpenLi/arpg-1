local QuestPick = class("QuestPick", AbstractQuest)

IQuestPick = QuestPick:new{}

function QuestPick:ctor()
	
end

function QuestPick:OnInit(playerInfo, start, offset)
	
end

-- 获得目标值
function QuestPick:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- 更新进度, 如果目标完成返回true
function QuestPick:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestPick