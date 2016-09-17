----------------------------------------------------------------------------------------------------------------------------------------------
--Unit封装
UnitInfo = class('UnitInfo', BinLogObject)

--让unitInfo暂时拥有发包功能,下一步将转移到playerContext
local Protocols = require('share.protocols')
Protocols:extend(UnitInfo)

--TODO:在unitInfo和playerContext分开未实现时，先这么处理
-- local ScenedContext = require 'scened.context.scened_context'
-- ScenedContext:extend(UnitInfo)

function UnitInfo:ctor( )
	if(GetUnitTypeID(self.ptr) == TYPEID_PLAYER)then
		self.ptr_player_data = playerLib.GetSession(self.ptr)
	end
end

--获得int guid
function UnitInfo:GetIntGuid(  )
	return unitLib.GetIntGuid(self.ptr)
end

--最重要的操作结果
function UnitInfo:CallOptResult( typed, reason, data )
	if GetUnitTypeID(self.ptr) ~= TYPEID_PLAYER then 
		outFmtError("UnitInfo:CallOptResult not player cant send packet")
		return
	end
	--碰上字符串数组自动拼接	
	if type(data) == 'table' then
		data = string.join(',', data)
	else
		data = tostring(data) or ''
	end
	self:call_operation_failed(typed, reason, data)
end

--发送技能开始给客户端
function UnitInfo:CallCastSpellStart( caster_guid, target_guid, spellid, data, isbrodcast )
	if GetUnitTypeID(self.ptr) ~= TYPEID_PLAYER 
		and not self:GetUnitFlags(UNIT_FIELD_FLAGS_IS_ROBOT) 
		and not self:GetUnitFlags(UNIT_FIELD_FLAGS_IS_BOSS_CREATURE)
		and not self:GetUnitFlags(UNIT_FIELD_FLAGS_IS_XIALV) then 
		outFmtError("UnitInfo:CallCastSpellStart not player cant send packet")
		return
	end
	--碰上字符串数组自动拼接	
	if type(data) == 'table' then
		data = string.join(',', data)
	else
		data = tostring(data) or ''
	end

	local pkt = Protocols.pack_cast_spell_start(caster_guid, target_guid, spellid, data)
	if isbrodcast then
		app:Broadcast(self, pkt)
	else
		self:SendPacket(pkt)
	end
	pkt:delete()
end


function UnitInfo:CheckPlayer(name)
	if(self:GetTypeID() ~= TYPEID_PLAYER)then
		outDebug(string.format("func CheckPlayer  not player call player function !!! guid = %s name = %s   %s", self:GetGuid(), self:GetName(), name))
		bengdiaoba()
	end
end

function UnitInfo:GetPlayerBit(index, offset)
	--self:CheckPlayer(string.format("GetPlayerBit index = %d offset = %d ", index, offset))
	return binLogLib.GetBit(self.ptr_player_data, index, offset)
end

function UnitInfo:GetPlayerByte(index, offset)
	--self:CheckPlayer(string.format("GetPlayerByte-- index = %d offset = %d", index, offset))
	return binLogLib.GetByte(self.ptr_player_data, index, offset)
end

function UnitInfo:GetPlayerUInt16(index, offset)
	self:CheckPlayer(string.format("GetPlayerUInt16-- index = %d offset = %d", index, offset))
	return binLogLib.GetUInt16(self.ptr_player_data, index, offset)
end

function UnitInfo:GetPlayerUInt32(index)
	self:CheckPlayer(string.format("GetPlayerUInt32-- index = %d", index))
	return binLogLib.GetUInt32(self.ptr_player_data, index)
end

function UnitInfo:SetPlayerBit(index, offset)
	--self:CheckPlayer(string.format("SetPlayerBit index = %d offset = %d", index, offset))
	binLogLib.SetBit(self.ptr_player_data, index, offset)
end

function UnitInfo:UnSetPlayerBit(index, offset)
	--self:CheckPlayer(string.format("UnSetPlayerBit-- index =%d offset = %d ", index, offset))
	binLogLib.UnSetBit(self.ptr_player_data, index, offset)
end

