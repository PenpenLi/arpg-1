local QuestTrainMount = class("QuestTrainMount", AbstractQuest)

IQuestTrainMount = QuestTrainMount:new{}

function QuestTrainMount:ctor()
	
end

function QuestTrainMount:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestTrainMount:GetTargetValue(targetInfo)
	return targetInfo[ 2 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestTrainMount:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeTimes(quest_ptr, start, offset, params)
end

return QuestTrainMount