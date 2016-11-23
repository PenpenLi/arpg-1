local Packet = require 'util.packet'


-------------------------------------------------����-------------------------------------------------------------

BASE_SKILL = 1				--��������
MOUNT_SKILL = 1				--���＼��

-- ��������(����)����
function PlayerInfo:Handle_Raise_BaseSpell(pkt)
	
	local spellId  = pkt.spellId
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- �жϼ����Ƿ����
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- �ж�����Ƿ�ӵ���������
	if not self:hasSpell(spellId) then
		outFmtError("player has no spellId %d", spellId)
		return
	end
	
	-- �ж��Ƿ�������
	if self:isTopLevel(spellId) then
		outFmtError("spellId %d is in topLevel", spellId)
		return
	end
	
	-- �ж��Ƿ��ǻ���(ŭ��)����
	if not self:isBaseSkill(spellId) and not self:isAngerSpell(spellId) then
		outFmtError("spellId %d is cannot do in this way", spellId)
		return
	end
	
	-- �ж�����ȼ�
	local index = spellMgr:getSpellUpgradeIndex(spellId)
	local upLevelConfig = tb_skill_uplevel[index]
	if not self:checkPlayerLevel(upLevelConfig.need_level) then
		outFmtError("spellId %d, player level not enough, need level = %d", spellId, upLevelConfig.need_level)
		return
	end
	
	-- �ж����ĵ���
	if #upLevelConfig.uplevel_item > 0 then
		if not self:hasMulItem(upLevelConfig.uplevel_item) then
			outFmtError("item not enough")
			return
		end
	end
	
	-- �ж�������Դ
	if #upLevelConfig.uplevel_cost > 0 then
		if not self:checkMoneyEnoughs(upLevelConfig.uplevel_cost) then
			outFmtError("resouce not enough")
			return
		end
	end
	
	-- �۳�����
	if #upLevelConfig.uplevel_item > 0 then
		if not self:useMulItem(upLevelConfig.uplevel_item) then
			outFmtError("use item fail")
			return
		end
	end
	
	-- �۳���Դ
	if #upLevelConfig.uplevel_cost > 0 then
		if not self:costMoneys(MONEY_CHANGE_UP_ASSISTSPELL, upLevelConfig.uplevel_cost) then
			outFmtError("sub resouce fail")
			return
		end
	end
	
	local prev = spellMgr:getSpellLevel(spellId)
	spellMgr:raiseBaseSpell(spellId)
	local spellLv = spellMgr:getSpellLevel(spellId)
	local spellTable = {}
	
	-- �ڼ��ܲ۵��޸ļ��ܲ�����(ŭ������Ҳ����������)
	if self:isInitiativeSpell(config.is_initiative) or self:isAngerSpell(spellId) then
		--ͬ���������ܵ�p����
		if self:isSloted(spellId) then
			local slot = config.skill_slot
			self:replace(slot, spellId, spellLv)
			table.insert(spellTable, {spellId, spellLv})
			
			-- ���������
			local arry = tb_skill_base[spellId].follow
			for _, id in pairs(arry) do
				self:replace(slot, id, spellLv)
				table.insert(spellTable, {id, spellLv})
			end
		end
	elseif self:isPassiveSpell(config.is_initiative) then
		--ͬ���������ܵ�p������
		self:updatePassive(spellId, spellLv)
		table.insert(spellTable, {spellId, spellLv})
	elseif self:isSupportSpell(config.is_initiative) then
		playerLib.SetSpellLevel(self.ptr, spellId, spellLv)
	end
	
	-- �Ƿ��ͳ�����
	self:sendSpellInfoIfEnabled(config.is_initiative, spellTable)
	
	outFmtInfo("raise spell %d success, from %d to %d", spellId, prev, spellLv)
end