function UnitInfo:SetPlayerByte(index, offset, value)
	--self:CheckPlayer(string.format("SetPlayerByte-- index = %d offset = %d", index, offset))
	binLogLib.SetByte(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SetPlayerUInt16(index, offset, value)
	--self:CheckPlayer(string.format("SetPlayerUInt16-- index = %d offset = %d", index, offset))
	binLogLib.SetUInt16(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SubPlayerUInt16(index, offset, value)
	--self:CheckPlayer(string.format("SubPlayerUInt16-- index = %d offset = %d", index, offset))
	binLogLib.SubUInt16(self.ptr_player_data, index, offset, value)
end

function UnitInfo:AddPlayerUInt16(index, offset, value)
	--self:CheckPlayer(string.format("SubPlayerUInt16-- index = %d offset = %d", index, offset))
	binLogLib.AddUInt16(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SetPlayerUInt32(index, value)
	--self:CheckPlayer(string.format("SetPlayerUInt32-- index = %d ", index))
	binLogLib.SetUInt32(self.ptr_player_data, index, value)
end

function UnitInfo:AddPlayerUInt32(index, value)
	--self:CheckPlayer(string.format("AddPlayerUInt32-- index = %d", index))
	binLogLib.AddUInt32(self.ptr_player_data, index, value)
end

function UnitInfo:SubPlayerUInt32(index, value)
	--self:CheckPlayer(string.format("SubPlayerUInt32-- index = %d", index))
	binLogLib.SubUInt32(self.ptr_player_data, index, value)
end

function UnitInfo:GetPlayerDouble(index)
	--self:CheckPlayer(string.format("GetPlayerDouble-- index = %d", index))
	return binLogLib.GetDouble(self.ptr_player_data, index)
end

function UnitInfo:SetPlayerDouble(index, value)
	--self:CheckPlayer(string.format("SetPlayerDouble-- index = %d", index))
	binLogLib.SetDouble(self.ptr_player_data, index, value)
end

function UnitInfo:AddPlayerDouble(index, value)
	--self:CheckPlayer(string.format("AddPlayerDouble-- index = %d", index))
	binLogLib.AddDouble(self.ptr_player_data, index, value)
end

function UnitInfo:SubPlayerDouble(index, value)
	--self:CheckPlayer(string.format("SubPlayerDouble-- index = %d", index))
	binLogLib.SubDouble(self.ptr_player_data, index, value)
end

function UnitInfo:AddPlayerByte(index, offset, value)
	--self:CheckPlayer(string.format("AddPlayerByte-- index = % d offset = %d", index, offset))
	binLogLib.AddByte(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SetPlayerStr(index, value)
	--self:CheckPlayer(string.format("SetPlayerStr-- index = %d", index))
	binLogLib.SetStr(self.ptr_player_data, index,value)
end

function UnitInfo:SetPlayerFloat(index, value)
	--self:CheckPlayer(string.format("SetPlayerFloat-- index = %d", index))
	binLogLib.SetFloat(self.ptr_player_data, index, value)
end

function UnitInfo:GetPlayerFloat(index)
	--self:CheckPlayer(string.format("GetPlayerFloat-- index = %d", index))
	return binLogLib.GetFloat(self.ptr_player_data, index)
end

function UnitInfo:GetPlayerStr(index)
	--self:CheckPlayer(string.format("GetPlayerStr-- index = %d", index))
	return binLogLib.GetStr(self.ptr_player_data, index)
end

--获得主玩家guid
function UnitInfo:GetPlayerGuid()
	--self:CheckPlayer("GetPlayerGuid")
	return binLogLib.GetStr(self.ptr_player_data, BINLOG_STRING_FIELD_GUID)
end

--把某玩家标志位变成1
function UnitInfo:SetFlags(index)
	self:SetPlayerBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

--把某玩家标志位变成0
function UnitInfo:UnSetFlags(index)
	self:UnSetPlayerBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

--获取某玩家标志位
function UnitInfo:GetFlags(index)
	return self:GetPlayerBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

--获得在线时长
function UnitInfo:GetOnlineTime()
	return self:GetPlayerUInt32(PLAYER_FIELD_ONLINE_TIME)
end

--获取类型
function UnitInfo:GetTypeID()
	return self:GetByte(UNIT_FIELD_BYTE_0, 0)
end

--获取模板
function UnitInfo:GetEntry()
	return self:GetUInt16(UNIT_FIELD_UINT16_0, 0)
end

--获取等级
function UnitInfo:GetLevel()
	return self:GetUInt16(UNIT_FIELD_UINT16_0, 1)
end

--设置等级
function UnitInfo:SetLevel(val)
	self:SetUInt16(UNIT_FIELD_UINT16_0, 1, val)
end

--获取头衔等级
function UnitInfo:GetTouXianLv()
	return self:GetByte(UNIT_FIELD_BYTE_0, 3)
end

--生物部分
function UnitInfo:SetBaseAttrs(info, bRecal)
	local tBaseKey = {
		-- [EQUIP_ATTR_MIN_DAMAGE	] = {UNIT_FIELD_MIN_DAMAGE},			--最小攻击
		-- [EQUIP_ATTR_MAX_DAMAGE	] = {UNIT_FIELD_MAX_DAMAGE},			--最大攻击
		-- [EQUIP_ATTR_DEF			] = {UNIT_FIELD_RESISTANCES},			--防御
		[EQUIP_ATTR_HIT			] = {UNIT_FIELD_COMBAT_HIT},			--命中	
		-- [EQUIP_ATTR_EVA			] = {UNIT_FIELD_COMBAT_EVA},			--闪避	
		-- [EQUIP_ATTR_CRIT		] = {UNIT_FIELD_COMBAT_CRIT},   		--暴击
		-- [EQUIP_ATTR_CRIT_DEF	] = {UNIT_FIELD_COMBAT_CRIT_DEF},   	--抗暴
		-- [EQUIP_ATTR_EVA_RATE	] = {UNIT_FIELD_COMBAT_RATE_EVA},		--闪避率(万分比)
		-- [EQUIP_ATTR_CRIT_RATE	] = {UNIT_FIELD_COMBAT_RATE_CRIT},		--暴击率(万分比)
	}
	if bRecal then
		tBaseKey[EQUIP_ATTR_HP] = {UNIT_FIELD_MAXHEALTH}		 --血
	else
		tBaseKey[EQUIP_ATTR_HP] = {UNIT_FIELD_MAXHEALTH, UNIT_FIELD_HEALTH}		 --血
	end
	
	local movespd = 130
	for i = 1, #info, 2 do
		local attrtype = info[i]
		local attrval = info[i+1]
		if attrtype == EQUIP_ATTR_MOVE_SPD and attrval > 0 then
			movespd = attrval
		end
		
		if tBaseKey[attrtype] then
			for _,k in pairs(tBaseKey[attrtype]) do					
				if(self:GetUInt32(k) ~= attrval)then
					self:SetUInt32(k, attrval)
				end
			end
		end			
	end
	--outFmtDebug('---> init creature attr %d %d %d', self:GetEntry(), self:GetUInt32(UNIT_FIELD_MAXHEALTH), self:GetUInt32(UNIT_FIELD_HEALTH))
	--设置移动速度
	if self:GetByte(UNIT_FIELD_BYTE_0, 2) ~= movespd then
		self:SetByte(UNIT_FIELD_BYTE_0, 2, movespd)
	end
end

--获取最大生命
function UnitInfo:GetMaxHealth()
	return self:GetUInt32(UNIT_FIELD_MAXHEALTH)
end	

--设置最大生命
function UnitInfo:SetMaxHealth(val)
	self:SetUInt32(UNIT_FIELD_MAXHEALTH,val)
end

function UnitInfo:AddMaxHealth(val)
	self:SetMaxHealth(self:GetMaxHealth() + val)
end

--获取最大能量（包括：体力）
function UnitInfo:GetMaxPower(ntype) -- type: POWER_ENERGY 
	if(ntype >= MAX_POWERS)then
		return 0
	end
	if ntype == POWER_ENERGY then
		return self:GetUInt32(UNIT_FIELD_MAXPOWERS_ENERGY)
	end
	return 0
end

--设置最大能量（包括：体力）type: POWER_ENERGY 
function UnitInfo:SetMaxPower(ntype, val)
	if(ntype >= MAX_POWERS)then
		return 
	end
	if ntype == POWER_ENERGY then
		self:SetUInt32(UNIT_FIELD_MAXPOWERS_ENERGY, val)
	end
end

--获取最小攻击
function UnitInfo:GetMinDamage()
	return self:GetUInt32(UNIT_FIELD_MIN_DAMAGE)
end

--设置最小攻击
function UnitInfo:SetMinDamage(val)
	self:SetUInt32(UNIT_FIELD_MIN_DAMAGE, val)
end

--获取最大攻击
function UnitInfo:GetMaxDamage()
	return self:GetUInt32(UNIT_FIELD_MAX_DAMAGE)
end

--设置最大攻击
function UnitInfo:SetMaxDamage(val)
	self:SetUInt32(UNIT_FIELD_MAX_DAMAGE, val)
end

--获取暴击率、闪避率
function UnitInfo:GetCombatRate(ntype)	-- type:COMBAT_RATE_CRIT  COMBAT_RATE_EVA
	if(ntype >= MAX_COMBAT_RATE)then
		return 0
	end
	if ntype == COMBAT_RATE_CRIT then
		return self:GetUInt32(UNIT_FIELD_COMBAT_RATE_CRIT)
	elseif ntype == COMBAT_RATE_EVA then
		return self:GetUInt32(UNIT_FIELD_COMBAT_RATE_EVA)		
	end
	return 0
end

--设置暴击率、闪避率
function UnitInfo:SetCombatRate(ntype, val)	-- type:COMBAT_RATE_CRIT  COMBAT_RATE_EVA
	if(ntype >= MAX_COMBAT_RATE)then
		return
	end
	if ntype == COMBAT_RATE_CRIT then
		self:SetUInt32(UNIT_FIELD_COMBAT_RATE_CRIT, val)
	elseif ntype == COMBAT_RATE_EVA then
		self:SetUInt32(UNIT_FIELD_COMBAT_RATE_EVA, val)		
	end
end

--获取防御
function UnitInfo:GetArmor()
	return self:GetUInt32(UNIT_FIELD_RESISTANCES)
end

--设置防御
function UnitInfo:SetArmor(val)
	self:SetUInt32(UNIT_FIELD_RESISTANCES, val)
end

--获取伤害加深属性值
function UnitInfo:GetAddDamage()
	return self:GetUInt32(UINT_FIELD_ADD_DAMAGE)
end

--设置伤害加深属性值
function UnitInfo:SetAddDamage(val)
	self:SetUInt32(UINT_FIELD_ADD_DAMAGE, val)
end

--获取伤害减免属性值
function UnitInfo:GetSubDamage()
	return self:GetUInt32(UINT_FIELD_SUB_DAMAGE)
end

--设置伤害减免属性值
function UnitInfo:SetSubDamage(val)
	self:SetUInt32(UINT_FIELD_SUB_DAMAGE, val)
end


--获取当前血量
function UnitInfo:GetHealth()
	return self:GetUInt32(UNIT_FIELD_HEALTH)
end

--设置当前血量
function UnitInfo:SetHealth(val)
	unitLib.SetHealth(self.ptr, val)
end

--增加当前血量
function UnitInfo:AddHealth(val)
	local current_hp = self:GetHealth()
	current_hp = current_hp + val
	self:SetHealth(current_hp)
end

--修改生物生命值
function UnitInfo:ModifyHealth(dval)
	unitLib.ModifyHealth(self.ptr, dval)
end

--获得能量（包括：体力）type: POWER_ENERGY 
function UnitInfo:GetPower(ntype)
	if(ntype >= MAX_POWERS)then
		return 0
	end
	if ntype == POWER_ENERGY then
		return self:GetUInt32(UNIT_FIELD_POWERS_ENERGY)
	end
	return 0
end

--设置能量（包括：体力）type:POWER_ENERGY
function UnitInfo:SetPower(ntype, val)
	if(ntype >= MAX_POWERS)then
		return
	end
	local maxPower = self:GetMaxPower(ntype)
	if(val > maxPower)then
		val = maxPower
	end
	if ntype == POWER_ENERGY then
		self:SetUInt32(UNIT_FIELD_POWERS_ENERGY, val)
	end
end

--修改能量（包括：体力）type: POWER_ENERGY
function UnitInfo:ModifyPower(ntype, dval)
	if(dval == 0 or ntype >= MAX_POWERS)then
		return
	end
	local curMp = self:GetPower(ntype)
	local val = curMp + dval
	local maxMp = self:GetMaxPower(ntype)
	if(val > maxMp)then
		val = maxMp
	end
	if(val < 0)then
		val = 0
	end
	self:SetPower(ntype, val)
end

--获得闪避
function UnitInfo:GetEva()
	return self:GetUInt32(UNIT_FIELD_COMBAT_EVA)
end
--设置闪避
function UnitInfo:SetEva(val)
	self:SetUInt32(UNIT_FIELD_COMBAT_EVA,val)
end

--获得暴击
function UnitInfo:GetCrit()
	return self:GetUInt32(UNIT_FIELD_COMBAT_CRIT)
end
--设置暴击
function UnitInfo:SetCrit(val)
	self:SetUInt32(UNIT_FIELD_COMBAT_CRIT,val)
end

--获得抗暴
function UnitInfo:GetCritDef()
	return self:GetUInt32(UNIT_FIELD_COMBAT_CRIT_DEF)
end	
--设置抗暴
function UnitInfo:SetCritDef(val)
	self:SetUInt32(UNIT_FIELD_COMBAT_CRIT_DEF,val)
end	

--获得命中
function UnitInfo:GetHit()
	return self:GetUInt32(UNIT_FIELD_COMBAT_HIT)
end

--设置命中
function UnitInfo:SetHit(val)
	self:SetUInt32(UNIT_FIELD_COMBAT_HIT,val)
end

--获得闪避率
function UnitInfo:GetEvaRate()
	return self:GetUInt32(UNIT_FIELD_COMBAT_RATE_EVA)
end

--获得获得暴击率
function UnitInfo:GetCritRate()
	return self:GetUInt32(UNIT_FIELD_COMBAT_RATE_CRIT)
end

--设置阵营
function UnitInfo:SetFaction(val)
	self:SetByte(UNIT_FIELD_BYTE_1, 1, val)
end

--获得阵营
function UnitInfo:GetFaction()
	return self:GetByte(UNIT_FIELD_BYTE_1, 1)
end

--获取地图ID
function UnitInfo:GetMapID()
	return self:GetUInt16(UNIT_FIELD_UINT16_1, 0)
end

--设置地图ID
function UnitInfo:SetMapID(val)
	self:SetUInt16(UNIT_FIELD_UINT16_1, 0, val)
end

--获得通用guid
function UnitInfo:GetGeneralGuid()
	return self:GetPlayerStr(PLAYER_STRING_FIELD_TELEPORT_GUID)
end

--获得跨服编号
function UnitInfo:GetKuafuNumber()
	return self:GetPlayerUInt16(PLAYER_INT_FIELD_KUAFU_NUMBER, 0)
end

--判断是否还活着
function UnitInfo:IsAlive()
	return self:GetByte(UNIT_FIELD_BYTE_0, 1) == DEATH_STATE_ALIVE
end

--设置生存状态
function UnitInfo:SetDeathState(val)
	self:SetByte(UNIT_FIELD_BYTE_0, 1,val)
end

--获取生命源泉
function UnitInfo:GetAutoHp()
	local hp = self:GetPlayerDouble(PLAYER_FIELD_AUTO_HP)
	return hp
end	

--设置生命源泉
function UnitInfo:SetAutoHp(val)
	self:SetPlayerDouble(PLAYER_FIELD_AUTO_HP, val)
end	

--获取内力源泉
function UnitInfo:GetAutoMp()
	local mp = self:GetPlayerDouble(PLAYER_FIELD_AUTO_MP)
	return mp
end	

--设置内力源泉
function UnitInfo:SetAutoMp(val)
	self:SetPlayerDouble(PLAYER_FIELD_AUTO_MP, val)
end

--获取性别 1女 0男
function UnitInfo:GetGender()
	return self:GetByte(UNIT_FIELD_BYTE_1, 0)
end

--获取性别 1女 0男
function UnitInfo:SetGender(val)
	self:SetByte(UNIT_FIELD_BYTE_1, 0, val)
end

--获取头像
function UnitInfo:GetHead()
	return self:GetByte(UNIT_FIELD_BYTE_3, 0)
end

--获取头像
function UnitInfo:SetHead(val)
	self:SetByte(UNIT_FIELD_BYTE_3, 0, val)
end

--获取种族
function UnitInfo:GetRace()
	return self:GetByte(UNIT_FIELD_BYTE_1, 2)
end

--获取种族
function UnitInfo:SetRace(val)
	self:SetByte(UNIT_FIELD_BYTE_1, 2, val)
end

--获取职业
function UnitInfo:GetProfession()
	return self:GetByte(UNIT_FIELD_BYTE_1, 3)
end

--获取职业
function UnitInfo:SetProfession(val)
	self:SetByte(UNIT_FIELD_BYTE_1, 3, val)
end

--设置生物变身（机器人的皮肤）
function UnitInfo:SetCreatureSkin(val)
	self:SetByte(UNIT_FIELD_BYTE_4, 2, val)
end

--获取生物变身（机器人的皮肤）
function UnitInfo:GetCreatureSkin()
	return self:GetByte(UNIT_FIELD_BYTE_4, 2)
end

--设置战斗力
function UnitInfo:SetForce(val)
	self:SetUInt32(UNIT_FIELD_FORCE, val)
end

--获取战斗力
function UnitInfo:GetForce()
	return self:GetUInt32(UNIT_FIELD_FORCE)
end

--设置npc标志
function UnitInfo:SetNpcFlags(val)
	self:SetUInt32(UNIT_FIELD_NPC_FLAG, val)
end

--获得npc标志
function UnitInfo:GetNpcFlags()
	return self:GetUInt32(UNIT_FIELD_NPC_FLAG, val)
end

--获得pos槽中的buff id 
function UnitInfo:GetBuffByPos(pos)
	return self:GetUInt16(UNIT_FIELD_BUFF + math.floor(pos/2), math.fmod(pos,2))
end

--设置pos槽中的buff id 
function UnitInfo:SetBuffByPos(pos, val)
	self:SetUInt16(UNIT_FIELD_BUFF + math.floor(pos/2), math.fmod(pos,2), val)
end

--获得pos槽中的buff duration
function UnitInfo:GetBuffDuration(pos)
	return self:GetUInt16(UNIT_FIELD_BUFF_TM + math.floor(pos/2), math.fmod(pos,2))
end

--设置pos槽中的buff duration 
function UnitInfo:SetBuffDuration(pos, val)
	self:SetUInt16(UNIT_FIELD_BUFF_TM + math.floor(pos/2), math.fmod(pos,2), val)
end

--获取正在释放的技能ID
function UnitInfo:GetCurSpellId()
	return self:GetUInt32(UINT_FIELD_BOOS_CUR_SPELLID)
end

--设置正在释放的技能ID
function UnitInfo:SetCurSpellId(val)
	self:SetUInt32(UINT_FIELD_BOOS_CUR_SPELLID, val)
end

--获取释放的时间点
function UnitInfo:GetCurSpellTime()
	return self:GetUInt32(UINT_FIELD_BOOS_CUR_SPELL_TIME)
end

--设置释放的时间点
function UnitInfo:SetCurSpellTime(val)
	self:SetUInt32(UINT_FIELD_BOOS_CUR_SPELL_TIME, val)
end

--清理BOSS正在释放的技能
function UnitInfo:ClearCurSpell(is_ok)
	--被打断
	if not is_ok then
		if unitLib.HasBuff(self.ptr, BUFF_YINCHANG) then
			SpelladdBuff(self.ptr, BUFF_SHIHUA, self.ptr, 1, tb_buff_template[BUFF_SHIHUA].duration)
			SpelladdBuff(self.ptr, BUFF_YISHANG, self.ptr, 1, tb_buff_template[BUFF_YISHANG].duration)
			unitLib.RemoveBuff(self.ptr, BUFF_YINCHANG)
			ClearBuffFlags(self.ptr, BUFF_YINCHANG)
		end
	end
	self:SetCurSpellId(0)
	self:SetCurSpellTime(0)
end

--获得到坐标x,y的直线距离
function UnitInfo:GetDistance(x, y)
	local cas_x, cas_y = unitLib.GetPos(self.ptr)
	local dx = x - cas_x
	local dy = y - cas_y
	return math.sqrt(dy*dy + dx*dx)	
end

--判断是否能施法 返回值为true则可以施法
function UnitInfo:IsCanCast(spell_id)
	--local cant_casts = config.cant_cast		--取出配置
	--for k, buff in pairs(cant_casts) do
	--	if unitLib.HasBuff(self.ptr, buff) then
	--		return false				
	--	end
	--end
	if self:GetUnitFlags(UNIT_FIELD_FLAGS_CANT_CAST) then
		return false
	end
	return true
end

function UnitInfo:GetAngle(x, y)
	local cas_x, cas_y = unitLib.GetPos(self.ptr)
	local dx = x - cas_x
	local dy = y - cas_y
	
	local ang = math.atan2(dy, dx)
	if(ang < 0)then
		ang = ang + 2 * math.pi
	end
	return ang
end
	
--玩家部分
--获得付费等级
function UnitInfo:GetPayLevel()
	return self:GetByte(UNIT_FIELD_BYTE_2, 1)
end

--获取免费复活次数
function UnitInfo:GetFreeReliveCount()
	return self:GetByte(UNIT_FIELD_BYTE_2, 2)
end

--设置免费复活次数
function UnitInfo:SetFreeReliveCount(val)
	self:SetByte(UNIT_FIELD_BYTE_2, 2, val)
end

--获取玩家身上的money
function UnitInfo:GetMoney(type)
	if(type < MAX_MONEY_TYPE)then
		return self:GetPlayerDouble(PLAYER_EXPAND_INT_MONEY + type*2)
	end
	return 0
end

-- --扣金钱
-- function UnitInfo:SubMoney(money_type, oper_type, val, p1, p2, p3, p4, p5)
-- 	if(val <= 0)then
-- 		return false
-- 	end
-- 	if(p1 == nil)then
-- 		p1 = ''
-- 	end
-- 	if(p2 == nil)then
-- 		p2 = 0
-- 	end
-- 	if(p3 == nil)then
-- 		p3 = 0
-- 	end
-- 	if(p4 == nil)then
-- 		p4 = 0
-- 	end
-- 	if(p5 == nil)then
-- 		p5 = 0
-- 	end
-- 	return playerLib.SendSubMoney(self.ptr, money_type, oper_type, val, p1, p2, p3, p4, p5)
-- end

--金钱增加
function UnitInfo:AddMoney(money_type, oper_type, val, p1, p2, p3, p4, p5)
	if(val <= 0)then
		return false
	end
	if(p1 == nil)then
		p1 = ''
	end
	if(p2 == nil)then
		p2 = 0
	end
	if(p3 == nil)then
		p3 = 0
	end
	if(p4 == nil)then
		p4 = 0
	end
	if(p5 == nil)then
		p5 = 0
	end
	return playerLib.SendAddMoney(self.ptr, money_type, oper_type, val, p1, p2, p3, p4, p5)
end

--通过物品模板获取金钱数量
function UnitInfo:GetMoneyForEntry(entry)
	if(entry == Item_Loot_Silver)then
		return self:GetMoney(MONEY_TYPE_SILVER)
	elseif(entry == Item_Loot_Bind_Gold)then
		return self:GetMoney(MONEY_TYPE_BIND_GOLD)
	elseif(entry == Item_Loot_Gold)then
		return self:GetMoney(MONEY_TYPE_GOLD_INGOT)	
	end
end

-- --通过物品模板金钱减少
-- function UnitInfo:SubMoneyForEntry(entry,log_type, val)
-- 	local money_type
-- 	if(entry == Item_Loot_Silver)then
-- 		money_type = MONEY_TYPE_SILVER
-- 	elseif(entry == Item_Loot_Bind_Gold)then
-- 		money_type = MONEY_TYPE_BIND_GOLD
-- 	elseif(entry == Item_Loot_Gold)then
-- 		money_type = MONEY_TYPE_GOLD_INGOT
-- 	end
-- 	return self:SubMoney(money_type,log_type,val)
-- end

--获取元宝和绑元数量
function UnitInfo:GetGoldMoney()
	return self:GetMoney(MONEY_TYPE_GOLD_INGOT) + self:GetMoney(MONEY_TYPE_BIND_GOLD)
end

--获取帮派id
function UnitInfo:GetFactionId()
	return self:GetStr(UNIT_STRING_FIELD_FACTION)
end
--获取队伍id
function UnitInfo:GetGroupId()
	return self:GetStr(UNIT_STRING_FIELD_GROUP)
end

--获取PK值
function UnitInfo:GetPKValue()
	return self:GetPlayerUInt32(PLAYER_APPD_INT_FIELD_PK_VALUE)
end

--获得精灵下标的flag标志
function UnitInfo:GetUnitFlags(index)
	return self:GetBit(UNIT_FIELD_FLAGS, index)
end
--设置精灵下标的flag标志
function UnitInfo:SetUnitFlags(index)
	self:SetBit(UNIT_FIELD_FLAGS, index)
end
--设置精灵下标的flag标志
function UnitInfo:UnSetUnitFlags(index)
	self:UnSetBit(UNIT_FIELD_FLAGS, index)
end

--获得玩家主下标的flag标志
function UnitInfo:GetPlayerFlags(index)
	return self:GetPlayerBit(PLAYER_FIELD_FLAGS, index)
end
--设置玩家主下标的flag标志
function UnitInfo:SetPlayerFlags(index)
	self:SetPlayerBit(PLAYER_FIELD_FLAGS, index)
end
--设置玩家主下标的flag标志
function UnitInfo:UnSetPlayerFlags(index)
	self:UnSetPlayerBit(PLAYER_FIELD_FLAGS, index)
end

--获取攻击模式
function UnitInfo:GetAttackMode()
	return self:GetByte(UNIT_FIELD_BYTE_3, 3)
end

--设置攻击模式
function UnitInfo:SetAttackMode(val)
	if self:GetAttackMode() == val then
		return
	end
	self:SetByte(UNIT_FIELD_BYTE_3, 3, val)
	unitLib.InvalidFriendlyCache(self.ptr)
end

--获取当前地图进度
function UnitInfo:GetMapStatus()
	return self:GetPlayerUInt32(PLAYER_EXPAND_INT_MAP_STATUS)
end

--设置当前地图进度
function UnitInfo:SetMapStatus(status)
	if(self:GetMapStatus() ~= status)then
		self:SetPlayerUInt32(PLAYER_EXPAND_INT_MAP_STATUS,status)
	end
end

--获得pvp状态
function UnitInfo:GetPVPState()
	return self:GetPlayerBit(PLAYER_FIELD_FLAGS, UNIT_FIELD_FLAGS_IS_PVP)
end

--获得pve状态
function UnitInfo:GetPVEState()
	return self:GetPlayerBit(PLAYER_FIELD_FLAGS, UNIT_FIELD_FLAGS_IS_PVE)
end

--获得备战状态
function UnitInfo:GetCastState(  )
	return self:GetPlayerBit(PLAYER_FIELD_FLAGS, UNIT_FIELD_FLAGS_IS_CAST)
end

--取消备战标识
function UnitInfo:UnSetCastState( )
	if self:GetCastState() then
		self:UnSetPlayerBit(PLAYER_FIELD_FLAGS, UNIT_FIELD_FLAGS_IS_CAST)
	end
end

--获取是否挂机
function UnitInfo:GetHungUp()
	return self:GetPlayerBit(PLAYER_SCENED_INT_FLAGS, PLAYER_SCENED_FLAS_HUNG_UP)
end

--set是否挂机
function UnitInfo:SetHungUp()
	self:SetPlayerBit(PLAYER_SCENED_INT_FLAGS, PLAYER_SCENED_FLAS_HUNG_UP)
end

--set是否挂机
function UnitInfo:UnSetHungUp()
	self:UnSetPlayerBit(PLAYER_SCENED_INT_FLAGS, PLAYER_SCENED_FLAS_HUNG_UP)
end

--设置开始挂机时间点
function UnitInfo:SetHungUpStartTime(val)
	self:SetPlayerUInt32(PLAYER_HT_INT_FIELD_HUNGUP_START_TIME, val)
end

--获取开始挂机时间点
function UnitInfo:GetHungUpStartTime()
	return self:GetPlayerUInt32(PLAYER_HT_INT_FIELD_HUNGUP_START_TIME)
end

--获取玩家退出副本时的x坐标
function UnitInfo:GetExitanceDBPosx()
	return self:GetPlayerFloat(PLAYER_EXPAND_INT_DB_POS_X)
end

--设置玩家退出副本时的x坐标
function UnitInfo:SetExitanceDBPosx(val)
	self:SetPlayerFloat(PLAYER_EXPAND_INT_DB_POS_X, val)
end

--获取玩家退出副本时的y坐标
function UnitInfo:GetExitanceDBPosy()
	return self:GetPlayerFloat(PLAYER_EXPAND_INT_DB_POS_Y)
end

--设置玩家退出副本时的y坐标
function UnitInfo:SetExitanceDBPosy(val)
	self:SetPlayerFloat(PLAYER_EXPAND_INT_DB_POS_Y, val)
end

--获取玩家退出副本时的地图id
function UnitInfo:GetExitanceDBMapid()
	return self:GetPlayerUInt32(PLAYER_EXPAND_INT_DB_MAP)
end

--设置玩家退出副本时的地图id
function UnitInfo:SetExitanceDBMapid(val)
	self:SetPlayerUInt32(PLAYER_EXPAND_INT_DB_MAP, val)
end

--获取防沉迷
function UnitInfo:GetFCMLoginTime()
	return self:GetPlayerUInt32(PLAYER_EXPAND_INT_FCM_LOGIN_TIME)
end

--获得任务完成列表bit
function UnitInfo:GetQuestCompleteListFlag(off)
	local off_index = math.floor(off/32)
	local off_bit = math.fmod(off, 32)
	return self:GetPlayerBit(PLAYER_SCENED_INT_FIELD_QUEST_COMPLETE_LIST + off_index, off_bit)
end

--获得玩家当前经验
function UnitInfo:GetPlayerCurExp()
	return self:GetPlayerDouble(PLAYER_EXPAND_INT_XP)
end

--获得玩家下一级经验
function UnitInfo:GetPlayerNextLevelExp()
	return self:GetPlayerDouble(PLAYER_EXPAND_INT_NEXT_LEVEL_XP)
end

-- 获取玩家基础属性
function UnitInfo:GetPlayerBaseAttr(offset)
	return self:GetPlayerDouble(PLAYER_SCENED_INT_FIELD_BASE_ATTR_START + offset*2)
end

-- 设置玩家基础属性
function UnitInfo:SetPlayerBaseAttr(offset, val)
	self:SetPlayerDouble(PLAYER_SCENED_INT_FIELD_BASE_ATTR_START + offset*2, val)
end

-- 获取玩家固定属性
function UnitInfo:GetPlayerFixedAttr(offset)
	return self:GetPlayerDouble(PLAYER_SCENED_INT_FIELD_FIXED_ATTR_START + offset*2)
end

-- 设置玩家固定属性
function UnitInfo:SetPlayerFixedAttr(offset, val)
	self:SetPlayerDouble(PLAYER_SCENED_INT_FIELD_FIXED_ATTR_START + offset*2, val)
end
	
-- 获取玩家名字（公告的时候用）
function UnitInfo:GetTextName()
	local sName = self:GetName()
	if sName ~= "" then
		local tName = lua_string_split(sName,",")
		sName = tName[#tName]
	end
	return sName
end

-- 是否已经接受任务
function UnitInfo:IsHasAcceptQuest(questid)
	if(self:GetQuestCompleteListFlag(questid) or playerLib.HasQuest(self.ptr,questid))then
		return true
	end
	return false
end

--获取挂机保护时间
function UnitInfo:GetGuaJiBaoHu()
	return self:GetPlayerUInt32(PLAYER_APPD_INT_FIELD_GUAJIBAOHU)
end

--设置挂机保护时间
function UnitInfo:SetGuaJiBaoHu(val)
	if self:GetGuaJiBaoHu() ~= val then
		self:SetPlayerUInt32(PLAYER_APPD_INT_FIELD_GUAJIBAOHU, val)
		if val < os.time() then
			self:UnSetPlayerFlags(UNIT_FIELD_FLAGS_BUFF_DAZUO)
		else
			self:SetPlayerFlags(UNIT_FIELD_FLAGS_BUFF_DAZUO)
		end
	end
end

-- 清除玩家buff对应的flag标识
function UnitInfo:ClearPlayerBuffFlags()
	local flag = false
	local cant_casts = config.cant_cast		--取出配置
	for k, buff in pairs(cant_casts) do
		if unitLib.HasBuff(self.ptr, buff) then
			flag = true		--如果玩家身上还有类似的buff，则暂不清flag
			break
		end
	end
	if(flag and self:GetPlayerFlags(UNIT_FIELD_FLAGS_CANT_CAST) == false)then
		self:SetPlayerFlags(UNIT_FIELD_FLAGS_CANT_CAST)
	elseif(self:GetPlayerFlags(UNIT_FIELD_FLAGS_CANT_CAST))then
		self:UnSetPlayerFlags(UNIT_FIELD_FLAGS_CANT_CAST)
	end
	flag = false
	local cant_moves = config.cant_move		--取出配置
	for k, buff in pairs(cant_moves) do
		if unitLib.HasBuff(self.ptr, buff) then
			flag = true		--如果玩家身上还有类似的buff，则暂不清flag
			break
		end
	end
	if(flag and self:GetPlayerFlags(UNIT_FIELD_FLAGS_CANT_MOVE) == false)then
		self:SetPlayerFlags(UNIT_FIELD_FLAGS_CANT_MOVE)
	elseif(self:GetPlayerFlags(UNIT_FIELD_FLAGS_CANT_MOVE))then
		self:UnSetPlayerFlags(UNIT_FIELD_FLAGS_CANT_MOVE)
	end
end

--添加总挂机时间
function UnitInfo:AddHungUpTime(val)
	self:AddPlayerUInt32(PLAYER_HT_INT_FIELD_ALL_HUNGUP_TIME, val)
end

--添加每日挂机时间
function UnitInfo:AddHungUpDailyTime(val)
	self:AddPlayerUInt32(PLAYER_HT_INT_FIELD_DAILY_HUNGUP_TIME, val)
end

-- 获取使用游戏对象时间
function UnitInfo:GetUseGameObjectTime()
	return self:GetPlayerUInt32(PLAYER_SCENED_INT_FIELD_USE_GAMEOBJECT_TIME)
end

-- 设置使用游戏对象时间
function UnitInfo:SetUseGameObjectTime(val)
	self:SetPlayerUInt32(PLAYER_SCENED_INT_FIELD_USE_GAMEOBJECT_TIME, val)
end

-- 获取使用游戏对象标识
function UnitInfo:GetUseGameObjectFlag()
	return self:GetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT)
end

-- 设置使用游戏对象标识
function UnitInfo:SetUseGameObjectFlag(val)
	self:SetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT)
end

function UnitInfo:UnSetUseGameObjectFlag(val)
	self:UnSetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT)
end

--开始使用游戏对象
function UnitInfo:StartUseGameObject()
	if self:GetUseGameObjectTime() == 0 then
		self:SetUseGameObjectTime(os.time())
	end
	if not self:GetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT) then
		self:SetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT)
	end
