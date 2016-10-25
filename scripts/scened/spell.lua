-----------------------------------------------------------------
-----------------------------------------------------------------
--技能id
erduan_spell_self_cd = {}
luoyanzhan_spell_time = {}	--施放落雁斩的时间
gehou_spell_time = {}	--施放割喉的时间
SPELL_ID_LUOYANZHAN_1		= 1		--落雁斩1
SPELL_ID_LUOYANZHAN_2		= 2		--落雁斩2
SPELL_ID_LUOYANZHAN_3		= 3		--落雁斩3
SPELL_ID_WUXIANGJIEZHI		= 7		--无相劫指
SPELL_ID_CHONGFENG			= 9		--冲锋
SPELL_ID_ANXIANGSHUYING		= 13	--暗香疏影
SPELL_ID_YUNFEIYUHUANG_2	= 15	--云飞玉皇·二段
SPELL_ID_YUNFEIYUHUANG_3	= 16	--云飞玉皇·三段
SPELL_ID_FENGFANYUNBIAN_1	= 17	--风翻云变·一段
SPELL_ID_FENGFANYUNBIAN_2	= 18	--风翻云变·二段
SPELL_ID_ZHUXIANJIANZHEN_1	= 20	--诛仙剑阵·二段
SPELL_ID_ZHUXIANJIANZHEN_2	= 19	--诛仙剑阵·一段
SPELL_ID_WANJIANGUIZHONG	= 22	--万剑归宗
SPELL_ID_QUANTUMIAOSHA		= 29	--全屏秒杀
SPELL_ID_GEHOU				= 151	--割喉

--侠侣技能
XIALV_SPELL_YHLW			= 62	--月华乱舞

--六道技能
LIUDAO_SPELL_XUNSHI			= 30	--觅食
LIUDAO_SPELL_KUANGBEN		= 31	--狂奔
LIUDAO_SPELL_CAIJI			= 32	--采集
LIUDAO_SPELL_HUOBA			= 33	--火把
LIUDAO_SPELL_GUIZHUA		= 34	--鬼爪
LIUDAO_SPELL_LINGTI			= 35	--灵体
LIUDAO_SPELL_YAOSHU			= 36	--妖术
LIUDAO_SPELL_HUANHUA		= 37	--幻化
LIUDAO_SPELL_XIANFA			= 38	--仙法
LIUDAO_SPELL_TIANYAN		= 39	--天眼
LIUDAO_SPELL_SHISHA			= 40	--嗜杀
LIUDAO_SPELL_XIULUOLI		= 41	--修罗力

--boss技能
BOSS_SPELL_DINGSHEN			= 121	--定身
BOSS_SPELL_JIASUO			= 122	--枷锁
BOSS_SPELL_GOUHE			= 123	--沟壑
BOSS_SPELL_ELING			= 124	--恶灵
BOSS_SPELL_SIWANGYIZHI		= 125	--死亡一指
BOSS_SPELL_LIUXUE			= 126	--流血
BOSS_SPELL_ZHUOSHAO			= 127	--灼烧
BOSS_SPELL_ZHONGDU			= 128	--中毒
BOSS_SPELL_BINGJIA			= 129	--冰甲
BOSS_SPELL_DILEI			= 130	--地雷
BOSS_SPELL_ZHAOHUAN			= 131	--召唤
BOSS_SPELL_BIAOJI			= 132	--标记
BOSS_SPELL_JIANSU			= 133	--减速
BOSS_SPELL_CHENMO			= 134	--沉默
BOSS_SPELL_BOSSSPELL1		= 135	--BOSS技能1
BOSS_SPELL_BOSSSPELL2		= 136	--BOSS技能2
BOSS_SPELL_BOSSSPELL3		= 137	--BOSS技能3


--塞外伏击技能
SWFJ_SPELL_TSHF				= 203	--天山护法


--荒岛求生技能
HDQS_SPELL_NORMAL			= 211	--普通攻击
HDQS_SPELL_CISHA			= 212	--刺杀
HDQS_SPELL_PIKAN			= 213	--劈砍
HDQS_SPELL_HENGSAO			= 214	--横扫
HDQS_SPELL_JUJI				= 215	--狙击
HDQS_SPELL_HUOQIU			= 216	--火球
HDQS_SPELL_YOUBU			= 217	--诱捕
HDQS_SPELL_STEAL			= 218	--猴子偷桃
HDQS_SPELL_ANGER			= 219	--野性咆哮
HDQS_SPELL_LOYAL			= 220	--忠诚守护
HDQS_SPELL_DRUG				= 221	--草药
HDQS_SPELL_BOOM				= 222	--炸弹
HDQS_SPELL_TRAP				= 223	--陷阱
HDQS_SPELL_BAOZIDAN			= 224	--豹子胆
HDQS_SPELL_NET				= 225	--网

--生化危机技能
SHWJ_SPELL_BUQIANG				= 42	--步枪
SHWJ_SPELL_JIQIANG				= 43	--机枪
SHWJ_SPELL_JUJIQIANG			= 44	--狙击枪
SHWJ_SPELL_FENGKUANG_LUANZHUA	= 47	--疯狂乱抓
SHWJ_SPELL_BAOFA_TUJIN			= 48	--爆发突进
SHWJ_SPELL_BIANYI_ZAISHENG		= 49	--变异再生


----------------------------------------------------------------
----------被动技能ID--------------------------------------------
--boss技能 被攻击触发
passive_spell_cd = {}
BOSS_PASSIVESPELL_FANTAN		= 1	--反弹
BOSS_PASSIVESPELL_LIANJIE		= 2	--连接
BOSS_PASSIVESPELL_GANGCI		= 3	--钢刺
BOSS_PASSIVESPELL_HUIFUHUDUN	= 4	--恢复护盾
BOSS_PASSIVESPELL_FANJIHUDUN	= 5	--反击护盾
BOSS_PASSIVESPELL_KUANGBAO		= 6	--狂暴
BOSS_PASSIVESPELL_XUECHI		= 7	--血池
BOSS_PASSIVESPELL_WAIGONGMIANYI	= 8	--外攻免疫
BOSS_PASSIVESPELL_NEIGONGMIANYI	= 9	--内攻免疫

--玩家被动技能
PASSIVESPELLID_CJDG				= 71 --摧经断骨
PASSIVESPELLID_HSQJ				= 72 --横扫千军
PASSIVESPELLID_TZSL				= 73 --天助神力
PASSIVESPELLID_LSHZ				= 74 --灵神护住
PASSIVESPELLID_FHZY				= 81 --飞花摘叶
PASSIVESPELLID_BYLH				= 82 --暴雨梨花
PASSIVESPELLID_LSCH				= 83 --辣手摧花
PASSIVESPELLID_FHYY				= 84 --风花饮月

--需求特殊hit_info的技能
SPECIL_HIT_INFO_TBL = {
	--暗器
	[PASSIVESPELLID_FHZY] = HITINFO_ANQI_INFO, --暗器：飞花摘叶
	[PASSIVESPELLID_BYLH] = HITINFO_ANQI_INFO, --暗器：暴雨梨花
	[PASSIVESPELLID_LSCH] = HITINFO_ANQI_INFO, --暗器：辣手摧花
	[PASSIVESPELLID_FHYY] = HITINFO_ANQI_INFO, --暗器：风花饮月
	--剑鞘
	[PASSIVESPELLID_CJDG] = HITINFO_JIANQIAO,
	[PASSIVESPELLID_HSQJ] = HITINFO_JIANQIAO,
	[PASSIVESPELLID_TZSL] = HITINFO_JIANQIAO,
	[PASSIVESPELLID_LSHZ] = HITINFO_JIANQIAO,
}

--技能释放类型
SPELL_SHIFANG_DAN					= 0	--目标单体
SPELL_SHIFANG_QUN					= 1	--自身周围
SPELL_SHIFANG_ZHI					= 2	--前方直线范围
SPELL_SHIFANG_SHAN					= 3	--前方扇形范围
SPELL_SHIFANG_DIAN					= 4	--坐标点范围

