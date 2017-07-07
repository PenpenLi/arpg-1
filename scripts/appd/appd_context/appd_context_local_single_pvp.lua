
-- ƥ�����
SINGLE_PVP_QUEUE = {
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
}


function OnProcessLocalSinglePVPMatch()
	-- �Ȱ���ƥ���ƥ������
	for i = #SINGLE_PVP_QUEUE, 1, -1 do
		local queue = SINGLE_PVP_QUEUE[ i ]
		local size = #queue
		-- �Ȱ����һ����������
		local last = nil
		if size % 2 == 1 then
			last = queue[size]
			size = size - 1
		end
		
		for j = 1, size, 2 do
			local fa = queue[ j ]
			local fb = queue[j+1]
			local key = string.format("%s#%s", fa[ 1 ], fb[ 1 ])
			OnLocalSinglePVPMatch(fa[ 1 ], key)
			OnLocalSinglePVPMatch(fb[ 1 ], key)
		end
		
		-- �����һ���������
		table.remove(queue)
		if last then
			table.insert(queue, last)
		end
	end	
	
	-- ����ÿ���׶εĶ������ֻ��1����
	for i = #SINGLE_PVP_QUEUE, 1, -1 do
		
	end
end


function OnLocalSinglePVPMatch(guid, key)
	
	app:SetMatchingKuafuType(guid, nil)
end

-- ȡ��ƥ����Ӹ���
function PlayerInfo:OnCancelLocalSinglePVPMatchBeforeOffline()
	if not app:IsKuafuTypeMatching(self:GetGuid(), MATCH_TYPE_LOCAL_SINGLE_PVP) then
		return
	end
	
end


-- ƥ����Ӹ���
function PlayerInfo:OnLocalSinglePVPMatch(indx)
	-- �Ѿ��ڿ����
	if self:IsKuafuing() then
		return false
	end
	
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		return false
	end
		
	app:SetMatchingKuafuType(self:GetGuid(), MATCH_TYPE_LOCAL_SINGLE_PVP)
	
	if self:isMatchRobot() then
		-- 
	else
		local indx = self:calcQueueIndx()
		local queue = SINGLE_PVP_QUEUE[indx]
		local matchLast = tb_single_pvp_base[ 1 ].matchLast
		-- ����ƥ�����
		table.insert(queue, {self:GetGuid(), 0, os.time() + matchLast})
		-- {guid, matchTimes, ������ʱ���}
	end
	
	return true
end

function PlayerInfo:calcQueueIndx()
	return 0
end

function PlayerInfo:isMatchRobot()
	return false
end


-- ����������
function PlayerInfo:OnBuyLocalSinglePVPTicket(count)
	
end

-- ������Ӹ���
function PlayerInfo:OnResetLocalSinglePVPDayTimes()
	local instMgr = self:getInstanceMgr()
	instMgr:ResetLocalSinglePVPDayTimes()
end