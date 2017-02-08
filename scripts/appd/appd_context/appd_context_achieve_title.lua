-- 设置某个成就
function PlayerInfo:SetAchieve(id,num)
	local questMgr = self:getQuestMgr()
	
	local config = tb_achieve_base[id]
	if config == nil then
		return
	end
	
	--判断是否已完成
	if questMgr:getHasAchieve(id) == 1 then
		return
	end
	
	if num >= config.maxnum then
		questMgr:setAchieve(id,config.maxnum)
		questMgr:setHasAchieve(id)
		questMgr:addAchieveAll(config.achval)
		return
	end
	
	questMgr:setAchieve(id,num)
	
end

-- 添加某个成就
function PlayerInfo:AddAchieve(id,num)
	local questMgr = self:getQuestMgr()
	local cur = questMgr:getAchieve(id)
	cur = cur + num
	self:SetAchieve(id,cur)
end

--获取成就值
function PlayerInfo:GetAchieve(id)
	local questMgr = self:getQuestMgr()
	return questMgr:getAchieve(id)
end

--领取成就奖励
function PlayerInfo:AchieveReward(id)
	local questMgr = self:getQuestMgr()
	
	if questMgr:getHasAchieve(id) == 0 then
		self:CallOptResult(OPRATE_TYPE_ACHIEVE, ACHIEVE_OPERATE_NO_GET)
		return
	end
	
	if questMgr:getAchieveReward(id) == 1 then
		self:CallOptResult(OPRATE_TYPE_ACHIEVE, ACHIEVE_OPERATE_HASGET)
		return
	end
	
	local config = tb_achieve_base[id]
	if config == nil then
		return
	end
	
	self:AppdAddItems(config.reward,LOG_ITEM_OPER_TYPE_ACHIEVE)
	
	questMgr:setAchieveReward(id)
	
	--添加称号
	if config.title > 0 then
		self:AddTitle(config.title)
	end
	
end

--领取总成就奖励
function PlayerInfo:AchieveAllReward()
	local questMgr = self:getQuestMgr()
	local allnum = questMgr:getAchieveAll()
	
	local rewardID = questMgr:getAchieveAllReward()
	
	local targetReward = rewardID + 1
	
	local config = tb_achieve_progress[targetReward]
	if config == nil then
		return
	end
	
	outFmtDebug("rewardID %d %d %d",targetReward,allnum,config.achval)
	
	if allnum >= config.achval then
		self:AppdAddItems(config.reward,LOG_ITEM_OPER_TYPE_ACHIEVE)
		questMgr:addAchieveAllReward()
	else 
		self:CallOptResult(OPRATE_TYPE_ACHIEVE, ACHIEVE_OPERATE_NO_ALL)
	end
	
end

--添加称号
function PlayerInfo:AddTitle(id)
	local questMgr = self:getQuestMgr()
	questMgr:addTitle(id)
end
--设置称号
function PlayerInfo:SetTitle(id)
	local questMgr = self:getQuestMgr()
	local has,idx = questMgr:hasTitle(id)
	
	if has and id ~=0 then
		questMgr:initTitle(idx)
	end
	
	if id == 0 then
		has = true
	end
	
	if has then
		self:SetByte(PLAYER_FIELD_BYTES_2,3,id)
		self:CallOptResult(OPRATE_TYPE_ACHIEVE, ACHIEVE_OPERATE_TITLE_SUC)
	else
		self:CallOptResult(OPRATE_TYPE_ACHIEVE, ACHIEVE_OPERATE_TITLE_FAL)
	end
	self:RecalcAttrAndBattlePoint()
end
--初始化称号
function PlayerInfo:InitTitle(id)
	local questMgr = self:getQuestMgr()
	local has,idx = questMgr:hasTitle(id)
	
	if has and id ~=0 then
		questMgr:initTitle(idx)
	end
end
--称号装备重算
function PlayerInfo:calculTitleAttr(attrs)
	local questMgr = self:getQuestMgr()
	questMgr:calculTitleAttr(attrs)
end
--移除失效称号
function PlayerInfo:removeExpireTitle()
	local questMgr = self:getQuestMgr()
	questMgr:removeExpireTitle()
end


function PlayerInfo:pickQuest(indx)
	local questMgr = self:getQuestMgr()
	questMgr:OnPickQuest(indx)
end
