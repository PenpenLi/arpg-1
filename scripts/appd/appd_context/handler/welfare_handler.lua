
--领取首冲奖励
function PlayerInfo:Handle_Welfare_Shouchong(pkt)
	--local questMgr = self:getQuestMgr()
	self:WelfareShouchong()
end

--领取签到奖励
function PlayerInfo:Handle_Welfare_CheckIn(pkt)
	local day = tonumber(os.date("%d", os.time()))
	self:WelfareCheckIn(day)
end

--领取累积签到奖励
function PlayerInfo:Handle_Welfare_CheckInAll(pkt)
	local id = pkt.id
	self:WelfareCheckInAll(id)
end
--补签奖励
function PlayerInfo:Handle_Welfare_CheckIn_Getback(pkt)

	local day = pkt.id
	--outFmtDebug("day get back %d",day)
	local curday = tonumber(os.date("%d", os.time()))
	if day >= curday then
		return
	end
	if self:GetVIP() == 0 then
		return
	end
	
	self:WelfareCheckIn(day)
end

--领取等级奖励
function PlayerInfo:Handle_Welfare_Level(pkt)
	local id = pkt.id
	self:WelfareLevel(id)
end

--领取找回奖励
function PlayerInfo:Handle_Welfare_ActiveGetback(pkt)
	local type = pkt.id
	local best
	if pkt.best == 1 then
		best = true
	else 
		best = false
	end
	local num = pkt.num
	self:GetWelfareBackReward(type,best,num)
end
--一键找回奖励列表
function PlayerInfo:Handle_Welfare_List_Getback(pkt)
	local best
	if pkt.best == 1 then
		best = true
	else 
		best = false
	end
	self:GetWelfareAllRewardList(best)
end
--一键领取找回奖励
function PlayerInfo:Handle_Welfare_All_Getback(pkt)
	local best
	if pkt.best == 1 then
		best = true
	else 
		best = false
	end
	self:GetWelfareAllReward(best)
end