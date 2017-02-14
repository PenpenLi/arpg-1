--领取首充奖励
function PlayerInfo:WelfareShouchong()
	local questMgr = self:getQuestMgr()
	if questMgr:getWelfareShouchong() == 1 then
		outFmtDebug("has get shouchong")
		return
	end
	
	
	if self:GetRechageSum() == 0 then
		outFmtDebug("has never Rechage")
		return
	end
	
	local config = tb_welfare_shouchong[1]
	if not config then
		return
	end
	
	self:AppdAddItems(config.item,LOG_ITEM_OPER_TYPE_SHOUCHONG)
	questMgr:setWelfareShouchong()
end
--每日签到奖励
function PlayerInfo:WelfareCheckIn(day)
	
	local questMgr = self:getQuestMgr()
	
	if questMgr:getWelfareCheckIn(day) then 
		self:CallOptResult(OPRATE_TYPE_ACTIVITY, ACTIVITY_OPERATE_HASGET)
		return
	end
	
	local config = tb_welfare_checkin[day]
	if not config then
		return
	end
	
	local vip = self:GetVIP()
	local times = 1
	if vip >= config.vip then
		times = config.times
	end
	
	local itemdic = {}
	
	if times == 1 then
		itemdic = config.item
	else 
		for _,v in ipairs(config.item) do
			local tab = {}
			table.insert(tab,v[1])
			table.insert(tab,v[2] * times)
			
			table.insert(itemdic,tab)
		end
	end
	
	self:AppdAddItems(itemdic,LOG_ITEM_OPER_TYPE_CHECKIN)
	
	questMgr:setWelfareCheckIn(day)
end
--领取累积签到奖励
function PlayerInfo:WelfareCheckInAll(id)
	local questMgr = self:getQuestMgr()
	
	if questMgr:getWelfareCheckInAll(id) then 
		self:CallOptResult(OPRATE_TYPE_ACTIVITY, ACTIVITY_OPERATE_HASGET)
		return
	end
	
	local config = tb_welfare_checkin_all[id]
	if not config then
		return
	end
	
	local allnum = questMgr:getWelfareCheckInDayNum()
	
	if allnum >= config.num then
		self:AppdAddItems(config.item,LOG_ITEM_OPER_TYPE_CHECKIN)
		questMgr:setWelfareCheckInAll(id)
	end
	
end
--领取等级奖励
function PlayerInfo:WelfareLevel(id)
	--outFmtDebug("000000000000")
	local questMgr = self:getQuestMgr()
	
	if questMgr:getWelfareLev(id) then 
		self:CallOptResult(OPRATE_TYPE_ACTIVITY, ACTIVITY_OPERATE_HASGET)
		return
	end
	
	local config = tb_welfare_level[id]
	if not config then
		return
	end
	
	if self:GetLevel() < config.lev then
		return
	end
	
	self:AppdAddItems(config.item,LOG_ITEM_OPER_TYPE_CHECKIN)
	
	questMgr:setWelfareLev(id)
end
--福利找回奖励
function PlayerInfo:GetWelfareBackReward(type,bestGetback,backNum)
	local questMgr = self:getQuestMgr()
	local curnum = questMgr:getWelfareBackAllNum(type)
	
	local maxNum = self:GetWelfareBackMaxNum(type)
	
	local allNum = questMgr:getWelfareBackAllNum(type)
	
	--for j=-3,-1 do
	--	local time = GetTodayStartTimestamp(j)
	--	local curnum = questMgr:getWelfareBackNum(type,time)
	--	allNum = allNum + maxNum - curnum
	--	outFmtDebug("type:%d curnum:%d",type,curnum)
	--end
	
	if allNum < backNum then
		return
	end
	
	local cost = self:GetWelfareBackRewardCost(type,bestGetback)
	
	if not self:costMoneys(MONEY_CHANGE_WELF_ACTIVE_GETBACK, cost, backNum) then
		self:CallOptResult(OPERTE_TYPE_NPCBUY, NPC_BUY_MONEY_NO_ENOUGH)
		return
	end
	
	local rewardConfig = self:GetWelfareBackRewardData(type,bestGetback)
	
	if rewardConfig then
		self:AppdAddItems(rewardConfig,LOG_ITEM_OPER_TYPE_GETBACK,LOG_ITEM_OPER_TYPE_GETBACK,backNum)
	end
	
	local lastNum = backNum
	
	for j=-3,-1 do
		
		local time = GetTodayStartTimestamp(j)
		
		
		local curNum = questMgr:getWelfareBackNum(type,time)
		local lastItemNum = maxNum - curNum
		if lastNum < lastItemNum then
			questMgr:addWelfareBackNum(type,time,lastNum)
			lastNum = 0
			break
		else 
			questMgr:addWelfareBackNum(type,time,lastItemNum)
			lastNum = lastNum - lastItemNum
		end
		
	end
	
	self:SetWelfareBackAllNum()
	
end

--添加可以找回的记录
function PlayerInfo:AddWelfareBackLog(type,num)
	local daytime = GetTodayStartTimestamp(0)
	local questMgr = self:getQuestMgr()
	questMgr:addWelfareBackNum(type,daytime,num)
	
	self:SetWelfareBackAllNum()
end

function PlayerInfo:AddWelfareBackGmLog(type,num,day)
	local off = -day
	local daytime = GetTodayStartTimestamp(off)
	local questMgr = self:getQuestMgr()
	questMgr:addWelfareBackNum(type,daytime,num)
	
	self:SetWelfareBackAllNum()
end

--根据日志重算所有次数
function PlayerInfo:SetWelfareBackAllNum()
	outFmtDebug("----------------------------------")
	local questMgr = self:getQuestMgr()
	--找回类型循环
	for i=0,WELFA_BACK_TYPE_COUNT do
		local type = i+1
		local maxNum = self:GetWelfareBackMaxNum(type)
		if maxNum > 0 then
			local allNum = 0
			--找回天数循环
			for j=-3,-1 do
				local time = GetTodayStartTimestamp(j)
				local curnum = questMgr:getWelfareBackNum(type,time)
				allNum = allNum + maxNum - curnum
				outFmtDebug("type:%d curnum:%d",type,curnum)
			end
			
			local time = GetTodayStartTimestamp(0)
			local curnum = questMgr:getWelfareBackNum(type,time)
			outFmtDebug("type:%d today:%d",type,curnum)
			
			questMgr:setWelfareBackAllNum(type,allNum)
			outFmtDebug("--------")
		end
	end
end

function PlayerInfo:GetWelfareBackMaxNum(type)
	-- 1-5 表示资源副本 	
	if type >= 1 and type <= 5 then
		return tb_instance_res[type].times
	end

	return 0
end

function PlayerInfo:GetWelfareBackRewardData(type,bestGetback)
	-- 1-5 表示资源副本 	
	if type >= 1 and type <= 5 then
		local lev = self:GetLevel()
		local id = type * 10000 + lev * 100
		local config = tb_welfare_back_data[id]
		
		if config then
			if bestGetback then
				return config.bestitem
			else
				return config.baseitem
			end
		end
	end
	return nil
end

function PlayerInfo:GetWelfareBackRewardCost(type,bestGetback)
	local config = tb_welfare_back[type]
	local cost
	if bestGetback then
		cost = GetCostMulTab(config.allcost,config.alldc/10)
	else
		cost = GetCostMulTab(config.basecost,config.basedc/10)
	end
	return cost
end