--获得当前生命
function PlayerInfo:GetHealth()
	return self:GetDouble(PLAYER_FIELD_HEALTH)
end

--设置当前生命
function PlayerInfo:SetHealth(val)
	self:SetDouble(PLAYER_FIELD_HEALTH, val)
end

--获得最大生命
function PlayerInfo:GetMaxhealth()
	return self:GetDouble(PLAYER_FIELD_MAXHEALTH)
end

--设置最大生命
function PlayerInfo:SetMaxhealth(val)
	self:SetDouble(PLAYER_FIELD_MAXHEALTH, val)
--	self:SetHealth(val)
end

--获得攻击力
function PlayerInfo:GetDamage()
	return self:GetDouble(PLAYER_FIELD_DAMAGE)
end

--设置攻击力
function PlayerInfo:SetDamage(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE, val)
end

--获得防御力
function PlayerInfo:GetArmor()
	return self:GetDouble(PLAYER_FIELD_ARMOR)
end

--设置防御力
function PlayerInfo:SetArmor(val)
	self:SetDouble(PLAYER_FIELD_ARMOR, val)
end

--获得命中
function PlayerInfo:GetHit()
	return self:GetDouble(PLAYER_FIELD_HIT)
end

--设置命中
function PlayerInfo:SetHit(val)
	self:SetDouble(PLAYER_FIELD_HIT, val)
end

--获得闪避
function PlayerInfo:GetDodge()
	return self:GetDouble(PLAYER_FIELD_DODGE)
end

--设置闪避
function PlayerInfo:SetDodge(val)
	self:SetDouble(PLAYER_FIELD_DODGE, val)
end

--获得暴击
function PlayerInfo:GetCrit()
	return self:GetDouble(PLAYER_FIELD_CRIT)
end

--设置暴击
function PlayerInfo:SetCrit(val)
	self:SetDouble(PLAYER_FIELD_CRIT, val)
end

--获得坚韧
function PlayerInfo:GetTough()
	return self:GetDouble(PLAYER_FIELD_TOUGH)
end

--设置坚韧
function PlayerInfo:SetTough(val)
	self:SetDouble(PLAYER_FIELD_TOUGH, val)
end

--获得攻击速度
function PlayerInfo:GetAttackSpeed()
	return self:GetDouble(PLAYER_FIELD_ATTACK_SPEED)
end

--设置攻击速度
function PlayerInfo:SetAttackSpeed(val)
	self:SetDouble(PLAYER_FIELD_ATTACK_SPEED, val)
end

--获得伤害加深(万分比)
function PlayerInfo:GetAmplifyDamage()
	return self:GetDouble(PLAYER_FIELD_AMPLIFY_DAMAGE)
end

--设置伤害加深(万分比)
function PlayerInfo:SetAmplifyDamage(val)
	self:SetDouble(PLAYER_FIELD_AMPLIFY_DAMAGE, val)
end

--获得忽视防御(万分比)
function PlayerInfo:GetIgnoreDefense()
	return self:GetDouble(PLAYER_FIELD_IGNORE_DEFENSE)
end

--设置忽视防御(万分比)
function PlayerInfo:SetIgnoreDefense(val)
	self:SetDouble(PLAYER_FIELD_IGNORE_DEFENSE, val)
end

--获得伤害减免(万分比)
function PlayerInfo:GetDamageResist()
	return self:GetDouble(PLAYER_FIELD_DAMAGE_RESIST)
end

--设置伤害减免(万分比)
function PlayerInfo:SetDamageResist(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE_RESIST, val)
end

--获得反弹伤害(万分比)
function PlayerInfo:GetDamageReturned()
	return self:GetDouble(PLAYER_FIELD_DAMAGE_RETURNED)
end

--设置反弹伤害(万分比)
function PlayerInfo:SetDamageReturned(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE_RETURNED, val)
end

--获得命中率加成(万分比)
function PlayerInfo:GetHitRate()
	return self:GetDouble(PLAYER_FIELD_HIT_RATE)
end

--设置命中率加成(万分比)
function PlayerInfo:SetHitRate(val)
	self:SetDouble(PLAYER_FIELD_HIT_RATE, val)
end

--获得闪避率加成(万分比)
function PlayerInfo:GetDodgeRate()
	return self:GetDouble(PLAYER_FIELD_DODGE_RATE)
end

--设置闪避率加成(万分比)
function PlayerInfo:SetDodgeRate(val)
	self:SetDouble(PLAYER_FIELD_DODGE_RATE, val)
end

--获得暴击率加成(万分比)
function PlayerInfo:GetCritRate()
	return self:GetDouble(PLAYER_FIELD_CRIT_RATE)
end

--设置暴击率加成(万分比)
function PlayerInfo:SetCritRate(val)
	self:SetDouble(PLAYER_FIELD_CRIT_RATE, val)
end

--获得抗暴率加成(万分比)
function PlayerInfo:GetCriticalResistRate()
	return self:GetDouble(PLAYER_FIELD_CRITICAL_RESIST_RATE)
end

