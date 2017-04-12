-------------------------------------------------------------------------------
----------------------------buff相关-------------------------------------------
--周期性buff
function DoBuffTriggerScript(unit,buff_id,buff_lv)
	local unitInfo = UnitInfo:new{ptr = unit}
	local giver_ptr = unitLib.GetBuffGiverUnit(unit, buff_id)
	
	local config = tb_buff_template[buff_id]
	if not config then
		return
	end
	local buff_type = config.buff_type
	--[[
	if buff_id == BUFF_LIANJIE then		--连接
		local dst_x, dst_y = unitLib.GetPos(unit)
		local targets = mapLib.GetCircleTargets(dst_x, dst_y, 15, unit, TARGET_TYPE_ENEMY)
		--如果只剩下一个目标(自己) 移除BUFF
		if #targets <= 1 then
			unitLib.RemoveBuff(unit,buff_id)
			return
		end
		for key, attack_target in pairs(targets) do
			if attack_target ~= nil and attack_target ~= unit then
				local reserve = unitLib.GetBuffReserve(unit,buff_id)
				--如果附近有被连接的BUFF
				if unitLib.HasBuff(attack_target, BUFF_BEILIANJIE) == true then
					AddSpellCastinfo(unit, attack_target, reserve, HITINFO_NORMALSWING, tb_buff_template[buff_id].skill_id)
					unitLib.SetBuffReserve(unit, BUFF_LIANJIE, 0)
					break
				end
				--如果附近没有被连接BUFF，移除BUFF
				if key == #targets then
					unitLib.RemoveBuff(unit,buff_id)
					return
				end
			end
		end
		
	 --每秒损失上限的1%总生命
	elseif buff_id >= BUFF_LINGXUE and buff_id <= BUFF_BINGJIA then
		AddSpellCastinfo(giver_ptr, unit, unitInfo:GetMaxHealth()*0.1, HITINFO_LIUXUE, tb_buff_template[buff_id].skill_id)
	elseif buff_id == BUFF_BAOZHA_DILEI then		--地雷
		local map_ptr = unitLib.GetMap(unit)
		local dst_x, dst_y = unitLib.GetPos(unit)
		local targets = mapLib.GetCircleTargets(dst_x, dst_y, 1, unit, TARGET_TYPE_ENEMY)
		for key, attack_target in pairs(targets) do
			if attack_target ~= nil and attack_target ~= unit then
				local dst_x1, dst_y1 = unitLib.GetPos(attack_target)
				local targets1 = mapLib.GetCircleTargets(dst_x1, dst_y1, 8, attack_target, TARGET_TYPE_ENEMY)
				for key1, attack_target1 in pairs(targets1) do
					if attack_target1 ~= nil and attack_target1 ~= unit then
						AddSpellCastinfo(unit, attack_target1, 100, HITINFO_NORMALSWING, tb_buff_template[buff_id].skill_id)
					end
				end
				mapLib.RemoveWorldObject(map_ptr, unit)
				break
			end
		end
		
	elseif buff_id == BUFF_XUECHI then		--血池
		local dst_x, dst_y = unitLib.GetPos(unit)
		local targets = mapLib.GetCircleTargets(dst_x, dst_y, 20, unit, TARGET_TYPE_ENEMY)
		for key, attack_target in pairs(targets) do
			if attack_target ~= nil and attack_target == creatureLib.GetMonsterHost(unit) then
				local userInfo = UnitInfo:new{ptr = attack_target}
				userInfo:ModifyHealth(userInfo:GetMaxHealth()*0.1)
				break
			end
		end	
	elseif buff_id == BUFF_HUOBA then		--火把
		local dst_x, dst_y = unitLib.GetPos(unit)
		local targets = mapLib.GetCircleTargets(dst_x, dst_y, 15, unit, TARGET_TYPE_ENEMY)
		for key, target in pairs(targets) do
			if target ~= nil and target ~= unit then
				local targetInfo = UnitInfo:new{ptr = target}
				local zhiye = targetInfo:GetProfession()
				local pifu = targetInfo:GetCreatureSkin()
				local map_ptr = unitLib.GetMap(unit)
				if not map_ptr then return end
				local mapInfo = Instance_liudaolunhui:new{ptr = map_ptr}
				local monster = creatureLib.GetMonsterHost(unit)
				--对鬼、没有幻化的妖、幻化成鬼的妖 造成伤害
				if 	zhiye == mapInfo.LIUDAO_GUI 
					or (zhiye == mapInfo.LIUDAO_YAO and pifu == 0)
					or (zhiye == mapInfo.LIUDAO_YAO and pifu == mapInfo.LIUDAO_GUI)
					then
					--清除灵体buff
					if unitLib.HasBuff(target, BUFF_LINGTI) then
						unitLib.RemoveBuff(target,BUFF_LINGTI)
						SpelladdBuff(target, BUFF_ZHANDOU_STATE, target, 1, tb_buff_template[BUFF_ZHANDOU_STATE].duration)
					end
					--清理幻化
					if pifu > 0 then
						unitLib.RemoveBuff(target,BUFF_HUANHUA)
						targetInfo:SetCreatureSkin(0)
					end
					AddSpellCastinfo(monster, target, 2, HITINFO_LIUXUE, tb_buff_template[buff_id].skill_id)
				end
			end
		end
	 --修罗力
	elseif  buff_id == BUFF_XIULUOLI then
		AddSpellCastinfo(giver_ptr, unit, unitInfo:GetMaxHealth()*0.01, HITINFO_LIUXUE, tb_buff_template[buff_id].skill_id)
	--变异再生
	elseif buff_id == BUFF_BIANYIZAISHENG then
		local reserve = unitLib.GetBuffReserve(unit,buff_id)
		local add = 50
		if reserve > 10 then
			add = 500
		end
		if unitInfo:GetPVPState() then
			reserve = 0
		else
			reserve = reserve + 1
			unitInfo:ModifyHealth(add)
		end
		if unitLib.GetBuffReserve(unit,buff_id) ~= reserve then
			unitLib.SetBuffReserve(unit,buff_id,reserve)
		end
	elseif buff_id == BUFF_DAZUO then
		unitInfo:ModifyHealth(unitInfo:GetMaxHealth()*tb_game_set[5].value[3]/100)
		unitInfo:ModifyPower(POWER_MANA,unitInfo:GetMaxPower(POWER_MANA)*tb_game_set[5].value[4]/100)
	elseif buff_id == BUFF_LJ_ZHIYU then --论剑-治愈
		unitInfo:ModifyHealth(unitInfo:GetMaxHealth()*0.03)
	elseif buff_id == BUFF_ZHILIAO_BUFF then --治疗buff
		local percentage = unitLib.GetBuffReserve(unit,buff_id) / 100
		unitInfo:ModifyHealth(unitInfo:GetMaxHealth()*percentage)
	elseif buff_id == BUFF_COMMON_ADD_HP_VAL then --固定值回血
		local id = unitLib.GetBuffReserve(unit,buff_id)
		local config = tb_normal_buff[id]
		if config then
			unitInfo:ModifyHealth(config.effect)
		end
	--]]
	if buff_type == BUFF_TYPE_ADD_HP_PER_RATE then --百分比回血
		local value = config.value * buff_lv
		local add_hp = math.floor(unitInfo:GetMaxHealth()*value/100)
		unitInfo:ModifyHealth(add_hp)
		
		local mapid = unitLib.GetMapID(unit)
		local map_ptr = unitLib.GetMap(unit)
		local mapInfo = Select_Instance_Script(mapid):new {ptr = map_ptr}
		mapInfo:OnPlayerHurt(unit, unit, -add_hp)
		if add_hp < 0 then
			-- 周期性掉血触发
			DoHandlePassiveEffect(unit, nil, PASSIVE_DISPATCH_TYPE_ATTR_CHANGE)
		end
	end
