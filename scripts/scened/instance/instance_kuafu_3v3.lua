InstanceKuafu3v3 = class("InstanceKuafu3v3", InstanceInstBase)

InstanceKuafu3v3.Name = "InstanceKuafu3v3"
InstanceKuafu3v3.exit_time = 10
InstanceKuafu3v3.player_auto_respan = 1000
InstanceKuafu3v3.Time_Out_Fail_Callback = "timeoutCallback"

function InstanceKuafu3v3:ctor(  )
	
end

--初始化脚本函数
function InstanceKuafu3v3:OnInitScript()
	InstanceInstBase.OnInitScript(self) --调用基类
	
	-- 加任务任务时间
	local timestamp = os.time() + 120
	
	self:SetMapQuestEndTime(timestamp)
	-- 副本时间超时回调
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- 副本失败退出
function InstanceInstBase:timeoutCallback()
	self:SetMapState(self.STATE_FAIL)
	return false
end

--当副本状态发生变化时间触发
function InstanceKuafu3v3:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s后结束副本
		local timestamp = os.time() + InstanceKuafu3v3.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- 判断是否能退出副本
function InstanceKuafu3v3:DoPlayerExitInstance(player)
	return 1	--返回1的话为正常退出，返回0则不让退出
end

--玩家加入地图
function InstanceKuafu3v3:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--死亡了还进来，直接弹出去
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
end

--当玩家加入后触发
function InstanceKuafu3v3:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

function InstanceKuafu3v3:DoIsFriendly(killer_ptr, target_ptr)
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	local targetInfo = UnitInfo:new{ptr = target_ptr}
	
	ret = killerInfo:GetVirtualCamp() == targetInfo:GetVirtualCamp()
	
	if ret then
		return 1
	end
	return 0
end

--当玩家死亡后触发()
function InstanceKuafu3v3:OnPlayerDeath(player)
	-- 如果状态已经改变, 即使死了也不再更新时间
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	self:SetMapState(self.STATE_FAIL)
end

--当玩家离开时触发
function InstanceKuafu3v3:OnLeavePlayer( player, is_offline)
	
end

return InstanceKuafu3v3