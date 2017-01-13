--世界变量
local GlobalValue = class('GlobalValue', assert(BinLogObject))


function GlobalValue:ctor( )
end

--获取全服在线玩家数
function GlobalValue:GetQuanFuOnLinePlayerNum()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_ONLINE_PLAYER_NUM)
end

--获取当前活动版本号
function GlobalValue:GetLimitActivityVersion()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_LIMIT_ACTIVITY_VERSION)
end

--设置当前活动版本号
function GlobalValue:SetLimitActivityVersion(val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_LIMIT_ACTIVITY_VERSION,val)
end

--获取当前活动脚本
function GlobalValue:GetLimitActivityScript()
	return self:GetStr(GLOBALVALUE_STRING_FIELD_LIMIT_ACTIVITY_SCRIPT)
end
--设置当前活动脚本
function GlobalValue:SetLimitActivityScript(val)
	self:SetStr(GLOBALVALUE_STRING_FIELD_LIMIT_ACTIVITY_SCRIPT,val)
end

--获取当前活动结束时间
function GlobalValue:GetLimitActivityEndTime()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_LIMIT_ACTIVITY_END_TIME)
end
--设置当前活动结束时间
function GlobalValue:SetLimitActivityEndTime(val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_LIMIT_ACTIVITY_END_TIME,val)
end

--清空一些合服的时候需要清空的数据
function GlobalValue:ClearNeedClearInfo_Hefu()
	
end

-- 获得野外BOSS序号
function GlobalValue:GetFieldBossIndex(mapid, lineNo)
	local mapIndex = tb_map_field_boss[mapid].indx
	return mapIndex * MAX_DEFAULT_LINE_COUNT + lineNo - 1
end

-- 获得野外BOSS数据的int起始值
function GlobalValue:GetFieldBossIntStart(indx)
	return GLOBALVALUE_INT_FIELD_FIELD_BOSS_START + indx * MAX_FIELD_BOSS_INT_DATA_COUNT
end

-- 获得野外BOSS数据的str起始值
function GlobalValue:GetFieldBossStrStart(indx)
	return GLOBALVALUE_STRING_FIELD_FIELD_BOSS_START + indx * MAX_FIELD_BOSS_STR_DATA_COUNT
end


-- 重置野外boss数据
function GlobalValue:ResetFieldBoss(mapid, lineNo)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	local strStart = self:GetFieldBossStrStart(indx)

	-- 设置倒计时
	self:SetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE, FIELD_BOSS_PROCESS_START_COUNTDOWN)
	-- 即将刷新的时间
	self:SetUInt32(intStart + FIELD_BOSS_DATA_NEXT_BORN_TIME, os.time() + tb_map_field_boss_time[1].noticestarttime * 60)
	-- 清空优先开启时间戳
	--self:SetUInt32(intStart + FIELD_BOSS_DATA_PRIORITY_TIME, 0)
	-- 清空优先开始玩家guid
	--self:SetStr(strStart + FIELD_BOSS_DATA_MAX_DAMAGE_GUID, "")
	--self:SetStr(strStart + FIELD_BOSS_DATA_NAME, "")
end

-- 野外刷新BOSS
function GlobalValue:BornFieldBoss(mapid, lineNo)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	-- 设置最近一次刷新时间
	-- 设置boss刷新
	self:SetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE, FIELD_BOSS_PROCESS_BORN)
	-- 血量满
	-- self:SetDouble(intStart + FIELD_BOSS_DATA_CURR_HP, 100)
end

-- 野外BOSS受到伤害
function GlobalValue:FieldBossDamageDeal(mapid, lineNo, percent)
	--[[
	血量好像不需要存
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	-- 设置血量
	self:SetDouble(intStart + FIELD_BOSS_DATA_CURR_HP, percent)
	--]]
end

-- 野外BOSS死亡, 刷新箱子
function GlobalValue:FieldBossKilled(mapid, lineNo, guid, name)
	-- 一定要boss刷出来才会刷新箱子
	if not self:IsFieldBossBorn(mapid, lineNo) then
		return
	end
	
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	local strStart = self:GetFieldBossStrStart(indx)
	
	-- 血量清零
	--self:SetDouble(intStart + FIELD_BOSS_DATA_CURR_HP, 0)
	-- 设置宝箱出现
	self:SetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE, FIELD_BOSS_PROCESS_TREASURE)
	-- 设置BOSS击杀次数
	self:AddUInt32(intStart + FIELD_BOSS_DATA_KILLED, 1)
	
	-- 设置优先者 和 优先时间 及其名字
	self:SetUInt32(intStart + FIELD_BOSS_DATA_PRIORITY_TIME, os.time() + 60)
	self:SetStr(strStart + FIELD_BOSS_DATA_MAX_DAMAGE_GUID, guid)
	self:SetStr(strStart + FIELD_BOSS_DATA_NAME, name)
