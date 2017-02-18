LogindPlayer = class('LogindPlayer', BinLogObject)

function LogindPlayer:GetAccount()
	return self:GetStr(PLAYER_STRING_FIELD_ACCOUNT)
end

function LogindPlayer:DefereSuccess()
	local slavehoder = self:GetSlavehoder()
	if(slavehoder > 0)then
		self:SetUInt32(PLAYER_FIELD_SLAVEHODER, -slavehoder)
	end
end

-- 获得角色id
function LogindPlayer:GetGender()
	return self:GetByte(PLAYER_FIELD_BYTES_0, 0)
end

--获取某玩家标志位
function LogindPlayer:GetFlags(index)
	return self:GetBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

function LogindPlayer:UnSetFlags(index)
	return self:UnSetBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end


--获取某玩家礼包标志位
function LogindPlayer:GetGiftFlags(index)
	return self:GetBit(PLAYER_APPD_INT_FIELD_GIFT_FLAG, index)
end

--获取MapId
function LogindPlayer:GetMapId()
	return self:GetUInt32(PLAYER_FIELD_MAP_ID)
end

--设置传送的地图id和坐标
function LogindPlayer:SetTeleportInfo(mapid, posx, posy, general_id)
	self:SetUInt32(PLAYER_EXPAND_INT_TO_MAP, mapid)
	self:SetFloat(PLAYER_EXPAND_INT_TO_POS_X, posx)
	self:SetFloat(PLAYER_EXPAND_INT_TO_POS_Y, posy)
	self:SetUInt32(PLAYER_FIELD_INSTANCE_ID, 0)
	--outDebug('guid = '..self:GetGuid()..' name = '..self:GetName()..' mapid = '..mapid..' posx = '..posx..' posy = '..posy)
	if(general_id)then
		self:SetStr(PLAYER_STRING_FIELD_TELEPORT_GUID, general_id)
	end
end

KUAFU_FENGLIUZHEN_MAPID = 3002
--pk服，根据跨服类型选择要传送到的地图id
function LogindPlayer:SelectKuafuMapid(warid, kuafu_type, number, reverse, reverse_str)
	if(kuafu_type == KUAFU_TYPE_FENGLIUZHEN)then
		local general_id = string.format("flz_%s", reverse_str)		--warid即房间id
		outFmtDebug("######################SelectKuafuMapid general_id = %s, pos = %d", general_id, reverse)
		local config = tb_kuafu3v3_base[ 1 ].bornPos
		local pos = config[reverse]
		-- 设置玩家的虚拟阵营
		self:SetUInt32(PLAYER_INT_FIELD_VIRTUAL_CAMP, reverse)
		self:SetTeleportInfo(KUAFU_FENGLIUZHEN_MAPID, pos[ 1 ], pos[ 2 ], general_id)
		return true
	end
	
	return false
end

--离线做些什么
function LogindPlayer:Logout()
	
end

--付费等级计算
function LogindPlayer:DoPayLevel()
	local pay_table = {0,5000,20000,50000,100000,200000,500000,800000,1000000,1500000,2000000}
	local rechage = self:GetUInt32(PLAYER_APPD_INT_FIELD_RECHARGE_SUM)
	local pay_level = #pay_table - 1
	for i = 1,#pay_table do
		if(rechage < pay_table[i])then
			pay_level = i - 2
			break
		end
	end
	return pay_level
end


--合服数据处理
function DoMergeSomething()

end

--生命
function LogindPlayer:SetHealth(val)
	self:SetDouble(PLAYER_FIELD_HEALTH, val)
end

--设置最大生命
function LogindPlayer:SetMaxhealth(val)
	self:SetDouble(PLAYER_FIELD_MAXHEALTH, val)
end

--设置攻击力
function LogindPlayer:SetDamage(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE, val)
end

--设置防御力
function LogindPlayer:SetArmor(val)
	self:SetDouble(PLAYER_FIELD_ARMOR, val)
end

--设置命中
function LogindPlayer:SetHit(val)
	self:SetDouble(PLAYER_FIELD_HIT, val)
end

--设置闪避
function LogindPlayer:SetDodge(val)
	self:SetDouble(PLAYER_FIELD_DODGE, val)
end

--设置暴击
function LogindPlayer:SetCrit(val)
	self:SetDouble(PLAYER_FIELD_CRIT, val)
end

--设置坚韧
function LogindPlayer:SetTough(val)
	self:SetDouble(PLAYER_FIELD_TOUGH, val)
end

--设置攻击速度
function LogindPlayer:SetAttackSpeed(val)
	self:SetDouble(PLAYER_FIELD_ATTACK_SPEED, val)
end

--设置移动速度
function LogindPlayer:SetMoveSpeed(val)
	self:SetDouble(PLAYER_FIELD_MOVE_SPEED, val)
end

--设置伤害加深(万分比)
function LogindPlayer:SetAmplifyDamage(val)
	self:SetDouble(PLAYER_FIELD_AMPLIFY_DAMAGE, val)
end

--设置忽视防御(万分比)
function LogindPlayer:SetIgnoreDefense(val)
	self:SetDouble(PLAYER_FIELD_IGNORE_DEFENSE, val)
