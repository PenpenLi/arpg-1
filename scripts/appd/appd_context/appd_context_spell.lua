local Packet = require 'util.packet'

BASE_SKILL = 1				--��������

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
		outFmtError("no way to cost item")
		return
	end
	
	-- �ж�������Դ
	if #upLevelConfig.uplevel_cost > 0 then
		for _, resource in pairs(upLevelConfig.uplevel_cost) do
			if not self:checkMoneyEnough(resource[ 1 ], resource[ 2 ]) then
				outFmtError("resouce %d not enough", resource[ 1 ])
				return
			end
		end
	end
	
	-- �۳�����
	if #upLevelConfig.uplevel_item > 0 then
		--TODO: �´���˵
	end
	
	-- �۳���Դ
	if #upLevelConfig.uplevel_cost > 0 then
		for _, resource in pairs(upLevelConfig.uplevel_cost) do
			if resource[ 2 ] > 0 then
				self:SubMoney(resource[ 1 ], MONEY_CHANGE_UP_ASSISTSPELL, resource[ 2 ])
			end
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
	
	-- �����Ƿ���Ҫ�Զ�װ��
	local slot = config.skill_slot
	
	-- �������������
	if self:isInitiativeSpell(config.is_initiative) then
		outFmtInfo("active spell %d", spellId)
		if not self:hasSkillBySlot(slot) then
			-- ͬ���������ܵ�p����
			self:replace(slot, spellId, 1)
			--���͵��������滻����������Ϣ
			self:Send2ScenedReplaceEquipedSpell(slot, spellId, 1)
		end
		return
	end
	
	-- �������ܷ��ͳ�����
	if self:isPassiveSpell(config.is_initiative) then
		outFmtInfo("active spell %d", spellId)
		--ͬ����p������
		self:updatePassive(spellId, 1)
		local spellTable = {}
		table.insert(spellTable, {spellId, 1})
		-- ���͵����������±���������Ϣ
		self:sendSpellInfoIfEnabled(config.is_initiative, spellTable)
	end
	
end

-- �ж�����ȼ��Ƿ���������
function PlayerInfo:checkPlayerLevel(needLevel)
	local level = self:GetLevel()
	return level >= needLevel
end

-- �ж�Ǯ�Ƿ��㹻
function PlayerInfo:checkMoneyEnough(moneyType, cost)
	local value = self:GetMoney(moneyType)
	return value >= cost and cost >= 0
end

-- �Ƿ�����������
function PlayerInfo:isInitiativeSpell(initiative)
	return initiative >= SPELL_INITIATIVE_DAMAGE and initiative <= SPELL_INITIATIVE_BUFF
end

-- �Ƿ��Ǳ�������
function PlayerInfo:isPassiveSpell(initiative)
	return initiative >= SPELL_PASSIVE_DAMAGE and initiative <= SPELL_PASSIVE_BUFF
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