--领取成就点奖励
function PlayerInfo:Handle_Achieve_Reward(pkt)
	local id = pkt.id
	
	local config = tb_achieve_base[id]
	if config == nil then
		self:CallOptResult(OPRATE_TYPE_ACHIEVE, ACHIEVE_OPERATE_NO_FIND)
		return
	end
	
	self:AchieveReward(id)
end

--领取总成就点奖励
function PlayerInfo:Handle_Achieve_All_Reward(pkt)
	self:AchieveAllReward()
end
--装备称号
function PlayerInfo:Handle_Set_Title(pkt)
	outFmtDebug("PlayerInfo:Handle_Set_Title")
	local id = pkt.id
	self:SetTitle(id)
end

-- 领取任务奖励(包括进行下一步任务)
function PlayerInfo:Handle_Pick_Quest(pkt)
	local indx = pkt.indx
	
	-- 任务下标不存在
	if indx < 0 or indx >= MAX_QUEST_COUNT then
		return
	end
	
	self:pickQuest(indx)
end