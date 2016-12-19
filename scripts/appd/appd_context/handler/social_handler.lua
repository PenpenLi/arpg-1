

function PlayerInfo:Handle_Add_Friend(pkt)
	local  guid = pkt.guid
	self:ApplyFriend(guid)
end
