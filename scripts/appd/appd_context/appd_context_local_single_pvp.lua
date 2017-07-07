
-- 匹配队列
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
	-- 先把能匹配的匹配下来
	for i = #SINGLE_PVP_QUEUE, 1, -1 do
		local queue = SINGLE_PVP_QUEUE[ i ]
		local size = #queue
		-- 先把最后一个给留下来
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
		
		-- 把最后一个存进队列
		table.remove(queue)
		if last then
			table.insert(queue, last)
		end
	end	
	
	-- 现在每个阶段的队列最多只有1个人
	for i = #SINGLE_PVP_QUEUE, 1, -1 do
		
	end
end


function OnLocalSinglePVPMatch(guid, key)
	
	app:SetMatchingKuafuType(guid, nil)
end

-- 取消匹配组队副本
function PlayerInfo:OnCancelLocalSinglePVPMatchBeforeOffline()
	if not app:IsKuafuTypeMatching(self:GetGuid(), MATCH_TYPE_LOCAL_SINGLE_PVP) then
		return
	end
	
end


-- 匹配组队副本
function PlayerInfo:OnLocalSinglePVPMatch(indx)
	-- 已经在跨服了
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
		-- 加入匹配队列
		table.insert(queue, {self:GetGuid(), 0, os.time() + matchLast})
		-- {guid, matchTimes, 本队列时间戳}
	end
	
	return true
end

function PlayerInfo:calcQueueIndx()
	return 0
end

function PlayerInfo:isMatchRobot()
	return false
end


-- 购买进入次数
function PlayerInfo:OnBuyLocalSinglePVPTicket(count)
	
end

-- 重置组队副本
function PlayerInfo:OnResetLocalSinglePVPDayTimes()
	local instMgr = self:getInstanceMgr()
	instMgr:ResetLocalSinglePVPDayTimes()
end