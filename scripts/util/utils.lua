
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