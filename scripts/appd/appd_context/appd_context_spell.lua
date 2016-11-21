local Packet = require 'util.packet'

BASE_SKILL = 1				--基础技能

-- 升级基础(包括)技能
function PlayerInfo:Handle_Raise_BaseSpell(pkt)
	
	local spellId  = pkt.spellId
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- 判断技能是否存在
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- 判断玩家是否拥有这个技能
	if not self:hasSpell(spellId) then
		outFmtError("player has no spellId %d", spellId)
		return
	end
	
	-- 判断是否满级了
	if self:isTopLevel(spellId) then
		outFmtError("spellId %d is in topLevel", spellId)
		return
	end
	
	-- 判断是否是基础(怒气)技能
	if not self:isBaseSkill(spellId) and not self:isAngerSpell(spellId) then
		outFmtError("spellId %d is cannot do in this way", spellId)
		return
	end
	
	-- 判断人物等级
	local index = spellMgr:getSpellUpgradeIndex(spellId)
	local upLevelConfig = tb_skill_uplevel[index]
	if not self:checkPlayerLevel(upLevelConfig.need_level) then
		outFmtError("spellId %d, player level not enough, need level = %d", spellId, upLevelConfig.need_level)
		return
	end
	
	-- 判断消耗道具
	if #upLevelConfig.uplevel_item > 0 then
		outFmtError("no way to cost item")
		return
	end
	
	-- 判断消耗资源
	if #upLevelConfig.uplevel_cost > 0 then
		for _, resource in pairs(upLevelConfig.uplevel_cost) do
			if not self:checkMoneyEnough(resource[ 1 ], resource[ 2 ]) then
				outFmtError("resouce %d not enough", resource[ 1 ])
				return
			end
		end
	end
	
	-- 扣除道具
	if #upLevelConfig.uplevel_item > 0 then
		--TODO: 下次再说
	end
	
	-- 扣除资源
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
	
	-- 在技能槽的修改技能槽数据(怒气技能也是主动技能)
	if self:isInitiativeSpell(config.is_initiative) or self:isAngerSpell(spellId) then
		--同步主动技能到p对象
		if self:isSloted(spellId) then
			local slot = config.skill_slot
			self:replace(slot, spellId, spellLv)
			table.insert(spellTable, {spellId, spellLv})
			
			-- 如果是连招
			local arry = tb_skill_base[spellId].follow
			for _, id in pairs(arry) do
				self:replace(slot, id, spellLv)
				table.insert(spellTable, {id, spellLv})
			end
		end
	elseif self:isPassiveSpell(config.is_initiative) then
		--同步被动技能到p对象中
		self:updatePassive(spellId, spellLv)
		table.insert(spellTable, {spellId, spellLv})
	end
	
	-- 是否发送场景服
	self:sendSpellInfoIfEnabled(config.is_initiative, spellTable)
	
	outFmtInfo("raise spell %d success, from %d to %d", spellId, prev, spellLv)
end

-- 怒气技能进阶
function PlayerInfo:Handle_Upgrade_AngleSpell(pkt)
	
	local spellId  = pkt.spellId
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- 判断技能是否存在
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- 判断玩家是否拥有这个技能
	if not self:hasSpell(spellId) then
		outFmtError("player has no spellId %d", spellId)
		return
	end
	
	-- 判断是否满级了
	if not self:isTopLevel(spellId) then
		outFmtError("spellId %d is not in topLevel, cannot upgrade", spellId)
		return
	end
	
	-- 判断是否是怒气技能
	if not self:isAngerSpell(spellId) then
		outFmtError("spellId %d is not anger spell", spellId)
		return
	end
	
	-- 判断金币是否充足
	local upgradeConfig = tb_assistangerspell_upgrade[spellId]
	local cost = upgradeConfig.cost
	if not self:checkMoneyEnough(MONEY_TYPE_SILVER, cost) then
		outFmtError("resouce %d not enough", MONEY_TYPE_SILVER)
		return
	end
	
	-- 消耗金币
	self:SubMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_SPELL_UP, cost)

	local nextId = upgradeConfig.nextid
	--同步主动技能到p对象
	local slot = config.skill_slot
	
	--激活技能
	spellMgr:activeBaseSpell(nextId)
	
	self:replace(slot, nextId, 1)
	
	--发送到场景服替换主动技能信息
	self:Send2ScenedReplaceEquipedSpell(slot, nextId, 1)
	
	outFmtInfo("upgrade spell success, from %d to %d", spellId, nextId)
end

-- 看看能否激活
function PlayerInfo:activeBaseSpell(spellId, activeType)
	
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- 判断技能是否存在
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- 判断玩家是否拥有这个技能
	if self:hasSpell(spellId) then
		outFmtError("player has exist spellId %d", spellId)
		return
	end
	
	-- 等级是否满足条件
	local learnConfig = tb_learn_spell[spellId]
	if learnConfig == nil then
		outFmtError("spellId %d not in tb_learn_spell", spellId)
		return
	end 
	
	if activeType ~= SPELL_ACTIVE_BY_LEVEL and not self:checkPlayerLevel(learnConfig.playerLevel) then
		outFmtError("activeBaseSpell spellId %d, player level not enough, need level %d", spellId, learnConfig.playerLevel)
		return
	end
	
	-- 判断消耗道具
	if #learnConfig.item > 0 then
		outFmtError("no way to cost item")
		return
	end

	-- 激活技能
	spellMgr:activeBaseSpell(spellId)
	
	-- 看看是否需要自动装备
	local slot = config.skill_slot
	
	-- 如果是主动技能
	if self:isInitiativeSpell(config.is_initiative) then
		outFmtInfo("active spell %d", spellId)
		if not self:hasSkillBySlot(slot) then
			-- 同步主动技能到p对象
			self:replace(slot, spellId, 1)
			--发送到场景服替换主动技能信息
			self:Send2ScenedReplaceEquipedSpell(slot, spellId, 1)
		end
		return
	end
	
	-- 被动技能发送场景服
	if self:isPassiveSpell(config.is_initiative) then
		outFmtInfo("active spell %d", spellId)
		--同步到p对象中
		self:updatePassive(spellId, 1)
		local spellTable = {}
		table.insert(spellTable, {spellId, 1})
		-- 发送到场景服更新被动技能信息
		self:sendSpellInfoIfEnabled(config.is_initiative, spellTable)
	end
	
end

-- 判断人物等级是否满足条件
function PlayerInfo:checkPlayerLevel(needLevel)
	local level = self:GetLevel()
	return level >= needLevel
end

-- 判断钱是否足够
function PlayerInfo:checkMoneyEnough(moneyType, cost)
	local value = self:GetMoney(moneyType)
	return value >= cost and cost >= 0
end

-- 是否是主动技能
function PlayerInfo:isInitiativeSpell(initiative)
	return initiative >= SPELL_INITIATIVE_DAMAGE and initiative <= SPELL_INITIATIVE_BUFF
end

-- 是否是被动技能
function PlayerInfo:isPassiveSpell(initiative)
	return initiative >= SPELL_PASSIVE_DAMAGE and initiative <= SPELL_PASSIVE_BUFF
end

-- 技能是否存在
function PlayerInfo:isSpellExist(spellId)
	return tb_skill_base[spellId] ~= nil
end

-- 是否是怒气技能
function PlayerInfo:isAngerSpell(spellId)
	return tb_skill_base[spellId].skill_slot == SLOT_ANGER
end

-- 是否是基础技能
function PlayerInfo:isBaseSkill(spellId)
	return tb_skill_base[spellId].skill_type == BASE_SKILL
end

-- 是否达到顶级
function PlayerInfo:isTopLevel(spellId)
	local spellMgr = self:getSpellMgr()
	local spellLv  = self:GetSpellLevel(spellId)
	local topLevel = spellMgr:getSpellTopLevel(spellId)
	
	return spellLv == topLevel
