InstanceWorldBossP = class("InstanceWorldBossP", Instance_base)

InstanceWorldBossP.Name = "InstanceWorldBossP"


function InstanceWorldBossP:ctor(  )
	
end

--��Ҽ����ͼ
function InstanceWorldBossP:OnJoinPlayer(player)
	InstanceInstBase.OnJoinPlayer(self, player)
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

return InstanceWorldBossP