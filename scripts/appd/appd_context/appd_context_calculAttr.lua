-- PlayerInfo的属性个数
PlayerInfo_Set_Attr = {
	EQUIP_ATTR_MAXHEALTH, 
	EQUIP_ATTR_DAMAGE, 
	EQUIP_ATTR_ARMOR,
	EQUIP_ATTR_HIT,
	EQUIP_ATTR_DODGE,
	EQUIP_ATTR_CRIT,
	EQUIP_ATTR_TOUGH,
	EQUIP_ATTR_ATTACK_SPEED,
	EQUIP_ATTR_MOVE_SPEED,
	EQUIP_ATTR_AMPLIFY_DAMAGE,
	EQUIP_ATTR_IGNORE_DEFENSE,
	EQUIP_ATTR_DAMAGE_RESIST,
	EQUIP_ATTR_DAMAGE_RETURNED,
	EQUIP_ATTR_HIT_RATE,
	EQUIP_ATTR_DODGE_RATE,
	EQUIP_ATTR_CRIT_RATE,
	EQUIP_ATTR_CRITICAL_RESIST_RATE,
	EQUIP_ATTR_DAMAGE_CRIT_MULTIPLE,
	EQUIP_ATTR_RESIST_CRIT_MULTIPLE
}


function PlayerInfo:RecalcAttrAndBattlePoint()
	playerLib.SendAttr(self.ptr)
end

--属性重算入口
function PlayerInfo:DoCalculAttr  ( attr_binlog)
	-- TODO: 应用服计算属性
	local attrs = {}
	local nonePropBattlePoint = 0
	
	-- 技能管理类
	local spellMgr = self:getSpellMgr()
	
	--基础技能战力
	for i = SPELL_INT_FIELD_BASE_SPELL_START, SPELL_INT_FIELD_BASE_SPELL_END - 1 do
		local spellID	= spellMgr:GetUInt16(i, 0)
		local lv 		= spellMgr:GetUInt16(i, 1)
		if spellID > 0 then
			local bp = self:GetSkillBattlePoint(spellID, lv)
			nonePropBattlePoint = nonePropBattlePoint + bp
		end
	end

	-- 装备
	
	-- 坐骑
	local level = spellMgr:getMountLevel()
	local star  = spellMgr:getMountStar()
	local seq = (level - 1) * 11 + star + 1
	
	local trainConfig = tb_mount_train[seq]
	if trainConfig then
		-- 属性
		for _, val in ipairs(trainConfig.pros)do
			local indx = val[ 1 ]
			-- 速度属性就不在这里计算了
			if indx ~= EQUIP_ATTR_MOVE_SPEED then
				if attrs[indx] == nil then
					attrs[indx] = 0
				end
				attrs[indx] = attrs[indx] + val[ 2 ]
			end
		end
		
		--TODO 坐骑进阶技能战力
		for i = SPELL_INT_FIELD_MOUNT_SPELL_START, SPELL_INT_FIELD_MOUNT_SPELL_END - 1 do
			local spellID	= spellMgr:GetUInt16(i, 0)
			local lv 		= spellMgr:GetUInt16(i, 1)
			if spellID > 0 then
				local bp = self:GetSkillBattlePoint(spellID, lv)
				nonePropBattlePoint = nonePropBattlePoint + bp
			end
		end
		
		--TODO 坐骑幻化技能战力
		for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, SPELL_INT_FIELD_MOUNT_ILLUSION_END, MAX_ILLUSION_ATTR_COUNT do	
			for j = ILLUSION_ATTR_SPELL_START + i, ILLUSION_ATTR_SPELL_END + i - 1 do
				local spellID	= spellMgr:GetUInt16(j, 0)
				local lv		= spellMgr:GetUInt16(j, 1)
				if spellID > 0 then
					local bp = self:GetSkillBattlePoint(spellID, lv)
					nonePropBattlePoint = nonePropBattlePoint + bp
				end
			end
		end
		
	end
	
	-- 神兵
	
	
	-- 设置到playerBase中
	for attrId, val in pairs(attrs) do
		local index = attrId - 1
		binLogLib.SetUInt32(attr_binlog, index, val)
	end
	
	-- 设置非属性战力
	binLogLib.SetUInt32(attr_binlog, #PlayerInfo_Set_Attr, nonePropBattlePoint)
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