--设置抗暴率加成(万分比)
function PlayerInfo:SetCriticalResistRate(val)
	self:SetDouble(PLAYER_FIELD_CRITICAL_RESIST_RATE, val)
end

--获得暴击伤害倍数(万分比)
function PlayerInfo:GetDamageCritMultiple()
	return self:GetDouble(PLAYER_FIELD_DAMAGE_CRIT_MULTIPLE)
end

--设置暴击伤害倍数(万分比)
function PlayerInfo:SetDamageCritMultiple(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE_CRIT_MULTIPLE, val)
end

--获得降暴伤害倍数(万分比)
function PlayerInfo:GetResistCritMultiple()
	return self:GetDouble(PLAYER_FIELD_RESIST_CRIT_MULTIPLE)
end

--设置降暴伤害倍数(万分比)
function PlayerInfo:SetResistCritMultiple(val)
	self:SetDouble(PLAYER_FIELD_RESIST_CRIT_MULTIPLE, val)
end

--获得移动速度
function PlayerInfo:GetMoveSpeed()
	return self:GetDouble(PLAYER_FIELD_MOVE_SPEED)
end

--设置移动速度
function PlayerInfo:SetMoveSpeed(val)
	self:SetDouble(PLAYER_FIELD_MOVE_SPEED, val)
end

-- PlayerInfo的属性映射方法
PlayerInfo_Set_Attr_Func = {
	[EQUIP_ATTR_MAXHEALTH] = PlayerInfo.SetMaxhealth,
	[EQUIP_ATTR_DAMAGE] = PlayerInfo.SetDamage,
	[EQUIP_ATTR_ARMOR] = PlayerInfo.SetArmor,
	[EQUIP_ATTR_HIT] = PlayerInfo.SetHit,
	[EQUIP_ATTR_DODGE] = PlayerInfo.SetDodge,
	[EQUIP_ATTR_CRIT] = PlayerInfo.SetCrit,
	[EQUIP_ATTR_TOUGH] = PlayerInfo.SetTough,
	[EQUIP_ATTR_ATTACK_SPEED] = PlayerInfo.SetAttackSpeed,
	[EQUIP_ATTR_MOVE_SPEED] = PlayerInfo.SetMoveSpeed,
	[EQUIP_ATTR_AMPLIFY_DAMAGE] = PlayerInfo.SetAmplifyDamage,
	[EQUIP_ATTR_IGNORE_DEFENSE] = PlayerInfo.SetIgnoreDefense,
	[EQUIP_ATTR_DAMAGE_RESIST] = PlayerInfo.SetDamageResist,
	[EQUIP_ATTR_DAMAGE_RETURNED] = PlayerInfo.SetDamageReturned,
	[EQUIP_ATTR_HIT_RATE] = PlayerInfo.SetHitRate,
	[EQUIP_ATTR_DODGE_RATE] = PlayerInfo.SetDodgeRate,
	[EQUIP_ATTR_CRIT_RATE] = PlayerInfo.SetCritRate,
	[EQUIP_ATTR_CRITICAL_RESIST_RATE] = PlayerInfo.SetCriticalResistRate,
	[EQUIP_ATTR_DAMAGE_CRIT_MULTIPLE] = PlayerInfo.SetDamageCritMultiple,
	[EQUIP_ATTR_RESIST_CRIT_MULTIPLE] = PlayerInfo.SetResistCritMultiple,
}


function PlayerInfo:RecalcAttrAndBattlePoint()
	playerLib.SendAttr(self.ptr)
end

