-- ����ĳ���ɾ�
function PlayerInfo:SetAchieve(id,num)
	local questMgr = self:getQuestMgr()
	
	local config = tb_achieve_base[id]
	if config == nil then
		return
	end
	
	--�ж��Ƿ������
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

-- ���ĳ���ɾ�
function PlayerInfo:AddAchieve(id,num)
	local questMgr = self:getQuestMgr()
	local cur = questMgr:getAchieve(id)
	cur = cur + num
	self:SetAchieve(id,cur)
end

--��ȡ�ɾ�ֵ
function PlayerInfo:GetAchieve(id)
	local questMgr = self:getQuestMgr()
	return questMgr:getAchieve(id)
end

--��ȡ�ɾͽ���
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
	
	--��ӳƺ�
	if config.title > 0 then
		self:AddTitle(config.title)
	end
	
end

--��ȡ�ܳɾͽ���
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

--��ӳƺ�
function PlayerInfo:AddTitle(id)
	local questMgr = self:getQuestMgr()
	questMgr:addTitle(id)
end
--���óƺ�
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
--��ʼ���ƺ�
function PlayerInfo:InitTitle(id)
	local questMgr = self:getQuestMgr()
	local has,idx = questMgr:hasTitle(id)
	
	if has and id ~=0 then
		questMgr:initTitle(idx)
	end
end
--�ƺ�װ������
function PlayerInfo:calculTitleAttr(attrs)
	local questMgr = self:getQuestMgr()
	questMgr:calculTitleAttr(attrs)
end
--�Ƴ�ʧЧ�ƺ�
function PlayerInfo:removeExpireTitle()
	local questMgr = self:getQuestMgr()
	questMgr:removeExpireTitle()
end


function PlayerInfo:pickQuest(indx)
	local questMgr = self:getQuestMgr()
	questMgr:OnPickQuest(indx)
end
