InstanceFieldBase = class("InstanceFieldBase", Instance_base)

InstanceFieldBase.Name = "InstanceFieldBase"

function InstanceFieldBase:ctor(  )
	
end

--��ʼ���ű�����
function InstanceFieldBase:OnInitScript(  )
	Instance_base.OnInitScript(self) --���û���
end

function InstanceFieldBase:DoIsFriendly(killer_ptr, target_ptr)
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	local targetInfo = UnitInfo:new{ptr = target_ptr}

	-- ���ж�
	local ret = true
	if killerInfo:GetTypeID() == TYPEID_PLAYER then
		if targetInfo:GetTypeID() == TYPEID_PLAYER then
			local killerMode = killerInfo:GetBattleMode()
			local targetMode = targetInfo:GetBattleMode()
			
			local mask = tb_battle_mode[killerMode+1].mask
			local battleMask = targetInfo:generateBattleMask(killerInfo)
	
			ret = bit.band(mask, battleMask) == 0
			
			-- ��������Ѻõ� �� ������������ģʽ
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

--����������󴥷�()
function InstanceFieldBase:OnPlayerDeath(player)
	local playerInfo = UnitInfo:new{ptr = player}
	-- �Ƿ��ڹһ�, �Ƿ��Զ�ʹ�ø��
	--[[if player:isInHook() and self:isUseRespawnItem() then
		playerLib.SendToAppdDoSomething(player, SCENED_APPD_USE_RESPAWN_ITEM, 0)
		return
	end--]]
	local cooldown = 120
	local timestamp = os.time() + cooldown
	self:AddTimeOutCallback(self.Leave_Callback, timestamp)
	
	-- ����Ұ�������سǵ���ʱ
	playerInfo:call_field_death_cooldown(cooldown)
end

return InstanceFieldBase