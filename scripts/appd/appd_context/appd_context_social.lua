local protocols = require('share.protocols')

--申请添加好友
function PlayerInfo:ApplyFriend(guid)
	local friend = app.objMgr:getObj(guid)
	if not friend then 
		outFmtDebug("friend not on line or not extis, %s", guid)
		return false
	end
	--向目标申请加好友
	friend:AddApplyFriend(self)
end
--确认添加好友
function PlayerInfo:SureApplyFriend(guid)
	local socialMgr = self:getSocialMgr()
	local idx = socialMgr:getApplyIndex(guid)
	--是否在好友列表中
	if idx ~= -1 then
		--对方是否还在线
		local friend = app.objMgr:getObj(guid)
		if not friend then 
			--清除申请对象
			socialMgr:setSocilaItem(idx,0,0,"","")
			outFmtDebug("friend not on line or not extis, %s", guid)
			return false
		end

		if friend:AddFriend(self) == false then
			--清除申请对象
			socialMgr:setSocilaItem(idx,0,0,"","")
			return false
		end

		local i1,i2,s1,s2 = socialMgr:getSocilaItem(idx)
		local emp = socialMgr:getEmptyFriendIndex()

		if emp ~= -1 then
			socialMgr:setSocilaItem(emp,i1,i2,s1,s2)
			socialMgr:setSocilaItem(idx,0,0,"","")
		end


		return true
	end
	return false
end

--添加申请好友
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
--直接添加好友
function PlayerInfo:AddFriend(friend)
	local socialMgr = self:getSocialMgr()
	local guid = friend:GetGuid()

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

	local tf = socialMgr:addFriendPlayer(friend)
	if tf == false then
		outFmtDebug("target friend is full")
	end
	return tf

end
--赠送礼物
function PlayerInfo:AddGiftFriend(guid,gift)
	local friend = app.objMgr:getObj(guid)
	if not friend then 
		outFmtDebug("friend not on line or not extis, %s", guid)
		return
	end
	local famNum = 0
	local money = {}
	for _,v in pairs(gift) do
		local config = tb_social_shop[v.item_id]
		if not config then
			outFmtDebug("cannot find tb_social_shop data, %d", v.item_id)
			return
		end
		famNum = famNum + config.familiay
		local costTab = config.costResource
		for _, res in pairs(costTab) do
			AddTempInfoIfExist(money,res[1],res[2])
		end
	end
	
	--for k,v in pairs(money) do
	--	print(k,v[1],v[2])
	--end

	--是否有足够的资源
	if not self:checkMoneyEnoughs(money) then
		outFmtError("resouce not enough")
		return
	end

	if self:costMoneys(MONEY_CHANGE_SOCIAL_GIFT,money) then
		--同时增加双方好友度
		self:AddFamiliay(famNum,friend:GetGuid())
		friend:AddFamiliay(famNum,self:GetGuid())

		--给东西
		for _,v in pairs(gift) do
			local config = tb_social_shop[v.item_id]
			friend:AddItemByEntry(config.itemId, v.num, nil, 8, true)--FIXME
		end
	end

end

function PlayerInfo:RecommendFriend()
	playerLib.GetAndSendRecommendFriends(self:GetGuid())
end
--增加亲密度
function PlayerInfo:AddFamiliay(num,guid)
	local socialMgr = self:getSocialMgr()
	socialMgr:addFamiliay(guid,num)
end
--增加仇恨度 仇人id 仇恨度
function PlayerInfo:AddEnemy(guid,num)
	local socialMgr = self:getSocialMgr()
	--socialMgr:addFamiliay(guid,num)
	local enemy = app.objMgr:getObj(guid)
	if not enemy then 
		outFmtDebug("enemy not on line or not extis, %s", guid)
	end
	socialMgr:addEnemyPlayerNum(enemy,guid,num)
end

--是否为好友
function PlayerInfo:isFriend(guid)
	local socialMgr = self:getSocialMgr()
	return socialMgr:isFriend(guid)
end
