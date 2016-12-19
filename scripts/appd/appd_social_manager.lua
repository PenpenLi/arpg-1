--技能管理器

local AppSocialMgr = class("AppSocialMgr", BinLogObject)

function AppSocialMgr:ctor()
	
end

----------------------------------------基础技能部分------------------------------------
--添加一条数据
function AppSocialMgr:addSocialItem(player,index)

	local name = player:GetName()
	local guid	= player:GetGuid()
	local level = player:GetLevel()
	local gender = player:GetGender()
	local vip = player:GetVIP()
	local faction = player:GetFactionId()


	--图标 vip 等级
	self:SetByte(index,0,gender)
	self:SetByte(index,1,vip)
	self:SetUInt16(index,1,level)

	--亲密度设置
	--self:SetUInt16(index+1,0,0)
	--self:SetUInt16(index+1,1,0)
	--guid
	self:SetStr(index,guid)
	--name faction
	local str = name .. "\1" .. faction
	--outFmtDebug("addSocialItem %d",index)
	--outFmtDebug("addSocialStr %s",str)
	self:SetStr(index+1,str)
	
end

--是否是朋友
function AppSocialMgr:isFriend(guid)
	for i=SOCIAL_FRIEND_START,SOCIAL_FRIEND_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == guid then
			return true
		end
	end
	return false
end
--是否在申请列表中
function AppSocialMgr:isApply(guid)
	--outFmtDebug("isApply %s",guid)
	for i=SOCIAL_APPLY_START,SOCIAL_APPLY_END,MAX_FRIENT_COUNT do
		--outFmtDebug("applye item %d,%s",i,self:getGuid(i))
		if self:getGuid(i) == guid then
			return true
		end
	end
	return false
end
--获取一个空的朋友位
function AppSocialMgr:getEmptyFriendIndex()
	for i=SOCIAL_FRIEND_START,SOCIAL_FRIEND_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == '' then
			return i
		end
	end
	return -1
end
--获取一个空的申请位
function AppSocialMgr:getEmptyApplyIndex()
	for i=SOCIAL_APPLY_START,SOCIAL_APPLY_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == '' then
			return i
		end
	end
	return -1
end

function AppSocialMgr:addApplyPlayer(player)
	local idx = self:getEmptyApplyIndex()

	if idx == -1 then
		local flag = self:GetUInt32(SOCIAL_APPLY_CLEAR_FLAG)
		idx = SOCIAL_APPLY_START + flag * MAX_FRIENT_COUNT
		flag = flag + 1
		if flag >= SOCIAL_APPLY_MAX_NUM then
			flag = 0;
		end
		self:SetUInt32(SOCIAL_APPLY_CLEAR_FLAG,flag)
	end

	self:addSocialItem(player,idx)

end

function AppSocialMgr:addFriendPlayer()
	
end


function AppSocialMgr:getGuid(index)
	return self:GetStr(index)
end


return AppSocialMgr