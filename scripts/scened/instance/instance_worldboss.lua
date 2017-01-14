InstanceWorldBoss = class("InstanceWorldBoss", Instance_base)
local protocols = require('share.protocols')

InstanceWorldBoss.Name = "InstanceWorldBoss"
InstanceWorldBoss.player_auto_respan = 5

-- �����ߵ�����
InstanceWorldBoss.rankList = {}

-- �����ȵ�roll�����ֵ�ͻ����, ����ʼʱ��ͽ���ʱ��
InstanceWorldBoss.rollList = {}

-- ����roll���������б�
InstanceWorldBoss.rollNameList = {}

-- BOSS��Ѫ��
InstanceWorldBoss.boss_hp = {}

-- ��������
InstanceWorldBoss.deathList = {}


-- ��ʤ��־ (0:δ����, 1:����ʤ��, 2:����ʧ��)
InstanceWorldBoss.FLAG_WIN = 1
InstanceWorldBoss.FLAG_LOSE = 2

InstanceWorldBoss.WORLD_BOSS_NAME = "WORLD_BOSS"

-- ��������BOSS
function ClearWorldBossData(all)
	all  = all or 0
	InstanceWorldBoss.rankList = {}
	InstanceWorldBoss.boss_hp = {}
	InstanceWorldBoss.deathList = {}
	if all == 1 then
		InstanceWorldBoss.rollList = {}
		InstanceWorldBoss.rollNameList = {}
	end
end

-- �ж�BOSS�Ƿ���Ҫ����
function DoIfBOSSLevelUp()
	print("===========***======***========== WORLD BOSS end")
	
	local num = 0
	local rooms = globalValue:GetTodayWorldBossRoom()
	for i = 1, rooms do
		if globalValue:IsWorldBossEndInLine(i) then
			num = num + 1
		end
	end

	-- BOSS��Ҫ������
	if num * 2 > rooms then
		globalValue:AddWorldBossLevel()
	end
end

-- roll����
function Roll_Treasure(playerInfo)
	-- ����roll���������б�
	-- InstanceWorldBoss.rollNameList = {}
	local map_ptr = unitLib.GetMap(playerInfo.ptr)
	local instanceInfo = InstanceFieldBase:new{ptr = map_ptr}
	local lineNo = instanceInfo:GetMapLineNo()
	-- �ж��Ƿ���roll���ڼ�
	local now = os.time()
	local rollConfig = InstanceWorldBoss.rollList[lineNo]
	if not rollConfig or not (rollConfig[ 3 ] <= now and now <= rollConfig[ 4 ]) then
		outFmtDebug("=================cannot roll")
		return
	end
	
	-- �Ƿ�μ�����
	local id = globalValue:GetWorldBossTimes()
	-- û���й������Ĳ���roll
	if id ~= playerInfo:GetLastJoinID() then
		outFmtDebug("current joinid = %d, but curr = %d", id, playerInfo:GetLastJoinID())
		return
	end
	
	-- �Ƿ��Ѿ�roll��
	if InstanceWorldBoss.rollNameList[lineNo][playerInfo:GetPlayerGuid()] then
		outFmtDebug("=================has already roll")
		return
	end
	
	-- �����Ѿ�roll��־
	InstanceWorldBoss.rollNameList[lineNo][playerInfo:GetPlayerGuid()] = 1
	local gf = randInt(1, 100)
	local isHighest = 0
	if gf > rollConfig[ 1 ] then
		rollConfig[ 1 ] = gf
		rollConfig[ 2 ] = playerInfo:GetPlayerGuid()
		isHighest = 1
	end
	
	NotifyAllRollResult(map_ptr, gf, playerInfo:GetName(), isHighest, rollConfig[ 4 ], rollConfig[ 5 ])
end


function InstanceWorldBoss:ctor(  )
	
end


--��ʼ���ű�����
function InstanceWorldBoss:OnInitScript(  )
	Instance_base.OnInitScript(self) --���û���
	
	mapLib.DelTimer(self.ptr, 'OnTimer_RefreshBoss')
	mapLib.DelTimer(self.ptr, 'OnTimer_UpdateRank')
	-- ˢ��BOSS ��ʱ��
	
	local boss = mapLib.AliasCreature(self.ptr, InstanceWorldBoss.WORLD_BOSS_NAME)
	if not boss then
		mapLib.AddTimer(self.ptr, 'OnTimer_RefreshBoss', config.world_boss_wait * 1000)
		self:SetUInt32(WORLDBOSS_FIELDS_BORN_TIME, config.world_boss_wait)
	end
	
	-- ˢ������ ��ʱ��
	mapLib.AddTimer(self.ptr, 'OnTimer_UpdateRank', 1000)
	
	-- �����ܽ���ʱ��
	self:SetMapEndTime(os.time() + tb_worldboss_time[ 1 ].time_last * 60)
