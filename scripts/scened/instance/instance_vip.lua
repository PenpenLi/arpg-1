InstanceVIP = class("InstanceVIP", InstanceInstBase)

InstanceVIP.Name = "InstanceVIP"
InstanceVIP.player_auto_respan = 120
InstanceVIP.exit_time = 10
InstanceVIP.BOSS_NAME = "meichaofeng"

function InstanceVIP:ctor(  )
	
end

--初始化脚本函数
function InstanceVIP:OnInitScript(  )
	InstanceInstBase.OnInitScript(self) --调用基类
	
	if self:GetMapQuestEndTime() > 0 then
		return
	end
	
	self:parseGeneralId()
	
	local id	= self:getIndex()
	local hard	= self:getHard()
	local time	= tb_map_vip[ id ].time
	local questTable = tb_map_vip[ id ].quests[hard]
	-- 加副本任务
	InstanceInstBase.OnAddQuests(self, questTable)
	-- 加任务任务时间
	local timestamp = os.time() + time
	
	self:SetMapQuestEndTime(timestamp)
	-- 副本时间超时回调
	self:AddTimeOutCallback(InstanceInstBase.Time_Out_Fail_Callback, timestamp)
end

function InstanceVIP:getIndex()
	return self:GetUInt16(VIP_INSTANCE_FIELD_ID, 0)
end

function InstanceVIP:getHard()
	return self:GetUInt16(VIP_INSTANCE_FIELD_ID, 1)
end

function InstanceVIP:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local params = string.split(generalId, ':')
	local indx = tonumber(params[ 1 ])
	local hard = tonumber(params[ 2 ])
	
	self:SetUInt16(VIP_INSTANCE_FIELD_ID, 0, indx)
	self:SetUInt16(VIP_INSTANCE_FIELD_ID, 1, hard)
end

--当副本状态发生变化时间触发
function InstanceVIP:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(InstanceInstBase.Time_Out_Fail_Callback)
		
		--10s后结束副本
		local timestamp = os.time() + InstanceVIP.exit_time
		
		self:AddTimeOutCallback(InstanceInstBase.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- 判断是否能退出副本
function InstanceVIP:DoPlayerExitInstance(player)
	self:RemoveTimeOutCallback(InstanceInstBase.Leave_Callback)
	return 1	--返回1的话为正常退出，返回0则不让退出
end

--玩家加入地图
function InstanceVIP:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--死亡了还进来，直接弹出去
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
	
	-- 刷新BOSS
	self:OnRefreshBoss(player)
	
end

--刷怪
function InstanceVIP:OnRefreshBoss(player)
	
	local boss = mapLib.AliasCreature(self.ptr, InstanceVIP.BOSS_NAME)
	
	if boss then
		return
	end
	
	local hard		= self:getHard()
	local id		= self:getIndex()
	local entry		= tb_map_vip[id].creatures[hard]
	
	local config	= tb_creature_template[entry]
	local bornX		= tb_map_vip[id].bossx
	local bornY		= tb_map_vip[id].bossy

	mapLib.AddCreature(self.ptr, {
			templateid = entry, x = bornX, y = bornY, 
			active_grid = true, alias_name = InstanceVIP.BOSS_NAME, ainame = config.ainame, npcflag = {}
		}
	)
	
end

--当玩家加入后触发
function InstanceVIP:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

--当玩家死亡后触发()
function InstanceVIP:OnPlayerDeath(player)
	self:SetMapState(self.STATE_FAIL)
end

--当玩家离开时触发
function InstanceVIP:OnLeavePlayer( player, is_offline)
	if not is_offline then
		self:SetMapEndTime(os.time())
	end
end

-------------------------------- BOSS
AI_vipboss = class("AI_vipboss", AI_Base)
AI_vipboss.ainame = "AI_vipboss"
--死亡
function AI_vipboss:JustDied( map_ptr,owner,killer_ptr )	
	
	-- 先判断是不是VIP副本	
	local mapid = mapLib.GetMapID(map_ptr)
	if tb_map[mapid].inst_sub_type ~= 1 then
		return
	end
	
	local instanceInfo = InstanceVIP:new{ptr = map_ptr}
	local id  = instanceInfo:getIndex()
	
	if tb_map_vip[id] == nil then
		return
	end
	
	
	-- 随机奖励
	local hard   = instanceInfo:getHard()
	
	local dropId = tb_map_vip[id].rewards[hard]
	local reward = DoRandomDrop(killer_ptr, dropId)
	local data = string.join(",", reward)
	
	instanceInfo:SetMapReward(data)
	
	local ownerInfo = UnitInfo:new {ptr = owner}
	local entry = ownerInfo:GetEntry()
	InstanceInstBase.OneMonsterKilled(instanceInfo, entry)
	
	instanceInfo:SetMapState(instanceInfo.STATE_FINISH)
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	return 0
end

return InstanceVIP