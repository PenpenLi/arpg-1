require("math")
--------------------------------------

--------------------------------------------------------------------------------------------------------------
-- 传送的时候该做点什么事
function DoPlayerTeleport(player)
	local playerInfo = UnitInfo:new{ptr = player}
	playerInfo:RemoveUseGameObjectFlag()
end


--玩家脱离战斗之后干点什么事情
function DosometingScript(player)
	
end

-- PVP战斗死亡的逻辑
function OnPVPKilled(killer, target)
	local killerInfo = UnitInfo:new{ptr = killer}
	-- 加仇人列表
	playerLib.SendToAppdDoSomething(target, SCENED_APPD_ADD_ENEMY, 1, killerInfo:GetPlayerGuid())
end

--玩家PVP时目标方的一些处理
function DOPlayerPvP(player,target)
	--[[
		1、取消骑乘状态并锁定为不可使用
		2、取消打坐状态并锁定为不可使用
		3、取消采集状态
		
		假如当前为和平模式，则切换为自卫模式
	]]
	
	local targetInfo = UnitInfo:new {ptr = target}
	if targetInfo:isPeaceMode() then
		targetInfo:ChangeToFamilyMode()
	end
	
	local mapid = unitLib.GetMapID(target)
	local map_ptr = unitLib.GetMap(target)
	local openguid = mapLib.GetOnOpenGuid(map_ptr)
	local myguid = playerLib.GetPlayerGuid(target)
	if openguid ~= myguid then
		return
	end
	
	local mapInfo = Select_Instance_Script(mapid):new {ptr = map_ptr}
	mapInfo:OnDisrupt(player)
	
	--取消打坐	
	--[[if playerInfo:GetDaZuoTime() > 0 then
		playerInfo:ReceiveDaZuo()
	end--]]
end

-- 怪物攻击玩家时的一些处理
function DOPlayerPvE(creature, target)
	
	local mapid = unitLib.GetMapID(target)
	local map_ptr = unitLib.GetMap(target)
	local openguid = mapLib.GetOnOpenGuid(map_ptr)
	local myguid = playerLib.GetPlayerGuid(target)
	if openguid ~= myguid then
		return
	end
	
	local mapInfo = Select_Instance_Script(mapid):new {ptr = map_ptr}
	mapInfo:OnDisrupt(player)
	
	--取消打坐
	--[[
	if playerInfo:GetDaZuoTime() > 0 then
		playerInfo:ReceiveDaZuo()
	end
	]]
end

--上线清除一些BUFF
function DoOnlineClearBuff(player)
	

end

function DOTiaozhanBonus(player,lv)	
	-- local bonus = {}
	-- bonus[EQUIP_ATTR_HP] = 0
	-- bonus[EQUIP_ATTR_DAMAGE] = 0
	-- bonus[EQUIP_ATTR_DEF] =    0
	-- bonus[EQUIP_ATTR_HIT] =    0
	-- bonus[EQUIP_ATTR_CRIT] =   0
	-- bonus[EQUIP_ATTR_MANA] =   0

	-- for i = 1,80,1
	-- do
		-- if(hasAchievementsBonus(player,i-1,SERIES_CHALLENGE)==1 and hasAchievements(player,i-1,SERIES_CHALLENGE)==1)then
			-- --生命	攻击	防御	命中	重击
			-- bonus[EQUIP_ATTR_HP] = bonus[EQUIP_ATTR_HP] + ChallengeAttrBonus[i][1]
			-- bonus[EQUIP_ATTR_DAMAGE] = bonus[EQUIP_ATTR_DAMAGE] + ChallengeAttrBonus[i][2]
			-- bonus[EQUIP_ATTR_DEF] = bonus[EQUIP_ATTR_DEF] +ChallengeAttrBonus[i][3]
			-- bonus[EQUIP_ATTR_HIT] = bonus[EQUIP_ATTR_HIT] + ChallengeAttrBonus[i][4]
			-- bonus[EQUIP_ATTR_CRIT] = bonus[EQUIP_ATTR_CRIT] + ChallengeAttrBonus[i][5]
			-- bonus[EQUIP_ATTR_MANA] = bonus[EQUIP_ATTR_MANA] + ChallengeAttrBonus[i][6]
		-- end
	-- end

	-- return (bonus[EQUIP_ATTR_HP]/25.72 + bonus[EQUIP_ATTR_MANA]/102.88 + bonus[EQUIP_ATTR_DAMAGE]/1.55 + bonus[EQUIP_ATTR_DEF]/4.34 +bonus[EQUIP_ATTR_HIT]/1.03 + bonus[EQUIP_ATTR_CRIT]/1.37)*2.12

end



