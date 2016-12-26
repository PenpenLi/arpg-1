local protocols = require('share.protocols')


function DoScenedDoSomething(unit, ntype, data, str)
	local unitInfo = UnitInfo:new {ptr = unit}
	unitInfo:DoGetAppdDoSomething(ntype, data, str)
end

-- Ӧ�÷�֪ͨ��������Щʲô
function UnitInfo:DoGetAppdDoSomething( ntype, data, str)
	if ntype == APPD_SCENED_SWEEP_TRIAL_INSTANCE then
		self:sweepTrial(data)
	elseif ntype == APPD_SCENED_SWEEP_VIP_INSTANCE then
		self:sweepVIP(data, tonumber(str))
	elseif ntype == APPD_SCENED_RESPAWN then
		self:sceneGoldRespawn(data)
	elseif ntype == APPD_SCENED_NEAR_BY_CHAT then
		self:chatNearBy(str)
	end
end

-- vip����ɨ��
function UnitInfo:sweepVIP(id, hard)
	hard = tonumber(hard)
	local dict = {}
	local dropIdTable = tb_map_vip[id].rewards[hard]
	
	for _, dropId in pairs(dropIdTable) do
		DoRandomDrop(self.ptr, dropId, dict)
	end
	
	-- ɨ���Ľ������
	local list = self:Change_To_Item_Reward_Info(dict)
	
	protocols.call_sweep_instance_reward ( self, INSTANCE_SUB_TYPE_VIP, id, hard, 0, list)
end

function UnitInfo:Change_To_Item_Reward_Info(dict)
	-- ɨ���Ľ������
	local list = {}
	for item_id, num in pairs(dict) do
		local stru = item_reward_info_t .new()
		stru.item_id	= item_id
		stru.num 		= num
		table.insert(list, stru)
	end
	
	return list
end


---------------------------ɨ��������
function UnitInfo:sweepTrial(id)
	local dict = {}
	
	for i = 1, id do
		local dropIdTable = tb_map_trial[ i ].reward
			
		for _, dropId in pairs(dropIdTable) do
			DoRandomDrop(self.ptr, dropId, dict)
		end
	end
	
	-- ɨ���Ľ������
	local list = self:Change_To_Item_Reward_Info(dict)
	
	protocols.call_sweep_instance_reward ( self, INSTANCE_SUB_TYPE_TRIAL, 0, 0, 0, list)
end

-- ������Ԫ������
function UnitInfo:sceneGoldRespawn(itemId)
	ScenedUseItem[itemId](ScenedUseItem, self, itemId, 1)
end


-- ��������
function UnitInfo:chatNearBy(content)
	-- ��ѯ��Ұ��Χ�ڵ����
	local allPlayers = playerLib.GetAllPlayerNearBy(self.ptr)
	for _, player in pairs(allPlayers) do
		local playerInfo = UnitInfo:new {ptr = player}
		if not playerInfo:isDeclineNearMsg() then
			playerInfo:call_send_chat (CHAT_TYPE_CURRENT ,self:GetGuid() ,0 ,self:GetName() ,self:GetVIP() ,0 ,self:GetLevel() ,self:GetGender() ,content, "")
		end
	end
end