end

--BUFF结束时需要做的一些事情
function DoBuffOverScript(unit, buff_id, buff_lv)
	local unitInfo = UnitInfo:new{ptr = unit}
	--反击护盾
	if buff_id == BUFF_FANJI_HUDUN then
		local cast_x, cast_y = unitLib.GetPos(unit)
		local targets = mapLib.GetCircleTargets(cast_x, cast_y, 8, unit, TARGET_TYPE_ENEMY)	
		for key, attack_target in pairs(targets) do
			--目标不能是自己				--不能是友好的
			if attack_target ~= nil and attack_target ~= unit then
				AddSpellCastinfo(unit, attack_target, 5000, HITINFO_NORMALSWING, tb_buff_template[buff_id].skill_id)
			end
		end
	--战斗状态结束后
	elseif buff_id == BUFF_ZHANDOU_STATE then
		SpelladdBuff(unit, BUFF_LINGTI, unit, 1, tb_buff_template[BUFF_LINGTI].duration)
	--妖术结束后
	elseif buff_id == BUFF_HUANHUA then
		unitInfo:SetCreatureSkin(0)
	end
	
	
	if buff_id >= BUFF_FANTAN then	--有buff
		local config = tb_buff_template[buff_id]
		if config and config.recalculation == 1 then	-- 有结束重算标识
			unitLib.SetCalculAttr(unit)
		end
		ClearBuffFlags(unit, buff_id)
	end
end

