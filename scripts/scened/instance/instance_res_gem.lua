InstanceResGem = class("InstanceResGem", InstanceResBase)

InstanceResGem.Name = "InstanceResGem"
InstanceResGem.exit_time = 10

InstanceResGem.GEM_NAME = "GEM11:11"
InstanceResGem.THREAT_V = 9999999

function InstanceResGem:ctor(  )
	
end


function InstanceResGem:InitRes(config)
	outFmtDebug("gem----------------------- %d", #config.protectors)
	-- 加晶石
	for _, pInfo in pairs(config.protectors) do
		local entry = pInfo[ 1 ]
		local bornX = pInfo[ 2 ]
		local bornY = pInfo[ 3 ]
		
		local creature = mapLib.AddCreature(self.ptr, 
				{templateid = entry, x = bornX, y = bornY, active_grid = true, alias_name = InstanceResGem.GEM_NAME, ainame = "AI_gem", npcflag = {}})
	end
	
	mapLib.AddTimer(self.ptr, 'OnTimerRefreshGemHp', 1000)
end

-- 更新晶石血量
function InstanceResGem:OnTimerRefreshGemHp()
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		return false
	end
	
	local GEM_NPC = mapLib.AliasCreature(self.ptr, InstanceResGem.GEM_NAME)
	if not GEM_NPC then
		return true
	end
	local gemInfo = UnitInfo:new {ptr = GEM_NPC}
	local hp = gemInfo:GetHealth()
	local maxHealth  = gemInfo:GetMaxhealth()
	local rate = math.floor(hp * 100 / maxHealth)
	self:ProtectorHit(gemInfo:GetEntry(), rate)
	
	return true
end

function InstanceResGem:ApplyRefreshMonsterBatch(player,batchIdx)
	outFmtDebug("gem ************")

	local id = self:GetIndex()
	local config = tb_instance_res[ id ]
	local prev = player:GetLevel()
	local cnt = config.monsternum
	local entry = config.monster[1]
	local monsterposlist = config.monsterInfo
	
	local GEM_NPC = mapLib.AliasCreature(self.ptr, InstanceResGem.GEM_NAME)
	
	for i = 1, cnt do
		--randInt(0, self.RefreshOffset)
		local bornPos = monsterposlist[1]
		local bornPos2 = monsterposlist[2]
		
		local bornX = randInt(bornPos[ 1 ],bornPos2[1])
		local bornY = randInt(bornPos[ 2 ],bornPos2[2])

		local creature = mapLib.AddCreature(self.ptr, 
			{templateid = entry, x = bornX, y = bornY, level=prev, active_grid = true, attackType = REACT_AGGRESSIVE,
			ainame = "AI_res", npcflag = {}})
		
		-- 设置仇恨度
		creatureLib.ModifyThreat(creature, GEM_NPC, InstanceResGem.THREAT_V)
	end
	
	for i = 1, cnt do
		--randInt(0, self.RefreshOffset)
		local bornPos = monsterposlist[3]
		local bornPos2 = monsterposlist[4]
		
		local bornX = randInt(bornPos[ 1 ],bornPos2[1])
		local bornY = randInt(bornPos[ 2 ],bornPos2[2])

		local creature = mapLib.AddCreature(self.ptr, 
			{templateid = entry, x = bornX, y = bornY, level=prev, active_grid = true, attackType = REACT_AGGRESSIVE,
			ainame = "AI_res", npcflag = {}})
		
		-- 设置仇恨度
		creatureLib.ModifyThreat(creature, GEM_NPC, InstanceResGem.THREAT_V)
	end
	
	return true,cnt+cnt
end

--刷新boss
function InstanceResGem:RefreshBoss(playerInfo)
	local id = self:GetIndex()
	local prev = playerInfo:GetLevel()
	
	mapLib.AddTimer(self.ptr, 'OnTimerRefreshBoss', 5000, id, prev)
end

--刷新boss
function InstanceResGem:OnTimerRefreshBoss(id, level)
	local id = self:GetIndex()
	local config = tb_instance_res[ id ]
	local entry = config.boss
	local bornPos = config.bosspos
	
	local creature = mapLib.AddCreature(self.ptr, {templateid = entry, x = bornPos[1], y = bornPos[2], level=level, 
		active_grid = true, alias_name = config.name, ainame = "AI_resBoss", npcflag = {}})
	
	-- 设置仇恨度
	local GEM_NPC = mapLib.AliasCreature(self.ptr, InstanceResGem.GEM_NAME)
	creatureLib.ModifyThreat(creature, GEM_NPC, InstanceResGem.THREAT_V)
	
	return false
end

-- 
function InstanceResGem:DoIsFriendly(killer_ptr, target_ptr)
	
	if self:GetMapState() ~= self.STATE_START then
		return 1
	end
			
	local ret = Instance_base.DoIsFriendly(self, killer_ptr, target_ptr)
	
	if ret == 1 then
		local killerInfo = UnitInfo:new{ptr = killer_ptr}
		local targetInfo = UnitInfo:new{ptr = target_ptr}
		if killerInfo:GetTypeID() == TYPEID_UNIT then
			if targetInfo:GetNpcFlags() > 0 then
				ret = 0
			end
		end
	end

	return ret
end


----------------------------- 怪物----------------------------
AI_gem = class("AI_gem", AI_Base)
AI_gem.ainame = "AI_gem"
--死亡
function AI_gem:JustDied( map_ptr,owner,killer_ptr )
	-- 先判断是不是试炼塔副本
	local mapid = mapLib.GetMapID(map_ptr)
	if tb_map[mapid].inst_sub_type ~= INSTANCE_SUB_TYPE_RES then
		return
	end
	
	local instanceInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	
	-- 如果时间到了失败了 即使最后下杀死BOSS都没用
	if instanceInfo:GetMapState() ~= instanceInfo.STATE_START then
		return
	end
	
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	-- 失败
	instanceInfo:SetMapState(instanceInfo.STATE_FAIL)
	
	return 0
end


return InstanceResGem