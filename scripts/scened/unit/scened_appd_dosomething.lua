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
	if ntype == APPD_SCENED_RESPAWN then
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