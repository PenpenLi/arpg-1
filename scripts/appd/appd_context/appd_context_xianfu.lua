
local security = require("base/Security")

local sub = "world_xianfu"

function PlayerInfo:OnCheckWorldXianfuMatch()
	-- 匹配的不是3v3
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_XIANFU) then
		return
	end
	
	local url = string.format("%s%s/check_match", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	-- 这里获得3v3队伍匹配的信息
	data.player_guid = self:GetGuid()
	data.indx = app:GetKuafuTypeMatchingArg(self:GetGuid())
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		
		local dict = nil
		security.call(
			--try block
			function()
				dict = json.decode(response)
			end
		)
		
		
		if dict then
			print("OnCheckWorldXianfuMatch result", dict.ret, dict.msg)
			-- 匹配到了
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
				call_appd_login_to_send_kuafu_info(login_fd, guid, war_id, 0, battle_server, '', KUAFU_TYPE_XIANFU)
				-- 已经匹配到了
				app:SetMatchingKuafuType(self:GetGuid(), nil)
				
				-- 增加进入次数
				--local instMgr = self:getInstanceMgr()
				-- instMgr:add3v3EnterTimes()
			-- timeout取消匹配
			elseif dict.ret == 2 then
				print("== player on cancel match", self:GetGuid())
				self:OnCancelMatch(KUAFU_TYPE_XIANFU)
			end
		end
	end)
end


-- 取消匹配仙府夺宝
function PlayerInfo:OnCancelWorldXianfuMatchBeforeOffline()
	
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_XIANFU) then
		return
	end
	
	local url = string.format("%s%s/cancel_match", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	data.player_guid = self:GetGuid()
	data.indx = app:GetKuafuTypeMatchingArg(self:GetGuid())
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug("cancel_match response = ", response)
		self:OnCancelMatch(KUAFU_TYPE_XIANFU)
	end)
end


-- 匹配仙府夺宝
function PlayerInfo:OnWorldXianfuMatch(indx)
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		return false
	end

	local url = string.format("%s%s/match", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	data.player_guid = self:GetGuid()
	data.open_time = 1
	data.indx = indx
	
	app:SetMatchingKuafuType(self:GetGuid(), KUAFU_TYPE_XIANFU + indx * 65536)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		
		local dict = nil
		security.call(
			--try block
			function()
				dict = json.decode(response)
			end
		)
		
		if dict then
			
		end
	end)
	
	return true
end


-- 检查跨服仙府夺宝奖励
function PlayerInfo:CheckWorldXianfuReward()
	local url = string.format("%s%s/check_match_result", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	data.player_guid = self:GetGuid()
	data.open_time = 1
	
	local askguid = self:GetGuid()
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		outFmtDebug(response)
		
		local dict = nil
		security.call(
			--try block
			function()
				dict = json.decode(response)
			end
		)
		if dict then
			print(dict.ret, dict.msg, askguid)
			
			if dict.ret == 0 then
				local data = dict.details
				if type(data) == "string" then
					data = json.decode(data)
				end
				
			end
		end
		
	end)
end


