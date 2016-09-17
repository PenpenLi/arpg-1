local ActionBase = require('robotd.action.action')
local ActionJump = class('ActionJump', ActionBase)

--获取类型
function ActionJump:GetType()
	return ROBOT_ACTION_TYPE_SCENED
end

--初始化变量
function ActionJump:Initialize(x, y)
	self.to_x = x
	self.to_y = y
	self.toJump = false
end

--获取类型名
function ActionJump:GetName()
	return 'ActionJump'
end

--心跳
function ActionJump:Update(diff)
	if(self.toJump == false)then
		local x, y = self.player:GetPos()
		outFmtDebug("~~~~~~~~~~~ActionJump~~~~~~~~~~~~~guid:%s fromx:%s fromy:%s tox:%s toy:%s", self.player.my_unit:GetGuid(), x,y,self.to_x ,self.to_y)
		self.player.my_unit:stopMoving(x,y)
		self.player:call_move_stop(self.player.my_unit:GetUIntGuid(),x,y)
		self.player:call_spell_start(200 ,self.to_x ,self.to_y ,0 ,0)
		self.player:SetPos(self.to_x, self.to_y)
		self:SetWaitTimeInterval(2000)
		self.toJump = true
		return true
	end
	
	--到达目的地了
	return false, 1

end


return ActionJump