end

-- ����BOSS������
function InstanceWorldBoss:IsEnd()
	local lineNo = self:GetMapLineNo()
	return globalValue:IsWorldBossEnd() or globalValue:IsWorldBossEndInLine(lineNo)
end

-- ˢ��BOSS
function InstanceWorldBoss:OnTimer_RefreshBoss()

	if globalValue:IsWorldBossBorn() then
		-- ˢBOSS		
		local boss = mapLib.AliasCreature(self.ptr, InstanceWorldBoss.WORLD_BOSS_NAME)
		if not boss then
			local indx   = globalValue:GetTodayWorldBossID()
			local wbconfig = tb_worldboss_base[indx]
			local entry  = wbconfig.entry
			local born   = wbconfig.born
		
			local config = tb_creature_template[entry]
			local creature = mapLib.AddCreature(self.ptr, {
					templateid = entry, x = born[ 1 ], y = born[ 2 ], active_grid = true, 
					alias_name = InstanceWorldBoss.WORLD_BOSS_NAME, ainame = config.ainame, npcflag = {}
				}
			)
			
			if creature then
				local creatureInfo = UnitInfo:new{ptr = creature}
				-- ��ʶΪboss��
				creatureInfo:SetUnitFlags(UNIT_FIELD_FLAGS_IS_FIELD_BOSS_CREATURE)
			end
		end
	end

	return false
end

-- ��ʼ��������Ϣ
function InstanceWorldBoss:InitCreatureInfo(creature_ptr, bRecal, mul)
	local level = globalValue:GetWorldBossLevel()
	mul = 1 + level * 0.2
	Instance_base.InitCreatureInfo(self, creature_ptr, bRecal, mul)
end

