
--添加技能
function UnitInfo:AddSpell(need_add_spell, spell_cd_save)
	local idx = 0
	for i = 1, #need_add_spell, 2 do
		local index = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0 + idx * MAX_SLOT_ATTR_COUNT
		local spell_id = need_add_spell[i]
		self:SetPlayerUInt32(index + SLOT_SPELL_ID, spell_id)
		self:SetPlayerUInt32(index + SLOT_SPELL_LV, need_add_spell[i+1])
		if(spell_cd_save[spell_id] ~= nil and spell_cd_save[spell_id] > 0)then
			--需要存技能cd的技能
			if(self:isNeedSaveSpellCd(spell_id))then
				if self:GetPlayerUInt32(index + SLOT_SPELL_CD) ~= spell_cd_save[spell_id] then
					self:SetPlayerUInt32(index + SLOT_SPELL_CD, spell_cd_save[spell_id])
				end
			else
				playerLib.SetSpellCD(self.ptr, spell_id, spell_cd_save[spell_id])--保存cd
			end
		else
			--需要存技能cd的技能
			if(self:isNeedSaveSpellCd(spell_id))then
				if self:GetPlayerUInt32(index + SLOT_SPELL_CD) ~= 0 then
					self:SetPlayerUInt32(index + SLOT_SPELL_CD, 0)
				end
			else
				if(playerLib.GetSpellCD(self.ptr, spell_id) ~= 0)then
					playerLib.SetSpellCD(self.ptr, spell_id, 0)
				end
			end
		end
		idx = idx + 1
		if idx >= PLAYER_SPELL_MAX_COUNT then break end				--已经超过最大技能槽个数了
	end
	--把后面多余的清空
	for i = idx, PLAYER_SPELL_MAX_COUNT-1 do
		local index = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0 + i * MAX_SLOT_ATTR_COUNT
		if(self:GetPlayerUInt32(index + SLOT_SPELL_ID) ~= 0)then
			--清空
			self:SetPlayerUInt32(index + SLOT_SPELL_ID, 0)
			self:SetPlayerUInt32(index + SLOT_SPELL_LV, 0)
			self:SetPlayerUInt32(index + SLOT_SPELL_CD, 0)
		end
	end
end

function UnitInfo:PrintSpellSlotInfo()
	for i = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0, PLAYER_SCENED_INT_FIELD_SLOT_SPELL_END-1, MAX_SLOT_ATTR_COUNT do
		local spell_id = self:GetPlayerUInt32(i + SLOT_SPELL_ID)
		if(spell_id ~= 0)then
			outDebug('spell id = '..spell_id)
			outDebug('spell spell_lv = '..self:GetPlayerUInt32(i + SLOT_SPELL_LV))	
			outDebug('spell cd = '..self:GetPlayerUInt32(i + SLOT_SPELL_CD))					
		end
	end
end

--删除技能
function UnitInfo:DeleteSpell(spell_id)
	for i = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0, PLAYER_SCENED_INT_FIELD_SLOT_SPELL_END-1, MAX_SLOT_ATTR_COUNT do
		if(self:GetPlayerUInt32(i + SLOT_SPELL_ID) == spell_id)then
			self:SetPlayerUInt32(i + SLOT_SPELL_ID, 0)
			self:SetPlayerUInt32(i + SLOT_SPELL_LV, 0)
			playerLib.SetSpellCD(self.ptr, spell_id, 0)
			self:SetPlayerUInt32(i + SLOT_SPELL_CD, 0)
			break
		end
	end
end

--获得技能等级
function UnitInfo:GetSpellLevel(spell_id)
	for i = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0, PLAYER_SCENED_INT_FIELD_SLOT_SPELL_END-1, MAX_SLOT_ATTR_COUNT do
		if(self:GetPlayerUInt32(i + SLOT_SPELL_ID) == spell_id)then
			return self:GetPlayerUInt32(i + SLOT_SPELL_LV)
		end
	end
	return 0
end

--判断释放技能的消耗是否够 返回true则够消耗
function UnitInfo:IsEnoughConsumption(spell_id)
	--FIXME
	if true then
		return true
	end

	spell_id = self:GetNextSpellID(spell_id)
	local config = tb_skill_base[spell_id].nuqi_change
	if config < 0 then
		if self:GetAnger() < math.abs(config) then
			return false
		end
	end
	return true
end

--处理释放技能消耗
function UnitInfo:SpellConsumption(spell_id)
	--FIXME
	if true then
		return true
	end

	spell_id = self:GetNextSpellID(spell_id)
	self:AddAnger(spell_id)
	return true
end

