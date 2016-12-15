local Packet = require 'util.packet'
--使用物品入口
--[[
@player:玩家对象
@item_id:物品id
@count:使用物品数量
]]
function UseItem(player, item_guid, count)
	if count <= 0 then return end		--数量不能小于等于0
	local itemMgr = player:getItemMgr()	
	local item = itemMgr:getItemByGuid(item_guid, BAG_TYPE_MAIN_BAG)		--只有主包裹的物品才能使用
	if not item then
		outFmtError("UseItem: not find item_id %s ", item_guid)
		--没找到这个物品
		player:CallOptResult(OPRATE_TYPE_BAG,BAG_RESULT_ITEM_NOT_EXIST)
		return
	end
	--使用的数量不够
	if count > item:getCount() then
		outFmtError("UseItem: item entry %d use count %d > has count %d", item:getEntry(), count, item:getCount())
		player:CallOptResult(OPRATE_TYPE_BAG,BAG_RESULT_LACK_USER)
		return
	end
	
	local item_entry = item:getEntry()
	local item_template = tb_item_template[item_entry]
	if not item_template then
		--模板配置没加
		outFmtError("UseItem: tb_item_template not find %d ! ",item_entry)
		return
	end
	--是否不可被使用物品
	if item_template.use_result == ITEM_USE_RESULT_UN_USE then
		outFmtError("UseItem: item %d cant be used!", item_entry)
		return
	end
	--校验下使用等级
	if player:GetLevel() < item_template.level then
		outFmtError("UseItem: player %s level %d is too low to use item %d %d", player:GetGuid(), player:GetLevel(), item_entry, item_template.level)
		return
	end
	
	--校验物品cd
	local cd = itemMgr:getCoolDown(item_entry)
	if cd > 0 then
		outFmtDebug("UseItem: item %d has cd %d", item_entry, cd)
		return 
	end
	--处理cd
	itemMgr:handleCoolDown(item_entry)
	
	player.cur_use_item_guid = item_guid 	--保存当前正在使用的物品id
	--使用接口
	UseItemScripts.Go(UseItemScripts, player, item, count)
end

GOLD_TO_SILVER_RATE = 100000
function UseHpItem(player, entry, count)
	if count <= 0 then return false end		--数量不能小于等于0
	
	local itemMgr = player:getItemMgr()
	local items = itemMgr:getItemByEntry(BAG_TYPE_MAIN_BAG, entry)
	
	if #items == 0 then
		-- 购买药品
		-- 是否自动购买血瓶
		if not self:isAutoBuyHpItem() then
			return false
		end
		
		-- 银两不足是否用元宝购买
		local goldInstead = 0
		if self:isAutoBuyHpItemUseGold() then
			goldInstead = 1
		end
		
		-- 购买道具是否成功
		if not player:buyItem(MONEY_TYPE_SILVER, entry, count, MONEY_CHANGE_BUY_HP_ITEM, goldInstead, GOLD_TO_SILVER_RATE) then
			return false
		end
		
		items = itemMgr:getItemByEntry(BAG_TYPE_MAIN_BAG, entry)
	end
	
	local item = items[ 1 ]
	UseItem(player, item:getGuid(), count)
	
	return true
end


-- 购买自动复活道具
function useRespawn(player)
	local entry = 50003
	local count = 1
	
	local itemMgr = player:getItemMgr()
	local items = itemMgr:getItemByEntry(BAG_TYPE_MAIN_BAG, entry)
	
	if #items == 0 then
		-- 购买复活丹
		-- 是否自动购买
		if not self:isBuyRespawnByBindGold() then
			return false
		end
		
		-- 绑银不足是否用元宝购买
		local goldInstead = 0
		if self:isBuyRespawnByGold() then
			goldInstead = 1
		end
		
		-- 购买道具是否成功
		if not player:buyItem(MONEY_TYPE_BIND_GOLD, entry, count, MONEY_CHANGE_BUY_ATUO_RESPAWN, goldInstead, 1) then
			return false
		end
		
		items = itemMgr:getItemByEntry(BAG_TYPE_MAIN_BAG, entry)
	end
	
	local item = items[ 1 ]
	UseItem(player, item:getGuid(), count)
	return true
end



