InstanceDoujiantai = class("InstanceDoujiantai", InstanceInstBase)

InstanceDoujiantai.Name = "InstanceDoujiantai"
InstanceDoujiantai.exit_time = 10

function InstanceDoujiantai:ctor(  )
	
end

--��ʼ���ű�����
function InstanceDoujiantai:OnInitScript()
	InstanceInstBase.OnInitScript(self) --���û���
	
	self:OnTaskStart()
end

-- ���ʽ��ʼ
function InstanceDoujiantai:OnTaskStart()
	local timestamp = os.time() +  tb_doujiantai_base[ 1 ].last + tb_doujiantai_base[ 1 ].cd
	-- ������ʱ��
	self:SetMapQuestEndTime(timestamp)
	-- ����ʱ�䳬ʱ�ص�
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- ����ʧ���˳�
function InstanceDoujiantai:timeoutCallback()
	self:SetMapState(self.STATE_FINISH)
	return false
end

return InstanceDoujiantai