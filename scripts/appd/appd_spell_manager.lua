--���ܹ�����

local AppSpellMgr = class("AppSpellMgr", BinLogObject)

function AppSpellMgr:ctor()
	
end

-- ������guid
function AppSpellMgr:getPlayerGuid()
	--��Ʒ������guidת���guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

return AppSpellMgr