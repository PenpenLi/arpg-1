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

--玩家PVP时的一些处理
function DOPlayerPvP(player,target)
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



