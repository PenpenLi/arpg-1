-- 聊天限制
chat_limit = {}
-- 最后聊天时间
last_chat_time = {}
-- 聊天时间
limit_t = 0
-- 聊天等级次数限制表
LIMIT_LEVEL_COUNT_CONFIG = {
-- 等级(10倍)	次数
	[0] = 0,
	[1] = 0,
	[2] = 0,
	[3] = 5,
	[4] = 8,
	[5] = 10,
	[6] = 12,
	[7] = 15,
	[8] = 18,
	[9] = 20,
}

-- 发送聊天信息
function PlayerInfo:SendChat(c_type, content, to_guid, to_name)
	if content == "" then return end
	if to_guid == nil then to_guid = "" end
	if to_name == nil then to_name = "" end
	-- 禁言
	if self:IsGag() then
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_RESULT_IS_GAG)
	end
	if(c_type == CHAT_TYPE_WORLD and string.sub(content,1,1) == '@')then
		self:GmCommand(content)
		return
	end
	-- 写下日志
	WriteChatLog(self:GetGuid(), c_type, to_guid, to_name, content, self:GetLevel(), self:GetGmNum())
	--屏蔽词
	if(self:GetGmNum() == 0)then
		content = fuckPingBi(content)
	end
	--//过滤
	content = ChatMsgFilter(content)
	--//加标识
	content = ChatMsgAddSing(content, self:GetFalseGM(), self:GetGirlGM())
	-- 世界聊天
	if(c_type == CHAT_TYPE_WORLD)then
		-- 广播
		app.objMgr:foreachAllPlayer(function(player)
			player:call_chat_world(self:GetGuid(), self:GetFaction(), self:GetName(), content)
		end)
	-- 帮派聊天
	elseif(c_type == CHAT_TYPE_FACTION)then
		local faction_guid = self:GetFactionId()
		if faction_guid == "" then
			return
		end
		local faction = app.objMgr:getObj(faction_guid)
		if faction == nil then
			return
		end
		local allPlayers = faction:GetFactionAllMemberPtr()
		for _, player in pairs(allPlayers) do
			player:call_faction_chat(self:GetGuid(), self:GetName(), content)
		end
	end
end

