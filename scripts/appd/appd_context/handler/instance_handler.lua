
function PlayerInfo:Handle_Reset_Vip_Instance_Times(pkt)
	local mapid = pkt.id
	
	if tb_map_vip[mapid] == nil then
		return
	end
	
	self:buyVipMapTimes(mapid)
end