end

-- 移除使用游戏对象标识
function UnitInfo:RemoveUseGameObjectFlag()
	if self:GetUseGameObjectTime() ~= 0 then
		self:SetUseGameObjectTime(0)
	end
	if self:GetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT) then
		self:UnSetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT)
	end
end

--获取玩家跳跃CD
function UnitInfo:GetPlayerJumpCd()
	return self:GetPlayerUInt32(PLAYER_SCENED_INT_FIELD_PLAYER_JUMP_CD)
end

--设置玩家跳跃CD
function UnitInfo:SetPlayerJumpCd(val)
	self:SetPlayerUInt32(PLAYER_SCENED_INT_FIELD_PLAYER_JUMP_CD,val)
end

-- 获取玩家技能等级对应skill_base表的索引
function UnitInfo:GetSpellLvIndex(spell_id)
	return tb_skill_base[spell_id].uplevel_id[1] + self:GetSpellLevel(spell_id) - 1
end

-- 获取精灵对象的类型（玩家、精灵）
function GetUnitTypeID(spirit)
	return binLogLib.GetByte(spirit, UNIT_FIELD_BYTE_0, 0)
end

--获取VIP时间
function UnitInfo:GetVipEndTime(lv)
	if lv > MAX_GAME_VIP_TYPE then
		return
	end
	return self:GetPlayerUInt32(PLAYER_FIELD_VIP1_TIME_OUT + lv - 1)
