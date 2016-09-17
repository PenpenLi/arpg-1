
--属性重算入口
function PlayerInfo:DoCalculAttr  ( attr_binlog)

end

--重设装备下标
function PlayerInfo:UpdatePlayerEquipment  ()
	for i = 0, EQUIPMENT_TYPE_MAX_POS-1 do
		self:UpdateEquipDisplay(i)
	end	
end

--更新玩家装备显示
function PlayerInfo:UpdateEquipDisplay  ( pos)		
	local useFashion = self:GetBit(PLAYER_EXPAND_INT_USE_FASHION, pos)

	--时装优先
	if(useFashion) then 
		local fashion_pos = pos + EQUIPMENT_TYPE_MAX_POS
		if(self:TrySetEquipment(pos, fashion_pos))then
			return
		end
	end
	-- --看下普通位置
	-- if(pos == EQUIPMENT_TYPE_MAIN_WEAPON)then
		-- --已穿戴的兵魂设置
		-- for i = SHENBING_TYPE_TANLANGXING, MAX_SHENBING_TYPE - 1 do
			-- if(self:GetShenBingWearFlags(i))then				
				-- if(tb_weapon[i+1].item_id ~= nil)then
					-- self:SetEquipment(EQUIPMENT_TYPE_MAIN_WEAPON, tb_weapon[i+1].item_id)
				-- end
				-- return
			-- end
		-- end
	-- end
	
	if(self:TrySetEquipment(pos, pos))then
		return
	end
	--什么都没有
	self:SetEquipment(pos, 0)
end

--尝试下设置装备显示
function PlayerInfo:TrySetEquipment  (equip_pos,item_pos)
	local itemMgr = self:getItemMgr()
	local item = itemMgr:getBagItemByPos(BAG_TYPE_EQUIP, item_pos)
	if item then
		local entry = item:getEntry()
		if(entry) then
			self:SetEquipment(equip_pos, entry)
			return true
		end		
	end
	
	return false
end