-- ŭ�����ܽ���
function PlayerInfo:Handle_Upgrade_AngleSpell(pkt)
	
	local spellId  = pkt.spellId
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- �жϼ����Ƿ����
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- �ж�����Ƿ�ӵ���������
	if not self:hasSpell(spellId) then
		outFmtError("player has no spellId %d", spellId)
		return
	end
	
	-- �ж��Ƿ�������
	if not self:isTopLevel(spellId) then
		outFmtError("spellId %d is not in topLevel, cannot upgrade", spellId)
		return
	end
	
	-- �ж��Ƿ���ŭ������
	if not self:isAngerSpell(spellId) then
		outFmtError("spellId %d is not anger spell", spellId)
		return
	end
	
	-- �жϽ���Ƿ����
	local upgradeConfig = tb_assistangerspell_upgrade[spellId]
	local cost = upgradeConfig.cost
	if not self:checkMoneyEnough(MONEY_TYPE_SILVER, cost) then
		outFmtError("resouce %d not enough", MONEY_TYPE_SILVER)
		return
	end
	
	-- ���Ľ��
	self:SubMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_SPELL_UP, cost)

	local nextId = upgradeConfig.nextid
	--ͬ���������ܵ�p����
	local slot = config.skill_slot
	
	--�����
	spellMgr:activeBaseSpell(nextId)
	
	self:replace(slot, nextId, 1)
	
	--���͵��������滻����������Ϣ
	self:Send2ScenedReplaceEquipedSpell(slot, nextId, 1)
	
	outFmtInfo("upgrade spell success, from %d to %d", spellId, nextId)
end

-- �����ܷ񼤻�
function PlayerInfo:activeBaseSpell(spellId, activeType)
	
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- �жϼ����Ƿ����
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- �ж�����Ƿ�ӵ���������
	if self:hasSpell(spellId) then
		outFmtError("player has exist spellId %d", spellId)
		return
	end
	
	-- �ȼ��Ƿ���������
	local learnConfig = tb_learn_spell[spellId]
	if learnConfig == nil then
		outFmtError("spellId %d not in tb_learn_spell", spellId)
		return
	end 
	
	if activeType ~= SPELL_ACTIVE_BY_LEVEL and not self:checkPlayerLevel(learnConfig.playerLevel) then
		outFmtError("activeBaseSpell spellId %d, player level not enough, need level %d", spellId, learnConfig.playerLevel)
		return
	end
	
	-- �ж����ĵ���
	if #learnConfig.item > 0 then
		outFmtError("no way to cost item")
		return
	end

	-- �����
	spellMgr:activeBaseSpell(spellId)
	
	self:onActiveSpell(spellId)
end

-- �ж�����ȼ��Ƿ���������
function PlayerInfo:checkPlayerLevel(needLevel)
	local level = self:GetLevel()
	return level >= needLevel
end

-- �Ƿ�����������
function PlayerInfo:isInitiativeSpell(initiative)
	return initiative >= SPELL_INITIATIVE_DAMAGE and initiative <= SPELL_INITIATIVE_BUFF
end

-- �Ƿ��Ǳ�������
function PlayerInfo:isPassiveSpell(initiative)
	return initiative >= SPELL_PASSIVE_DAMAGE and initiative <= SPELL_PASSIVE_BUFF
end

-- �Ƿ��Ǹ�������
function PlayerInfo:isSupportSpell(initiative)
	return initiative == SPELL_SUPPORT
end

-- �����
function PlayerInfo:onActiveSpell(spellId)
	local config   = tb_skill_base[spellId]
	
	-- �������������
	if self:isInitiativeSpell(config.is_initiative) then
		local config = tb_skill_base[spellId]
		local slot = config.skill_slot
		if not self:hasSkillBySlot(slot) then
			-- ͬ���������ܵ�p����
			self:replace(slot, spellId, 1)
			--���͵��������滻����������Ϣ
			self:Send2ScenedReplaceEquipedSpell(slot, spellId, 1)
		else
			playerLib.SetSpellLevel(self.ptr, spellId, 1)
		end
		outFmtInfo("on active spell %d", spellId)
		return
	end
	
	self:onActiveSpellWithoutInitiative(spellId)
end


