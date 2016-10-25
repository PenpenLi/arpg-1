InstanceFactionBoss = class("InstanceFactionBoss", Instance_base)

InstanceFactionBoss.Name = "InstanceFactionBoss"
InstanceFactionBoss.REFRESH_CREATURE_INTERNAL = 1000	--1s检测一次
InstanceFactionBoss.RESPAWN_TIME = 10000				--10秒复活时间
InstanceFactionBoss.DURATION_TIME = 1800				--副本持续时间
InstanceFactionBoss.FACTION_BOSS_NAME = "faction_boss"	--帮派boss名字

--获取副本层数
function InstanceFactionBoss:GetFactionMapID()
	return self:GetUInt32(MAP_INT_FIELD_FACTION_MAP_ID) 
end
--设置副本层数
function InstanceFactionBoss:SetFactionMapID(val)
	self:SetUInt32(MAP_INT_FIELD_FACTION_MAP_ID, val) 
end

function InstanceFactionBoss:ctor(  )
	
end

--初始化脚本函数
function InstanceFactionBoss:OnInitScript(  )
	Instance_base.OnInitScript(self)					--调用基类
	self:SetMapEndTime(os.time() + self.DURATION_TIME)	--30分钟后回收
	
	--添加boss
	--mapLib.DelTimer(self.ptr, 'OnTimer_CheckRefreshBoss')
	--mapLib.AddTimer(self.ptr, 'OnTimer_CheckRefreshBoss', self.REFRESH_CREATURE_INTERNAL)
end

--当副本状态发生变化时间触发
function InstanceFactionBoss:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		--10s后结束副本
		self:SetMapEndTime(os.time() + 5)
	end
end

--玩家加入地图
function InstanceFactionBoss:OnJoinPlayer(player)
	Instance_base.OnJoinPlayer(self, player)
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--死亡了还进来，直接弹出去
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
	local lv = playerInfo:GetFactionFbCount() + 1
	self:SetFactionMapID(lv)
	--伤害加成buff
	if playerInfo:GetFlags(PLAYER_APPD_INT_FIELD_FLAGS_FACTION_BOSS_ADD) then
		AddNormalBuff(player,4,player,1)
		AddNormalBuff(player,5,player,1)
	end
end

--定时检查boss刷新
function InstanceFactionBoss:OnTimer_CheckRefreshBoss()
	local timenow = os.time()
	local config = tb_bangpai_boss[self:GetFactionMapID()]
	if config == nil then 
		--直接结束副本
		self:SetMapState(self.STATE_FAIL)
		return false
	end
	
	local boss = mapLib.AliasCreature(self.ptr, self.FACTION_BOSS_NAME)
	if not boss then
		local creature = mapLib.AddCreature(self.ptr, {templateid = config.boss_id, x = config.boss_point[1], y = config.boss_point[2], active_grid = true, alias_name = self.FACTION_BOSS_NAME, ainame = "AI_faction_boss", npcflag = {}})
		if creature then
			local creatureInfo = UnitInfo:new{ptr = creature}
			-- 标识为boss怪
			creatureInfo:SetUnitFlags(UNIT_FIELD_FLAGS_IS_BOSS_CREATURE)
			return false
		end	
	end
	return true
end

--当玩家离开时触发
function InstanceFactionBoss:OnLeavePlayer( player, is_offline)
	self:SetMapEndTime(os.time())
	RemoveNormalBuff(player,4)
	RemoveNormalBuff(player,5)
end

--这里不能复活，所以不处理
function InstanceFactionBoss:DoRespawn( player,cur_map_id,respwan_map,respwan_type,respwan_x,respwan_y )
	
end

-----------------------------------------------------------------------------
-----------------帮派单人boss ai------------------------
AI_faction_boss = class("AI_faction_boss", AI_boss)
AI_faction_boss.ainame = "AI_faction_boss"

--死亡
function AI_faction_boss:JustDied( map_ptr,owner,killer_ptr )
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	local playerInfo = UnitInfo:new{ptr = killer_ptr}	
	local lv = playerInfo:GetFactionFbCount()
	playerInfo:SetFactionFbCount(lv + 1)
	local mapInfo = InstanceFactionBoss:new{ptr = map_ptr}
	mapInfo:SetMapState(mapInfo.STATE_FINISH)
	return 0
end

return InstanceFactionBoss