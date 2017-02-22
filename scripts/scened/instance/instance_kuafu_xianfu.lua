InstanceKuafuXianfu = class("InstanceKuafuXianfu", InstanceInstBase)

InstanceKuafuXianfu.Name = "InstanceKuafuXianfu"
InstanceKuafuXianfu.exit_time = 20
InstanceKuafuXianfu.Time_Out_Fail_Callback = "timeoutCallback"
InstanceKuafuXianfu.broadcast_nogrid = 1

function InstanceKuafuXianfu:ctor(  )
	
end

--初始化脚本函数
function InstanceKuafuXianfu:OnInitScript()
	InstanceInstBase.OnInitScript(self) --调用基类
	
	self:OnTaskStart()
	self:AddCountDown()
	
	-- boss刷新定时器
	mapLib.AddTimer(self.ptr, 'OnMonsterRefresh', 1000)
end

function InstanceKuafuXianfu:AddCountDown()
	local timestamp = os.time() + tb_kuafu_xianfu_base[ 1 ].cd
	self:SetMapStartTime(timestamp)
	self:AddTimeOutCallback("countdown", timestamp)
end

-- 倒计时结束
function InstanceKuafuXianfu:countdown()
	-- 符点刷新定时器
	mapLib.AddTimer(self.ptr, 'OnBuffRefresh', tb_kuafu_xianfu_base[ 1 ].interval * 1000)
end

-- 活动正式开始
function InstanceKuafuXianfu:OnTaskStart()
	local timestamp = os.time() +  tb_kuafu_xianfu_base[ 1 ].last + tb_kuafu_xianfu_base[ 1 ].cd
	-- 加任务时间
	self:SetMapQuestEndTime(timestamp)
	-- 副本时间超时回调
	self:AddTimeOutCallback(self.Time_Out_Fail_Callback, timestamp)
end

-- 刷新boss
function InstanceKuafuXianfu:OnMonsterRefresh()
	if self:GetMapState() == self.STATE_FINISH then
		return false
	end
	
	local timestamp = os.time()
	for indx, bossInfo in pairs(tb_kuafu_xianfu_boss) do
		local info = bossInfo.bossTime
		local createBossTime = info[ 1 ] * 60 + info[ 2 ]
		if self:GetMapCreateTime() + createBossTime == timestamp then
			local pos = bossInfo.bossPos
			local entry = bossInfo.bossEntry
			local bossName = tb_creature_template[entry].name
			local creature = mapLib.AddCreature(self.ptr, {
					templateid = entry, x = pos[ 1 ], y = pos[ 2 ], 
					active_grid = true, alias_name = bossName, ainame = "AI_XianfuBoss", npcflag = {}
				}
			)
			local place = string.char(64+indx)
			local boxid = tb_kuafu_xianfu_base[ 1 ].boxid
			app:CallOptResult(self.ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_OCCUR, {bossName, place, tb_item_template[boxid].name})
			self:SetUInt32(KUAFU_XIANFU_FIELDS_INT_BOSS_INDX, indx)
			break
		end
	end
	
	return true
end