end

function GlobalValue:GetProtectCooldown(mapid, lineNo)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	local future = self:GetUInt32(intStart + FIELD_BOSS_DATA_PRIORITY_TIME)
	return future - os.time()
end


-- 箱子被领取, 活动结束
function GlobalValue:FieldBossTreasurePicked(mapid, lineNo)
	-- 一定是箱子领了才会活动结束
	if not self:IsFieldBossTreasureOccur(mapid, lineNo) then
		return
	end
	
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	-- 设置结束
	self:SetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE, FIELD_BOSS_PROCESS_TYPE_FINISH)
end

-- 是否已经结束
function GlobalValue:IsFieldBossFinish(mapid, lineNo)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	return self:GetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE) == FIELD_BOSS_PROCESS_TYPE_FINISH
end

-- 是否开始倒计时
function GlobalValue:IsFieldBossCountDown(mapid, lineNo)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	return self:GetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE) == FIELD_BOSS_PROCESS_START_COUNTDOWN
end

-- 是否刷新BOSS
function GlobalValue:IsFieldBossBorn(mapid, lineNo)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	return self:GetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE) == FIELD_BOSS_PROCESS_BORN
end

-- 是否是宝箱出现
function GlobalValue:IsFieldBossTreasureOccur(mapid, lineNo)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)
	
	return self:GetUInt32(intStart + FIELD_BOSS_DATA_PROCESS_TYPE) == FIELD_BOSS_PROCESS_TREASURE
end

-- 是否能够采集宝箱
function GlobalValue:CanPickTreasure(mapid, lineNo, guid)
	local indx = self:GetFieldBossIndex(mapid, lineNo)
	local intStart = self:GetFieldBossIntStart(indx)	
	local strStart = self:GetFieldBossStrStart(indx)
	
	-- 设置优先者 和 优先时间
	local priorityTime = self:GetUInt32(intStart + FIELD_BOSS_DATA_PRIORITY_TIME)
	local priorityGuid = self:GetStr(strStart + FIELD_BOSS_DATA_MAX_DAMAGE_GUID)
	return priorityTime < os.time() or guid == priorityGuid
end



-------------------------------世界BOSS---------------------------------

-- 获得世界BOSS的等级
function GlobalValue:GetWorldBossLevel()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_WORLD_BOSS_LEVEL)
end

-- 增加世界BOSS的等级
function GlobalValue:AddWorldBossLevel()
	self:AddUInt32(GLOBALVALUE_INT_FIELD_WORLD_BOSS_LEVEL, 1)
end

-- 获得世界BOSS的状态
function GlobalValue:GetWorldBossState()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_WORLD_BOSS_STATE)
end

-- 设置世界BOSS的状态
function GlobalValue:SetWorldBossState(state)
	if self:GetWorldBossState() == state then
		return
	end
	self:SetUInt32(GLOBALVALUE_INT_FIELD_WORLD_BOSS_STATE, state)
end

-- 获得世界BOSS的次数
function GlobalValue:GetWorldBossTimes()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_WORLD_BOSS_TIMES)
end

-- 设置世界BOSS的次数
function GlobalValue:AddWorldBossTimes()
	self:AddUInt32(GLOBALVALUE_INT_FIELD_WORLD_BOSS_TIMES, 1)
end

-- 是否是世界BOSS结束
function GlobalValue:IsWorldBossEnd()
	return self:GetWorldBossState() == WORLD_BOSS_PROCESS_TYPE_FINISH
end

-- 是否是世界BOSS报名阶段
function GlobalValue:IsWorldBossEnroll()
	return self:GetWorldBossState() == WORLD_BOSS_PROCESS_ENROLL
end

-- 是否是世界BOSS刷新阶段
function GlobalValue:IsWorldBossBorn()
	return self:GetWorldBossState() == WORLD_BOSS_PROCESS_BORN
end

-- 世界BOSS某条线是否结束
function GlobalValue:IsWorldBossEndInLine(lineNo)
	if lineNo < 1 or lineNo >= 32 then
		return
	end
	return self:GetBit(GLOBALVALUE_INT_FIELD_WORLD_BOSS_LINE_STATE, lineNo)
end

function GlobalValue:SetWorldBossEndInLine(lineNo)
	if lineNo < 1 or lineNo >= 32 then
		return
	end
	self:SetBit(GLOBALVALUE_INT_FIELD_WORLD_BOSS_LINE_STATE, lineNo)
end

function GlobalValue:UnSetWorldBossEndInLine()
	self:SetUInt32(GLOBALVALUE_INT_FIELD_WORLD_BOSS_LINE_STATE, 0)
end

-- 设置这2天要刷的世界BOSS类型
function GlobalValue:RandomStepWorldBoss()
	print("RandomStepWorldBoss")
	local dict = GetRandomIndexTable(#tb_worldboss_base, 2)
	self:SetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 0, dict[ 1 ])
	self:SetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 1, dict[ 2 ])
