

function PlayerInfo:Handle_Add_Friend(pkt)
	local  guid = pkt.guid
	self:ApplyFriend(guid)
end

function PlayerInfo:Handle_Add_Friend_ByName(pkt)
	local name = pkt.name
	if name == nil then
		return
	end
	local flag = false
	
	app.objMgr:foreachAllPlayer(function(player)
		local pname = player:GetName()
		local _, q= string.find(pname, name)  
		if q ~= nil and q == #pname then
			self:ApplyFriend(player:GetGuid())
			flag = true
		end
	end)
	
	if flag then
		self:CallOptResult(OPERTE_TYPE_SOCIAL, OPERTE_TYPE_SOCIAL_HAS_SEND)
	else
		self:CallOptResult(OPERTE_TYPE_SOCIAL, OPERTE_TYPE_SOCIAL_NOT_FIND)
	end
end
--同意申请加好友
function PlayerInfo:Handle_Sure_Add_Friend(pkt)
	local  guid = pkt.guid
	--outFmtDebug("sure add friend %s",guid)
	self:SureApplyFriend(guid)
end

function PlayerInfo:Handle_Gift_Friend(pkt)
	local guid = pkt.guid
	local gift = pkt.gift
	if #gift > 5 then
		outFmtDebug("gift list to long %s",guid)
		return
	end
	self:AddGiftFriend(guid,gift)
end 
function PlayerInfo:Handle_Recommend_Friend(pkt)
	self:RecommendFriend()
end
function PlayerInfo:Handle_Revenge_Enemy(pkt)
	--outFmtDebug("fu chou")
	local guid = pkt.guid
	local data = {}
	data.name = 'Handle_Revenge_Enemy'
	data.callback_guid = guid
	data.my_guid = self:GetGuid()
	function data.fun (data, objs)
		print("callbacked ===================")
		local targetPlayer = objs[data.callback_guid]
		if not targetPlayer then return end
		print("target player =", targetPlayer:GetGuid())
	end
	GetObjects(data)
end
function PlayerInfo:Handle_Remove_Friend(pkt)
	--outFmtDebug("del friend")
	local guid = pkt.guid
	self:RemoveFriend(guid,true)
end
function PlayerInfo:Handler_Clear_Apply(pkt)
	self:ClearApply()
end
