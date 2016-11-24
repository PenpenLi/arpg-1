--技能管理器

local AppSpellMgr = class("AppSpellMgr", BinLogObject)

function AppSpellMgr:ctor()
	
end

----------------------------------------基础技能部分------------------------------------

-- 激活基础技能
function AppSpellMgr:activeBaseSpell(spellId)
	-- 激活
	local count = self:GetUInt32(SPELL_BASE_COUNT)
	local index = SPELL_INT_FIELD_BASE_SPELL_START + count
	self:SetUInt16(index, SHORT_SPELL_ID, spellId)
	self:SetUInt16(index, SHORT_SPELL_LV,       1)
	self:SetUInt32(SPELL_BASE_COUNT, count + 1)
end

-- 升级基础技能
function AppSpellMgr:raiseBaseSpell(spellId)
	local prev = self:getSpellLevel(spellId)
	
	-- 加技能等级
	self:SetBaseSpellLevel(spellId,  prev+1)
	
	-- 如果是3连击
	local arry = tb_skill_base[spellId].follow
	for _, id in pairs(arry) do
		self:SetBaseSpellLevel(id,  prev+1)
	end
end

--判断玩家是否拥有这个技能
function AppSpellMgr:getSpellLevel(spellId)
	local owner = self:getOwner()
	local level = playerLib.GetSpellLevel(owner.ptr, spellId)
	
	return level
end

--技能最大等级
function AppSpellMgr:getSpellTopLevel(spellId)
	local config = tb_skill_base[spellId]
	return config.uplevel_id[ 2 ] - config.uplevel_id[ 1 ] + 1
end

--当前升级id
function AppSpellMgr:getSpellUpgradeIndex(spellId)
	local config = tb_skill_base[spellId]
	local level = self:getSpellLevel(spellId)
	return config.uplevel_id[ 1 ] + level - 1
end

--设置技能等级
function AppSpellMgr:SetBaseSpellLevel(spellId, spellLv)
	for i = SPELL_INT_FIELD_BASE_SPELL_START, SPELL_INT_FIELD_BASE_SPELL_END-1 do
		if self:GetUInt16(i, SHORT_SPELL_ID) == spellId then
			self:SetUInt16(i, SHORT_SPELL_LV, spellLv)
			break
		end
	end
	
	-- 同步映射关系
	self:SetSpellLevel(spellId, spellLv)
end

-- 设置映射技能等级
function AppSpellMgr:SetSpellLevel(spellId, spellLv)
	local owner = self:getOwner()
	playerLib.SetSpellLevel(owner.ptr, spellId, spellLv)
end

----------------------------------------基础技能部分 结束------------------------------------


----------------------------------------------坐骑-----------------------------------------------
-- 玩家是否有坐骑
function AppSpellMgr:hasMount()
	return self:getMountLevel() > 0
end

-- 当前阶数
function AppSpellMgr:getMountLevel()
	return self:GetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 0)
end

-- 设置当前阶数
function AppSpellMgr:setMountLevel(level)
	self:SetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 0, level)
end

-- 玩家能否升星
function AppSpellMgr:canRaise()
	return self:getMountStar() < 10
end

-- 玩家能否升阶
function AppSpellMgr:canUpgrade()
	return self:getMountLevel() < #tb_mount_upgrade and self:getMountStar() == 10
end

-- 当前星级
function AppSpellMgr:getMountStar()
	return self:GetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 1)
end

-- 设置当前星级
function AppSpellMgr:setMountStar(star)
	self:SetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 1, star)
end

-- 当前升星经验
function AppSpellMgr:getTrainExp()
	return self:GetUInt32(SPELL_INT_FIELD_MOUNT_TRAIN_EXP)
end

-- 设置当前升星经验
function AppSpellMgr:setTrainExp(value)
	self:SetUInt32(SPELL_INT_FIELD_MOUNT_TRAIN_EXP, value)
end

-- 增加当前升星经验
function AppSpellMgr:addTrainExp(value)
	local prev = self:getTrainExp()
	self:SetUInt32(SPELL_INT_FIELD_MOUNT_TRAIN_EXP, value + prev)
end

-- 获得祝福值
function AppSpellMgr:getBlessExp()
	return self:GetUInt32(SPELL_INT_FIELD_MOUNT_BLESS_EXP)
end

-- 设置祝福值
function AppSpellMgr:setBlessExp(value)
	self:SetUInt32(SPELL_INT_FIELD_MOUNT_BLESS_EXP, value)
end

-- 激活坐骑技能
function AppSpellMgr:activeMountSpell(spellId)
	for i = SPELL_INT_FIELD_MOUNT_SPELL_START, SPELL_INT_FIELD_MOUNT_SPELL_END-1 do
		if self:GetUInt16(i, SHORT_SPELL_ID) == 0 then
			self:SetUInt16(i, SHORT_SPELL_ID, spellId)
			self:SetUInt16(i, SHORT_SPELL_LV, 1)
			break
		end
	end
end

-- 是否存在当前幻化坐骑
function AppSpellMgr:hasIllusion(illuId)
	
	local count = self:GetUInt32(SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT)
	local size = SPELL_INT_FIELD_MOUNT_ILLUSION_START + SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT * MAX_ILLUSION_ATTR_COUNT
	
	for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, size, MAX_ILLUSION_ATTR_COUNT do
		if self:GetUInt32(ILLUSION_ATTR_ID + i) == 0 then
			return false
		end
		if self:GetUInt32(ILLUSION_ATTR_ID + i) == illuId then
			return true
		end
	end
	
	return false
end


-- 激活幻化
function AppSpellMgr:onActiveIllusion(illuId)

	local count = self:GetUInt32(SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT)
	
	-- 加幻化id
	local size = SPELL_INT_FIELD_MOUNT_ILLUSION_START + count * MAX_ILLUSION_ATTR_COUNT
	self:SetUInt32(ILLUSION_ATTR_ID + size, illuId)
	
	outFmtInfo("active illusion %d", illuId)

	-- 加过期时间
	local config = tb_mount_illusion[illuId]
	local expire = 0
	if config.last > 0 then
		expire = os.time() + config.last * 24 * 3600
	end
	self:SetUInt32(ILLUSION_ATTR_EXPIRE + size, expire)
	
	-- 加技能
	local config = tb_mount_illusion[illuId]
	local st = size + ILLUSION_ATTR_SPELL_START
	for _, spellId in pairs(config.spells) do
		self:SetUInt16(st, SHORT_SPELL_ID, spellId)
		self:SetUInt16(st, SHORT_SPELL_LV, 1)
		st = st + 1
	end

	self:SetUInt32(SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT, count + 1)
end


-- 获得玩家guid
function AppSpellMgr:getPlayerGuid()
	--物品管理器guid转玩家guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--获得技能管理器的拥有者
function AppSpellMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end

return AppSpellMgr