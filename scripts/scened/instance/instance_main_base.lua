InstanceMainBase = class("InstanceMainBase", Instance_base)

function InstanceMainBase:ctor(  )
	
end

--��ʼ���ű�����
function InstanceMainBase:OnInitScript(  )
	Instance_base.OnInitScript(self) --���û���
end

--����Ҽ���󴥷�
function InstanceMainBase:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- �����޸�ģʽ
	playerInfo:ChangeToPeaceModeAfterTeleport()
end