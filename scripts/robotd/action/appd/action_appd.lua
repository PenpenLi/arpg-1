
local ActionBase = require('robotd.action.action')
local ActionAppd = class('ActionAppd', ActionBase)

--获取类型
function ActionAppd:GetType()
	return ROBOT_ACTION_TYPE_APPD
end

--初始化变量
function ActionAppd:Initialize(...)
	self:RegOpcodeHandler(SMSG_OPERATION_FAILED, self.HandlerOperationFailed)
	-- 装备等使用检测
	-- self:AddTimer("use_item_timer", self.player.NeedUseItem, 10000, self.player)
end

--获取类型名
function ActionAppd:GetName()
	return 'ActionAppd'
end

--操作失败提示
function ActionAppd:HandlerOperationFailed(args)
	outDebug(OperationFailedToString(args.type, args.reason, args.data))
	if(args.type == OPERTE_TYPE_CLOSE)then
		outFmtInfo("%s  %s", OperationFailedToString(args.type, args.reason, args.data), self.player.account)
	end
end

--心跳
function ActionAppd:Update(diff)
	return true
end
return ActionAppd
