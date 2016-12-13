-- ����ܷ����VIP����
function PlayerInfo:checkVipMapTeleport(id, hard)
	local instMgr = self:getInstanceMgr()
	instMgr:checkIfCanEnter(id, hard)
end

-- ���й���������
function PlayerInfo:buyVipMapTimes(mapid)
	-- ÿ����Ϣ4��byte[0:�´���Ҫͨ���Ѷ�,1:��ǰ�Ѷ�,2:��ս����,3:�������]
	local config = tb_map_vip[mapid]
	local indx = INSTANCE_INT_FIELD_VIP_START + config.indx - 1
	local instMgr = self:getInstanceMgr()
	
	-- �ж��Ƿ���Ҫ����
	local times = instMgr:GetByte(indx, 2)
	if times < config.times then
		outFmtError("not need to buy because of full times")
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
		instMgr:SetByte(indx, 2, 0)
		instMgr:AddByte(indx, 3, 1)
		outFmtInfo("reset times success")
	end
	
end