function PlayerInfo:onActiveSpellWithoutInitiative(spellId)
	local config   = tb_skill_base[spellId]
	outFmtInfo("on active spell %d", spellId)
	
	-- �������ܷ��ͳ�����
	if self:isPassiveSpell(config.is_initiative) then
		--ͬ����p������
		self:updatePassive(spellId, 1)
		local spellTable = {}
		table.insert(spellTable, {spellId, 1})
		-- ���͵����������±���������Ϣ
		self:sendSpellInfoIfEnabled(config.is_initiative, spellTable)
		
		return
	end
	
	-- ��������
	if self:isSupportSpell(config.is_initiative) then
		playerLib.AddSupportSpell(self.ptr, spellId)
		
		return
	end
end

-- �����Ƿ����
function PlayerInfo:isSpellExist(spellId)
	return tb_skill_base[spellId] ~= nil
end

-- �Ƿ���ŭ������
function PlayerInfo:isAngerSpell(spellId)
	return tb_skill_base[spellId].skill_slot == SLOT_ANGER
end

-- �Ƿ��ǻ�������
function PlayerInfo:isBaseSkill(spellId)
	return tb_skill_base[spellId].skill_type == BASE_SKILL
end

-- �Ƿ�ﵽ����
function PlayerInfo:isTopLevel(spellId)
	local spellMgr = self:getSpellMgr()
	local spellLv  = self:GetSpellLevel(spellId)
	local topLevel = spellMgr:getSpellTopLevel(spellId)
	
	return spellLv == topLevel
end

-- �Ƿ�ӵ���������
function PlayerInfo:hasSpell(spellId)
	local spellLv = self:GetSpellLevel(spellId)
	return spellLv > 0
end

-- ���ܵȼ�
function PlayerInfo:GetSpellLevel(spellId)
	local spellLv = playerLib.GetSpellLevel(self.ptr, spellId)
	return spellLv
end

--[[
-- TODO: (�Ժ���� ��ʱ����) �滻���ܲۼ���
function PlayerInfo:HandleReplaceSlotSpell(pkt)
	
	local spellId  = pkt.spellId
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- �жϼ����Ƿ����
	if not self:isSpellExist(spellId) then
		return
	end
	
	-- �ж�����Ƿ�ӵ���������
	if not self:hasSpell(spellId) then
		return
	end	
	
	-- ��ǰ�����Ƿ�Ϊ��������
	if not self:isInitiativeSpell(config.is_initiative) then
		return
	end
	
	-- �Ƿ��Ѿ��ڼ��ܲ���
	if self:isSloted(spellId) then
		return
	end
	
	-- 	��λ�Ƿ�Ϸ�
	local slot = config.skill_slot
	if slot > SPELL_SLOT_COUNT or slot <= SLOT_COMBO then
		return
	end
	
	-- ͬ���������ܵ�p����
	self:replace(slot, spellId, spellLv)
	
	--���͵��������滻����������Ϣ
	self:Send2ScenedReplaceEquipedSpell(slot, spellId, spellLv)
end
]]

-- �Ƿ��Ѿ��ڼ��ܲ�
function PlayerInfo:isSloted(spellId)
	for i = PLAYER_INT_FIELD_SPELL_START, PLAYER_INT_FIELD_SPELL_END-1 do
		if self:GetUInt16(i, SHORT_SLOT_SPELL_ID) == spellId then
			return true
		end
	end
	
	return false
end

-- �滻(�����������)
function PlayerInfo:replace(slot, spellId, spellLv)
	playerLib.UpdateSlotSpell(self.ptr, slot, spellId, spellLv)
end

-- ��������ͬ����P����
function PlayerInfo:updatePassive(spellId, spellLv)
	playerLib.UpdatePassive(self.ptr, spellId, spellLv)
end

-- �жϼ��ܲ��Ƿ��м���
function PlayerInfo:hasSkillBySlot(slot)
	for i = PLAYER_INT_FIELD_SPELL_START, PLAYER_INT_FIELD_SPELL_END-1 do
		local sl = self:GetByte(i, BYTE_SLOT)
		if sl == 0 then
			break
		end
		
		if sl == slot then
			return true
		end
	end
	
	return false
end