end

-- 服务器启动的时候调用 确定有需要随机的BOSS
function GlobalValue:RandomStepWorldBossIfNeverDoes()
	local id = self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 0)
	local id2 = self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 1)
	if not (0 < id and id <= #tb_worldboss_base) or not (0 < id2 and id2 <= #tb_worldboss_base) then
		globalValue:RandomStepWorldBoss()
	end
	print("curr boss id = ", self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 0), self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 1))
end

-- 设置这次的BOSS ID
function GlobalValue:RandomTodayWorldBossID()
	local indx = randInt(0, 1)
	local id = self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, indx)
	self:SetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 2, id)
	
	return self:GetTodayWorldBossID()
end

-- 获得今日的世界BOSSid
function GlobalValue:GetTodayWorldBossID()
	return self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 2)
end

-- BOSS结束的时候调用 确定有需要随机的BOSS
function GlobalValue:RandomWorldBossIfNextStep()
	local times = self:GetWorldBossTimes()
	if times % 2 == 0 then
		globalValue:RandomStepWorldBoss()
	end
end


-- 获得今日的世界BOSS房间个数
function GlobalValue:GetTodayWorldBossRoom()
	return self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 3)
end

-- 设置今日的世界BOSS房间个数
function GlobalValue:SetTodayWorldBossRoom(rooms)
	self:SetByte(GLOBALVALUE_INT_FIELD_WORLD_BOSS_ID, 3, rooms)
end











--根据帮派GUID返回帮派所在位置
function GlobalValue:GetFactionPosFromGuid(faction_guid)
	local pos
	for i = GLOBALVALUE_STRING_FIELD_FACTION_GUID_1,GLOBALVALUE_STRING_FIELD_FACTION_GUID_3
	do
		if(self:GetStr(i) == faction_guid)then
			pos =  i - GLOBALVALUE_STRING_FIELD_FACTION_GUID_1
			break
		end
	end
	return pos
end

--设置帮派所在世界变量位置
function GlobalValue:SetFactionPosFromGuid(faction_guid,faction_name)
	local pos
	for i = GLOBALVALUE_STRING_FIELD_FACTION_GUID_1,GLOBALVALUE_STRING_FIELD_FACTION_GUID_3
	do
		if(self:GetStr(i) == "" or self:GetStr(i) == nil)then
			pos =  i - GLOBALVALUE_STRING_FIELD_FACTION_GUID_1
			break
		end
	end
	--没位置可以设置
	if(pos == nil)then
		return false
	end
	self:SetStr(pos + GLOBALVALUE_STRING_FIELD_FACTION_GUID_1, faction_guid)
	self:SetStr(pos + GLOBALVALUE_STRING_FIELD_FACTION_NAME_1, faction_name)
	return true
end

--校验世界变量的帮派
function GlobalValue:CheckFactionGlobalValue()
	local faction_table = {}
	for i = GLOBALVALUE_STRING_FIELD_FACTION_GUID_1,GLOBALVALUE_STRING_FIELD_FACTION_GUID_3
	do
		local faction_guid = self:GetStr(i)
		local pos =  i - GLOBALVALUE_STRING_FIELD_FACTION_GUID_1
		if(faction_guid ~= "" and faction_guid ~= nil)then
			if(faction_table[faction_guid] == nil)then					
				faction_table[faction_guid] = 1
				--判断下帮派是否存在
				local faction = app.objMgr:getObj(faction_guid)
				if(faction == nil)then
					self:ClearFactionPosFromGuid(faction_guid)
				else
					if(self:GetStr(pos + GLOBALVALUE_STRING_FIELD_FACTION_NAME_1) == nil or self:GetStr(pos + GLOBALVALUE_STRING_FIELD_FACTION_NAME_1) == "" or self:GetStr(pos + GLOBALVALUE_STRING_FIELD_FACTION_NAME_1) ~= faction:GetName())then
						self:SetStr(pos + GLOBALVALUE_STRING_FIELD_FACTION_NAME_1,faction:GetName())
					end
				end
			else
				--世界变量存在双帮派问题
				self:SetStr(i,"")
				self:SetStr(pos + GLOBALVALUE_STRING_FIELD_FACTION_NAME_1,"")
			end
		end
	end
end
--获取兵魂激活人数
function GlobalValue:GetBingHunJiHuoNum(ntype)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_SHENBING_RANK + ntype)
end

--添加兵魂激活人数
function GlobalValue:AddBingHunJiHuoNum(ntype,val)
	self:AddUInt32(GLOBALVALUE_INT_FIELD_SHENBING_RANK + ntype,val)
end

--设置兵魂激活人数
function GlobalValue:SetBingHunJiHuoNum(ntype,val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_SHENBING_RANK + ntype,val)
end

