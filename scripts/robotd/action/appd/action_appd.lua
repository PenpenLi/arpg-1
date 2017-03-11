
local ActionBase = require('robotd.action.action')
local ActionAppd = class('ActionAppd', ActionBase)

--获取类型
function ActionAppd:GetType()
	return ROBOT_ACTION_TYPE_APPD
end

--初始化变量
function ActionAppd:Initialize(...)
	self:RegOpcodeHandler(SMSG_OPERATION_FAILED, self.HandlerOperationFailed)
	-- AddTimer 参数：1：名字，2：对应业务逻辑的函数名，3:间隔执行时间，4：玩家对象
	--[[
	-- 装备等使用检测
	self:AddTimer("Send_Bag_Exchange_Pos", self.player.Send_Bag_Exchange_Pos, 10000, self.player)
	-- 加物品
	self:AddTimer("GmAddItem", self.player.GmAddItem, 9000, self.player)
	-- 摧毁物品
	self:AddTimer("Send_Bag_Destroy", self.player.Send_Bag_Destroy, 8000, self.player)
	-- 使用物品
	self:AddTimer("Send_Use_Item", self.player.Send_Use_Item, 7000, self.player)
	--]]
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
