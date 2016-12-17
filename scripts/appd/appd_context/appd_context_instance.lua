-- 检测能否进入VIP副本
function PlayerInfo:checkVipMapTeleport(id, hard)
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnterVIP(id, hard)
end

-- 通关VIP关卡
function PlayerInfo:passVipInstance(id, hard)
	local instMgr = self:getInstanceMgr()
	instMgr:passVipInstance(id, hard)
end

-- 进行扫荡
function PlayerInfo:sweepVIP(id)
	-- 每个信息4个byte[0:下次需要通关难度,1:当前难度,2:挑战次数,3:购买次数]
	local config = tb_map_vip[id]
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local instMgr = self:getInstanceMgr()
	
	-- 判断是否需要购买
	local times = instMgr:GetByte(indx, 2)
	if times < config.times then
		outFmtError("not need to buy because of full times")
		return
	end
	
	-- 有通关难度才让挑战
	local hard = instMgr:GetByte(indx, 1)
	if hard == 0 then
		outFmtError("not pass any hard in id = %d", id)
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
		instMgr:AddByte(indx, 3, 1)
		-- 发送到场景服进行挑战
		self:CallScenedDoSomething(APPD_SCENED_SWEEP_VIP_INSTANCE, id, ""..hard)
	end
	
end

---------------------------试炼塔-----------------------------
-- 检测能否进入试炼塔副本
function PlayerInfo:checkTrialMapTeleport()
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnterTrial()
end

-- 通关关卡
function PlayerInfo:passTrialInstance(id)
	local instMgr = self:getInstanceMgr()
	instMgr:passInstance(id)
	
	-- 设置试炼塔通关层数
	if self:GetUInt32(PLAYER_FIELD_TRIAL_LAYERS) < id then
		self:SetUInt32(PLAYER_FIELD_TRIAL_LAYERS, id)
	end
	-- 更新排名
	rankInsertTask(self:GetGuid(), RANK_TYPE_TRIAL)
end

-- 一键扫荡
function PlayerInfo:sweepTrial()
	local instMgr = self:getInstanceMgr()
	instMgr:sweepTrialInstance()
end

-- 重置试炼塔
function PlayerInfo:resetTrial()
	local instMgr = self:getInstanceMgr()
	instMgr:resetTrialInstance()
end


-----------------------------------------------------------------------------------
--- 副本模块每日重置
function PlayerInfo:instanceDailyReset()
	local instMgr = self:getInstanceMgr()
	instMgr:instanceDailyReset()
end