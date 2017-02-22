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
	if (size < count) then
		return {}
	end
	
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

-- 合并 {[key] = value}的table
function MergeSameTable(map, key, value)
	if not map[key] then
		map[key] = 0
	end
	map[key] = map[key] + value
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

-- 是否是资源
function IsResource(itemId)
	return tb_item_template[itemId].money_type > 0
end

-- 获得资源类型
function GetMoneyType(itemId)
	local money_type = tb_item_template[itemId].money_type - 1
	local ret = false
	money_type = money_type or -1
	ret = ret or money_type ~= -1
	return money_type
end

-- 判断字符串匹配正则的结果
function DoFind(str, regex, rep)
	local ret = {}
    local indx = 1
    local size = #str
    while (indx <= size) do
        local a, b = string.find(str, regex, indx)
        if not a then
            break
        end
        indx = b+1
		local substr = string.sub(str, a, b)
		substr, _ = string.gsub(substr, regex, rep)
		table.insert(ret, {a, b, substr})
    end
	
	return ret
end


function DoRandomDropTable(dropTable, dict)
	for _, dropId in pairs(dropTable) do
		DoRandomDrop(dropId, dict)
	end
end

-- 随机奖励 并合并到dict中
function DoRandomDrop(dropId, dict)
	local config = tb_drop_reward[dropId]
	
	for _, packetInfo in pairs(config.reward) do
		local packetId = packetInfo[ 1 ]
		local rate = packetInfo[ 2 ]
		local rd = randInt(1, 10000)
		
		if rd <= rate then
			local packConfig = tb_drop_packet[packetId]
			
			local indx = GetRandomIndex(packConfig.items)
			local itemId = packConfig.items[indx][ 1 ]
			local count = GetRandomExp(packConfig.counts[indx])
			
			if dict[itemId] == nil then
				dict[itemId] = 0
			end
			dict[itemId] = dict[itemId] + count
		end
	end
end

--[[
dict = {[itemId] = num}
]]
function Change_To_Item_Reward_Info(dict, exp)
	exp = exp or false
	-- 扫荡的结果发送
	local list = {}
	for item_id, num in pairs(dict) do
		if (item_id ~= Item_Loot_Exp or exp) then
			local stru = item_reward_info_t .new()
			stru.item_id	= item_id
			stru.num 		= num
			table.insert(list, stru)
		end
	end
	
	return list
end

--[[
	{{key1, value1}, {key2, value2}}  => {[key] = value}
]]
function changeTableStruct(dict)
	local ret = {}
	
	for _, info in pairs(dict) do
		ret[info[ 1 ]] = info[ 2 ]
	end
	
	return ret
end


-- PlayerInfo的属性换算战力
UnitInfo_Battle_Point_Rate = {
	[EQUIP_ATTR_MAXHEALTH] = 2,
	[EQUIP_ATTR_DAMAGE] = 3,
	[EQUIP_ATTR_ARMOR] = 2,
	[EQUIP_ATTR_HIT] = 2,
	[EQUIP_ATTR_DODGE] = 2,
	[EQUIP_ATTR_CRIT] = 1,
	[EQUIP_ATTR_TOUGH] = 1,
	[EQUIP_ATTR_ATTACK_SPEED] = 1,
	[EQUIP_ATTR_MOVE_SPEED] = 0,
	[EQUIP_ATTR_AMPLIFY_DAMAGE] = 1,
	[EQUIP_ATTR_IGNORE_DEFENSE] = 1,
	[EQUIP_ATTR_DAMAGE_RESIST] = 1,
	[EQUIP_ATTR_DAMAGE_RETURNED] = 1,
	[EQUIP_ATTR_HIT_RATE] = 1,
	[EQUIP_ATTR_DODGE_RATE] = 1,
	[EQUIP_ATTR_CRIT_RATE] = 1,
	[EQUIP_ATTR_CRITICAL_RESIST_RATE] = 1,
	[EQUIP_ATTR_DAMAGE_CRIT_MULTIPLE] = 1,
	[EQUIP_ATTR_RESIST_CRIT_MULTIPLE] = 1,
}

