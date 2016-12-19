--申请添加好友
function PlayerInfo:ApplyFriend(guid)
	outFmtDebug("shenqinghaoyou")
	local friend = app.objMgr:getObj(guid)
	if not friend then 
		outFmtDebug("friend not on line or not extis, %s", guid)
		return false
	end
	--向目标申请加好友
	friend:AddApplyFriend(self)
end

function PlayerInfo:AddApplyFriend(friend)
	local socialMgr = self:getSocialMgr()
	local guid = friend:GetGuid();

	--判断是不是好友
	if socialMgr:isFriend(guid) then
		outFmtDebug("player is already friend, %s", guid)
		return false
	end
	--判断是不是自己
	if self:GetName() == guid then
		outFmtDebug("you self is a friend, %s", guid)
		return false
	end

	--判断是不是已经在列表中
	if socialMgr:isApply(guid) then
		outFmtDebug("player is already in apply, %s", guid)
		return false
	end

	socialMgr:addApplyPlayer(friend)

end
--添加好友
function PlayerInfo:AddFriend(guid)
	--outFmtInfo("add friend %s",guid)
	local player = app.objMgr:getObj(guid)
	if not player then 
		outFmtDebug("player not on line or not extis, %s", guid)
		return false
	end

	local socialMgr = self:getSocialMgr()

	--判断是不是好友
	if socialMgr:isFriend(guid) then
		outFmtDebug("player is already friend, %s", guid)
		return false
	end
	--判断是不是自己
	if self:GetName() == guid then
		outFmtDebug("you self is a friend, %s", guid)
		return false
	end

	--判断是不是已经在列表中
	if socialMgr:isApply(guid) then
		outFmtDebug("player is already in apply, %s", guid)
		return false
	end

	--获取一个空的朋友位
	local pos = socialMgr:getEmptyFriendIndex()
	if pos ~= -1 then
		socialMgr:addSocialItem(player,pos)
		return true
	end

	return false

end
