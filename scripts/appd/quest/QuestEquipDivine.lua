local QuestEquipDivine = class("QuestEquipDivine", AbstractQuest)

IQuestEquipDivine = QuestEquipDivine:new{}

function QuestEquipDivine:ctor()
	
end

function QuestEquipDivine:OnInit(playerInfo, start, offset)
	local quest_ptr = playerInfo:getQuestMgr().ptr
	local questId = binLogLib.GetUInt16(quest_ptr, start + QUEST_INFO_ID, 0)
	local divineId = tb_quest[questId].targets[offset+1][ 2 ]
	
	if playerInfo:hasEquDivine(divineId) then
		self:OnUpdate(quest_ptr, start, offset, {divineId})
	end
end

-- 获得目标值
function QuestEquipDivine:GetTargetValue(targetInfo)
	return 1
end

-- 更新进度, 如果目标完成返回true
function QuestEquipDivine:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestEquipDivine