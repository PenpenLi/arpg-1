local Packet = require 'util.packet'


-------------------------------------------------技能-------------------------------------------------------------

BASE_SKILL = 1				--基础技能

-- 升级基础(包括)技能
function PlayerInfo:DoHandleRaiseSpell(raiseType, spellId)
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	local index = spellMgr:getSpellUpgradeIndex(spellId)
	local upLevelConfig = tb_skill_uplevel[index]
	
	-- 扣除道具
	if #upLevelConfig.uplevel_item > 0 then
		if not self:useMulItem(upLevelConfig.uplevel_item) then
			outFmtError("use item fail")
			return
		end
	end
	
	-- 扣除资源
	if #upLevelConfig.uplevel_cost > 0 then
		if not self:costMoneys(MONEY_CHANGE_UP_ASSISTSPELL, upLevelConfig.uplevel_cost) then
			outFmtError("sub resouce fail")
			return
		end
	end
	
	local prev = spellMgr:getSpellLevel(spellId)
	spellMgr:onRaiseSpell(raiseType, spellId)
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
	elseif self:isSupportSpell(config.is_initiative) then
		playerLib.SetSpellLevel(self.ptr, spellId, spellLv)
	end
	
	-- 是否发送场景服
	self:sendSpellInfoIfEnabled(config.is_initiative, spellTable)
	
	outFmtInfo("raise spell %d success, from %d to %d", spellId, prev, spellLv)
end

-- 怒气技能进阶
function PlayerInfo:DoHandleUpgradeAngleSpell(spellId)
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	local upgradeConfig = tb_assistangerspell_upgrade[spellId]

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
		if not self:hasMulItem(learnConfig.item) then
			outFmtError("item not enough")
			return
		end
	end
	
	if #learnConfig.resource > 0 then
		if not self:checkMoneyEnoughs(learnConfig.resource) then
			outFmtError("resouce not enough")
			return
		end
	end
	
	
	-- 扣除道具
	if #learnConfig.item > 0 then
		if not self:useMulItem(learnConfig.item) then
			outFmtError("use item fail")
			return
		end
	end
	
	-- 扣除资源
	if #learnConfig.resource > 0 then
		if not self:costMoneys(MONEY_CHANGE_ACTIVE_SPELL, learnConfig.resource) then
			outFmtError("sub resouce fail")
			return
		end
	end

	-- 激活技能
	spellMgr:activeBaseSpell(spellId)
	
	self:onActiveSpell(spellId)
end

-- 判断人物等级是否满足条件
function PlayerInfo:checkPlayerLevel(needLevel)
	local level = self:GetLevel()
	return level >= needLevel
end

-- 是否是主动技能
function PlayerInfo:isInitiativeSpell(initiative)
	return initiative >= SPELL_INITIATIVE_DAMAGE and initiative <= SPELL_INITIATIVE_BUFF
end

-- 是否是被动技能
function PlayerInfo:isPassiveSpell(initiative)
	return initiative >= SPELL_PASSIVE_DAMAGE and initiative <= SPELL_PASSIVE_BUFF
end

-- 是否是辅助技能
function PlayerInfo:isSupportSpell(initiative)
	return initiative == SPELL_SUPPORT
end

-- 激活技能
function PlayerInfo:onActiveSpell(spellId)
	local config   = tb_skill_base[spellId]
	
	-- 如果是主动技能
	if self:isInitiativeSpell(config.is_initiative) then
		local config = tb_skill_base[spellId]
		local slot = config.skill_slot
		if not self:hasSkillBySlot(slot) then
			-- 同步主动技能到p对象
			self:replace(slot, spellId, 1)
			--发送到场景服替换主动技能信息
			self:Send2ScenedReplaceEquipedSpell(slot, spellId, 1)
		else
			playerLib.SetSpellLevel(self.ptr, spellId, 1)
		end
		outFmtInfo("on active spell %d", spellId)
		return
	end
	
	self:onActiveSpellWithoutInitiative(spellId)
end

