local protocols = require('share.protocols')

local AppInstanceMgr = class("AppInstanceMgr", BinLogObject)

function AppInstanceMgr:ctor()
	
end

function AppInstanceMgr:checkIfCanEnterVIP(id, hard)

	local config = tb_map_vip[id]

	-- �ж�VIP�Ƿ���������
	local player = self:getOwner()
	if not player:isVIP(config.vip) then
		outFmtError("vip level not satisfy")
		return
	end
	
	if not self:isEnoughForceByHard(id, hard, player:GetForce()) then
		outFmtError("no force to enter hard = %s", hard)
		return
	end
	
	-- �жϽ�������Ƿ��㹻
	-- ÿ����Ϣ4��byte[0:ͨ���Ѷ�,1:��ǰ�Ѷ�,2:��ս����,3:�������]
	
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local times = self:GetByte(indx, 2)
	local x 	= config.x
	local y 	= config.y
	local mapid = config.mapid
	
	if times == config.times then
		outFmtError("try time is not fit for mapid %d", mapid)
		return
	end
	
	self:AddByte(indx, 2, 1)
	
	local gerneralId = string.format("%d:%s:%d_%d:%s", id, hard, times, getMsTime(), player:GetGuid())
	
	-- ������
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, gerneralId)
end

-- ͨ���Ѷ�
function AppInstanceMgr:passVipInstance(id, hard)
	local indx = INSTANCE_INT_FIELD_VIP_START + id - 1
	local cmp = self:GetByte(indx, 1)
	local max = cmp
	
	if max < hard then
		max = hard
	end
	
	if max > cmp then
		outFmtInfo("vip instance passed, id = %d, hard = %d ", id, hard)
		self:SetByte(indx, 1, max)
	end
end

function AppInstanceMgr:isEnoughForceByHard(id, hard, force)
	hard = tonumber(hard)
	local config = tb_map_vip[id]
	return force >= config.forces[hard]
end

-- һ��ɨ��VIP
function AppInstanceMgr:sweepVIPInstance(id, hard)

	local dict = {}
	local dropIdTable = tb_map_vip[id].rewards[hard]
	
	DoRandomDropTable(dropIdTable, dict)
	
	local itemDict = {}
	for entry, count in pairs(dict) do
		table.insert(itemDict, {entry, count})
	end
	
	local playerInfo = self:getOwner()
	playerInfo:AppdAddItems(itemDict, MONEY_CHANGE_VIP_INSTANCE_REWARD, LOG_ITEM_OPER_TYPE_VIP_INSTANCE_REWARD)
	
	-- ɨ���Ľ������
	local list = Change_To_Item_Reward_Info(dict, true)
	playerInfo:call_sweep_instance_reward (INSTANCE_SUB_TYPE_VIP, 0, 0, 0, list)
end

-------------------------------��Դ����------------------------------
function AppInstanceMgr:checkIfCanEnterResInstance(id)
	
	outFmtDebug("appd enter res %d",id)
	local config = tb_instance_res[id]
	
	
	local player = self:getOwner()
	
	
	-- �жϽ�������Ƿ��㹻
	-- ÿ����Ϣ4��byte[0:��ս����,1:Ԥ��,2:Ԥ��,3:Ԥ��]
	
	local indx = INSTANCE_INT_FIELD_RES_START + id - 1
	local times = self:GetByte(indx, 0)
	local mapid = config.mapid
	
	local allTime = config.times
	local vip = player:GetVIP()
	if vip > 0 then
		allTime = allTime + tb_vip_base[vip].instance
	end
	--local viptimes = tb_vip_base
	
	outFmtDebug("times %d ,mapID %d",times,mapid)
	--�жϴ���
	if times >= allTime then
		outFmtError("try time is not fit for mapid %d", mapid)
		return
	end
	--�жϵȼ�
	local lev = player:GetLevel()
	if lev < config.limLev then
		outFmtError("res instance Limit lev %d", lev)
		return
	end
	
	local x 	= config.x
	local y 	= config.y
	
	self:AddByte(indx, 0, 1)

	player:AddActiveItem(1)
	
	local gerneralId = string.format("%d:%d:%s", id, getMsTime(), player:GetGuid())
	
	outFmtDebug("gerneralId %s",gerneralId)
	
	-- ������
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, gerneralId)
	
	local questMgr = player:getQuestMgr()
	questMgr:OnUpdate(QUEST_TARGET_TYPE_RESOURCE_INSTANCE, {mapid})