end

--设置VIP时间
function UnitInfo:SetVipEndTime(lv,tm)
	if lv > MAX_GAME_VIP_TYPE then
		return
	end
	self:SetPlayerUInt32(PLAYER_FIELD_VIP1_TIME_OUT + lv - 1, tm)
end

--获得掉落物品的归属者guid
function UnitInfo:GetLootOwnerGuid(  )
	return self:GetStr(UNIT_STRING_FIELD_LOOT_OWNER_GUID)
end

--设置掉落物品的归属者guid
function UnitInfo:SetLootOwnerGuid( guid )
	if self:GetLootOwnerGuid() ~= guid then
		self:SetStr(UNIT_STRING_FIELD_LOOT_OWNER_GUID, guid)
	end
end

--获得掉落物品的归属者名字
function UnitInfo:GetLootOwnerName(  )
	return self:GetStr(UNIT_STRING_FIELD_LOOT_OWNER_NAME)
end

--设置掉落物品的归属者名字
function UnitInfo:SetLootOwnerName( name )
	if self:GetLootOwnerName() ~= name then
		self:SetStr(UNIT_STRING_FIELD_LOOT_OWNER_NAME, name)
	end
end

--获取被动技能ID
function UnitInfo:GetPassiveSpellId( index)
	return self:GetPlayerUInt16(PLAYER_SCENED_INT_FIELD_PASSIVE_SPELL + index * MAX_SLOT_PASSIVE_COUNT + SLOT_PASSIVE_SPELL_ID ,0)
