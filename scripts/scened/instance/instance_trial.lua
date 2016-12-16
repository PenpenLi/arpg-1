InstanceTrial = class("InstanceTrial", InstanceInstBase)

InstanceTrial.Name = "InstanceTrial"
InstanceTrial.player_auto_respan = 120
InstanceTrial.exit_time = 10

function InstanceTrial:ctor(  )
	
end

--初始化脚本函数
function InstanceTrial:OnInitScript(  )
	InstanceInstBase.OnInitScript(self) --调用基类
	
	if self:GetMapQuestEndTime() > 0 then
		return
	end
	
	self:parseGeneralId()
	
	local id = self:GetIndex()
	local time	= tb_map_trial[ id ].time	
	local questTable = tb_map_trial[ id ].quests
	-- 加副本任务
	self:OnAddQuests(questTable)
	-- 加任务任务时间
	local timestamp = os.time() + time
	
	self:SetMapQuestEndTime(timestamp)
	-- 副本时间超时回调
	self:AddTimeOutCallback(InstanceInstBase.Time_Out_Fail_Callback, timestamp)
end


function InstanceTrial:GetIndex()
	return self:GetUInt32(TRIAL_INSTANCE_FIELD_ID)
end

function InstanceTrial:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local params = string.split(generalId, ':')
	local indx = tonumber(params[ 1 ])
	
	self:SetUInt32(TRIAL_INSTANCE_FIELD_ID, indx)
end


--当副本状态发生变化时间触发
function InstanceTrial:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(InstanceInstBase.Time_Out_Fail_Callback)
		
		--10s后结束副本
		local timestamp = os.time() + InstanceTrial.exit_time
		
		self:AddTimeOutCallback(InstanceInstBase.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- 判断是否能退出副本
function InstanceTrial:DoPlayerExitInstance(player)
	self:RemoveTimeOutCallback(InstanceInstBase.Leave_Callback)
	return 1	--返回1的话为正常退出，返回0则不让退出
end

--玩家加入地图
function InstanceTrial:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--死亡了还进来，直接弹出去
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
	
	-- 刷新怪物
	self:OnRefreshMonster(player)
	
end

--刷怪
function InstanceTrial:OnRefreshMonster(player)
	
	-- 由于是进副本就刷的, 判断如果进入时间比开始时间开始时间超过2秒以上则不刷了
	-- 主要为了解决离线重连的问题
	local time = os.time()
	local startTime = self:GetMapCreateTime()
	if time - startTime > 2 then
		return
	end
	
	local id		= self:GetIndex()
	local config	= tb_map_trial[ id ]
	
	local entry
	local bornX
	local bornY
	
	if #config.monsterInfo > 0 then
		-- 中心点的坐标
		local cx	= config.monsterInfo[ 1 ]
		local cy	= config.monsterInfo[ 2 ]
		
		entry 		= config.monsterInfo[ 3 ]
		local offs	= config.monsterInfo[ 4 ]
		local num	= config.monsterInfo[ 5 ]
		local width = offs * 2 + 1
		local grids = width * width
		local cent	= (grids - 1) / 2
		
		-- 左上角点的坐标
		local lx = cx - offs
		local ly = cy - offs
		
		
		local idTable = GetRandomIndexTable(grids, num)
		for _, indx in pairs(idTable) do
			local id = indx - 1
			local offx = id % width
			local offy = id / width
			bornX = lx + offx
			bornY = ly + offy
			
			mapLib.AddCreature(self.ptr, {
				templateid = entry, x = bornX, y = bornY, 
				active_grid = true, alias_name = "", ainame = tb_creature_template[entry].ainame, npcflag = {}
			}
		)
		end
	end
	
	if #config.bossInfo > 0 then
		entry = config.bossInfo[ 3 ]
		bornX = config.bossInfo[ 1 ]
		bornY = config.bossInfo[ 2 ]
		mapLib.AddCreature(self.ptr, {
				templateid = entry, x = bornX, y = bornY, 
				active_grid = true, alias_name = "TrialBoss", ainame = tb_creature_template[entry].ainame, npcflag = {}
			}
		)
	end


	
end

--当玩家加入后触发
function InstanceTrial:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

--当玩家死亡后触发()
function InstanceTrial:OnPlayerDeath(player)
	-- 如果状态已经改变, 即使死了也不再更新时间
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	self:SetMapState(self.STATE_FAIL)
end

--当玩家离开时触发
function InstanceTrial:OnLeavePlayer( player, is_offline)
	if not is_offline then
		self:SetMapEndTime(os.time())
	end
end

-- 当进度更新时调用
function InstanceTrial:AfterProcessUpdate(player)
	-- 判断副本是否
	if self:CheckQuestAfterTargetUpdate() then
		local id = self:GetIndex()
		-- 获得随机奖励dropIdTable
		local dropIdTable = tb_map_trial[ id ].reward
		local data = self:RandomReward(player, dropIdTable)
		
		self:SetMapReward(data)
		
		-- 设置状态
		self:SetMapState(self.STATE_FINISH)
		
		--发到应用服进行进入判断
		playerLib.SendToAppdDoSomething(player, SCENED_APPD_PASS_TRIAL_INSTANCE, id)
	end
end

-------------------------------- BOSS
AI_trialboss = class("AI_trialboss", AI_Base)
AI_trialboss.ainame = "AI_trialboss"
--死亡
function AI_trialboss:JustDied( map_ptr,owner,killer_ptr )	
	
	-- 先判断是不是试炼塔副本
	local mapid = mapLib.GetMapID(map_ptr)
	if tb_map[mapid].inst_sub_type ~= 2 then
		return
	end
	
	local instanceInfo = InstanceTrial:new{ptr = map_ptr}
	
	-- 如果时间到了失败了 即使最后下杀死BOSS都没用
	if instanceInfo:GetMapState() ~= instanceInfo.STATE_START then
		return
	end
	
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	-- 更新杀怪进度
	local ownerInfo = UnitInfo:new {ptr = owner}
	local entry = ownerInfo:GetEntry()
	local updated = instanceInfo:OneMonsterKilled(entry)
	
	-- 更新进度
	if updated then
		instanceInfo:AfterProcessUpdate(killer_ptr)
	end
	
	return 0
end


----------------------------- 小怪----------------------------
AI_trial = class("AI_trial", AI_Base)
AI_trial.ainame = "AI_trial"
--死亡
function AI_trial:JustDied( map_ptr,owner,killer_ptr )	
	
	-- 先判断是不是试炼塔副本
	local mapid = mapLib.GetMapID(map_ptr)
	if tb_map[mapid].inst_sub_type ~= 2 then
		return
	end
	
	local instanceInfo = InstanceTrial:new{ptr = map_ptr}
	
	-- 如果时间到了失败了 即使最后下杀死BOSS都没用
	if instanceInfo:GetMapState() ~= instanceInfo.STATE_START then
		return
	end
	
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	-- 更新杀怪进度
	local ownerInfo = UnitInfo:new {ptr = owner}
	local entry = ownerInfo:GetEntry()
	local updated = instanceInfo:OneMonsterKilled(entry)
	
	-- 更新进度
	if updated then
		instanceInfo:AfterProcessUpdate(killer_ptr)
	end
	
	return 0
end

return InstanceTrial