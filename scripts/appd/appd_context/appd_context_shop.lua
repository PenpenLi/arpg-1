
--MONEY_CHANGE_BUY_HP_ITEM
function PlayerInfo:buyItem(moneyType, entry, count, oper_type, goldInstead, insteadRate)
	goldInstead = goldInstead or 0
	
	local id = moneyType * 100000 + entry
	-- 是否在商城可以买到
	if not tb_shop[id] then
		return false
	end
	-- 单价不能 < 0
	local price = tb_shop[id].costResource[ 1 ][ 2 ]
	if price < 0 then
		return false
	end 
	local money = count * price
	
	if not self:SubMoney(moneyType, oper_type, money) then
		if goldInstead == 0 then
			return false
		end
		
		local gold = math.ceil(money / insteadRate)
		if not self:SubMoney(MONEY_TYPE_GOLD_INGOT, oper_type, gold) then
			return false
		end
	end
	
	
	return true
end