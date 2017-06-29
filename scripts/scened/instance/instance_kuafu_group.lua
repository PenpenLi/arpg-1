local security = require("base/Security")

InstanceKuafuGroup = class("InstanceKuafuGroup", InstanceInstBase)

InstanceKuafuGroup.Name = "InstanceKuafuGroup"
InstanceKuafuGroup.exit_time = 20
InstanceKuafuGroup.Time_Out_Fail_Callback = "timeoutCallback"
--InstanceKuafuGroup.broadcast_nogrid = 1
InstanceKuafuGroup.sub = "group_instance"

function InstanceKuafuGroup:ctor(  )
	
end

--初始化脚本函数
function InstanceKuafuGroup:OnInitScript()
	InstanceInstBase.OnInitScript(self) --调用基类
	-- 解析generalid
	self:parseGeneralId()
	
	self:OnInitMapTime()
	self:AddCountDown()
end

-- 活动正式开始
function InstanceKuafuGroup:OnInitMapTime()
	local id = self:GetHard()
	local timestamp = os.time() + tb_group_instance_base[ id ].startcd + tb_group_instance_base[ id ].time
	-- 加任务时间
	self:SetMapQuestEndTime(timestamp)
	-- 副本时间超时回调
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

function InstanceKuafuGroup:AddCountDown()
	local id = self:GetHard()
	local timestamp = os.time() + tb_group_instance_base[ id ].startcd
	self:SetMapStartTime(timestamp)
	self:AddTimeOutCallback("OnMonsterRefresh", timestamp)
end

function InstanceKuafuGroup:parseGeneralId()
	local generalId	= self:GetMapGeneralId()
	local params = string.split(generalId, '|')
	local hard = tonumber(params[ 2 ])
	self:SetHard(hard)
end

function InstanceKuafuGroup:TryToNextPart()
	self:AddUInt32(KUAFU_GROUP_INSTANCE_FIELDS_PART, 1)
	local part = self:GetPart()
	local id = self:GetHard()
	local len = #tb_group_instance_base[id].monster
	if part >= len then
		-- 写奖励
		local config = tb_group_instance_base[id]
		local allPlayers = mapLib.GetAllPlayer(self.ptr)
		for _, player_ptr in pairs(allPlayers) do
			local playerInfo = UnitInfo:new {ptr = player_ptr}
			
			local itemKeys = config.passRewardId
			local itemVals = config.passRewardCnt
			if not playerInfo:isGroupInstanceClearFlag(id) then
				itemKeys = config.fpRewardId
				itemVals = config.fpRewardCnt
			end
			
			local rewardDict = {}
			for i = 1, #itemKeys do
				local itemId = itemKeys[ i ]
				local count  = itemVals[ i ]
				table.insert(rewardDict, itemId..":"..count)
			end
			
			-- 设置名称
			local emptyIndex = self:findIndexByName(playerInfo:GetName())
			if emptyIndex > -1 then
				local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
				local strstart = KUAFU_GROUP_INSTANCE_STR_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_STR_COUNT
				self:SetStr(strstart + KUAFU_GROUP_INSTANCE_PLAYER_REWARDS, string.join(",", rewardDict))
			end
		end
	
		-- 副本完成
		self:SetMapState(self.STATE_FINISH)
		
		return
	end
	
	self:OnMonsterRefresh()
end

-- 当进度更新时调用
function InstanceKuafuGroup:AfterProcessUpdate(player)
	-- 判断副本是否
	if self:CheckQuestAfterTargetUpdate() then
		self:TryToNextPart()
	end
end

function InstanceKuafuGroup:SetHard(hard)
	self:SetUInt32(KUAFU_GROUP_INSTANCE_FIELDS_HARD, hard)
end

function InstanceKuafuGroup:GetHard()
	return self:GetUInt32(KUAFU_GROUP_INSTANCE_FIELDS_HARD)
end

function InstanceKuafuGroup:GetPart()
	return self:GetUInt32(KUAFU_GROUP_INSTANCE_FIELDS_PART)
end