end

-- 是否拥有这个技能
function PlayerInfo:hasSpell(spellId)
	local spellLv = self:GetSpellLevel(spellId)
	return spellLv > 0
end

-- 技能等级
function PlayerInfo:GetSpellLevel(spellId)
	local spellLv = playerLib.GetSpellLevel(self.ptr, spellId)
	return spellLv
end

--[[
-- TODO: (以后会用 暂时不用) 替换技能槽技能
function PlayerInfo:HandleReplaceSlotSpell(pkt)
	
	local spellId  = pkt.spellId
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- 判断技能是否存在
	if not self:isSpellExist(spellId) then
		return
	end
	
	-- 判断玩家是否拥有这个技能
	if not self:hasSpell(spellId) then
		return
	end	
	
	-- 当前技能是否为主动技能
	if not self:isInitiativeSpell(config.is_initiative) then
		return
	end
	
	-- 是否已经在技能槽中
	if self:isSloted(spellId) then
		return
	end
	
	-- 	槽位是否合法
	local slot = config.skill_slot
	if slot > SPELL_SLOT_COUNT or slot <= SLOT_COMBO then
		return
	end
	
	-- 同步主动技能到p对象
	self:replace(slot, spellId, spellLv)
	
	--发送到场景服替换主动技能信息
	self:Send2ScenedReplaceEquipedSpell(slot, spellId, spellLv)
end
]]

-- 是否已经在技能槽
function PlayerInfo:isSloted(spellId)
	for i = PLAYER_INT_FIELD_SPELL_START, PLAYER_INT_FIELD_SPELL_END-1 do
		if self:GetUInt16(i, SHORT_SLOT_SPELL_ID) == spellId then
			return true
		end
	end
	
	return false
end

-- 替换(包括升级情况)
function PlayerInfo:replace(slot, spellId, spellLv)
	playerLib.UpdateSlotSpell(self.ptr, slot, spellId, spellLv)
end

-- 被动技能同步到P数据
function PlayerInfo:updatePassive(spellId, spellLv)
	playerLib.UpdatePassive(self.ptr, spellId, spellLv)
end

-- 判断技能槽是否有技能
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

-- 判断是否需要发送场景服
function PlayerInfo:sendSpellInfoIfEnabled(is_initiative, spellTable)
	-- 主动技能
	if self:isInitiativeSpell(is_initiative) then
		if self:isSloted(spellId) then
			self:Send2ScenedUpdateSpellInfo(spellTable)
		end
	elseif self:isPassiveSpell(is_initiative) then
		--TODO: 如果不是神兵技能, 或者当前技能是已经装备的神兵技能
		self:Send2ScenedUpdatePassiveInfo(spellTable)
	end
end


-- 发送到场景服替换主动技能信息
function PlayerInfo:Send2ScenedReplaceEquipedSpell(slot, spellId, spellLv)
	local pkt = Packet.new(INTERNAL_OPT_REPLACE_EQUIPED_SPELL)
	pkt:writeUTF(self:GetGuid())
	pkt:writeByte(slot)
	pkt:writeU16(spellId)
	pkt:writeByte(spellLv)
	app:sendToConnection(self:GetScenedFD(), pkt)
	pkt:delete()
end

-- 发送到场景服更新技能等级
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

-- 发送到场景服更新技能槽技能信息
-- 愤怒技能修改也发这边
function PlayerInfo:Send2ScenedUpdateSpellInfo(spellTable)
	self:Send2ScenedUpdateSpell(TYPE_SPELL_SLOT, spellTable)
end

-- 发送到场景服更新被动技能信息
function PlayerInfo:Send2ScenedUpdatePassiveInfo(spellTable)
	self:Send2ScenedUpdateSpell(TYPE_SPELL_PASSIVE, spellTable)
end