--设置技能cd
function UnitInfo:SetSpellCD(spell_id, nowtime)
	--设置技能cd
	if true then
		local cd = 500;
		--print("set next spell cd:"..(nowtime + cd))
		playerLib.SetSpellCD(self.ptr, spell_id, nowtime + cd)			--设置单独cd
		return
	end

	local spell_lv = self:GetSpellLevel(spell_id)
	local config = tb_skill_base[spell_id]
	if config ~= nil and spell_lv > 0 then
		local category_cd = config.groupCD
		local single_cd = config.singleCD
		local type = config.group				--技能族(同一技能族共享公共CD)
		--给同一族的技能设置公共CD
		for i = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0, PLAYER_SCENED_INT_FIELD_SLOT_SPELL_END-1, MAX_SLOT_ATTR_COUNT do
			local temp_id = self:GetPlayerUInt32(i + SLOT_SPELL_ID)
			if temp_id == spell_id and single_cd > 0 then
				--如果是二段技能，不用设置CD
				local old_spell_id = spell_id
				if self:GetTypeID() == TYPEID_PLAYER then
					old_spell_id = self:GetNextSpellID(spell_id)
				end
				if old_spell_id == spell_id then
					local cd_tm = nowtime + single_cd
					--需要存技能cd的技能
					if self:isNeedSaveSpellCd(spell_id) then
						if self:GetPlayerUInt32(i + SLOT_SPELL_CD) ~= cd_tm then
							self:SetPlayerUInt32(i + SLOT_SPELL_CD, cd_tm)
						end
					else
						playerLib.SetSpellCD(self.ptr, temp_id, cd_tm)			--设置单独cd
					end
				end
			end
			if tb_skill_base[temp_id] ~= nil and type == tb_skill_base[temp_id].group and category_cd > 0 then
				if temp_id == spell_id and category_cd > single_cd then
					local cd_tm = nowtime + category_cd
					if self:isNeedSaveSpellCd(temp_id) then
						if self:GetPlayerUInt32(i + SLOT_SPELL_CD) ~= cd_tm then
							self:SetPlayerUInt32(i + SLOT_SPELL_CD, cd_tm)
						end
					else
						playerLib.SetSpellCD(self.ptr, temp_id, cd_tm)		--设置公共cd
					end
				elseif temp_id ~= spell_id then
					local cd_tm = nowtime + category_cd
					if self:isNeedSaveSpellCd(temp_id) then
						if self:GetPlayerUInt32(i + SLOT_SPELL_CD) < cd_tm then
							self:SetPlayerUInt32(i + SLOT_SPELL_CD, cd_tm)
						end
					else
						if playerLib.GetSpellCD(self.ptr, temp_id) < cd_tm then
							playerLib.SetSpellCD(self.ptr, temp_id, cd_tm)	--设置公共cd
						end
					end
				end
			end
		end
	end
end

--判断技能是否处于CD，返回为true则技能冷却中
function UnitInfo:IsSpellCD(spell_id, nowtime)
	--print("IsSpellCD, spellID:"..spell_id)
	local cd = playerLib.GetSpellCD(self.ptr, spell_id)
	return nowtime < cd;
	--[[
	for i = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0, PLAYER_SCENED_INT_FIELD_SLOT_SPELL_END-1, MAX_SLOT_ATTR_COUNT do
		--print("index = "..i)
		if(self:GetPlayerUInt32(i + SLOT_SPELL_ID) == spell_id)then
			print("spellId = "..playerLib.GetSpellCD(self.ptr, spell_id))
			if(self:isNeedSaveSpellCd(spell_id))then
				if nowtime < self:GetPlayerUInt32(i + SLOT_SPELL_CD) then
					return true
				else
					self:SetPlayerUInt32(i + SLOT_SPELL_CD, 0)
				end
				break
			elseif(nowtime < playerLib.GetSpellCD(self.ptr, spell_id))then
				return true			--技能冷却中
			else
				--清理cd
				playerLib.SetSpellCD(self.ptr, spell_id, 0)
			end
			break
		end
	end
	return false
	]]
end

--判断是否有某个技能 返回为true则有这个技能
function UnitInfo:HasSpell(spell_id)
	for i = PLAYER_SCENED_INT_FIELD_SLOT_SPELL_0, PLAYER_SCENED_INT_FIELD_SLOT_SPELL_END-1, MAX_SLOT_ATTR_COUNT do
		if(self:GetPlayerUInt32(i + SLOT_SPELL_ID) == spell_id)then
			return true
		end
	end
	
	return false
end

--触发被动技能
function UnitInfo:triggerPassiveSpell(spell_id,cd)
	local nowtime = os.time()
	if passive_spell_cd[spell_id] then
		local ps_table = passive_spell_cd[spell_id]
		for i = 1,#ps_table,2 do
			if ps_table[i] == self:GetGuid() then
				if nowtime >= ps_table[2] then
					self:SetUnitPassiveSpellCD(spell_id,cd)
					return true
				end
			end
		end
	else
		passive_spell_cd[spell_id] = {}
		self:SetUnitPassiveSpellCD(spell_id,cd)
		return true
	end
	return false
end

--设置被动技能cd
function UnitInfo:SetUnitPassiveSpellCD(spell_id,cd)
	local new_cd = os.time() + cd
	local ps_table = passive_spell_cd[spell_id]
	for i = 1,#ps_table,2 do
		if ps_table[i] == self:GetGuid() then
			ps_table[i+1] = new_cd
			return
		end
	end
	table.insert(ps_table,self:GetGuid())
	table.insert(ps_table,new_cd)
end

--玩家是否激活该技能
function UnitInfo:IsActiveSpell(spell_id)
	for i = PLAYER_APPD_INT_FIELD_SPELL,PLAYER_APPD_INT_FIELD_SPELL_END,MAX_SPELLBASE do
		if(self:GetPlayerUInt32(i + SPELL_BASE_ID) == spell_id)then
			return true
		end
	end
	return false
end

--2段技能对应的有效时间下标
spell_valid_time_config = {
--技能ID = 下标位置
	[11] = SPELL_VALID_TIME_POTIAN_2, 
	[12] = SPELL_VALID_TIME_POTIAN_3, 
	[15] = SPELL_VALID_TIME_YUNFEI_2, 
	[16] = SPELL_VALID_TIME_YUNFEI_3, 
	[18] = SPELL_VALID_TIME_FENGFAN_2, 
	[20] = SPELL_VALID_TIME_ZHUXIAN_2,
	
}
