local AppInstanceMgr = class("AppInstanceMgr", BinLogObject)

function AppInstanceMgr:ctor()
	
end

function AppInstanceMgr:checkIfCanEnterVIP(id, hard)

	local config = tb_map_vip[id]

	-- �ж�VIP�Ƿ���������
	local player = self:getOwner()
	if not player:isVIP(config.vip) then
		outFmtError("vip level not satisfy")
		return
	end
	
	if not self:isEnoughForceByHard(id, hard, player:GetForce()) then
		outFmtError("no force to enter hard = %s", hard)
		return
	end
	
	-- �жϽ�������Ƿ��㹻
	-- ÿ����Ϣ4��byte[0:ͨ���Ѷ�,1:��ǰ�Ѷ�,2:��ս����,3:�������]
	
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
	
	local gerneralId = string.format("%d:%s:%d_%d", id, hard, times, getMsTime())
	
	-- ������
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, gerneralId)
end

-- ͨ���Ѷ�
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








-------------------------------������------------------------------
function AppInstanceMgr:checkIfCanEnterTrial()
	--[[INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT	= INSTANCE_INT_FIELD_VIP_END,					//(0:���տ�ɨ������,1:��ʷͨ�ز���)
	INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT	= INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT + 1,	//(0:ɨ������,1:�ɹ���ɨ������)--]]
	
	local passed = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1)
	if passed == #tb_map_trial then
		outFmtError("reach top layer")
		return
	end
	
	local nextId = passed + 1
	local player = self:getOwner()
	local config = tb_map_trial[nextId]
	
	local gerneralId = string.format("%d:%d", nextId, getMsTime())
	
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), config.x, config.y, config.mapid, gerneralId)
end


-- ͨ�ز���
function AppInstanceMgr:passInstance(id)
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1, id)
end


-- һ��ɨ��������
function AppInstanceMgr:sweepTrialInstance()
	local prevSweepTimes = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0)
	if prevSweepTimes == 0 then
		outFmtError("no times to sweepTrialInstance")
		return
	end
	
	local layers = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0)
	-- ��ûͨ��û��Ҫɨ��
	if layers == 0 then
		outFmtError("please pass the 1st layer first")
		return
	end
	
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, prevSweepTimes - 1)
	local player = self:getOwner()
	player:CallScenedDoSomething(APPD_SCENED_SWEEP_TRIAL_INSTANCE, layers)
end

-- ����������
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
	-- TODO: ������� ���ֻ�ǲ���
--	prevBuyTimes = 1
	
	-- �ж��ܷ�Ԫ��
	local gold = tb_map_trial[passed].resetgold
	local player = self:getOwner()
	if not player:checkMoneyEnough(MONEY_TYPE_GOLD_INGOT, gold) then
		outFmtError("gold is not enough")
		return
	end
	
	-- ��Ǯ
	player:SubMoney(MONEY_TYPE_GOLD_INGOT, MONEY_CHANGE_RESET_TRIAL, gold)
	
	-- �۹������
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 1, prevBuyTimes - 1)
	
	-- �Ӵ���
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, 1)
	
	-- �޸Ľ��տ�ɨ������
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0, passed)
end



-- ������guid
function AppInstanceMgr:getPlayerGuid()
	--��Ʒ������guidת���guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--��ø�����������ӵ����
function AppInstanceMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end

return AppInstanceMgr