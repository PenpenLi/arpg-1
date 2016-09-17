-------------------------------------------------------------------------------
----------------------------buff相关-------------------------------------------
--周期性buff
function DoBuffTriggerScript(unit,buff_id,buff_lv)
	local unitInfo = UnitInfo:new{ptr = unit}
	local giver_ptr = unitLib.GetBuffGiverUnit(unit, buff_id)
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
	elseif buff_id == BUFF_COMMON_ADD_HP_PER then --百分比回血
		local id = unitLib.GetBuffReserve(unit,buff_id)
		local config = tb_normal_buff[id]
		if config then
			local add_hp = math.floor(unitInfo:GetMaxHealth()*config.effect/100)
			unitInfo:ModifyHealth(add_hp)
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
	--百分比
	local percentage = unitLib.GetBuffReserve(unit,buff_id) / 100
	if buff_id == BUFF_JIANSU then	--减速
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed + speed * unitLib.GetBuffReserve(unit,buff_id)/100
		unitLib.SetMoveSpeed(unit, speed)
	elseif buff_id == BUFF_ANXIANG_SHUYING or buff_id == BUFF_BINGJIA then	--减速DEBUFF：移动速度降低50%
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed + speed *0.5
		unitLib.SetMoveSpeed(unit, speed)
	elseif buff_id == BUFF_JUMP_DOWN then --移动速度提升25%、闪避率提升30%，持续5秒
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed - speed * 0.25
		unitLib.SetMoveSpeed(unit, speed)
		unitInfo:SetCombatRate(COMBAT_RATE_EVA,unitInfo:GetCombatRate(COMBAT_RATE_EVA)*1.3)
	elseif buff_id == BUFF_KUANGBEN or buff_id == BUFF_BAOFATUJIN or buff_id == BUFF_GUANZHAN then --移动速度提升50%
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed - speed * 0.5
		unitLib.SetMoveSpeed(unit, speed)
	elseif buff_id == BUFF_LINGTI then	--灵体
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed - speed * 0.2
		unitLib.SetMoveSpeed(unit, speed)	
	elseif buff_id == BUFF_WAIGONGMIANYI then	--外攻免疫
		unitInfo:SetArmor(9999999999)--外防
	elseif buff_id == BUFF_NEIGONGMIAN then	--内攻免疫
		unitInfo:SetArmor(9999999999)--内防
	elseif buff_id == BUFF_ZHANSHEN_FUTI then	--战神附体	提升自身30%外攻、内攻
		unitInfo:SetMinDamage(unitInfo:GetMinDamage()*1.3)
		unitInfo:SetMaxDamage(unitInfo:GetMaxDamage()*1.3)
	elseif buff_id == BUFF_JINGANG_BUHUAITI then	--金刚不坏体	提升自身30%外防、内防
		unitInfo:SetOutArmor(unitInfo:GetArmor()*1.3)
	elseif buff_id == BUFF_JUMP_JUMP then --连跳
		local ms = 57
		if buff_lv == 2 then
			ms = 55
		end
		unitLib.SetMoveSpeed(unit, ms)
	elseif buff_id == BUFF_LIHUAJIU then --梨花酒
		unitInfo:SetMinDamage(unitInfo:GetMinDamage()*1.1)
		unitInfo:SetMaxDamage(unitInfo:GetMaxDamage()*1.1)
	elseif buff_id == BUFF_XIONGHUANGJIU then	--雄黄酒	
		unitInfo:SetOutArmor(unitInfo:GetArmor()*1.1)
	elseif buff_id == BUFF_BAICAOJIU then	--百草酒	
		unitInfo:SetMaxHealth(unitInfo:GetMaxHealth()*1.2)
	elseif buff_id == BUFF_GUJINGGONGJIU then	--古井贡酒	
		unitInfo:SetCombatRate(COMBAT_RATE_CRIT,unitInfo:GetCombatRate(COMBAT_RATE_CRIT)*1.1)
	elseif buff_id == BUFF_HOUERJIU then	--猴儿酒	
		unitInfo:SetCombatRate(COMBAT_RATE_EVA,unitInfo:GetCombatRate(COMBAT_RATE_EVA)*1.1)
	elseif buff_id == BUFF_DALIJINGANGWAN then	--大力金刚丸
		unitInfo:SetMinDamage(unitInfo:GetMinDamage()*1.5)
		unitInfo:SetMaxDamage(unitInfo:GetMaxDamage()*1.5)
	elseif buff_id == BUFF_KUANGBAODAN then	--狂暴丹	
		unitInfo:SetCombatRate(COMBAT_RATE_CRIT,unitInfo:GetCombatRate(COMBAT_RATE_CRIT)*1.5)
	elseif buff_id == BUFF_QINGFENGDAN then	--清风丹	
		unitInfo:SetCombatRate(COMBAT_RATE_EVA,unitInfo:GetCombatRate(COMBAT_RATE_EVA)*1.5)
	elseif buff_id == BUFF_DIAO_FLY then	--雕飞
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed * 0.6
		unitLib.SetMoveSpeed(unit, speed)
	elseif buff_id == BUFF_TIANZHUSHENLI then	--天助神力
		local adddamage = unitInfo:GetAddDamage()
		adddamage = adddamage + adddamage * unitLib.GetBuffReserve(unit,buff_id)/100
		unitInfo:SetAddDamage(adddamage)
	elseif buff_id == BUFF_LINGSHENHUZHU then	--灵神护主
		local subdamage = unitInfo:GetSubDamage()
		subdamage = subdamage + subdamage * unitLib.GetBuffReserve(unit,buff_id)/100
		unitInfo:SetSubDamage(subdamage)
	elseif buff_id == BUFF_ANQI_LSCH then --辣手摧花
		local reserve = unitLib.GetBuffReserve(unit,buff_id)
		local config = tb_skill_uplevel[reserve].type_effect
		--破甲
		local armor = unitInfo:GetArmor()*(1-config[2]/100)
		unitInfo:SetArmor(armor)
		--减速
		local speed = unitLib.GetMoveSpeed(unit)*(1+config[3]/100)
		unitLib.SetMoveSpeed(unit, speed)
	elseif buff_id == BUFF_HDQS_MINJIE then --荒岛求生-敏捷
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed - speed * tb_game_set[119].value[1]/100
		unitLib.SetMoveSpeed(unit, speed)
	elseif buff_id == BUFF_HDQS_XIONGXIN then --荒岛求生-熊心
		local per = 1 + tb_game_set[119].value[2]/100
		unitInfo:SetMaxHealth(unitInfo:GetMaxHealth()*per)
	elseif buff_id == BUFF_HDQS_BAOZIDAN then --荒岛求生-豹子胆
		--取出数值
		local uplevel_id = tb_skill_base[HDQS_SPELL_BAOZIDAN].uplevel_id[1]
		local per = 1 + tb_skill_uplevel[uplevel_id].type_effect[2]/100
		unitInfo:SetMinDamage(unitInfo:GetMinDamage()*per)
		unitInfo:SetMaxDamage(unitInfo:GetMaxDamage()*per)
	elseif buff_id == BUFF_HDQS_ANGER then --荒岛求生-野性咆哮
		--取出数值
		local uplevel_id = tb_skill_base[HDQS_SPELL_ANGER].uplevel_id[1]
		local speed_per = 1 - tb_skill_uplevel[uplevel_id].type_effect[2]/100
		unitLib.SetMoveSpeed(unit, unitLib.GetMoveSpeed(unit)*speed_per)
		local damage_per = 1 + tb_skill_uplevel[uplevel_id].type_effect[3]/100
		unitInfo:SetMinDamage(unitInfo:GetMinDamage()*damage_per)
		unitInfo:SetMaxDamage(unitInfo:GetMaxDamage()*damage_per)
	elseif buff_id == BUFF_HDQS_LOYAL then --荒岛求生-忠诚守护
		--取出数值
		local uplevel_id = tb_skill_base[HDQS_SPELL_LOYAL].uplevel_id[1]
		local per = 1 + tb_skill_uplevel[uplevel_id].type_effect[2]/100
		unitInfo:SetArmor(unitInfo:GetArmor()*per)
	elseif buff_id == BUFF_WANJIANGUIZONG then --万剑归宗 移速提升20%
		local speed = unitLib.GetMoveSpeed(unit)
		speed = speed - speed * 0.2
		unitLib.SetMoveSpeed(unit, speed)
	elseif buff_id == BUFF_LJ_QIANGGONG then --论剑-强攻
		unitInfo:SetMinDamage(unitInfo:GetMinDamage()*1.2)
		unitInfo:SetMaxDamage(unitInfo:GetMaxDamage()*1.2)
	elseif buff_id == BUFF_ZENGSHANG_BUFF then --增伤buff
		local zs_val = unitInfo:GetAddDamage()
		unitInfo:SetAddDamage(zs_val * (1 + percentage))
	elseif buff_id == BUFF_JIANSHANG_BUFF then --减伤buff
		local js_val = unitInfo:GetSubDamage()
		unitInfo:SetSubDamage(js_val * (1 + percentage))
	elseif buff_id == BUFF_POJIA_BUFF then --破甲buff
		local pj_val = unitInfo:GetArmor()
		unitInfo:SetArmor(pj_val * (1 - percentage))
	elseif buff_id == BUFF_JIANSU_BUFF then --减速buff
		local jiansu_val = unitLib.GetMoveSpeed(unit)
		unitLib.SetMoveSpeed(unit, jiansu_val * (1 + percentage))
	elseif buff_id == BUFF_JIASU_BUFF then --加速buff
		local jiasu_val = unitLib.GetMoveSpeed(unit)
		unitLib.SetMoveSpeed(unit, jiasu_val * (1 - percentage))
	elseif buff_id == BUFF_GONGJI_BUFF then --攻击buff
		local min_gj_val = unitInfo:GetMinDamage()
		local max_gj_val = unitInfo:GetMaxDamage()
		unitInfo:SetMinDamage(min_gj_val * (1 + percentage))
		unitInfo:SetMaxDamage(max_gj_val * (1 + percentage))
	elseif buff_id == BUFF_FANGYU_BUFF then --防御buff
		local fy_val = unitInfo:GetArmor()
		unitInfo:SetArmor(fy_val * (1 + percentage))
	elseif buff_id == BUFF_JIAXUE_BUFF then --加血buff
		local xl_val = unitInfo:GetMaxHealth()
		unitInfo:SetMaxHealth(xl_val * (1 + percentage))
	elseif buff_id == BUFF_COMMON_ADD_DAMAGE_PER then --百分比加攻击
		local id = unitLib.GetBuffReserve(unit,buff_id)
		local config = tb_normal_buff[id]
		if config then
			local mindamage = math.floor(unitInfo:GetMinDamage()*(1+config.effect/100))
			local maxdamage = math.floor(unitInfo:GetMaxDamage()*(1+config.effect/100))
			unitInfo:SetMinDamage(mindamage)
			unitInfo:SetMaxDamage(maxdamage)
		end
	elseif buff_id == BUFF_COMMON_ADD_DEF_PER then --百分比加防御
		local id = unitLib.GetBuffReserve(unit,buff_id)
		local config = tb_normal_buff[id]
		if config then
			local armor = math.floor(unitInfo:GetArmor()*(1+config.effect/100))
			unitInfo:SetArmor(armor)
		end
	elseif buff_id == BUFF_COMMON_ADD_JS_PER then --百分比加减伤
		local id = unitLib.GetBuffReserve(unit,buff_id)
		local config = tb_normal_buff[id]
		if config then
			local js = math.floor(unitInfo:GetSubDamage()*(1+config.effect/100))
			unitInfo:SetSubDamage(js)
		end	
		
	elseif buff_id == BUFF_SHANGXIANG then --上香BUFF	
		local reserve = unitLib.GetBuffReserve(unit,buff_id)
		local config = tb_bangpai_god[reserve]
		if config == nil then return end
		for i = 1,config.prop_add,2 do
			local add_type = config.prop_add[i]
			local add = config.prop_add[i+1]*buff_lv
			--固定生命
			if add_type == EQUIP_ATTR_FIXED_HP then	
				unitInfo:SetMaxHealth(unitInfo:GetMaxHealth() + add)
			--固定最小攻击	
			elseif add_type == EQUIP_ATTR_FIXED_MIN_DAMAGE then	
				unitInfo:SetMinDamage(unitInfo:GetMinDamage() + add)
			--固定最大攻击
			elseif add_type == EQUIP_ATTR_FIXED_MAX_DAMAGE then	
				unitInfo:SetMaxDamage(unitInfo:GetMaxDamage() + add)
			--固定防御	
			elseif add_type == EQUIP_ATTR_FIXED_DEF then		
				unitInfo:SetArmor(unitInfo:GetArmor() + add)
			--固定命中	
			elseif add_type == EQUIP_ATTR_FIXED_HIT then		
				unitInfo:SetHit(unitInfo:GetHit() + add)
			--固定闪避	
			elseif add_type == EQUIP_ATTR_FIXED_EVA then		
				unitInfo:SetEva(unitInfo:GetEva() + add)
			--固定暴击		
			elseif add_type == EQUIP_ATTR_FIXED_CRIT then	
				unitInfo:SetCrit(unitInfo:GetCrit() + add)
			--固定抗暴	
			elseif add_type == EQUIP_ATTR_FIXED_CRIT_DEF then		
				unitInfo:SetCritDef(unitInfo:GetCritDef() + add)
			end
		end
	end	
end

-----------------------------------------------------------------
--脚本调用脚本
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
