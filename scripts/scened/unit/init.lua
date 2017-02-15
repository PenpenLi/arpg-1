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

-- 是否在挂机
function UnitInfo:isInHook()
	return self:GetPlayerUInt32(PLAYER_FIELD_HOOK) > 0
end

-- 是否自动使用复活丹(原地复活)
function UnitInfo:isUseRespawnItem()
	return self:GetPlayerByte(PLAYER_FIELD_HOOK_BYTE3, 0) > 0
end

-- 获得玩家的虚拟阵营
function UnitInfo:GetVirtualCamp()
	return self:GetPlayerUInt32(PLAYER_INT_FIELD_VIRTUAL_CAMP)
end

-- 是否拒绝接受附近消息
function UnitInfo:isDeclineNearMsg()
	return self:GetPlayerByte(PLAYER_FIELD_DECLINE_CHANNEL_BYTE1, 0) > 0
end

--获得int guid
function UnitInfo:GetIntGuid(  )
	return unitLib.GetIntGuid(self.ptr)
end

-- 判断大的进入条件是否满足
function UnitInfo:makeEnterTest(toMapId)
	local mapid = unitLib.GetMapID(self.ptr)
	local bbit  = tb_map[mapid].type
	local value = bit.lshift(1, bbit)
	
	local mask = tb_map[toMapId].enter_mask
	return bit.band(mask, value) > 0
end

--最重要的操作结果
function UnitInfo:CallOptResult( typed, reason, data )
	if GetUnitTypeID(self.ptr) ~= TYPEID_PLAYER then 
		outFmtError("UnitInfo:CallOptResult not player cant send packet")
		return
	end
	--碰上字符串数组自动拼接	
	if type(data) == 'table' then
		data = string.join('|', data)
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
		data = string.join('|', data)
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
	self:CheckPlayer(string.format("GetPlayerBit index = %d offset = %d ", index, offset))
	return binLogLib.GetBit(self.ptr_player_data, index, offset)
end

function UnitInfo:GetPlayerByte(index, offset)
	self:CheckPlayer(string.format("GetPlayerByte-- index = %d offset = %d", index, offset))
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
	self:CheckPlayer(string.format("SetPlayerBit index = %d offset = %d", index, offset))
	binLogLib.SetBit(self.ptr_player_data, index, offset)
end

function UnitInfo:UnSetPlayerBit(index, offset)
	self:CheckPlayer(string.format("UnSetPlayerBit-- index =%d offset = %d ", index, offset))
	binLogLib.UnSetBit(self.ptr_player_data, index, offset)
end

