InstanceVIP = class("InstanceVIP", InstanceInstBase)

InstanceVIP.Name = "InstanceVIP"
InstanceVIP.player_auto_respan = 120

function InstanceVIP:ctor(  )
	
end

--��ʼ���ű�����
function InstanceVIP:OnInitScript(  )
	InstanceInstBase.OnInitScript(self) --���û���
	
	local mapId = self:GetMapId()
	
	self:SetMapEndTime(os.time() + tb_map_vip[mapId].time)	--2���Ӻ����
end

--������״̬�����仯ʱ�䴥��
function InstanceVIP:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		--10s���������
		self:SetMapEndTime(os.time() + 10)
	end
end

--��Ҽ����ͼ
function InstanceVIP:OnJoinPlayer(player)
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--�����˻�������ֱ�ӵ���ȥ
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		self:SetMapState(self.STATE_FAIL)
	end
	
	-- ˢ��BOSS
	local teleId = playerLib.GetTeleportID(player)
	local hard   = tonumber(teleId) + 1
	local mapId  = self:GetMapId()
	local entry  = tb_map_vip[mapId].creatures[hard]
	
	self:OnRefreshBoss(entry)
end

--ˢ��
function InstanceVIP:OnRefreshBoss(entry)
	local config = tb_creature_template[entry]
	local mapId  = self:GetMapId()
	local bornX = tb_map_vip[mapId].bossx
	local bornY = tb_map_vip[mapId].bossy

	local boss = mapLib.AliasCreature(self.ptr, config.name)
	if not boss then
		mapLib.AddCreature(self.ptr, {
				templateid = entry, x = bornX, y = bornY, 
				active_grid = true, alias_name = config.name, ainame = config.ainame, npcflag = {}
			}
		)
	end
end

--����Ҽ���󴥷�
function InstanceVIP:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

--����������󴥷�()
function InstanceVIP:OnPlayerDeath(player)
	print("player death")
	self:SetMapState(self.STATE_FAIL)
end

--������뿪ʱ����
function InstanceVIP:OnLeavePlayer( player, is_offline)
	self:SetMapEndTime(os.time())
end



-------------------------------- BOSS
AI_meichaofei = class("AI_meichaofei", AI_Base)
AI_meichaofei.ainame = "AI_meichaofei"
--����
function AI_meichaofei:JustDied( map_ptr,owner,killer_ptr )
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	local instanceInfo = InstanceVIP:new{ptr = map_ptr}
	instanceInfo:SetMapState(instanceInfo.STATE_FINISH)
	
	-- �������
	
	
	return 0
end




return InstanceVIP