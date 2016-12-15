--技能管理器

local AppSpellMgr = class("AppSpellMgr", BinLogObject)

function AppSpellMgr:ctor()
	
end

----------------------------------------基础技能部分------------------------------------

-- 升级技能分发
function AppSpellMgr:onRaiseSpell(raiseType, spellId)
	if raiseType == RAISE_BASE_SKILL then
		self:raiseBaseSpell(spellId)
	elseif raiseType == RAISE_MOUNT_SKILL then
		self:raiseMountSpell(spellId)
	elseif raiseType == RAISE_ILLUSION_SKILL then
		self:raiseIlluSpell(spellId)
	elseif raiseType == RAISE_DIVINE_SKILL then
		self:DivineSkillUpLev(spellId)
	end
end

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

-- 升级坐骑技能
function AppSpellMgr:raiseMountSpell(spellId)
	local prev = self:getSpellLevel(spellId)
	
	for i = SPELL_INT_FIELD_MOUNT_SPELL_START, SPELL_INT_FIELD_MOUNT_SPELL_END-1 do
		if self:GetUInt16(i, SHORT_SPELL_ID) == 0 then
			return
		elseif self:GetUInt16(i, SHORT_SPELL_ID) == spellId then
			self:SetUInt16(i, SHORT_SPELL_LV, prev + 1)
			self:SetSpellLevel(spellId, prev+1)
			return
		end
	end
end

-- 是否存在当前幻化坐骑
function AppSpellMgr:hasIllusion(illuId)
	
	for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, SPELL_INT_FIELD_MOUNT_ILLUSION_END, MAX_ILLUSION_ATTR_COUNT do
		if self:GetUInt32(ILLUSION_ATTR_ID + i) == illuId then
			return true
		end
	end
	
	return false
end


-- 激活幻化
function AppSpellMgr:onActiveIllusion(illuId)
	-- 加幻化id
	local indx = self:findEmptyIllusionSlot()
	self:SetUInt32(ILLUSION_ATTR_ID + indx, illuId)
	
	outFmtInfo("active illusion %d", illuId)

	-- 加过期时间
	local config = tb_mount_illusion[illuId]
	local expire = 0
	if config.last > 0 then
		expire = os.time() + config.last * 24 * 3600
	end
	self:SetUInt32(ILLUSION_ATTR_EXPIRE + indx, expire)
	
	-- 加技能
	local config = tb_mount_illusion[illuId]
	local st = indx + ILLUSION_ATTR_SPELL_START
	for _, spellId in pairs(config.spells) do
		self:SetUInt16(st, SHORT_SPELL_ID, spellId)
		self:SetUInt16(st, SHORT_SPELL_LV, 1)
		st = st + 1
	end
	
	-- 如果是有过期时间的幻化, 就加到过期字典中
	if expire > 0 then
		playerLib.SetToExpireMap(self.ptr, EXPIRE_TYPE_ILLUSION, illuId, expire)
	end
end

function AppSpellMgr:findEmptyIllusionSlot()
	for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, SPELL_INT_FIELD_MOUNT_ILLUSION_END, MAX_ILLUSION_ATTR_COUNT do
		if self:GetUInt32(ILLUSION_ATTR_ID + i) == 0 then
			return i
		end
	end
	
	return -1
end


-- 升级坐骑技能
function AppSpellMgr:raiseIlluSpell(spellId)

	local prev = self:getSpellLevel(spellId)

	for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, SPELL_INT_FIELD_MOUNT_ILLUSION_END, MAX_ILLUSION_ATTR_COUNT do	
		for j = ILLUSION_ATTR_SPELL_START + i, ILLUSION_ATTR_SPELL_END + i do
			if self:GetUInt16(j, SHORT_SPELL_ID) == spellId then
				self:SetUInt16(j, SHORT_SPELL_LV, prev + 1)
				self:SetSpellLevel(spellId, prev+1)
				return
			end
		end
	end
end

-- 获得幻化的binlogindex
function AppSpellMgr:getIllusionBinLogIndex(illuId)
	local indx = -1
	for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, SPELL_INT_FIELD_MOUNT_ILLUSION_END, MAX_ILLUSION_ATTR_COUNT do
		if self:GetUInt32(ILLUSION_ATTR_ID + i) == illuId then
			indx = i
			break
		end
	end
	
	return indx
end

-- 移除幻化
function AppSpellMgr:removeIllusion(illuId)
	-- 清空幻化
	local indx = self:getIllusionBinLogIndex(illuId)
	if indx > -1 then
		self:SetUInt32(ILLUSION_ATTR_ID + indx, 0)
		for i = ILLUSION_ATTR_SPELL_START, ILLUSION_ATTR_SPELL_END-1 do
			self:SetUInt32(i + indx, 0)		
		end
		self:SetUInt32(ILLUSION_ATTR_EXPIRE + indx, 0)
	end
