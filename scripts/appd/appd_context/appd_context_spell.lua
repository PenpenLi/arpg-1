local Packet = require 'util.packet'


-------------------------------------------------技能-------------------------------------------------------------

BASE_SKILL = 1				--基础技能
MOUNT_SKILL = 1				--坐骑技能

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
		if not self:hasMulItem(upLevelConfig.uplevel_item) then
			outFmtError("item not enough")
			return
		end
	end
	
	-- 判断消耗资源
	if #upLevelConfig.uplevel_cost > 0 then
		if not self:checkMoneyEnoughs(upLevelConfig.uplevel_cost) then
			outFmtError("resouce not enough")
			return
		end
	end
	
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
	elseif self:isSupportSpell(config.is_initiative) then
		playerLib.SetSpellLevel(self.ptr, spellId, spellLv)
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
function PlayerInfo:Handle_Raise_Mount(pkt)
	local spellMgr = self:getSpellMgr()
	-- 当前是否有坐骑
	if not spellMgr:hasMount() then
		outFmtError("player not active mount")
		return
	end
	
	-- 是否可以再升(已到达10星)
	if not spellMgr:canRaise() then
		outFmtError("player cannot raise star because of full stars")
		return
	end
	
	local level = spellMgr:getMountLevel()
	local config = tb_mount_base[level]
	
	local star  = spellMgr:getMountStar()
	local trainExp = spellMgr:getTrainExp()	
	
	-- 扣资源
	if not self:costMoneys(MONEY_CHANGE_RAISE_MOUNT, config.traincost) then
		outFmtError("resouce not enough")
		return
	end
	
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
	if vip then
		plist = config.trainVIPIds
	end
	
	-- 获得随机上限
	local sum = 0
	for _, value in pairs(plist) do
		sum = sum + tb_mount_train_type[value].rate
	end
	
	-- 获得随机值
	local rd = randInt(1, sum)

	-- 通过随机值来获得随机到的倍数
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

-- 申请升阶坐骑
function PlayerInfo:Handle_Upgrade_Mount(pkt)
	local spellMgr = self:getSpellMgr()
	-- 当前是否有坐骑
	if not spellMgr:hasMount() then
		outFmtError("player not active mount")
		return
	end
	
	-- 是否可以升阶
	if not spellMgr:canUpgrade() then
		outFmtError("player cannot upgrade")
		return
	end
	
	local level = spellMgr:getMountLevel()
	local upgradeConfig = tb_mount_upgrade[level]
	local cost = upgradeConfig.upgradecost
	
	-- 如果扣除物品失败, 返回
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

-- 一键进阶
function PlayerInfo:Handle_Upgrade_Mount_One_Step(pkt)
	local spellMgr = self:getSpellMgr()
	-- 当前是否有坐骑
	if not spellMgr:hasMount() then
		outFmtError("player not active mount")
		return
	end
	
	-- 是否可以升阶
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
		-- 如果扣除物品失败, break
		-- 判断是否同时拥有多个物品
		if not self:hasMulItem(cost, times+1) then
			break
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
	if not self:useMulItem(cost, times) then
		outFmtError("one step upgrade alarm!!!!!!!!!!!!!!!!")
	end
	
	-- 进阶了
	if vist then
		self:upgraded()
	end
	
	-- 设置经验
	spellMgr:setBlessExp(now)
	
	outFmtInfo("upgrade from (%d, 10, %d) to (%d, %d, %d)", level, prev, spellMgr:getMountLevel(), spellMgr:getMountStar(), spellMgr:getBlessExp())
end

-- 进行进阶一次
function PlayerInfo:upgradeOnce(blessExp)
	local spellMgr = self:getSpellMgr()
	local level = spellMgr:getMountLevel()
	local upgradeConfig = tb_mount_upgrade[level]
	local range = upgradeConfig.addBlessExpRange
	local limit = upgradeConfig.upgradeExp
	local rate  = upgradeConfig.upgradeSuccessRate

	-- 是否进阶成功
	if randInt(1, 100) > rate then
		return false, 0
	end
	
	-- 获得加的祝福值
	local added = randInt(range[ 1 ], range[ 2 ])
	local now   = blessExp + added
	
	-- 如果祝福值满足条件
	if now >= limit then
		return true, 0
	end
	
	return false, added
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
	
	-- 解锁幻化
	local b = tb_mount_upgrade[level].illusions
	for _, illuId in pairs(b) do
		self:onActiveIllusion(illuId)
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


-- 申请解锁幻化坐骑
function PlayerInfo:Handle_Illusion_Active(pkt)
	local illuId = pkt.illuId
	
	-- 幻化存在
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
	-- 幻化是否存在
	if spellMgr:hasIllusion(illuId) then
		outFmtError("player already has illusion id = %d", illuId)
		return
	end
	
	self:onActiveIllusion(illuId)
end

ILLUSION_LEVEL_ACTIVE = 1		--进阶坐骑达到对应等级
ILLUSION_ITEM_ACTIVE = 2		--消耗对应坐骑碎片
ILLUSION_RESOURCE_ACTIVE = 3	--消耗一定数量元宝
ILLUSION_EXPIRE_ACTIVE = 4		--有实现的激活

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
function PlayerInfo:Handle_Illusion(pkt)
	local illuId = pkt.illuId
	
	if self:GetUInt16(PLAYER_INT_FIELD_MOUNT_LEVEL, 1) == illuId then
		self:SetUInt16(PLAYER_INT_FIELD_MOUNT_LEVEL, 1, 0)
	else
		self:SetUInt16(PLAYER_INT_FIELD_MOUNT_LEVEL, 1, illuId)
	end
end