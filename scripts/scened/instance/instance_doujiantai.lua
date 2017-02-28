InstanceDoujiantai = class("InstanceDoujiantai", InstanceInstBase)

InstanceDoujiantai.Name = "InstanceDoujiantai"
InstanceDoujiantai.exit_time = 10

function InstanceDoujiantai:ctor(  )
	
end

--初始化脚本函数
function InstanceDoujiantai:OnInitScript()
	InstanceInstBase.OnInitScript(self) --调用基类
	
	self:OnTaskStart()
end

-- 活动正式开始
function InstanceDoujiantai:OnTaskStart()
	local timestamp = os.time() +  tb_doujiantai_base[ 1 ].last + tb_doujiantai_base[ 1 ].cd
	-- 加任务时间
	self:SetMapQuestEndTime(timestamp)
	-- 副本时间超时回调
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- 副本失败退出
function InstanceDoujiantai:timeoutCallback()
	self:SetMapState(self.STATE_FINISH)
	return false
end

return InstanceDoujiantai