
local ActionBase = require('robotd.action.action')
local ActionScened = class('ActionScened', ActionBase)

--获取类型
function ActionScened:GetType()
	return ROBOT_ACTION_TYPE_SCENED
end

--初始化变量
function ActionScened:Initialize(...)
end

--获取类型名
function ActionScened:GetName()
	return 'ActionScened'
end

--心跳
function ActionScened:Update(diff)
	return true
end

return ActionScened
