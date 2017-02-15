InstanceKuafu3v3 = class("InstanceKuafu3v3", InstanceInstBase)

InstanceKuafu3v3.Name = "InstanceKuafu3v3"
InstanceKuafu3v3.exit_time = 10
InstanceKuafu3v3.player_auto_respan = 1000
InstanceKuafu3v3.Time_Out_Fail_Callback = "timeoutCallback"

function InstanceKuafu3v3:ctor(  )
	
end

--��ʼ���ű�����
function InstanceKuafu3v3:OnInitScript()
	InstanceInstBase.OnInitScript(self) --���û���
	
	-- ����������ʱ��
	local timestamp = os.time() + 120
	
	self:SetMapQuestEndTime(timestamp)
	-- ����ʱ�䳬ʱ�ص�
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- ����ʧ���˳�
function InstanceInstBase:timeoutCallback()
	self:SetMapState(self.STATE_FAIL)
	return false
end

--������״̬�����仯ʱ�䴥��
function InstanceKuafu3v3:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s���������
		local timestamp = os.time() + InstanceKuafu3v3.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- �ж��Ƿ����˳�����
function InstanceKuafu3v3:DoPlayerExitInstance(player)
	return 1	--����1�Ļ�Ϊ�����˳�������0�����˳�
end

--��Ҽ����ͼ
function InstanceKuafu3v3:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--�����˻�������ֱ�ӵ���ȥ
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
end

--����Ҽ���󴥷�
function InstanceKuafu3v3:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

function InstanceKuafu3v3:DoIsFriendly(killer_ptr, target_ptr)
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	local targetInfo = UnitInfo:new{ptr = target_ptr}
	
	ret = killerInfo:GetVirtualCamp() == targetInfo:GetVirtualCamp()
	
	if ret then
		return 1
	end
	return 0
end

--����������󴥷�()
function InstanceKuafu3v3:OnPlayerDeath(player)
	-- ���״̬�Ѿ��ı�, ��ʹ����Ҳ���ٸ���ʱ��
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	self:SetMapState(self.STATE_FAIL)
end

--������뿪ʱ����
function InstanceKuafu3v3:OnLeavePlayer( player, is_offline)
	
end

return InstanceKuafu3v3