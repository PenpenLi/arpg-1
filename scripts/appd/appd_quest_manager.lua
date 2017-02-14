--技能管理器

local AppQuestMgr = class("AppQuestMgr", BinLogObject)

function AppQuestMgr:ctor()
	
end
---成就--------------------------------------------------
--获取成就进度
function AppQuestMgr:getAchieve(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_CURRENT
	return self:GetUInt32(idx)
end
--设置成就进度
function AppQuestMgr:setAchieve(id,num)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_CURRENT
	self:SetUInt32(idx,num)
end
--是否领取成就奖励
function AppQuestMgr:getAchieveReward(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	return self:GetByte(idx,0)
end
--领取成就奖励
function AppQuestMgr:setAchieveReward(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	self:SetByte(idx,0,1)
end
--是否达成成就
function AppQuestMgr:getHasAchieve(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	return self:GetByte(idx,1)
end
--达成成就
function AppQuestMgr:setHasAchieve(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	self:SetByte(idx,1,1)
end

--添加总成就点数
function AppQuestMgr:addAchieveAll(num)
	self:AddUInt32(QUEST_FIELD_ACHIEVE_ALL,num)
end
--获取总成就点数
function AppQuestMgr:getAchieveAll()
	return self:GetUInt32(QUEST_FIELD_ACHIEVE_ALL)
end

--总成就奖励ID
function AppQuestMgr:getAchieveAllReward()
	return self:GetUInt32(QUEST_FIELD_ACHIEVE_REWARD)
end
--设置总成就奖励ID
function AppQuestMgr:addAchieveAllReward()
	self:AddUInt32(QUEST_FIELD_ACHIEVE_REWARD,1)
end

---称号--------------------------------------------------
--添加称号ID
function AppQuestMgr:addTitle(id)
	local config = tb_title_base[id]
	if not config then 
		return false
	end
	
	local hast,tid = self:hasTitle(id)
	if hast then
		if config.limtime > 0 then
			self:SetUInt32(tid + TITLE_FIELD_TIME,os.time() + config.limtime * 60)
		else
			self:SetUInt32(tid + TITLE_FIELD_TIME,0)
		end
		return true
	end
	
	for i=QUEST_FIELD_TITLE_START,QUEST_FIELD_TITLE_END-1,MAX_TITLE_FIELD do
		if self:GetUInt16(i,0) == 0 then
			self:SetUInt16(i,0,id)
			self:SetUInt16(i,1,0)
			if config.limtime > 0 then
				self:SetUInt32(i + TITLE_FIELD_TIME,os.time() + config.limtime * 60)
			else
				self:SetUInt32(i + TITLE_FIELD_TIME,0)
			end
			return true
		end
	end
	
	return false
end

--是否拥有某个称号
function AppQuestMgr:hasTitle(id)
	for i=QUEST_FIELD_TITLE_START,QUEST_FIELD_TITLE_END-1,MAX_TITLE_FIELD do
		if self:GetUInt16(i,0) == id then
			return true,i
		end
	end
	return false,0
end

--初始化称号
function AppQuestMgr:initTitle(idx)
	if self:GetUInt16(idx,1) == 0 then
		self:SetUInt16(idx,1,1)
	end
end

--称号装备重算
function AppQuestMgr:calculTitleAttr(attrs)
	
	local owner = self:getOwner()
	local equtitle = owner:GetTitle()
	if equtitle == 0 then
		return
	end
	
	local config = tb_title_base[equtitle].prop
	
	for i=1,#config do
		attrs[config[i][1]] = attrs[config[i][1]] + config[i][2]
	end

end
--检测失效称号
function AppQuestMgr:removeExpireTitle()
	local owner = self:getOwner()
	local cur = owner:GetTitle()
	for i=QUEST_FIELD_TITLE_START,QUEST_FIELD_TITLE_END-1,MAX_TITLE_FIELD do
		local id = self:GetUInt16(i,0)
		if id ~= 0 then
			local time  = self:GetUInt32(i + TITLE_FIELD_TIME)
			if time > 0 and time < os.time() then
				self:SetUInt16(i,0,0) 
				self:SetUInt32(i + TITLE_FIELD_TIME,0)
				
				if cur == id then
					owner:SetTitle(0)
				end
			end
		end
	end
end
-------------------------------福利-------------------------------
--是否领取首冲奖励
function AppQuestMgr:getWelfareShouchong()
	return self:GetUInt32(QUEST_FIELD_WELFARE_SHOUCHONG)
end
--领取首冲奖励标记
function AppQuestMgr:setWelfareShouchong()
	self:SetUInt32(QUEST_FIELD_WELFARE_SHOUCHONG,1)
end

--每日签到奖励是否已领取
function AppQuestMgr:getWelfareCheckIn(day)
	return self:GetBit(QUEST_FIELD_WELFARE_CHECKIN,day-1)
end
--领取每日签到奖励
function AppQuestMgr:setWelfareCheckIn(day)
	return self:SetBit(QUEST_FIELD_WELFARE_CHECKIN,day-1)
end
--本月累积签到次数
function AppQuestMgr:getWelfareCheckInDayNum()
	local num = 0
	for i = 0,31 do
		if self:GetBit(QUEST_FIELD_WELFARE_CHECKIN,i) then
			num = num + 1
		end
	end
	return num
end

--累积每日签到奖励是否已领取
function AppQuestMgr:getWelfareCheckInAll(id)
	return self:GetBit(QUEST_FIELD_WELFARE_CHECKIN_ALL,id)
end

--领取累积每日签到奖励
function AppQuestMgr:setWelfareCheckInAll(id)
	return self:SetBit(QUEST_FIELD_WELFARE_CHECKIN_ALL,id)
end

--等级是否已领取
function AppQuestMgr:getWelfareLev(id)
	return self:GetBit(QUEST_FIELD_WELFARE_LEVEL,id-1)
end
--领取等级奖励
function AppQuestMgr:setWelfareLev(id)
	return self:SetBit(QUEST_FIELD_WELFARE_LEVEL,id-1)
end

--type类型所有可以找回的次数
function AppQuestMgr:setWelfareBackAllNum(type,allnum)
	local idx = QUEST_FIELD_WELFARE_BACK_START + (type-1) * MAX_WELFA_BACK_ITEM + WELFA_BACK_ITEM_NUM
	self:SetUInt32(idx,allnum)
end
function AppQuestMgr:getWelfareBackAllNum(type)
	local idx = QUEST_FIELD_WELFARE_BACK_START + (type-1) * MAX_WELFA_BACK_ITEM + WELFA_BACK_ITEM_NUM
	return self:GetUInt32(idx)
end
--type类型下指定时间的已使用次数
function AppQuestMgr:getWelfareBackNum(type,time)
	local startIdx = QUEST_FIELD_WELFARE_BACK_START + (type-1) * MAX_WELFA_BACK_ITEM
	
	for i=WELFA_BACK_ITEM,WELFA_BACK_ITEM_END,2 do
		local idx = startIdx + i
		local dtime = self:GetUInt32(idx)
		if time == dtime then
			return self:GetUInt32(idx+1)
		end
	end
	
	return 0
end

--添加type类型下指定时间的已使用次数
function AppQuestMgr:addWelfareBackNum(type,time,num)
	
	local targetIdx,outTimeIdx = self:getWelfareTimeIdx(type,time)

	if targetIdx ~= 0 then
		local curnum = self:GetUInt32(targetIdx+1)
		curnum = curnum + num
		self:SetUInt32(targetIdx+1,curnum)
	elseif outTimeIdx ~=0 then
		self:SetUInt32(outTimeIdx,time)
		self:SetUInt32(outTimeIdx+1,num)
	end
	
end

function AppQuestMgr:setWelfareBackNum(type,time,num)
	
	local targetIdx,outTimeIdx = self:getWelfareTimeIdx(type,time)

	if targetIdx ~= 0 then
		self:SetUInt32(targetIdx+1,num)
	elseif outTimeIdx ~=0 then
		self:SetUInt32(outTimeIdx,time)
		self:SetUInt32(outTimeIdx+1,num)
	end
	
end


function AppQuestMgr:getWelfareTimeIdx(type,time)
	local startIdx = QUEST_FIELD_WELFARE_BACK_START + (type-1) * MAX_WELFA_BACK_ITEM
	local targetIdx = 0
	local outTimeIdx = 0
	local curTime = GetTodayStartTimestamp(0)
	for i=WELFA_BACK_ITEM,WELFA_BACK_ITEM_END-1,2 do
		--outFmtDebug("welf %d",i)
		local idx = startIdx + i
		local dtime = self:GetUInt32(idx)
		if time == dtime then
			targetIdx = idx
			break
		elseif dtime == 0 then
			outTimeIdx = idx
		elseif self:testOutTime(curTime,dtime) then
			outTimeIdx = idx
		end
	end
	return targetIdx,outTimeIdx
end

function AppQuestMgr:testOutTime(curTime,targetTime)
	local num = curTime - targetTime
	--outFmtDebug("chazhi %d",num)
	if num >= 345600 then
		return true
	end
	return false
end


-------------------------------下面是任务-------------------------------
--[[
// 最多可领取任务个数
#define MAX_QUEST_COUNT 10
// 任务最多目标
#define MAX_QUEST_TARGET_COUNT 5
QUEST_TARGET_INFO_SHORT0	= 0,	//0:状态, 1:目标值
QUEST_TARGET_INFO_PROCESS	= 1,	//进度
MAX_QUEST_TARGET_INFO_COUNT		

QUEST_INFO_ID				= 0,					//任务id
QUEST_INFO_STEP_START		= QUEST_INFO_ID + 1,	//任务分步骤开始
QUEST_INFO_STEP_END			= QUEST_INFO_STEP_START + MAX_QUEST_STEP_COUNT,	//任务分步骤结束
MAX_QUEST_INFO_COUNT		= QUEST_INFO_STEP_END,

QUEST_FIELD_QUEST_START			//任务开始
QUEST_FIELD_QUEST_END			//任务结束

	QUEST_STATUS_NONE           = 0,		// 
	QUEST_STATUS_COMPLETE       = 1,		//完成
	QUEST_STATUS_UNAVAILABLE    = 2,		//得不到的，没空的，不能利用的???
	QUEST_STATUS_INCOMPLETE     = 3,		//不完全,未完成
	QUEST_STATUS_AVAILABLE      = 4,		//有效，可接受
	QUEST_STATUS_FAILED         = 5,		//失败
--]]

-- 激活下一个关联的任务
function AppQuestMgr:ActiveFlowingQuests(questId)
	local config = tb_quest[questId]
	
	-- 是否有下一个主线
	if config.nextid > 0 then
		if tb_quest[config.nextid] then
			self:OnAddQuest(config.nextid)
		end
	end
	
	-- 支线任务
	if #config.acitveIds then
		for _, id in pairs(config.acitveIds) do
			if tb_quest[id] then
				self:OnAddQuest(id)
			end
		end
	end
end

-- 领取章节奖励
function AppQuestMgr:OnPickQuestChapterReward(indx)
	local rewards = tb_quest_chapter[indx].items
	local playerInfo = self:getOwner()
	playerInfo:AppdAddItems(rewards, MONEY_CHANGE_QUEST, LOG_ITEM_OPER_TYPE_QUEST)
	--playerInfo:SetQuestChapterPicked(indx)
end

-- 领取奖励
function AppQuestMgr:OnPickQuest(indx)
	local start = QUEST_FIELD_QUEST_START + indx * MAX_QUEST_INFO_COUNT
	local playerInfo = self:getOwner()
	
	local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
	local state   = self:GetUInt16(start + QUEST_INFO_ID, 1)
	if state == QUEST_STATUS_COMPLETE then
		self:OnRemoveQuest(start)
		-- 领取奖励
		if #tb_quest[questId].rewards > 0 then
			local gender = playerInfo:GetGender()
			if #tb_quest[questId].rewards == 1 then
				gender = 1
			end
			local rewards = tb_quest[questId].rewards[gender]
			-- 判断背包格子是否足够
			local itemMgr = playerInfo:getItemMgr()
			local emptys  = itemMgr:getEmptyCount(BAG_TYPE_MAIN_BAG)
			if emptys < #rewards then
				playerInfo:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_BAG_FULL)
				return
			end
			playerInfo:AppdAddItems(rewards, MONEY_CHANGE_QUEST, LOG_ITEM_OPER_TYPE_QUEST)
		end
		
		-- 如果是主线任务 当前主线任务id + 1000000 表示完成
		if tb_quest[questId].type == QUEST_TYPE_MAIN then
			playerInfo:SetMainQuestID(1000000 + questId)
		end
		
		-- 如果是章节最后一个任务 自动领取章节奖励
		if tb_quest[questId].chapterLast == 1 then
			local chapterIndex = tb_quest[questId].chapter
			self:OnPickQuestChapterReward(chapterIndex)
		end
		self:ActiveFlowingQuests(questId)
	end
end

-- 如果需要初始化进度的
function AppQuestMgr:ProcessInit(start)
	local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
	local config = tb_quest[questId]
	local targets = config.targets
	local size = math.min(#targets, MAX_QUEST_TARGET_COUNT)
	local playerInfo = self:getOwner()
	
	for i = 1, size do
		local targetInfo = targets[ i ]
		local targetType = targetInfo[ 1 ]
		
		if QUEST_UPDATE_CALLBACK[targetType] then
			local dest = QUEST_UPDATE_CALLBACK[targetType]:GetTargetValue(targetInfo)
			local qtIndx = GetOneQuestTargetStartIndx(start, i-1)
			self:SetUInt16(qtIndx + QUEST_TARGET_INFO_SHORT0, 1, dest)
			
			QUEST_UPDATE_CALLBACK[targetType]:OnInit (playerInfo, start, i-1)
		end
	end
end

-- 升级了判断主线任务是否解锁
function AppQuestMgr:OnCheckMainQuestActive(currLevel)
	for start = QUEST_FIELD_QUEST_START, QUEST_FIELD_QUEST_END - 1, MAX_QUEST_INFO_COUNT do
		local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
		local state   = self:GetUInt16(start + QUEST_INFO_ID, 1)
		if questId > 0 and state == QUEST_STATUS_UNAVAILABLE then
			if tb_quest[questId].level <= currLevel then
				local state = QUEST_STATUS_INCOMPLETE
				self:SetUInt16(start + QUEST_INFO_ID, 1, state)
				self:ProcessInit(start)
				self:CheckQuestFinish(start)
			end
			return
		end
	end
end

-- 增加非主线任务
function AppQuestMgr:OnAddQuest(addQuestId)
	local playerInfo = self:getOwner()
	
	for start = QUEST_FIELD_QUEST_START, QUEST_FIELD_QUEST_END - 1, MAX_QUEST_INFO_COUNT do
		local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)

		if questId == 0 then
			local state = QUEST_STATUS_INCOMPLETE
			if tb_quest[addQuestId].level > playerInfo:GetLevel() then
				state = QUEST_STATUS_UNAVAILABLE
			end
			self:SetUInt16(start + QUEST_INFO_ID, 0, addQuestId)
			self:SetUInt16(start + QUEST_INFO_ID, 1, state)
			if state == QUEST_STATUS_INCOMPLETE then
				self:ProcessInit(start)
				self:CheckQuestFinish(start)
			end
			if tb_quest[addQuestId].type == QUEST_TYPE_MAIN then
				playerInfo:SetMainQuestID(addQuestId)
			end
			return
		end
	end
	
	outFmtDebug("quest max count excceed for add quest %d", addQuestId)
end

-- 通过位置移除任务
function AppQuestMgr:OnRemoveQuest(start)
	local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)

	for i = 0, MAX_QUEST_INFO_COUNT-1 do
		self:SetUInt32(start + i, 0)
	end
end

-- 通过任务id移除任务
function AppQuestMgr:OnRemoveQuestByQuestID(removeQuestId)
	for start = QUEST_FIELD_QUEST_START, QUEST_FIELD_QUEST_END - 1, MAX_QUEST_INFO_COUNT do
		local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)

		if questId == removeQuestId then
			for i = 0, MAX_QUEST_INFO_COUNT-1 do
				self:SetUInt32(start + i, 0)
			end
			return
		end
	end
end

-- 选择主线任务
function AppQuestMgr:OnSelectMainQuest(id)
	-- 换的不是主线任务 不让换
	if tb_quest[id].type ~= QUEST_TYPE_MAIN then
		return
	end
	
	-- 删除原来的主线任务
	for start = QUEST_FIELD_QUEST_START, QUEST_FIELD_QUEST_END - 1, MAX_QUEST_INFO_COUNT do
		local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)

		if questId > 0 then
			if tb_quest[questId].type == QUEST_TYPE_MAIN then
				self:OnRemoveQuest(start)
				break
			end
		end
	end
	
	-- 加入新的主线任务
	self:OnAddQuest(id)
end

-- 遍历任务是否需要更新
function AppQuestMgr:OnUpdate(questTargetType, params)
	for start = QUEST_FIELD_QUEST_START, QUEST_FIELD_QUEST_END - 1, MAX_QUEST_INFO_COUNT do
		local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
		local state   = self:GetUInt16(start + QUEST_INFO_ID, 1)

		local config = tb_quest[questId]
		if config and QUEST_STATUS_INCOMPLETE == state then
			local updated = self:CheckQuestUpdate(questTargetType, start, params)
			-- 所有任务是否完成
			if updated then
				self:CheckQuestFinish(start)
			end
		end
	end
end

-- 检查是否更新任务
function AppQuestMgr:CheckQuestUpdate(questTargetType, start, params)
	local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
	local config = tb_quest[questId]
	local targets = config.targets
	local size = math.min(#targets, MAX_QUEST_TARGET_COUNT)
	
	local updated = false
	for i = 1, size do
		local target = targets[ i ]
		local targetType = target[ 1 ]
		local qtIndx = GetOneQuestTargetStartIndx(start, i-1)
		-- 未完成的才需要更新
		if targetType == questTargetType and self:GetUInt16(qtIndx + QUEST_TARGET_INFO_SHORT0, 0) == 0 then
			if QUEST_UPDATE_CALLBACK[targetType] then
				if QUEST_UPDATE_CALLBACK[targetType]:OnUpdate(self.ptr, start, i-1, params) then
					updated = true
				end
			end
		end
	end
	
	return updated
end

-- 检查任务是否完成
function AppQuestMgr:CheckQuestFinish(start)
	local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
	local config = tb_quest[questId]
	local targets = config.targets
	local size = math.min(#targets, MAX_QUEST_TARGET_COUNT)
	
	for i = 1, size do
		local qtIndx = GetOneQuestTargetStartIndx(start, i-1)
		if self:GetUInt16(qtIndx + QUEST_TARGET_INFO_SHORT0, 0) == 0 then
			return
		end
	end
	
	self:SetUInt16(start + QUEST_INFO_ID, 1, QUEST_STATUS_COMPLETE)
end

-------------------------------上面是任务-------------------------------
-- 获得玩家guid
function AppQuestMgr:getPlayerGuid()
	--物品管理器guid转玩家guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--获得技能管理器的拥有者
function AppQuestMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end


return AppQuestMgr