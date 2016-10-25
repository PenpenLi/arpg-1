--考虑到离线binlog的问题,再做一次封装
function PlayerInfo:getObj( guid )	
	return self.offlineObjects and self.offlineObjects[guid] or app.objMgr:getObj(guid)
end

--根据玩家ID取礼包对象
function PlayerInfo:getGiftPacksInfo()
	if not self.guid_GiftPacksInfo then
		self.guid_GiftPacksInfo = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypeGiftPacks)
	end
	return self:getObj(self.guid_GiftPacksInfo)
end

--根据玩家ID取限时活动对象
function PlayerInfo:getLimitActivityInfo()
	--TODO:这里应该根据每日限时活动类型信息重新生成
	if not self.guid_LimitActivityInfo then
		self.guid_LimitActivityInfo = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypeLimit)
	end
	local limit = self:getObj(self.guid_LimitActivityInfo)
	local la = GetToDayLimitActivity()
	if la then
		for k,v in pairs(la) do limit[k] = v end
	end
	return limit
end

--根据玩家guid获得物品管理器
function PlayerInfo:getItemMgr()
	if not self.guid_itemMgr then
		self.guid_itemMgr = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypeItemMgr)
	end
	return self:getObj(self.guid_itemMgr)	
end

--根据玩家guid获得强化管理器
function PlayerInfo:getLogicalMgr()
	if not self.guid_logicalMgr then
		self.guid_logicalMgr = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypeLogical)
	end
	return self:getObj(self.guid_logicalMgr)	
end