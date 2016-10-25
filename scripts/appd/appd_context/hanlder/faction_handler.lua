--创建帮派
function PlayerInfo:Handle_Faction_Create( pkt )
	local name = pkt.name
	
	local faction_guid = self:GetFactionId()
	if faction_guid ~= "" then
		print("already created faction = "..faction_guid)
		return
	end

	local name_tab = lua_string_split(self:GetName(), ',')
	local faction_name = string.format("%s,%s,%s", name_tab[1], name_tab[2], name)
	local server_name = string.format("%s_%s", name_tab[1], name_tab[2])

	-- local reserve = pkt.reserve

	--[[
	local config = tb_bangpai[1]
	--判断创建帮派等级
	if self:GetLevel() < config.need_level then
		self:CallOptResult(OPRATE_TYPE_FACTION, OPRATE_TYPE_FACTION_LEVEL_LACK)
		return
	end
	--玩家已经有帮派了
	if self:GetFactionId() ~= "" then
		self:CallOptResult(OPRATE_TYPE_FACTION, OPRATE_TYPE_FACTION_IS_HAVE)
		return
	end
	
	-- 玩家名字不能是空的
	if self:GetName() == "" then
		self:CallOptResult(OPRATE_TYPE_FACTION, OPRATE_TYPE_FACTION_PLAYER_NAME_ERR)
		return
	end
	
	--帮派名称不能为空 帮派名称不能超过6个中文字符
	if name == "" or string.len(name) > 12 then
		self:CallOptResult(OPRATE_TYPE_FACTION, OPRATE_TYPE_FACTION_NAME_ERR)
		return
	end
	
	--判断是否有屏蔽词
	local name = fuckPingBi(pkt.name)
	if name ~= pkt.name then
		self:CallOptResult(OPRATE_TYPE_FACTION, OPRATE_TYPE_FACTION_NAME_HAVE_FUCK)
		return
	end
	
	
	--判断帮派名字是否重复
	local name_tab = lua_string_split(self:GetName(), ',')
	local faction_name = string.format("%s,%s,%s", name_tab[1], name_tab[2], name)
	local server_name = string.format("%s_%s", name_tab[1], name_tab[2])
	local bRepeat = false
	app.objMgr:foreachAllFaction(function(faction)
		if faction:GetName() == faction_name then
			bRepeat = true
			return true
		end
	end)

	if bRepeat then
		self:CallOptResult(OPRATE_TYPE_FACTION, OPRATE_TYPE_FACTION_NAME_REPEAT)
		return
	end
	--判断帮派数量上限
	local faction_num = 0
	app.objMgr:foreachAllFaction(function(faction)
		faction_num = faction_num + 1
	end)
	if faction_num >= config.num_bangpai then
		self:CallOptResult(OPRATE_TYPE_FACTION, OPEATE_TYPE_FACTION_CREATE_MAX)
		return
	end
	
	--判断消耗
	local cost_table = tb_bangpai_cost[2].cost
	local faction_lv = 2	--初始帮派等级
	if reserve == 1 then
		cost_table = tb_bangpai_cost[1].cost
		faction_lv = 1
	end
	if not self:SubItemByConfig(cost_table,MONEY_CHANGE_CREATE_FACTION,OPRATE_TYPE_FACTION,OPEATE_TYPE_FACTION_MONEY_ERR,nil,OPEATE_TYPE_FACTION_ITEM_ERR) then
		return
	end
	]]
	-- 获取guid
	local new_guid = guidMgr:Make_New_Guid(guidMgr.ObjectTypeFaction, guidMgr:NewIndex(guidMgr.ObjectTypeFaction), server_name)
	--local events_guid = guidMgr.replace(new_guid, guidMgr.ObjectTypeFactionEvents)
	local faction = app.objMgr:newAndCallPut(new_guid, FACTION_BINLOG_OWNER_STRING)
	if(not faction)then
		return
	end
	--[[
	local faction_events = app.objMgr:newAndCallPut(events_guid, 'faction_events')
	if(not faction_events)then
		return
	end
	]]
	local faction_lv = 1

	faction:SetName(faction_name)
	faction:SetFactionLevel(faction_lv)

	--[[
	if not faction:MemberAdd(self) then
		guidMgr:callRemoveObject(new_guid)
		--guidMgr:callRemoveObject(events_guid)
		self:SetFactionId("")
		self:SetFactionName("")
		return
	end
	]]

	--下发binlog给客户端
	app.objMgr:callAddWatch(self:GetSessionId(), new_guid)
	self:SetFactionId(new_guid)
	print("faction created = "..new_guid)

	--app.objMgr:callAddWatch(self:GetSessionId(), events_guid)
	--[[
	--登录服也监听下
	app.objMgr:callAddWatch(serverConnList:getLogindFD(), new_guid)
	app.objMgr:callAddWatch(serverConnList:getLogindFD(), events_guid)
	--通知场景服监听
	serverConnList:forEachScenedFD(function (fd)
		app.objMgr:callAddWatch(fd, new_guid)
		app.objMgr:callAddWatch(fd, events_guid)
	end)
	]]
end

-- 升级
function PlayerInfo:Handle_Faction_Upgrade(pkt)
	local faction_guid = self:GetFactionId()
	if faction_guid == "" then
		print("Handle_Faction_Upgrade with no faction = ")
		return
	end
	local faction = app.objMgr:getObj(faction_guid)
	if faction then
		faction:FactionLevelUp(self)
	end
end

--获取帮派列表
function PlayerInfo:Handle_Faction_Get_List( pkt )
	local start, t_end = pkt.start, pkt.t_end
	local faction_num = 0
	local results = {}	
	for i = start,t_end do
		app.objMgr:foreachAllFaction(function(faction)
			if i == faction:GetFactionRank() then
				local list = faction_info_t:new 
					{	
						faction_name = faction:GetName(),
						bangzhu_name = faction:GetBangZhuName(), 
						level 		 = faction:GetFactionLevel(), 
						player_count = faction:GetMemberCount(), 
						force 		 = faction:GetFactionForce(),
						faction_guid = faction:GetGuid()
					}
				table.insert(results, list)
				faction_num = faction_num + 1
				return
			end
		end)
	end
	-- 下发给客户端
	self:call_faction_get_list_result(results, faction_num)
end

--帮派申请
function PlayerInfo:Hanlde_Faction_Apply( pkt )
	local faction_guid = self:GetFactionId()
	if faction_guid ~= "" then
		print("you cannot join other, have faction = "..faction_guid)
		return
	end

	local faction = app.objMgr:getObj(pkt.id)   --帮派guid
	if faction then
		app.objMgr:callAddWatch(self:GetSessionId(), pkt.id)
		self:SetFactionId(pkt.id)
		print("you have joined faction = "..pkt.id)
		--[[
		if faction:GetFactionFlags(FACTION_FLAGS_AUTO) then
			faction:MemberAdd(self)
		else
			faction:FactionApply(self)
		end
		]]
	end	
end

--退出帮派
function PlayerInfo:Handle_Faction_Quit( pkt )
	local faction_guid = self:GetFactionId()
	if faction_guid == "" then
		return
	end
	local faction = app.objMgr:getObj(faction_guid)
	if faction then
		faction:FactionQuit(self)
	end
end

--帮派管理
function PlayerInfo:Hanlde_Faction_Manager( pkt )
	local faction_guid = self:GetFactionId()
	if faction_guid == "" then
		return
	end
	local faction = app.objMgr:getObj(faction_guid)
	if faction == nil then
		return
	end
	
	local opt_type = pkt.opt_type			--操作类型
	local reserve_int1 = pkt.reserve_int1   --预留int值1*/
	local reserve_int2 = pkt.reserve_int2   --预留int值2*/
	local reserve_str1 = pkt.reserve_str1   --预留string值1*/
	local reserve_str2 = pkt.reserve_str2   --预留string值2*/
	
	--同意加入帮派
	if opt_type == FACTION_MANAGER_TYPE_AGREE_JOIN then
		faction:FactionAgreeJoin(self,reserve_str1)
	--拒绝加入帮派
	elseif opt_type == FACTION_MANAGER_TYPE_REFUSE_JOIN then
		faction:FactionRefuseJoin(self,reserve_str1)
	--踢出帮派	
	elseif opt_type == FACTION_MANAGER_TYPE_KICK then
		faction:MemberKicked(self, reserve_str1)
	--职位任免	
	elseif opt_type == FACTION_MANAGER_TYPE_APPOINT then
		faction:FactionAppoint(self, reserve_str1,reserve_int1)	
	--勾选“不需审核”
	elseif opt_type == FACTION_MANAGER_TYPE_NO_REVIEW then
		faction:FactionReview(self, reserve_int1)	
	--	帮派升级
	elseif opt_type == FACTION_MANAGER_TYPE_LEVEL_UP then
		faction:FactionLevelUp(self)	
	--	替换帮旗
	elseif opt_type == FACTION_MANAGER_TYPE_CHANGE_FLAGS then
		faction:FactionChangeFlags(self,reserve_int1)		
	--帮会公告	
	elseif opt_type == FACTION_MANAGER_TYPE_NOTICE then	
		faction:FactionNotice(self,reserve_str1)		
	end
	
end

--帮众操作
function PlayerInfo:Handle_Faction_People( pkt )
	local faction_guid = self:GetFactionId()
	if faction_guid == "" then
		return
	end
	local faction = app.objMgr:getObj(faction_guid)
	if faction == nil then
		return
	end
	
	local pos = faction:FindPlayerIndex(self:GetGuid())
	if pos == nil then return end
	
	local opt_type = pkt.opt_type			--操作类型
	local reserve_int1 = pkt.reserve_int1   --预留int值1*/
	local reserve_int2 = pkt.reserve_int2   --预留int值2*/
	local reserve_str1 = pkt.reserve_str1   --预留string值1*/
	local reserve_str2 = pkt.reserve_str2   --预留string值2*/
	
	--捐献
	if opt_type == FACTION_MANAGER_TYPE_JUANXIAN then
		faction:FactionJuanXian(self,pos,reserve_int1,reserve_int2)
	--领取福利	
	elseif opt_type == FACTION_MANAGER_TYPE_FULI then
		faction:FactionFuLi(self,pos)
	--发红包	
	elseif opt_type == FACTION_MANAGER_TYPE_FA_HONGBAO then
		faction:FactionFaHongBao(self,reserve_int1,reserve_int2)
	--领取红包	
	elseif opt_type == FACTION_MANAGER_TYPE_LQ_HONGBAO then	
		faction:FactionLqHongBao(self,pos)
	--上香	
	elseif opt_type == FACTION_MANAGER_TYPE_SHANGXIANG then	
		faction:FactionShangXiang(self,pos,reserve_int1)
	end
	
	
end