end

-- 获得坐骑幻化技能
function AppSpellMgr:getIllusionSkill(illuId)
	local indx = self:getIllusionBinLogIndex(illuId)
	local skillTable = {}
	
	if indx > -1 then
		for i = ILLUSION_ATTR_SPELL_START, ILLUSION_ATTR_SPELL_END-1 do
			local spellId = self:GetUInt16(i + indx, 0)
			table.insert(skillTable, spellId)
		end
	end
	
	return skillTable
end

----------------------------------------------神兵-----------------------------------------------
--获取神兵列表
function AppSpellMgr:getDivineList()
	local tab = {}
	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		--outFmtInfo("divine %d",i)
		local id = self:GetByte(i,0)
		if id ~= 0  then
			local lev = self:GetByte(i,1)
			tab[id] = lev
		end
	end
	return tab
end
--神兵属性加成
function AppSpellMgr:calculDivineAttr(attrs)
	local tab = self:getDivineList()
	--Ttab(attrs)
	for k,v in pairs(tab) do
		local id = (k-1) * #tb_divine_bless + v + 1
		local config = tb_divine_streng[id].props
		for i=1,#config do
			attrs[config[i][1]] = attrs[config[i][1]] + config[i][2]
		end
	end
	--Ttab(attrs)
end
-- 是否存在神兵
function AppSpellMgr:hasDivine(divineId)
	
	--local count = self:GetUInt32(SPELL_DIVINE_COUNT)
	--local size = SPELL_DIVINE_START + count * MAX_DIVINE_COUNT
	
	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		--outFmtInfo("divine %d",i)
		if self:GetByte(i,0) == divineId then
			return true
		end
	end
	
	return false
end
--添加神兵
function AppSpellMgr:addDivine(divineId,time)
	if self:hasDivine(divineId) then
		return
	end

	--outFmtInfo("add divine %d,%d",divineId,time)

	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		if self:GetByte(i,0) == 0 then
			self:SetByte(i,0,divineId)
			self:SetUInt32(i + DIVINE_TIME,time)
			return true;
		end
	end

	return false;
end

function AppSpellMgr:addDivineSkill(divineId,skill,isPassive)
	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		if self:GetByte(i,0) == divineId then
			outFmtInfo("add skill %d,%d,%d",i,divineId,skill)
			if isPassive then -- 添加被动技能
				for j = 0,2 do 
					local pid = self:GetUInt16(i+DIVINE_PASSIVE_SKILL+j,0)
					if pid == skill then -- 已经存在被动技能
						outFmtError("divine passive skill has exist")
						return
					end

					if pid == 0 then
						self:SetUInt16(i+DIVINE_PASSIVE_SKILL+j,0,skill)
						self:SetUInt16(i+DIVINE_PASSIVE_SKILL+j,1,1)
						return
					end
				end
				outFmtError("divine passive skill canot add")
			else --添加主动技能
				self:SetUInt16(i+DIVINE_SKILL,0,skill)
				self:SetUInt16(i+DIVINE_SKILL,1,1)
			end
		end
	end

end
--获得神兵的index、等级和祝福值
function AppSpellMgr:getDivinIdxLevBless(divineId)
	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		if self:GetByte(i,0) == divineId then
			return i,self:GetByte(i,1),self:GetByte(i,2)
		end
	end
	return 0
end
--设置神兵的等级和祝福值
function AppSpellMgr:setDivinLevBless(index,lev,bless)
	self:SetByte(index,1,lev)
	self:SetUInt16(index,1,bless)
end
--设置神兵的初始主动饥饿ngn
function AppSpellMgr:GetDivineInitiativeSpellInfo(divineId)
	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		if self:GetByte(i,0) == divineId then
			local sid = self:GetUInt16(i+DIVINE_SKILL,0)
			local lev = self:GetUInt16(i+DIVINE_SKILL,1)
			return sid,lev
		end
	end
	return 0,0
end 
--获取神兵被动技能列表
function AppSpellMgr:GetDivinePassiveSpellInfoTable(divineId)
	
	local tab = {}
	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		if self:GetByte(i,0) == divineId then
			for j=0,2 do
				local sid = self:GetUInt16(i+DIVINE_PASSIVE_SKILL+j,0)
				local lev = self:GetUInt16(i+DIVINE_PASSIVE_SKILL+j,1)
				table.insert(tab, {sid, lev})
			end
		end
	end
	return tab
end