--清除buff对应的flag标识
function ClearBuffFlags(unit, buff_id)
	local unitInfo = UnitInfo:new{ptr = unit}
	---------------清空限制性buff的flag----------------------
	local cant_casts = config.cant_cast		--取出配置
	for k, buff in pairs(cant_casts) do
		if buff_id == buff then
			local flag = false
			for k1, buff1 in pairs(cant_casts) do
				if buff1 ~= buff_id and unitLib.HasBuff(unit, buff1)  then
					flag = true		--如果玩家身上还有类似的buff，则暂不清flag
					break	
				end		
			end
			if not flag then
				unitInfo:UnSetUnitFlags(UNIT_FIELD_FLAGS_CANT_CAST)
			end	
			break
		end
	end
	local cant_moves = config.cant_move		--取出配置
	for k, buff in pairs(cant_moves) do
		if buff_id == buff then
			local flag = false
			for k1, buff1 in pairs(cant_moves) do
				if buff1 ~= buff_id and unitLib.HasBuff(unit, buff1) then
					flag = true		--如果玩家身上还有类似的buff，则暂不清flag
					break	
				end		
			end
			if not flag then
				unitInfo:UnSetUnitFlags(UNIT_FIELD_FLAGS_CANT_MOVE)
			end	
			break
		end
	end
	-------------------清空限制性buff的flag end-----------------	
end

--计算BUFF属性 --加属性的BUFF在这搞就可以了
function DOComputeBuffAttr(unit,buff_id,buff_lv)
	local unitInfo = UnitInfo:new{ptr = unit}
	
	local config = tb_buff_template[buff_id]
	if not config then
		return
	end
	local buff_type = config.buff_type
	local value = config.value * buff_lv
	
	-- 改变属性的
	if buff_type >= BUFF_TYPE_ATTR_START and buff_type <= BUFF_TYPE_ATTR_END then
		local attrId = buff_type
		local binlogIndx = GetAttrUnitBinlogIndex(attrId)
		binLogLib.AddUInt32(unit, binlogIndx, value)
	end
end

-----------------------------------------------------------------
--脚本调用脚本

--------------------------------系统给玩家增加buff------------------------------------
function SystemAddBuff(unit, buffId, bonus_time)
	unitLib.SystemAddBuff(unit, buffId, bonus_time)
end