end

--设置被动技能ID
function UnitInfo:SetPassiveSpellId( index, val)
	self:SetPlayerUInt16(PLAYER_SCENED_INT_FIELD_PASSIVE_SPELL + index * MAX_SLOT_PASSIVE_COUNT + SLOT_PASSIVE_SPELL_ID,0, val)
end

--获取被动技能等级
function UnitInfo:GetPassiveSpellLevel( index)
	return self:GetPlayerUInt16(PLAYER_SCENED_INT_FIELD_PASSIVE_SPELL + index * MAX_SLOT_PASSIVE_COUNT + SLOT_PASSIVE_SPELL_ID,1)
end

--设置被动技能等级
function UnitInfo:SetPassiveSpellLevel( index, val)
	self:SetPlayerUInt16(PLAYER_SCENED_INT_FIELD_PASSIVE_SPELL + index * MAX_SLOT_PASSIVE_COUNT + SLOT_PASSIVE_SPELL_ID,1, val)
end

--获取被动技能CD
function UnitInfo:GetPassiveSpellCD( index)
	return self:GetPlayerUInt32(PLAYER_SCENED_INT_FIELD_PASSIVE_SPELL + index * MAX_SLOT_PASSIVE_COUNT + SLOT_PASSIVE_SPELL_CD)
