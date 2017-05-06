local Packet = require 'util.packet'
--出售物品入口
--[[
@player:玩家对象
@item_id:物品id
@count:使用物品数量
]]
function SellItem(player, item_guid, count)
	if count <= 0 then return end		--数量不能小于等于0
	local itemMgr = player:getItemMgr()	
	local item = itemMgr:getItemByGuid(item_guid, BAG_TYPE_MAIN_BAG)		--只有主包裹的物品才能出售
	if not item then
		outFmtError("SellItem: not find item_id %s ", item_guid)
		--没找到这个物品
		player:CallOptResult(OPRATE_TYPE_BAG,BAG_RESULT_ITEM_NOT_EXIST)
		return
	end
	--背包物品的数量不够
	if count > item:getCount() then
		outFmtError("SellItem: item entry %d use count %d > has count %d", item:getEntry(), count, item:getCount())
		player:CallOptResult(OPRATE_TYPE_BAG,BAG_RESULT_LACK_USER)
		return
	end
	
	local item_entry = item:getEntry()
	local item_template = tb_item_template[item_entry]
	if not item_template then
		--模板配置没加
		outFmtError("SellItem: tb_item_template not find %d ! ",item_entry)
		return
	end
	if item_template.price == 0 then
		--物品不可出售
		outFmtError("SellItem: item price = 0 can not sell! ")
		return
	end
	
	local sell_reward = tb_item_template[item:getEntry()].sell_reward
	local all_rewards = {}
	for _,reward in pairs(sell_reward) do
		table.insert(all_rewards,{reward[1],reward[2]*count})
	end
	
	if itemMgr:delItemObj(item,count) then
		player:AppdAddItems(all_rewards,MONEY_CHANGE_NPC_SELL,nil)
--		player:AddMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_NPC_SELL, price*count)
		--print("")
	end
	
end

--整理主背包物品入口
--[[
@player:玩家对象
@flag:强制整理
]]
function SortItem(player,flag)
	local nowtime = os.time()
	local lasttime = player:GetBagSortTime()
	if  nowtime - lasttime < tb_item_sort_cd[1].cd or not flag then
		--outFmtError("SortItem: less than 10s from last sort!")
		return
	end
	if not flag then
		player:SetBagSortTime(nowtime)
	end
	
	for _,bag_type in pairs({BAG_TYPE_MAIN_BAG,BAG_TYPE_EQUIP_BAG}) do
		
		local itemMgr = player:getItemMgr()
		local items = itemMgr:getBagAllItem(bag_type)
		local index = 0
		for pos, item in pairsByKeys(items) do      
			--outFmtInfo("pos:%d item:%s",pos,item) 
			if pos == index then
				index = index + 1
			else
				itemMgr:exchangePos(bag_type,pos,bag_type,index)
				index = index + 1
			end
		end
		local items = itemMgr:getBagAllItem(bag_type)
		local tempTable = {}
		for pos, item in pairsByKeys(items) do
			
			local value1 = tb_item_template[item:getEntry()].rank --等级(降序) 品质(降序)  类型(升序)  战力(降序)  获取时间(降序)  entry(升序)
			local value2 = tb_item_template[item:getEntry()].quality
			local value3 = tb_item_template[item:getEntry()].type_c
			local value4 = item:getForce()
			local value5 = 0
			local value6 = item:getEntry()
			table.insert(tempTable,{pos=pos,value1=value1,value2=value2,value3=value3,value4=value4,value5=value5,value6=value6})
		end

		--print("------------------------------")	
		--printTable(tempTable)
		
		--quickSort(itemMgr,tempTable,function(a,b)
		mi_sort(tempTable, function(a,b)
			--print("================")
			--printTable(a)
			--printTable(b)
			local r = false
			if a.value1 == b.value1 then
				if a.value2 == b.value2 then
					if a.value3 == b.value3 then
						if a.value4 == b.value4 then
							if a.value5 == b.value5 then
								r =  a.value6 < b.value6
							else
							
							
							r =  a.value5 > b.value5
							end
						else
							r =  a.value4 > b.value4
						end
					else
						r =  a.value3 < b.value3
					end
				else
					r =  a.value2 > b.value2
				end
			else
				r =  a.value1 > b.value1
			end
			
			
			return r
		end,function(a,b)
			itemMgr:exchangePos(bag_type,a.pos,bag_type,b.pos)
			local temp = a.pos
			a.pos = b.pos
			b.pos = temp
		end)
	end

	
end

function printTable(obj)
	local value = dfs(obj)
	print(value)
end

function dfs(obj)
	local list = {}
	for key, val in pairs(obj) do
		local show = val
		if type(show) == 'table' then
			show = printTable(show)
		end
		
		table.insert(list, string.format("'%s' = %s", key, tostring(show)))
	end
	
	return string.join(",", list)
end


--按key值从小到大排序的迭代器
function pairsByKeys(t)
    local a = {}
    for n in pairs(t) do
        a[#a+1] = n
    end
    table.sort(a)
    local i = 0
    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end

