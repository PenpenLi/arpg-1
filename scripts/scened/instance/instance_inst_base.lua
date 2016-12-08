InstanceInstBase = class("InstanceInstBase", Instance_base)

InstanceInstBase.Name = "InstanceInstBase"

function InstanceInstBase:ctor(  )
	
end

--初始化脚本函数
function InstanceInstBase:OnInitScript(  )
	Instance_base.OnInitScript(self) --调用基类
end

--当玩家加入后触发
function InstanceInstBase:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- 进城修改模式
	playerInfo:ChangeToPeaceModeAfterTeleport()
end

return InstanceInstBase