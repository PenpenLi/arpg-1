require("math")
--------------------------------------
--计算玩家战斗力
function DoCalculPlayerForce(player, attrs, spells_force)
	local force = DOCalculForce(attrs)
	--加上技能战斗力
	for i = 1,#spells_force do
		force = force + spells_force[i]
	end
	return force
end


--------------------------------------------------------------------------------------------------------------
-- 传送的时候该做点什么事
function DoPlayerTeleport(player)
	local playerInfo = UnitInfo:new{ptr = player}
	playerInfo:RemoveUseGameObjectFlag()
end


--玩家脱离战斗之后干点什么事情
function DosometingScript(player)
	
end

--玩家PVP时目标方的一些处理
function DOPlayerPvP(player,target)
	--[[
		1、取消骑乘状态并锁定为不可使用
		2、取消打坐状态并锁定为不可使用
		3、取消采集状态
		
		假如当前为和平模式，则切换为自卫模式
	]]
	
	--取消打坐
	--[[
	local playerInfo = UnitInfo:new{ptr = target}
	if playerInfo:GetDaZuoTime() > 0 then
		playerInfo:ReceiveDaZuo()
	end
	]]
end

-- 怪物攻击玩家时的一些处理
function DOPlayerPvE(creature, target)
	--取消打坐
	--[[
	local playerInfo = UnitInfo:new{ptr = target}
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
-- 攻击方命中率=MAX（0.65，MIN（1，（8*攻击方命中+3*防守方闪避+19000）/（8*攻击方命中+4*防守方闪避+20000）+攻击方命中率%加成-防守方闪避率%加成）)
-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- return
--		是否命中
function isHit(attackInfo, hurtInfo)
	local hdP = (8 * attackInfo:GetHit() + 3 * hurtInfo:GetDodge() + 19000) / (8 * attackInfo:GetHit() + 4 * hurtInfo:GetDodge() + 20000)
	local hdrP = (attackInfo:GetHitRate() - hurtInfo:GetDodgeRate()) / 10000
	local p = math.floor(math.max(0.65, math.min(1, hdP + hdrP)) * 10000)
	local val = randInt(1, 10000)

	return val <= p
end

-- 普通伤害(不暴击时伤害)=（（（原伤害+攻击方等级伤害）*伤害随机区间）*攻击方技能伤害修正系数+攻击方附加技能伤害）*MAX（0，（1-防守方伤害减免））
-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- @param skillLevel: 攻击方技能等级
-- @param skillDamFactor: 攻击方技能伤害修正系数(填表的)
-- @param skillDamVal: 攻击方技能伤害附加值(填表的)
-- return
--		伤害
function getCastDamage(attackInfo, hurtInfo, skillLevel, skillDamFactor, skillDamVal)
	-- 原伤害
	local baseDam = getBaseDam(attackInfo, hurtInfo)
	-- 攻击方等级伤害
	local attackerLevelDam = getCasterLevelDam(attackInfo)
	-- 伤害随机区间
	local damRange = getDamRange()
	-- 附加技能伤害
	local skillExtraDam = getSkillExtraDam(skillLevel, skillDamVal)
	
	-- 普通伤害
	local normalDam = ((baseDam + attackerLevelDam) * damRange * skillDamFactor + skillExtraDam) * math.max(0, (1 - hurtInfo:GetDamageResist() / 10000))

	return normalDam
end

-- 原伤害=攻击方攻击*(1+攻击方攻击增强)-防守方防御*MAX(0,（1-攻击方忽视防御）)
-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- return
--		原伤害
function getBaseDam(attackInfo, hurtInfo)
	return attackInfo:GetDamage() * (1 + attackInfo:GetAmplifyDamage() / 10000) - hurtInfo:GetArmor() * math.max(0, (1 - attackInfo:GetIgnoreDefense() / 10000))
end

-- 攻击方等级伤害= ROUND(0.00054*攻击方等级^2.5+1,0)
-- @param attackInfo: 攻击方
-- return
--		等级伤害
function getCasterLevelDam(attackInfo)
	local level = attackInfo:GetLevel()
	return 0.00054 * math.pow(level, 2.5) + 1.5
end

-- 伤害随机区间：[85%, 115%]
-- return
--		随机伤害比率
function getDamRange()
	return randInt(85, 115) / 100
end

--附加技能伤害
function getSkillExtraDam(skillLevel, skillDamVal)
	return skillDamVal
end

-- 攻击方暴击率=MAX(0，MIN(0.5，（7*攻击方暴击+2000）/（100*防守方坚韧+20*攻击方暴击+50000）+攻击方暴击率%加成-防守方抗暴率%加成))
-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- return
--		是否暴击
function isCrit(attackInfo, hurtInfo)
	local ctP = (7 * attackInfo:GetCrit() + 2000) / (20 * attackInfo:GetCrit() + 100 * hurtInfo:GetTough() + 50000)
	local ctrP = (attackInfo:GetCritRate() - hurtInfo:GetCriticalResistRate()) / 10000
	local p = math.floor(math.max(0, math.min(.5, ctP + ctrP)) * 10000)
	local val = randInt(1, 10000)

	return val <= p
end

-- 暴击伤害倍数=MAX(1.5,MIN(5,2+攻击方暴击伤害倍数-防守方降暴击伤害倍数))
-- @param attackInfo: 攻击方
-- @param hurtInfo: 防守方
-- return
--		暴击倍数
function critMult(attackInfo, hurtInfo)
	return math.max(1.5, math.min(5, 2 + (attackInfo:GetDamageCritMultiple() - hurtInfo:GetResistCritMultiple()) / 10000))
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
	return math.floor(damage * hurtInfo:GetDamageReturned() / 10000)
end