-- ������������
function InstanceWorldBoss:OnTimer_UpdateRank()
	-- ��������
	local lineNo = self:GetMapLineNo()
	local rankInfo = InstanceWorldBoss.rankList[lineNo]
	local maxHP = InstanceWorldBoss.boss_hp[lineNo]
	
	local rankList = {}
	if not rankInfo then
		rankInfo = {}
	end
	
	local len = math.min(#rankInfo, 10)
	for i = 1, len do
		local stru = rank_info_t .new()
		stru.name = rankInfo[ i ][ 1 ]
		stru.value = rankInfo[ i ][ 2 ] * 100 / maxHP
		table.insert(rankList, stru)
	end
	
	NotifyAllRankUpdate(self.ptr, rankInfo, rankList)
	
	-- ����BOSS����
	if self:IsEnd() then
		InstanceWorldBoss.rankList[lineNo] = {}
		-- ������ǰ����ʱ��
		-- self:SetMapEndTime(os.time() + 20)
		return false
	end
	
	return true
end

function InstanceWorldBoss:DoIsFriendly(killer_ptr, target_ptr)	
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	local targetInfo = UnitInfo:new{ptr = target_ptr}
	
	-- ���ж�
	local ret = true
	if killerInfo:GetTypeID() == TYPEID_PLAYER then
		-- �Է����ǹ���������޵�
		ret = targetInfo:GetTypeID() ~= TYPEID_UNIT or unitLib.HasBuff(target_ptr, BUFF_INVINCIBLE)
	elseif killerInfo:GetTypeID() == TYPEID_UNIT then
		-- �Լ��޵�����²��ܴ����
		ret = unitLib.HasBuff(killer_ptr, BUFF_INVINCIBLE)
	end
	
	if ret then
		return 1
	end
	return 0
end

function NotifyAllRankUpdate(map_ptr, rankInfo, rankList)
	local allPlayers = mapLib.GetAllPlayer(map_ptr)
	local tmp = {}
	for i = 1, #rankInfo do
		tmp[rankInfo[ i ][ 1 ]] = i
	end
		
	for _, player in pairs(allPlayers) do
		local unitInfo = UnitInfo:new {ptr = player}
		local mine = tmp[unitInfo:GetName()]
		mine = mine or 0
		unitInfo:call_world_boss_rank(rankList, mine)
	end
end

--��Ҽ����ͼ
function InstanceWorldBoss:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--�����˻�������ֱ�ӵ���ȥ
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
		mapLib.ExitInstance(self.ptr, player)
		return
	end
	
	-- ����ʱ�䵽�Ͳ��ý���
	if os.time() >= self:GetMapEndTime() or self:IsEnd() then
		mapLib.ExitInstance(self.ptr, player)
		return
	end
end

--����Ҽ���󴥷�
function InstanceWorldBoss:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- �����޸�ģʽ
	playerInfo:ChangeToPeaceModeAfterTeleport()
end

-- ��õ��˵ĸ���ʱ��
function InstanceWorldBoss:GetSingleRespawnTime(player)
	local lineNo = self:GetMapLineNo()
	local playerInfo = UnitInfo:new{ptr = player}
	if not InstanceWorldBoss.deathList[lineNo] then
		InstanceWorldBoss.deathList[lineNo] = {}
	end
	local cnt = InstanceWorldBoss.deathList[lineNo][playerInfo:GetPlayerGuid()]
	cnt = cnt or 0
	return self.player_auto_respan + cnt * 3
end

-- �����������
function InstanceWorldBoss:OnPlayerDeath(player)
	
	local lineNo = self:GetMapLineNo()
	if not InstanceWorldBoss.deathList[lineNo] then
		InstanceWorldBoss.deathList[lineNo] = {}
	end
	
	local playerInfo = UnitInfo:new{ptr = player}
	local prev = InstanceWorldBoss.deathList[lineNo][playerInfo:GetPlayerGuid()]
	prev = prev or 0
	InstanceWorldBoss.deathList[lineNo][playerInfo:GetPlayerGuid()] = prev + 1
end


--AI_WorldBoss
-------------------------����boss---------------------------
AI_WorldBoss = class("AI_WorldBoss", AI_Base)
AI_WorldBoss.ainame = "AI_WorldBoss"

--����
function AI_WorldBoss:JustDied( map_ptr,owner,killer_ptr )
	outFmtInfo("============================ world BOSS was dead")
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	local instanceInfo = InstanceFieldBase:new{ptr = map_ptr}
	local mapid  = instanceInfo:GetMapId()
	local lineNo = instanceInfo:GetMapLineNo()
	
	-- ����״̬
	globalValue:SetWorldBossEndInLine(lineNo)
	instanceInfo:SetMapEndTime(os.time() + 12)
	
	-- �������� ���ʼ�
	local rankInfo = InstanceWorldBoss.rankList[lineNo]
	local indx = 1
	for i = 1, #rankInfo do
		local to = tb_worldboss_rank_reward[ indx ].id2
		-- ������������������
		if to > 0 and to < i then
			indx = indx + 1
		end 
		
		to = tb_worldboss_rank_reward[ indx ].id2
		if i <= to then
			local playerGuid = rankInfo[ i ][ 3 ]
			--����Ӧ�÷�������
			local player = mapLib.GetPlayerByPlayerGuid(map_ptr, playerGuid)
			local mailEntry = GetMailEntryId(GIFT_PACKS_TYPE_WORLD_BOSS, i)
			playerLib.SendToAppdDoSomething(player, SCENED_APPD_ADD_MAIL, mailEntry, tb_worldboss_rank_reward[ indx ].reward)
		end 
	end
	
	return 0
end

-- �˺�����ǰ
function AI_WorldBoss:DamageTaken(owner, unit, damage)
	local bossInfo = UnitInfo:new{ptr = owner}
	local map_ptr = unitLib.GetMap(owner)
	local instanceInfo = InstanceWorldBoss:new{ptr = map_ptr}
	local mapid  = instanceInfo:GetMapId()
	local lineNo = instanceInfo:GetMapLineNo()
	
	if damage <= 0 then
		return
	end
	
	local prev = bossInfo:GetHealth()
	local maxHealth  = bossInfo:GetMaxhealth()
	if damage > prev then
		damage = prev
	end
	
	currHealth = prev - damage
	
	if prev == 0 then
		return
	end
	
	local unitInfo = UnitInfo:new {ptr = unit}
	
	-- ����BOSS���Ѫ��
	InstanceWorldBoss.boss_hp[lineNo] = maxHealth
	
	-- ��������
	AddWorldBossDamage(lineNo, unitInfo:GetPlayerGuid(), unitInfo:GetName(), damage)
	
	-- �����Ƿ���Ҫ����roll��	
	local prev = currHealth + damage
	local rollId = -1
	for i = 1, #tb_worldboss_roll do
		local hprate = tb_worldboss_roll[ i ].hprate
		if prev  * 100 > maxHealth * hprate and currHealth * 100 <= maxHealth * hprate then
			rollId = i
			break
		end
	end

	-- ��Ҫroll��
	if rollId > 0 then
		-- δ���� ���޵�buff
		if currHealth > 0 then
			unitLib.AddBuff(owner, BUFF_INVINCIBLE, owner, 1, config.world_boss_invincible_time)
			-- ֪ͨ�����޵�ģʽ
		end
		
		-- ׼��roll��
		instanceInfo:PrepareToRoll(rollId)
	end
	
end

-- �ܵ��˺���
function AI_WorldBoss:DamageDeal( owner, unit, damage)
	local map_ptr = unitLib.GetMap(owner)
	local instanceInfo = InstanceWorldBoss:new{ptr = map_ptr}
	local lineNo = instanceInfo:GetMapLineNo()
	
	if damage < 0 then
		InstanceWorldBoss.rankList[lineNo] = {}
		return
	end
end


function NotifyAllRollResult(map_ptr, point, name, isHighest, cd, rollid)
	local allPlayers = mapLib.GetAllPlayer(map_ptr)
	for _, player in pairs(allPlayers) do
		local unitInfo = UnitInfo:new {ptr = player}
		unitInfo:call_roll_result(point, name, isHighest, cd, rollid)
	end
end

-- ׼��roll��
function InstanceWorldBoss:PrepareToRoll(rollId)
	mapLib.AddTimer(self.ptr, 'OnTimer_RollStart', 1000, rollId)
end

-- roll��ʾ��ʼ
function InstanceWorldBoss:OnTimer_RollStart(rollId)
	
	local lineNo = self:GetMapLineNo()
	
	InstanceWorldBoss.rollList[lineNo] = {0, "", os.time(), os.time() + config.world_boss_roll_last_time, rollId}
	InstanceWorldBoss.rollNameList[lineNo] = {}
	
	mapLib.AddTimer(self.ptr, 'OnTimer_Roll', config.world_boss_roll_last_time * 1000, rollId)
	-- ֪ͨ�������������roll��
	NotifyAllRollResult(self.ptr, 0, "", 0, os.time() + config.world_boss_roll_last_time, rollId)
	
	return false
end

-- roll��ʱ�����
function InstanceWorldBoss:OnTimer_Roll(rollId)
	local lineNo = self:GetMapLineNo()
	local playerGuid = InstanceWorldBoss.rollList[lineNo][ 2 ]
	-- û����roll��
	if playerGuid == "" then
		return false
	end
	local player = mapLib.GetPlayerByPlayerGuid(self.ptr, playerGuid)
	local itemId = tb_worldboss_roll[rollId].itemid
	
	PlayerAddRewards(player, {[itemId] = 1}, MONEY_CHANGE_WORLD_BOSS_ROLL, LOG_ITEM_OPER_TYPE_WORLD_BOSS_ROLL)
	
	local reason = WORLD_BOSS_OPERTE_WILL_ROLL1
	if rollId == #tb_worldboss_roll then
		reason = WORLD_BOSS_OPERTE_WILL_ROLL2
	end
	local playerInfo = UnitInfo:new {ptr = player}
	local playerName = ToShowName(playerInfo:GetName())
	app:CallOptResult(self.ptr, OPERTE_TYPE_WORLD_BOSS, reason, {playerName})
	
	return false
end

function AddWorldBossDamage(lineNo, playerGuid, name, damage)
	if not InstanceWorldBoss.rankList[lineNo] then
		InstanceWorldBoss.rankList[lineNo] = {}
	end
	local rankInfo = InstanceWorldBoss.rankList[lineNo]
	local indx = #rankInfo + 1
	
	for i = 1, #rankInfo do
		local dataInfo = rankInfo[ i ]
		if dataInfo[ 1 ] == name then
			dataInfo[ 2 ] = dataInfo[ 2 ] + damage
			indx = i
			break
		end
	end
	
	if indx == #rankInfo + 1 then
		table.insert(rankInfo, {name, damage, playerGuid})
	end
	
	RankSort(rankInfo, indx)
end

-- ��������
function RankSort(rankInfo, indx)
	for i = indx, 2, -1 do
		local curr = rankInfo[ i ]
		local prev = rankInfo[i-1]
		if curr[ 2 ] > prev[ 2 ] then
			rankInfo[ i ] = prev
			rankInfo[i-1] = curr
		end
	end
end

return InstanceWorldBoss