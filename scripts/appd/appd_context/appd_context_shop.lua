-- 商店购买物品
function PlayerInfo:storeBuyItem(itemId, count)
	local itemMgr = self:getItemMgr()
	-- 判断背包是否足够
	if not itemMgr:canHold(BAG_TYPE_MAIN_BAG, itemId, count, 1, 0) then
		self:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_BAG_FULL)
		return
	end
	
	local costTable = tb_store[itemId].costResource
	if not self:costMoneys(MONEY_CHANGE_TYPE_STORE_BUY, costTable, count) then
		-- 银两不足提示
		return
	end

	-- 加道具
	itemMgr:addItem(itemId,count,1,true,true,0,0)
end

-- 商城购买物品
function PlayerInfo:shopBuyItem(id, count)

	local itemMgr = self:getItemMgr()
	local entry = GetItemIdByShopId(id)
	local added = count * tb_shop[id].count
	
	-- 判断背包是否足够
	if not itemMgr:canHold(BAG_TYPE_MAIN_BAG, entry, added, 1, 0) then
		self:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_BAG_FULL)
		return
	end
	
	local costTable = tb_shop[id].costResource
	if not self:costMoneys(MONEY_CHANGE_TYPE_MALL_BUY, costTable, count) then
		return
	end
	
	-- 加道具
	itemMgr:addItem(entry,added,1,true,true,0,0)
end

-- 元宝复活
function PlayerInfo:goldRespawn(useGold)
	local resItemId = tb_hook_hp_item[ 2 ].items[ 1 ]
	local id = GetShopId(MONEY_TYPE_GOLD_INGOT, resItemId)
	
	if not tb_shop[id] then
		return
	end
	
	-- 本身就活着
	if self:IsAlive() then
		return
	end
		
	local cost = tb_shop[id].costResource[ 1 ][ 2 ]
	if useGold then
		if not self:SubGoldMoney (MONEY_CHANGE_BUY_ATUO_RESPAWN, cost) then
			return
		end
	else
		if not self:SubMoney(MONEY_TYPE_BIND_GOLD, MONEY_CHANGE_BUY_ATUO_RESPAWN, cost) then
			return
		end
	end
	
	
	local itemMgr = self:getItemMgr()
	--处理cd
	itemMgr:handleCoolDown(resItemId)
	
	-- 发送到场景服
	self:CallScenedDoSomething(APPD_SCENED_RESPAWN, resItemId)
end