-- 刷新buff
function InstanceKuafuXianfu:OnBuffRefresh()
	-- 处理刷新次数
	local times = self:GetMapReserveValue1()
	if times < tb_kuafu_xianfu_base[ 1 ].times then
		self:SetMapReserveValue1(times+1)
	end
	
	-- 刷新把原来的先删掉
	local allGameObjects = mapLib.GetAllGameObject(self.ptr)
	for _, gameobject in pairs(allGameObjects) do
		mapLib.RemoveWorldObject(self.ptr, gameobject)
	end
	
	-- 刷新新的
	local indice = GetRandomIndexTable(#tb_buff_xianfu, #tb_kuafu_xianfu_base[ 1 ].buffPos)
	for i = 1, #indice do
		local pos = tb_kuafu_xianfu_base[ 1 ].buffPos[ i ]
		local indx = indice[ i ]
		local entry = tb_buff_xianfu[indx].gameobject_id
		mapLib.AddGameObject(self.ptr, entry, pos[ 1 ], pos[ 2 ], GO_GEAR_STATUS_END)
	end
	
	return self:GetMapReserveValue1() < tb_kuafu_xianfu_base[ 1 ].times
end

-- 副本失败退出
function InstanceKuafuXianfu:timeoutCallback()
	self:SyncResultToWeb()
	self:SetMapState(self.STATE_FINISH)
	return false
end

--当副本状态发生变化时间触发
function InstanceKuafuXianfu:OnSetState(fromstate,tostate)
	if tostate == self.STATE_FINISH then
		self:RemoveTimeOutCallback(self.Time_Out_Fail_Callback)
		
		--10s后结束副本
		local timestamp = os.time() + InstanceKuafuXianfu.exit_time
		
		self:AddTimeOutCallback(self.Leave_Callback, timestamp)
		self:SetMapEndTime(timestamp)
	end
end

-- 判断是否能退出副本
function InstanceKuafuXianfu:DoPlayerExitInstance(player)
	return 1	--返回1的话为正常退出，返回0则不让退出
end




--[[

// 仙府夺宝 玩家信息
enum KUAFU_XIANFU_PLAYER_INFO
{
	KUAFU_XIANFU_PLAYER_SHOW_INFO	= 0,									// 4个byte(byte0:宝箱数量, byte1:击杀人数, byte2:击杀BOSS数量)
	KUAFU_XIANFU_PLAYER_SETTLEMENT	= KUAFU_XIANFU_PLAYER_SHOW_INFO + 1,	// 玩家战力
	MAX_KUAFU_XIANFU_INT_COUNT,												// kuafu属性数量

	KUAFU_XIANFU_PLAYER_NAME		= 0,									//玩家名称
	KUAFU_XIANFU_PLAYER_GUID		= KUAFU_XIANFU_PLAYER_NAME + 1,			//玩家guid
	MAX_KUAFU_XIANFU_STR_COUNT,
};

#define MAX_KUAFU_XIANFU_COUNT 10
// 跨服仙府夺宝匹配
enum KUAFU_XIANFU_FIELDS 
{
	KUAFU_XIANFU_FIELDS_INT_INFO_START	= MAP_INT_FIELD_INSTANCE_TYPE + 1,														// 跨服数据开始
	KUAFU_XIANFU_FIELDS_INT_INFO_END	= KUAFU_XIANFU_FIELDS_INT_INFO_START + MAX_KUAFU_XIANFU_COUNT * MAX_KUAFU_XIANFU_INT_COUNT,		// 3v3总共6个人

	KUAFU_XIANFU_FIELDS_STR_INFO_START	= MAP_STR_REWARD + 1,																// 字符串数据开始
	KUAFU_XIANFU_FIELDS_STR_INFO_END	= KUAFU_XIANFU_FIELDS_STR_INFO_START + MAX_KUAFU_XIANFU_COUNT * MAX_KUAFU_XIANFU_STR_COUNT,	// 字符串数据结束
};

--]]

--玩家加入地图
function InstanceKuafuXianfu:OnJoinPlayer(player)
	
	InstanceInstBase.OnJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	if not playerInfo:IsAlive() then
		--死亡了还进来，直接弹出去
		local login_fd = serverConnList:getLogindFD()
		call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
		return
	end
	
	-- 不能重复进入
	if self:findIndexByName(playerInfo:GetName()) > -1 then
		local login_fd = serverConnList:getLogindFD()
		call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
		return
	end
	
	-- 设置名称
	local emptyIndex = self:findIndexByName(playerInfo:GetName())
	if emptyIndex > -1 then
		local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_INT_COUNT
		local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START + emptyIndex * MAX_KUAFU_XIANFU_STR_COUNT

		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_NAME, playerInfo:GetName())
		self:SetStr(strstart + KUAFU_XIANFU_PLAYER_GUID, playerInfo:GetPlayerGuid())

		self:SetUInt32(intstart + KUAFU_XIANFU_PLAYER_SETTLEMENT,playerInfo:GetForce())
	end
end

-- 获得名字对应的位置, ''表示用来查询空位位置
function InstanceKuafuXianfu:findIndexByName(name)
	name = name or ''
	local start = KUAFU_XIANFU_FIELDS_STR_INFO_START
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do
		if self:GetStr(start+KUAFU_XIANFU_PLAYER_NAME) == name then
			return i
		end
		start = start + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	return -1
end

--当玩家加入后触发
function InstanceKuafuXianfu:OnAfterJoinPlayer(player)
	InstanceInstBase.OnAfterJoinPlayer(self, player)
end

function InstanceKuafuXianfu:DoIsFriendly(killer_ptr, target_ptr)
	local killerInfo = UnitInfo:new{ptr = killer_ptr}
	local targetInfo = UnitInfo:new{ptr = target_ptr}
	
	-- 只有怪物不能攻击怪物
	local ret =  targetInfo:GetTypeID() == TYPEID_UNIT and killerInfo:GetTypeID() == TYPEID_UNIT
	if ret then
		return 1
	end
	return 0
end

--当玩家死亡后触发()
function InstanceKuafuXianfu:OnPlayerDeath(player)
	-- 如果状态已经改变, 即使死了也不再更新时间
	if self:GetMapState() ~= self.STATE_START then
		return
	end
	
end

