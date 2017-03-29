
local ActionBase = require('robotd.action.action')
local ActionScenedKuafu = class('ActionScenedKuafu', ActionBase)

--获取类型
function ActionScenedKuafu:GetType()
	return ROBOT_ACTION_TYPE_SCENED
end

--初始化变量
function ActionScenedKuafu:Initialize(...)
	self:AddTimer("ActionScenedKuafu_update", self.Update, 5000, self)
	self.player.Kuafu_Status = nil
end

--获取类型名
function ActionScenedKuafu:GetName()
	return 'ActionScenedKuafu'
end

--心跳
ACTION_SCENE_KUAfU_STATUS_START = -1;
ACTION_SCENE_KUAfU_STATUS_GUAJI = 1;
ACTION_SCENE_KUAfU_STATUS_ISDIE = 2;
function ActionScenedKuafu:Update(diff)
	if(self.player == nil or self.player.my_unit == nil or self.player.mapInfo == nil)then
		return true
	end
	if(self.player.Kuafu_Status == nil) then
		self.player.Kuafu_Status = ACTION_SCENE_KUAfU_STATUS_START
		outFmtDebug("in xianfu init")
	end
	
	-- 如果在仙府夺宝
	if  self.player:GetMapID() == 3003 then
		local params = self.player:FindBossFirst()
		if params then
			self:PushAction('robotd.action.scened.action_scened_quest_killmonster', params[ 1 ], params[ 2 ], params[ 3 ], params[ 4 ],  params[ 5 ], params[ 6 ])
			self:SetWaitTimeInterval(1000)
		end
		return true
	end
	
	--[[
	if self.player:GetMapID() == KUAFU_MILLION_WAR_MAPID then
		if self.player.Kuafu_Status == ACTION_SCENE_KUAfU_STATUS_START then
			local t = os.time()
			if t > self.player.mapInfo:GetMillion_War_Ready_End_Time() then
				self.player.Kuafu_Status = ACTION_SCENE_KUAfU_STATUS_GUAJI;
				self:PushAction('robotd.action.scened.action_scened_zhuiji',TYPE_PEPLE)
				outFmtDebug("in million_war player guaji start")
			end
		end
		
		if self.player.Kuafu_Status == ACTION_SCENE_KUAfU_STATUS_GUAJI then
			if self.player:GetMillionWarLifeNum() == 0 or self.player.mapInfo:GetMillionWinGuid() ~= '' then
				self.player.Kuafu_Status = ACTION_SCENE_KUAfU_STATUS_ISDIE;
				outFmtDebug("in million_war player is Die goback")
				outFmtDebug("------------------------%s",self.player.mapInfo:GetMillionWinGuid())
				
				self.player:call_instance_exit()
			--买一次命
			--self.player:call_million_war_buy(0,0)
				return true
			end
		end
		if self.player.Kuafu_Status == ACTION_SCENE_KUAfU_STATUS_ISDIE then
			outFmtDebug("in million_war player is Die")
		end
	end
	
	if self.player:GetMapID() == 204001 then
		if self.player.Kuafu_Status == ACTION_SCENE_KUAfU_STATUS_START then
			self.player.Kuafu_Status = ACTION_SCENE_KUAfU_STATUS_GUAJI;
			--creatures_1={{110102,83,57},{110103,53,100},{110104,80,167},{110105,122,179},{110106,162,119},{110107,123,66},{110101,107,112}
			self:PushAction('robotd.action.scened.action_scened_zhuiji',TYPE_PEPLE)		
		end
		
		if self.player.Kuafu_Status == ACTION_SCENE_KUAfU_STATUS_GUAJI then
			if self.player.my_unit:IsDie() or self.player.mapInfo:GetBossCount() == 0 then
				self.player.Kuafu_Status = ACTION_SCENE_KUAfU_STATUS_ISDIE;
				outFmtDebug("in huangjin_war player is Die goback")
				self.player:call_instance_exit()
				return true
			end
		end
		if self.player.Kuafu_Status == ACTION_SCENE_KUAfU_STATUS_ISDIE then
			outFmtDebug("in huangjin_war player is Die")
		end
	end
	--]]
	
	return true
end

return ActionScenedKuafu
