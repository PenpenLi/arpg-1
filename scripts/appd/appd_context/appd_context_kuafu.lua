-- ��ʱ���ļ����ƥ�����
function PlayerInfo:QueryKuafuMatchInfo()
	self:OnCheckWorld3v3Match()
end

function PlayerInfo:OnCheckWorld3v3Match()
	-- ƥ��Ĳ���3v3
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_FENGLIUZHEN) then
		return
	end
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/check_match"
	local data = {}
	-- ������3v3����ƥ�����Ϣ
	data.player_guid = self:GetPlayerMatchKey()
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		
		local dict = json.decode(response)
		if dict then
			print(dict.ret, dict.msg)
			-- ƥ�䵽��
			if dict.ret == 0 then
				local login_fd = serverConnList:getLogindFD()
				local guid = self:GetGuid()
				-- dict.enter_info = json.decode(dict.enter_info)
				local enter_info = dict.enter_info
				if type(enter_info) == "string" then
					enter_info = json.decode(enter_info)
				end
				local pos = enter_info.pos
				local war_id = enter_info.war_id
				local battle_server = enter_info.battle_server
				call_appd_login_to_send_kuafu_info(login_fd, guid, war_id, pos, battle_server)
				-- �Ѿ�ƥ�䵽��
				app:SetMatchingKuafuType(self:GetGuid(), nil)
				
				-- ���ӽ������
				local instMgr = self:getInstanceMgr()
				instMgr:add3v3EnterTimes()
			-- timeoutȡ��ƥ��
			elseif dict.ret == 2 then
				self:OnCancelMatch()
			-- ����δ׼����
			elseif dict.ret == 3 then
				self:SomeOneDeclineMatch()
			-- ׼�����
			elseif dict.ret == 4 then
				local wait_info = dict.wait_info
				if type(wait_info) == "string" then
					wait_info = json.decode(wait_info)
				end
				self:OnSendWaitInfo(wait_info)
			end
		end
	end)
end


-- ��������ȡ������ƥ��
function PlayerInfo:OnCancelKuafuMatch()
	self:OnCancelWorld3v3MatchBeforeOffline()
end

-- ȡ��ƥ��3v3
function PlayerInfo:OnCancelWorld3v3MatchBeforeOffline()
	-- ƥ��Ĳ���3v3
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_FENGLIUZHEN) then
		return
	end
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/cancel_match"
	local data = {}
	data.player_guid = self:GetPlayerMatchKey()
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("cancel_match response = ", response)
		self:OnCancelMatch()
	end)
end

-- ����ƥ��3v3
function PlayerInfo:OnWorld3v3Match()
	-- �Ѿ���ƥ��������
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		return false
	end
	app.world_3v3_team_dict[self:GetGuid()] = {self:GetGuid()}
	app.world_3v3_player_team[self:GetGuid()] = self:GetGuid()
	return self:OnWorld3v3GroupMatch()
end

-- ����ƥ��3v3

function PlayerInfo:OnWorld3v3GroupMatch()
	-- �ӳ����ܽ���ƥ��, ���ǵĲ��ý�
	local group_guid = self:GetGuid()
	if app.world_3v3_player_team[self:GetGuid()] ~= group_guid then
		return false
	end
	
	-- �Ѿ���ƥ��������
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		return false
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
	data.group_guid = self:GetPlayerMatchKey()
	data.open_time = 1
	data.team_info = string.join(",", teamdict)
	
	app:SetMatchingKuafuType(self:GetGuid(), KUAFU_TYPE_FENGLIUZHEN)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		local dict = json.decode(response)
		if dict then
			print(dict.ret, dict.msg)
		end
	end)
	
	return true
end

-- ���н������
function PlayerInfo:CheckMatchReward()
	-- ��������
	local isPkServer = globalGameConfig:IsPKServer()
	if isPkServer then
		return
	end
	
	self:CheckWorld3v3Reward()
end

-- �����3v3����
function PlayerInfo:CheckWorld3v3Reward()
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/check_match_result"
	local data = {}
	data.player_guid = self:GetGuid()
	data.open_time = 1
	
	local askguid = self:GetGuid()
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		local dict = json.decode(response)
		if dict then
			print(dict.ret, dict.msg, askguid)
			
			if dict.ret == 0 then
				local data = dict.details
				if type(data) == "string" then
					data = json.decode(data)
				end
				self:AddKuafu3v3Score(data.score)
				-- data.honor
				if data.result == 1 then
					self:Kuafu3v3Win()
				elseif data.result == -1 then
					self:Kuafu3v3Lose()
				else
					self:SetKuafu3v3TrendInfo(0)
				end
			end
		end
		
	end)
end


function PlayerInfo:World3v3Rank()
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/rank"
	
	local data = {}
	data.player_name = self:GetName()
	data.avatar = self:GetAvatar()
	data.weapon = self:GetWeapon()
	data.divine = self:GetDivine()
	data.score = self:GetKuafu3v3Score()
	
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("response = ", response)
		local dict = json.decode(response)
		if dict then
			print(dict.ret, dict.msg)
		end
		
	end)
end

-- ��������
function UpdateKuafuRank()
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/check_rank"
	
	local data = {}
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		local dict = json.decode(response)
		if dict then
			print(dict.ret, dict.msg)
			if type(dict.details) == "string" then
				dict.details = json.decode(dict.details)
			end
			app.kuafu_rank = dict.details
		end
		
	end)
end

-- ׼������
function PlayerInfo:OnPrepareMatch(oper)
	print("OnPrepareMatch ", oper)
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/prepare_match"
	
	local data = {}
	data.player_guid = self:GetPlayerMatchKey()
	data.oper = oper
	
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("response = ", response)
		local dict = json.decode(response)
		if dict then
			print(dict.ret, dict.msg)
		
			if dict.ret == 0 then
				local wait_info = dict.wait_info
				if type(wait_info) == "string" then
					wait_info = json.decode(wait_info)
				end
				self:OnSendWaitInfo(wait_info)
			-- ȡ���ȴ�
			elseif dict.ret == 2 then
				self:OnCancelMatch()
			end
		end
		
	end)
end

-- ���͵ȴ��б�
function PlayerInfo:OnSendWaitInfo(wait_info)

	local wait_info_list = {}
	for _, info in ipairs(wait_info) do
		local stru = wait_info_t .new()
		stru.name = info[ 2 ]
		stru.state = info[ 1 ]
		table.insert(wait_info_list, stru)
	end
	
	self:call_kuafu_3v3_wait_info(wait_info_list)
end

-- ƥ��ȡ��
function PlayerInfo:OnCancelMatch()
	app:SetMatchingKuafuType(self:GetGuid(), nil)
	self:call_kuafu_3v3_cancel_match(KUAFU_TYPE_FENGLIUZHEN)
end

-- ����δ׼����
function PlayerInfo:SomeOneDeclineMatch()
	app:SetMatchingKuafuType(self:GetGuid(), nil)
	self:call_kuafu_3v3_decline_match(KUAFU_TYPE_FENGLIUZHEN)
end

function PlayerInfo:GetPlayerMatchKey()
	return self:GetGuid()
end