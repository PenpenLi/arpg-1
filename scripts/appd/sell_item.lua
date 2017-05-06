local Packet = require 'util.packet'
--������Ʒ���
--[[
@player:��Ҷ���
@item_id:��Ʒid
@count:ʹ����Ʒ����
]]
function SellItem(player, item_guid, count)
	if count <= 0 then return end		--��������С�ڵ���0
	local itemMgr = player:getItemMgr()	
	local item = itemMgr:getItemByGuid(item_guid, BAG_TYPE_MAIN_BAG)		--ֻ������������Ʒ���ܳ���
	if not item then
		outFmtError("SellItem: not find item_id %s ", item_guid)
		--û�ҵ������Ʒ
		player:CallOptResult(OPRATE_TYPE_BAG,BAG_RESULT_ITEM_NOT_EXIST)
		return
	end
	--������Ʒ����������
	if count > item:getCount() then
		outFmtError("SellItem: item entry %d use count %d > has count %d", item:getEntry(), count, item:getCount())
		player:CallOptResult(OPRATE_TYPE_BAG,BAG_RESULT_LACK_USER)
		return
	end
	
	local item_entry = item:getEntry()
	local item_template = tb_item_template[item_entry]
	if not item_template then
		--ģ������û��
		outFmtError("SellItem: tb_item_template not find %d ! ",item_entry)
		return
	end
	if item_template.price == 0 then
		--��Ʒ���ɳ���
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

--������������Ʒ���
--[[
@player:��Ҷ���
@flag:ǿ������
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
			
			local value1 = tb_item_template[item:getEntry()].rank --�ȼ�(����) Ʒ��(����)  ����(����)  ս��(����)  ��ȡʱ��(����)  entry(����)
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


--��keyֵ��С��������ĵ�����
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

