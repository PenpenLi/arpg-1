InstanceRemind0 = class("InstanceRemind0", InstanceInstBase)

InstanceRemind0.Name = "InstanceRemind0"

function InstanceRemind0:ctor(  )
	
end

--��ʼ���ű�����
function InstanceRemind0:OnInitScript(  )
	InstanceInstBase.OnInitScript(self) --���û���
	
	if self:GetMapQuestEndTime() > 0 then
		return
	end
	
	self:parseGeneralId()
	
	self:SetMapEndTime(os.time() + 60)
end

function InstanceRemind0:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local params = string.split(generalId, '|')
	
	local prevMapId = tonumber(params[ 3 ])
	local entry		= tonumber(params[ 4 ])
	local bornX		= tonumber(params[ 5 ])
	local bornY		= tonumber(params[ 6 ])
	local lineNo	= tonumber(params[ 7 ])
	self:SetUInt32(MAP_INT_FIELD_RESERVE1, prevMapId)
	self:SetUInt32(MAP_INT_FIELD_RESERVE2, lineNo)
	
	local config	= tb_creature_template[entry]
	local creature = mapLib.AddCreature(self.ptr, {
			templateid = entry, x = bornX, y = bornY, 
			active_grid = true, alias_name = config.name, ainame = 'AI_RemindBoss0', npcflag = {}
		}
	)
end

--������״̬�����仯ʱ�䴥��
function InstanceRemind0:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s���������
		local timestamp = os.time()
		self:SetMapEndTime(timestamp)
		
		-- ֱ�Ӵ���ȥ
		local allPlayers = mapLib.GetAllPlayer(self.ptr)
		local player_ptr = allPlayers[ 1 ]
		local prevMapId = self:GetUInt32(MAP_INT_FIELD_RESERVE1)
		local lineNo = self:GetUInt32(MAP_INT_FIELD_RESERVE2)
		local toX, toY = unitLib.GetPos(player_ptr)
		playerLib.Teleport(player_ptr, prevMapId, toX, toY, lineNo)
	end
end

--��Ҽ����ͼ
function InstanceRemind0:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--�����˻�������ֱ�ӵ���ȥ
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
end

--����������󴥷�()
function InstanceRemind0:OnPlayerDeath(player)
	-- ���״̬�Ѿ��ı�, ��ʹ����Ҳ���ٸ���ʱ��
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	
	-- ������
	unitLib.Respawn(player, RESURRPCTION_HUANHUNDAN, 100)	--ԭ�ظ���
	
	-- ����״̬
	self:SetMapState(self.STATE_FAIL)
end

--������뿪ʱ����
function InstanceRemind0:OnLeavePlayer( player, is_offline)
	self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
	self:RemoveTimeOutCallback(self.Leave_Callback)
	-- Ϊ�˴�����Ϸˢ��(��֪����ô�˳������)
	if self:GetMapState() == self.STATE_START then
		self:SetMapState(self.STATE_FAIL)
	end
end

-------------------------------- BOSS
AI_RemindBoss0 = class("AI_RemindBoss0", AI_Base)
AI_RemindBoss0.ainame = "AI_RemindBoss0"
--����
function AI_RemindBoss0:JustDied( map_ptr,owner,killer_ptr )	
	
	local instanceInfo = InstanceRemind0:new{ptr = map_ptr}
	
	-- ���ʱ�䵽��ʧ���� ��ʹ�����ɱ��BOSS��û��
	if instanceInfo:GetMapState() ~= instanceInfo.STATE_START then
		return
	end
	
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	instanceInfo:SetMapState(instanceInfo.STATE_FINISH)
	
	return 0
end

return InstanceRemind0