--3v3每周排名奖励
function Rank3v3kuafuWeek()
	outFmtDebug("Rank3v3kuafuWeek11")
	
	local ranklist = app.kuafu_rank
	
	--local pid = globalGameConfig:GetPlatformID()
	local sid = globalGameConfig:GetServerID()
	
	outFmtDebug("Rank3v3kuafuWeek22--%s",sid)
	
	local server = string.split(sid,"_")
	
	for i,v in ipairs(ranklist) do
		--outFmtDebug("rank %d,%s,%d",i,v[1],v[5])
		local serAry = string.split(v[1],",")
		--本服发奖
		if serAry[1] == server[1] and serAry[2] == server[2] then
			local config = Rank3v3GetWeekReward(i)
			AddGiftPacksData(v[6],0,GIFT_PACKS_TYPE_3V3_WEEK,os.time(),os.time() + 86400*30, config.mailname, config.maildesc, config.reward, "系统")
		end
		
	end
	
end

--3v3每周奖励取表操作
function Rank3v3GetWeekReward(rank)
	for _,v in ipairs(tb_kuafu3v3_week_reward) do
		if rank >= v.rank[1] and rank <= v.rank[2] then
			return v
		end
	end
end

--3v3每月段位奖励
function PlayerInfo:Rank3v3SegmentReward()
	
end