end




-------------------------------������------------------------------
function AppInstanceMgr:checkIfCanEnterTrial()
	--[[INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT	= INSTANCE_INT_FIELD_VIP_END,					//(0:���տ�ɨ������,1:��ʷͨ�ز���)
	INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT	= INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT + 1,	//(0:ɨ������,1:�ɹ���ɨ������)--]]
	
	local passed = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1)
	if passed == #tb_map_trial then
		outFmtError("reach top layer")
		return
	end
	
	local nextId = passed + 1
	local player = self:getOwner()
	local config = tb_map_trial[nextId]
	
	local gerneralId = string.format("%d:%d:%s", nextId, getMsTime(), player:GetGuid())
	
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), config.x, config.y, config.mapid, gerneralId)
	
	local questMgr = player:getQuestMgr()
	questMgr:OnUpdate(QUEST_TARGET_TYPE_TRIAL_INSTANCE)
end


-- ͨ�ز���
function AppInstanceMgr:passInstance(id)
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1, id)
end
-- ͨ����Դ����
function AppInstanceMgr:passResInstance(id)
	--outFmtDebug("ton guan zi yuan fu ben %d *************************************",id)
	local idx =  INSTANCE_INT_FIELD_RES_START + id - 1
	local pas = self:GetByte(idx,1)
	if pas == 0 then
		self:SetByte(idx,1,1)
	end
end


-- һ��ɨ��������
function AppInstanceMgr:sweepTrialInstance()
	local prevSweepTimes = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0)
	if prevSweepTimes == 0 then
		outFmtError("no times to sweepTrialInstance")
		return
	end
	
	local layers = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0)
	-- ��ûͨ��û��Ҫɨ��
	if layers == 0 then
		outFmtError("please pass the 1st layer first")
		return
	end
	
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, prevSweepTimes - 1)
	local player = self:getOwner()
	
	local dict = {}
	for i = 1, layers do
		local dropIdTable = tb_map_trial[ i ].reward
		DoRandomDropTable(dropIdTable, dict)
	end
	
	local itemDict = {}
	for entry, count in pairs(dict) do
		table.insert(itemDict, {entry, count})
	end
	
	local playerInfo = self:getOwner()
	playerInfo:AppdAddItems(itemDict, MONEY_CHANGE_TRIAL_INSTANCE_REWARD, LOG_ITEM_OPER_TYPE_TRIAL_INSTANCE_REWARD)
	
	-- ɨ���Ľ������
	local list = Change_To_Item_Reward_Info(dict, true)
	playerInfo:call_sweep_instance_reward (INSTANCE_SUB_TYPE_TRIAL, 0, 0, 0, list)
end
-- ɨ����Դ����
function AppInstanceMgr:sweepResInstance(id)
	--print("AppInstanceMgr:sweepResInstance")
	local baseIdx =  INSTANCE_INT_FIELD_RES_START + id - 1
	local pas = self:GetByte(baseIdx,1)
	if pas == 1 then
		--print("begin sao dang")
		
		--tb_instance_reward
		local baseconfig = tb_instance_res[id]
		local times = self:GetByte(baseIdx, 0)
		
		local allTime = baseconfig.times
		local player = self:getOwner()
		local vip = player:GetVIP()
		if vip > 0 then
			allTime = allTime + tb_vip_base[vip].instance
		end
		
		--�жϴ���
		if times >= allTime then
			outFmtError("try time is not fit for mapid  %d",times)
			return
		end
		
		local playerInfo = self:getOwner()
		local idx = id * 100 + playerInfo:GetLevel()
		local config = tb_instance_reward[idx]
		local tab = {}
		table.insert(tab,config.basereward[1])
		local randomReward = config.randomreward
		local rewardIdx = randInt(1, #randomReward)
		table.insert(tab,randomReward[rewardIdx])
		table.insert(tab,config.reward[1])
		
		local list = {}
		
		for _,v in ipairs(tab) do
			
			playerInfo:PlayerAddItem(v[1],v[2])
			--����֪ͨ
			local stru = item_reward_info_t .new()
			stru.item_id	= v[1]
			stru.num 		= v[2]
			table.insert(list, stru)
		end
		
		--��Ӵ���
		self:AddByte(baseIdx, 0, 1)
		
		player:AddActiveItem(1)
		
		protocols.call_sweep_instance_reward ( player, INSTANCE_SUB_TYPE_RES, id, 0, 0, list)
		
	else
		outFmtDebug("not first res instance")
	end
end

-- ����������
function AppInstanceMgr:resetTrialInstance()
	local prevSweepTimes	= self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0)
	local prevBuyTimes		= self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 1)
	
	if prevSweepTimes > 0 then
		outFmtError("not need to resetTrialInstance")
		return
	end
	
	local passed = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1)
	if passed == 0 then
		outFmtError("you can resetTrialInstance after pass the 1st layer")
		return
	end
	
	if prevBuyTimes == 0 then
		outFmtError("no time to buy to resetTrialInstance")
		return
	end
	
	-- �ж��ܷ�Ԫ��
	local gold = tb_map_trial[passed].resetgold
	local player = self:getOwner()
	if not player:checkMoneyEnough(MONEY_TYPE_GOLD_INGOT, gold) then
		outFmtError("gold is not enough")
		return
	end
	
	-- ��Ǯ
	player:SubMoney(MONEY_TYPE_GOLD_INGOT, MONEY_CHANGE_RESET_TRIAL, gold)
	
	-- �۹������
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 1, prevBuyTimes - 1)
	
	-- �Ӵ���
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, 1)
	
	-- �޸Ľ��տ�ɨ������
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0, passed)
end

