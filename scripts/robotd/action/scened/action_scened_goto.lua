local ActionBase = require('robotd.action.action')
local ActionScenedGoto = class('ActionScenedGoto', ActionBase)

--获取类型
function ActionScenedGoto:GetType()
	return ROBOT_ACTION_TYPE_SCENED
end

--初始化变量
function ActionScenedGoto:Initialize(mapid,x, y)
	self.to_mapid = mapid
	self.to_x = x
	self.to_y = y
	self.send_path = false
end

--获取类型名
function ActionScenedGoto:GetName()
	return 'ActionScenedGoto'
end

--心跳
function ActionScenedGoto:Update(diff)
	local mapid = self.player:GetMapID()
	--不再这张地图了，无法同图寻路
	if(mapid ~= self.to_mapid)then
		outFmtDebug("ActionScenedGoto:Update mapid ~= self.to_mapid %s %u", self:ToString(),mapid)
		return false, 1
	end
	
	local x, y = self.player:GetPos()
	--到达目的地了
	if(self.to_x == x and self.to_y == y)then
		--outFmtDebug("================222222222222222222222")
		return false, 2
	end
	--新手村才需要检测跳跃
	if(mapid == BORN_MAP)then
		--检测当前坐标是否是跳跃点
		for	i, v in pairs(jumpPosData) do
			if(math.floor(v[1])==x and math.floor(v[2])==y)then
				self.player.my_unit:stopMoving(x,y)
				self.player:call_move_stop(self.player.my_unit:GetUIntGuid(),x,y)
				self:PushAction('robotd.action.scened.action_scened_jump',v[3],v[4])
				return true
			end
		end
	end

	if(self.player.my_unit:IsMoving() == false)then
		--outFmtDebug("================1111111111111111111111111111")
		--寻路发包
		local result = mapLib.PathfindingGoto(self.player.ptr, self.player.my_unit.ptr, self.to_x, self.to_y)
		if(result == false)then
			PathfindingGotoFailure(self.player,mapid)
			self:SetWaitTimeInterval(1000)
		end
	end
	return true
end


return ActionScenedGoto
