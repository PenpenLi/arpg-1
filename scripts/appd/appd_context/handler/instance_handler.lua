-- ɨ��vip����
function PlayerInfo:Handle_Sweep_Vip_Instance(pkt)
	local id = pkt.id
	
	if tb_map_vip[id] == nil then
		return
	end
	
	self:sweepVIP(id)
end


-- ɨ��������
function PlayerInfo:Handle_Sweep_Trial(pkt)
	self:sweepTrial()
end

-- ����������
function PlayerInfo:Handle_Reset_Trial(pkt)
	self:resetTrial()
end