InstanceWorldBossP = class("InstanceWorldBossP", Instance_base)

InstanceWorldBossP.Name = "InstanceWorldBossP"


function InstanceWorldBossP:ctor(  )
	
end

--������뿪ʱ����
function InstanceWorldBossP:OnLeavePlayer( player, is_offline)
	
end

--��ʼ���ű�����
function InstanceWorldBossP:OnInitScript(  )
	Instance_base.OnInitScript(self) --���û���
	
	local endTime = os.time() + config.field_boss_born_time * 60
	
	-- ���ý���ʱ��
	self:SetMapEndTime(endTime)
	self:SetUInt32(WORLDBOSS_FIELDS_WAIT_TIME, endTime)
end

--����Ҽ���󴥷�
function InstanceWorldBossP:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- �����޸�ģʽ
	playerInfo:ChangeToPeaceModeAfterTeleport()
end

function InstanceWorldBossP:DoIsMate(killer_ptr, target_ptr)
	if GetUnitTypeID(killer_ptr) == TYPEID_PLAYER and GetUnitTypeID(target_ptr) == TYPEID_PLAYER then
		return true
	end
	return false
end


return InstanceWorldBossP