-- 可适用坐骑激活技能
function PlayerInfo:onActiveSpellWithoutInitiative(spellId)
	local config   = tb_skill_base[spellId]
	outFmtInfo("on active spell %d", spellId)
	
	-- 被动技能发送场景服
	if self:isPassiveSpell(config.is_initiative) then
		--同步到p对象中
		self:updatePassive(spellId, 1)
		local spellTable = {}
		table.insert(spellTable, {spellId, 1})
		-- 发送到场景服更新被动技能信息
		self:sendSpellInfoIfEnabled(config.is_initiative, spellTable)
		
		return
	end
	
	-- 辅助技能
	if self:isSupportSpell(config.is_initiative) then
		playerLib.AddSupportSpell(self.ptr, spellId)
		
		return
	end
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






----------------------------------------------------------坐骑--------------------------------------------------------
UPGRADE_MODE_MANUAL = 1	-- 手动进阶

-- 申请升星坐骑
function PlayerInfo:DoHandleRaiseMount()
	local spellMgr = self:getSpellMgr()	
	local level = spellMgr:getMountLevel()
	local config = tb_mount_base[level]
	
	local star  = spellMgr:getMountStar()
	local trainExp = spellMgr:getTrainExp()	
	
	-- 获得暴击值
	local vip = false
	local multi = self:randomMulti(config, vip)
	local addExp = multi * config.addTrainExp
	
	-- 计算升星上线
	local seq = (level - 1) * 11 + star + 1
	local trainConfig = tb_mount_train[seq]
	local limit = trainConfig.exp
	
	-- 如果升星了
	if addExp + trainExp >= limit then
		local value = addExp + trainExp - limit
		spellMgr:setTrainExp(value)
		
		local nextStar = star + 1
		local upgradeConfg = tb_mount_upgrade[level]
		-- 不能进阶 或者 手动进阶
		if nextStar < 10 or upgradeConfg.upgradeMode == UPGRADE_MODE_MANUAL then
			spellMgr:setMountStar(nextStar)
		else -- 自动进阶
			self:upgraded()
		end
	else
		-- 未升星, 只加经验
		spellMgr:addTrainExp(addExp)
	end
	
	outFmtInfo("raise from (%d, %d, %d) to (%d, %d, %d)", level, star, trainExp, spellMgr:getMountLevel(), spellMgr:getMountStar(), spellMgr:getTrainExp())
end

-- 随机暴击值
function PlayerInfo:randomMulti(config, vip)
	-- 确实是VIP的随机方式, 还是普通的
	local plist = config.trainIds
	local randList = tb_mount_train_type[plist[ 1 ]].range
	if vip then
		randList = tb_mount_train_type[plist[ 2 ]].range
	end

	-- 通过随机值来获得随机到的倍数
	return GetRandomExp(randList)
end

-- 申请升阶坐骑
function PlayerInfo:DoHandleUpgradeMount()
	local spellMgr = self:getSpellMgr()
	
	local level = spellMgr:getMountLevel()
	
	local prev = spellMgr:getBlessExp()
	local ret, added = self:upgradeOnce(prev)
	
	if not ret and added == 0 then
		outFmtDebug("upgrade fail")
		return
	end
	local now = prev + added
	
	if ret then
		self:upgraded()
		now = 0
	end
	
	if prev ~= now then
		spellMgr:setBlessExp(now)
	end
	
	outFmtInfo("upgrade from (%d, 10, %d) to (%d, %d, %d)", level, prev, spellMgr:getMountLevel(), spellMgr:getMountStar(), spellMgr:getBlessExp())
end

