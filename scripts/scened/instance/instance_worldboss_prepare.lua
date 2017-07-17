InstanceWorldBossP = class("InstanceWorldBossP", Instance_base)

InstanceWorldBossP.Name = "InstanceWorldBossP"


function InstanceWorldBossP:ctor(  )
	
end

--玩家加入地图
function InstanceWorldBossP:OnJoinPlayer(player)
	InstanceInstBase.OnJoinPlayer(self, player)
end

--当玩家离开时触发
function InstanceWorldBossP:OnLeavePlayer( player, is_offline)
	
end

--初始化脚本函数
function InstanceWorldBossP:OnInitScript(  )
	Instance_base.OnInitScript(self) --调用基类
	
	local endTime = os.time() + config.field_boss_born_time * 60
	
	-- 设置结束时间
	self:SetMapEndTime(endTime)
	self:SetUInt32(WORLDBOSS_FIELDS_WAIT_TIME, endTime)
end

return InstanceWorldBossP