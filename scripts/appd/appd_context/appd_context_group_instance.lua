
local security = require("base/Security")

local sub = "group_instance"
function PlayerInfo:OnCheckGroupInstanceMatch()
	-- ƥ��Ĳ�����Ӹ���
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_GROUP_INSTANCE) then
		return
	end
	
	local url = string.format("%s%s/check_match", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	local indx = app:GetKuafuTypeMatchingArg(self:GetGuid())
	-- ��������Ӹ�������ƥ�����Ϣ
	data.player_guid = self:GetGuid()
	data.indx = indx
	outFmtDebug("$$$$$$$$$$$$$$$$$$$$$$ %d", data.indx)
	data.open_time = 1
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		if response then
			outFmtDebug("OnCheckGroupInstanceMatch response = %s", response)
		end
		local dict = nil
		security.call(
			--try block
			function()
				dict = json.decode(response)
			end
		)
		
		
		if dict then
			outFmtDebug("OnCheckGroupInstanceMatch result %d %s", dict.ret, dict.msg)
			-- ƥ�䵽��
			if dict.ret == 0 then
				local login_fd = serverConnList:getLogindFD()
				local guid = self:GetGuid()
				-- dict.enter_info = json.decode(dict.enter_info)
				local enter_info = dict.enter_info
				if type(enter_info) == "string" then
					enter_info = json.decode(enter_info)
				end
				
				-- �Ѿ�ƥ�䵽��
				app:SetMatchingKuafuType(self:GetGuid(), nil)
				
				-- ��ʱ���ܿ۽���ȯ�Ͳ��ý�
				--local config = tb_kuafu_xianfu_condition[indx]
				--if not self:useMulItem(config.ticket) then
				--	return
				--end
				
				-- ���ӽ������
				--local instMgr = self:getInstanceMgr()
				--instMgr:AddXianfuDayTimes()
				
				-- ��web��Ǯ(��Ȼ�п������ݱȽ�������)
				--self:OnSaveMoney()
				
				local pos = enter_info.pos
				local war_id = enter_info.war_id
				local battle_server = enter_info.battle_server
				outFmtInfo("$$$$ on xianfu matched guid = %s war_id = %s battle_server = %s", self:GetGuid(), war_id, battle_server)
				call_appd_login_to_send_kuafu_info(login_fd, guid, war_id, indx, battle_server, '', KUAFU_TYPE_GROUP_INSTANCE)
				-- �������ڽ��п����־
				self:KuafuMarked(KUAFU_TYPE_GROUP_INSTANCE)
				
			-- timeoutȡ��ƥ��
			elseif dict.ret == 1 then
				local target = dict.target
				local count = dict.count
				outFmtDebug("taget = %d, count = %d", target, count)
				self:call_kuafu_match_wait(KUAFU_TYPE_GROUP_INSTANCE, target ,count)
			elseif dict.ret == 2 then
				outFmtDebug("== player on cancel match, %s", self:GetGuid())
				self:OnCancelMatch(KUAFU_TYPE_GROUP_INSTANCE)
			end
		end
	end)
end


-- ȡ��ƥ����Ӹ���
function PlayerInfo:OnCancelGroupInstanceMatchBeforeOffline()
	
	if not app:IsKuafuTypeMatching(self:GetGuid(), KUAFU_TYPE_GROUP_INSTANCE) then
		return
	end
	
	local url = string.format("%s%s/cancel_match", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	data.player_guid = self:GetGuid()
	data.indx = app:GetKuafuTypeMatchingArg(self:GetGuid())
	outFmtDebug("OnCancelGroupInstanceMatchBeforeOffline %d", data.indx)
	data.open_time = 1
	self:OnCancelMatch(KUAFU_TYPE_GROUP_INSTANCE)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		if response then
			outFmtDebug("OnCancelGroupInstanceMatchBeforeOffline response = %s", response)
		end
	end)
end


-- ƥ����Ӹ���
function PlayerInfo:OnGroupInstanceMatch(indx)
	-- �Ѿ��ڿ����
	if self:IsKuafuing() then
		return false
	end
	
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		return false
	end
	
	outFmtInfo("###OnGroupInstanceMatch guid = %s", self:GetGuid())
	local url = string.format("%s%s/match", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	data.player_guid = self:GetGuid()
	data.open_time = 1
	data.indx = indx
	
	app:SetMatchingKuafuType(self:GetGuid(), KUAFU_TYPE_GROUP_INSTANCE + indx * 65536)
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		if response then
			outFmtDebug("OnGroupInstanceMatch response = %s", response)
		end
		local dict = nil
		security.call(
			--try block
			function()
				dict = json.decode(response)
			end
		)
		
		if dict then
			outFmtDebug("OnGroupInstanceMatch %d %s", dict.ret, dict.msg)
		end
	end)
	
	return true
end


-- �������Ӹ�������
function PlayerInfo:CheckGroupInstanceReward()
	local url = string.format("%s%s/check_match_result", globalGameConfig:GetExtWebInterface(), sub)
	local data = {}
	data.player_guid = self:GetGuid()
	data.open_time = 1
	
	app.http:async_post(url, string.toQueryString(data), function (status_code, response)
		if response then
			outFmtDebug("CheckGroupInstanceReward response = %s", response)
		end
		local dict = nil
		security.call(
			--try block
			function()
				dict = json.decode(response)
			end
		)
		if dict then
			outFmtDebug("%d %s %s", dict.ret, dict.msg, self:GetGuid())
			
			if dict.ret == 0 then
				
				-- ����
				--[[
				local questMgr = self:getQuestMgr()
				questMgr:OnUpdate(QUEST_TARGET_TYPE_JOIN_XIANFU)
				--]]
				-- �����data�ж��Ƿ�ͨ��
				local data = dict.details
				--[[
				local itemInfoTable = string.split(data, ",")
				
				if #itemInfoTable > 0 then
					outFmtDebug("%s get reward %s", self:GetGuid(), data)
					local rewardDict = {}
					for i = 1, #itemInfoTable, 2 do
						local itemId = tonumber(itemInfoTable[ i ])
						local count  = tonumber(itemInfoTable[i+1])
						table.insert(rewardDict, {itemId, count})
					end
					
					self:AppdAddItems(rewardDict, MONEY_CHANGE_KUAFU_WORLD_XIANFU, LOG_ITEM_OPER_TYPE_XIANFU)
				end
				--]]
				
				
			end
		end
		
	end)
end


-- ����������
function PlayerInfo:OnBuyTicket(type, indx, count)
	local config = tb_kuafu_xianfu_condition[type].price
	
	if not config[indx] then
		return
	end
	
	local ticketid = tb_kuafu_xianfu_condition[type].ticketid
	local cost = {{config[indx][1], config[indx][2]}}
	
	local itemMgr = self:getItemMgr()
	local emptys  = itemMgr:getEmptyCount(BAG_TYPE_MAIN_BAG)
	if emptys < 1 then
		self:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_BAG_FULL)
		return
	end
	
	if self:costMoneys(MONEY_CHANGE_BUY_XIANFU_TICKET, cost, count) then
		self:AppdAddItems({{ticketid, count}}, nil, LOG_ITEM_OPER_TYPE_XIANFU_BUY)
	end
end

-- ������Ӹ���
function PlayerInfo:OnResetXianfu()
	local instMgr = self:getInstanceMgr()
	instMgr:ResetXianfuDayTimes()
end