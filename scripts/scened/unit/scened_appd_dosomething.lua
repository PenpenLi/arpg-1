local protocols = require('share.protocols')


function DoScenedDoSomething(unit, ntype, data, str)
	-- �����Ҫ����
	if unit then
		local unitInfo = UnitInfo:new {ptr = unit}
		unitInfo:DoGetAppdDoSomething(ntype, data, str)
	else
		-- ��������Ҫ���� (����ˢҰ��BOSSʲô��)
		DoScenedAppGetAppdDoSomething( ntype, data, str)
	end
end

-- Ӧ�÷�֪ͨ��������Щʲô
function UnitInfo:DoGetAppdDoSomething( ntype, data, str)
	if ntype == APPD_SCENED_SWEEP_TRIAL_INSTANCE then
		self:sweepTrial(data)
	elseif ntype == APPD_SCENED_SWEEP_VIP_INSTANCE then
		self:sweepVIP(data, tonumber(str))
	elseif ntype == APPD_SCENED_RESPAWN then
		self:sceneGoldRespawn(data)
	elseif ntype == APPD_SCENED_NEAR_BY_CHAT then
		self:chatNearBy(str)
	elseif ntype == APPD_SCENED_ADD_EXP then
		self:AddExp(data)
	elseif ntype == APPD_SCENED_WORLD_BOSS_WAITING then
		self:ToWaitingRoom()
	elseif ntype == APPD_SCENED_WORLD_BOSS_ENTER then
		self:ToWorldBossRoom(data)
	end
end

-- vip����ɨ��
function UnitInfo:sweepVIP(id, hard)
	hard = tonumber(hard)
	local dict = {}
	local dropIdTable = tb_map_vip[id].rewards[hard]
	
	for _, dropId in pairs(dropIdTable) do
		DoRandomDrop(dropId, dict)
	end
	
	PlayerAddRewards(self.ptr, dict, MONEY_CHANGE_VIP_INSTANCE_REWARD, LOG_ITEM_OPER_TYPE_VIP_INSTANCE_REWARD)
	
	-- ɨ���Ľ������
	local list = self:Change_To_Item_Reward_Info(dict)
	
	protocols.call_sweep_instance_reward ( self, INSTANCE_SUB_TYPE_VIP, id, hard, 0, list)
end

function UnitInfo:Change_To_Item_Reward_Info(dict)
	-- ɨ���Ľ������
	local list = {}
	for item_id, num in pairs(dict) do
		local stru = item_reward_info_t .new()
		stru.item_id	= item_id
		stru.num 		= num
		table.insert(list, stru)
	end
	
	return list
end


---------------------------ɨ��������
function UnitInfo:sweepTrial(id)
	local dict = {}
	
	for i = 1, id do
		local dropIdTable = tb_map_trial[ i ].reward
			
		for _, dropId in pairs(dropIdTable) do
			DoRandomDrop(dropId, dict)
		end
	end
	
	PlayerAddRewards(self.ptr, dict, MONEY_CHANGE_TRIAL_INSTANCE_REWARD, LOG_ITEM_OPER_TYPE_TRIAL_INSTANCE_REWARD)
	
	-- ɨ���Ľ������
	local list = self:Change_To_Item_Reward_Info(dict)
	
	protocols.call_sweep_instance_reward ( self, INSTANCE_SUB_TYPE_TRIAL, 0, 0, 0, list)
end

-- ������Ԫ������
function UnitInfo:sceneGoldRespawn(itemId)
	ScenedUseItem[itemId](ScenedUseItem, self, itemId, 1)
end


-- ��������
function UnitInfo:chatNearBy(content)
	-- ��ѯ��Ұ��Χ�ڵ����
	local allPlayers = playerLib.GetAllPlayerNearBy(self.ptr)
	for _, player in pairs(allPlayers) do
		local playerInfo = UnitInfo:new {ptr = player}
		if not playerInfo:isDeclineNearMsg() then
			playerInfo:call_send_chat (CHAT_TYPE_CURRENT ,self:GetPlayerGuid() ,0 ,self:GetName() ,self:GetVIP() ,0 ,self:GetLevel() ,self:GetGender() ,content, "")
		end
	end
