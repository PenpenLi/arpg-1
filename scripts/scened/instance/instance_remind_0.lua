InstanceRemind0 = class("InstanceRemind0", InstanceInstBase)

InstanceRemind0.Name = "InstanceRemind0"

function InstanceRemind0:ctor(  )
	
end

--初始化脚本函数
function InstanceRemind0:OnInitScript(  )
	InstanceInstBase.OnInitScript(self) --调用基类
	
	if self:GetMapQuestEndTime() > 0 then
		return
	end
	
	self:parseGeneralId()
	
	self:SetMapEndTime(os.time() + 60)
end

function InstanceRemind0:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local params = string.split(generalId, '|')
	
	local prevMapId = tonumber(params[ 3 ])
	local entry		= tonumber(params[ 4 ])
	local bornX		= tonumber(params[ 5 ])
	local bornY		= tonumber(params[ 6 ])
	local lineNo	= tonumber(params[ 7 ])
	self:SetUInt32(MAP_INT_FIELD_RESERVE1, prevMapId)
	self:SetUInt32(MAP_INT_FIELD_RESERVE2, lineNo)
	
	local config	= tb_creature_template[entry]
	local creature = mapLib.AddCreature(self.ptr, {
			templateid = entry, x = bornX, y = bornY, 
			active_grid = true, alias_name = config.name, ainame = 'AI_RemindBoss0', npcflag = {}
		}
	)
end

--当副本状态发生变化时间触发
function InstanceRemind0:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s后结束副本
		local timestamp = os.time()
		self:SetMapEndTime(timestamp)
		
		-- 直接传出去
		local allPlayers = mapLib.GetAllPlayer(self.ptr)
		local player_ptr = allPlayers[ 1 ]
		local prevMapId = self:GetUInt32(MAP_INT_FIELD_RESERVE1)
		local lineNo = self:GetUInt32(MAP_INT_FIELD_RESERVE2)
		local toX, toY = unitLib.GetPos(player_ptr)
		playerLib.Teleport(player_ptr, prevMapId, toX, toY, lineNo)
	end
end

--玩家加入地图
function InstanceRemind0:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--死亡了还进来，直接弹出去
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
end

--当玩家死亡后触发()
function InstanceRemind0:OnPlayerDeath(player)
	-- 如果状态已经改变, 即使死了也不再更新时间
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	
	-- 立马复活
	unitLib.Respawn(player, RESURRPCTION_HUANHUNDAN, 100)	--原地复活
	
	-- 设置状态
	self:SetMapState(self.STATE_FAIL)
end

--当玩家离开时触发
function InstanceRemind0:OnLeavePlayer( player, is_offline)
	self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
	self:RemoveTimeOutCallback(self.Leave_Callback)
	-- 为了处理游戏刷新(不知道怎么退出的情况)
	if self:GetMapState() == self.STATE_START then
		self:SetMapState(self.STATE_FAIL)
	end
end

-------------------------------- BOSS
AI_RemindBoss0 = class("AI_RemindBoss0", AI_Base)
AI_RemindBoss0.ainame = "AI_RemindBoss0"
--死亡
function AI_RemindBoss0:JustDied( map_ptr,owner,killer_ptr )	
	
	local instanceInfo = InstanceRemind0:new{ptr = map_ptr}
	
	-- 如果时间到了失败了 即使最后下杀死BOSS都没用
	if instanceInfo:GetMapState() ~= instanceInfo.STATE_START then
		return
	end
	
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	instanceInfo:SetMapState(instanceInfo.STATE_FINISH)
	
	return 0
end

return InstanceRemind0