end
--设置被动技能CD
function UnitInfo:SetPassiveSpellCD( index, val)
	self:SetPlayerUInt32(PLAYER_SCENED_INT_FIELD_PASSIVE_SPELL + index * MAX_SLOT_PASSIVE_COUNT + SLOT_PASSIVE_SPELL_CD, val)
end

--完成任务后某系统开启做点什么
function UnitInfo:ActivedSystemToDoSomething(questid)
	for key,val in pairs(tb_system_open)do
		local active_type = val.type
		if active_type == 1 then--任务激活
			if questid == val.value then
				playerLib.SendToAppdDoSomething(self.ptr, SCENED_APPD_ACTIVE_SYSTEM, key)
			end
		end
	end

	--新手引导，技能激活
	if questid == 3 then
		--发到应用服激活技能落雁斩
		playerLib.SendToAppdDoSomething(self.ptr, SCENED_APPD_ACTIVE_SPELL, 1)
	--elseif questid == 8 then
	--	--发到应用服激活技能破天三试一段
	--	playerLib.SendToAppdDoSomething(self.ptr, SCENED_APPD_ACTIVE_SPELL, 10)
	end
end

--通过原点和半径获取随机点坐标(b:为true时，为在地图内可在打码区，为false时，为玩家可到区域非打码区)
function GetRandPosByRadius(map_ptr, x, y, r, b)
	local beishu = 10000
	local pos_x, pos_y = x, y
	local dst_x, dst_y = x, y
	for i=1, 10 do		-- 10次没找到就把中心点给他
		local radius = randIntD(0, r*beishu)			-- 先随机半径
		local randX = randInt(-radius, radius)			-- 再随机x距离
		local randY = math.sqrt(math.pow(radius,2) - math.pow(randX,2))		-- 求出y距离
		pos_x = x + randX/beishu
		if randIntD(0, 100) <= 50 then
			pos_y = y + randY/beishu
		else
			pos_y = y - randY/beishu
		end
		if b and mapLib.IsInMap(map_ptr, pos_x, pos_y) ~= 0 or mapLib.IsCanRun(map_ptr, pos_x, pos_y) == 1 then
			dst_x, dst_y = pos_x, pos_y
			break
		end
	end
	return dst_x, dst_y