--场景服返回使用物品结果
function ScenedUseItemResult(player_guid, item_entry, count, result)
	if result == 0 then return end
	local player = app.objMgr:getObj(player_guid)
	if not player then
		outFmtDebug("use_item_result:player %s not online item_entry %d count %d", player_guid, item_entry, count)
		return
	end
	local itemMgr = player:getItemMgr()
	local item = itemMgr:getItemByGuid(player.cur_use_item_guid)
	if not item then 
		outFmtDebug("use_item_result: player %s not find item id %s", player_guid, player.cur_use_item_guid)
		return 
	end
	if item_entry ~= item:getEntry() then
		outFmtDebug("use_item_result: player %s useitem item_entry %d ~= %d", player_guid, item_entry, item:getEntry())
		return
	end

	local item_template = tb_item_template[item_entry]
	local use_type = item_template.use_result
	if use_type == ITEM_USE_RESULT_DISAPPEAR then
		local stack_count = item:getCount()
		if stack_count > count then
			item:setCount(stack_count - count)
			itemMgr.itemMgr:SavePtr(item.item)	
			WriteItemLog(player, LOG_ITEM_OPER_TYPE_FORGE_DECOMPOSE, item_entry, count, item:isBind())
		elseif stack_count == count then
			itemMgr:delItemObj(item)
			WriteItemLog(player, LOG_ITEM_OPER_TYPE_FORGE_DECOMPOSE, item_entry, count, item:isBind())
		end		
	end
end


---------------------------------------------------------
--使用物品:
--	@self:		自身table
--	@player:	使用物品的玩家
--	@item_entry:	使用的物品模板ID
--	@item_type:	物品模板里面的物品类别
--	@item_data:	物品模板中的保留字段

