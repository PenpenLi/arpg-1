InstanceMainBase = class("InstanceMainBase", Instance_base)

InstanceMainBase.Name = "InstanceMainBase"

function InstanceMainBase:ctor(  )
	
end

--��ʼ���ű�����
function InstanceMainBase:OnInitScript(  )
	Instance_base.OnInitScript(self) --���û���
end

--����Ҽ���󴥷�
function InstanceMainBase:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- �����޸�ģʽ
	playerInfo:ChangeToPeaceModeAfterTeleport()
end