-- 同步数据到场景服
function InstanceKuafuXianfu:SyncResultToWeb()
	local sendInfo = {}

	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START
	local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do

		
		intstart = intstart + MAX_KUAFU_XIANFU_INT_COUNT
		strstart = strstart + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	local retInfo = {}
	-- 然后同步到web
	for _, info in pairs(sendInfo) do
		table.insert(retInfo, string.join(",", info))
	end
	
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/match_result"
	local data = {}
	-- 这里获得3v3队伍匹配的信息
	data.ret = string.join(";", retInfo)
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("response = %s", tostring(response))
	end)
end

-- 复活后
function InstanceKuafuXianfu:DoAfterRespawn(unit_ptr)
	local unitInfo = UnitInfo:new{ptr = unit_ptr}
	-- 加无敌buff
	unitLib.AddBuff(unit_ptr, BUFF_INVINCIBLE, unit_ptr, 1, 10)
	-- unitLib.AddBuff(unit_ptr, BUFF_INVISIBLE, unit_ptr, 1, MAX_BUFF_DURATION)
end

--[[
-- 玩家受到实际伤害(负数表示加血)
function InstanceKuafuXianfu:OnPlayerHurt(killer, player, damage)
	local killerInfo = UnitInfo:new{ptr = killer}
	local targetInfo = UnitInfo:new{ptr = player}
	
	-- 计算玩家血量
	local indx = self:findIndexByName(targetInfo:GetName())
	local rate = math.floor((targetInfo:GetHealth() - damage) * 100 / targetInfo:GetMaxhealth())
	local intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
	self:SetByte(intStart + KUAFU_XIANFU_PLAYER_SHOW_INFO, 1, rate)
	-- 计算玩家伤害
	if damage > 0 then
		indx = self:findIndexByName(killerInfo:GetName())
		intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
		self:AddDouble(intStart + KUAFU_XIANFU_PLAYER_DAMAGE, damage)
	end
	
	return 0
end
--]]

function InstanceKuafuXianfu:OnPlayerKilled(player, killer)
	local killerInfo = UnitInfo:new{ptr = killer}
	local playerInfo = UnitInfo:new{ptr = player}
	
	-- 击杀者加击杀数
	local indx1 = self:findIndexByName(killerInfo:GetName())
	local intStart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx1 * MAX_KUAFU_XIANFU_INT_COUNT
	self:AddByte(intStart + KUAFU_XIANFU_PLAYER_SETTLEMENT, 0, 1)
	
	-- 被杀者下标
	local indx2 = self:findIndexByName(playerInfo:GetName())
	
	-- 通知所有人击杀信息
	local strstart = KUAFU_XIANFU_FIELDS_STR_INFO_START
	for i = 0, MAX_KUAFU_XIANFU_COUNT-1 do
		local player_guid = self:GetStr(strstart + KUAFU_XIANFU_PLAYER_GUID)
		local player = mapLib.GetPlayerByPlayerGuid(self.ptr, player_guid)
		if player then
			local playerInfo = UnitInfo:new {ptr = player}
			playerInfo:call_kuafu_3v3_kill_detail(indx1, indx2)
		end
		
		strstart = strstart + MAX_KUAFU_XIANFU_STR_COUNT
	end
	
	self:OnDropTreasure(playerInfo, killerInfo:GetPlayerGuid())
	
	return 0
end


function InstanceKuafuXianfu:OnDropTreasure(playerInfo, belongGuid, is_offline)
	belongGuid = belongGuid or ''
	is_offline = is_offline or false
	local indx = self:findIndexByName(playerInfo:GetName())
	local intstart = KUAFU_XIANFU_FIELDS_INT_INFO_START + indx * MAX_KUAFU_XIANFU_INT_COUNT
end

--当玩家离开时触发
function InstanceKuafuXianfu:OnLeavePlayer( player, is_offline)
	-- 活动副本结束了就不进行处理
	if self:GetMapState() == self.STATE_FINISH then
		return
	end
	
	self:OnDropTreasure(UnitInfo:new{ptr = player})
end

--使用游戏对象之前
--返回1的话就继续使用游戏对象，返回0的话就不使用
function InstanceKuafuXianfu:OnBeforeUseGameObject(user, go, go_entryid, posX, posY)
	-- 如果已经死了 就不能捡了
	if unitLib.HasBuff(user, BUFF_INVINCIBLE) then
		return 0
	end
	
	if Script_Gameobject_Pick_Check(user, go_entryid, posX, posY) then
		return 1
	end
	return 0
end

