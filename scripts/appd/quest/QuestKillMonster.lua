local QuestKillMonster = class("QuestKillMonster", AbstractQuest)

IQuestKillMonster = QuestKillMonster:new{}

function QuestKillMonster:ctor()
	
end

function QuestKillMonster:OnInit(playerInfo, start, offset)
	
end

-- ���Ŀ��ֵ
function QuestKillMonster:GetTargetValue(targetInfo)
	return targetInfo[ 3 ]
end

-- ���½���, ���Ŀ����ɷ���true
function QuestKillMonster:OnUpdate(quest_ptr, start, offset, params)
	return self:OnUpdateModeObjectTimes(quest_ptr, start, offset, params)
end

return QuestKillMonster