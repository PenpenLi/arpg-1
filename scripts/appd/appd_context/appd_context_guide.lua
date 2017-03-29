
--设置上次引导id
function PlayerInfo:SetGuideIdLast(id)
	self:SetUInt32(PLAYER_INT_FIELD_GUIDE_ID_LAST,id)
end
--获得上次引导id
function PlayerInfo:GetGuideIdLast()
	return self:GetUInt32(PLAYER_INT_FIELD_GUIDE_ID_LAST,id)

end
--设置当前引导id 更新上次引导id
function PlayerInfo:SetGuideIdNow(id)
	if id < 1 then
		return
	end
	local now_id = self:GetGuideIdNow()
	self:SetGuideIdLast(now_id)
	self:SetUInt32(PLAYER_INT_FIELD_GUIDE_ID_NOW,id)
end
--获得当前引导id
function PlayerInfo:GetGuideIdNow()
	return self:GetUInt32(PLAYER_INT_FIELD_GUIDE_ID_NOW,id)

end


function PlayerInfo:UpdateGuideIdByTaskId (task_id)
	local taskInfo = tb_quest[task_id]
	if not taskInfo then
		return
	end
	local guide_id =  taskInfo.guide_id
	if guide_id > 0 then
		self:SetGuideIdNow(guide_id)
	end
end

function PlayerInfo:UpdateGuideIdByModuleId (module_id)
	local moduleInfo = tb_system_base[module_id]
	if not moduleInfo then
		return
	end
	local guide_id =  moduleInfo.guide_id
	if guide_id > 0 then
		self:SetGuideIdNow(guide_id)
	end
end

