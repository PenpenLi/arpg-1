-- 定时器的具体模块刷新
function PlayerInfo:QueryKuafuMatchInfo()
	if self:GetMatchingKuafuType() == KUAFU_TYPE_FENGLIUZHEN then
		self:OnWorld3v3Match()
	end
end

-- 匹配3v3
function PlayerInfo:OnWorld3v3Match()
	if self:GetMatchingKuafuType() ~= KUAFU_TYPE_FENGLIUZHEN then
		self:SetMatchingKuafuType(KUAFU_TYPE_FENGLIUZHEN)
	end
	
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/match"
	local data = {}
	data.group_guid = self:GetGuid()
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		local dict = json.decode(response)
		
		print(dict.ret, dict.msg)
		-- 匹配到了
		if dict.ret == 0 then
			local scened_fd = serverConnList:getLogindFD()
			local guid = self:GetGuid()
			dict.enter_info = json.decode(dict.enter_info)
			local enter_info = dict.enter_info
			local war_id = enter_info.war_id
			local battle_server = enter_info.battle_server
			call_appd_login_to_send_kuafu_info(scened_fd, guid, war_id, battle_server)
			-- 已经匹配到了
			self:SetMatchingKuafuType(0)
		elseif dict.ret == 4 then
			if dict.msg == "cancel" then
				-- timeout取消匹配
				self:SetMatchingKuafuType(0)
			end
		end
	end)
end

function PlayerInfo:OnCancelKuafuMatch()
	self:OnCancelWorld3v3Match()
end

-- 取消匹配3v3
function PlayerInfo:OnCancelWorld3v3Match()
	if self:GetMatchingKuafuType() ~= KUAFU_TYPE_FENGLIUZHEN then
		return
	end
	local url = globalGameConfig:GetExtWebInterface().."world_3v3/cancel_match"
	local data = {}
	data.group_guid = self:GetGuid()
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		self:SetMatchingKuafuType(0)
	end)
end