end
	
--计算经验加成(@player玩家对象，@creature怪物对象，@xp基本经验，@fcmtime防沉迷时间，@suitexp套装加成百分比，@percent可获得经验百分比)
function DOComputeExpBonusScript(player, creature, xp, fcmtime, percent)
	if(player == nil or GetUnitTypeID(player) ~= TYPEID_PLAYER)then
		return 0,0
	end
	if(xp == 0)then
		return 0,0
	end
	local cur_time = os.time()
	local result = xp
	local vip_exp = 0
	
	-- 队伍加成
	if GetGroupAddExp(player) > 0 then
		result = result + xp*GetGroupAddExp(player)/100
	end
	
	--经验丹加成
	if unitLib.HasBuff(player, BUFF_ONEPOINTFIVE_JINGYAN) then		
		result =  result + xp*0.5		
	elseif unitLib.HasBuff(player, BUFF_TOW_JINGYAN) then
		result =  result + xp*1
	elseif unitLib.HasBuff(player, BUFF_THREE_JINGYAN) then
		result =  result + xp*2
	elseif unitLib.HasBuff(player, BUFF_FIVE_JINGYAN) then
		result =  result + xp*4		
	end
	
	--防沉迷部分
	if(fcmtime ~= MAX_UINT32_NUM and fcmtime >=300) then
		result = 0
		vip_exp = 0
	elseif(fcmtime ~= MAX_UINT32_NUM and fcmtime >= 180) then
		result = result * 0.5
		vip_exp = vip_exp * 0.5
	end
	return result,vip_exp
