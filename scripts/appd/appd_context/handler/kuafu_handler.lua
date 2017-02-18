-- 3v3 ∆•≈‰
function PlayerInfo:Handle_Kuafu_3v3_Match(pkt)
	
	local config = tb_kuafu3v3_base[1]
	
	--local lev = self:GetLevel()
	--outFmtDebug("Kuafu_3v3_----------------%d",lev)
	if self:GetLevel() < config.limlev then
		self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_NO_LEV,config.limlev)
		return
	end
	
	if self:GetForce() < config.limforce then
		self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_NO_FORCE,config.limforce)
		return
	end
	
	local curtime = os.time()
	local intime = false
	for _,v in ipairs(config.activetime) do
		local t1 = GetTodayHMSTimestamp(v[1],v[2],0)
		local t2 = GetTodayHMSTimestamp(v[3],v[4],0)
		if curtime >= t1 and curtime <= t2 then
			intime = true
			break
		end
	end
	if not intime then
		self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_NO_OPEN)
		return
	end
	
	
	local instMgr = self:getInstanceMgr()
	local curNum = instMgr:get3v3EnterTimes()
	local buyNum = instMgr:get3v3BuyTimes()
	
	outFmtDebug("--------curNum:%d,buyNum:%d,maxnum:%d,buyNum:%d",curNum,buyNum,config.daytimes,config.daybuytimes)
	
	if curNum >= (buyNum + config.daytimes) then
		
		if buyNum < config.daybuytimes then
			self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_NO_TIME_BUY)
		else
			self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_NO_TIME)
		end
	
		return
	end
	
	if app:IsInKuafuTypeMatching(self:GetGuid()) then
		self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_IN_MATCH)
		return
	end
	
	local tf = self:OnWorld3v3Match()
	
	if tf then
		self:call_kuafu_3v3_match_start()
		--instMgr:add3v3EnterTimes()
	end
	
end
--3v3π∫¬Ú¥Œ ˝
function PlayerInfo:Handle_Kuafu_3v3_BuyTimes(pkt)
	outFmtDebug("Handle_Kuafu_3v3_BuyTimes")
	local num = pkt.num
	
	if num < 0 then 
		return
	end
	
	local config = tb_kuafu3v3_base[1]
	
	local instMgr = self:getInstanceMgr()
	local buyNum = instMgr:get3v3BuyTimes()
	
	if (num + buyNum) > config.daybuytimes then
		self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_MAX_BUY)
		return
	end
	
	if not self:costMoneys(MONEY_CHANGE_WELF_ACTIVE_GETBACK, config.daybuycost,num) then
		self:CallOptResult(OPRATE_TYPE_ATHLETICS, ATHLETICS_OPERATE_NO_MONEY)
		return
	end
	
	instMgr:add3v3BuyTimes(num)
	
end

function PlayerInfo:Handle_Kuafu_3v3_Match_Oper(pkt)
	local oper = pkt.oper
	if oper ~= 0 and oper ~= 1 then
		return
	end
	self:OnPrepareMatch(oper)
end

function PlayerInfo:Handle_Kuafu_3v3_Cancel_Match(pkt)
	local type = pkt.type
	if type == KUAFU_TYPE_FENGLIUZHEN then
		self:OnCancelWorld3v3MatchBeforeOffline()
	end
end