-- 检测能否进入VIP副本
function PlayerInfo:checkVipMapTeleport(id, hard)
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnter(id, hard)
end

-- 进行购买进入次数
function PlayerInfo:buyVipMapTimes(mapid)
	-- 每个信息4个byte[0:下次需要通关难度,1:当前难度,2:挑战次数,3:购买次数]
	local config = tb_map_vip[mapid]
	local indx = INSTANCE_INT_FIELD_VIP_START + config.indx - 1
	local instMgr = self:getInstanceMgr()
	
	-- 判断是否需要购买
	local times = instMgr:GetByte(indx, 2)
	if times < config.times then
		outFmtError("not need to buy because of full times")
		return
	end
	
	-- 购买次数已满
	local buyTimes = instMgr:GetByte(indx, 3)
	if buyTimes >= #config.cost then
		outFmtError("buy times is not enough")
		return
	end
	
	local cost = config.cost[buyTimes+1]
	
	if self:costMoneys(MONEY_CHANGE_BUY_VIP_INSTANCE, {{MONEY_TYPE_GOLD_INGOT, cost}}) then
		instMgr:SetByte(indx, 2, 0)
		instMgr:AddByte(indx, 3, 1)
		outFmtInfo("reset times success")
	end
	
end