UseItemScripts = {
	--需要发送到场景服的物品模板(复活丹也写这里)
	scened_use_items_array = {
		191,171,201,202,203,204
	},
	
	scened_use_items_set = {},
	__init__= function(self)
		table.foreach(self.scened_use_items_array, function(i,v)
			self.scened_use_items_set[v] = 1
		end)
	end,
	
	Send2ScenedUseItem = function(self, player, item_entry, count)
		local pkt = Packet.new(INTERNAL_OPT_USER_ITEM)
		pkt:writeUTF(player:GetGuid())
		pkt:writeU32(item_entry)
		pkt:writeU32(count)
		app:sendToConnection(player:GetScenedFD(), pkt)
		pkt:delete()
	end,
	
	--使用物品脚本
	Go = function(self,player,item,count)
		local itemMgr = player:getItemMgr()
		local gender = player:GetGender()
		local item_entry = item:getEntry()
		local config = tb_item_template[item_entry]
		if not config then return end
		local item_type = config.type	
		local func = DoUseItem[item_entry]
		if(func ~= nil)then
			func(DoUseItem,player,item,count)
		else
			---发送到场景服使用
			--装备类型的物品不可以使用
			if item_type == ITEM_TYPE_EQUIP then
				outFmtError("item %d is equip, cant use!", item_entry)
				return
			end
			
			if(self.scened_use_items_set[item_entry]) then
				--需要发送的参数：玩家guid、物品模板、数量
				self:Send2ScenedUseItem(player, item_entry, count)		
				return
			end	
			--走使用物品流程
			if item_type == ITEM_TYPE_BOX then
				if config.is_slather == 0 and count > 1 then
					--不能批量使用，使用数量却大于1
					outFmtError("item cant batch use item %d count %d", item_entry, count)
					return
				end

				--宝箱类（使用获得道具类型）
				local  box_config = tb_box[item_entry]
				if not box_config then return end
				--是否装得下物品
				if (itemMgr:getEmptyCount() < (box_config.bag_num or 1) ) then	
					player:CallOptResult(OPRATE_TYPE_BAG,BAG_RESULT_BAG_FULL)
					return
				end
				local consum_config = box_config.cost
				--先看下够不够消耗
				for i = 1, #consum_config, 2 do
					local consum_type = consum_config[i]
					local consum_val = consum_config[i+1] * count
					if consum_type == Item_Loot_Silver then		--消耗铜钱
						if player:GetMoney(MONEY_TYPE_SILVER) < consum_val then return end
					elseif consum_type == Item_Loot_Bind_Gold then	--消耗绑定元宝
						if player:GetMoney(MONEY_TYPE_BIND_GOLD) < consum_val then return end
					elseif consum_type == Item_Loot_Gold then	--消耗元宝
						if player:GetMoney(MONEY_TYPE_GOLD_INGOT) < consum_val then return end
					else
						--消耗道具
						if player:CountItem(consum_type) < consum_val then return end
					end					
				end
				--可以处理消耗了
				for i = 1, #consum_config, 2 do
					local consum_type = consum_config[i]
					local consum_val = consum_config[i+1] * count
					if consum_type == Item_Loot_Silver then		--消耗铜钱
						if(self:SubMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_USE_BOX, consum_val) == false)then return end
					elseif consum_type == Item_Loot_Bind_Gold then	--消耗绑定元宝
						if(self:SubMoney(MONEY_TYPE_BIND_GOLD, MONEY_CHANGE_USE_BOX, consum_val) == false)then return end
					elseif consum_type == Item_Loot_Gold then	--消耗元宝
						if(self:SubMoney(MONEY_TYPE_GOLD_INGOT, MONEY_CHANGE_USE_BOX, consum_val) == false)then return end
					else
						--消耗道具
						if(itemMgr:delItem(consum_type, consum_val) == SUB_ITEM_FAIL)then return end
					end					
				end
				--把物品先删掉
				if not itemMgr:delItemObj(item, count) then
					return
				end
				
				--可以开始给道具了
				local reward_config = box_config.reward_fix_nan
				if gender == CHAR_GENDER_FEMALE then
					reward_config = box_config.reward_fix_nv
				end
				
				for i = 1, count do				
					--给固定奖励
					for _,reward in ipairs(reward_config) do
						local typed = reward[1]
						if typed == Item_Loot_Silver then		--给铜钱
							player:AddItemByEntry(typed, reward[2], MONEY_CHANGE_BOX_OPEN)
						elseif typed == Item_Loot_Bind_Gold then	--给绑元
							player:AddItemByEntry(typed, reward[2], MONEY_CHANGE_BOX_OPEN)
						elseif typed == Item_Loot_Gold then	--给元宝
							player:AddItemByEntry(typed, reward[2], MONEY_CHANGE_BOX_OPEN)
						else
							--给道具
							player:AddItemByEntry(typed, reward[2], 0, LOG_ITEM_OPER_TYPE_OPEN_BOX, reward[3])						
						end				
					end
				end
				if config.is_slather == 0 then
					--给随机奖励
					local result = ExtractRandomReward( gender, box_config.reward_random_id )
					for _, config in ipairs(result) do
						--抽中了则给随机奖励
						player:AddItemByEntry(config[1], config[2] , MONEY_CHANGE_BOX_RANDOM, LOG_ITEM_OPER_TYPE_OPEN_BOX, config[3])
					end
				end
			elseif item_type == ITEM_TYPE_MEDICINE or item_type == ITEM_TYPE_BUFF or item_type == ITEM_TYPE_PK_MEDICINE or item_type == ITEM_TYPE_PET_MEDICINE then
				--药品、获得buff、pk药、宠物药发到场景服处理
				self:Send2ScenedUseItem(player, item_entry, count)	
			end			
		end
	end,
	
}
--初始化
UseItemScripts:__init__()

-- 是否是大cd物品模版（返回下标偏移值1-20，可使用次数）
function DoIsBigCdItemsEntry(entry)
	
	return 0
end

DoUseItem = {
	[301] = --八仙过海
		function(self,player,item,count)
			local itemMgr = player:getItemMgr()
			if (itemMgr:delItemObj(item, count)) then
				player:DoTitleOpt(TITLE_OPT_TYPE_JIHUO,TITLE_TYPE_BAXIANGUOHAI,os.time()+2592000)
			end
		end,
	[193] = --初级潜力丹
		function(self,player,item,count)
			local itemMgr = player:getItemMgr( )
			if (itemMgr:delItemObj(item, count)) then
				player:AddQianLiValue(count)
				player:AddAddQianLiValue(count)
			end
		end,		
	[194] = --中级潜力丹
		function(self,player,item,count)			
			local itemMgr = player:getItemMgr( )
			if (itemMgr:delItemObj(item, count)) then
				player:AddQianLiValue(3*count)
				player:AddAddQianLiValue(3*count)
			end
		end,		
	[195] = --高级潜力丹
		function(self,player,item,count)
			local itemMgr = player:getItemMgr( )
			if (itemMgr:delItemObj(item, count)) then
				player:AddQianLiValue(10*count)
				player:AddAddQianLiValue(10*count)
			end
		end,
}