-- 刷新boss
function InstanceKuafuGroup:OnMonsterRefresh()
	local id = self:GetHard()
	local part = self:GetPart()
	
	local entry = tb_group_instance_base[id].monster[part+1]
	local cnt = tb_group_instance_base[id].monsternum[part+1]
	local pos = tb_group_instance_base[id].monsterPos[part+1]
	
	local offs = 2
	local width = offs * 2 + 1
	local grids = width * width
	
	-- 左上角点的坐标
	local lx = pos[ 1 ] - offs
	local ly = pos[ 2 ] - offs
	
	local config = tb_creature_template[entry]
	local idTable = GetRandomIndexTable(grids, cnt)
	for _, indx in pairs(idTable) do
		local id = indx - 1
		local offx = id % width
		local offy = id / width
		local bornX = lx + offx
		local bornY = ly + offy
		
		local creature = mapLib.AddCreature(self.ptr, {
			templateid = entry, x = bornX, y = bornY,
			active_grid = true, ainame = config.ainame, npcflag = {}
		})
	end
	
	-- 刷新任务
	local mapQuest = tb_group_instance_base[id].quests[part+1]
	-- 加副本任务
	InstanceInstBase.OnAddQuests(self, {mapQuest})
end

-- 副本失败退出
function InstanceKuafuGroup:timeoutCallback()
	self:SetMapState(self.STATE_FAIL)
end

--当副本状态发生变化时间触发
function InstanceKuafuGroup:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH or tostate == self.STATE_FAIL then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		self:SyncResultToWeb()
		--10s后结束副本
		local timestamp = os.time() + self.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- 判断是否能退出副本
function InstanceKuafuGroup:DoPlayerExitInstance(player)
	return 1	--返回1的话为正常退出，返回0则不让退出
end

--玩家加入地图
function InstanceKuafuGroup:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		unitLib.Respawn(player, RESURRECTION_SPAWNPOINT, 100)
	end
	
	-- 不能重复进入
	if self:findIndexByName(playerInfo:GetName()) > -1 then
		local login_fd = serverConnList:getLogindFD()
		call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
		return
	end
	
	-- 设置名称
	local emptyIndex = self:findIndexByName()
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		local strstart = KUAFU_GROUP_INSTANCE_STR_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_STR_COUNT

		self:SetStr(strstart + KUAFU_GROUP_INSTANCE_PLAYER_NAME, playerInfo:GetName())
		self:SetStr(strstart + KUAFU_GROUP_INSTANCE_PLAYER_GUID, playerInfo:GetPlayerGuid())
		self:SetByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0, 0)
	end
end

--当玩家离开时触发
function InstanceKuafuGroup:OnLeavePlayer( player, is_offline)
	local unitInfo = UnitInfo:new{ptr = player}

	-- 活动副本结束了就不进行处理
	if self:GetMapState() ~= self.STATE_START then
		return
	end

	-- 如果没人了 那就结束
	local persons = mapLib.GetPlayersCounts(self.ptr)
	if persons == 0 then
		self:SetMapState(self.STATE_FAIL)
	end
end

-- 获得名字对应的位置, ''表示用来查询空位位置
function InstanceKuafuGroup:findIndexByName(name)
	name = name or ''
	local start = KUAFU_GROUP_INSTANCE_STR_FIELDS_PLAYER_INFO_START
	for i = 0, MAX_GROUP_INSTANCE_PLAYER_COUNT - 1 do
		if self:GetStr(start + KUAFU_GROUP_INSTANCE_PLAYER_NAME) == name then
			return i
		end
		start = start + MAX_KUAFU_GROUP_INSTANCE_PLAYER_STR_COUNT
	end
	
	return -1
end

--当玩家加入后触发
function InstanceKuafuGroup:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

--当玩家死亡后触发()
function InstanceKuafuGroup:OnPlayerDeath(player)
	-- 如果状态已经改变, 即使死了也不再更新时间
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	
	local playerInfo = UnitInfo:new {ptr = player}
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		self:AddByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0, 1)
	end
	
	self:OnSendDeathInfo(playerInfo, '', '', '')
end

-- 同步数据到场景服
function InstanceKuafuGroup:SyncResultToWeb()
	if self:GetMapState() ~= self.STATE_FINISH then
		return
	end
	
	local url = string.format("%s%s/match_result", globalGameConfig:GetExtWebInterface(), InstanceKuafuGroup.sub)
	local data = {}
	
	local sendInfo = {}
	local allPlayers = mapLib.GetAllPlayer(self.ptr)
	for _, player_ptr in pairs(allPlayers) do
		table.insert(sendInfo, GetPlayerGuid(player_ptr))
	end
	
	data.ret = string.join('|', sendInfo)..';'..self:GetHard()
	data.open_time = 1
	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@result = ", data.ret)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("response = %s", tostring(response))
	end)
end

