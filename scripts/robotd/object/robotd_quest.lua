local RobotdQuest = class('RobotdQuest', BinLogObject)

--构造函数
function RobotdQuest:ctor()
	
end

-- 获得主线任务的信息
--[[
{
	questId = int,
	state = int,
	steps = {
		{
			stepState = int
			targetNum = int
			process   = int
		}
	}
}
--]]
function RobotdQuest:GetMainQuestInfo()
	local indx = self:GetMainQuestIndx()
	if not indx then
		return
	end
	
	return self:GetQuestInfoByIndx(indx)
end

-- 获得主线任务的binlogindx
function RobotdQuest:GetMainQuestIndx()

	local intstart = QUEST_FIELD_QUEST_START
	for i = 1, MAX_QUEST_COUNT do
		local questId = self:GetUInt16(intstart + QUEST_INFO_ID, 0)
		if questId > 0 then
			if tb_quest[questId].type == QUEST_TYPE_MAIN then
				return intstart
			end
		end
		intstart = intstart + MAX_QUEST_INFO_COUNT
	end

	return
end

-- 获得任务的binlogindx
function RobotdQuest:GetQuestIndxById(matchQuestId)

	local intstart = QUEST_FIELD_QUEST_START
	for i = 1, MAX_QUEST_COUNT do
		local questId = self:GetUInt16(intstart + QUEST_INFO_ID, 0)
		if questId > 0 and questId == matchQuestId then
			return i-1
		end
		intstart = intstart + MAX_QUEST_INFO_COUNT
	end

	return
end

function RobotdQuest:CheckQuestIsFinished(matchQuestId)
	local intstart = QUEST_FIELD_QUEST_START
	for i = 1, MAX_QUEST_COUNT do
		local questId = self:GetUInt16(intstart + QUEST_INFO_ID, 0)
		if questId > 0 and questId == matchQuestId then
			return self:GetUInt16(intstart + QUEST_INFO_ID, 1) == QUEST_STATUS_COMPLETE
		end
		intstart = intstart + MAX_QUEST_INFO_COUNT
	end

	return false
end

-- 获得binlogindx的任务信息
function RobotdQuest:GetQuestInfoByIndx(intstart)
	local questId = self:GetUInt16(intstart + QUEST_INFO_ID, 0)
	if questId == 0 then
		return
	end
	
	local info = {}
	info.questId = questId
	info.state = self:GetUInt16(intstart + QUEST_INFO_ID, 1)
	info.steps = {}
	for i = QUEST_INFO_STEP_START, QUEST_INFO_STEP_END-1, MAX_QUEST_TARGET_INFO_COUNT do
		local targetIntstart = intstart + i
		local stepInfo = {}
		stepInfo.stepState = self:GetUInt16(targetIntstart + QUEST_TARGET_INFO_SHORT0, 0)
		stepInfo.targetNum = self:GetUInt16(targetIntstart + QUEST_TARGET_INFO_SHORT0, 1)
		stepInfo.process   = self:GetUInt32(targetIntstart + QUEST_TARGET_INFO_PROCESS)
		table.insert(info.steps, stepInfo)
	end
	
	return info
end

return RobotdQuest