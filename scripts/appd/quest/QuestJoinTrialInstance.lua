local QuestJoinTrialInstance = class("QuestJoinTrialInstance", AbstractQuest)

IQuestJoinTrialInstance = QuestJoinTrialInstance:new{}

function QuestJoinTrialInstance:ctor()
	
end

function QuestJoinTrialInstance:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestJoinTrialInstance:GetTargetValue(targetInfo)
	return targetInfo[ 2 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestJoinTrialInstance:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeTimes(quest_ptr, start, offset, params)
end

return QuestJoinTrialInstance