-------------------增加Buff----------------------
function SpelladdBuff(unit, buff_id, buff_giver, lv, bonus_time, reserve)
	if unit == nil then
		outFmtError("SpelladdBuff unit == nil buff_id = %d",buff_id)
		return
	end
	local unitInfo = UnitInfo:new{ptr = unit}
	if unitInfo:IsAlive() == false then
		outFmtError("SpelladdBuff unit %d is not alive buff_id = %d", unitInfo:GetEntry(), buff_id)
		return
	end
	
	if buff_id == BUFF_ONEPOINTFIVE_JINGYAN or buff_id == BUFF_TOW_JINGYAN or buff_id == BUFF_THREE_JINGYAN or buff_id == BUFF_FIVE_JINGYAN then
		--经验丹		
		if unitLib.HasBuff(unit, buff_id) then
			--已经有这个buff了就处理叠加
			local duration = unitLib.GetBuffDuration(unit, buff_id)
			if duration + bonus_time >= 65535 then
				duration = 65534
			else
				duration = duration + bonus_time
			end
			unitLib.SetBuffDuration(unit, buff_id, duration)
		else
			--添加buff
			unitLib.AddBuff(unit, buff_id, buff_giver, lv, bonus_time)
			--添加了buff的同时移除其他经验buff
			local jingyan = {BUFF_ONEPOINTFIVE_JINGYAN, BUFF_TOW_JINGYAN, BUFF_THREE_JINGYAN, BUFF_FIVE_JINGYAN}
			for _, id in ipairs(jingyan) do
				if id ~= buff_id and unitLib.HasBuff(unit, id) then
					unitLib.RemoveBuff(unit, id)
				end
			end
		end

	elseif buff_id == BUFF_GANGCI then				--钢刺
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,lv,bonus_time,reserve)
			AddSpellCastinfo(buff_giver, unit, 100 + unitInfo:GetHealth()*0.01, HITINFO_NORMALSWING, tb_buff_template[buff_id].skill_id)
		else
			unitLib.SetBuffDuration(unit, buff_id, tb_buff_template[buff_id].duration)
			unitLib.SetBuffReserve(unit, buff_id, unitLib.GetBuffReserve(unit,buff_id) + reserve)
			AddSpellCastinfo(buff_giver, unit, 100 + unitInfo:GetHealth()*unitLib.GetBuffReserve(unit,buff_id)/100, HITINFO_NORMALSWING, tb_buff_template[buff_id].skill_id)
		end
	
	elseif buff_id == BUFF_FANJI_HUDUN then				--反击护盾
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,lv,bonus_time,reserve)
		end	
	elseif buff_id == BUFF_JUMP_JUMP then		--连跳BUFF
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,1,bonus_time)
		else
			unitLib.RemoveBuff(unit, buff_id)
			unitLib.AddBuff(unit,buff_id,buff_giver,2,bonus_time)
		end
	elseif buff_id == BUFF_SHIHUA 	--石化
			or buff_id == BUFF_YUNXUAN 	--晕眩
			or buff_id == BUFF_YINCHANG	--吟唱
			or buff_id == BUFF_ZHIKONG	--滞空
			or buff_id == BUFF_XUANYUN_BUFF 	--晕眩
		 then		
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,1,bonus_time,reserve or 0)
		else
			unitLib.RemoveBuff(unit, buff_id)
			unitLib.AddBuff(unit,buff_id,buff_giver,1,bonus_time,reserve or 0)
		end	
		--限制施法
		if unitInfo:GetUnitFlags(UNIT_FIELD_FLAGS_CANT_CAST)==false then
			unitInfo:SetUnitFlags(UNIT_FIELD_FLAGS_CANT_CAST)
		end
		--限制移动
		if unitInfo:GetUnitFlags(UNIT_FIELD_FLAGS_CANT_MOVE)==false then
			unitInfo:SetUnitFlags(UNIT_FIELD_FLAGS_CANT_MOVE)
		end
		
	elseif buff_id == BUFF_DINGSHEN or buff_id == BUFF_HDQS_NET 
			or buff_id == BUFF_DINGSHEN_BUFF then --定身、网
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,1,bonus_time)
		else
			unitLib.RemoveBuff(unit, buff_id)
			unitLib.AddBuff(unit,buff_id,buff_giver,1,bonus_time)
		end	
		--限制移动
		if unitInfo:GetUnitFlags(UNIT_FIELD_FLAGS_CANT_MOVE)==false then
			unitInfo:SetUnitFlags(UNIT_FIELD_FLAGS_CANT_MOVE)
		end
	elseif buff_id == BUFF_CHENMO then		--沉默
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,1,bonus_time)
		else
			unitLib.RemoveBuff(unit, buff_id)
			unitLib.AddBuff(unit,buff_id,buff_giver,1,bonus_time)
		end	
		--限制施法
		if unitInfo:GetUnitFlags(UNIT_FIELD_FLAGS_CANT_CAST)==false then
			unitInfo:SetUnitFlags(UNIT_FIELD_FLAGS_CANT_CAST)
		end
	elseif buff_id == BUFF_HUDUN_BUFF then		--护盾buff
		local targetInfo = unitInfo
		local monster = creatureLib.GetMonsterHost(buff_giver)
		if monster then
			targetInfo = UnitInfo:new{ptr = monster}
		end
		reserve = targetInfo:GetMaxHealth() * reserve / 100
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,lv,bonus_time,reserve or 0)
		else
			unitLib.RemoveBuff(unit,buff_id)
			unitLib.AddBuff(unit,buff_id,buff_giver,lv,bonus_time,reserve or 0)
		end
	--如果不需要特殊处理就这么弄
	else
		if unitLib.HasBuff(unit, buff_id) == false then
			unitLib.AddBuff(unit,buff_id,buff_giver,lv,bonus_time,reserve or 0)
		else
			unitLib.RemoveBuff(unit,buff_id)
			unitLib.AddBuff(unit,buff_id,buff_giver,lv,bonus_time,reserve or 0)
		end
	end
	
	OnPassiveEffect(unit, buff_giver, nil, PASSIVE_DISPATCH_TYPE_ON_BUFF, 0, {buff_id})
end

--根据id增加通用性的buff
function AddNormalBuff(unit, id, buff_giver, lv)
	local config = tb_normal_buff[id]
	if config == nil then return end
	if unit == nil then return end
	local unitInfo = UnitInfo:new{ptr = unit}
	if not unitInfo:IsAlive() then
		return
	end
	if unitLib.HasBuff(unit, config.buff_id) then
		unitLib.RemoveBuff(unit, config.buff_id)
	end
	unitLib.AddBuff(unit, config.buff_id, buff_giver, lv, config.time, id)
end

--根据id移除通用性的buff
function RemoveNormalBuff(unit, id)
	local buff_id = tb_normal_buff[id].buff_id
	if unitLib.HasBuff(unit,buff_id) and unitLib.GetBuffReserve(unit,buff_id) == id then
		unitLib.RemoveBuff(unit, buff_id)
	end
end
