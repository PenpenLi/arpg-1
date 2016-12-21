InstanceFieldBase = class("InstanceFieldBase", Instance_base)

InstanceFieldBase.Name = "InstanceFieldBase"

function InstanceFieldBase:ctor(  )
	
end

--初始化脚本函数
function InstanceFieldBase:OnInitScript(  )
	Instance_base.OnInitScript(self) --调用基类
end

function InstanceFieldBase:DoIsFriendly(killer_ptr, target_ptr)
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	local targetInfo = UnitInfo:new{ptr = target_ptr}

	-- 先判断
	local ret = true
	if killerInfo:GetTypeID() == TYPEID_PLAYER then
		if targetInfo:GetTypeID() == TYPEID_PLAYER then
			local killerMode = killerInfo:GetBattleMode()
			local targetMode = targetInfo:GetBattleMode()
			
			local mask = tb_battle_mode[killerMode+1].mask
			local battleMask = targetInfo:generateBattleMask(killerInfo)
	
			ret = bit.band(mask, battleMask) == 0
			
			-- 如果都是友好的 且 我是自卫反击模式
			if ret then
				if killerMode == SELF_DEFENSE_MODE and killerInfo:GetSelfProtectedUIntGuid() == targetInfo:GetIntGuid() and targetMode ~= PEACE_MODE and targetMode ~= SELF_DEFENSE_MODE then
					ret = false
				end
			end
		elseif targetInfo:GetTypeID() == TYPEID_UNIT then
			ret = false
		end
	elseif killerInfo:GetTypeID() == TYPEID_UNIT then
		ret = targetInfo:GetTypeID() ~= TYPEID_PLAYER
	end
	
	if ret then
		return 1
	end
	return 0
end

--当玩家死亡后触发()
function InstanceFieldBase:OnPlayerDeath(player)
	local playerInfo = UnitInfo:new{ptr = player}
	-- 是否在挂机, 是否自动使用复活丹
	--[[if player:isInHook() and self:isUseRespawnItem() then
		playerLib.SendToAppdDoSomething(player, SCENED_APPD_USE_RESPAWN_ITEM, 0)
		return
	end--]]
	local cooldown = 120
	local timestamp = os.time() + cooldown
	self:AddTimeOutCallback(self.Leave_Callback, timestamp)
	
	-- 发送野外死亡回城倒计时
	playerInfo:call_field_death_cooldown(cooldown)
end

return InstanceFieldBase