end

--设置伤害减免(万分比)
function LogindPlayer:SetDamageResist(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE_RESIST, val)
end

--设置反弹伤害(万分比)
function LogindPlayer:SetDamageReturned(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE_RETURNED, val)
end

--设置命中率加成(万分比)
function LogindPlayer:SetHitRate(val)
	self:SetDouble(PLAYER_FIELD_HIT_RATE, val)
end

--设置闪避率加成(万分比)
function LogindPlayer:SetDodgeRate(val)
	self:SetDouble(PLAYER_FIELD_DODGE_RATE, val)
end

--设置暴击率加成(万分比)
function LogindPlayer:SetCritRate(val)
	self:SetDouble(PLAYER_FIELD_CRIT_RATE, val)
end

--设置抗暴率加成(万分比)
function LogindPlayer:SetCriticalResistRate(val)
	self:SetDouble(PLAYER_FIELD_CRITICAL_RESIST_RATE, val)
end

--设置暴击伤害倍数(万分比)
function LogindPlayer:SetDamageCritMultiple(val)
	self:SetDouble(PLAYER_FIELD_DAMAGE_CRIT_MULTIPLE, val)
end

--设置降暴伤害倍数(万分比)
function LogindPlayer:SetResistCritMultiple(val)
	self:SetDouble(PLAYER_FIELD_RESIST_CRIT_MULTIPLE, val)
end

-- 设置战力
function LogindPlayer:SetForce(val)
	self:SetDouble(PLAYER_FIELD_FORCE, val)
end

-- LogindPlayer的属性映射方法
InitAttrFunc = {
	[EQUIP_ATTR_MAXHEALTH] = LogindPlayer.SetMaxhealth,
	[EQUIP_ATTR_DAMAGE] = LogindPlayer.SetDamage,
	[EQUIP_ATTR_ARMOR] = LogindPlayer.SetArmor,
	[EQUIP_ATTR_HIT] = LogindPlayer.SetHit,
	[EQUIP_ATTR_DODGE] = LogindPlayer.SetDodge,
	[EQUIP_ATTR_CRIT] = LogindPlayer.SetCrit,
	[EQUIP_ATTR_TOUGH] = LogindPlayer.SetTough,
	[EQUIP_ATTR_ATTACK_SPEED] = LogindPlayer.SetAttackSpeed,
	[EQUIP_ATTR_MOVE_SPEED] = LogindPlayer.SetMoveSpeed,
	[EQUIP_ATTR_AMPLIFY_DAMAGE] = LogindPlayer.SetAmplifyDamage,
	[EQUIP_ATTR_IGNORE_DEFENSE] = LogindPlayer.SetIgnoreDefense,
	[EQUIP_ATTR_DAMAGE_RESIST] = LogindPlayer.SetDamageResist,
	[EQUIP_ATTR_DAMAGE_RETURNED] = LogindPlayer.SetDamageReturned,
	[EQUIP_ATTR_HIT_RATE] = LogindPlayer.SetHitRate,
	[EQUIP_ATTR_DODGE_RATE] = LogindPlayer.SetDodgeRate,
	[EQUIP_ATTR_CRIT_RATE] = LogindPlayer.SetCritRate,
	[EQUIP_ATTR_CRITICAL_RESIST_RATE] = LogindPlayer.SetCriticalResistRate,
	[EQUIP_ATTR_DAMAGE_CRIT_MULTIPLE] = LogindPlayer.SetDamageCritMultiple,
	[EQUIP_ATTR_RESIST_CRIT_MULTIPLE] = LogindPlayer.SetResistCritMultiple,
}

--设置玩家初始信息
function LogindPlayer:SetNewPlayerInfo()
	-- 初始化属性
	local config = tb_char_level[1]
	if config then
		self:SetDouble(PLAYER_EXPAND_INT_NEXT_LEVEL_XP, config.next_exp)
		for _, val in ipairs(config.prop)do
			local func = InitAttrFunc[val[ 1 ]];
			if func ~= nil then
				func(self, val[2])
				-- 需要设置当前血量
				if val[ 1 ] == EQUIP_ATTR_MAXHEALTH then
					self:SetHealth(val[ 2 ])
				end
			end
		end
	end
	
	-- 计算战力
	local force = DoAnyOneCalcForceByAry(config.prop)
	self:SetForce(force)

	-- 初始化玩家技能
	local gender = self:GetGender()
	local config = tb_char_skill[gender]

	if config then
		-- 初始主动技能
		local initiativeStart = PLAYER_INT_FIELD_SPELL_START
		
		for _, spellId in ipairs(config.init_spell) do
			
			local spellBaseConfig = tb_skill_base[spellId]
			if spellBaseConfig ~= nil then
				-- 主动技能列表
				self:SetUInt16(initiativeStart, SHORT_SLOT_SPELL_ID, spellId)
				self:SetByte(initiativeStart, BYTE_SLOT_SPELL_LV,		1)
				local slot = spellBaseConfig.skill_slot
				self:SetByte(initiativeStart, BYTE_SLOT,	slot)
				initiativeStart = initiativeStart + 1
			end
		end
	end
end