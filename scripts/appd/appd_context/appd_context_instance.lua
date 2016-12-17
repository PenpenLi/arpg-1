-- ����ܷ����VIP����
function PlayerInfo:checkVipMapTeleport(id, hard)
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnterVIP(id, hard)
end

-- ͨ��VIP�ؿ�
function PlayerInfo:passVipInstance(id, hard)
	local instMgr = self:getInstanceMgr()
	instMgr:passVipInstance(id, hard)
end

-- ����ɨ��
function PlayerInfo:sweepVIP(id)
	-- ÿ����Ϣ4��byte[0:�´���Ҫͨ���Ѷ�,1:��ǰ�Ѷ�,2:��ս����,3:�������]
	local config = tb_map_vip[id]
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local instMgr = self:getInstanceMgr()
	
	-- �ж��Ƿ���Ҫ����
	local times = instMgr:GetByte(indx, 2)
	if times < config.times then
		outFmtError("not need to buy because of full times")
		return
	end
	
	-- ��ͨ���ѶȲ�����ս
	local hard = instMgr:GetByte(indx, 1)
	if hard == 0 then
		outFmtError("not pass any hard in id = %d", id)
		return
	end
	
	-- �����������
	local buyTimes = instMgr:GetByte(indx, 3)
	if buyTimes >= #config.cost then
		outFmtError("buy times is not enough")
		return
	end
	
	local cost = config.cost[buyTimes+1]
	
	if self:costMoneys(MONEY_CHANGE_BUY_VIP_INSTANCE, {{MONEY_TYPE_GOLD_INGOT, cost}}) then
		instMgr:AddByte(indx, 3, 1)
		-- ���͵�������������ս
		self:CallScenedDoSomething(APPD_SCENED_SWEEP_VIP_INSTANCE, id, ""..hard)
	end
	
end

---------------------------������-----------------------------
-- ����ܷ��������������
function PlayerInfo:checkTrialMapTeleport()
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnterTrial()
end

-- ͨ�عؿ�
function PlayerInfo:passTrialInstance(id)
	local instMgr = self:getInstanceMgr()
	instMgr:passInstance(id)
	
	-- ����������ͨ�ز���
	if self:GetUInt32(PLAYER_FIELD_TRIAL_LAYERS) < id then
		self:SetUInt32(PLAYER_FIELD_TRIAL_LAYERS, id)
	end
	-- ��������
	rankInsertTask(self:GetGuid(), RANK_TYPE_TRIAL)
end

-- һ��ɨ��
function PlayerInfo:sweepTrial()
	local instMgr = self:getInstanceMgr()
	instMgr:sweepTrialInstance()
end

-- ����������
function PlayerInfo:resetTrial()
	local instMgr = self:getInstanceMgr()
	instMgr:resetTrialInstance()
end


-----------------------------------------------------------------------------------
--- ����ģ��ÿ������
function PlayerInfo:instanceDailyReset()
	local instMgr = self:getInstanceMgr()
	instMgr:instanceDailyReset()
end