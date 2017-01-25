local QuestJoinFaction = class("QuestJoinFaction", AbstractQuest)

IQuestJoinFaction = QuestJoinFaction:new{}

function QuestJoinFaction:ctor()
	
end

function QuestJoinFaction:OnInit(playerInfo, start, offset)
	local fguid = playerInfo:GetFactionId()
	if fguid ~= "" then
		local quest_ptr = playerInfo:getQuestMgr().ptr
		self:OnUpdate(quest_ptr, start, offset, {})
	end
end

-- ���Ŀ��ֵ
function QuestJoinFaction:GetTargetValue(targetInfo)
	return 1
end

-- ���½���, ���Ŀ����ɷ���true
function QuestJoinFaction:OnUpdate(quest_ptr, start, offset, params)
	
	local questId = binLogLib.GetUInt16(quest_ptr, start + QUEST_INFO_ID, 0)
	local qtIndx = GetOneQuestTargetStartIndx(start, offset)
	
	binLogLib.SetUInt32(quest_ptr, qtIndx + QUEST_TARGET_INFO_PROCESS, 1)
	binLogLib.SetUInt16(quest_ptr, qtIndx + QUEST_TARGET_INFO_SHORT0, 0, 1)
	
	return true
end

return QuestJoinFaction