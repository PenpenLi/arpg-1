local QuestPlayerLevel = class("QuestPlayerLevel", AbstractQuest)

IQuestPlayerLevel = QuestPlayerLevel:new{}

function QuestPlayerLevel:ctor()
	
end

function QuestPlayerLevel:OnInit(playerInfo, start, offset)
	local quest_ptr = playerInfo:getQuestMgr().ptr
	local level = playerInfo:GetLevel()
	self:OnUpdate(quest_ptr, start, offset, {level})
end

-- 获得目标值
function QuestPlayerLevel:GetTargetValue(targetInfo)
	return targetInfo[ 2 ]
end

-- 更新进度, 如果目标完成返回true
function QuestPlayerLevel:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeValue(quest_ptr, start, offset, params)
end

return QuestPlayerLevel