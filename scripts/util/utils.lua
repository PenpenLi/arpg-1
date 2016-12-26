--[[
随机获得类似 {{值1, 万分比概率1},{值2, 万分比概率2},...}的值
]]
function GetRandomExp(expTable)
	local index = GetRandomIndex(expTable)
	if index > 0 then
		return expTable[index][ 1 ]
	end
	
	return 0
end

SHOP_ID_FACTOR = 100000
-- 通过货币类型和道具id获得商城道具序列号
function GetShopId(money_type, itemId)
	return money_type * SHOP_ID_FACTOR + itemId
end

function GetItemIdByShopId(id)
	return id % SHOP_ID_FACTOR
end

--[[
随机获得类似 {{值1, 万分比概率1},{值2, 万分比概率2},...}的下标
]]
function GetRandomIndex(randTable)
	local rd = randInt(1, 10000)
	local bs = 0
	
	for i = 1, #randTable do
		bs = bs + randTable[ i ][ 2 ]
		if rd <= bs then
			return i
		end
	end
	
	return 0
end

-- 从连续的size个数里面随机count个数, 保证惟一
function GetRandomIndexTable(size, count)
	assert(size >= count)
	
	local ret = {}
	
	local dict = {}
	for i = 1, size do
		table.insert(dict, i)
	end
	
	for i = 1, count do
		local indx = randInt(1, #dict)
		table.insert(ret, dict[indx])
		-- 替换到最后个并置空
		local last = dict[#dict]
		if indx ~= #dict then
			dict[indx] = last
		end
		dict[#dict] = nil
	end
	
	return ret
end


--合并类似{{key1, value1}, {key2, value2}...}的table
function AddTempInfoIfExist(map, key, value)
	for _, info in pairs(map) do
		if info[ 1 ] == key then
			info[ 2 ] = info[ 2 ] + value
			return
		end
	end
	table.insert(map, {key, value})
end

function TPrint(map)
	local out = "{"
	for i = 1, #map do
		if i > 1 then
			out = out .. ", "
		end
		out = out.."{"..map[ i ][ 1 ]..", "..map[ i ][ 2 ].."}"
	end
	out = out.."}"
end

function Ttab( tab )
	local out = "{"
	for i,v in ipairs(tab) do
		out = out .."{" .. i .. "," .. v .."}"
	end
	out = out.."}"
	outFmtInfo(out)
end

ItemToResoureceTable = {
	[Item_Loot_Gold_Ingot] = MONEY_TYPE_GOLD_INGOT,
	[Item_Loot_Bind_Gold ] = MONEY_TYPE_BIND_GOLD,
	[Item_Loot_Silver	 ] = MONEY_TYPE_SILVER,
	
	[Item_Loot_QI		 ] = MONEY_TYPE_QI,
	[Item_Loot_BEAST	 ] = MONEY_TYPE_BEAST,
	[Item_Loot_GEM		 ] = MONEY_TYPE_GEM,
}