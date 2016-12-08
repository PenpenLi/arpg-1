-- ����ܷ����VIP����
function PlayerInfo:checkVipMapTeleport(id)
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnter(id)
end

-- ���й���������
function PlayerInfo:buyVipMapTimes(mapid)
	-- ÿ����Ϣ4��byte[0:�´���Ҫͨ���Ѷ�,1:��ǰ�Ѷ�,2:��ս����,3:�������]
	local config = tb_map_vip[mapid]
	local indx = INSTANCE_INT_FIELD_VIP_START + config.indx - 1
	
	-- �ж��Ƿ���Ҫ����
	local times = self:GetByte(indx, 2)
	if times < config.times then
		return
	end
	
	-- �����������
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

-- �ж��Ƿ��ܽ����Ѷ�
function PlayerInfo:activeHardIfForceChanged()
	local battlePoint = self:GetForce()
	for i = 1, #tb_map_vip do
		local config = tb_map_vip[ i ]
		local indx = INSTANCE_INT_FIELD_VIP_START + config.indx - 1
		
		local nextHard = self:GetByte(indx, 0)
		local currHard = self:GetByte(indx, 1)
		if currHard < hardlimit and config. nextHard > currHard and battlePoint >= config.raiseHardBattlePoints[nextHard] then
			-- �����Ѷ�
			self:AddByte(indx, 1)
		end
	end
end