----------------------------------计算战斗公式----------------------------------
-- 攻方命中率=min(命中 * 10000 /(命中+4*lv+20)+命中率增加(万分比),1)
-- 守方闪避率=max((闪避-忽视闪避(攻方))* 10000 /(闪避-忽视闪避(攻方)+lv*150+3000)+闪避率增加,0)
-- 实际命中率=攻方命中率-守方闪避率
-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- return
--		是否命中
function isHit(attackInfo, hurtInfo)
	-- 小怪必定命中
	if hurtInfo:GetTypeID() == TYPEID_UNIT and not hurtInfo:GetUnitFlags(UNIT_FIELD_FLAGS_IS_BOSS_CREATURE) then
		return true
	end
	local casterHit  = math.min(attackInfo:GetHit() * 10000 / (attackInfo:GetHit() + 4 * attackInfo:GetLevel() + 20) + attackInfo:GetHitRate(), 10000)
	local targetMiss1 = hurtInfo:GetMiss() - attackInfo:GetIgnoreMiss()
	local targetMiss = math.max(targetMiss1 * 10000 / (targetMiss1 + hurtInfo:GetLevel() * 150 + 3000) + hurtInfo:GetMissRate(), 0)
	local p = math.floor(casterHit - targetMiss)
	local val = randInt(1, 10000)
	
	return val <= p
end

-- 防御免伤=(防御-忽视防御)/((防御-忽视防御)*1.25+500+22.5*lv)
-- PS：此处防御是守方防御，忽视防御是攻方的忽视防御，lv是守方等级

-- 最终伤害=技能伤害*防御免伤*伤害增强*(1-伤害减免)
-- PS：此处伤害增强是攻方的伤害增强属性，伤害减免是守方的伤害减免属性

-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- @param skillLevel: 攻击方技能等级
-- @param skillDamFactor: 攻击方技能伤害修正系数(填表的)
-- @param skillDamVal: 攻击方技能伤害附加值(填表的)
-- return
--		伤害
function getCastDamage(attackInfo, hurtInfo, skillLevel, skillDamFactor, skillDamVal)
	
	-- 防御免伤
	local armorDiff = hurtInfo:GetArmor() - attackInfo:GetIgnoreArmor()
	if armorDiff < 0 then
		armorDiff = 0
	end
	local armorResit = armorDiff / (armorDiff * 1.25 + 500 + 22.5 * hurtInfo:GetLevel())
	-- 技能伤害
	local skillam = getSkillDam(attackInfo:GetDamage(), skillDamFactor, skillDamVal)
	-- 最终伤害
	local normalDam = math.floor(skillam * (1-armorResit) * (1 + attackInfo:GetDamageAmplifyRate() / 10000) * (10000 - hurtInfo:GetDamageResistRate()) / 10000)
	return normalDam
end

-- 伤害随机区间：[85%, 115%]
-- return
--		随机伤害比率
function getDamRange()
	return randInt(85, 115) / 100
end

-- 技能伤害=(攻击*技能伤害系数+技能附加伤害)*伤害随机区间
-- 伤害随机区间：[85%,115%]
function getSkillDam(damage, skillDamFactor, skillDamVal)
	-- 伤害随机区间
	local damRange = getDamRange()
	return (damage * skillDamFactor + skillDamVal) * damRange
end

--[[
	攻方暴击率=暴击*10000/(暴击*1. 5+3950+25*lv)+暴击率增加
	守方免暴率=坚韧*10000/(坚韧*8+7000+20*lv)+免暴率增加
	实际暴击率=max(攻方暴击率-守方免暴率,0)

	@param attackInfo: 攻击方
	@param hurtInfo: 防守方
	return
		是否暴击
--]]

function isCrit(attackInfo, hurtInfo)
	local casterCrit	= math.floor(attackInfo:GetCrit() * 10000 / (attackInfo:GetCrit() * 1.5 + 3950 + 25 * attackInfo:GetLevel()) + attackInfo:GetCritRate())
	local targetResist	= math.floor(hurtInfo:GetTough() * 10000 / (hurtInfo:GetTough() * 8 + 7000+ 20 * hurtInfo:GetLevel()) + hurtInfo:GetCritResistRate())
	local p = math.max(casterCrit - targetResist, 0)
	local val = randInt(1, 10000)

	return val <= p
end

-- 爆伤万分比=200%+(爆伤增加(攻方)-爆伤减免(守方)) / 10000
-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- return
--		暴击倍数
function critMult(attackInfo, hurtInfo)
	return 2 + (attackInfo:GetCritDamRate() - hurtInfo:GetCritResistDamRate()) / 10000
end

-- 暴击伤害=暴击伤害倍数*普通伤害
-- @param normalDam: 普通伤害
-- @param mult: 暴击倍数
-- return
--		暴击伤害
function critDamage(normalDam, mult)
	return math.floor(normalDam * mult)
end

-- 攻击方受到的反弹伤害=攻击方对防守方造成最终伤害*防守方反弹伤害
-- @param damage: 最终伤害
-- @param hurtInfo: 防守方
-- return
--		反弹伤害
function damageReturned(damage, hurtInfo)
	return math.floor(damage * hurtInfo:GetDamageReturnRate() / 10000)
end

-- 吸血
-- @param damage: 最终伤害
-- @param casterInfo: 攻击方
-- return
--		吸血值
function damageVampiric(damage, casterInfo)
	return math.floor(damage * casterInfo:GetVampiricRate() / 10000)
end