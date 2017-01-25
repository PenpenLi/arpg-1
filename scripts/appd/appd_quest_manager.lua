--���ܹ�����

local AppQuestMgr = class("AppQuestMgr", BinLogObject)

function AppQuestMgr:ctor()
	
end
---�ɾ�--------------------------------------------------
--��ȡ�ɾͽ���
function AppQuestMgr:getAchieve(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_CURRENT
	return self:GetUInt32(idx)
end
--���óɾͽ���
function AppQuestMgr:setAchieve(id,num)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_CURRENT
	self:SetUInt32(idx,num)
end
--�Ƿ���ȡ�ɾͽ���
function AppQuestMgr:getAchieveReward(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	return self:GetByte(idx,0)
end
--��ȡ�ɾͽ���
function AppQuestMgr:setAchieveReward(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	self:SetByte(idx,0,1)
end
--�Ƿ��ɳɾ�
function AppQuestMgr:getHasAchieve(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	return self:GetByte(idx,1)
end
--��ɳɾ�
function AppQuestMgr:setHasAchieve(id)
	local idx = QUEST_FIELD_ACHIEVE_START + (id - 1) * MAX_ACHIEVE_FIELD + ACHIEVE_FIELD_REWARD
	self:SetByte(idx,1,1)
end

--����ܳɾ͵���
function AppQuestMgr:addAchieveAll(num)
	self:AddUInt32(QUEST_FIELD_ACHIEVE_ALL,num)
end
--��ȡ�ܳɾ͵���
function AppQuestMgr:getAchieveAll()
	return self:GetUInt32(QUEST_FIELD_ACHIEVE_ALL)
end

--�ܳɾͽ���ID
function AppQuestMgr:getAchieveAllReward()
	return self:GetUInt32(QUEST_FIELD_ACHIEVE_REWARD)
end
--�����ܳɾͽ���ID
function AppQuestMgr:addAchieveAllReward()
	self:AddUInt32(QUEST_FIELD_ACHIEVE_REWARD,1)
end

---�ƺ�--------------------------------------------------
--��ӳƺ�ID
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

--�Ƿ�ӵ��ĳ���ƺ�
function AppQuestMgr:hasTitle(id)
	for i=QUEST_FIELD_TITLE_START,QUEST_FIELD_TITLE_END-1,MAX_TITLE_FIELD do
		if self:GetUInt16(i,0) == id then
			return true,i
		end
	end
	return false,0
end

--�ƺ�װ������
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
--���ʧЧ�ƺ�
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

-------------------------------����������-------------------------------
--[[
// ������ȡ�������
#define MAX_QUEST_COUNT 10
// �������Ŀ��
#define MAX_QUEST_TARGET_COUNT 5
QUEST_TARGET_INFO_SHORT0	= 0,	//0:״̬, 1:Ŀ��ֵ
QUEST_TARGET_INFO_PROCESS	= 1,	//����
MAX_QUEST_TARGET_INFO_COUNT		

QUEST_INFO_ID				= 0,					//����id
QUEST_INFO_STEP_START		= QUEST_INFO_ID + 1,	//����ֲ��迪ʼ
QUEST_INFO_STEP_END			= QUEST_INFO_STEP_START + MAX_QUEST_STEP_COUNT,	//����ֲ������
MAX_QUEST_INFO_COUNT		= QUEST_INFO_STEP_END,

QUEST_FIELD_QUEST_START			//����ʼ
QUEST_FIELD_QUEST_END			//�������

	QUEST_STATUS_NONE           = 0,		// 
	QUEST_STATUS_COMPLETE       = 1,		//���
	QUEST_STATUS_UNAVAILABLE    = 2,		//�ò����ģ�û�յģ��������õ�???
	QUEST_STATUS_INCOMPLETE     = 3,		//����ȫ,δ���
	QUEST_STATUS_AVAILABLE      = 4,		//��Ч���ɽ���
	QUEST_STATUS_FAILED         = 5,		//ʧ��
--]]

-- ������һ������������
function AppQuestMgr:ActiveFlowingQuests(questId)
	local config = tb_quest[questId]
	
	-- �Ƿ�����һ������
	if config.nextid > 0 then
		if tb_quest[config.nextid] then
			self:OnAddQuest(config.nextid)
		end
	end
	
	-- ֧������
	if #config.acitveIds then
		for _, id in pairs(config.acitveIds) do
			if tb_quest[id] then
				self:OnAddQuest(id)
			end
		end
	end
end

-- ��ȡ����
function AppQuestMgr:OnPickQuest(indx)
	local start = QUEST_FIELD_QUEST_START + indx * MAX_QUEST_INFO_COUNT
	local playerInfo = self:getOwner()
	
	local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
	local state   = self:GetUInt16(start + QUEST_INFO_ID, 1)
	if state == QUEST_STATUS_COMPLETE then
		self:OnRemoveQuest(start)
		-- ��ȡ����
		if #tb_quest[questId].rewards > 0 then
			local gender = playerInfo:GetGender()
			if #tb_quest[questId].rewards == 1 then
				gender = 1
			end
			local rewards = tb_quest[questId].rewards[gender]
			playerInfo:AppdAddItems(rewards, MONEY_CHANGE_QUEST, LOG_ITEM_OPER_TYPE_QUEST)
		end
		self:ActiveFlowingQuests(questId)
	end
end

-- �����Ҫ��ʼ�����ȵ�
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

-- �������ж����������Ƿ����
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

-- ���ӷ���������
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

-- ͨ��λ���Ƴ�����
function AppQuestMgr:OnRemoveQuest(start)
	local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)

	for i = 0, MAX_QUEST_INFO_COUNT-1 do
		self:SetUInt32(start + i, 0)
	end
end

-- ͨ������id�Ƴ�����
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

-- ���������Ƿ���Ҫ����
function AppQuestMgr:OnUpdate(questTargetType, params)
	for start = QUEST_FIELD_QUEST_START, QUEST_FIELD_QUEST_END - 1, MAX_QUEST_INFO_COUNT do
		local questId = self:GetUInt16(start + QUEST_INFO_ID, 0)
		local state   = self:GetUInt16(start + QUEST_INFO_ID, 1)

		local config = tb_quest[questId]
		if config and QUEST_STATUS_INCOMPLETE == state then
			local updated = self:CheckQuestUpdate(questTargetType, start, params)
			-- ���������Ƿ����
			if updated then
				self:CheckQuestFinish(start)
			end
		end
	end
end

-- ����Ƿ��������
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
		-- δ��ɵĲ���Ҫ����
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

-- ��������Ƿ����
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

-------------------------------����������-------------------------------
-- ������guid
function AppQuestMgr:getPlayerGuid()
	--��Ʒ������guidת���guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--��ü��ܹ�������ӵ����
function AppQuestMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end


return AppQuestMgr