--设置神兵技能等级
function AppSpellMgr:DivineSkillUpLev(skillid)
	for i = SPELL_DIVINE_START, SPELL_DIVINE_END, MAX_DIVINE_COUNT do
		if self:GetByte(i,0) ~= 0 then
			local sid = self:GetUInt16(i+DIVINE_SKILL,0)
			local lev = self:GetUInt16(i+DIVINE_SKILL,1)
			--主动技能
			if sid == skillid then
				self:SetUInt16(i+DIVINE_SKILL,1,lev+1)
				-- 同步映射关系
				self:SetSpellLevel(skillid, lev+1)
				return true
			end
			--被动技能
			for j=0,2 do
				sid = self:GetUInt16(i+DIVINE_PASSIVE_SKILL+j,0)
				lev = self:GetUInt16(i+DIVINE_PASSIVE_SKILL+j,1)
				if sid == skillid then
					self:SetUInt16(i+DIVINE_PASSIVE_SKILL+j,1,lev+1)
					
					-- 同步映射关系
					self:SetSpellLevel(skillid, lev+1)
					return true
				end
			end
		end
	end
	return false
end

----------------------------------------------神兵结束-------------------------------------------

----------------------------------------------强化宝石-----------------------------------------------
-- 获取部位强化等级
function AppSpellMgr:getStrengLev(part)
	return self:GetUInt16(SPELL_STRENGTHEN_START + (part-1) * MAX_STRENGTHEN_COUNT,0)
end
-- 设置部位强化等级
function AppSpellMgr:setStrengLev(part,lev)
	self:SetUInt16(SPELL_STRENGTHEN_START + (part-1) * MAX_STRENGTHEN_COUNT,0,lev)
end
-- 获取部位强化祝福值
function AppSpellMgr:getStrengBlessExp(part)
	return self:GetUInt16(SPELL_STRENGTHEN_START + (part-1) * MAX_STRENGTHEN_COUNT,1)
end
-- 设置部位强化祝福值
function AppSpellMgr:setStrengBlessExp(part,val)
	return self:SetUInt16(SPELL_STRENGTHEN_START + (part-1) * MAX_STRENGTHEN_COUNT,1,val)
end
-- 设置全身强化等级加成
function AppSpellMgr:setStrengMul(val)
	return self:SetUInt32(SPELL_STRENGTHEN_ALLMUL,val)
end
-- 获取全身强化等级加成
function AppSpellMgr:getStrengMul()
	return self:GetUInt32(SPELL_STRENGTHEN_ALLMUL)
end

-- 获取部位当前宝石的等级
function AppSpellMgr:getGemCurLev(part)
	local gemid = SPELL_GEM_START + (part-1) * MAX_GEM_COUNT
	local id = self:GetUInt16(gemid + GEM_CURID_BLESS,0)
	local val = self:GetUInt32(gemid + id)
	return val
end
-- 设置当前部位宝石的等级
function AppSpellMgr:setGemCurLev(part,lev)
	local gemid = SPELL_GEM_START + (part-1) * MAX_GEM_COUNT
	local id = self:GetUInt16(gemid + GEM_CURID_BLESS,0)
	return self:SetUInt32(gemid + id,lev)
end

-- 获取部位最小的宝石等级
function AppSpellMgr:getGemMinLev(part)
	local gemid = SPELL_GEM_START + (part-1) * MAX_GEM_COUNT
	local minval = 10000

	for i=0,2 do
		local lev = self:GetUInt32(gemid + i)
		if lev < minval then
			minval = lev
		end
	end

	return minval
end
--获取所有宝石等级
function AppSpellMgr:getGemAllLev(part)
	local gemid = SPELL_GEM_START + (part-1) * MAX_GEM_COUNT
	local tab = {}
	for i=0,2 do
		local lev = self:GetUInt32(gemid + i)
		table.insert(tab,lev)
	end
	return tab
end

-- 获取部位当前宝石的祝福值
function AppSpellMgr:getGemCurBless(part)
	local gemid = SPELL_GEM_START + (part-1) * MAX_GEM_COUNT
	return self:GetUInt16(gemid + GEM_CURID_BLESS,1)
end

-- 设置当前宝石的祝福值
function AppSpellMgr:setGemCurBless(part,val)
	local gemid = SPELL_GEM_START + (part-1) * MAX_GEM_COUNT
	self:SetUInt16(gemid + GEM_CURID_BLESS,1,val)
end
-- 切换宝石的当前ID 0->1->2->0->1->...
function AppSpellMgr:setGemChgID(part)
	local gemid = SPELL_GEM_START + (part-1) * MAX_GEM_COUNT
	local cid = self:GetUInt16(gemid + GEM_CURID_BLESS,0)
	if cid == 2 then
		cid = 0
	else 
		cid = cid + 1
	end
	self:SetUInt16(gemid + GEM_CURID_BLESS,0,cid)
end

-- 设置全身宝石等级加成
function AppSpellMgr:setGemMul(val)
	return self:SetUInt32(SPELL_GEM_ALLMUL,val)
end
-- 获取全身宝石等级加成
function AppSpellMgr:getGemMul()
	return self:GetUInt32(SPELL_GEM_ALLMUL)
end
----------------------------------------------强化宝石结束-------------------------------------------

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