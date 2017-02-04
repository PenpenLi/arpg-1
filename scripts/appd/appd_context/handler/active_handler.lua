---获取活跃度奖励
function PlayerInfo:Handle_Avtive_Reward(pkt)
	outFmtDebug("PlayerInfo:Handle_Avtive_Reward")
	local id = pkt.id
	local vip = pkt.vip
	
	local config = tb_activity_reward[id]
	
	if config == nil then
		return 
	end
	
	if vip == 1 then
		if self:GetVIP() <=0 then
			self:CallOptResult(OPRATE_TYPE_ACTIVITY, ACTIVITY_OPERATE_NOTVIP)
			return 
		end
	end
	
	local instMgr = self:getInstanceMgr()
	local activity = instMgr:getActivity()
	if activity < config.active then
		self:CallOptResult(OPRATE_TYPE_ACTIVITY, ACTIVITY_OPERATE_NOENOUGH)
		return
	end
	
	
	local idx = id * 2
	if vip == 1 then
		idx = idx + 1
	end
	
	local hasget = instMgr:hasGetActivityReward(idx)
	
	if hasget then
		self:CallOptResult(OPRATE_TYPE_ACTIVITY, ACTIVITY_OPERATE_HASGET)
		return 
	end
	
	instMgr:SetActivityReward(idx)
	
	local tab 

	if vip == 1 then
		tab = config.reward
	else
		tab = config.vipreward
	end
	
	for _,v in ipairs(tab) do
		self:PlayerAddItem(v[1],v[2],LOG_ITEM_OPER_TYPE_ACTIVITY)	
	end
	
	
end

--添加活跃度
function PlayerInfo:AddActiveItem(id)
	print("PlayerInfo:AddActiveItem-------------")
	local config = tb_activity_base[id]
	if config == nil then
		outFmtDebug("add active fail,no data %d",id)
		return 
	end
	
	local instMgr = self:getInstanceMgr()
	local num = instMgr:getActiveNum(id)
	num = num + 1
	instMgr:setActiveNum(id,num)
	instMgr:addActivity(config.active)
end