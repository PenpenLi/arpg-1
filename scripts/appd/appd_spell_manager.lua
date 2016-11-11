--技能管理器

local AppSpellMgr = class("AppSpellMgr", BinLogObject)

function AppSpellMgr:ctor()
	
end

-- 获得玩家guid
function AppSpellMgr:getPlayerGuid()
	--物品管理器guid转玩家guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

return AppSpellMgr