--获取奇遇多人副本boss刷新时间
function GlobalValue:GetQiYuBossFreshTime(ntype)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_QIYU_BOSS_FRESH_TIME_START + ntype)
end

--设置奇遇多人副本boss刷新时间
function GlobalValue:SetQiYuBossFreshTime(ntype,val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_QIYU_BOSS_FRESH_TIME_START + ntype,val)
end

--获取奇遇多人副本boss id
function GlobalValue:GetQiYuBossId(ntype)
	return self:GetUInt16(GLOBALVALUE_INT_FIELD_QIYU_BOSS_ID_START + ntype,0)
end

--设置奇遇多人副本boss id
function GlobalValue:SetQiYuBossId(ntype,val)
	self:SetUInt16(GLOBALVALUE_INT_FIELD_QIYU_BOSS_ID_START + ntype,0,val)
end

--获取奇遇多人否刷新公告标识
function GlobalValue:GetQiYuBossFreshFlag(ntype)
	return self:GetUInt16(GLOBALVALUE_INT_FIELD_QIYU_BOSS_ID_START + ntype,1)
end

--设置奇遇多人副本是否刷新公告标识
function GlobalValue:SetQiYuBossFreshFlag(ntype,val)
	self:SetUInt16(GLOBALVALUE_INT_FIELD_QIYU_BOSS_ID_START + ntype,1,val)
end

--获取天地灵矿刷新时间
function GlobalValue:GetTianDiLingKuangFreshTime()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_TIANDILINGKUANG_FRESH_TIME)
end

--设置天地灵矿刷新时间
function GlobalValue:SetTianDiLingKuangFreshTime(val)
	--设置各个地图是否第一次刷新标识
	if(self:GetTianDiLingKuangFreshTime() == 0)then
		for i = 1,13 do
			self:SetTianDiLingKuangFirstFlag(i)
		end
	end
	self:SetUInt32(GLOBALVALUE_INT_FIELD_TIANDILINGKUANG_FRESH_TIME,val)
end

--获取天地灵矿各地图第一次是否需要刷新了
function GlobalValue:GetTianDiLingKuangFirstFlag(offset)
	return self:GetBit(GLOBALVALUE_INT_FIELD_TIANDILINGKUANG_FIRST_FLAG,offset)
end

--设置天地灵矿各地图第一次是否需要刷新了
function GlobalValue:SetTianDiLingKuangFirstFlag(offset)
	self:SetBit(GLOBALVALUE_INT_FIELD_TIANDILINGKUANG_FIRST_FLAG,offset)
end

--设置天地灵矿各地图第一次是否需要刷新了
function GlobalValue:UnSetTianDiLingKuangFirstFlag(offset)
	self:UnSetBit(GLOBALVALUE_INT_FIELD_TIANDILINGKUANG_FIRST_FLAG,offset)
end

--获取全服杀怪总数（仅限世界地图）
function GlobalValue:GetWorldKillCreatureNum()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_WORLD_KILL_CREATURE_NUM)
end

--设置全服杀怪总数（仅限世界地图）
function GlobalValue:SetWorldKillCreatureNum(val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_WORLD_KILL_CREATURE_NUM,val)
end

--添加全服杀怪总数（仅限世界地图）
function GlobalValue:AddWorldKillCreatureNum(val)
	self:AddUInt32(GLOBALVALUE_INT_FIELD_WORLD_KILL_CREATURE_NUM,val)
end

--获取某个云游仙人所在地图（仅限世界地图）
function GlobalValue:GetWorldYyxrBossMap(offset)
	local idx = 0
	if(offset >= 4)then
		idx = 1
		offset = offset - 4
	end
	return self:GetByte(GLOBALVALUE_INT_FIELD_WORLD_YYXR_BOSS_MAP_START + idx,offset)
end

--设置某个云游仙人所在地图（仅限世界地图）
function GlobalValue:SetWorldYyxrBossMap(offset,val)
	local idx = 0
	if(offset >= 4)then
		idx = 1
		offset = offset - 4
	end
	self:SetByte(GLOBALVALUE_INT_FIELD_WORLD_YYXR_BOSS_MAP_START + idx,offset,val)
end

--获取当前要刷出的云游仙人uint16 0:所在地图 1:boss模板
function GlobalValue:GetWorldYyxrBossData(offset)
	return self:GetUInt16(GLOBALVALUE_INT_FIELD_WORLD_YYXR_BOSS_MAP_DATA,offset)
end

--设置当前要刷出的云游仙人uint16 0:所在地图 1:boss模板
function GlobalValue:SetWorldYyxrBossData(offset,val)
	self:SetUInt16(GLOBALVALUE_INT_FIELD_WORLD_YYXR_BOSS_MAP_DATA,offset,val)
end

--处理云游仙人相关
function GlobalValue:DoYunYouXianRen(value_map,value_boss,value_rate)
	local need_num = tb_game_set[46].value[1]
	local have_num = self:GetWorldKillCreatureNum()		
	if(have_num < need_num)then
		return--杀怪总数未达到
	end
	--boss
	local boss_entry_table = tb_game_set[47].value
	local total_num = 0
	local need_boss_tb = {}
	local have_map_tb = {}
	local len = #boss_entry_table
	--所有世界地图上的云游仙人数量
	for i = 1,len do
		local cc = self:GetWorldYyxrBossMap(i-1)
		if(cc == 0)then
			table.insert(need_boss_tb,boss_entry_table[i])
		else
			if(have_map_tb[cc] == nil)then
				have_map_tb[cc] = 1
			else
				have_map_tb[cc] = have_map_tb[cc] + 1
			end
			--print("222222222222222222 "..have_map_tb[cc])
			total_num = total_num + 1
		end
	end
	--是否刷新的仙人概率 
	local rate = GetXianRenNewFreshRate( {["count"] = total_num} )
	if(rate <= 0 or randIntD(0,100) > rate or #boss_entry_table <= 0)then
		--没有指定概率
		if(value_rate == nil)then
			return--不用刷了
		end	
	end
	--刷新哪个仙人 已经存在了就不能再刷了
	local rate_boss_idx = randIntD(1,#need_boss_tb)
	local boss_id = need_boss_tb[rate_boss_idx]
	--如果有指定boss
	if(value_boss ~= nil and value_boss ~= 0)then
		boss_id = value_boss
	end
	--刷出在哪里
	local rankLevel_10 = 0--排行榜第10名玩家等级
	local qz_tb = {}
	local total_qz = 0
	for i= 1,#have_map_tb do
		local num = 0
		local open_level = 0
		if(have_map_tb[i] ~= nil)then
			num = have_map_tb[i]
			local yy_data = tb_yunyouxianren[i]
			if(yy_data ~= nil)then
				open_level = yy_data.open_level
			end
		end
		qz_tb[i] = GetXianRenQuanZhong({["rank_lv"]=rankLevel_10,["open_lv"] = open_level,["count"] = num})			
		total_qz = total_qz + qz_tb[i]
	end
	
	local rate_map_tb = {}
	local max_rate = -1
	local max_rate_map_id = randIntD(3,13)--先随机下
	for i = 1,#qz_tb do
		if(qz_tb[i] ~= nil)then
			rate_map_tb[i] = GetXianRenMapFreshRate({["map_qz"]=qz_tb[i], ["total_qz"]=total_qz})
			if(rate_map_tb[i] > max_rate)then
				max_rate = rate_map_tb[i]
				max_rate_map_id = i
			end				
		end
	end
	
	--如果有指定地图
	if(value_map ~= nil and value_map ~= 0)then
		max_rate_map_id = value_map
	end
	
	--设置地图  boss
	self:SetWorldYyxrBossData(0,max_rate_map_id)
	self:SetWorldYyxrBossData(1,boss_id)
	--设置仙人在哪张地图上		
	if(max_rate_map_id > 0 and boss_id > 0)then
		self:SetWorldYyxrBossMap(rate_boss_idx-1,max_rate_map_id)
	end		
end

--根据帮派GUID清理下世界变量下
function GlobalValue:ClearFactionPosFromGuid(faction_guid)
	for i = GLOBALVALUE_STRING_FIELD_FACTION_GUID_1,GLOBALVALUE_STRING_FIELD_FACTION_GUID_3
	do
		local name_index = i - GLOBALVALUE_STRING_FIELD_FACTION_GUID_1 + GLOBALVALUE_STRING_FIELD_FACTION_NAME_1
		if(self:GetStr(i) == faction_guid)then
			self:SetStr(i, "")
			self:SetStr(name_index, "")
			break
		end
	end	
end

--设置帮派大将军上线标志
function GlobalValue:SetFactionManagerOnline(faction_guid)
	local pos = self:GetFactionPosFromGuid(faction_guid)
	if(pos ~= nil)then
		self:SetBit(GLOBALVALUE_INT_FIELD_FLAGS,GLOBALVALUE_FIELD_FLAGS_FACTION_1_ONLINE+pos)
	end
end

--设置帮派大将军下线标志
function GlobalValue:UnSetFactionManagerOnline(faction_guid)
	local pos = self:GetFactionPosFromGuid(faction_guid)
	if(pos ~= nil)then
		self:UnSetBit(GLOBALVALUE_INT_FIELD_FLAGS,GLOBALVALUE_FIELD_FLAGS_FACTION_1_ONLINE+pos)
	end
end

--获取帮派大将军上线标志
function GlobalValue:GetFactionManagerOnline(faction_guid)
	local pos = self:GetFactionPosFromGuid(faction_guid)
	if(pos ~= nil)then
		return self:GetBit(GLOBALVALUE_INT_FIELD_FLAGS,GLOBALVALUE_FIELD_FLAGS_FACTION_1_ONLINE+pos)
	end
	return false
end

--=============================蟠桃园 =================================================
-- 获取蟠桃成熟时间
function GlobalValue:GetPantaoyuanRefreshTm( index)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_PANTAO_TIME_START + index - 1)
end

-- 设置成熟时间
function GlobalValue:SetPantaoyuanRefreshTm( index, val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_PANTAO_TIME_START + index - 1, val)
end

--获取蟠桃园人数
function GlobalValue:GetPantaoyuanNum()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_PANTAO_PLAYER_NUM)
end

--添加蟠桃园人数
function GlobalValue:AddPantaoyuanNum(val)
	self:AddUInt32(GLOBALVALUE_INT_FIELD_PANTAO_PLAYER_NUM ,val)
end

--设置蟠桃园人数
function GlobalValue:SetPantaoyuanNum(val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_PANTAO_PLAYER_NUM,val)
end

--设置蟠桃园人数
function GlobalValue:SubPantaoyuanNum(val)
	self:SubUInt32(GLOBALVALUE_INT_FIELD_PANTAO_PLAYER_NUM,val)
end

-------------------------------挖宝 ---------------------------------------------
-- 获取下一场挖宝时间
function GlobalValue:GetWaBaoNextTime()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_WABAO_NEXT_TIME)
end

-- 设置下一场挖宝时间
function GlobalValue:SetWaBaoNextTime( val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_WABAO_NEXT_TIME, val)
end

-------------------------------红颜-----------------------------
-- 获取红颜美人点赞数
function GlobalValue:GetHongYanDianZanCount(meiren_id)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_DIANZAN + meiren_id * MAX_MEIREN_RENQI_TYPE)
end

-- 增加红颜美人点赞数
function GlobalValue:AddHongYanDianZanCount( meiren_id,val)
	self:AddUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_DIANZAN + meiren_id * MAX_MEIREN_RENQI_TYPE, val)
end

-- 设置红颜美人点赞数
function GlobalValue:SetHongYanDianZanCount( meiren_id,val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_DIANZAN + meiren_id * MAX_MEIREN_RENQI_TYPE, val)
end

-- 获取红颜美人美貌值
function GlobalValue:GetHongYanMeiMao(meiren_id)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_MEIHAO + meiren_id * MAX_MEIREN_RENQI_TYPE)
end

-- 设置红颜美人美貌值
function GlobalValue:SetHongYanMeiMao( meiren_id,val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_MEIHAO + meiren_id * MAX_MEIREN_RENQI_TYPE, val)
end

-- 获取红颜美人结识玩家数
function GlobalValue:GetHongYanJieShiCount(meiren_id)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_JIESHI_COUNT + meiren_id * MAX_MEIREN_RENQI_TYPE)
end

-- 增加红颜美人结识玩家数
function GlobalValue:AddHongYanJieShiCount( meiren_id,val)
	self:AddUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_JIESHI_COUNT + meiren_id * MAX_MEIREN_RENQI_TYPE, val)
end

-- 设置红颜美人结识玩家数
function GlobalValue:SetHongYanJieShiCount( meiren_id,val)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_HONGYAN_MEIREN_RENQI_START + HONGYAN_MEIREN_JIESHI_COUNT + meiren_id * MAX_MEIREN_RENQI_TYPE, val)
end

----------------风流镇酒馆------------------------------------
--获取风流镇酒馆武将id
function GlobalValue:GetFengLiuZhenPubWuJiangId(off)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ID_START + off)
end

--设置风流镇酒馆武将id
function GlobalValue:SetFengLiuZhenPubWuJiangId(off,value)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ID_START + off,value)
end

--获取风流镇酒馆武将留存时间
function GlobalValue:GetFengLiuZhenPubWuJiangStayTime(off)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_TIME_START + off)
end

--设置风流镇酒馆武将留存时间
function GlobalValue:SetFengLiuZhenPubWuJiangStayTime(off,value)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_TIME_START + off,value)
end

--获取风流镇酒馆武将最高竞拍价格
function GlobalValue:GetFengLiuZhenPubWuJiangHighPrice(off)
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_HIGH_PRICE_START + off)
end

--设置风流镇酒馆武将最高竞拍价格
function GlobalValue:SetFengLiuZhenPubWuJiangHighPrice(off,value)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_HIGH_PRICE_START + off,value)
end

--增加风流镇酒馆武将最高竞拍价格
function GlobalValue:AddFengLiuZhenPubWuJiangHighPrice(off,value)
	self:AddUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_HIGH_PRICE_START + off,value)
end

--获取风流镇酒馆武将是否已招募（0-9）
function GlobalValue:GetFengLiuZhenPubWuJiangIsZhaoMu(off)
	return self:GetBit(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ZHAOMU_FLAG,off)
end

--设置风流镇酒馆武将是否已招募（0-9）
function GlobalValue:SetFengLiuZhenPubWuJiangIsZhaoMu(off)
	self:SetBit(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ZHAOMU_FLAG,off)
end

--撤销设置风流镇酒馆武将是否已招募（0-9）
function GlobalValue:UnSetFengLiuZhenPubWuJiangIsZhaoMu(off)
	self:UnSetBit(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ZHAOMU_FLAG,off)
end

--获取风流镇酒馆武将是否机器人竞拍（10-19）
function GlobalValue:GetFengLiuZhenPubWuJiangIsRobatAuction(off)
	return self:GetBit(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ZHAOMU_FLAG,off + 10)
end

--设置风流镇酒馆武将是否机器人竞拍（10-19）
function GlobalValue:SetFengLiuZhenPubWuJiangIsRobatAuction(off)
	self:SetBit(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ZHAOMU_FLAG,off + 10)
end

--撤销设置风流镇酒馆武将是否机器人竞拍（10-19）
function GlobalValue:UnSetFengLiuZhenPubWuJiangIsRobatAuction(off)
	self:UnSetBit(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_WUJIANG_ZHAOMU_FLAG,off + 10)
end

--获取风流镇酒馆武将最高竞拍者guid
function GlobalValue:GetFengLiuZhenPubWuJiangHighPriceGuid(off)
	return self:GetStr(GLOBALVALUE_STRING_FIELD_FENGLIUZHEN_PUB_WUJIANG_HIGH_GUID_START + off)
end

--设置风流镇酒馆武将最高竞拍者guid
function GlobalValue:SetFengLiuZhenPubWuJiangHighPriceGuid(off,value)
	self:SetStr(GLOBALVALUE_STRING_FIELD_FENGLIUZHEN_PUB_WUJIANG_HIGH_GUID_START + off,value)
end

--获取风流镇酒馆武将最高竞拍者名字
function GlobalValue:GetFengLiuZhenPubWuJiangHighPriceName(off)
	return self:GetStr(GLOBALVALUE_STRING_FIELD_FENGLIUZHEN_PUB_WUJIANG_HIGH_NAME_START + off)
end

--设置风流镇酒馆武将最高竞拍者名字
function GlobalValue:SetFengLiuZhenPubWuJiangHighPriceName(off,value)
	self:SetStr(GLOBALVALUE_STRING_FIELD_FENGLIUZHEN_PUB_WUJIANG_HIGH_NAME_START + off,value)
end

--获取风流镇酒馆刷新时间
function GlobalValue:GetFengLiuZhenPubWuJiangFreshTime()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_FRESH_TIME)
end
--设置风流镇酒馆刷新时间
function GlobalValue:SetFengLiuZhenPubWuJiangFreshTime(value)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_FRESH_TIME,value)
end

------------------------============================ 风流镇酒馆动态信息前20条 ==========================================
--信息个数加1
function GlobalValue:NextFengLiuZhenPubEvent()
	local cur_num = self:GetFengLiuZhenPubEventCount()
	if(cur_num >= MAX_FENGLIUZHEN_PUB_EVENT-1)then--最多保留 MAX_FENGLIUZHEN_PUB_EVENT
		self:SetFengLiuZhenPubEventCount(0)	
	else
		self:AddFengLiuZhenPubEventCount(1)
	end
end

--信息int开始下标
function GlobalValue:FengLiuZhenPubEventStart()
	return GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_EVENT_INFO_START + self:GetFengLiuZhenPubEventCount() * MAX_FENGLIUZHEN_PUB_EVENT_INT_FIELD
end

--信息str开始下标
function GlobalValue:FengLiuZhenPubEventStrStart()
	return GLOBALVALUE_STRING_FIELD_FENGLIUZHEN_PUB_EVENT_INFO_START + self:GetFengLiuZhenPubEventCount() * MAX_FENGLIUZHEN_PUB_EVENT_STR_FIELD
end

--获得信息当前索引
function GlobalValue:GetFengLiuZhenPubEventCount()
	return self:GetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_EVENT_INFO_INDEX)
end

--设置信息当前索引
function GlobalValue:SetFengLiuZhenPubEventCount(value)
	self:SetUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_EVENT_INFO_INDEX,value)
end

--增加信息当前索引
function GlobalValue:AddFengLiuZhenPubEventCount(value)
	self:AddUInt32(GLOBALVALUE_INT_FIELD_FENGLIUZHEN_PUB_EVENT_INFO_INDEX,value)
end

--获得当前信息类型
function GlobalValue:GetFengLiuZhenPubEventType()
	return self:GetByte(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_TYPE,0)
end

