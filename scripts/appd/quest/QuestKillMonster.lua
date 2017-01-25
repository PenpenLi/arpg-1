local QuestKillMonster = class("QuestKillMonster", AbstractQuest)

IQuestKillMonster = QuestKillMonster:new{}

function QuestKillMonster:ctor()
	
end

function QuestKillMonster:OnInit(playerInfo, start, offset)
	
end

-- 获得目标值
function QuestKillMonster:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- 更新进度, 如果目标完成返回true
function QuestKillMonster:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestKillMonster