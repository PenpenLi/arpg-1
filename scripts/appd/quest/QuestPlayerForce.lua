local QuestPlayerForce = class("QuestPlayerForce", AbstractQuest)

IQuestPlayerForce = QuestPlayerForce:new{}

function QuestPlayerForce:ctor()
	
end

function QuestPlayerForce:OnInit(playerInfo, start, offset)
	local quest_ptr = playerInfo:getQuestMgr().ptr
	local force = playerInfo:GetForce()
	self:OnUpdate(quest_ptr, start, offset, {force})
end

-- ���Ŀ��ֵ
function QuestPlayerForce:GetTargetValue(targetInfo)
	return targetInfo[ 2 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestPlayerForce:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeValue(quest_ptr, start, offset, params)
end

return QuestPlayerForce