--技能开始的逻辑判断 (Handle_Spell_Start) 返回false则条件不满足(玩家才会走这个判断)
function DoHandleSpellStart(caster, map_ptr, spell_id, tar_x, tar_y, nowtime)
	local casterInfo = UnitInfo:new{ptr = caster}
	
	if(casterInfo:IsAlive() == false)then
		outDebug("do DoHandleSpellStart but caster is not alive")
		return false
	end

	--[[
	--看看本地图是否允许施法
	if(not mapLib.GetCanCastSpell(map_ptr))then
		outDebug("DoHandleSpellStart  this map is cannot cast spell !!!")
		return false
	end
	
	local spellid_str = string.format('%d', spell_id)
	if(tb_skill_base[spell_id] == nil)then
		--技能不存在
		casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_SPELL_DOENT_EXIST, spellid_str)		
		return false
	end
	if(not(casterInfo:HasSpell(spell_id)))then
		--没有装备这个技能
		casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_NOT_HAVE_SPELL, spellid_str)		
		return false
	end
	if(not casterInfo:IsEnoughConsumption(spell_id))then
		--不够消耗
		casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_NOT_ENOUGH_CONSUMPTION, spellid_str)		
		return false
	end
	
	--获取2段技能的技能ID
	local old_spell_id = spell_id
	spell_id = casterInfo:GetNextSpellID(spell_id)
	if erduan_spell_self_cd[casterInfo:GetGuid()] and old_spell_id ~= spell_id  then
		if casterInfo:IsErDuanSpellCD(nowtime) then
			--技能冷却中
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_SPELL_COOLDOWN, spellid_str)		
			return false
		end
	else
		if casterInfo:IsSpellCD(spell_id, nowtime) then
			--技能冷却中
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_SPELL_COOLDOWN, spellid_str)		
			return false
		end
	end
	]]
	--print("now is:"..nowtime)
	if casterInfo:IsSpellCD(spell_id, nowtime) then
		--print("skill is countdown")
		--技能冷却中
		casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_SPELL_COOLDOWN, spellid_str)		
		return false
	end

	--[[
	if(not casterInfo:IsCanCast(spell_id))then
		--被限制施法
		casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_CAN_NOT_CAST, spellid_str)		
		return false
	end
	if(unitLib.GetCurSpell(caster) ~= 0 and unitLib.GetCurSpell(caster) == spell_id)then
		--此技能已经在施法
		casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_ALREADY_CAST, spellid_str)		
		return false
	end
	
	if(unitLib.HasUnitState(caster, UNIT_STAT_CAST_SPELL) or unitLib.HasUnitState(caster, UNIT_STAT_SPELL_PROCESS))then
		--已经在施法，则停止施法
		unitLib.SpellStop(caster)
	end
	
	
	local target = unitLib.GetTarget(caster)
	if(spell_id == SPELL_ID_CHONGFENG) then -- 冲撞技能
		return true
	end

	--荒岛求生技能
	if spell_id >= HDQS_SPELL_NORMAL and spell_id <= HDQS_SPELL_NET then
		if not hdqs_spell_start_before(caster, target, spell_id) then
			return false
		end
	end
	
	--pvp状态不能释放
	if spell_id == LIUDAO_SPELL_HUANHUA then 
		if(GetUnitTypeID(caster) == TYPEID_PLAYER and casterInfo:GetPVPState())then
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_PVP_STATE, spellid_str)
			return false
		end
	end
	
	local spell_type = tb_skill_base[spell_id].type   --获得技能类型
	if(spell_type == TARGET_TYPE_ONESELF)then	--目标为自己
		if(casterInfo:IsAlive() == false)then
			--已经死了
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_TARGET_DEAD, spellid_str)		
			return false
		end
	end
	local index = casterInfo:GetSpellLvIndex(spell_id)
	local target_type = tb_skill_base[spell_id].target_type --获得施放类型
	local spell_dis = tb_skill_uplevel[index].distance 	--获得技能施放距离
	--目标单体并且目标不是自己
	if(target_type == SPELL_SHIFANG_DAN and spell_type ~= TARGET_TYPE_ONESELF)then
		--要求有目标
		if(target == nil)then
			--技能需要目标
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_NEED_TARGET, spellid_str)
			return false
		end
		local targetInfo = UnitInfo:new{ptr = target}
		if(targetInfo:IsAlive() == false)then
			--目标已死
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_TARGET_DEAD, spellid_str)
			return false
		end
		if(unitLib.GetMap(target) == nil)then
			return false	
		end
		local x, y = unitLib.GetPos(target)
		local dis = casterInfo:GetDistance(x,y)
		if(dis > spell_dis + 3)then		--允许3码误差
			--超出施放距离
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_OUT_OF_RANGE, spellid_str)		
			return false
		end
		local isfriend = unitLib.IsFriendlyTo(caster, target)
		if(spell_type == TARGET_TYPE_FRIENDLY and isfriend == 0)then --目标要求为友方
		--目标要求为友方，但与目标友好判断却为不友好
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_WRONG_TARGET, spellid_str)		
			return false
		elseif(spell_type == TARGET_TYPE_ENEMY and isfriend == 1)then--目标要求为仇人
			--目标要求为仇人，但与目标友好判断却为友好
			casterInfo:CallOptResult(OPRATE_TYPE_SPELL_LOSE, LOST_RESON_WRONG_TARGET, spellid_str)					
			return false
		end
	--目标直前范围和坐标点范围 这个坐标由客户端传上来
	elseif(target_type == SPELL_SHIFANG_ZHI or target_type == SPELL_SHIFANG_DIAN or target_type == SPELL_SHIFANG_SHAN)then
		if(tar_x == 0 or tar_y == 0)then
			return false
		end
	end
	
	--有无相劫指buff 不能施法无相劫指技能
	if spell_id == SPELL_ID_WUXIANGJIEZHI then
		if unitLib.HasBuff(caster, BUFF_WUXIANGJIEZHI) then
			return false
		end
	end
	
	--设置二段技能的自身cd
	local self_cd = tb_skill_base[spell_id].self_cd
	if self_cd > 0 then
		erduan_spell_self_cd[casterInfo:GetGuid()] = nowtime + self_cd
	else
		erduan_spell_self_cd[casterInfo:GetGuid()] = nil
	end
	
	--如果触发割喉，则不触发其他技能
	if tb_skill_base[spell_id].is_kill == 1 then
		if DoHandleGeHou(caster, target, SPELL_ID_GEHOU) then
			return false
		end
	end
	]]

	return true
end

--增加施法信息
function AddSpellCastinfo(caster, target, damage, attacktype, spell_id, dstx, dsty, reserve2, reserve3)

	if(caster == nil)then
		outDebug("tip: add fighting info caster is nil")
		return 
	end

	local casterInfo = UnitInfo:new{ptr = caster}	
	FightingInfo:SetCasterGuid(casterInfo:GetGuid())
	FightingInfo:SetCasterIntGuid(casterInfo:GetIntGuid())
	local caster_typeid = GetUnitTypeID(caster)
	if(caster_typeid == TYPEID_PLAYER)then
		FightingInfo:SetCasterType(TYPEID_PLAYER)	
	else
		FightingInfo:SetCasterType(TYPEID_UNIT)	
	end
	
	if(target ~= nil)then	--允许目标为nil
		local targetInfo = UnitInfo:new{ptr = target}
		FightingInfo:SetTargetGuid(targetInfo:GetGuid())
		FightingInfo:SetTargetIntGuid(targetInfo:GetIntGuid())
		FightingInfo:SetTargetType( GetUnitTypeID(target) )			
		--添加仇恨
		if(targetInfo:GetTypeID() == TYPEID_UNIT and target ~= caster and damage ~= 0)then	
			creatureLib.ModifyThreat(target, caster, damage)
		end
	end
	FightingInfo:SetDamage(damage)
	FightingInfo:SetAttackType(attacktype)
	FightingInfo:SetSpellId(spell_id)
	if(dstx ~= nil)then
		FightingInfo:SetReserve0(dstx)		--暂时保存把目标击飞到的x坐标
	end
	if(dsty ~= nil)then
		FightingInfo:SetReserve1(dsty)		--暂时保存把目标击飞到的y坐标
	end
	if(reserve2 ~= nil)then
		FightingInfo:SetReserve2(reserve2)
	end
	if(reserve3 ~= nil)then
		FightingInfo:SetReserve3(reserve3)
	end

	FightingInfo:Next()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