-- ����ÿ������
function AppInstanceMgr:instanceDailyReset()
	-- ����VIP����
	for i = INSTANCE_INT_FIELD_VIP_START, INSTANCE_INT_FIELD_VIP_END-1 do
		local id = i - INSTANCE_INT_FIELD_VIP_START + 1
		self:SetByte(i, 2, 0)
		self:SetByte(i, 3, 0)
	end
	
	-- ����������
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 1, 1)
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_SWEEP_SHORT, 0, 1)
	local passed = self:GetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 1)
	self:SetUInt16(INSTANCE_INT_FIELD_TRIAL_PASSED_SHORT, 0, passed)
	
	-- ������Դ����
	for i = INSTANCE_INT_FIELD_RES_START,INSTANCE_INT_FIELD_RES_END-1 do
		self:SetByte(i,0,0)
	end
end

-------------------------------�------------------------------
--���û����
function AppInstanceMgr:setActiveNum(id,num)
	self:SetUInt32(INSTANCE_INT_FIELD_ACTIVE_START + id - 1,num)
end

function AppInstanceMgr:getActiveNum(id)
	return self:GetUInt32(INSTANCE_INT_FIELD_ACTIVE_START + id - 1)
end

--���ӻ�Ծ��
function AppInstanceMgr:addActivity(num)
	self:AddUInt32(INSTANCE_INT_FIELD_ACTIVE,num)
end

--��ȡ�ܻ�Ծ��
function AppInstanceMgr:getActivity()
	return self:GetUInt32(INSTANCE_INT_FIELD_ACTIVE)
end

function AppInstanceMgr:hasGetActivityReward(offset)
	return self:GetBit(INSTANCE_INT_FIELD_ACTIVE_REWARD,offset)
end

function AppInstanceMgr:SetActivityReward(offset)
	self:SetBit(INSTANCE_INT_FIELD_ACTIVE_REWARD,offset)
end

-------------------------------�end------------------------------

-------------------------------����------------------------------
--3v3�ѲμӴ���
function AppInstanceMgr:get3v3EnterTimes()
	return self:GetUInt16(INSTANCE_INT_FIELD_3V3_TIMES,0)
end

--����3v3�μӴ���
function AppInstanceMgr:add3v3EnterTimes()
	self:AddUInt16(INSTANCE_INT_FIELD_3V3_TIMES,0,1)
end

--3v3�ѹ������
function AppInstanceMgr:get3v3BuyTimes()
	return self:GetUInt16(INSTANCE_INT_FIELD_3V3_TIMES,1)
end

function AppInstanceMgr:add3v3BuyTimes(num)
	self:AddUInt16(INSTANCE_INT_FIELD_3V3_TIMES,1,num)
end

-------------------------------����end------------------------------

-- ������guid
function AppInstanceMgr:getPlayerGuid()
	--��Ʒ������guidת���guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--��ø�����������ӵ����
function AppInstanceMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end

return AppInstanceMgr