-- 复活后
function InstanceKuafuGroup:DoAfterRespawn(unit_ptr)
	local unitInfo = UnitInfo:new{ptr = unit_ptr}
	-- 加无敌buff
	unitLib.AddBuff(unit_ptr, BUFF_INVINCIBLE, unit_ptr, 1, 3)
	
	local unitInfo = UnitInfo:new {ptr = unit_ptr}
	if unitInfo:GetTypeID() == TYPEID_PLAYER then
		-- 如果不对 退出跨服
		if unitInfo:GetUseRespawnMapId() > 0 then
			if unitInfo:GetUseRespawnMapId() ~= self:GetMapId() then
				self:IsNeedTeleportWhileMapClear(unit_ptr)
			end
			
			-- 复活到进入点
			local id = self:GetHard()
			local part = self:GetPart()
			local len = #tb_group_instance_base[id].monster
			if part >= len then
				part = len - 1
			end
			local pos = tb_group_instance_base[id].enterPos[part+1]
			local offsetX = randInt(-1, 1)
			local offsetY = randInt(-1, 1)
			
			local toMapId = self:GetMapId()
			local toX = pos[ 1 ] + offsetX
			local toY = pos[ 2 ] + offsetY
			local lineNo = self:GetMapLineNo()
			local generalId	= self:GetMapGeneralId()
			playerLib.Teleport(unit_ptr, toMapId, toX, toY, lineNo, generalId)

		end
		unitInfo:SetUseRespawnMapId(0)
	end
end

function InstanceKuafuGroup:OnSendDeathInfo(playerInfo, deathname ,killername ,params)
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	local cd = 60
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		local times = self:GetByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0)
		local id = self:GetHard()
		if times > #tb_group_instance_base[id].reborn then
			times = #tb_group_instance_base[id].reborn
		end
		cd = tb_group_instance_base[id].reborn[times]
	end
	
	-- 发送野外死亡回城倒计时
	playerInfo:call_field_death_cooldown(DEAD_PLACE_TYPE_GROUP_INSTANCE, deathname, killername, params, cd)
end

-- 获得单人的复活时间
function InstanceKuafuGroup:GetSingleRespawnTime(player)
	local playerInfo = UnitInfo:new {ptr = player}
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	if emptyIndex > -1 then
		local intstart = KUAFU_GROUP_INSTANCE_INT_FIELDS_PLAYER_INFO_START + emptyIndex * MAX_KUAFU_GROUP_INSTANCE_PLAYER_INT_COUNT
		local times = self:GetByte(intstart + KUAFU_GROUP_INSTANCE_PLAYER_DAED_TIMES, 0)
		local id = self:GetHard()
		if times > #tb_group_instance_base[id].reborn then
			times = #tb_group_instance_base[id].reborn
		end
		return tb_group_instance_base[id].reborn[times]
	end
	
	return 60
end

-- 地图需要清空人时要做的事
function InstanceKuafuGroup:IsNeedTeleportWhileMapClear(player)
	local playerInfo = UnitInfo:new {ptr = player}
	local login_fd = serverConnList:getLogindFD()
	call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
	return 0
end


-- 判断是否够钱花元宝复活
function InstanceKuafuGroup:OnCheckIfCanCostRespawn(player) end
-- 花元宝复活
function InstanceKuafuGroup:OnCostRespawn(unitInfo) end

function InstanceKuafuGroup:OnRandomRespawn(unitInfo)
	if not unitInfo:IsAlive() then
		local mapid = self:GetMapId()
		unitInfo:SetUseRespawnMapId(mapid)
		unitLib.Respawn(unitInfo.ptr, RESURRPCTION_HUANHUNDAN, 100)	--原地复活
	end
end

AI_GroupMonster = class("AI_GroupMonster", AI_Base)
AI_GroupMonster.ainame = "AI_GroupMonster"
--死亡
function AI_GroupMonster:JustDied( map_ptr,owner,killer_ptr )	
	-- 先判断是不是VIP副本	
	local mapid = mapLib.GetMapID(map_ptr)
	if tb_map[mapid].inst_sub_type ~= 12 then
		return
	end
	
	local instanceInfo = InstanceKuafuGroup:new{ptr = map_ptr}
	
	-- 如果时间到了失败了 即使最后下杀死BOSS都没用
	if instanceInfo:GetMapState() ~= instanceInfo.STATE_START then
		return
	end
	
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	
	-- 更新杀怪进度
	local ownerInfo = UnitInfo:new {ptr = owner}
	local entry = ownerInfo:GetEntry()
	local updated = instanceInfo:OneMonsterKilled(entry)
	
	-- 更新进度
	if updated then
		instanceInfo:AfterProcessUpdate(killer_ptr)
	end
	
	return 0
end

AI_GroupBoss = class("AI_GroupBoss", AI_GroupMonster)
AI_GroupBoss.ainame = "AI_GroupBoss"

return InstanceKuafuGroup