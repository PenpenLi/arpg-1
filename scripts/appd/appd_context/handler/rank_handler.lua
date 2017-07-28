function PlayerInfo:Handle_Rank_Like(pkt)
	--outFmtDebug("fu chou")
	local guid = pkt.guid
	local types = pkt.type
	
	local flag = self:GetBit(PLAYER_FIELD_USE_RANK_LIKE,types)
	--outFmtDebug("day usenu %d",usenum)
	if flag  then
		--outFmtDebug("day max use like")
		self:CallOptResult(OPERTE_TYPE_RANK_LIST, RANK_LIST_OPERATE_HAS_LIKE)
		return
	end
	
	local player
	if types == RANK_TYPE_POWER or types == RANK_TYPE_MONEY or
		types == RANK_TYPE_LEVEL --[[or types == RANK_TYPE_DIVINE or
		types == RANK_TYPE_MOUNT--]] then
		local flag , rank = RankHasGuid(types,guid)
		if flag == false or rank < 1 or rank > 3 then
			outFmtDebug("use is not in rank")
			return
		end
		
	elseif types == RANK_TYPE_FACTION then
		local flag , rank = RankHasGuid(types,guid)
		if flag == false or rank < 1 or rank > 3 then
			outFmtDebug("use is not in rank")
			return
		end
		
		if not app.objMgr:IsFactionGuid(guid) then
			return
		end
		
		local faction = app.objMgr:getObj(guid)
		
		if not faction then
			return
		end
		guid = faction:GetBangZhuGuid()
	else 
		return
	end
	
	
	if not app.objMgr:IsPlayerGuid(guid) then
		return
	end
	player = app.objMgr:getObj(guid)
	
	if player ~= nil then
		if self:ApplyRankLike(types,guid) then
			local like = player:AddRankLike()
			self:AddRankLikeResult(types,guid,like)
		end
		return
	end
	
	local data = {}
	data.name = 'Handle_Rank_Like'
	data.callback_guid = guid
	data.my_guid = self:GetGuid()
	data.ranktype = types
	function data.fun (data, objs)
		local targetPlayer = objs[data.callback_guid]
		if not targetPlayer then return end
		
		local myplayer = app.objMgr:getObj(data.my_guid)
		if not myplayer then return end
		
		if myplayer:ApplyRankLike(data.ranktype,data.callback_guid ) then
			local like = targetPlayer:AddRankLike()
			--更新到排行榜
			UpdateRankLike(data.ranktype,data.callback_guid,like)
			self:AddRankLikeResult(data.ranktype,data.callback_guid,like)
			
			local reward = tb_rank_like[1].reward
			self:AppdAddItems(reward,MONEY_CHANGE_RANK_LIKE)
		end
		
	end
	GetObjects(data)
end

function PlayerInfo:RankLikeRest()
	for i=PLAYER_STRING_FIELD_RANKLIKE_START,PLAYER_STRING_FIELD_RANKLIKE_ENE-1 do
		self:SetStr(i,"")
	end
	self:SetUInt32(PLAYER_FIELD_USE_RANK_LIKE,0)
end

function PlayerInfo:AddRankLikeResult(types,guid,like)
	self:call_rank_add_like_result(types,guid, like)
end

function PlayerInfo:AddRankLike()
	local like = self:GetUInt32(PLAYER_FIELD_RANK_LIKE)
	like = like + 1
	self:SetUInt32(PLAYER_FIELD_RANK_LIKE,like)
	return like
end

function PlayerInfo:AddApplyRankLike()
	local like = self:GetUInt32(PLAYER_FIELD_USE_RANK_LIKE)
	if like >= MAX_RANK_LIKE then
		return
	end
	like = like + 1
	self:SetUInt32(PLAYER_FIELD_USE_RANK_LIKE,like)
end
--对某个排行榜的某个人点赞
function PlayerInfo:ApplyRankLike(types,guid)
	if self:HasRankLike(types,guid) then
		--outFmtDebug("has like it")
		self:CallOptResult(OPERTE_TYPE_RANK_LIST, RANK_LIST_OPERATE_HAS_LIKE)
		return false
	end
	--[[
	local usenum = self:GetUInt32(PLAYER_FIELD_USE_RANK_LIKE)
	if usenum >= MAX_RANK_LIKE then
		return false
	end
	--]]
	
	local flag = self:GetBit(PLAYER_FIELD_USE_RANK_LIKE,types)
	if flag  then
		return false
	end
	
	for i=PLAYER_STRING_FIELD_RANKLIKE_START,PLAYER_STRING_FIELD_RANKLIKE_ENE-1 do
		if self:GetStr(i) == "" then
			local spkey = "\1"
			local key = guid .. spkey .. types
			self:SetStr(i,key)
			--usenum = usenum + 1
			--self:SetUInt32(PLAYER_FIELD_USE_RANK_LIKE,usenum)
			self:SetBit(PLAYER_FIELD_USE_RANK_LIKE,types)
			return true
		end
	end
	return false
end

function PlayerInfo:HasRankLike(types,guid)
	local spkey = "\1"
	local key = guid .. spkey .. types
	for i=PLAYER_STRING_FIELD_RANKLIKE_START,PLAYER_STRING_FIELD_RANKLIKE_ENE-1 do
		if self:GetStr(i) == key then
			return true
		end
	end
	return false
end

