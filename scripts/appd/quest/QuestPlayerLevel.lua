local QuestPlayerLevel = class("QuestPlayerLevel", AbstractQuest)

IQuestPlayerLevel = QuestPlayerLevel:new{}

function QuestPlayerLevel:ctor()
	
end

function QuestPlayerLevel:OnInit(playerInfo, start, offset)
	local quest_ptr = playerInfo:getQuestMgr().ptr
	local level = playerInfo:GetLevel()
	self:OnUpdate(quest_ptr, start, offset, {level})
end

-- ���Ŀ��ֵ
function QuestPlayerLevel:GetTargetValue(targetInfo)
	return targetInfo[ 2 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestPlayerLevel:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeValue(quest_ptr, start, offset, params)
end

return QuestPlayerLevel