end

-- �Ӿ���
function UnitInfo:AddExp(exp)
	playerLib.AddExp(self.ptr, exp)
end

-- ���͵��ȴ�����
function UnitInfo:ToWaitingRoom()
	-- ������ڵȴ���ͼ �ʹ���
	local config  = tb_worldboss_waitroom[ 1 ]
	local toMapId = config.mapid
	local toX = randInt(config.rect[ 1 ], config.rect[ 3 ])
	local toY = randInt(config.rect[ 2 ], config.rect[ 4 ])
	playerLib.Teleport(self.ptr, toMapId, toX, toY, 0, "")
end

-- ���͵�����BOSS����
function UnitInfo:ToWorldBossRoom(line)
	local indx = globalValue:GetTodayWorldBossID()
	print("ToWorldBossRoom", indx)
	local config = tb_worldboss_base[indx]
	local toMapId = config.mapid
	local toX = randInt(config.rect[ 1 ], config.rect[ 3 ])
	local toY = randInt(config.rect[ 2 ], config.rect[ 4 ])
	self:SetLastLine(line)
	
	outFmtDebug("ToWorldBossRoom playerguid = %s, line = %d", self:GetPlayerGuid(), line)
	
	playerLib.Teleport(self.ptr, toMapId, toX, toY, line, "")
end

----------------------------------------��������Ҫ����-----------------------------------------------
function DoScenedAppGetAppdDoSomething( ntype, data, str)
	-- ����������Ұ��BOSS
	if ntype == APPD_SCENED_CLEAR_FIELD_BOSS then
		OnClearFieldBoss()
	-- ������ˢ��Ұ��
	elseif ntype == APPD_SCENED_REBORN_FIELD_BOSS then
		OnRebornFieldBoss()
	elseif ntype == APPD_SCENED_FIGHT_WORLD_BOSS then
		OnFightWorldBoss(data)
	elseif ntype == APPD_SCENED_WORLD_BOSS_END then
		OnWorldBossEnd()
	end
end

-- ȫ�ֱ�������Ұ��BOSS
function OnClearFieldBoss()
	outFmtInfo("====================== OnClearFieldBoss")
	for mapid, _ in pairs(tb_map_field_boss) do
		for lineNo = 1, MAX_DEFAULT_LINE_COUNT do
			globalValue:ResetFieldBoss(mapid, lineNo)
		end
	end
end

-- ȫ�ֱ���ˢ��Ұ��BOSS
function OnRebornFieldBoss()
	outFmtInfo("******************** OnRebornFieldBoss")
	for mapid, _ in pairs(tb_map_field_boss) do
		for lineNo = 1, MAX_DEFAULT_LINE_COUNT do
			globalValue:BornFieldBoss(mapid, lineNo)
		end
	end
end

-- ����ս������
function OnFightWorldBoss(rooms)
	-- ����ս���ȴ�״̬
	globalValue:SetWorldBossState(WORLD_BOSS_PROCESS_BORN)
	-- ÿ���������ÿ�
	globalValue:UnSetWorldBossEndInLine()
	-- ��������BOSS����
	ClearWorldBossData(1)
	-- ���÷�����
	globalValue:SetTodayWorldBossRoom(rooms)
end

-- ����BOSS����
function OnWorldBossEnd()
	globalValue:SetWorldBossState(WORLD_BOSS_PROCESS_TYPE_FINISH)
	-- ÿ���������ÿ�
	globalValue:UnSetWorldBossEndInLine()
	--------------------------- �����Ժ�Ĵ���--------------------------
	-- BOSS�Ƿ�����
	DoIfBOSSLevelUp()
	-- �����Ƿ���Ҫ������һ�׶ε�BOSS
	globalValue:RandomWorldBossIfNextStep()
	-- ��������BOSS����
	ClearWorldBossData()
end