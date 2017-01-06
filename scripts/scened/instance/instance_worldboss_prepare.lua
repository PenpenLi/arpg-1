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
	
	-- ���ý���ʱ��
	self:SetMapEndTime(os.time() + config.field_boss_born_time * 60 + 8)
end

--����Ҽ���󴥷�
function InstanceWorldBossP:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- �����޸�ģʽ
	playerInfo:ChangeToPeaceModeAfterTeleport()
	
	outFmtDebug("=====================InstanceWorldBossP join guid = %s, line = %d", playerInfo:GetPlayerGuid(), self:GetMapLineNo())
end

return InstanceWorldBossP