-- 计算战斗力
function DoAnyOneCalcForce(attrDict)
	local battlePoint = 0
	for attrId, value in pairs(attrDict) do
		battlePoint = battlePoint + value * UnitInfo_Battle_Point_Rate[attrId]
	end
	
	return battlePoint
end
function DoAnyOneCalcForceByAry(attrAy)
	local battlePoint = 0
	for k, v in pairs(attrAy) do
		--battlePoint = battlePoint + value * UnitInfo_Battle_Point_Rate[attrId]
		battlePoint = battlePoint + v[2] * UnitInfo_Battle_Point_Rate[v[1]]
	end
	
	return battlePoint
end

-- 获得邮件模版id
function GetMailEntryId(gift_type, level)
	return gift_type * 65536 + level
end


function ToShowName(playerName)
	outFmtDebug("playerName=%s", playerName)
	local A = string.byte("A")
	local dict = string.split(playerName, ",")
	local str = string.format("%s%s.%s", string.char((tonumber(dict[2]) - 1001) + A), dict[ 1 ], dict[ 3 ])
	
	return str
end

-- 获得今天刚开始的时间戳
function GetTodayStartTimestamp(days)
	local cur_date = os.date('*t', os.time())
	cur_date.hour = 0
	cur_date.sec = 0
	cur_date.min = 0
	return os.time(cur_date) + days * 86400
end
--获得今日指定时分秒的时间戳
function GetTodayHMSTimestamp(h,m,s)
	local cur_date = os.date('*t', os.time())
	cur_date.hour = h
	cur_date.sec = s
	cur_date.min = m
	return os.time(cur_date)
end

-- 价格打折
function GetCostMulTab(baseTab,mul)
	
	if mul == 1 then
		return baseTab
	else 
		local resultdic = {}
		for _,v in ipairs(baseTab) do
			local tab = {}
			table.insert(tab,v[1])
			table.insert(tab,math.ceil(v[2] * mul))
			
			table.insert(resultdic,tab)
		end
		return resultdic
	end

end

-- 获得玩家的当前速度
function GetPlayerSpeed(playerLevel, mountLevel, illusionId, isRidable)
	local speed = 0
	
	-- 未骑乘的取玩家速度
	if not isRidable then
		local config = tb_char_level[playerLevel]
		if config then
			for _, val in ipairs(config.prop) do
				local indx = val[ 1 ]
				if indx == EQUIP_ATTR_MOVE_SPEED then
					return val[ 2 ]
				end
			end
		end
		outFmtError("player level = %d has no speed attr", playerLevel)
		return 60
	end

	if tb_mount_base[mountLevel] then
		speed = tb_mount_base[mountLevel].speed
	end
	if illusionId > 0 then
		if speed < tb_mount_illusion[illusionId].speed then
			speed = tb_mount_illusion[illusionId].speed
		end
	end
	
	return speed
end


local weektimes = 604800
-- 从当前时间开始算 下一个星期x开始的时间戳
function GetNextWeekXStartTimeFromNow(x)
	-- 确保在0-6之间
	if x < 0 or x >= 7 then
		x = ((x % 7) + 7) % 7
	end
	
	return GetNextWeekXStartTimeFromTimestamp(x, os.time())
end

-- 从指定时间开始算 下一个星期x开始的时间戳
function GetNextWeekXStartTimeFromTimestamp(x, timestamp)
	local date = os.date('*t', timestamp)
	local weekend = date.wday
	date.hour = 0
	date.sec = 0
	date.min = 0
	date.wday = x+1 -- 周日为1
	local real_time = os.time(date)
	if real_time < timestamp then
		real_time = real_time + weektimes
	end
	
	return real_time
end

-- print(GetNextWeekXStartTimeFromNow(1))
-- print(GetNextWeekXStartTimeFromTimestamp(1, 1488211200-weektimes))