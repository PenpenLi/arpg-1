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
function QuestKillMonster:OnUpdate(playerInfo, start, offset, params)
	local showname = nil
	if tb_creature_template[params[ 1 ]] then
		showname = tb_creature_template[params[ 1 ]].name
	end
	return self:OnUpdateModeObjectTimes(playerInfo, start, offset, params, showname)
end

return QuestKillMonster