--[[
	KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START
	KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_END
	MAX_KUAFU_XIANFU_BOSS_INT_COUNT
	
	KUAFU_XIANFU_BOSS_SHOW_INFO		= 0,									// 2 shorts(0:entry, 1:死亡状态(0:未刷,1:刷新,2:死亡))
	KUAFU_XIANFU_BOSS_BORN_INFO		= KUAFU_XIANFU_BOSS_SHOW_INFO + 1,		// 是否刷新
	KUAFU_XIANFU_BOSS_BORN_TIME		= KUAFU_XIANFU_BOSS_BORN_INFO + 1,		// 刷新时间戳
--]]

function PlayerInfo:FindBossFirst()
	-- 怪物是否已经
	if self.bossObserve then
		return
	end
	
	-- 有宝箱的先捡起来
	if self.lootMgr then
		local lootInfo = self.lootMgr:ReadData()
		for _, info in ipairs(lootInfo) do
			self:call_loot_select(info[ 1 ], info[ 2 ])
		end
	end
	
	local mapId = self:GetMapID()
	-- 先找BOSS
	local start = KUAFU_XIANFU_FIELDS_INT_BOSS_INFO_START
	for i = 1, #tb_kuafu_xianfu_boss do
		local state = self.mapInfo:GetUInt16(start + KUAFU_XIANFU_BOSS_SHOW_INFO, 1)
		if state == 1 or state == 0 then
			-- 去BOSS刷新地
			local config = tb_kuafu_xianfu_boss[ i ]
			local entry = config.bossEntry
			self.bossObserve = true
			local indx = start
			return 
			{
				entry, 
				mapId, 
				config.bossPos[ 1 ], 
				config.bossPos[ 2 ], 
				-- 是否完成
				function()
					local state = self.mapInfo:GetUInt16(indx + KUAFU_XIANFU_BOSS_SHOW_INFO, 1)
					return state == 2
				end, 
				-- 完成以后做的事
				function()
					self.bossObserve = false
				end
			}
		end
		start = start + MAX_KUAFU_XIANFU_BOSS_INT_COUNT
	end
	
	-- 再找人
	return
end