--gm命令入口
function PlayerInfo:GmCommand(str)
	local command = str
	local tokens = lua_string_split(str, ' ')
	local gm_str = tokens[1]
	local size_t = #tokens
	local gm_key = GetGmCommandKey(gm_str)
	if(gm_key == GM_COMMAND_JIULONGCHAO)then	--//"@八仙"
		if size_t == 1 then
			return
		end
		local bx_tokens = lua_string_split(command, '|')
		if(#bx_tokens ~= 9)then
			return
		end
		local at_tokens = lua_string_split(tokens[1], ' ')
		if(#at_tokens ~= 2)then
			return
		end
		WriteClientInfoLog(self:GetGuid(), at_tokens[2], bx_tokens[2], bx_tokens[3], bx_tokens[4], bx_tokens[5], bx_tokens[6], bx_tokens[7], bx_tokens[8], bx_tokens[9])
		return
	end
	
	outFmtInfo("player %s send gm command : %s", self:GetGuid(), str)
	local gm_level = 100;
	--[[
	local gm_level = self:GetGMLevel()
	local whisper_str = "Please do not enter illegal characters"
	if(gm_level < GM_LEVEL_3)then
		self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
		return
	end
	]]
	-- //发给其他服务器
	call_gm_command(self:GetGuid(), command)
	
	if(gm_key == GM_COMMAND_SUCAI)then		-- @素材
		if(gm_level < GM_LEVEL_2)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		call_opt_command(0, 0, "reload_template")
		
	elseif gm_key == GM_COMMAND_CUSTOM then	--@CUSTOM
		-- 应用服需要加的
		-- 发一套装备和武器, 背包中在需要一个替换衣服
		local vv = {
			{
				10001,
				10002,
				10003,
				10004,
				10005,
				10006,
				10007,
				10008,
				10009,
				10010,
			
				10022
			},
			{
				10011,
				10012,
				10013,
				10014,
				10015,
				10016,
				10017,
				10018,
				10019,
				10020,
			
				10032
			},
		
		}
		
		
		local gender = self:GetGender()
		local entrys = vv[gender]
		local itemMgr = self:getItemMgr()	
		
		for _, id in pairs(entrys) do
			itemMgr:addItem(id,1,1,true,true,0,0)
		end
		
		-- 穿戴装备和武器
		for i = 1, #entrys-1 do
			itemMgr:exchangePos(BAG_TYPE_MAIN_BAG, i-1, BAG_TYPE_EQUIP, tb_item_template[entrys[i]].pos)
		end
		
		-- 激活神兵和装备
		itemMgr:addItem(101,10,1,true,true,0,0)
		local divineId = 1
		self:DivineActive(divineId)
		self:switchDivine(divineId)
		
	elseif(gm_key == GM_COMMAND_JIAOBEN)then		-- @脚本
		--[[
		if(gm_level < GM_LEVEL_3)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		]]
		local temp = "reload_script"
		for i=2, size_t do
			temp = temp..','..tokens[i]
		end
		call_opt_command(0, 0, temp)
	elseif(gm_key == GM_COMMAND_TI)then			-- @踢
		if(gm_level < GM_LEVEL_1)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		if tokens[2] then
			-- 广播
			app.objMgr:foreachAllPlayer(function(player)
				if(player:GetName() == tokens[2])then
					player:Close(PLAYER_CLOSE_OPERTE_APPD_ONE4)
				end
			end)
		end
	elseif(gm_key == GM_COMMAND_ZHAOCAI)then		-- @招财
		if(gm_level < GM_LEVEL_1)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		if tokens[2] then
			local m_type = 3
			if tokens[3] then
				m_type = math.fmod(tonumber(tokens[3]), MAX_MONEY_TYPE)
			end
			local val = tonumber(tokens[2])
			if val > 0 then
				self:AddMoney(m_type, MONEY_CHANGE_GM_COMMAND, val)
			elseif val < 0 then
				self:SubMoney(m_type, MONEY_CHANGE_GM_COMMAND, math.abs(val))
			end
		else
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), "{@ lucky number type [currency] }")
		end
	elseif(gm_key == GM_COMMAND_PINGBICI)then		-- @屏蔽词
		if(gm_level < GM_LEVEL_3)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		loadFuckPingBi()
	elseif(gm_key == GM_COMMAND_PAIHANGBANG)then		-- @排行榜
		for i=0, MAX_RANK_TYPE-1 do
			clearRankTask(i)
		end
	elseif(gm_key == GM_COMMAND_RETURN_DATA)then		-- @回档数据
		self:Close(PLAYER_CLOSE_OPERTE_APPD_ONE5, "")
	elseif(gm_key == GM_COMMAND_PRINT_OBJECT)then		-- @打印对象
		if(gm_level < GM_LEVEL_3)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		local temp = string.format("print_object,%s,%s,%s", tokens[2] or ".*", tokens[3] or "0", tokens[4] or "0")
		call_opt_command(0, 0, temp)
	elseif(gm_key == GM_COMMAND_TEST_HEFU)then		-- @合服测试
		
	elseif(gm_key == GM_COMMAND_MEMORY_RECOVERY)then		-- @内存回收
		call_opt_command(0, 0, "memory_recovery")
	elseif(gm_key == GM_COMMAND_RESTORE_SYSTEM)then		-- @后台命令
		if(gm_level < GM_LEVEL_3)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		local temp = "restore_system"
		for i=2, size_t do
			temp = temp..','..tokens[i]
		end
		call_opt_command(0, 0, temp)
	else
		--[[
		if(gm_level < GM_LEVEL_1)then
			self:call_chat_whisper(self:GetGuid(), self:GetFaction(), self:GetName(), whisper_str)
			return
		end
		]]
		--outFmtInfo("DoGMScripts")
		DoGMScripts(self.ptr, str)
	end
end

-- 检测聊天限制
function PlayerInfo:CheckChatLimit(c_type, content)
	--gm很屌！！！
	if self:GetGmNum() > 0 then
		return true
	end
	--还没名字的玩家不能发言
	if self:GetName() == "" then
		return false
	end
	--没内容的发言
	if content == "" then
		return false
	end
	--是否被禁言
	if self:IsGag() then
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_RESULT_IS_GAG)
		return false
	end
	--聊天长度不能超过120
	if string.len(content) > 120 then
		return false
	end
	
	-- 等级限制
	local level = self:GetLevel()
	if(c_type == CHAT_TYPE_WHISPER and level < config.player_chat_whisper_level)then
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_LEVEL_WHISPER_LEVEL_NO)
		return false
	elseif(c_type == CHAT_TYPE_WORLD and level < config.player_chat_world_level)then
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_LEVEL_WORLD_LEVEL_NO)
		return false
	end
	
	--频率限制
	local guid = self:GetGuid()
	local t = os.time()
	local last_time = last_chat_time[guid] or 0
	if(last_time + 5 > t)then
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_RESULT_CHECK_LIMIT)
		return false
	end
	last_chat_time[guid] = t
	
	-- 等级次数限制
	if(t > limit_t)then
		limit_t = t - math.fmod(t,3600) + 3600
		chat_limit = {}
	end
	
	local chat_num = chat_limit[guid] or 0
	local result = true
	local max_num = LIMIT_LEVEL_COUNT_CONFIG[math.floor(level/10)]
	if(max_num)then
		result = chat_num < max_num
	end
	if result then
		chat_limit[guid] = chat_num + 1
	else
		self:CallOptResult(OPRATE_TYPE_CHAT, CHAT_RESULT_CHECK_LIMIT)
	end
	return result
end