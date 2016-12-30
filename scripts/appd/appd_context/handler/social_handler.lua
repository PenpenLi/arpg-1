

function PlayerInfo:Handle_Add_Friend(pkt)
	local  guid = pkt.guid
	self:ApplyFriend(guid)
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
	--outFmtDebug("huoqu tui jian lie biao")
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
