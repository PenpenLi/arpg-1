RobotdItem = class('RobotdItem', BinLogObject)

--构造函数
function RobotdItem:ctor()
	
end

--获取模板ID
function RobotdItem:GetEntry()
	return self:GetUInt32(ITEM_FIELD_ENTRY)
end

--获取数量
function RobotdItem:GetCount()
	return self:GetUInt32(ITEM_FIELD_STACK_COUNT)
end

--获取所在包裹
function RobotdItem:GetBag()
	return self:GetUInt32(ITEM_FIELD_CONTAINED)
end

--获取所在位置
function RobotdItem:GetPos()
	return self:GetUInt32(ITEM_FIELD_POS)
end

--是否需要鉴定
function RobotdItem:GetNeedAppraisal()
	return self:GetByte(ITEM_FIELD_EQUIP_BASE_INFO, 2)
end


--获取装备战斗力
function RobotdItem:GetEquipZDL()
	return self:GetUInt32(ITEM_FIELD_EQUIP_ZDL)
end

--获取强化等级
function RobotdItem:GetStrengthenLev()
	return self:GetByte(ITEM_FIELD_EQUIP_STRENGTHEN_LEV, 0)
end



return RobotdItem