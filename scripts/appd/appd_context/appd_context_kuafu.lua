-- 定时器的检测跨服匹配情况
function PlayerInfo:QueryKuafuMatchInfo()
	self:OnCheckWorld3v3Match()
end

function PlayerInfo:OnCheckWorld3v3Match()
	-- 匹配的不是3v3
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_FENGLIUZHEN) then
		return
	end
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/check_match"
	local data = {}
	-- 这里获得3v3队伍匹配的信息
	data.player_guid = self:GetGuid()
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		
		local dict = json.decode(response)
		if dict then
			print(dict.ret, dict.msg)
			-- 匹配到了
			if dict.ret == 0 then
				local scened_fd = serverConnList:getLogindFD()
				local guid = self:GetGuid()
				-- dict.enter_info = json.decode(dict.enter_info)
				local enter_info = dict.enter_info
				local pos = enter_info.pos
				local war_id = enter_info.war_id
				local battle_server = enter_info.battle_server
				call_appd_login_to_send_kuafu_info(scened_fd, guid, war_id, pos, battle_server)
				-- 已经匹配到了
				app:SetMatchingKuafuType(self:GetGuid(), nil)
			elseif dict.ret == 2 then
				if dict.msg == "cancel" then
					-- timeout取消匹配
					app:SetMatchingKuafuType(self:GetGuid(), nil)
				end
			end
		end
	end)
end


-- 人物离线取消所有匹配
function PlayerInfo:OnCancelKuafuMatch()
	self:OnCancelWorld3v3MatchBeforeOffline()
end

-- 取消匹配3v3
function PlayerInfo:OnCancelWorld3v3MatchBeforeOffline()
	-- 匹配的不是3v3
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_FENGLIUZHEN) then
		return
	end
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/cancel_match"
	local data = {}
	data.player_guid = self:GetGuid()
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		app:SetMatchingKuafuType(self:GetGuid(), nil)
	end)
end

-- 单人匹配3v3
function PlayerInfo:OnWorld3v3Match()
	-- 已经在匹配其他了
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		return
	end
	app.world_3v3_team_dict[self:GetGuid()] = {self:GetGuid()}
	app.world_3v3_player_team[self:GetGuid()] = self:GetGuid()
	self:OnWorld3v3GroupMatch()
end

-- 队伍匹配3v3

function PlayerInfo:OnWorld3v3GroupMatch()
	-- 队长才能进行匹配, 不是的不让进
	local group_guid = self:GetGuid()
	if app.world_3v3_player_team[self:GetGuid()] ~= group_guid then
		return
	end
	
	-- 已经在匹配其他了
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		return
	end
	
	local teamdict = {}
	table.insert(teamdict, string.format("%s,%d", self:GetGuid(), self:GetWorld3v3MatchValue()))
	
	local group_info = app.world_3v3_team_dict[group_guid]
	for i = 2, #group_info do
		local player_guid = group_info[ i ]
		local player = app.objMgr:getObj(player_guid)
		table.insert(teamdict, string.format("%s,%d", player:GetGuid(), player:GetWorld3v3MatchValue()))
	end
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/match"
	local data = {}
	data.group_guid = group_guid
	data.open_time = 1
	data.team_info = string.join(",", teamdict)
	
	app:SetMatchingKuafuType(self:GetGuid(), KUAFU_TYPE_FENGLIUZHEN)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		local dict = json.decode(response)
		print(dict.ret, dict.msg)
	end)
end