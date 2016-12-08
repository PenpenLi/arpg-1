-- 检测能否进入VIP副本
function PlayerInfo:checkVipMapTeleport(id)
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnter(id)
end

-- 进行购买进入次数
function PlayerInfo:buyVipMapTimes(mapid)
	-- 每个信息4个byte[0:下次需要通关难度,1:当前难度,2:挑战次数,3:购买次数]
	local config = tb_map_vip[mapid]
	local indx = INSTANCE_INT_FIELD_VIP_START + config.indx - 1
	
	-- 判断是否需要购买
	local times = self:GetByte(indx, 2)
	if times < config.times then
		return
	end
	
	-- 购买次数已满
	local buyTimes = self:GetByte(indx, 3)
	if buyTimes >= #config.cost then
		return
	end
	
	local cost = config.cost[buyTimes+1]
	
	if self:costMoneys(MONEY_CHANGE_BUY_VIP_INSTANCE, {{MONEY_TYPE_GOLD_INGOT, cost}}) then
		self:SetByte(indx, 2, 0)
		self:AddByte(indx, 3)
	end
	
end

-- 判断是否能解锁难度
function PlayerInfo:activeHardIfForceChanged()
	local battlePoint = self:GetForce()
	for i = 1, #tb_map_vip do
		local config = tb_map_vip[ i ]
		local indx = INSTANCE_INT_FIELD_VIP_START + config.indx - 1
		
		local nextHard = self:GetByte(indx, 0)
		local currHard = self:GetByte(indx, 1)
		if currHard < hardlimit and config. nextHard > currHard and battlePoint >= config.raiseHardBattlePoints[nextHard] then
			-- 增加难度
			self:AddByte(indx, 1)
		end
	end
end