--使用游戏对象
--返回1的话成功使用游戏对象，返回0的话使用不成功
function InstanceKuafuXianfu:OnUseGameObject(user, go, go_entryid, posX, posY)
	-- 判断对应的是那种buff
	for _, obj in ipairs(tb_buff_xianfu) do
		if obj.gameobject_id == go_entryid then
			local effects = obj.type_effect
			for _, effect in pairs(effects) do
				local buffId = effect[ 1 ]
				local lv = effect[ 2 ]
				local duration = tb_buff_template[buffId].duration
				SpelladdBuff(user, buffId, user, lv, duration)
			end
			break
		end
	end
	
	-- 需要删除对象
	mapLib.RemoveWorldObject(self.ptr, go)
	
	return 1	
end

-- 获得单人的复活时间
function InstanceKuafuXianfu:GetSingleRespawnTime(player)
	return tb_kuafu_xianfu_base[ 1 ].seconds[ 1 ]
end

-- 地图需要清空人时要做的事
function InstanceKuafuXianfu:IsNeedTeleportWhileMapClear(player)
	local playerInfo = UnitInfo:new {ptr = player}
	local login_fd = serverConnList:getLogindFD()
	call_scene_login_to_kuafu_back(login_fd, playerInfo:GetPlayerGuid())
	return 0
end





-------------------------仙府夺宝boss---------------------------
AI_XianfuBoss = class("AI_XianfuBoss", AI_Base)
AI_XianfuBoss.ainame = "AI_XianfuBoss"

--死亡
function AI_XianfuBoss:JustDied( map_ptr,owner,killer_ptr )
	AI_Base.JustDied(self,map_ptr,owner,killer_ptr)
	local bossInfo = UnitInfo:new{ptr = owner}
	local playerInfo = UnitInfo:new{ptr = killer_ptr}
	
	local instanceInfo = InstanceKuafuXianfu:new{ptr = map_ptr}
	
	-- 提示击杀奖励
	local indx = instanceInfo:GetUInt32(KUAFU_XIANFU_FIELDS_INT_BOSS_INDX)
	local boxes = tb_kuafu_xianfu_boss[indx].bossDrop[ 1 ]
	app:CallOptResult(map_ptr, OPRATE_TYPE_XIANFU, XIANFU_TYPE_BOSS_KILL, {bossInfo:GetName(), playerInfo:GetName(), boxes})
	
	
	--[[

	
	local instanceInfo = InstanceFieldBase:new{ptr = map_ptr}
	local mapid  = instanceInfo:GetMapId()
	local lineNo = instanceInfo:GetMapLineNo()
	local entry = bossInfo:GetEntry()
	
	globalValue:FieldBossDamageDeal(mapid, lineNo, 0)
	-- 获得伤害最高的guid
	local guid = mapLib.GetMaxinumFieldBossDamage(map_ptr)
	-- 清空BOSS伤害
	mapLib.ClearFieldBossDamage(map_ptr)
	-- BOSS死亡
	globalValue:FieldBossKilled(mapid, lineNo, guid, playerInfo:GetName())
	local playerName = ToShowName(playerInfo:GetName())
	app:CallOptResult(instanceInfo.ptr, OPERTE_TYPE_FIELD_BOSS, FIELD_BOSS_OPERTE_BOSS_KILL, {tb_creature_template[entry].name, playerName, tb_gameobject_template[InstanceFieldBase.Treasure_Entry].name})
	
	-- 加宝箱
	local posx, posy = unitLib.GetPos(owner)
	instanceInfo:AddTreasure(posx, posy, 500)
	]]
	
	return 0
end

--生成战利品
function AI_XianfuBoss:LootAllot(owner, player, killer, drop_rate_multiples, boss_type, fcm)
	local playerInfo = UnitInfo:new{ptr = player}
	local player_guid = playerInfo:GetPlayerGuid()

	print("################ AI_XianfuBoss:LootAllot")
	local map_ptr = unitLib.GetMap(owner)
	local instanceInfo = InstanceKuafuXianfu:new{ptr = map_ptr}
	
	-- 生成奖励
	local indx = instanceInfo:GetUInt32(KUAFU_XIANFU_FIELDS_INT_BOSS_INDX)
	local dropConfig = tb_kuafu_xianfu_boss[indx].bossDrop
	local boxes			= dropConfig[ 1 ]
	local protectTime	= dropConfig[ 2 ]
	local loot_entry 	= tb_kuafu_xianfu_base[ 1 ].boxid
	
	for i = 1, boxes do
		--模板,数量,绑定与否,存在时间,保护时间,强化等级
		--local drop_item_config = {entry, 1, 0, config.loot_exist_timer, protectTime, 0}		
		local count = 1
		AddLootGameObject(map_ptr, owner, player_guid, loot_entry, 0, fcm, config.loot_exist_timer, protectTime, 0)
	end
			
end


return InstanceKuafuXianfu