end

--属性重算（场景服）
function DoRecalculationAttrs(attrBinlog, player, runtime, bRecal)


end

--应用服通知场景服消耗元宝或铜钱做些什么
function DoScenedComsumeMoney(player_ptr, money_type, use_type, use_param)
	local map_ptr = unitLib.GetMap(player_ptr)
	local mapid = unitLib.GetMapID(player_ptr)
	local playerInfo = UnitInfo:new{ptr = player_ptr}
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}

	if use_type == USE_GLOD_BUY_AUTO_RESPAWN then --原地复活
		-- 必须在世界地图
		if not IsWorldMap(mapid) then
			return
		end
		-- 必须是死了
		if playerInfo:IsAlive() then
			return
		end
		unitLib.Respawn(player_ptr, RESURRPCTION_HUANHUNDAN, 5)	
	elseif(use_type == USE_GOLD_BUY_PLAYER_FUBENLING)then		-- 购买副本令		
		local energy = playerInfo:GetPlayerCurEnergyCount()
		playerInfo:SetPlayerCurEnergyCount(energy + 10)
	end
end

-- 判断是否是没有buff NPC(不会有流血等buff)
function IsNoBuffNPC(entry)
	for k,v in pairs(no_buff_npc_entry_config) do
		if(entry == v)then
			return true
		end
	end
	return false
end

-- 获取点到点的距离
function GetTwoPointDistance(pos_x, pos_y, tar_x, tar_y)
	local dx = pos_x - tar_x
	local dy = pos_y - tar_y
	return math.sqrt(math.pow(dx,2)+math.pow(dy,2))
end

require 'scened.unit.unit_spell'
