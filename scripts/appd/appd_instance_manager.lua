local AppInstanceMgr = class("AppInstanceMgr", BinLogObject)

function AppInstanceMgr:ctor()
	
end

function AppInstanceMgr:checkIfCanEnterVIP(id, hard)

	local config = tb_map_vip[id]

	-- 判断VIP是否满足条件
	local player = self:getOwner()
	if not player:isVIP(config.vip) then
		outFmtError("vip level not satisfy")
		return
	end
	
	if not self:isEnoughForceByHard(id, hard, player:GetForce()) then
		outFmtError("no force to enter hard = %s", hard)
		return
	end
	
	-- 判断进入次数是否足够
	-- 每个信息4个byte[0:通关难度,1:当前难度,2:挑战次数,3:购买次数]
	
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local times = self:GetByte(indx, 2)
	local x 	= config.x
	local y 	= config.y
	local mapid = config.mapid
	
	if times == config.times then
		outFmtError("try time is not fit for mapid %d", mapid)
		return
	end
	
	self:AddByte(indx, 2, 1)
	
	local gerneralId = string.format("%d:%s:%d_%d:%s", id, hard, times, getMsTime(), player:GetGuid())
	
	-- 发起传送
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, gerneralId)
end

-- 通关难度
function AppInstanceMgr:passVipInstance(id, hard)
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local cmp = self:GetByte(indx, 1)
	local max = cmp
	
	if max < hard then
		max = hard
	end
	
	if max > cmp then
		outFmtInfo("vip instance passed, id = %d, hard = %d ", id, hard)
		self:SetByte(indx, 1, max)
	end
end

function AppInstanceMgr:isEnoughForceByHard(id, hard, force)
	hard = tonumber(hard)
	local config = tb_map_vip[id]
	return force >= config.forces[hard]
end


-------------------------------资源副本------------------------------
function AppInstanceMgr:checkIfCanEnterResInstance(id)
	
	outFmtDebug("appd enter res %d",id)
	local config = tb_instance_res[id]
	
	
	local player = self:getOwner()
	
	
	-- 判断进入次数是否足够
	-- 每个信息4个byte[0:挑战次数,1:预留,2:预留,3:预留]
	
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local times = self:GetByte(indx, 0)
	local mapid = config.mapid
	
	--outFmtDebug("times %d ,mapID %d",times,mapid)
	
	if times >= config.times then
		outFmtError("try time is not fit for mapid %d", mapid)
		return
	end
	
	local x 	= config.x
	local y 	= config.y
	
	self:AddByte(indx, 0, 1)

	
	
	local gerneralId = string.format("%d:%d:%s", id, getMsTime(), player:GetGuid())
	
	outFmtDebug("gerneralId %s",gerneralId)
	
	-- 发起传送
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, gerneralId)
end




-------------------------------试炼塔------------------------------
function AppInstanceMgr:checkIfCanEnterTrial()
	--[[INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT	= INSTANCE_INT_FIELD_VIP_END,					//(0:今日可扫荡层数,1:历史通关层数)
	INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT	= INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT + 1,	//(0:扫荡次数,1:可购买扫荡次数)--]]
	
	local passed = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1)
	if passed == #tb_map_trial then
		outFmtError("reach top layer")
		return
	end
	
	local nextId = passed + 1
	local player = self:getOwner()
	local config = tb_map_trial[nextId]
	
	local gerneralId = string.format("%d:%d:%s", nextId, getMsTime(), player:GetGuid())
	
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), config.x, config.y, config.mapid, gerneralId)
end


-- 通关层数
function AppInstanceMgr:passInstance(id)
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1, id)
end


-- 一键扫荡试炼塔
function AppInstanceMgr:sweepTrialInstance()
	local prevSweepTimes = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0)
	if prevSweepTimes == 0 then
		outFmtError("no times to sweepTrialInstance")
		return
	end
	
	local layers = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0)
	-- 都没通关没必要扫荡
	if layers == 0 then
		outFmtError("please pass the 1st layer first")
		return
	end
	
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, prevSweepTimes - 1)
	local player = self:getOwner()
	player:CallScenedDoSomething(APPD_SCENED_SWEEP_TRIAL_INSTANCE, layers)
end

-- 重置试炼塔
function AppInstanceMgr:resetTrialInstance()
	local prevSweepTimes	= self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0)
	local prevBuyTimes		= self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 1)
	
	if prevSweepTimes > 0 then
		outFmtError("not need to resetTrialInstance")
		return
	end
	
	local passed = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1)
	if passed == 0 then
		outFmtError("you can resetTrialInstance after pass the 1st layer")
		return
	end
	
	if prevBuyTimes == 0 then
		outFmtError("no time to buy to resetTrialInstance")
		return
	end
	
	-- 判断能否花元宝
	local gold = tb_map_trial[passed].resetgold
	local player = self:getOwner()
	if not player:checkMoneyEnough(MONEY_TYPE_GOLD_INGOT, gold) then
		outFmtError("gold is not enough")
		return
	end
	
	-- 扣钱
	player:SubMoney(MONEY_TYPE_GOLD_INGOT, MONEY_CHANGE_RESET_TRIAL, gold)
	
	-- 扣购买次数
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 1, prevBuyTimes - 1)
	
	-- 加次数
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, 1)
	
	-- 修改今日可扫荡层数
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0, passed)
end

-- 副本每日重置
function AppInstanceMgr:instanceDailyReset()
	-- 重置VIP副本
	for i = INSTANCE_INT_FIELD_VIP_START, INSTANCE_INT_FIELD_VIP_END-1 do
		local id = i - INSTANCE_INT_FIELD_VIP_START + 1
		self:SetByte(i, 2, 0)
		self:SetByte(i, 3, 0)
	end
	
	-- 重置试炼塔
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 1, 1)
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, 1)
	local passed = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1)
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0, passed)
end

-- 获得玩家guid
function AppInstanceMgr:getPlayerGuid()
	--物品管理器guid转玩家guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--获得副本管理器的拥有者
function AppInstanceMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end

return AppInstanceMgr