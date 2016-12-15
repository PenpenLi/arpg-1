
function PlayerInfo:Handle_Reset_Vip_Instance_Times(pkt)
	local id = pkt.id
	
	if tb_map_vip[id] == nil then
		return
	end
	
	self:buyVipMapTimes(id)
end