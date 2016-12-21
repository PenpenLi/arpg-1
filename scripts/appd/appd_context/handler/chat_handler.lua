-- 队伍聊天
function PlayerInfo:Handle_Group_chat(pkt)
	local groupID = self:GetGroupId()
	if( groupID == "")then
		self:CallOptResult(OPRATE_TYPE_GROUP,ACCACK_PACKET_TYPE_DATA)
		return
	end
	local msg = pkt.msg
	if(self:CheckChatLimit(CHAT_TYPE_GROUP, msg) == false)then
		return
	end
	--屏蔽词
	msg = fuckPingBi(pkt.msg)
	
	local group = app.objMgr:getObj(groupID)
	if(not group)then return end
	local guid_list = group:GetGroupAllMemberTable()
	for _,guid in pairs(guid_list) do
		local player = app.objMgr:getObj(guid)
		if(player)then
			player:call_group_chat(self:GetGuid(),self:GetName(),msg)
		end
	end
	WriteChatLog(self:GetGuid(), CHAT_TYPE_GROUP, "", "", msg, self:GetLevel(), self:GetGmNum())
end

--获取帮派聊天
function PlayerInfo:Handle_Chat_Faction( pkt )
	local player_id, player_name, msg = pkt.player_id, pkt.player_name, pkt.msg
	local faction_guid = self:GetFactionId()
	if faction_guid == "" then
		return
	end
	local faction = app.objMgr:getObj(faction_guid)
	if faction == nil then
		return
	end
	if(self:CheckChatLimit(CHAT_TYPE_FACTION, msg) == false)then
		return
	end
	if self:GetFactionXiaoHeiWu() > os.time() then
		return
	end
	msg = fuckPingBi(pkt.msg)
	local allPlayers = faction:GetFactionAllMemberPtr()
	for _, player in pairs(allPlayers) do
		player:call_faction_chat(self:GetGuid(), self:GetName(), msg)
	end
	WriteChatLog(self:GetGuid(), CHAT_TYPE_FACTION, "", "", msg, self:GetLevel(), self:GetGmNum())
end

-- 喇叭
function PlayerInfo:Handle_Chat_Horn( pkt )
	local guid, faction, name, content = pkt.guid, pkt.faction, pkt.name, pkt.content
	if content == "" then
		return
	end
	-- 禁言
	if self:IsGag() then
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_RESULT_IS_GAG)
	end
	if self:GetMoney(MONEY_TYPE_GOLD_INGOT) < config.laba_use_need_money then
		return
	end
	if(self:CheckChatLimit(CHAT_TYPE_HORM, content) == false)then
		return
	end
	-- 扣元宝
	if(self:SubMoney(MONEY_TYPE_GOLD_INGOT, MONEY_CHANGE_USE_LABA, config.laba_use_need_money) == false)then
		return
	end
	--屏蔽词
	content = fuckPingBi(content)
	--//过滤
	content = ChatMsgFilter(content)
	--//加标识
	content = ChatMsgAddSing(content, self:GetFalseGM(), self:GetGirlGM())
	-- 广播
	app.objMgr:foreachAllPlayer(function(player)
		player:call_chat_horn(self:GetGuid(), self:GetFaction(), self:GetName(), content)
	end)
	-- 写下日志
	WriteChatLog(self:GetGuid(), CHAT_TYPE_HORM, "", "", content, self:GetLevel(), self:GetGmNum())
end

-- 私聊
function PlayerInfo:Handle_Chat_Whisper( pkt )
	local guid, faction, name, content = pkt.guid, pkt.faction, pkt.name, pkt.content
	if content == "" then
		return
	end
	if(self:CheckChatLimit(CHAT_TYPE_WHISPER, content) == false)then
		return
	end
	local recipient = app.objMgr:getObj(guid)
	if not recipient then
		app.objMgr:foreachAllPlayer(function(player)
			if player:GetName() == name then
				recipient = player
				return true
			end
		end)
	end
	if not recipient then
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_RESULT_NOT_PLAYER)
		return
	end
	--屏蔽词
	content = fuckPingBi(content)
	recipient:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), content)
	--私聊后做点什么
	self:DoAfterChatWhisper(recipient)
	-- 写下日志
	WriteChatLog(self:GetGuid(), CHAT_TYPE_WHISPER, guid, recipient:GetName(), content, self:GetLevel(), self:GetGmNum())
end

-- 世界聊天
function PlayerInfo:Handle_Chat_World( pkt )
	local guid, faction, name, content = pkt.guid, pkt.faction, pkt.name, pkt.content
	if content == "" then
		return
	end
	
	--[[if(self:CheckChatLimit(CHAT_TYPE_WORLD, content) == false)then
		return
	end--]]

	self:SendChat(CHAT_TYPE_WORLD, content, guid, name)
end