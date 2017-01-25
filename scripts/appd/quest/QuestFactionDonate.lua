local QuestFactionDonate = class("QuestFactionDonate", AbstractQuest)

IQuestFactionDonate = QuestFactionDonate:new{}

function QuestFactionDonate:ctor()
	
end

function QuestFactionDonate:OnInit(playerInfo, start, offset)
	
end

-- 获得目标值
function QuestFactionDonate:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- 更新进度, 如果目标完成返回true
function QuestFactionDonate:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestFactionDonate