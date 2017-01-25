-- 升级基础(包括)技能
function PlayerInfo:Handle_Raise_BaseSpell(pkt)
	local spellId  = pkt.spellId
	local raiseType = pkt.raiseType
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
	
--[[	-- 判断是否是基础(怒气)技能
	if not self:isBaseSkill(spellId) and not self:isAngerSpell(spellId) then
		outFmtError("spellId %d is cannot do in this way", spellId)
		return
	end--]]
	
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
	
	self:DoHandleRaiseSpell(raiseType, spellId)
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
	
	if not self:costMoneys(MONEY_CHANGE_SPELL_UP, cost) then
		outFmtError("resouce %d not enough", MONEY_TYPE_SILVER)
		return
	end
	
	self:DoHandleUpgradeAngleSpell(spellId)
end

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
	
	self:DoHandleRaiseMount()
end

-- 申请升阶坐骑
function PlayerInfo:Handle_Upgrade_Mount(pkt)
	local spellMgr = self:getSpellMgr()
	local useItem = pkt.useItem
	
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
	if useItem == 0 then
		if not self:useMulItem(cost) then
			outFmtError("player has not enough item")
			return
		end
	else
		if not self:useMulItemIfCostMoneyEnabled(cost) then
			outFmtError("ingots not enough")
			return
		end
	end
	
	self:DoHandleUpgradeMount()
end

-- 一键进阶
function PlayerInfo:Handle_Upgrade_Mount_One_Step(pkt)
	local useItem = pkt.useItem
	
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
	
	self:DoHandleUpgradeMountOneStep(useItem)
end

ILLUSION_EXPIRE_ACTIVE = 3		--有实现的激活

-- 申请解锁幻化坐骑
function PlayerInfo:Handle_Illusion_Active(pkt)
	local illuId = pkt.illuId
	
	-- 幻化存在
	if tb_mount_illusion[illuId] == nil then
		outFmtError("illusion id = %d is not exist", illuId)
		return
	end
	
	local config = tb_mount_illusion[illuId]
	if config.condition == ILLUSION_EXPIRE_ACTIVE then
		outFmtError("Handle_Illusion_Active illusion id = %d cannot in this way", illuId)
		return
	end
	
	local spellMgr = self:getSpellMgr()
	-- 幻化是否存在
	if spellMgr:hasIllusion(illuId) then
		outFmtError("player already has illusion id = %d", illuId)
		return
	end
	
	local level = spellMgr:getMountLevel()
	if level < tb_mount_illusion[illuId].mountLevel then
		outFmtError("Handle_Illusion_Active illusion id = %d need level = %d", illuId, tb_mount_illusion[illuId].mountLevel)
		return
	end
	
	self:onActiveIllusion(illuId)
end

-- 申请幻化坐骑
function PlayerInfo:Handle_Illusion(pkt)
	local illuId = pkt.illuId
	
	local spellMgr = self:getSpellMgr()
	-- 幻化是否存在
	if not spellMgr:hasIllusion(illuId) then
		outFmtError("player has no illusion id = %d", illuId)
		return
	end
	
	self:DoHandleIllusion(illuId)
end

-- 激活神兵
function PlayerInfo:Handle_Divine_Active(pkt)
	local id = pkt.id
	--outFmtInfo("divine active id %d",id)
	if tb_divine_base[id] == nil then
		outFmtError("table has no divine id = %d", id)
		return
	end

	local spellMgr = self:getSpellMgr()

	if spellMgr:hasDivine(id) then
		outFmtError("player has already active divine id = %d", id)
		return
	end

	if self:DivineActive(id) then
		-- 加任务
		local questMgr = self:getQuestMgr()
		questMgr:OnUpdate(QUEST_TARGET_TYPE_OWN_DIVINE, {id})
	end
end

-- 升级神兵
function PlayerInfo:Handle_Divine_UpLev(pkt)
	local id = pkt.id
	local spellMgr = self:getSpellMgr()

	if not spellMgr:hasDivine(id) then
		outFmtError("player has not already active divine id = %d", id)
		return
	end

	self:DivineUpLev(id)
end
--切换神兵
function PlayerInfo:Handle_Divine_Switch(pkt)
	local id = pkt.id
	local spellMgr = self:getSpellMgr()

	if not spellMgr:hasDivine(id) then
		outFmtError("swich divine - player has not already active divine id = %d", id)
		return
	end

	local prev = self:GetUInt32(PLAYER_INT_FIELD_DIVINE_ID)
	if prev == id then
		self:switchDivine(0)
	else 
		self:switchDivine(id)
	end

	
end