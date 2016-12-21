

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
	outFmtDebug("huoqu tui jian lie biao")
	self:RecommendFriend()
end
function PlayerInfo:Handle_Revenge_Enemy(pkt)
	outFmtDebug("fu chou")
end