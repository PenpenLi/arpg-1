-- 扫荡vip副本
function PlayerInfo:Handle_Sweep_Vip_Instance(pkt)
	local id = pkt.id
	
	if tb_map_vip[id] == nil then
		return
	end
	
	self:sweepVIP(id)
end


-- 扫荡试炼塔
function PlayerInfo:Handle_Sweep_Trial(pkt)
	self:sweepTrial()
end

-- 重置试炼塔
function PlayerInfo:Handle_Reset_Trial(pkt)
	self:resetTrial()
end


-- 世界BOSS报名
function PlayerInfo:Handle_World_Boss_Enroll(pkt)
	onEnrole(self)
end