-- �ж��Ƿ���Ҫ���ͳ�����
function PlayerInfo:sendSpellInfoIfEnabled(is_initiative, spellTable)
	-- ��������
	if self:isInitiativeSpell(is_initiative) then
		if self:isSloted(spellId) then
			self:Send2ScenedUpdateSpellInfo(spellTable)
		end
	elseif self:isPassiveSpell(is_initiative) then
		--TODO: ��������������, ���ߵ�ǰ�������Ѿ�װ�����������
		self:Send2ScenedUpdatePassiveInfo(spellTable)
	end
end


-- ���͵��������滻����������Ϣ
function PlayerInfo:Send2ScenedReplaceEquipedSpell(slot, spellId, spellLv)
	local pkt = Packet.new(INTERNAL_OPT_REPLACE_EQUIPED_SPELL)
	pkt:writeUTF(self:GetGuid())
	pkt:writeByte(slot)
	pkt:writeU16(spellId)
	pkt:writeByte(spellLv)
	app:sendToConnection(self:GetScenedFD(), pkt)
	pkt:delete()
end

-- ���͵����������¼��ܵȼ�
function PlayerInfo:Send2ScenedUpdateSpell(spellType, spellTable)
	local pkt = Packet.new(INTERNAL_OPT_UPDATE_SPELL_INFO)
	
	pkt:writeUTF(self:GetGuid())
	pkt:writeByte(spellType)
	pkt:writeByte(#spellTable)
	for _, spell in pairs(spellTable) do
		local spellId = spell[ 1 ]
		local spellLv = spell[ 2 ]
		pkt:writeU16(spellId)
		pkt:writeByte(spellLv)
	end
	
	app:sendToConnection(self:GetScenedFD(), pkt)
		
	pkt:delete()
end

--INTERNAL_OPT_CHANGE_DIVINE_INFO	= 82

-- ���͵����������¼��ܲۼ�����Ϣ
-- ��ŭ�����޸�Ҳ�����
function PlayerInfo:Send2ScenedUpdateSpellInfo(spellTable)
	self:Send2ScenedUpdateSpell(TYPE_SPELL_SLOT, spellTable)
end

-- ���͵����������±���������Ϣ
function PlayerInfo:Send2ScenedUpdatePassiveInfo(spellTable)
	self:Send2ScenedUpdateSpell(TYPE_SPELL_PASSIVE, spellTable)
end






----------------------------------------------------------����--------------------------------------------------------
UPGRADE_MODE_MANUAL = 1	-- �ֶ�����

-- ������������
function PlayerInfo:Handle_Raise_Mount(pkt)
	local spellMgr = self:getSpellMgr()
	-- ��ǰ�Ƿ�������
	if not spellMgr:hasMount() then
		outFmtError("player not active mount")
		return
	end
	
	-- �Ƿ��������(�ѵ���10��)
	if not spellMgr:canRaise() then
		outFmtError("player cannot raise star because of full stars")
		return
	end
	
	local level = spellMgr:getMountLevel()
	local config = tb_mount_base[level]
	
	local star  = spellMgr:getMountStar()
	local trainExp = spellMgr:getTrainExp()	
	
	-- ����Դ
	if not self:costMoneys(MONEY_CHANGE_RAISE_MOUNT, config.traincost) then
		outFmtError("resouce not enough")
		return
	end
	
	-- ��ñ���ֵ
	local vip = false
	local multi = self:randomMulti(config, vip)
	local addExp = multi * config.addTrainExp
	
	-- ������������
	local seq = (level - 1) * 11 + star + 1
	local trainConfig = tb_mount_train[seq]
	local limit = trainConfig.exp

	-- ���������
	if addExp + trainExp >= limit then
		local value = addExp + trainExp - limit
		spellMgr:setTrainExp(value)
		
		local nextStar = star + 1
		local upgradeConfg = tb_mount_upgrade[level]
		-- ���ܽ��� ���� �ֶ�����
		if nextStar < 10 or upgradeConfg.upgradeMode == UPGRADE_MODE_MANUAL then
			spellMgr:setMountStar(nextStar)
		else -- �Զ�����
			self:upgraded()
		end
	else
		-- δ����, ֻ�Ӿ���
		spellMgr:addTrainExp(addExp)
	end
	
	outFmtInfo("raise from (%d, %d, %d) to (%d, %d, %d)", level, star, trainExp, spellMgr:getMountLevel(), spellMgr:getMountStar(), spellMgr:getTrainExp())
end

-- �������ֵ
function PlayerInfo:randomMulti(config, vip)
	-- ȷʵ��VIP�������ʽ, ������ͨ��
	local plist = config.trainIds
	if vip then
		plist = config.trainVIPIds
	end
	
	-- ����������
	local sum = 0
	for _, value in pairs(plist) do
		sum = sum + tb_mount_train_type[value].rate
	end
	
	-- ������ֵ
	local rd = randInt(1, sum)

	-- ͨ�����ֵ�����������ı���
	sum = 0
	for _, value in pairs(plist) do
		local config = tb_mount_train_type[value]
		sum = sum + config.rate
		if rd <= sum then
			return config.mul
		end
	end
	
	return 1
end

-- ������������
function PlayerInfo:Handle_Upgrade_Mount(pkt)
	local spellMgr = self:getSpellMgr()
	-- ��ǰ�Ƿ�������
	if not spellMgr:hasMount() then
		outFmtError("player not active mount")
		return
	end
	
	-- �Ƿ��������
	if not spellMgr:canUpgrade() then
		outFmtError("player cannot upgrade")
		return
	end
	
	local level = spellMgr:getMountLevel()
	local upgradeConfig = tb_mount_upgrade[level]
	local cost = upgradeConfig.upgradecost
	
	-- ����۳���Ʒʧ��, ����
	if not self:useMulItem(cost) then
		outFmtError("player has not enough item")
		return
	end
	
	local prev = spellMgr:getBlessExp()
	local ret, added = self:upgradeOnce(prev)
	local now = prev + added
	if ret then
		self:upgraded()
		now = 0
	end
	
	spellMgr:setBlessExp(now)
	
	outFmtInfo("upgrade from (%d, 10, %d) to (%d, %d, %d)", level, prev, spellMgr:getMountLevel(), spellMgr:getMountStar(), spellMgr:getBlessExp())
end

-- һ������
function PlayerInfo:Handle_Upgrade_Mount_One_Step(pkt)
	local spellMgr = self:getSpellMgr()
	-- ��ǰ�Ƿ�������
	if not spellMgr:hasMount() then
		outFmtError("player not active mount")
		return
	end
	
	-- �Ƿ��������
	if not spellMgr:canUpgrade() then
		outFmtError("player cannot upgrade")
		return
	end
	
	local level = spellMgr:getMountLevel()
	local upgradeConfig = tb_mount_upgrade[level]
	local cost = upgradeConfig.upgradecost
	
	local prev = spellMgr:getBlessExp()
	local now = prev
	local times = 0
	local vist = false
	
	while true do
		-- ����۳���Ʒʧ��, break
		-- �ж��Ƿ�ͬʱӵ�ж����Ʒ
		if not self:hasMulItem(cost, times+1) then
			break
		end
		-- �ӿ۳�����
		times = times + 1
		
		-- ��������� Ҳbreak
		local ret, added = self:upgradeOnce(now)
		if ret then
			now = 0
			vist = true
			break
		else
			now = now + added
		end
	end
	
	-- �۵���
	if not self:useMulItem(cost, times) then
		outFmtError("one step upgrade alarm!!!!!!!!!!!!!!!!")
	end
	
	-- ������
	if vist then
		self:upgraded()
	end
	
	-- ���þ���
	spellMgr:setBlessExp(now)
	
	outFmtInfo("upgrade from (%d, 10, %d) to (%d, %d, %d)", level, prev, spellMgr:getMountLevel(), spellMgr:getMountStar(), spellMgr:getBlessExp())
end

-- ���н���һ��
function PlayerInfo:upgradeOnce(blessExp)
	local spellMgr = self:getSpellMgr()
	local level = spellMgr:getMountLevel()
	local upgradeConfig = tb_mount_upgrade[level]
	local range = upgradeConfig.addBlessExpRange
	local limit = upgradeConfig.upgradeExp
	local rate  = upgradeConfig.upgradeSuccessRate

	-- �Ƿ���׳ɹ�
	if randInt(1, 100) > rate then
		return false, 0
	end
	
	-- ��üӵ�ף��ֵ
	local added = randInt(range[ 1 ], range[ 2 ])
	local now   = blessExp + added
	
	-- ���ף��ֵ��������
	if now >= limit then
		return true, 0
	end
	
	return false, added
end
	

-- ����
function PlayerInfo:upgraded()
	local spellMgr = self:getSpellMgr()
	local level = spellMgr:getMountLevel()
		
	spellMgr:setMountLevel(level + 1)
	spellMgr:setMountStar(0)
	self:DoAfterUpgrade(level+1)
end

-- ���׺���ĳЩ��
function PlayerInfo:DoAfterUpgrade(level)
	
	-- ��������
	local a = tb_mount_base[level].skills
	for _, spellId in pairs(a) do
		self:activeMountSpell(spellId)
	end
	
	-- �����û�
	local b = tb_mount_upgrade[level].illusions
	for _, illuId in pairs(b) do
		self:onActiveIllusion(illuId)
	end
end

-- �������＼��
function PlayerInfo:activeMountSpell(spellId)
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- �жϼ����Ƿ����
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- �ж�����Ƿ�ӵ���������
	if self:hasSpell(spellId) then
		outFmtError("player has spellId %d", spellId)
		return
	end
	
	-- �����
	spellMgr:activeMountSpell(spellId)
	
	self:onActiveSpellWithoutInitiative(spellId)
end


-- ��������û�����
function PlayerInfo:Handle_Illusion_Active(pkt)
	local illuId = pkt.illuId
	
	-- �û�����
	if tb_mount_illusion[illuId] == nil then
		outFmtError("illusion id = %d is not exist", illuId)
		return
	end
	
	local config = tb_mount_illusion[illuId]
	if config.condition == ILLUSION_LEVEL_ACTIVE or config.condition == ILLUSION_EXPIRE_ACTIVE then
		outFmtError("Handle_Illusion_Active illusion id = %d cannot in this way", illuId)
		return
	end
	
	local spellMgr = self:getSpellMgr()
	-- �û��Ƿ����
	if spellMgr:hasIllusion(illuId) then
		outFmtError("player already has illusion id = %d", illuId)
		return
	end
	
	self:onActiveIllusion(illuId)
end

ILLUSION_LEVEL_ACTIVE = 1		--��������ﵽ��Ӧ�ȼ�
ILLUSION_ITEM_ACTIVE = 2		--���Ķ�Ӧ������Ƭ
ILLUSION_RESOURCE_ACTIVE = 3	--����һ������Ԫ��
ILLUSION_EXPIRE_ACTIVE = 4		--��ʵ�ֵļ���

-- �����û�����
function PlayerInfo:onActiveIllusion(illuId)
	local config = tb_mount_illusion[illuId]
	local spellMgr = self:getSpellMgr()
	
	if config.condition == ILLUSION_ITEM_ACTIVE then
		if not self:useMulItem(config.costItem) then
			outFmtError("onActiveIllusion item not enough")
			return
		end
	elseif config.condition == ILLUSION_RESOURCE_ACTIVE then
		if not self:costMoneys(MONEY_CHANGE_ILLUSION, config.costResource) then
			outFmtError("onActiveIllusion resouce not enough")
			return
		end
	end
	
	-- ����û�
	spellMgr:onActiveIllusion(illuId)
	
	-- ����û��ļ���
	for _, spellId in pairs(config.spells) do
		self:onActiveSpellWithoutInitiative(spellId)
	end
end

-- ����û�����
function PlayerInfo:Handle_Illusion(pkt)
	local illuId = pkt.illuId
	
	if self:GetUInt16(PLAYER_INT_FIELD_MOUNT_LEVEL, 1) == illuId then
		self:SetUInt16(PLAYER_INT_FIELD_MOUNT_LEVEL, 1, 0)
	else
		self:SetUInt16(PLAYER_INT_FIELD_MOUNT_LEVEL, 1, illuId)
	end
end