-- 一键进阶
function PlayerInfo:DoHandleUpgradeMountOneStep(useItem)
	local spellMgr = self:getSpellMgr()

	local level = spellMgr:getMountLevel()
	local upgradeConfig = tb_mount_upgrade[level]
	local cost = upgradeConfig.upgradecost
	
	local prev = spellMgr:getBlessExp()
	local now = prev
	local times = 0
	local vist = false
	
	while true do
		-- 如果扣除物品失败, break
		-- 判断是否同时拥有多个物品
		if useItem == 0 then
			if not self:hasMulItem(cost, times+1) then
				break
			end
		else
			local ret, _, _ = checkItemEnoughIfCostMoneyEnabled(costItemTable, multiple)
			if not ret then
				break
			end
		end
		-- 加扣除次数
		times = times + 1
		
		-- 如果升级了 也break
		local ret, added = self:upgradeOnce(now)
		if ret then
			now = 0
			vist = true
			break
		else
			now = now + added
		end
	end
	
	-- 扣道具
	
	if not self:useMulItemIfCostMoneyEnabled(cost) then
		outFmtError("one step upgrade alarm!!!!!!!!!!!!!!!!")
		return
	end
	
	if not self:useMulItem(cost, times) then
		outFmtError("one step upgrade alarm!!!!!!!!!!!!!!!!")
		return
	end
	
	-- 进阶了
	if vist then
		self:upgraded()
	end
	
	-- 设置经验
	if prev ~= now then
		spellMgr:setBlessExp(now)
	end
	outFmtInfo("upgrade from (%d, 10, %d) to (%d, %d, %d)", level, prev, spellMgr:getMountLevel(), spellMgr:getMountStar(), spellMgr:getBlessExp())
end

-- 进行进阶一次
function PlayerInfo:upgradeOnce(blessExp)
	local spellMgr = self:getSpellMgr()
	local level = spellMgr:getMountLevel()
	local upgradeConfig = tb_mount_upgrade[level]
	local range = upgradeConfig.addBlessExpRange
	local limit = upgradeConfig.upgradeExp
	
	local added = GetRandomExp(range)
	
	-- 获得加的祝福值
	local now = blessExp + added
	
	-- 如果祝福值满足条件
	if now >= limit then
		return true, 0
	end
	
	return false, added
end

-- 激活坐骑
function PlayerInfo:activeMount()
	self:SetUInt16(PLAYER_INT_FIELD_MOUNT_LEVEL, 0, 1)
	self:upgraded()
end

-- 进阶
function PlayerInfo:upgraded()
	local spellMgr = self:getSpellMgr()
	local level = spellMgr:getMountLevel()
		
	spellMgr:setMountLevel(level + 1)
	spellMgr:setMountStar(0)
	self:DoAfterUpgrade(level+1)
end

-- 进阶后做某些事
function PlayerInfo:DoAfterUpgrade(level)
	
	-- 解锁技能
	local a = tb_mount_base[level].skills
	for _, spellId in pairs(a) do
		self:activeMountSpell(spellId)
	end
end

-- 解锁坐骑技能
function PlayerInfo:activeMountSpell(spellId)
	local config   = tb_skill_base[spellId]
	local spellMgr = self:getSpellMgr()
	
	-- 判断技能是否存在
	if not self:isSpellExist(spellId) then
		outFmtError("spellId %d not exist", spellId)
		return
	end
	
	-- 判断玩家是否拥有这个技能
	if self:hasSpell(spellId) then
		outFmtError("player has spellId %d", spellId)
		return
	end
	
	-- 激活技能
	spellMgr:activeMountSpell(spellId)
	
	self:onActiveSpellWithoutInitiative(spellId)
end


ILLUSION_ITEM_ACTIVE = 1		--消耗对应坐骑碎片
ILLUSION_RESOURCE_ACTIVE = 2	--消耗一定数量元宝

-- 解锁幻化操作
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
	
	-- 激活幻化
	spellMgr:onActiveIllusion(illuId)
	
	-- 激活幻化的技能
	for _, spellId in pairs(config.spells) do
		self:onActiveSpellWithoutInitiative(spellId)
	end
end

-- 申请幻化坐骑
function PlayerInfo:DoHandleIllusion(illuId)
	local spellMgr = self:getSpellMgr()

	local curr = 0
	if self:GetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 3) ~= illuId then
		curr = illuId
	end
	self:SetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 3, curr)
	-- 发送到场景服
	--[[
	self:Send2ScenedIllusion(illuId)
	]]
end

--[[
-- 发送到场景服替换主动技能信息
function PlayerInfo:Send2ScenedIllusion(illuId)
	local pkt = Packet.new(INTERNAL_OPT_ILLUSION)
	pkt:writeUTF(self:GetGuid())
	pkt:writeU16(illuId)
	app:sendToConnection(self:GetScenedFD(), pkt)
	pkt:delete()
end
]]