function UnitInfo:SetPlayerByte(index, offset, value)
	self:CheckPlayer(string.format("SetPlayerByte-- index = %d offset = %d", index, offset))
	binLogLib.SetByte(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SetPlayerUInt16(index, offset, value)
	self:CheckPlayer(string.format("SetPlayerUInt16-- index = %d offset = %d", index, offset))
	binLogLib.SetUInt16(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SubPlayerUInt16(index, offset, value)
	self:CheckPlayer(string.format("SubPlayerUInt16-- index = %d offset = %d", index, offset))
	binLogLib.SubUInt16(self.ptr_player_data, index, offset, value)
end

function UnitInfo:AddPlayerUInt16(index, offset, value)
	self:CheckPlayer(string.format("SubPlayerUInt16-- index = %d offset = %d", index, offset))
	binLogLib.AddUInt16(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SetPlayerUInt32(index, value)
	self:CheckPlayer(string.format("SetPlayerUInt32-- index = %d ", index))
	binLogLib.SetUInt32(self.ptr_player_data, index, value)
end

function UnitInfo:AddPlayerUInt32(index, value)
	self:CheckPlayer(string.format("AddPlayerUInt32-- index = %d", index))
	binLogLib.AddUInt32(self.ptr_player_data, index, value)
end

function UnitInfo:SubPlayerUInt32(index, value)
	self:CheckPlayer(string.format("SubPlayerUInt32-- index = %d", index))
	binLogLib.SubUInt32(self.ptr_player_data, index, value)
end

function UnitInfo:GetPlayerDouble(index)
	self:CheckPlayer(string.format("GetPlayerDouble-- index = %d", index))
	return binLogLib.GetDouble(self.ptr_player_data, index)
end

function UnitInfo:SetPlayerDouble(index, value)
	self:CheckPlayer(string.format("SetPlayerDouble-- index = %d", index))
	binLogLib.SetDouble(self.ptr_player_data, index, value)
end

function UnitInfo:AddPlayerDouble(index, value)
	self:CheckPlayer(string.format("AddPlayerDouble-- index = %d", index))
	binLogLib.AddDouble(self.ptr_player_data, index, value)
end

function UnitInfo:SubPlayerDouble(index, value)
	self:CheckPlayer(string.format("SubPlayerDouble-- index = %d", index))
	binLogLib.SubDouble(self.ptr_player_data, index, value)
end

function UnitInfo:AddPlayerByte(index, offset, value)
	self:CheckPlayer(string.format("AddPlayerByte-- index = % d offset = %d", index, offset))
	binLogLib.AddByte(self.ptr_player_data, index, offset, value)
end

function UnitInfo:SetPlayerStr(index, value)
	self:CheckPlayer(string.format("SetPlayerStr-- index = %d", index))
	binLogLib.SetStr(self.ptr_player_data, index,value)
end

function UnitInfo:SetPlayerFloat(index, value)
	self:CheckPlayer(string.format("SetPlayerFloat-- index = %d", index))
	binLogLib.SetFloat(self.ptr_player_data, index, value)
end

function UnitInfo:GetPlayerFloat(index)
	self:CheckPlayer(string.format("GetPlayerFloat-- index = %d", index))
	return binLogLib.GetFloat(self.ptr_player_data, index)
end

function UnitInfo:GetPlayerStr(index)
	self:CheckPlayer(string.format("GetPlayerStr-- index = %d", index))
	return binLogLib.GetStr(self.ptr_player_data, index)
end

--获得主玩家guid
function UnitInfo:GetPlayerGuid()
	self:CheckPlayer("GetPlayerGuid")
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

--获得打坐时间
function UnitInfo:GetDaZuoTime()
	return playerLib.GetDaZuoStartTime(self.ptr)
end

-- 开始打坐
function UnitInfo:StartDaZuo()
	playerLib.SetDaZuoStartTime(self.ptr, os.time())
end

-- 取消打坐
function UnitInfo:CancelDaZuo()
	--TODO: 取消以后的一些逻辑
	playerLib.SetDaZuoStartTime(self.ptr, 0)
end

-- 是否在战斗中
function UnitInfo:isInBattle()
	
end

------------------------------------
--需要读条
function UnitInfo:NeedUseMode()
	return self:GetBit(GO_FIELD_FLAGS, GO_FLAG_USEMODE)
end
------------------------------------


function UnitInfo:SetProcessTime(val)
	self:SetUInt32(UNIT_FIELD_PROCESS_TIME, val)
end

function UnitInfo:SetProcessSeconds(val)
	self:SetUInt32(UNIT_FIELD_PROCESS_SECONDS, val)
end	

function UnitInfo:SetPickedName(name)
	self:SetStr(UNIT_STRING_FIELD_PICK_NAME, name)
end	



--生物部分
function UnitInfo:SetBaseAttrs(info, bRecal, mul)
	local tBaseKey = {
		[EQUIP_ATTR_MAXHEALTH] = {UNIT_FIELD_MAXHEALTH},
		[EQUIP_ATTR_DAMAGE] = {UNIT_FIELD_DAMAGE},
		[EQUIP_ATTR_ARMOR] = {UNIT_FIELD_ARMOR},
		[EQUIP_ATTR_HIT] = {UNIT_FIELD_HIT},
		[EQUIP_ATTR_DODGE] = {UNIT_FIELD_DODGE},
		[EQUIP_ATTR_CRIT] = {UNIT_FIELD_CRIT},
		[EQUIP_ATTR_TOUGH] = {UNIT_FIELD_TOUGH},
		[EQUIP_ATTR_ATTACK_SPEED] = {UNIT_FIELD_ATTACK_SPEED},
		[EQUIP_ATTR_MOVE_SPEED] = {UNIT_FIELD_MOVE_SPEED},
		[EQUIP_ATTR_AMPLIFY_DAMAGE] = {UNIT_FIELD_AMPLIFY_DAMAGE},
		[EQUIP_ATTR_IGNORE_DEFENSE] = {UNIT_FIELD_IGNORE_DEFENSE},
		[EQUIP_ATTR_DAMAGE_RESIST] = {UNIT_FIELD_DAMAGE_RESIST},
		[EQUIP_ATTR_DAMAGE_RETURNED] = {UNIT_FIELD_DAMAGE_RETURNED},
		[EQUIP_ATTR_HIT_RATE] = {UNIT_FIELD_HIT_RATE},
		[EQUIP_ATTR_DODGE_RATE] = {UNIT_FIELD_DODGE_RATE},
		[EQUIP_ATTR_CRIT_RATE] = {UNIT_FIELD_CRIT_RATE},
		[EQUIP_ATTR_CRITICAL_RESIST_RATE] = {UNIT_FIELD_CRITICAL_RESIST_RATE},
		[EQUIP_ATTR_DAMAGE_CRIT_MULTIPLE] = {UNIT_FIELD_DAMAGE_CRIT_MULTIPLE},
		[EQUIP_ATTR_RESIST_CRIT_MULTIPLE] = {UNIT_FIELD_RESIST_CRIT_MULTIPLE},
	}
	--[[
	-- 只改变上线 不改变当前血量
	if bRecal then
		tBaseKey[EQUIP_ATTR_HP] = {UNIT_FIELD_MAXHEALTH}		 --血
	else
	]]
		-- 默认都走这里
	--tBaseKey[EQUIP_ATTR_MAXHEALTH] = {UNIT_FIELD_MAXHEALTH, UNIT_FIELD_HEALTH}		 --血
	--end
	
	for i = 1, #info do
		local attrtype = info[ i ][ 1 ]
		local attrval = info[ i ][ 2 ]
		if attrtype == EQUIP_ATTR_MAXHEALTH then
			attrval = math.floor(attrval * mul)
		end
		if tBaseKey[attrtype] then
			local k = tBaseKey[attrtype][ 1 ]
			if(self:GetUInt32(k) ~= attrval)then
				self:SetUInt32(k, attrval)
			end
			if attrtype == EQUIP_ATTR_MAXHEALTH and not bRecal then
				self:SetUInt32(UNIT_FIELD_HEALTH, attrval)
			end
		end	
	end
	--outFmtDebug('---> init creature attr %d %d %d', self:GetEntry(), self:GetUInt32(UNIT_FIELD_MAXHEALTH), self:GetUInt32(UNIT_FIELD_HEALTH))
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

--获取角色id
function UnitInfo:GetGender()
	return self:GetByte(UNIT_FIELD_BYTE_1, 0)
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
	self:SetDouble(UNIT_FIELD_FORCE, val)
end

--获取战斗力
function UnitInfo:GetForce()
	return self:GetDouble(UNIT_FIELD_FORCE)
end

--设置npc标志
function UnitInfo:SetNpcFlags(val)
	self:SetUInt32(UNIT_FIELD_NPC_FLAG, val)
end

--获得npc标志
function UnitInfo:GetNpcFlags()
	return self:GetUInt32(UNIT_FIELD_NPC_FLAG)
end

--设置npc名字
function UnitInfo:SetName(val)
	self:SetStr(BINLOG_STRING_FIELD_NAME, val)
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
	return self:GetPlayerStr(PLAYER_STRING_FIELD_FACTION_GUID)
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
	--TODO: return self:GetPlayerBit(PLAYER_FIELD_FLAGS, UNIT_FIELD_FLAGS_IS_PVE)
end

--获得备战状态
function UnitInfo:GetCastState(  )
	--TODO: return self:GetPlayerBit(PLAYER_FIELD_FLAGS, UNIT_FIELD_FLAGS_IS_CAST)
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

-- 获得怒气
function UnitInfo:GetSP()
	return self:GetUInt32(UNIT_FIELD_ANGER)
end

-- 设置怒气
function UnitInfo:SetSP(value)
	self:SetUInt32(UNIT_FIELD_ANGER, value)
end

-- 增加怒气
function UnitInfo:AddSP(value)
	local cas = playerLib.GetAngerSpell(self.ptr)
	if cas > 0 then
		local angerLimit = tb_anger_limit[cas].limit
		local currAnger = self:GetSP()
		if currAnger >= angerLimit then
			return
		end
		local nextAnger = currAnger + value
		if nextAnger > angerLimit then
			nextAnger = angerLimit
		end
		self:SetSP(nextAnger)
	end
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
	--[[
	if self:GetUseGameObjectTime() == 0 then
		self:SetUseGameObjectTime(os.time())
	end
	]]
	if not self:GetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT) then
		self:SetUnitFlags(UNIT_FIELD_FLAGS_USE_GAMEOBJECT)
	end
	
end

-- 移除使用游戏对象标识
function UnitInfo:RemoveUseGameObjectFlag()
	--[[
	if self:GetUseGameObjectTime() ~= 0 then
		self:SetUseGameObjectTime(0)
	end
	]]
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
	if not spirit then
		print( debug.traceback() )
	end
	return binLogLib.GetByte(spirit, UNIT_FIELD_BYTE_0, 0)
end


-- 获得vip等级
function UnitInfo:GetVIP()
	local vipLevel = self:GetUInt32(PLAYER_FIELD_VIP_LEVEL)
	if self:GetUInt32(PLAYER_FIELD_VIP_TIME_OUT) < os.time() then
		vipLevel = 0
	end
	return vipLevel
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

-- 同一个队伍返回1, 否则返回0
function UnitInfo:sameTeamCode(playerInfo)
	return 0
end

-- 同一个家族返回1, 否则返回0
function UnitInfo:sameFamilyCode(playerInfo)
	return 0
end

-- 生成是否能成为攻击目标的掩码
function UnitInfo:generateBattleMask(killerInfo)
	local bbit = self:GetBattleMode() * 4 + self:sameTeamCode(killerInfo) * 2 + self:sameFamilyCode(killerInfo)
	return bit.lshift(1, bbit)
end

-- 获得和平模式CD
function UnitInfo:GetPeaceModeCD()
	return self:GetPlayerUInt32(PLAYER_FIELD_PEACE_MODE_CD)
end

-- 设置和平模式CD
function UnitInfo:SetPeaceModeCD(cd)
	self:SetPlayerUInt32(PLAYER_FIELD_PEACE_MODE_CD, cd)
end

-- 获得战斗模式
function UnitInfo:GetBattleMode()
	return self:GetPlayerUInt16(PLAYER_FIELD_NOTORIETY, 0)
end

-- 设置战斗模式
function UnitInfo:SetBattleMode(value)
	self:SetPlayerUInt16(PLAYER_FIELD_NOTORIETY, 0, value)
end

-- 变成和平模式
function UnitInfo:ChangeToPeaceModeAfterTeleport()
	if self:GetBattleMode() ~= WICKED_MODE then
		self:SetBattleMode(PEACE_MODE)
	end
end

-- 获得恶名值
function UnitInfo:GetNotoriety()
	return self:GetPlayerUInt16(PLAYER_FIELD_NOTORIETY, 1)
end

-- 是否是和平模式
function UnitInfo:isPeaceMode()
	return self:GetBattleMode() == PEACE_MODE
end

-- 是否是全体模式
function UnitInfo:isAllMode()
	return self:GetBattleMode() == ALL_MODE
end

-- 设置恶名值
function UnitInfo:SetNotoriety(value)
	self:SetPlayerUInt16(PLAYER_FIELD_NOTORIETY, 1, value)
end

-- 获得自卫反击的GUID
function UnitInfo:GetSelfProtectedUIntGuid()
	return self:GetUInt32(UNIT_FIELD_SELF_DEFENSE_GUID)
end

-- 设置自卫反击的GUID
function UnitInfo:SetSelfProtectedUIntGuid(uintGuid)
	self:SetUInt32(UNIT_FIELD_SELF_DEFENSE_GUID, uintGuid)
end

-- 修改恶名值
function UnitInfo:ModifyNotoriety(value)
	local prev = self:GetNotoriety()
	local curr = prev + value
	if curr < 0 then curr = 0 end
	if curr > config.evil_max_value then curr = config.evil_max_value end
	
	-- 把自卫反击的对象消掉
	if self:GetSelfProtectedUIntGuid() > 0 then
		self:SetSelfProtectedUIntGuid(0)
	end
	
	if prev ~= curr then
		self:SetNotoriety(curr)
		-- 有恶名值的玩家被杀掉经验
		if curr < prev then
			if prev > 0 then
				local rate = tb_battle_killed_drop[prev].rate
				playerLib.LostExpOnDead(self.ptr, rate)
			end
		end
		-- 从恶人模式到和平模式
		if prev == config.evil_max_value then
			self:SetBattleMode(PEACE_MODE)
			return
		end
		-- 从其他模式到恶人模式
		if curr == config.evil_max_value then
			self:SetBattleMode(WICKED_MODE)
			return
		end
	end
end

-- 模式转换
function UnitInfo:modeChange(mode)
	local prev = self:GetBattleMode()
	if mode == prev then
		return
	end
	
	self:SetBattleMode(mode)
end

-- 是否有坐骑
function UnitInfo:IsMountActived()
	local actived = self:GetMountLevel()
	return actived > 0
end

-- 坐骑阶数
function UnitInfo:GetMountLevel()
	return self:GetByte(UNIT_FIELD_MOUNT_LEVEL, 0)
end

-- 坐骑星级
function UnitInfo:GetMountStar()
	return self:GetByte(UNIT_FIELD_MOUNT_LEVEL, 1)
end

-- 骑乘状态
function UnitInfo:rideFlag()
	return self:GetByte(UNIT_FIELD_MOUNT_LEVEL, 2)
end

-- 幻化id
function UnitInfo:GetCurrIllusionId()
	return self:GetByte(UNIT_FIELD_MOUNT_LEVEL, 3)
end

-- 是否骑乘
function UnitInfo:isRide()
	return self:IsMountActived() and self:rideFlag() > 0
end

-- 骑乘
function UnitInfo:MountRide()
	--playerLib.SendMountJumpDown(self.ptr, 1)
	playerLib.SendToAppdDoSomething(self.ptr, SCENED_APPD_RIDE, 1)
end

-- 下骑
function UnitInfo:MountUnride()
	playerLib.SendToAppdDoSomething(self.ptr, SCENED_APPD_RIDE, 0)
end

--获得当前生命	
function UnitInfo:GetHealth()
	return self:GetUInt32(UNIT_FIELD_HEALTH)
end

--设置当前生命	
function UnitInfo:SetHealth(val)
	self:SetUInt32(UNIT_FIELD_HEALTH, val)
end

--获得最大生命
function UnitInfo:GetMaxhealth()
	return self:GetUInt32(UNIT_FIELD_MAXHEALTH)
end

--设置最大生命
function UnitInfo:SetMaxhealth(val)
	self:SetUInt32(UNIT_FIELD_MAXHEALTH, val)
end

--获得攻击力
function UnitInfo:GetDamage()
	return self:GetUInt32(UNIT_FIELD_DAMAGE)
end

--设置攻击力
function UnitInfo:SetDamage(val)
	self:SetUInt32(UNIT_FIELD_DAMAGE, val)
end

--获得防御力
function UnitInfo:GetArmor()
	return self:GetUInt32(UNIT_FIELD_ARMOR)
end

--设置防御力
function UnitInfo:SetArmor(val)
	self:SetUInt32(UNIT_FIELD_ARMOR, val)
end

--获得命中
function UnitInfo:GetHit()
	return self:GetUInt32(UNIT_FIELD_HIT)
end

--设置命中
function UnitInfo:SetHit(val)
	self:SetUInt32(UNIT_FIELD_HIT, val)
end

--获得闪避
function UnitInfo:GetDodge()
	return self:GetUInt32(UNIT_FIELD_DODGE)
end

--设置闪避
function UnitInfo:SetDodge(val)
	self:SetUInt32(UNIT_FIELD_DODGE, val)
end

--获得暴击
function UnitInfo:GetCrit()
	return self:GetUInt32(UNIT_FIELD_CRIT)
end

--设置暴击
function UnitInfo:SetCrit(val)
	self:SetUInt32(UNIT_FIELD_CRIT, val)
end

--获得坚韧
function UnitInfo:GetTough()
	return self:GetUInt32(UNIT_FIELD_TOUGH)
end

--设置坚韧
function UnitInfo:SetTough(val)
	self:SetUInt32(UNIT_FIELD_TOUGH, val)
end

--获得攻击速度
function UnitInfo:GetAttackSpeed()
	return self:GetUInt32(UNIT_FIELD_ATTACK_SPEED)
end

--设置攻击速度
function UnitInfo:SetAttackSpeed(val)
	self:SetUInt32(UNIT_FIELD_ATTACK_SPEED, val)
end

--获得伤害加深(万分比)
function UnitInfo:GetAmplifyDamage()
	return self:GetUInt32(UNIT_FIELD_AMPLIFY_DAMAGE)
end

--设置伤害加深(万分比)
function UnitInfo:SetAmplifyDamage(val)
	self:SetUInt32(UNIT_FIELD_AMPLIFY_DAMAGE, val)
end

--获得忽视防御(万分比)
function UnitInfo:GetIgnoreDefense()
	return self:GetUInt32(UNIT_FIELD_IGNORE_DEFENSE)
end

--设置忽视防御(万分比)
function UnitInfo:SetIgnoreDefense(val)
	self:SetUInt32(UNIT_FIELD_IGNORE_DEFENSE, val)
end

--获得伤害减免(万分比)
function UnitInfo:GetDamageResist()
	return self:GetUInt32(UNIT_FIELD_DAMAGE_RESIST)
end

--设置伤害减免(万分比)
function UnitInfo:SetDamageResist(val)
	self:SetUInt32(UNIT_FIELD_DAMAGE_RESIST, val)
end

--获得反弹伤害(万分比)
function UnitInfo:GetDamageReturned()
	return self:GetUInt32(UNIT_FIELD_DAMAGE_RETURNED)
end

--设置反弹伤害(万分比)
function UnitInfo:SetDamageReturned(val)
	self:SetUInt32(UNIT_FIELD_DAMAGE_RETURNED, val)
end

--获得命中率加成(万分比)
function UnitInfo:GetHitRate()
	return self:GetUInt32(UNIT_FIELD_HIT_RATE)
end

--设置命中率加成(万分比)
function UnitInfo:SetHitRate(val)
	self:SetUInt32(UNIT_FIELD_HIT_RATE, val)
end

--获得闪避率加成(万分比)
function UnitInfo:GetDodgeRate()
	return self:GetUInt32(UNIT_FIELD_DODGE_RATE)
end

--设置闪避率加成(万分比)
function UnitInfo:SetDodgeRate(val)
	self:SetUInt32(UNIT_FIELD_DODGE_RATE, val)
end

--获得暴击率加成(万分比)
function UnitInfo:GetCritRate()
	return self:GetUInt32(UNIT_FIELD_CRIT_RATE)
end

--设置暴击率加成(万分比)
function UnitInfo:SetCritRate(val)
	self:SetUInt32(UNIT_FIELD_CRIT_RATE, val)
end

--获得抗暴率加成(万分比)
function UnitInfo:GetCriticalResistRate()
	return self:GetUInt32(UNIT_FIELD_CRITICAL_RESIST_RATE)
end

--设置抗暴率加成(万分比)
function UnitInfo:SetCriticalResistRate(val)
	self:SetUInt32(UNIT_FIELD_CRITICAL_RESIST_RATE, val)
end

--获得暴击伤害倍数(万分比)
function UnitInfo:GetDamageCritMultiple()
	return self:GetUInt32(UNIT_FIELD_DAMAGE_CRIT_MULTIPLE)
end

--设置暴击伤害倍数(万分比)
function UnitInfo:SetDamageCritMultiple(val)
	self:SetUInt32(UNIT_FIELD_DAMAGE_CRIT_MULTIPLE, val)
end

--获得降暴伤害倍数(万分比)
function UnitInfo:GetResistCritMultiple()
	return self:GetUInt32(UNIT_FIELD_RESIST_CRIT_MULTIPLE)
end

--设置降暴伤害倍数(万分比)
function UnitInfo:SetResistCritMultiple(val)
	self:SetUInt32(UNIT_FIELD_RESIST_CRIT_MULTIPLE, val)
end

--获得移动速度
function UnitInfo:GetMoveSpeed()
	return self:GetUInt32(UNIT_FIELD_MOVE_SPEED)
end

--设置移动速度
function UnitInfo:SetMoveSpeed(val)
	self:SetUInt32(UNIT_FIELD_MOVE_SPEED, val)
end

-- UnitInfo的属性映射方法
UnitInfo_Set_Attr_Func = {
	[EQUIP_ATTR_MAXHEALTH] = UnitInfo.SetMaxhealth,
	[EQUIP_ATTR_DAMAGE] = UnitInfo.SetDamage,
	[EQUIP_ATTR_ARMOR] = UnitInfo.SetArmor,
	[EQUIP_ATTR_HIT] = UnitInfo.SetHit,
	[EQUIP_ATTR_DODGE] = UnitInfo.SetDodge,
	[EQUIP_ATTR_CRIT] = UnitInfo.SetCrit,
	[EQUIP_ATTR_TOUGH] = UnitInfo.SetTough,
	[EQUIP_ATTR_ATTACK_SPEED] = UnitInfo.SetAttackSpeed,
	[EQUIP_ATTR_MOVE_SPEED] = UnitInfo.SetMoveSpeed,
	[EQUIP_ATTR_AMPLIFY_DAMAGE] = UnitInfo.SetAmplifyDamage,
	[EQUIP_ATTR_IGNORE_DEFENSE] = UnitInfo.SetIgnoreDefense,
	[EQUIP_ATTR_DAMAGE_RESIST] = UnitInfo.SetDamageResist,
	[EQUIP_ATTR_DAMAGE_RETURNED] = UnitInfo.SetDamageReturned,
	[EQUIP_ATTR_HIT_RATE] = UnitInfo.SetHitRate,
	[EQUIP_ATTR_DODGE_RATE] = UnitInfo.SetDodgeRate,
	[EQUIP_ATTR_CRIT_RATE] = UnitInfo.SetCritRate,
	[EQUIP_ATTR_CRITICAL_RESIST_RATE] = UnitInfo.SetCriticalResistRate,
	[EQUIP_ATTR_DAMAGE_CRIT_MULTIPLE] = UnitInfo.SetDamageCritMultiple,
	[EQUIP_ATTR_RESIST_CRIT_MULTIPLE] = UnitInfo.SetResistCritMultiple,
}

-- UnitInfo的属性映射方法
UnitInfo_Get_Attr_Func = {
	[EQUIP_ATTR_MAXHEALTH] = UnitInfo.GetMaxhealth,
	[EQUIP_ATTR_DAMAGE] = UnitInfo.GetDamage,
	[EQUIP_ATTR_ARMOR] = UnitInfo.GetArmor,
	[EQUIP_ATTR_HIT] = UnitInfo.GetHit,
	[EQUIP_ATTR_DODGE] = UnitInfo.GetDodge,
	[EQUIP_ATTR_CRIT] = UnitInfo.GetCrit,
	[EQUIP_ATTR_TOUGH] = UnitInfo.GetTough,
	[EQUIP_ATTR_ATTACK_SPEED] = UnitInfo.GetAttackSpeed,
	[EQUIP_ATTR_MOVE_SPEED] = UnitInfo.GetMoveSpeed,
	[EQUIP_ATTR_AMPLIFY_DAMAGE] = UnitInfo.GetAmplifyDamage,
	[EQUIP_ATTR_IGNORE_DEFENSE] = UnitInfo.GetIgnoreDefense,
	[EQUIP_ATTR_DAMAGE_RESIST] = UnitInfo.GetDamageResist,
	[EQUIP_ATTR_DAMAGE_RETURNED] = UnitInfo.GetDamageReturned,
	[EQUIP_ATTR_HIT_RATE] = UnitInfo.GetHitRate,
	[EQUIP_ATTR_DODGE_RATE] = UnitInfo.GetDodgeRate,
	[EQUIP_ATTR_CRIT_RATE] = UnitInfo.GetCritRate,
	[EQUIP_ATTR_CRITICAL_RESIST_RATE] = UnitInfo.GetCriticalResistRate,
	[EQUIP_ATTR_DAMAGE_CRIT_MULTIPLE] = UnitInfo.GetDamageCritMultiple,
	[EQUIP_ATTR_RESIST_CRIT_MULTIPLE] = UnitInfo.GetResistCritMultiple,
}

--属性重算（场景服）
function DoRecalculationAttrs(attrBinlog, player, runtime, bRecal)
	
end

-- 升级后增加的hp值 需要在场景服先算, 保证升级了血先满
function CalLevelUpRaisedHp(prev, curr)
	return calLevelHp(curr) - calLevelHp(prev)
end

function calLevelHp(level)
	local config = tb_char_level[level].prop
	if config then
		for _, attrInfo in pairs(config) do
			if attrInfo[ 1 ] == EQUIP_ATTR_MAXHEALTH then
				return attrInfo[ 2 ]
			end 
		end
	end
	return 100
end

-- PVP战斗死亡的逻辑
function OnPVPKilled(killer, target)
	local killerInfo = UnitInfo:new{ptr = killer}
	local targetInfo = UnitInfo:new{ptr = target}
		
	-- 如果targetInfo为和平模式,
	if targetInfo:isPeaceMode() then
		-- killer, 是全体模式的恶名值+1
		if killerInfo:isAllMode() then
			killerInfo:ModifyNotoriety(1)
			
			playerLib.SetNeedProtectBuff(targetInfo.ptr)
		end
	end
	-- target, 恶名值-1
	targetInfo:ModifyNotoriety(-1)
	
	-- 加仇人列表
	playerLib.SendToAppdDoSomething(target, SCENED_APPD_ADD_ENEMY, 1, killerInfo:GetPlayerGuid())
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
	
	--[[
	-- 队伍加成
	if GetGroupAddExp(player) > 0 then
		result = result + xp*GetGroupAddExp(player)/100
	end
	]]

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
	
	--[[
	--防沉迷部分
	if(fcmtime ~= MAX_UINT32_NUM and fcmtime >=300) then
		result = 0
		vip_exp = 0
	elseif(fcmtime ~= MAX_UINT32_NUM and fcmtime >= 180) then
		result = result * 0.5
		vip_exp = vip_exp * 0.5
	end
	]]
	
	return result,vip_exp
end

-- 怪物初始化
function creatureInit(creature, entry)
	local obj = tb_creature_template[entry]
	creatureLib.SetActionRadius(creature, obj.actionradius)
	creatureLib.SetVisionRadius(creature, obj.visionradius)
	creatureLib.SetScriptAI(creature, obj.ainame)
	creatureLib.SetReactState(creature, obj.attack_type)
end

-- 采集任务物品
function DoHandlePickGameObject(player_ptr, gameObjectEntry)
	playerLib.SendToAppdDoSomething(player_ptr, SCENED_APPD_GAMEOBJECT, gameObjectEntry)
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

function UnitInfo:GetUseRespawnMapId()
	return self:GetUInt32(UNIT_FIELD_USE_RESPAWN_MAPID)
end

function UnitInfo:SetUseRespawnMapId(mapid)
	self:SetUInt32(UNIT_FIELD_USE_RESPAWN_MAPID, mapid)
end


-- 获得最后一次参加世界BOSS的id
function UnitInfo:GetLastJoinID()
	return self:GetPlayerUInt32(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_ID)
end

-- 设置最后一次参加世界BOSS的id
function UnitInfo:SetLastJoinID(id)
	if self:GetLastJoinID() == id then
		return
	end
	self:SetPlayerUInt32(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_ID, id)
end

-- 获得最后一次参加世界BOSS的状态
function UnitInfo:GetLastState()
	return self:GetPlayerByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 0)
end

-- 设置最后一次参加世界BOSS的状态
function UnitInfo:SetLastState(state)
	if self:GetLastState() == state then
		return
	end
	self:SetPlayerByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 0, state)
end

-- 获得最后一次参加世界BOSS的分线
function UnitInfo:GetLastLine()
	return self:GetPlayerByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 1)
end

-- 设置最后一次参加世界BOSS的分线
function UnitInfo:SetLastLine(line)
	if self:GetLastLine() == line then
		return
	end
	self:SetPlayerByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 1, line)
end

-- 获得最后一次参加世界BOSS的自身死亡次数
function UnitInfo:GetLastDeath()
	return self:GetPlayerByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 2)
end

-- 增加最后一次参加世界BOSS的自身死亡次数
function UnitInfo:SetLastDeath(count)
	if self:GetLastDeath() == count then
		return
	end
	self:AddPlayerByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 2, count)
end


require 'scened.unit.unit_spell'
require 'scened.unit.scened_appd_dosomething'