--属性重算入口
function PlayerInfo:DoCalculAttr  ( attr_binlog)
	-- 如果是跨服的就不重算了
	local isPkServer = globalGameConfig:IsPKServer()
	if isPkServer then
		return
	end
	
	local attrs = {}
	local battleForce = 0
	for attrId,_ in pairs(PlayerInfo_Set_Attr_Func) do
		attrs[attrId] = 0
	end
	
	-- 玩家基础属性
	local level = self:GetLevel()
	local config = tb_char_level[level]
	if config then
		for _, val in ipairs(config.prop) do
			local indx = val[ 1 ]
			-- 不是速度属性 或者 是速度属性 但是未骑乘
			if indx ~= EQUIP_ATTR_MOVE_SPEED then
				attrs[indx] = val[ 2 ]
			end
		end
		-- battleForce = battleForce + DoAnyOneCalcForceByAry(config.prop)
	end
	
	printAttr("base ", attrs)
	
	-- 技能管理类
	local spellMgr = self:getSpellMgr()
	
	--基础技能战力
	for i = SPELL_INT_FIELD_BASE_SPELL_START, SPELL_INT_FIELD_BASE_SPELL_END - 1 do
		local spellID	= spellMgr:GetUInt16(i, 0)
		local lv 		= spellMgr:GetUInt16(i, 1)
		if spellID > 0 then
			local bp = self:GetSkillBattlePoint(spellID, lv)
			battleForce = battleForce + bp
		end
	end
	
	outFmtDebug("base skill force %d", battleForce)
	
	-- 装备
	local itemMgr = self:getItemMgr()
	if itemMgr then 
		itemMgr:itemCalculAttr(attrs) 
	end
	
	printAttr("suit ", attrs)

	-- 坐骑
	local nonForce = spellMgr:calculMountAttr(attrs)
	battleForce = battleForce + nonForce
	
	outFmtDebug("mount force %d", battleForce)
		
	printAttr("mount ", attrs)
	
	-- 幻化
	for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, SPELL_INT_FIELD_MOUNT_ILLUSION_END, MAX_ILLUSION_ATTR_COUNT do
		local illusionId = spellMgr:GetUInt32(i+ILLUSION_ATTR_ID)
		if illusionId > 0 then
			local illuConfig = tb_mount_illusion[illusionId]
			-- 属性
			for _, val in ipairs(illuConfig.pros)do
				local indx = val[ 1 ]
				-- 速度属性就不在这里计算了
				if indx ~= EQUIP_ATTR_MOVE_SPEED then
					if attrs[indx] == nil then
						attrs[indx] = 0
					end
					attrs[indx] = attrs[indx] + val[ 2 ]
				end
			end
			
			-- 坐骑幻化技能战力
			for j = ILLUSION_ATTR_SPELL_START + i, ILLUSION_ATTR_SPELL_END + i - 1 do
				local spellID	= spellMgr:GetUInt16(j, 0)
				local lv		= spellMgr:GetUInt16(j, 1)
				if spellID > 0 then
					local bp = self:GetSkillBattlePoint(spellID, lv)
					battleForce = battleForce + bp
				end
			end
		end
	end
	
	
	outFmtDebug("illusion force %d", battleForce)	
	printAttr("illusion ", attrs)

	-- 神兵
	spellMgr:calculDivineAttr(attrs)
	
	printAttr("divine ", attrs)
	
	--称号
	self:calculTitleAttr(attrs)
	
	printAttr("title ", attrs)
	
	-- 获得玩家速度
	local speed = GetPlayerSpeed(self:GetLevel(), spellMgr:getMountLevel(), self:GetCurrIllusionId(), self:isRide())
	attrs[EQUIP_ATTR_MOVE_SPEED] = speed
	
	-- 算属性的战力
	battleForce = battleForce + DoAnyOneCalcForce(attrs)
	-- 设置到playerBase中
	for attrId, val in pairs(attrs) do
		--local index = attrId - 1
		--binLogLib.SetUInt32(attr_binlog, index, val)
			
		local func = PlayerInfo_Set_Attr_Func[attrId]
		if func then
			local index = attrId - 1
			func(self, val)
		end
	end
	
	outFmtDebug("all force %d", battleForce)	
	
	binLogLib.SetDouble(attr_binlog, 0, battleForce)
end

function printAttr(str, dict)
	outFmtDebug("attr after %s", str)
	local list = {}
	for k, v in pairs(dict) do
		table.insert(list, k..":"..v)
	end
	outFmtDebug(string.join(" ", list))
	outFmtDebug("----------------")
end

function PlayerInfo:GetSkillBattlePoint(spellId, lv)
	local indx = tb_skill_base[spellId].uplevel_id[ 1 ] + lv - 1
	return tb_skill_uplevel[indx].fight_value
end

--重设装备下标
function PlayerInfo:UpdatePlayerEquipment  ()
	for i = 0, EQUIPMENT_TYPE_MAX_POS-1 do
		self:UpdateEquipDisplay(i)
	end
end

--更新玩家装备显示
function PlayerInfo:UpdateEquipDisplay  ( pos)
	local useFashion = self:GetBit(PLAYER_EXPAND_INT_USE_FASHION, pos)
	
	--时装优先
	if (useFashion) then
		local fashion_pos = pos + EQUIPMENT_TYPE_MAX_POS
		if (self:TrySetEquipment(pos, fashion_pos))then
			return
		end
	end
	-- --看下普通位置
	-- if(pos == EQUIPMENT_TYPE_MAIN_WEAPON)then
	-- --已穿戴的兵魂设置
	-- for i = SHENBING_TYPE_TANLANGXING, MAX_SHENBING_TYPE - 1 do
	-- if(self:GetShenBingWearFlags(i))then
	-- if(tb_weapon[i+1].item_id ~= nil)then
	-- self:SetEquipment(EQUIPMENT_TYPE_MAIN_WEAPON, tb_weapon[i+1].item_id)
	-- end
	-- return
	-- end
	-- end
	-- end
	
	if (self:TrySetEquipment(pos, pos))then
		return
	end
--	什么都没有
	self:SetEquipment(pos, 0)
end

--尝试下设置装备显示
function PlayerInfo:TrySetEquipment  (equip_pos,item_pos)
	local itemMgr = self:getItemMgr()
	local item = itemMgr:getBagItemByPos(BAG_TYPE_EQUIP, item_pos)
	if item then
		local entry = item:getEntry()
		if (entry) then
			self:SetEquipment(equip_pos, entry)
			return true
		end
	end
	
	return false
end

