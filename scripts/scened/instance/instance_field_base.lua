InstanceFieldBase = class("InstanceFieldBase", Instance_base)

InstanceFieldBase.Name = "InstanceFieldBase"
InstanceFieldBase.player_auto_respan = 120

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
	-- ����Ұ�������سǵ���ʱ
	playerInfo:call_field_death_cooldown(self.player_auto_respan)
end

return InstanceFieldBase