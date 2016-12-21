--技能管理器

local AppSocialMgr = class("AppSocialMgr", BinLogObject)

function AppSocialMgr:ctor()
	
end

----------------------------------------基础技能部分------------------------------------
--添加一条数据
function AppSocialMgr:addSocialItem(player,index,fam)
	fam = fam or 0
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
	self:SetUInt16(index+1,0,fam)
	self:SetUInt16(index+1,1,1)
	--guid
	self:SetStr(index,guid)
	--name faction
	local str = name .. "\1" .. faction
	--outFmtDebug("addSocialItem %d",index)
	--outFmtDebug("addSocialStr %s",str)
	self:SetStr(index+1,str)
	
end
--获取一条数据信息
function AppSocialMgr:getSocilaItem(index)
	local i1 = self:GetUInt32(index)
	local i2 = self:GetUInt32(index+1)
	local s1 = self:GetStr(index)
	local s2 = self:GetStr(index+1)

	return i1,i2,s1,s2
end
--设置一条数据信息
function AppSocialMgr:setSocilaItem(index,i1,i2,s1,s2)
	self:SetUInt32(index,i1)
	self:SetUInt32(index+1,i2)
	self:SetStr(index,s1)
	self:SetStr(index+1,s2)
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
	for i=SOCIAL_APPLY_START,SOCIAL_APPLY_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == guid then
			return true
		end
	end
	return false
end
--根据guid获取index
function AppSocialMgr:getApplyIndex(guid)
	for i=SOCIAL_APPLY_START,SOCIAL_APPLY_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == guid then
			return i
		end
	end
	return -1
end

function AppSocialMgr:getFriendIndex(guid)
	for i=SOCIAL_FRIEND_START,SOCIAL_FRIEND_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == guid then
			return i
		end
	end
	return -1
end

function AppSocialMgr:getEnemyIndex(guid)
	for i=SOCIAL_ENEMY_START,SOCIAL_ENEMY_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == guid then
			return i
		end
	end
	return -1
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
	for i=SOCIAL_APPLY_START,SOCIAL_ENEMY_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == '' then
			return i
		end
	end
	return -1
end
--获取一个空的仇人位
function AppSocialMgr:getEmptyEnemyIndex()
	for i=SOCIAL_ENEMY_START,SOCIAL_ENEMY_END,MAX_FRIENT_COUNT do
		if self:getGuid(i) == '' then
			return i
		end
	end
	return -1
end
--下线清空申请列表
function AppSocialMgr:clearApplyList()
	for i=SOCIAL_APPLY_START,SOCIAL_APPLY_END,MAX_FRIENT_COUNT do
		self:SetUInt32(i,0)
		self:SetUInt16(i+1,0,0)
		self:SetUInt16(i+1,1,1)
		self:SetStr(i,"")
		self:SetStr(i+1,"")
	end
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

function AppSocialMgr:addFriendPlayer(player)
	local idx = self:getEmptyFriendIndex()
	if idx == -1 then
		return false;
	end
	self:addSocialItem(player,idx)
	return true
end
--添加敌人仇恨值
function AppSocialMgr:addEnemyPlayerNum(player,guid,num)
	local idx = self:getEnemyIndex(guid)
	--如果在仇人列表
	if idx ~= -1 then
		local hatred = self:GetUInt16(idx + 1,0)
		hatred = hatred + num
		self:SetUInt16(idx + 1,0,hatred)
		self:setEnemyTime(idx)
	else
		local emIdx = self:getEmptyEnemyIndex(guid)
		--如果有空位则添加
		if emIdx ~= -1 then
			self:addSocialItem(player,emIdx,num)
			self:setEnemyTime(emIdx)
		else--如果没有空位找到时间最少并且仇恨值最少的
			local fuIdx = self:minHatredTimeIndex()
			self:addSocialItem(player,fuIdx,num)
			self:setEnemyTime(fuIdx)
		end
	end
end
--仇人时间戳
function AppSocialMgr:setEnemyTime(index)
	local idx = (index - SOCIAL_ENEMY_START) / MAX_FRIENT_COUNT + SOCIAL_ENEMY_TIME_START
	self:SetUInt32(idx,os.time())
end
function AppSocialMgr:getEnemyTime(index)
	local idx = (index - SOCIAL_ENEMY_START) / MAX_FRIENT_COUNT + SOCIAL_ENEMY_TIME_START
	return self:GetUInt32(idx)
end
function AppSocialMgr:minHatredTimeIndex()
	local minnum = 1073741824
	local minTime = os.time()
	local idx = -1

	for i=SOCIAL_ENEMY_START, SOCIAL_ENEMY_END, MAX_FRIENT_COUNT do
		local hatred = self:GetUInt16(i + 1,0)
		local time = self:getEnemyTime(i)
		if hatred < minnum or (hatred == minnum and  time < minTime) then
			minnum = hatred
			minTime = time
			idx = i
		end
	end

	return idx

end

function AppSocialMgr:getGuid(index)
	return self:GetStr(index)
end
--添加好友度
function AppSocialMgr:addFamiliay(guid,num)
	local idx = self:getFriendIndex(guid)

	if idx == -1 then
		return
	end

	local fam = self:GetUInt16(idx+1,0)
	local famlev = self:GetUInt16(idx+1,1)
	outFmtDebug("current fam %d,%d",fam,num)
	fam = fam + num
	outFmtDebug("current fam %d,%d,%d",fam,num,famlev)
	for i=famlev,#tb_social_familiay do
		local config = tb_social_familiay[i]
		if fam > config.exp then
			fam = fam - config.exp
			famlev = famlev + 1
		else
			break
		end
	end

	self:SetUInt16(idx+1,0,fam)
	self:SetUInt16(idx+1,1,famlev)

end


return AppSocialMgr