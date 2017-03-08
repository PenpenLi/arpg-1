--世界变量binlog
local GlobalCounter = class('GlobalCounter', assert(BinLogObject))

function GlobalCounter:ctor()
	
end

GlobalCounter.delimiter1 = ';'
GlobalCounter.delimiter2 = ','
GlobalCounter.WIN = 1
GlobalCounter.LOSE = -1

function GlobalCounter:IsInFight(rank)
	return self:GetBit(GLOBALCOUNTER_INT_FIELD_DOUJIANTAI_FLAG_START, rank-1)
end

function GlobalCounter:lock(rank1, rank2)
	if rank1 > 0 then
		self:SetBit(GLOBALCOUNTER_INT_FIELD_DOUJIANTAI_FLAG_START, rank1-1)
	end
	if rank2 > 0 then
		self:SetBit(GLOBALCOUNTER_INT_FIELD_DOUJIANTAI_FLAG_START, rank2-1)
	end
end

function GlobalCounter:unlock(rank1, rank2)
	if rank1 > 0 then
		self:UnSetBit(GLOBALCOUNTER_INT_FIELD_DOUJIANTAI_FLAG_START, rank1-1)
	end
	if rank2 > 0 then
		self:UnSetBit(GLOBALCOUNTER_INT_FIELD_DOUJIANTAI_FLAG_START, rank2-1)
	end
end

