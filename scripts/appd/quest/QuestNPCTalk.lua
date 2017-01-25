local QuestNPCTalk = class("QuestNPCTalk", AbstractQuest)

IQuestNPCTalk = QuestNPCTalk:new{}

function QuestNPCTalk:ctor()
	
end

function QuestNPCTalk:OnInit(playerInfo, start, offset)
	
end

-- 获得目标值
function QuestNPCTalk:GetTargetValue(targetInfo)
	return 1
end

-- 更新进度, 如果目标完成返回true
function QuestNPCTalk:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestNPCTalk