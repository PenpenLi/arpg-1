--角色登录 帮派处理
function PlayerInfo:factionLogin()
	local factionID = self:GetFactionId()
	if factionID ~= "" then
		local faction = app.objMgr:getObj(factionID)
		if faction then
			local player_guid = self:GetGuid()
			local index = faction:FindPlayerIndex(player_guid)
			if index == nil then
				self:clearFaction()
			else 
				faction:SetFactionMemberIsOnline(index,1)
				faction:SetFactionMemberLogoutTime(index,0)
			end
		else
			self:clearFaction()
		end
	end
end
--角色退出 帮派处理
function PlayerInfo:factionLogOut()
	local factionID = self:GetFactionId()
	if factionID ~= "" then
		local faction = app.objMgr:getObj(factionID)
		if faction then
			local player_guid = self:GetGuid()
			local index = faction:FindPlayerIndex(player_guid)
			if index ~= nil then
				faction:SetFactionMemberIsOnline(index,0)
				faction:SetFactionMemberLogoutTime(index,os.time())
			end
		end
	end
end
--清理角色帮派信息
function PlayerInfo:clearFaction()
	self:SetFactionId("")
	self:SetFactionName("")
end
--创建帮派
function PlayerInfo:Handle_Faction_Create( pkt )
	local name = pkt.name
	local icon = pkt.icon
	--print(name,"*",#name)
	outFmtDebug("Handle_Faction_Create")
	
	--玩家已经有帮派了
	if self:GetFactionId() ~= "" then
		self:CallOptResult(OPERTE_TYPE_FACTION, OPERTE_TYPE_FACTION_IS_HAVE)
		return
	end

	
	local config = tb_faction_creat[1]

	
	-- 玩家名字不能是空的
	if self:GetName() == "" then
		--self:CallOptResult(OPRATE_TYPE_FACTION, OPRATE_TYPE_FACTION_PLAYER_NAME_ERR)
		outFmtInfo("user name null")
		return
	end
	
	--帮派名称不能为空 帮派名称不能超过6个中文字符

	if name == "" or string.len(name) > 18 then
		self:CallOptResult(OPERTE_TYPE_FACTION, OPERTE_TYPE_FACTION_NAME_ERR)
		return
	end
	
	--判断是否有屏蔽词
	local name = fuckPingBi(pkt.name)
	if name ~= pkt.name then
		self:CallOptResult(OPERTE_TYPE_FACTION, OPERTE_TYPE_FACTION_NAME_HAVE_FUCK)
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
		self:CallOptResult(OPERTE_TYPE_FACTION, OPERTE_TYPE_FACTION_NAME_REPEAT)
		return
	end
	--判断帮派数量上限
	local faction_num = 0
	app.objMgr:foreachAllFaction(function(faction)
		faction_num = faction_num + 1
	end)
	if faction_num >= config.maxnum then
		self:CallOptResult(OPERTE_TYPE_FACTION, OPRATE_TYPE_FACTION_CREATE_MAX)
		return
	end
	

	--扣除相应资源 + 祝福值
	 if not self:costMoneys(MONEY_CHANGE_CREATE_FACTION,config.cost) then
	 	self:CallOptResult(OPERTE_TYPE_FACTION, OPERTE_TYPE_FACTION_CREATE_COST)
		return
	 end

	-- 获取guid
	local new_guid = guidMgr:Make_New_Guid(guidMgr.ObjectTypeFaction, guidMgr:NewIndex(guidMgr.ObjectTypeFaction), server_name)
	local faction = app.objMgr:newAndCallPut(new_guid, FACTION_BINLOG_OWNER_STRING)
	if(not faction)then
		return
	end

	local faction_lv = 1

	faction:SetName(faction_name)
	faction:SetFactionLevel(faction_lv)
	faction:SetBangZhuName(self:GetName())
	faction:SetFactionCurFlagId(icon)

	if not faction:MemberAdd(self) then
		guidMgr:callRemoveObject(new_guid)
		self:SetFactionId("")
		self:SetFactionName("")
		return
	end
	
	faction:RefreshShop()
	
	--登录服也监听下
	app.objMgr:callAddWatch(serverConnList:getLogindFD(), new_guid)
	--通知场景服监听
	serverConnList:forEachScenedFD(function (fd)
		app.objMgr:callAddWatch(fd, new_guid)
	end)
	
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
	local page, num,grep = pkt.page, pkt.num,pkt.grep 
	local lev = 0
	--outFmtDebug("self grep %d",grep)
	if grep == 1 then
		lev = self:GetLevel()
		--outFmtDebug("self level: %d",lev)
	end
	playerLib.FastGetFactionList(self:GetGuid(),page,num,lev)
	
end

--快速加入帮派
function PlayerInfo:Handle_Faction_FastJoin(pkt)
	print("Handle_Faction_FastJoin")
	local flag = true
	app.objMgr:foreachAllFaction(function(faction)
		
		if faction:GetFactionFlags(FACTION_FLAGS_AUTO) then
			local faclev = faction:GetFactionMinLev()
			if faclev > 0 then
				local lev = self:GetLevel()
				if lev >= faclev then
					flag = false
					return faction:MemberAdd(self)
				end
			else
				flag = false
				return faction:MemberAdd(self)
			end
		end
			
		
	end)
	
	if flag then
		self:CallOptResult(OPERTE_TYPE_FACTION, OPEATE_TYPE_FACTION_NOT_JOIN)
	end
	
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
		if self:GetLevel() < faction:GetFactionMinLev() then
			--玩家等级不够
			self:CallOptResult(OPERTE_TYPE_FACTION, OPERTE_TYPE_FACTION_LEV_LOW)
			return 
		end

		if faction:GetFactionFlags(FACTION_FLAGS_AUTO) then
			faction:MemberAdd(self)
		else
			faction:FactionApply(self)
		end
		
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
	--招募设置
	elseif opt_type == FACTION_MANAGER_TYPE_RECRUIT then
		faction:FactionRecruit(self, reserve_int1,reserve_int2,reserve_str1)
	--	帮派升级
	elseif opt_type == FACTION_MANAGER_TYPE_LEVEL_UP then
		faction:FactionLevelUp(self)	
	--	替换帮旗
	elseif opt_type == FACTION_MANAGER_TYPE_CHANGE_FLAGS then
		--faction:FactionChangeFlags(self,reserve_int1)		
	--帮会公告	
	elseif opt_type == FACTION_MANAGER_TYPE_NOTICE then	
		faction:FactionNotice(self,reserve_str1)		
	end
	
end

--帮众操作
function PlayerInfo:Handle_Faction_People( pkt )
	--outFmtDebug("juanxian")
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
		--faction:RefreshShop()
	--领取福利	
	elseif opt_type == FACTION_MANAGER_TYPE_FULI then
		--faction:FactionFuLi(self,pos)
	--发红包	
	elseif opt_type == FACTION_MANAGER_TYPE_FA_HONGBAO then
		--faction:FactionFaHongBao(self,reserve_int1,reserve_int2)
	--领取红包	
	elseif opt_type == FACTION_MANAGER_TYPE_LQ_HONGBAO then	
		--faction:FactionLqHongBao(self,pos)
	--上香	
	elseif opt_type == FACTION_MANAGER_TYPE_SHANGXIANG then	
		--faction:FactionShangXiang(self,pos,reserve_int1)
	--
	elseif opt_type == FACTION_MANAGER_TYPE_SHOP then
		faction:ShopItem(self,reserve_int1,reserve_int2)
	end
	
	
end