-- 初始化斗剑台初始排名
function GlobalCounter:InitDoujiantaiRank()
	local length = math.min(MAX_DOUJIANTAI_RANK_COUNT, #tb_doujiantai_dummy)
	for i = 1, length do
		self:unlock(i, 0)
	end
	----[[
	local firstInfo = self:GetStr(GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START)
	if string.len(firstInfo) > 0 then
		return
	end
	--]]
	local start = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START
	
	for i = 1, length do
		local config = tb_doujiantai_dummy[ i ]
		local content = self:OnJoinDummyInfo('', config)
		
		self:SetStr(start, content)
		start = start + 1
	end
end

-- 获得排名信息
function GlobalCounter:GetRankInfo(rank)
	local strstart = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START + rank - 1
	local content  = self:GetStr(strstart)
	
	--print("GetRankInfo =>", rank, content)
	
	local elements = string.split(content, '|')
	
	local config  = {}
	config.guid   = elements[ 1 ]
	config.name   = elements[ 2 ]
	config.gender = tonumber(elements[ 3 ])
	config.level  = tonumber(elements[ 4 ])
	config.attrs  = self:SplitStringTo2dDict(elements[ 5 ])
	config.weapon = tonumber(elements[ 6 ])
	config.avatar = tonumber(elements[ 7 ])
	config.divine = tonumber(elements[ 8 ])
	config.spells = self:SplitStringTo2dDict(elements[ 9 ])
	config.passivespells = self:SplitStringTo2dDict(elements[ 10 ])
	config.force  = tonumber(elements[ 11 ])
	config.vip    = tonumber(elements[ 12 ])
	config.reverse1 = tonumber(elements[ 13 ])
	config.reverse2 = tonumber(elements[ 14 ])
	config.reverse3 = tonumber(elements[ 15 ])
	config.reverse4 = tonumber(elements[ 16 ])
	config.reverse5 = tonumber(elements[ 17 ])
	
	return config
end

--[[
	delimiter1: 第一层的分隔符
	delimiter2: 第二层的分隔符
--]]
function GlobalCounter:Join2dDictString(dict, delimiter1, delimiter2)
	delimiter1 = delimiter1 or GlobalCounter.delimiter1
	delimiter2 = delimiter2 or GlobalCounter.delimiter2
	
	local f = {}
	
	for _, element in ipairs(dict) do
		table.insert(f, string.join(delimiter2, element))
	end
		
	if #f == 0 then
		return ''
	end
	return string.join(delimiter1, f)
end

--[[
	content	  : 加密的内容
	delimiter1: 第一层的分隔符
	delimiter2: 第二层的分隔符
--]]
function GlobalCounter:SplitStringTo2dDict(content, delimiter1, delimiter2)
	local f = {}
	
	if string.len(content) == 0 then
		return f
	end
	
	delimiter1 = delimiter1 or GlobalCounter.delimiter1
	delimiter2 = delimiter2 or GlobalCounter.delimiter2
	
	local subs = string.split(content, delimiter1)
	for _, sub in pairs(subs) do
		local params = string.split(sub, delimiter2)
		table.insert(f, {tonumber(params[ 1 ]), tonumber(params[ 2 ]), tonumber(params[ 3 ]), tonumber(params[ 4 ]), tonumber(params[ 5 ])})
	end
	
	return f
end

-- 组装内容
function GlobalCounter:OnJoinDummyInfo(guid, config)
	local content = string.format("%s|%s|%d|%d|%s|%d|%d|%d|%s|%s|%d|%d|%d|%d|%d|%d|%d",
		guid,
		config.name, 
		config.gender,
		config.level,
		self:Join2dDictString(config.attrs),
		config.weapon,
		config.avatar,
		config.divine,
		self:Join2dDictString(config.spells),
		self:Join2dDictString(config.passivespells),
		config.force,
		config.vip,
		config.reverse1,
		config.reverse2,
		config.reverse3,
		config.reverse4,
		config.reverse5
	)
	
	return content
end

-- 离线同步
-- rank 外面自己判断
function GlobalCounter:SyncPlayerInfo(playerInfo, isReplace)
	isReplace = isReplace or false
	local rank = playerInfo:GetDoujiantaiRank()
	if rank == 0 then
		return
	end
	
	local start = rank - 1 + GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START
	local prev = self:GetStr(start)
	
	-- 不是替换也不是跟新的return
	if not isReplace and not string.find(prev, playerInfo:GetGuid()) then
		return
	end
	local config = playerInfo:GetDummyInfo()
	local content = self:OnJoinDummyInfo(playerInfo:GetGuid(), config)
	
	--print("SyncPlayerInfo =>", rank, content)
	
	-- 覆盖
	self:SetStr(start, content)
	
	-- 清空离线战斗记录
	local strstart = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_RECORD_START + (rank - 1) * MAX_DOUJIANTAI_RECORD_COUNT
	for i = 0, MAX_DOUJIANTAI_RECORD_COUNT-1 do
		local record = self:GetStr(strstart + i)
		if string.len(record) > 0 then
			self:SetStr(strstart + i, '')
		end
	end
end

-- 2个人挑战完了 (被挑战者锁住的情况)
function GlobalCounter:BattleFinish(playerInfo, fightRank, battleResult)
	local prevRank = playerInfo:GetDoujiantaiRank()
	local info = self:GetStr(GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START + fightRank - 1)
	local guid, e = self:GetSubInfo(info)
	local defenseName = self:GetSubInfo(info, e+1)
	
	-- 给挑战奖励
	local tryRewards = tb_doujiantai_base[ 1 ].tryReward
	playerInfo:AppdAddItems(tryRewards, MONEY_CHANGE_DOUJIAN_COMBATWIN_REWARD, LOG_ITEM_OPER_TYPE_DOUJIAN_COMBAT_REWARD)
	
	-- 解锁
	self:unlock(prevRank, fightRank)
	-- 连胜信息
	playerInfo:DoujianCombatWin(battleResult == GlobalCounter.WIN)

	-- 如果赢了且能够提升排名的
	if battleResult == GlobalCounter.WIN then		
		-- 加首胜信息
		playerInfo:DoujianFirstReward(fightRank)
		
		-- 成就
		self:AddAchieve(ACHIEVE_TYPE_DOUJIANTAI, 1)

		-- 没排名情况下挑战
		if prevRank == 0 then
			-- 设置自己的排名
			playerInfo:SetDoujiantaiRank(fightRank)
			
			-- 给对手设置信息
			self:NoticeEnemyToRefreshIfItIsPlayer(guid, prevRank)
			
			-- 设置数据
			self:SyncPlayerInfo(playerInfo, true)
			
			-- 给自己加记录
			self:AddRecord(playerInfo:GetGuid(), playerInfo:GetName(), defenseName, prevRank, fightRank, GlobalCounter.WIN)
			
			-- 对方是玩家就给对方加记录
			if string.len(guid) > 0 then
				self:AddRecord(guid, playerInfo:GetName(), defenseName, fightRank, prevRank, GlobalCounter.LOSE)
			end
			
			-- 从新刷新对手
			local instMgr = playerInfo:getInstanceMgr()
			instMgr:OnbeatRank(fightRank)
			
			return
		end
		
		-- 排名比挑战的高
		if prevRank > fightRank then
			-- 设置自己的排名
			playerInfo:SetDoujiantaiRank(fightRank)
			-- 给对手设置信息
			self:NoticeEnemyToRefreshIfItIsPlayer(guid, prevRank)
		
			-- 交换排名数据
			local indx1 = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START +  prevRank - 1
			local indx2 = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START + fightRank - 1
			self:SwapRecord(indx1, indx2)
			
			-- 交换离线数据
			local strstart1 = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_RECORD_START + ( prevRank - 1) * MAX_DOUJIANTAI_RECORD_COUNT
			local strstart2 = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_RECORD_START + (fightRank - 1) * MAX_DOUJIANTAI_RECORD_COUNT
			for i = 0, MAX_DOUJIANTAI_RECORD_COUNT-1 do
				self:SwapRecord(strstart1+i, strstart2+i)
			end
			
			-- 设置数据
			-- self:SyncPlayerInfo(playerInfo, true)
			
			-- 给自己加记录
			self:AddRecord(playerInfo:GetGuid(), playerInfo:GetName(), defenseName, prevRank, fightRank, GlobalCounter.WIN)
			
			-- 对方是玩家就给对方加记录
			if string.len(guid) > 0 then
				self:AddRecord(guid, playerInfo:GetName(), defenseName, fightRank, prevRank, GlobalCounter.LOSE)
			end
			
			-- 从新刷新对手
			local instMgr = playerInfo:getInstanceMgr()
			instMgr:OnbeatRank(fightRank)
			
		-- 理论上不会有
		elseif prevRank < fightRank then
			-- 给自己加记录
			self:AddRecord(playerInfo:GetGuid(), playerInfo:GetName(), defenseName, prevRank, prevRank, GlobalCounter.WIN)
			
			-- 对方是玩家就给对方加记录
			if string.len(guid) > 0 then
				self:AddRecord(guid, playerInfo:GetName(), defenseName, fightRank, fightRank, GlobalCounter.LOSE)
			end
		end
	else
		-- 如果输了
		-- 给自己加记录
		self:AddRecord(playerInfo:GetGuid(), playerInfo:GetName(), defenseName, prevRank, prevRank, GlobalCounter.LOSE)
		
		-- 对方是玩家就给对方加记录
		if string.len(guid) > 0 then
			self:AddRecord(guid, playerInfo:GetName(), defenseName, fightRank, fightRank, GlobalCounter.WIN)
		end
	end
end

-- 替别人修改数据
function GlobalCounter:NoticeEnemyToRefreshIfItIsPlayer(guid, rank)
	-- 设置对方的排名 如果对方是玩家且在线的话
	if string.len(guid) > 0 then
		local enemyInfo = app.objMgr:getObj(guid)
		if enemyInfo then
			enemyInfo:SetDoujiantaiRank(rank)
			-- 名次变了需要刷新可挑战对手信息
			local instMgr = enemyInfo:getInstanceMgr()
			print("enemy RefreshEnemysAfterRankChanged")
			instMgr:RefreshEnemysAfterRankChanged()
		end
	end
end

--[[
	delimiter = '|'
--]]
-- 返回得到的值和匹配的位置
function GlobalCounter:GetSubInfo(info, startPos, delimiter)
	startPos = startPos or 1
	delimiter = delimiter or '|'
	local e,_ = string.find(info, delimiter, startPos)
	local sub = string.sub(info, startPos, e-1)
	
	return sub, e
end

-- 交换记录
function GlobalCounter:SwapRecord(indx1, indx2)
	local s1 = self:GetStr(indx1)
	local s2 = self:GetStr(indx2)
	self:SetStr(indx1, s2)
	self:SetStr(indx2, s1)
end

-- 加记录
function GlobalCounter:AddRecord(guid, attackerName, defenseName, prevRank, rank, result)
	local record = string.format("%s|%s|%d|%d|%d|%d", attackerName, defenseName, prevRank, rank, result, os.time())
	local playerInfo = app.objMgr:getObj(guid)
	-- 玩家在线
	if playerInfo then
		local instMgr = playerInfo:getInstanceMgr()
		instMgr:AddDoujiantaiRecord(record)
		return
	end
	-- 玩家不在线
	-- 只有在榜里的玩家有离线数据
	if rank > 0 then
		self:AddOfflineRecord(rank, record)
	end
end

-- 添加离线记录
function GlobalCounter:AddOfflineRecord(rank, record)
	local strstart = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_RECORD_START + (rank - 1) * MAX_DOUJIANTAI_RECORD_COUNT
	local empty = -1
	for i = 0, MAX_DOUJIANTAI_RECORD_COUNT-1 do
		local record = self:GetStr(strstart + i)
		if string.len(record) == 0 then
			empty = i
			break
		end
	end
	
	if empty > -1 then
		self:SetStr(strstart + empty, record)
		return
	end
	for i = 1, MAX_DOUJIANTAI_RECORD_COUNT-1 do
		self:SetStr(strstart + i - 1, self:GetStr(strstart + i))
	end
	self:SetStr(strstart+MAX_DOUJIANTAI_RECORD_COUNT-1, record)
end

-- 玩家上线获取离线战斗记录
-- 只会在appd中调用
function GlobalCounter:Login(playerInfo)
	local prevRank = playerInfo:GetDoujiantaiRank()
	if prevRank > 0 then
		local info = self:GetStr(GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START + prevRank - 1)
		-- 名次没变么
		if string.find(info, playerInfo:GetGuid()) then
			self:SyncOfflineRecord(playerInfo)
			return
		end
		
		local rank = 0
		-- 查询新名次
		for i = 1, MAX_DOUJIANTAI_RANK_COUNT do
			local content = self:GetStr(GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_START + i - 1)
			-- 找到我的新名次
			if string.find(content, playerInfo:GetGuid()) then
				rank = i
				break
			end
		end
		
		playerInfo:SetDoujiantaiRank(rank)
		-- 同步离线数据
		if rank > 0 then
			self:SyncOfflineRecord(playerInfo)
		end
		
		-- 名次变了需要刷新可挑战对手信息
		local instMgr = playerInfo:getInstanceMgr()
		instMgr:RefreshEnemysAfterRankChanged()
	end
end

-- 同步离线的数据
function GlobalCounter:SyncOfflineRecord(playerInfo)
	local prevrank = playerInfo:GetDoujiantaiRank()
	local strstart = GLOBALCOUNTER_STRING_FIELD_DOUJIANTAI_RECORD_START + (prevrank - 1) * MAX_DOUJIANTAI_RECORD_COUNT
	
	for i = 0, MAX_DOUJIANTAI_RECORD_COUNT-1 do
		local record = self:GetStr(strstart + i)
		if string.len(record) > 0 then
			-- 给人物加记录
			local instMgr = playerInfo:getInstanceMgr()
			instMgr:AddDoujiantaiRecord(record)
			self:SetStr(strstart + i, '')
		end
	end
end

return GlobalCounter