----------------------------------------------------------------------------------------------------------
--											使用魔法入口									  			--
----------------------------------------------------------------------------------------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- 释放技能入口
--（@caster：施法者，@target：攻击目标，@dst_x@dst_y：技能坐标点，@spellid：技能id，@spell_lv：技能等级，@unit：技能用精灵，@data：预留参数）
function DoSpellCastScript(caster, target, dst_x, dst_y, spell_id, spell_lv, unit, data)
	local allTargets = {}
	local casterInfo = UnitInfo:new{ptr = caster}

	-- 扇形(以自己为圆心, 有朝向)

	-- 圆形
		-- 以自己为圆心
		-- 以(dst_x, dst_y)为圆心, 需要认证正确性

	if true then
		local caster_x, caster_y = unitLib.GetPos(caster)
		local r = 5

		--[[
			float start_x	= (float)LUA_TONUMBER(scriptL,1);
	float end_y		= (float)LUA_TONUMBER(scriptL,2);
	float end_x		= (float)LUA_TONUMBER(scriptL,3);
	float start_y	= (float)LUA_TONUMBER(scriptL,4);

	Unit* unit = (Unit*)LUA_TOUSERDATA(scriptL,5, ObjectTypeUnit);
	if (!unit)
	{
		tea_perror("error: LuaGetRectTargets unit = null");
		return 0;
	}
	Spell_Target_Type TargetType = (Spell_Target_Type)(int)LUA_TONUMBER(scriptL,6);
		]]


		local targetUnits = mapLib.GetRectTargets(caster_x-5, caster_y+5, caster_x+5, caster_y-5, caster, TARGET_TYPE_ENEMY)
		local dam = 10
		if casterInfo:GetTypeID() == TYPEID_PLAYER then
			dam = 100
		end

		local hasTarget = false
		for _, _target in pairs(targetUnits) do
			--print("hit target:")
			--print("	"..unitLib.GetIntGuid(_target))
			if caster ~= _target then
				hasTarget = true
				AddSpellCastinfo(caster, _target, dam, HITINFO_NORMALSWING, spell_id)
				--BuffTargetType(_target,caster,spell_id,spell_lv,BUFF_JIANSU,dst_x,dst_y,10,80)
			end
		end
		
		if not hasTarget then
			--print("not find target:")
			AddSpellCastinfo(caster, caster, 0, HITINFO_NORMALSWING, spell_id)
		end
		
		return true
	end
	



	if(GetUnitTypeID(caster) == TYPEID_PLAYER)then
		if(unit == nil)then
			--[[FIXME
			--取一下二段技能
			spell_id = casterInfo:GetNextSpellID(spell_id)
			--设置下一个技能有效时间
			casterInfo:SetNextSpellValid(spell_id)
			spell_lv = casterInfo:GetNextSpellLv(spell_id,spell_lv)
			]]
		end
	end


	if(spell_id >= SPELL_ID_LUOYANZHAN_1 and spell_id <= SPELL_ID_LUOYANZHAN_3)then	--落雁斩1
		if GetUnitTypeID(caster) == TYPEID_PLAYER then
			if(unit == nil)then
				spell_id = casterInfo:GetLYZSpellStyle(spell_id)
				handle_cast_add_unit_effect_lyz(caster, target, spell_id, spell_lv,dst_x, dst_y)
				return false
			else
				luoyanzhan_spell_time[casterInfo:GetPlayerGuid()] = getMsTime()
				SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
			end
		else
			casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
		end
	elseif(spell_id == SPELL_ID_QUANTUMIAOSHA)then		--全屏秒杀
		handle_cast_monomer_quantumiaosha(spell_id,caster)	
	elseif(spell_id == SPELL_ID_CHONGFENG)then		--冲锋
		handle_cast_spell_chongfeng(caster,target,dst_x,dst_y,spell_id,spell_lv)
	elseif(spell_id >= LIUDAO_SPELL_XUNSHI and spell_id <= LIUDAO_SPELL_XIULUOLI)then	--六道轮回技能
		handle_cast_monomer_liudao_spell(caster, target, spell_id)
	elseif(spell_id == SPELL_ID_WUXIANGJIEZHI)then	--无相劫指
		if(unit == nil)then
			handle_cast_add_unit_effect_wxjz(caster, target, spell_id,spell_lv)
			return false
		else
			handle_cast_monomer_wuxiangjiezhi(caster, target, dst_x,dst_y,spell_id, spell_lv, allTargets)
		end
	elseif(spell_id == SPELL_ID_ANXIANGSHUYING)then	--暗香疏影
		if(unit == nil)then
			handle_cast_add_unit_effect_axsy(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			handle_cast_monomer_anxiangshuying(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
		end
	elseif(spell_id == SPELL_ID_YUNFEIYUHUANG_2)then	--云飞玉皇·二段
		if(unit == nil)then
			handle_cast_add_unit_effect_yfyh(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			handle_cast_monomer_yunfeiyuhuang_2(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
		end
	elseif(spell_id == SPELL_ID_YUNFEIYUHUANG_3)then	--云飞玉皇·三段
		if(unit == nil)then
			handle_cast_add_unit_effect_yfyh_3(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			handle_cast_monomer_yunfeiyuhuang_3(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
		end
	elseif(spell_id == SPELL_ID_FENGFANYUNBIAN_1)then	--风翻云变·一段
		if(unit == nil)then
			handle_cast_add_unit_effect_ffyb_1(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			handle_cast_monomer_fengfanyunbian_1(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
		end
	elseif(spell_id == SPELL_ID_FENGFANYUNBIAN_2)then	--风翻云变·二段
		if(unit == nil)then
			handle_cast_add_unit_effect_ffyb_2(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
		end
	elseif(spell_id == SPELL_ID_ZHUXIANJIANZHEN_1)then	--诛仙剑阵·一段	
		if(unit == nil)then
			handle_cast_add_unit_effect_zxjz_1(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
		end
	elseif(spell_id == SPELL_ID_ZHUXIANJIANZHEN_2)then	--诛仙剑阵·二段
		if(unit == nil)then
			handle_cast_monomer_zhuxianjianzhen_2(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
		else
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
			BuffTargetType(target,caster,spell_id,spell_lv,BUFF_DINGSHEN,dst_x,dst_y,3)
		end
	elseif(spell_id == SPELL_ID_WANJIANGUIZHONG)then	--万剑归宗	
		if(unit == nil)then
			handle_cast_add_unit_effect_wjgz(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
			--减速40%，持续3秒
			BuffTargetType(target,caster,spell_id,spell_lv,BUFF_JIANSU,dst_x,dst_y,3,40)
		end
	
	elseif(spell_id >= BOSS_SPELL_DINGSHEN and spell_id <= BOSS_SPELL_BOSSSPELL3)then	--boss技能	
		handle_cast_monomer_boss(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	elseif(spell_id == SWFJ_SPELL_TSHF)then	
		local index = tb_skill_base[spell_id].uplevel_id[1] + spell_lv - 1
		local js_config = tb_skill_uplevel[index]
		local js_time = js_config.type_effect[3]
		local js_bili = js_config.type_effect[2]
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_JIANSU,dst_x,dst_y,js_time,js_bili)
		SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	--生化危机技能
	elseif spell_id >= SHWJ_SPELL_BUQIANG and spell_id <= SHWJ_SPELL_BIANYI_ZAISHENG then
		handle_cast_monomer_shwj_spell(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	--荒岛求生技能
	elseif spell_id >= HDQS_SPELL_NORMAL and spell_id <= HDQS_SPELL_NET then
		handle_cast_hdqs_spell(caster, target, spell_id, spell_lv, dst_x, dst_y)
	elseif spell_id == SPELL_ID_GEHOU then
		handle_cast_monomer_gehou(caster, target, spell_id,spell_lv,dst_x,dst_y)
	elseif spell_id == XIALV_SPELL_YHLW then
		if(unit == nil)then
			handle_cast_add_unit_effect_xialv_yhlw(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
		end	
		
	elseif spell_id == PASSIVESPELLID_CJDG or spell_id == PASSIVESPELLID_HSQJ then
		if(unit == nil)then
			handle_cast_add_unit_effect_jianqiao(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
			return false
		else
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
		end
	else
		--蓄力技能
		local sing_time = tb_skill_base[spell_id].spell_time
		if #sing_time > 0 then
			if unit == nil then
				handle_cast_add_unit_effect_boss(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data,sing_time)
				return false
			else
				if casterInfo:GetCurSpellId() == sing_time[1] then
					casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
					SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
					casterInfo:ClearCurSpell(true)
				end
			end
		--不需要蓄力技能	
		else
			if(GetUnitTypeID(caster) == TYPEID_PLAYER 
				or casterInfo:GetUnitFlags(UNIT_FIELD_FLAGS_IS_BOSS_CREATURE)
				or casterInfo:GetUnitFlags(UNIT_FIELD_FLAGS_IS_XIALV)
				)then
				local targetintguid = 0
				if(target ~= nil)then
					local targetInfo = UnitInfo:new{ptr = target}
					targetintguid = targetInfo:GetIntGuid()
				end
				casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),targetintguid,spell_id,{dst_x,dst_y},true)
			end
			SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
		end
	end
	-- 处理被动技能
	DoPassiveSpellProceed(caster, allTargets, spell_id)
	return true
end

-- 处理被动技能
function DoPassiveSpellProceed(caster, allTargets, spell_id)
	--处理被动技能
	if(#allTargets > 0)then -- 是否闪避
		if GetUnitTypeID(caster) ~= TYPEID_PLAYER then		-- 不是玩家不用进来了
			return
		end		
		local playerInfo = UnitInfo:new{ptr = caster}
		for key, temptarget in pairs(allTargets) do
			--目标主动攻击时的被动技能效果
			calculPassiveSpell1(caster, temptarget, spell_id)
			if GetUnitTypeID(temptarget) == TYPEID_PLAYER then
				--目标受到攻击时，查看是否有可触发的被动技能
				-- calculPassiveSpell2(temptarget, caster)
			end
		end		
	end
end






--目标主动攻击时的被动技能处理
function calculPassiveSpell1(caster, target, spell_id)
	local timenow = os.time()
	local playerInfo = UnitInfo:new{ptr = caster}
	for i = 0, MAX_PASSIVE_SPELL_COUNT-1 do
		local passive_id = playerInfo:GetPassiveSpellId(i)
		local passive_lv = playerInfo:GetPassiveSpellLevel(i)
		local passive_cd = playerInfo:GetPassiveSpellCD(i)
		local config = tb_skill_base[passive_id]
		local need_setcd = true
		if config and config.is_initiative == 1 and passive_lv > 0 and passive_cd <= timenow then
			local rand = randInt(1, 10000)
			if rand <= config.skill_percent then
				--处理具体技能效果

				--暗器技能
				DoAnqiPassiveSpell(caster, target, passive_id, passive_lv)
				--剑鞘技能
				need_setcd = DoJianQiaoPassiveSpell(caster, target, passive_id, passive_lv)
				if need_setcd then
					playerInfo:SetPassiveCD(passive_id)
				end
			end
		end
	end
end



--暗器被动技能效果
function DoAnqiPassiveSpell(caster, target, passive_id, level)
	local dst_x, dst_y = unitLib.GetPos(target)
	if(passive_id == PASSIVESPELLID_FHZY or passive_id == PASSIVESPELLID_BYLH)then --飞花摘叶、暴雨梨花
		SpellTargetType(caster,target,passive_id,level,dst_x,dst_y,{})
	elseif(passive_id == PASSIVESPELLID_LSCH)then --辣手摧花
		local uplevel_id = tb_skill_base[passive_id].uplevel_id[1]
		local id = uplevel_id+level-1
		BuffTargetType(target,caster,passive_id,level,BUFF_ANQI_LSCH,dst_x,dst_y,tb_skill_uplevel[id].type_effect[4],id)
	elseif(passive_id == PASSIVESPELLID_FHYY)then --风花饮月
		local uplevel_id = tb_skill_base[passive_id].uplevel_id[1]
		local id = uplevel_id+level-1
		BuffTargetType(caster,caster,passive_id,level,BUFF_ANQI_FHYY,dst_x,dst_y,tb_skill_uplevel[id].type_effect[3],id)
	end
end

--剑鞘被动技能效果
function DoJianQiaoPassiveSpell(caster, target, passive_id, level)
	local dst_x, dst_y = unitLib.GetPos(target)
	local targetInfo = UnitInfo:new{ptr = target}
	if passive_id == PASSIVESPELLID_CJDG or passive_id == PASSIVESPELLID_HSQJ then
		if target ~= unitLib.GetTarget(caster) then
			return false
		end
		spellCastScript(caster, targetInfo:GetGuid(), dst_x, dst_y, passive_id, level, "")
	elseif passive_id == PASSIVESPELLID_TZSL then
		local index = tb_skill_base[passive_id].uplevel_id[1] + level - 1
		local times = tb_skill_uplevel[index].type_effect[3]
		local reserve = tb_skill_uplevel[index].type_effect[2]
		BuffTargetType(caster,caster,passive_id,level,BUFF_TIANZHUSHENLI,dst_x,dst_y,times,reserve)
	elseif passive_id == PASSIVESPELLID_LSHZ then
		local index = tb_skill_base[passive_id].uplevel_id[1] + level - 1
		local times = tb_skill_uplevel[index].type_effect[3]
		local reserve = tb_skill_uplevel[index].type_effect[2]
		BuffTargetType(caster,caster,passive_id,level,BUFF_LINGSHENHUZHU,dst_x,dst_y,times,reserve)	
	end
	return true
end



--设置被动技能cd
function UnitInfo:SetPassiveCD(passive_id)
	local nowtime = os.time()
	local config = tb_skill_base[passive_id]
	if not config then return end
	local category_cd = config.groupCD / 1000		--公共cd
	local single_cd = config.singleCD / 1000		--单独cd
	local type = config.group						--技能族(同一技能族共享公共CD)
	--给同一族的技能设置公共CD
	for i = 0, MAX_PASSIVE_SPELL_COUNT-1 do
		local temp_id = self:GetPassiveSpellId(i)
		if temp_id == passive_id and single_cd > 0 then
			local cd_tm = nowtime + single_cd
			if self:GetPassiveSpellCD(i) ~= cd_tm then
				self:SetPassiveSpellCD(i,cd_tm)
			end
		end
		if tb_skill_base[temp_id] ~= nil and type == tb_skill_base[temp_id].group and category_cd > 0 then
			if temp_id == passive_id and category_cd > single_cd then
				local cd_tm = nowtime + category_cd
				if self:GetPassiveSpellCD(i) ~= cd_tm then
					self:SetPassiveSpellCD(i, cd_tm)
				end
			elseif temp_id ~= passive_id then
				local cd_tm = nowtime + category_cd
				if self:GetPassiveSpellCD(i) < cd_tm then
					self:SetPassiveSpellCD(i, cd_tm)
				end
			end
		end
	end
end

--boss技能定时器
function handle_cast_add_unit_effect_boss(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data,sing_time)
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, sing_time[2], 1, "")
	local creatureInfo = UnitInfo:new{ptr = caster}
	creatureInfo:SetCurSpellId(sing_time[1])
	creatureInfo:SetCurSpellTime(getMsTime() + sing_time[2])
	--加吟唱buff
	SpelladdBuff(caster, BUFF_YINCHANG, caster, 1, math.ceil((sing_time[2] + tb_skill_base[spell_id].groupCD)/1000))
end 

--boss技能
function handle_cast_monomer_boss(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	
	
	if(spell_id == BOSS_SPELL_DINGSHEN)then		--定身
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_DINGSHEN,dst_x,dst_y)
	elseif(spell_id == BOSS_SPELL_JIANSU)then	--枷锁
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_DINGSHEN,dst_x,dst_y)
	elseif(spell_id == BOSS_SPELL_GOUHE)then	--沟壑
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_YUNXUAN,dst_x,dst_y)
	elseif(spell_id == BOSS_SPELL_ELING)then	--恶灵
		--刷普通怪
		local creature_entry = tb_creature_template[1].id
		local map_ptr = unitLib.GetMap(caster)
		local pos_x, pos_y = unitLib.GetPos(caster)
		for i = 1, 5 do
			local randX, randY = GetRandPosByRadius(map_ptr, pos_x, pos_y, 20)
			local creature = mapLib.AddCreature(map_ptr, {templateid = creature_entry, x = randX, y = randY, ainame = 'AI_guaiwu', active_grid = true, npcflag = {}})
			if creature ~= nil then
				--攻击模式
				creatureLib.SetReactState(creature,REACT_AGGRESSIVE_PLAYER)
				--设置主人
				creatureLib.SetMonsterHost(creature,caster)
				--设置移动类型
				creatureLib.MonsterMove(creature,FOLLOW_MOTION_TYPE,caster,-15000)
				--帮恶灵设置一个技能 每次对目标造成1%生命的伤害
				--creatureLib.MonsterAddSpell(creature, 99999, 1000, 1)
			end
		end	
	elseif(spell_id == BOSS_SPELL_SIWANGYIZHI)then	--死亡一指
		if target == nil then
			return
		end
		local targetInfo = UnitInfo:new{ptr = target}
		AddSpellCastinfo(caster, target, targetInfo:GetHealth()*0.8, HITINFO_NORMALSWING, spell_id )
	elseif(spell_id == BOSS_SPELL_LIUXUE)then	--流血
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_LINGXUE,dst_x,dst_y)
	elseif(spell_id == BOSS_SPELL_ZHUOSHAO)then	--灼烧
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_ZHUOSHAO,dst_x,dst_y)		
	elseif(spell_id == BOSS_SPELL_ZHONGDU)then	--中毒
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_ZHONGDU,dst_x,dst_y)
	elseif(spell_id == BOSS_SPELL_BINGJIA)then	--冰甲
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_BINGJIA,dst_x,dst_y)	
	elseif(spell_id == BOSS_SPELL_DILEI)then	--地雷
		--刷普通怪
		local creature_entry = tb_creature_template[1].id
		local map_ptr = unitLib.GetMap(caster)
		local pos_x, pos_y = unitLib.GetPos(caster)
		local randX, randY = GetRandPosByRadius(map_ptr, pos_x, pos_y, 15)
		local creature = mapLib.AddCreature(map_ptr, {templateid = creature_entry, x = randX, y = randY, ainame = 'AI_guaiwu', active_grid = true, npcflag = {}})
		if creature~=nil then
			--攻击模式
			creatureLib.SetReactState(creature,REACT_DEFENSIVE)
			--设置主人
			creatureLib.SetMonsterHost(creature,caster)
			SpelladdBuff(creature, BUFF_BAOZHA_DILEI, caster, 1, tb_buff_template[BUFF_BAOZHA_DILEI].duration)
			SpelladdBuff(creature, BUFF_WUDI, caster, 1, 40)
			creatureLib.MonsterMove(creature,DISAPPEAR_ONE_MOTION_TYPE,tb_buff_template[BUFF_BAOZHA_DILEI].duration*1000)
		end
	elseif(spell_id == BOSS_SPELL_ZHAOHUAN)then	--召唤
		--刷普通怪
		local creature_entry = tb_creature_template[1].id
		local map_ptr = unitLib.GetMap(caster)
		local pos_x, pos_y = unitLib.GetPos(caster)
		local creature = mapLib.AddCreature(map_ptr, {templateid = creature_entry, x = pos_x, y = pos_y, ainame = 'AI_guaiwu', active_grid = true, npcflag = {}})
		if creature~=nil then
			--攻击模式
			creatureLib.SetReactState(creature,REACT_AGGRESSIVE_PLAYER)
			--设置主人
			creatureLib.SetMonsterHost(creature,caster)
			--设置移动类型
			creatureLib.MonsterMove(creature,FOLLOW_MOTION_TYPE,caster,-40000)--设置时间
		end
	elseif(spell_id == BOSS_SPELL_BIAOJI)then	--标记
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_BIAOJI,dst_x,dst_y)
	elseif(spell_id == BOSS_SPELL_JIANSU)then	--减速
		SpelladdBuff(target, BUFF_JIANSU, caster, 1, tb_game_set[88].value[1],tb_game_set[88].value[2])
	elseif(spell_id == BOSS_SPELL_CHENMO)then	--沉默
		BuffTargetType(target,caster,spell_id,spell_lv,BUFF_CHENMO,dst_x,dst_y)		
	else
		SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	end
end






function handle_cast_add_unit_effect_lyz(caster, target, spell_id, spell_lv,dst_x, dst_y)
	local casterInfo = UnitInfo:new{ptr = caster}
	casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	unitLib.AddSpellTrigger(caster,"", dst_x, dst_y, spell_id, spell_lv, 50, 1, "")
end

--全图秒杀
function handle_cast_monomer_quantumiaosha(spell_id, caster)
	local map_ptr = unitLib.GetMap(caster)
	local map_id = unitLib.GetMapID(caster)
	if not (map_id >= 201 and map_id <= 206) then
		return --只有副本地图才能全图秒杀
	end
	local allPlayers = mapLib.GetAllPlayer(map_ptr)
	if(#allPlayers == 1)then
		local allCreatures = mapLib.GetAllCreature(map_ptr)
		for _, creature_ptr in pairs(allCreatures) do
			local creatureInfo = UnitInfo:new{ptr = creature_ptr}
			AddSpellCastinfo(caster, creature_ptr, creatureInfo:GetMaxHealth(), HITINFO_NORMALSWING, spell_id)			
		end	
	end
end

--无相劫指定时器
function handle_cast_add_unit_effect_wxjz(caster, target, spell_id,spell_lv)
	if(target == nil)then
		return
	end
	local creatureInfo = UnitInfo:new{ptr = caster}
	local targetInfo = UnitInfo:new{ptr = target}
	local target_x, target_y = unitLib.GetPos(target)
	local map_ptr = unitLib.GetMap(caster)
	if not map_ptr then return end
	local angle = creatureInfo:GetAngle(target_x, target_y)
	local distance = 15 - creatureInfo:GetDistance(target_x, target_y)	--击退距离
	local pos_x,pos_y
	if distance <= 0 then
		pos_x = target_x
		pos_y = target_y
	else
		while(distance > 0)do
			pos_x = target_x + distance * math.cos(angle)
			pos_y = target_y + distance * math.sin(angle)
			if mapLib.IsCanRun(map_ptr, pos_x, pos_y) ~= 0 then
				break
			else
				distance = distance - 0.5
			end
		end
	end
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),targetInfo:GetIntGuid(),spell_id,{pos_x,pos_y,pos_x,pos_y},true)
	unitLib.AddSpellTrigger(caster, targetInfo:GetGuid(), pos_x, pos_y, spell_id, spell_lv, 200, 1, "")
	SpelladdBuff(caster, BUFF_WUXIANGJIEZHI, caster, 1, tb_buff_template[BUFF_WUXIANGJIEZHI].duration)
end

--无相劫指
function handle_cast_monomer_wuxiangjiezhi(caster, target, dst_x,dst_y,spell_id, spell_lv, allTargets)
	if(target == nil)then
		return
	end
	local targetInfo = UnitInfo:new{ptr = target}
	handle_cast_monomer_spell(caster, target, spell_id, spell_lv, allTargets)
	--击退目标
	local map_ptr = unitLib.GetMap(caster)
	if not map_ptr then return end
	if mapLib.IsCanRun(map_ptr, dst_x, dst_y) == 1 then
		unitLib.SetPos(caster, dst_x, dst_y)
		unitLib.SetPos(target, dst_x, dst_y)
		AddSpellCastinfo(caster, target, 0, HITINFO_BLOWFLY, spell_id,dst_x,dst_y)
	end
	--将对目标定身2秒
	SpelladdBuff(target, BUFF_DINGSHEN, caster, 1, 2)
	--清空目标正在释放的技能
	targetInfo:ClearCurSpell(false)
end

--暗香疏影定时器
function handle_cast_add_unit_effect_axsy(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	local casterInfo = UnitInfo:new{ptr = caster}
	casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, 500, 6, "")
end

--暗香疏影
function handle_cast_monomer_anxiangshuying(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	local casterInfo = UnitInfo:new{ptr = caster}
	if casterInfo:IsAlive() then
		SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	end
end

function handle_cast_add_unit_effect_yfyh(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	if(target == nil)then
		return
	end
	local targetInfo = UnitInfo:new{ptr = target}
	local casterInfo = UnitInfo:new{ptr = caster}
	casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),targetInfo:GetIntGuid(),spell_id,{dst_x,dst_y},true)
	unitLib.AddSpellTrigger(caster, targetInfo:GetGuid(), dst_x, dst_y, spell_id, spell_lv, 150, 1, "")
end

--云飞玉皇·二段
function handle_cast_monomer_yunfeiyuhuang_2(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	--并且100%将目标挑飞，浮空2秒，浮空期间目标无法移动、攻击等
	BuffTargetType(target,caster,spell_id,spell_lv,BUFF_ZHIKONG,dst_x,dst_y)
end

function handle_cast_add_unit_effect_yfyh_3(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	if(target == nil)then
		return
	end
	local creatureInfo = UnitInfo:new{ptr = caster}
	local targetInfo = UnitInfo:new{ptr = target}
	--击退目标5码
	local map_ptr = unitLib.GetMap(caster)
	if map_ptr == nil then return end
	local angle = creatureInfo:GetAngle(dst_x, dst_y)
	local distance = 5	--击退距离
	local pos_x,pos_y
	while(distance > 0)do
		pos_x = dst_x + distance * math.cos(angle)
		pos_y = dst_y + distance * math.sin(angle)
		if mapLib.IsCanRun(map_ptr, pos_x, pos_y) ~= 0 then
			unitLib.SetPos(target, pos_x, pos_y)
			break
		else
			distance = distance - 0.5
		end
	end
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),targetInfo:GetIntGuid(),spell_id,{pos_x,pos_y},true)
	unitLib.AddSpellTrigger(caster, targetInfo:GetGuid(), pos_x, pos_y, spell_id, spell_lv, 400, 1, "")
end

--云飞玉皇·三段
function handle_cast_monomer_yunfeiyuhuang_3(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	--伤害
	SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	AddSpellCastinfo(caster, target, 0, HITINFO_BLOWFLY, spell_id,dst_x,dst_y) 
	--玩家自身浮空，浮空期间不会受到控制、击退等（会受到伤害）
	BuffTargetType(caster,caster,spell_id,spell_lv,BUFF_FUKONG,dst_x,dst_y)
end

--风翻云变·一段定时器
function handle_cast_add_unit_effect_ffyb_1(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	local map_ptr = unitLib.GetMap(caster)
	if map_ptr == nil then return end
	local creatureInfo = UnitInfo:new{ptr = caster}
	local index = tb_skill_base[spell_id].uplevel_id[1] + spell_lv - 1
	local max_distance = tb_skill_uplevel[index].distance
	local distance = creatureInfo:GetDistance(dst_x, dst_y)
	local angle = creatureInfo:GetAngle(dst_x, dst_y)
	local cast_x, cast_y = unitLib.GetPos(caster)
	distance = distance > max_distance and max_distance or distance
	while(distance > 0)do
		dst_x = cast_x + distance * math.cos(angle)
		dst_y = cast_y + distance * math.sin(angle)
		if mapLib.IsCanRun(map_ptr, dst_x, dst_y) ~= 0 then
			break
		else
			distance = distance - 0.5
		end
	end
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, 700, 1, "")
end

--风翻云变·一段
function handle_cast_monomer_fengfanyunbian_1(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	unitLib.SetPos(caster, dst_x, dst_y)
	SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	--减速40%，持续4秒
	BuffTargetType(target,caster,spell_id,spell_lv,BUFF_JIANSU,dst_x,dst_y,4,40)
end

--风翻云变·二段定时器
function handle_cast_add_unit_effect_ffyb_2(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	local creatureInfo = UnitInfo:new{ptr = caster}
	local pos_x,pos_y
	local cas_x, cas_y = unitLib.GetPos(caster)
	local angle = creatureInfo:GetAngle(dst_x, dst_y)
	local map_ptr = unitLib.GetMap(caster)
	if not map_ptr then return end
	local distance = 12
	while(distance > 0)do
		pos_x = cas_x + distance * math.cos(angle)
		pos_y = cas_y + distance * math.sin(angle)
		if mapLib.IsCanRun(map_ptr, pos_x, pos_y) ~= 0 then
			break
		else
			distance = distance - 0.5
		end
	end
	unitLib.SetPos(caster, pos_x, pos_y)
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),0,spell_id,{pos_x,pos_y},true)
	unitLib.AddSpellTrigger(caster, "", cas_x, cas_y, spell_id, spell_lv, 250, 1, "")
end


--万剑归宗定时器
function handle_cast_add_unit_effect_wjgz(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	local creatureInfo = UnitInfo:new{ptr = caster}
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, 500, 12, "")
	SpelladdBuff(caster, BUFF_WANJIANGUIZONG, caster, 1, tb_buff_template[BUFF_WANJIANGUIZONG].duration)
	SpelladdBuff(caster, BUFF_WUDI, caster, 1, tb_buff_template[BUFF_WANJIANGUIZONG].duration)
end

--诛仙剑阵·一段定时器
function handle_cast_add_unit_effect_zxjz_1(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	--处理一下最大距离
	local creatureInfo = UnitInfo:new{ptr = caster}
	local index = tb_skill_base[spell_id].uplevel_id[1] + spell_lv - 1
	local max_distance = tb_skill_uplevel[index].distance
	local distance = creatureInfo:GetDistance(dst_x, dst_y)
	local angle = creatureInfo:GetAngle(dst_x, dst_y)
	local cast_x, cast_y = unitLib.GetPos(caster)
	distance = distance > max_distance and max_distance or distance
	dst_x = cast_x + distance * math.cos(angle)
	dst_y = cast_y + distance * math.sin(angle)
	--通知客户端开始施法技能
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	--刷特效精灵
	local map_ptr = unitLib.GetMap(caster)
	if map_ptr == nil then return end
	local creature = mapLib.AddCreature(map_ptr, {templateid = 6001, x = dst_x, y = dst_y, ainame = 'AI_guaiwu', active_grid = true, npcflag = {UNIT_NPC_FLAG_GOSSIP}})
	if creature~=nil then
		creatureLib.MonsterMove(creature,DISAPPEAR_ONE_MOTION_TYPE,5000)
	end
	--技能延迟释放
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, 500, 10, "")
end

--诛仙剑阵·二段
function handle_cast_monomer_zhuxianjianzhen_2(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	--处理一下最大距离
	local creatureInfo = UnitInfo:new{ptr = caster}
	local index = tb_skill_base[spell_id].uplevel_id[1] + spell_lv - 1
	local max_distance = tb_skill_uplevel[index].distance
	local distance = creatureInfo:GetDistance(dst_x, dst_y)
	local angle = creatureInfo:GetAngle(dst_x, dst_y)
	local cast_x, cast_y = unitLib.GetPos(caster)
	distance = distance > max_distance and max_distance or distance
	dst_x = cast_x + distance * math.cos(angle)
	dst_y = cast_y + distance * math.sin(angle)
	--通知客户端开始施法技能
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	--刷特效精灵
	local map_ptr = unitLib.GetMap(caster)
	if map_ptr == nil then return end
	local creature = mapLib.AddCreature(map_ptr, {templateid = 6002, x = dst_x, y = dst_y, ainame = 'AI_guaiwu', active_grid = true, npcflag = {UNIT_NPC_FLAG_GOSSIP}})
	if creature~=nil then
		creatureLib.MonsterMove(creature,DISAPPEAR_ONE_MOTION_TYPE,4000)
	end
	--给伤害
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, 750, 3, "")
end






----------------------------------------------------------------------------------------------------------


--处理buff影响伤害和伤害类型
function handle_cast_monomer_buff(caster,target,total_damage,hit_info,spell_id)
	--buff伤害加深与减免百分比
	local buffPer = 0
	local targetInfo = UnitInfo:new{ptr = target}
	--无敌
	if unitLib.HasBuff(target, BUFF_WUDI) or unitLib.HasBuff(target, BUFF_JUMP_JUMP) then
		total_damage = 0
		hit_info = HITINFO_MISS
		return total_damage,hit_info
	end
	--反弹
	if unitLib.HasBuff(target, BUFF_FANTAN) then
		--反弹伤害
		AddSpellCastinfo(target, caster, total_damage/2, HITINFO_FANTANSHANGHAI, spell_id)
	end
	--连接
	if unitLib.HasBuff(target, BUFF_LIANJIE) then
		local reserve = unitLib.GetBuffReserve(target,BUFF_LIANJIE) + total_damage
		unitLib.SetBuffReserve(target, BUFF_LIANJIE, reserve)
		total_damage = 0
		hit_info = HITINFO_MISS
	end
	--恢复护盾
	if unitLib.HasBuff(target, BUFF_HUIFU_HUDUN) then
		targetInfo:ModifyHealth(total_damage)
		total_damage = 0
		hit_info = HITINFO_MISS
	end

	--易伤
	if unitLib.HasBuff(target, BUFF_YISHANG) then
		buffPer = buffPer + 1
	end
	--论剑-护体
	if unitLib.HasBuff(target, BUFF_LJ_HUTI) then
		buffPer = buffPer - 0.3
	end




	if buffPer < -1 then --减免最多全部减掉
		buffPer = -1
	end
	total_damage = total_damage * (1 + buffPer)
	
	--反击护盾
	if unitLib.HasBuff(target, BUFF_FANJI_HUDUN) then
		local reserve = unitLib.GetBuffReserve(target,BUFF_FANJI_HUDUN)
		if reserve > 0 and reserve >= total_damage then
			reserve = reserve - total_damage
			unitLib.SetBuffReserve(target, BUFF_FANJI_HUDUN, reserve)
			total_damage = 0
			hit_info = HITINFO_MISS
		--爆炸	--对周围8码范围的敌对玩家造成5000点伤害
		else
			unitLib.RemoveBuff(target,BUFF_FANJI_HUDUN)
			local cast_x, cast_y = unitLib.GetPos(target)
			local targets = mapLib.GetCircleTargets(cast_x, cast_y, 8, target, TARGET_TYPE_ENEMY)	
			for key, attack_target in pairs(targets) do
				--目标不能是自己				--不能是友好的
				if(attack_target ~= nil and attack_target ~= target)then
					AddSpellCastinfo(target, attack_target, 5000, HITINFO_NORMALSWING, spell_id)
				end
			end
		end
	end
	
	--护盾buff
	if unitLib.HasBuff(target, BUFF_HUDUN_BUFF) then
		local reserve = unitLib.GetBuffReserve(target, BUFF_HUDUN_BUFF)
		if reserve > 0 then
			total_damage = total_damage - reserve
			if total_damage < 0 then
				total_damage = 0
			end
			local after_reserve = reserve - total_damage
			if after_reserve < 0 then
				after_reserve = 0
			end
			unitLib.SetBuffReserve(target, BUFF_HUDUN_BUFF, after_reserve)
		end
	end
	
	--真实伤害buff
	if unitLib.HasBuff(caster, BUFF_TRUESHANGHAI_BUFF) then
		local reserve = unitLib.GetBuffReserve(caster, BUFF_TRUESHANGHAI_BUFF) / 100
		local true_damage = targetInfo:GetMaxHealth() * reserve
		AddSpellCastinfo(caster, target, true_damage, HITINFO_NORMALSWING, spell_id)
	end
	
	return total_damage,hit_info
end

-- 获取浮动值
function GetFlowDamage(damage)
	local flow = randIntD(98, 102)
	damage = damage * flow * 0.01	
	if(damage < 1)then
		damage = 1
	end
	return damage
end

--技能释放类型
function SpellTargetType(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)	
	local casterInfo = UnitInfo:new{ptr = caster}
	local shifang = tb_skill_base[spell_id].target_type --技能释放类型
	local _m_count = 0
	local index = tb_skill_base[spell_id].uplevel_id[1] + spell_lv - 1
	local max_count = tb_skill_uplevel[index].num	--施放数量
	local buff_table = tb_skill_uplevel[index].type_effect	--buff效果类型
	if shifang == SPELL_SHIFANG_DAN then--目标单体
		handle_cast_monomer_spell(caster, target, spell_id, spell_lv, allTargets)
		--处理技能触发buff
		handle_cast_monomer_spell_addbuff(caster,target,buff_table)
	else
		--发出点
		local cast_x, cast_y = unitLib.GetPos(caster)
		--施法点
		local shifa_x,shifa_y = cast_x,cast_y
		--对点释放的技能,施法点改变
		if shifang == SPELL_SHIFANG_DIAN then
			shifa_x = dst_x
			shifa_y = dst_y
		end
		--角度
		local angle = casterInfo:GetAngle(dst_x, dst_y)
		if tb_skill_base[spell_id].is_fix == 1 then
			angle = 0
		end
		--击中的目标们
		local hit_targets = ""
		local attack_mast = {0,0}
		for k = 1,#tb_skill_base[spell_id].attack_mast do
			attack_mast[k+2] = tb_skill_base[spell_id].attack_mast[k]
		end
		local target = unitLib.GetTarget(caster)	--获得攻击目标
		if max_count >= 1 then
			if target then
				--目标点
				local tar_x, tar_y = unitLib.GetPos(target)
				local pos = GetHitAreaPostion({cast_x,cast_y,shifa_x,shifa_y,tar_x,tar_y,angle})
				attack_mast[1] = pos[1]
				attack_mast[2] = pos[2]
				local isfriend = unitLib.IsFriendlyTo(caster, target)
				if CalHitTest(attack_mast)[1] and isfriend == 0 then
					handle_cast_monomer_spell(caster, target, spell_id, spell_lv, allTargets)
					--处理技能触发buff
					handle_cast_monomer_spell_addbuff(caster,target,buff_table)
					_m_count = _m_count + 1
					hit_targets = tar_x.."|"..tar_y
				end
			end
			if _m_count < max_count then
				local targets = mapLib.GetCircleTargets(cast_x, cast_y, 20, caster, TARGET_TYPE_ENEMY,true)		
				for _, attack_target in pairs(targets) do
					if attack_target ~= nil and attack_target ~= target and unitLib.IsCanHit(attack_target) == 0 then
						--目标点
						local tar_x, tar_y = unitLib.GetPos(attack_target)
						local pos = GetHitAreaPostion({cast_x,cast_y,shifa_x,shifa_y,tar_x,tar_y,angle})
						attack_mast[1] = pos[1]
						attack_mast[2] = pos[2]
						if CalHitTest(attack_mast)[1] then
							handle_cast_monomer_spell(caster, attack_target, spell_id, spell_lv, allTargets)
							--处理技能触发buff
							handle_cast_monomer_spell_addbuff(caster,target,buff_table)
							if hit_targets == "" then
								hit_targets = tar_x.."|"..tar_y
							else
								hit_targets = hit_targets.."|"..tar_x.."|"..tar_y
							end
							_m_count = _m_count + 1
							if(_m_count >= max_count)then
								break
							end
						end
					end
				end
			end
		end
		if GetUnitTypeID(caster) == TYPEID_PLAYER then
			casterInfo:QuerySpellEventInfo(casterInfo:GetPlayerGuid(),spell_id,cast_x,cast_y,angle,shifa_x,shifa_y,hit_targets)
		end
	end
end

--[[CAST:1]]
--单体接口,此接口玩家和怪物都可以调用
function handle_cast_monomer_spell(caster, target, spell_id, spell_lv, allTargets,tar_x, tar_y)
	if(target == nil)then
		return 	--这里是计算伤害的接口，没有目标怎么计算伤害
	end
	local casterInfo = UnitInfo:new{ptr = caster}
	local targetInfo = UnitInfo:new{ptr = target}
	if not targetInfo:IsAlive() then return end			--目标已经死了

	if tar_x == nil or tar_y == nil then
		tar_x, tar_y = unitLib.GetPos(target)	--获得目标坐标
	end
	local caster_typeid = GetUnitTypeID(caster)	
	local base_damage = calculDamage(caster, target, spell_id, spell_lv)  --基本伤害结果
	local hit_info = HITINFO_NORMALSWING
	local last_eva = GetLastEva(caster, target)
	local last_crit = GetLastCrit(caster, target)	
	local percent = randIntD(1, 10000)
	--闪避
	if percent <= last_eva then
		hit_info = HITINFO_MISS
		base_damage = 0
		AddSpellCastinfo(caster, target, base_damage, hit_info, spell_id, tar_x, tar_y)		
		return
	end

	--暴击
	percent = randIntD(1, 10000)
	if percent <= last_crit then
		hit_info = HITINFO_CRITHIT	
		base_damage = base_damage * 2
	end

	if tb_skill_base[spell_id].is_initiative == 0 then
		--威望加成
		base_damage = WeiWangAddSpellDamage(casterInfo,targetInfo,base_damage)
		--处理buff影响伤害和伤害类型
		base_damage,hit_info = handle_cast_monomer_buff(caster,target,base_damage,hit_info,spell_id)
	end

	--需要特殊hit_info的技能
	if SPECIL_HIT_INFO_TBL[spell_id] ~= nil then
		hit_info = SPECIL_HIT_INFO_TBL[spell_id]
	end

	--暗器buff：风花饮月，吸血
	if unitLib.HasBuff(caster, BUFF_ANQI_FHYY) then
		local reserve = unitLib.GetBuffReserve(caster, BUFF_ANQI_FHYY)
		local per = tb_skill_uplevel[reserve].type_effect[2]/100
		casterInfo:ModifyHealth(base_damage*per)
	end
	
	--弈棋伤害加成
	if caster_typeid == TYPEID_PLAYER then
		local add_yq = 0
		local yq_lv = casterInfo:GetYiQiLevel()
		for key,val in pairs(tb_yiqi_skill)do
			if val.id == spell_id then
				for i = 1,#val.shuxing,2 do
					if yq_lv >= val.shuxing[i] then
						add_yq = add_yq + val.shuxing[i+1]
					end
				end
			end
		end
		if add_yq > 0 then
			base_damage = base_damage + (base_damage*add_yq/100)
		end
	end
	
	--打包施法
	AddSpellCastinfo(caster, target, base_damage, hit_info, spell_id, tar_x, tar_y)
	--主动技能并且不是闪避才insert，防止重复
	if(tb_skill_base[spell_id].is_initiative == 0 and hit_info ~= HITINFO_MISS)then
		table.insert(allTargets, target)
		--真实击退
		DoTrueJiTui(caster,target,spell_id,tar_x,tar_y)
		DoTrueJiTui2(caster,target,spell_id,tar_x,tar_y)
	end
end



--技能触发buff
function handle_cast_monomer_spell_addbuff(caster, target, buff_table)
	for k = 1,#buff_table,4 do
		local buff_target = target
		if buff_table[k+3] == 0 then
			buff_target = caster
		elseif buff_table[k+3] == 2 then
			buff_target = creatureLib.GetMonsterHost(caster)
		end

		if buff_target then
			SpelladdBuff(buff_target, buff_table[k], caster, 1, buff_table[k+2],buff_table[k+1])
		end
	end
end

--buff添加类型
function BuffTargetType(unit,buff_giver,spell_id,spell_lv,buff_id,dst_x,dst_y,duration,reserve)
	local casterInfo = UnitInfo:new{ptr = buff_giver}
	local shifang = SPELL_SHIFANG_DAN
	--tb_skill_base[spell_id].target_type --释放类型
	--local duration = duration or tb_buff_template[buff_id].duration
	if shifang == SPELL_SHIFANG_DAN then	--目标单体
		SpelladdBuff(unit, buff_id, buff_giver, 1, duration,reserve)
	else
		--发出点
		local cast_x, cast_y = unitLib.GetPos(buff_giver)
		--施法点
		local shifa_x,shifa_y = cast_x,cast_y
		--对点释放的技能,施法点改变
		if shifang == SPELL_SHIFANG_DIAN then
			shifa_x = dst_x
			shifa_y = dst_y
		end
		--角度
		local angle = casterInfo:GetAngle(dst_x, dst_y)
		if tb_skill_base[spell_id].is_fix == 1 then
			angle = 0
		end
		local _m_count = 0
		local index = tb_skill_base[spell_id].uplevel_id[1] + spell_lv - 1
		local max_count = tb_skill_uplevel[index].num	--施放数量
		local attack_mast = {0,0}
		for k = 1,#tb_skill_base[spell_id].attack_mast do
			attack_mast[k+2] = tb_skill_base[spell_id].attack_mast[k]
		end
		local target = unitLib.GetTarget(buff_giver)	--获得攻击目标
		if max_count >= 1 then
			if target then
				--目标点
				local tar_x, tar_y = unitLib.GetPos(target)
				local pos = GetHitAreaPostion({cast_x,cast_y,shifa_x,shifa_y,tar_x,tar_y,angle})
				attack_mast[1] = pos[1]
				attack_mast[2] = pos[2]
				local isfriend = unitLib.IsFriendlyTo(buff_giver, target)
				if CalHitTest(attack_mast)[1] and isfriend == 0 then
					SpelladdBuff(target, buff_id, buff_giver, 1, duration,reserve)
					_m_count = _m_count + 1
				end
			end
			if _m_count < max_count then
				local targets = mapLib.GetCircleTargets(cast_x, cast_y, 20, buff_giver, TARGET_TYPE_ENEMY,true)		
				for _, attack_target in pairs(targets) do
					if attack_target ~= nil and attack_target ~= target then
						--目标点
						local tar_x, tar_y = unitLib.GetPos(attack_target)
						local pos = GetHitAreaPostion({cast_x,cast_y,shifa_x,shifa_y,tar_x,tar_y,angle})
						attack_mast[1] = pos[1]
						attack_mast[2] = pos[2]
						if CalHitTest(attack_mast)[1] then
							SpelladdBuff(attack_target, buff_id, buff_giver, 1, duration,reserve)
							_m_count = _m_count + 1
							if(_m_count >= max_count)then
								break
							end
						end
					end
				end
			end
		end
	end
end


--冲锋
function handle_cast_spell_chongfeng(caster,target,dst_x,dst_y,spell_id,spell_lv)
	if(GetUnitTypeID(caster) ~= TYPEID_PLAYER)then
		return 
	end
	local casterInfo = UnitInfo:new{ptr = caster}
	local map_ptr = unitLib.GetMap(caster)
	if map_ptr == nil then
		return
	end
	local index = casterInfo:GetSpellLvIndex(spell_id)
	local MAX_CAST_DISTANCE = tb_skill_uplevel[index].distance
	unitLib.StopMoving(caster, 1)	--施法者停止移动
	local angle = casterInfo:GetAngle(dst_x, dst_y)
	local distance = casterInfo:GetDistance(dst_x, dst_y)
	local cas_x, cas_y = unitLib.GetPos(caster)
	distance = distance > MAX_CAST_DISTANCE and MAX_CAST_DISTANCE or distance
	while(distance > 0)do
		dst_x = cas_x + distance * math.cos(angle)
		dst_y = cas_y + distance * math.sin(angle)
		if mapLib.IsCanRun(map_ptr, dst_x, dst_y) ~= 0 then
			break
		else
			distance = distance - 0.5
		end
	end
	if mapLib.IsCanRun(map_ptr, dst_x, dst_y) ~= 0 then
		casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
		unitLib.SetOrientation(caster, angle)				
		unitLib.SetPos(caster, dst_x, dst_y)	
		--用于给客户端播放特效
		AddSpellCastinfo(caster, nil, 0, HITINFO_CHONGFENG, spell_id, dst_x, dst_y)			
	else
		casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),0,spell_id,{cas_x,cas_y},true)
		unitLib.SetOrientation(caster, angle)
		--用于给客户端播放特效
		AddSpellCastinfo(caster, nil, 0, HITINFO_CHONGFENG, spell_id, cas_x, cas_y)
	end
	
end

--六道技能
function handle_cast_monomer_liudao_spell(caster, target, spell_id)
	local map_ptr = unitLib.GetMap(caster)
	local map_id = unitLib.GetMapID(caster)
	if(map_id ~= 31)then
		return
	end
	--狂奔
	if(spell_id == LIUDAO_SPELL_KUANGBEN)then
		SpelladdBuff(caster, BUFF_KUANGBEN, caster, 1, tb_buff_template[BUFF_KUANGBEN].duration)
	--火把
	elseif(spell_id == LIUDAO_SPELL_HUOBA)then
		local pos_x, pos_y = unitLib.GetPos(caster)
		local creature = mapLib.AddCreature(map_ptr, {templateid = 5416, x = pos_x, y= pos_y, ainame = "AI_LiuDaoLunHuiCreature", npcflag = {}})
		if(creature~=nil)then
			creatureLib.SetMonsterHost(creature, caster)
			SpelladdBuff(creature, BUFF_HUOBA, creature, 1, tb_buff_template[BUFF_HUOBA].duration)
			creatureLib.MonsterMove(creature,DISAPPEAR_ONE_MOTION_TYPE,tb_buff_template[BUFF_HUOBA].duration*1000)
		end
	--鬼爪
	elseif(spell_id == LIUDAO_SPELL_GUIZHUA)then	
		handle_cast_monomer_liudao_lunhui(caster, target,spell_id)	
	--妖术
	elseif(spell_id == LIUDAO_SPELL_YAOSHU)then	
		handle_cast_monomer_liudao_lunhui(caster, target,spell_id)
	--幻化
	elseif(spell_id == LIUDAO_SPELL_HUANHUA)then	
		local playerInfo = UnitInfo:new{ptr = caster}
		local rand = randIntD(1,100)
		for i = 1,#tb_liudaolunhui do
			if(rand <= tb_liudaolunhui[i].change_prob)then
				SpelladdBuff(caster, BUFF_HUANHUA, caster, 1, tb_buff_template[BUFF_HUANHUA].duration)
				--设置皮肤
				playerInfo:SetCreatureSkin(i)
				break
			else
				rand = rand - tb_liudaolunhui[i].change_prob
			end
		end
	--仙法
	elseif(spell_id == LIUDAO_SPELL_XIANFA)then	
		handle_cast_monomer_liudao_lunhui(caster, target,spell_id)	
	--嗜杀
	elseif(spell_id == LIUDAO_SPELL_SHISHA)then	
		handle_cast_monomer_liudao_lunhui(caster, target,spell_id)
	end
end


--六道轮回技能
function handle_cast_monomer_liudao_lunhui(caster, target,spell_id)
	if(target == nil)then
		return 	--这里是计算伤害的接口，没有目标怎么计算伤害
	end
	
	local casterInfo = UnitInfo:new{ptr = caster}
	local targetInfo = UnitInfo:new{ptr = target}
	if not targetInfo:IsAlive() then return end			--目标已经死了
	
	local map_ptr = unitLib.GetMap(caster)
	if not map_ptr then return end
	local mapInfo = Instance_liudaolunhui:new{ptr = map_ptr}
	
	local tar_x, tar_y = unitLib.GetPos(target)	--获得目标坐标
	local total_damage = casterInfo:GetMinDamage()
	local hit_info = HITINFO_NORMALSWING
	local zhiye = casterInfo:GetProfession()
	
	--鬼
	if(zhiye == mapInfo.LIUDAO_GUI)then
		if(unitLib.HasBuff(caster, BUFF_LINGTI))then
			unitLib.RemoveBuff(caster,BUFF_LINGTI)
		end
		SpelladdBuff(caster, BUFF_ZHANDOU_STATE, caster, 1, tb_buff_template[BUFF_ZHANDOU_STATE].duration)
	--妖
	elseif(zhiye == mapInfo.LIUDAO_YAO)then
		if(unitLib.HasBuff(caster, BUFF_HUANHUA))then
			unitLib.RemoveBuff(caster,BUFF_HUANHUA)
			casterInfo:SetCreatureSkin(0)
		end
	end
	
	--打包施法		
	AddSpellCastinfo(caster, target, total_damage, hit_info, spell_id, tar_x, tar_y)
end


--威望加成
function WeiWangAddSpellDamage(casterInfo,targetInfo,base_damage)
	if targetInfo:GetTypeID() == TYPEID_PLAYER and casterInfo:GetTypeID() == TYPEID_PLAYER then
		local g_lv = casterInfo:GetTouXianLv()
		local s_lv = targetInfo:GetTouXianLv()
		for i = 1,MAX_TOUXIAN_TYPE_COUNT do
			if casterInfo:GetGuid() == globalValue:GetWeiWangRankGuid(i) then
				g_lv = 100 - i
			end
			if targetInfo:GetGuid() == globalValue:GetWeiWangRankGuid(i) then
				s_lv = 100 - i
			end
		end
		if g_lv > s_lv then
			base_damage = base_damage + base_damage * ( tb_game_set[99].value[1]/100 )
		end
		
	end
	return base_damage
end

--生化危机技能
function handle_cast_monomer_shwj_spell(caster,target,spell_id,spell_lv,dst_x,dst_y, allTargets, unit, data)
	local casterInfo = UnitInfo:new{ptr = caster}
	local mapid = unitLib.GetMapID(caster)
	--不是生化危机地图就不用进了
	if mapid ~= SHWJ_INSTANCE_MAPID then 
		outFmtError("shwj_spell:mapid ~= SHWJ_INSTANCE_MAPID spell_id == %d",spell_id)
		return 
	end
	local map_ptr = unitLib.GetMap(caster)
	if not map_ptr then 
		outFmtError("shwj_spell:map_ptr == nil spell_id == %d",spell_id)
		return 
	end
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--不在比赛期间
	if mapInfo:GetMapState() ~= mapInfo.STATE_GAME_START then
		outFmtError("shwj_spell:state is not in game_start spell_id == %d",spell_id)
		return
	end
	--玩家索引
	local player_index = mapInfo:GetPlayerIndex(casterInfo:GetPlayerGuid())
	if player_index == -1 then 
		outFmtError("shwj_spell:player_index == -1 spell_id == %d",spell_id)
		return 
	end	
	--验证子弹
	if spell_id >= SHWJ_SPELL_BUQIANG and spell_id <= SHWJ_SPELL_JUJIQIANG then
		local cur_zidan = mapInfo:GetCurZiDanCount(player_index)
		--没子弹了
		if cur_zidan == 0 then
			outFmtError("shwj_spell:cur_zidan == 0 spell_id == %d",spell_id)
			return
		else	
			local use_zidan = 1
			if spell_id == SHWJ_SPELL_JIQIANG then
				use_zidan = 10
			end
			mapInfo:SubCurZiDanCount(player_index,use_zidan)
		end
	end		
	local shifang = tb_skill_base[spell_id].target_type --释放类型
	if shifang == SPELL_SHIFANG_DAN then	--目标单体
		--爆发突进
		if spell_id == SHWJ_SPELL_BAOFA_TUJIN then
			SpelladdBuff(caster, BUFF_BAOFATUJIN, caster, 1, tb_buff_template[BUFF_BAOFATUJIN].duration)
		--狙击枪
		elseif spell_id == SHWJ_SPELL_JUJIQIANG then
			handle_cast_monomer_shwj(caster, target, spell_id, spell_lv,mapInfo,player_index)
		end
	else
		--发出点
		local cast_x, cast_y = unitLib.GetPos(caster)
		--施法点
		local shifa_x,shifa_y = cast_x,cast_y
		--角度
		local angle = casterInfo:GetAngle(dst_x, dst_y)
		if tb_skill_base[spell_id].is_fix == 1 then
			angle = 0 
		end
		local _m_count = 0
		local index = tb_skill_base[spell_id].uplevel_id[1] + spell_lv - 1
		local max_count = tb_skill_uplevel[index].num	--施放数量
		local attack_mast = {0,0}
		for k = 1,#tb_skill_base[spell_id].attack_mast do
			attack_mast[k+2] = tb_skill_base[spell_id].attack_mast[k]
		end
		local target = unitLib.GetTarget(caster)	--获得攻击目标
		if max_count >= 1 then
			if target then
				local tar_x, tar_y = unitLib.GetPos(target)
				local pos = GetHitAreaPostion({cast_x,cast_y,shifa_x,shifa_y,tar_x,tar_y,angle})
				attack_mast[1] = pos[1]
				attack_mast[2] = pos[2]
				local isfriend = unitLib.IsFriendlyTo(caster, target)
				if CalHitTest(attack_mast)[1] and isfriend == 0 then
					handle_cast_monomer_shwj(caster, target, spell_id, spell_lv,mapInfo,player_index)
					_m_count = _m_count + 1
				end	
			end
			if _m_count < max_count then
				local targets = mapLib.GetCircleTargets(cast_x, cast_y, 20, caster, TARGET_TYPE_ENEMY,true)		
				for _, attack_target in pairs(targets) do
					if attack_target ~= nil and attack_target ~= target then
						--目标点
						local tar_x, tar_y = unitLib.GetPos(attack_target)
						local pos = GetHitAreaPostion({cast_x,cast_y,shifa_x,shifa_y,tar_x,tar_y,angle})
						attack_mast[1] = pos[1]
						attack_mast[2] = pos[2]
						if CalHitTest(attack_mast)[1] then
							handle_cast_monomer_shwj(caster, attack_target, spell_id, spell_lv,mapInfo,player_index)
							_m_count = _m_count + 1
							if(_m_count >= max_count)then
								break
							end
						end
					end
				end
			end
		end
	end
	local targetintguid = 0
	if(target ~= nil)then
		local targetInfo = UnitInfo:new{ptr = target}
		targetintguid = targetInfo:GetIntGuid()
	end
	casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),targetintguid,spell_id,{dst_x,dst_y},true)
end

--生化危机技能伤害
function handle_cast_monomer_shwj(caster,target,spell_id,spell_lv,mapInfo,player_index)
	if(target == nil)then
		outFmtError("shwj_spell:target == nil spell_id == %d",spell_id)
		return 	--这里是计算伤害的接口，没有目标怎么计算伤害
	end
	local casterInfo = UnitInfo:new{ptr = caster}
	local targetInfo = UnitInfo:new{ptr = target}
	
	if not targetInfo:IsAlive() then 
		outFmtError("shwj_spell:target is die spell_id == %d",spell_id)
		return 
	end			--目标已经死了
	local tar_x, tar_y = unitLib.GetPos(target)	--获得目标坐标
	local config
	for key,val in ipairs(tb_shwj_skill)do
		if val.spell_id == spell_id then
			config = tb_shwj_skill[key]
			break
		end
	end
	if not config then 
		outFmtError("shwj_spell:config is nil spell_id == %d",spell_id)
		return 
	end	
	--攻击者的职业
	local caster_zhiye = casterInfo:GetProfession()
	
	--伤害
	local hurt = config.hurt
	local total_damage = 0
	if #hurt > 0 then
		total_damage = math.floor( randIntD(hurt[1],hurt[2])*10 / (targetInfo:GetArmor()+1) )
	end

	local hit_info = HITINFO_NORMALSWING
	
	--闪避
	local eva = targetInfo:GetEva()
	local hit = config.attack_range[2]
	local last_hit = hit - eva	--命中率
	if randIntD(1,100) <= 100 - last_hit then
		hit_info = HITINFO_MISS
		total_damage = 0
		AddSpellCastinfo(caster, target, total_damage, hit_info, spell_id, tar_x, tar_y)
		return
	end
	
	--科技加成伤害
	if caster_zhiye >= SHWJ_PLAYER_TYPE_BUQIANG and caster_zhiye <= SHWJ_PLAYER_TYPE_JUJI then
		local keji_lv = mapInfo:GetKeJiLv(player_index,SHWJ_KEJI_TYPE_QIANGXIE)
		if keji_lv > 0 then
			local level_index = tb_shwj_science[SHWJ_KEJI_TYPE_QIANGXIE].level_id[keji_lv]
			local keji_config = tb_shwj_science_uplevel[level_index]
			--伤害
			total_damage = total_damage * (1 + keji_config.value[1]/100)
		end
	end
	
	--暴击
	local crit = config.crit
	if randIntD(1, 100) <= crit then
		hit_info = HITINFO_CRITHIT	
		total_damage = total_damage * 5
	end
	
	--爆发突进BUFF
	if unitLib.HasBuff(target, BUFF_BAOFATUJIN) then
		total_damage = total_damage * 1.5
	end
	--打包施法		
	AddSpellCastinfo(caster, target, total_damage, hit_info, spell_id, tar_x, tar_y)
	
	--击退
	if spell_id == SHWJ_SPELL_JIQIANG or spell_id == SHWJ_SPELL_JUJIQIANG then
		local base_pro = 100	--基本击退概率
		if spell_id == SHWJ_SPELL_JIQIANG then
			base_pro = 50
		end
		if unitLib.HasBuff(target, BUFF_BAOFATUJIN) then	--爆发突进80概率%击退免疫
			base_pro = base_pro * (1 - 0.8)
		end
		if randIntD(1,100) <= base_pro then
			local pos_x,pos_y
			local distance = 1
			local angle = casterInfo:GetAngle(tar_x, tar_y)
			while distance > 0 do
				pos_x = tar_x + distance * math.cos(angle)
				pos_y = tar_y + distance * math.sin(angle)
				if mapLib.IsCanRun(mapInfo.ptr, pos_x, pos_y) ~= 0 then
					unitLib.SetPos(target, pos_x, pos_y)
					AddSpellCastinfo(caster, target, 0, HITINFO_BLOWFLY, spell_id,pos_x,pos_y)
					break
				else
					distance = distance - 0.5
				end
			end
		end
	end
	--处理积分
	if caster_zhiye >= SHWJ_PLAYER_TYPE_BUQIANG and caster_zhiye <= SHWJ_PLAYER_TYPE_JUJI then
		mapInfo:AddJiFenCount(player_index,total_damage)
		mapInfo:AddMoneyCount(player_index,total_damage)
	--处理感染 
	elseif caster_zhiye >= SHWJ_PLAYER_TYPE_JIANGSHI and caster_zhiye <= SHWJ_PLAYER_TYPE_CHAOJIJIANGSHI_MUTI then
		local target_index = mapInfo:GetPlayerIndex(targetInfo:GetPlayerGuid())	
		local keji_lv = mapInfo:GetKeJiLv(target_index,SHWJ_KEJI_TYPE_MIANYI)
		local mianyi = 0
		if keji_lv > 0 then
			local level_index = tb_shwj_science[SHWJ_KEJI_TYPE_MIANYI].level_id[keji_lv]
			local keji_config = tb_shwj_science_uplevel[level_index]
			mianyi = keji_config.value[1]
		end
		--基础30%概率感染玩家
		local base_pro = 30
		base_pro = base_pro * (1 - mianyi/100)
		if randIntD(1,100) <= base_pro then
			unitLib.KillUnit(caster, target)
		end
	end
end

--割喉前的判断
function DoHandleGeHou(caster, target, spell_id)
	--没有选中目标
	if target == nil then
		return false
	end
	
	local casterInfo = UnitInfo:new{ptr = caster}
	local targetInfo = UnitInfo:new{ptr = target}
	local caster_guid = casterInfo:GetPlayerGuid()
	--目标已经死了
	if not targetInfo:IsAlive() then 
		return false
	end
	--对玩家和boss无效
	if GetUnitTypeID(target) ~= TYPEID_UNIT or targetInfo:GetUnitFlags(UNIT_FIELD_FLAGS_IS_BOSS_CREATURE) then
		--outDebug("gehou:target is not uint")
		return false
	end
	
	--冷却判断
	if gehou_spell_time[caster_guid] and getMsTime() < gehou_spell_time[caster_guid] then
		return false
	end
	
	local dst_x,dst_y = unitLib.GetPos(target)
	
	--概率判断
	local bili_hp = tb_game_set[121].value[1]/100
	local pro = tb_game_set[121].value[2]
	local cur_hp = targetInfo:GetHealth()
	local max_hp = targetInfo:GetMaxHealth()
	if cur_hp/max_hp <= bili_hp and randIntD(1,100) <= pro then
		spellCastScript(caster, targetInfo:GetGuid(), dst_x, dst_y, SPELL_ID_GEHOU, 1, "")
		return true
	end
	return false
end
--割喉
function handle_cast_monomer_gehou(caster, target, spell_id,spell_lv,dst_x,dst_y)
	local casterInfo = UnitInfo:new{ptr = caster}
	local targetInfo = UnitInfo:new{ptr = target}
	local caster_guid = casterInfo:GetPlayerGuid()
	--设置生存状态
	targetInfo:SetDeathState(DEATH_STATE_GEHOU)
	--设置CD
	gehou_spell_time[caster_guid] = getMsTime() + tb_skill_base[spell_id].singleCD
	--人物位置变化
	local map_ptr = unitLib.GetMap(caster)
	if not map_ptr then return end
	local pos_x,pos_y = dst_x,dst_y
	local distance = 2
	local angle = unitLib.GetOrientation(target)
	while distance > 0 do
		pos_x = dst_x + distance * math.cos(angle)
		pos_y = dst_y + distance * math.sin(angle)
		if mapLib.IsCanRun(map_ptr, pos_x, pos_y) ~= 0 then
			break
		else
			distance = distance - 0.5
		end
	end
	unitLib.SetPos(caster, pos_x, pos_y)
	--unitLib.SetOrientation(caster,angle + math.pi)
	casterInfo:CallCastSpellStart(casterInfo:GetIntGuid(),targetInfo:GetIntGuid(),spell_id,{pos_x,pos_y},true)
	--伤害
	local total_damage = targetInfo:GetHealth()
	AddSpellCastinfo(caster, target, total_damage, HITINFO_NORMALSWING, spell_id, dst_x, dst_y)
end



--真实击退
function DoTrueJiTui(caster,target,spell_id,tar_x,tar_y)
	if GetUnitTypeID(caster) ~= TYPEID_PLAYER --施法者必须是玩家
		or GetUnitTypeID(target) == TYPEID_PLAYER
		or spell_id == SPELL_ID_YUNFEIYUHUANG_2 then
		return
	end
	--只能是普通怪
	local targetInfo = UnitInfo:new{ptr = target}
	local creature_entry = targetInfo:GetEntry()
	if tb_creature_template[creature_entry].monster_type ~= 0 then
		return
	end
	local map_ptr = unitLib.GetMap(caster)
	if map_ptr ~= nil then
		local casterInfo = UnitInfo:new{ptr = caster}
		local distance = casterInfo:GetDistance(tar_x, tar_y)
		if distance < 4 then
			local angle = casterInfo:GetAngle(tar_x, tar_y)
			local jitui_distance = 4
			local pos_x,pos_y
			while(jitui_distance > 0)do
				pos_x = tar_x + jitui_distance * math.cos(angle)
				pos_y = tar_y + jitui_distance * math.sin(angle)
				if mapLib.IsCanRun(map_ptr, pos_x, pos_y) ~= 0 then
					unitLib.SetPos(target, pos_x, pos_y)
					SpelladdBuff(target, BUFF_DINGSHEN, caster, 1, 1)
					AddSpellCastinfo(caster, target, 0, HITINFO_BLOWFLY, spell_id, pos_x, pos_y)
					break
				else
					jitui_distance = jitui_distance - 0.5
				end
			end
		end
	end
end

--月华乱舞定时器
function handle_cast_add_unit_effect_xialv_yhlw(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	local creatureInfo = UnitInfo:new{ptr = caster}
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, 300, 1, "")
end

--剑鞘技能定时器
function handle_cast_add_unit_effect_jianqiao(caster, target, spell_id, spell_lv,dst_x,dst_y, allTargets,unit, data)
	local creatureInfo = UnitInfo:new{ptr = caster}
	creatureInfo:CallCastSpellStart(creatureInfo:GetIntGuid(),0,spell_id,{dst_x,dst_y},true)
	unitLib.AddSpellTrigger(caster, "", dst_x, dst_y, spell_id, spell_lv, 300, 1, "")
end

