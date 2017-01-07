InstanceWorldBossP = class("InstanceWorldBossP", Instance_base)

InstanceWorldBossP.Name = "InstanceWorldBossP"


function InstanceWorldBossP:ctor(  )
	
end

--当玩家离开时触发
function InstanceWorldBossP:OnLeavePlayer( player, is_offline)
	
end

--初始化脚本函数
function InstanceWorldBossP:OnInitScript(  )
	Instance_base.OnInitScript(self) --调用基类
	
	local endTime = os.time() + config.field_boss_born_time * 60
	
	-- 设置结束时间
	self:SetMapEndTime(endTime + 8)
	self:SetUInt32(WORLDBOSS_FIELDS_WAIT_TIME, endTime)
end

--当玩家加入后触发
function InstanceWorldBossP:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- 进城修改模式
	playerInfo:ChangeToPeaceModeAfterTeleport()
	
	outFmtDebug("=====================InstanceWorldBossP join guid = %s, line = %d", playerInfo:GetPlayerGuid(), self:GetMapLineNo())
end

return InstanceWorldBossP