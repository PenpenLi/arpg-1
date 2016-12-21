-- �̵깺����Ʒ
function PlayerInfo:storeBuyItem(itemId, count)
	local itemMgr = self:getItemMgr()
	-- �жϱ����Ƿ��㹻
	if not itemMgr:canHold(BAG_TYPE_MAIN_BAG, itemId, count, 1, 0) then
		self:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_BAG_FULL)
		return
	end
	
	local costTable = tb_store[itemId].costResource
	if not self:costMoneys(MONEY_CHANGE_TYPE_STORE_BUY, costTable, count) then
		-- ����������ʾ
		return
	end

	-- �ӵ���
	itemMgr:addItem(itemId,count,1,true,true,0,0)
end

-- �̳ǹ�����Ʒ
function PlayerInfo:shopBuyItem(id, count)

	local itemMgr = self:getItemMgr()
	local entry = GetItemIdByShopId(id)
	local added = count * tb_shop[id].count
	
	-- �жϱ����Ƿ��㹻
	if not itemMgr:canHold(BAG_TYPE_MAIN_BAG, entry, added, 1, 0) then
		self:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_BAG_FULL)
		return
	end
	
	local costTable = tb_shop[id].costResource
	if not self:costMoneys(MONEY_CHANGE_TYPE_MALL_BUY, costTable, count) then
		return
	end
	
	-- �ӵ���
	itemMgr:addItem(entry,added,1,true,true,0,0)
end

-- Ԫ������
function PlayerInfo:goldRespawn(useGold)
	local resItemId = tb_hook_hp_item[ 2 ].items[ 1 ]
	local id = GetShopId(MONEY_TYPE_GOLD_INGOT, resItemId)
	
	if not tb_shop[id] then
		return
	end
	
	-- ����ͻ���
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
	--����cd
	itemMgr:handleCoolDown(resItemId)
	
	-- ���͵�������
	self:CallScenedDoSomething(APPD_SCENED_RESPAWN, resItemId)
end