--设置当前信息类型
function GlobalValue:SetFengLiuZhenPubEventType(value)
	self:SetByte(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_TYPE,0,value)
end

--获得当前信息武将模板id
function GlobalValue:GetFengLiuZhenPubEventWujiangId()
	return self:GetUInt32(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_WUJIANG_ID)
end

--设置当前信息武将模板id
function GlobalValue:SetFengLiuZhenPubEventWujiangId(value)
	self:SetUInt32(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_WUJIANG_ID,value)
end

--获得当前信息花费
function GlobalValue:GetFengLiuZhenPubEventCost()
	return self:GetUInt32(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_COST)
end
--设置当前信息花费
function GlobalValue:SetFengLiuZhenPubEventCost(value)
	self:SetUInt32(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_COST,value)
end

--获得当前信息时间
function GlobalValue:GetFengLiuZhenPubEventTime()
	return self:GetUInt32(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_TIME)
end
--设置当前信息时间
function GlobalValue:SetFengLiuZhenPubEventTime(value)
	self:SetUInt32(self:FengLiuZhenPubEventStart() + FENGLIUZHEN_PUB_EVENT_INT_FIELD_TIME,value)
end

--获得当前信息玩家guid
function GlobalValue:GetFengLiuZhenPubEventPlayerGuid()
	return self:GetStr(self:FengLiuZhenPubEventStrStart() + FENGLIUZHEN_PUB_EVENT_STR_FIELD_PLAYER_GUID)
end
--设置当前信息玩家guid
function GlobalValue:SetFengLiuZhenPubEventPlayerGuid(value)
	self:SetStr(self:FengLiuZhenPubEventStrStart() + FENGLIUZHEN_PUB_EVENT_STR_FIELD_PLAYER_GUID,value)
end

--获得当前信息玩家名字
function GlobalValue:GetFengLiuZhenPubEventPlayerName()
	return self:GetStr(self:FengLiuZhenPubEventStrStart() + FENGLIUZHEN_PUB_EVENT_STR_FIELD_PLAYER_NAME)
end

--设置当前信息玩家名字
function GlobalValue:SetFengLiuZhenPubEventPlayerName(value)
	self:SetStr(self:FengLiuZhenPubEventStrStart() + FENGLIUZHEN_PUB_EVENT_STR_FIELD_PLAYER_NAME,value)
end

--添加一个信息
function GlobalValue:AddFengLiuZhenPubEvent(event_type,wujiang_id,p_guid,p_name,cost)
	self:SetFengLiuZhenPubEventType(event_type)
	self:SetFengLiuZhenPubEventWujiangId(wujiang_id)
	self:SetFengLiuZhenPubEventTime(os.time())
	if(p_guid)then
		self:SetFengLiuZhenPubEventPlayerGuid(p_guid)
		self:SetFengLiuZhenPubEventPlayerName(p_name)
		self:SetFengLiuZhenPubEventCost(cost)
	end
	self:NextFengLiuZhenPubEvent()
end	

----------------================风流镇酒馆动态信息结束=====================------------------------

--获取风流镇主考官考试开始时间
function GlobalValue:getFengLiuZhenExamStartTime()
	return self:GetUInt32(GLOBALVALUE_INT_FENGLIUZHEN_EXAM_START_TIME)
end
--设置风流镇主考官考试开始时间
function GlobalValue:setFengLiuZhenExamStartTime(value)
	return self:SetUInt32(GLOBALVALUE_INT_FENGLIUZHEN_EXAM_START_TIME,value)
end
	

------------------------------------------------------------------------

function GlobalValue:DoFactionGlobalCheck(faction_guid)
	if(self:GetFactionPosFromGuid(faction_guid) == nil)then
		--判断下帮派是否存在
		local faction = app.objMgr:getObj(faction_guid)
		if(faction ~= nil)then
			self:SetFactionPosFromGuid(faction:GetGuid(),faction:GetName())
		end
	end
end


-- 通过配置表获取每天下一场时间点（config为每日活动开始时间点，durTime为持续时间 单位：s）
function GetNextActiveStartTimeEveryDay(config, durTime)
	if (config == nil or #config < 1) then
		return
	end
	if durTime == nil then
		durTime = 0
	end
	local tTime = os.date("*t")
	local curTime = os.time()
	local nFirstTime = tTime
	for i=1, #config do
		tTime.hour = config[i].h
		tTime.min = config[i].m
		tTime.sec = config[i].s
		local nTime = os.time(tTime)
		-- 当前时间小于这一场时间 + 持续时间
		if (curTime < nTime + durTime) then
			return nTime, i
		end
		if (i == 1) then
			nFirstTime = nTime
		end
	end
	-- 取明天第一场时间
	nFirstTime = nFirstTime + 86400
	local nIndex = #config+1
	
	return  nFirstTime, nIndex
end

return GlobalValue
