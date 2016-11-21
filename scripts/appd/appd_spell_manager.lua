--���ܹ�����

local AppSpellMgr = class("AppSpellMgr", BinLogObject)

function AppSpellMgr:ctor()
	
end

----------------------------------------�������ܲ���------------------------------------

-- �����������
function AppSpellMgr:activeBaseSpell(spellId)
	-- ����
	local count = self:GetUInt32(SPELL_BASE_COUNT)
	local index = SPELL_INT_FIELD_BASE_SPELL_START + count
	self:SetUInt16(index, SHORT_SPELL_ID, spellId)
	self:SetUInt16(index, SHORT_SPELL_LV,       1)
	self:SetUInt32(SPELL_BASE_COUNT, count + 1)
end

-- ������������
function AppSpellMgr:raiseBaseSpell(spellId)
	local prev = self:getSpellLevel(spellId)
	
	-- �Ӽ��ܵȼ�
	self:SetBaseSpellLevel(spellId,  prev+1)
	
	-- �����3����
	local arry = tb_skill_base[spellId].follow
	for _, id in pairs(arry) do
		self:SetBaseSpellLevel(id,  prev+1)
	end
end

--�ж�����Ƿ�ӵ���������
function AppSpellMgr:getSpellLevel(spellId)
	local owner = self:getOwner()
	local level = playerLib.GetSpellLevel(owner.ptr, spellId)
	
	return level
end

--�������ȼ�
function AppSpellMgr:getSpellTopLevel(spellId)
	local config = tb_skill_base[spellId]
	return config.uplevel_id[ 2 ] - config.uplevel_id[ 1 ] + 1
end

--��ǰ����id
function AppSpellMgr:getSpellUpgradeIndex(spellId)
	local config = tb_skill_base[spellId]
	local level = self:getSpellLevel(spellId)
	return config.uplevel_id[ 1 ] + level - 1
end

--���ü��ܵȼ�
function AppSpellMgr:SetBaseSpellLevel(spellId, spellLv)
	for i = SPELL_INT_FIELD_BASE_SPELL_START, SPELL_INT_FIELD_BASE_SPELL_END-1 do
		if self:GetUInt16(i, SHORT_SPELL_ID) == spellId then
			self:SetUInt16(i, SHORT_SPELL_LV, spellLv)
			break
		end
	end
	
	-- ͬ��ӳ���ϵ
	self:SetSpellLevel(spellId, spellLv)
end

-- ����ӳ�似�ܵȼ�
function AppSpellMgr:SetSpellLevel(spellId, spellLv)
	local owner = self:getOwner()
	playerLib.SetSpellLevel(owner.ptr, spellId, spellLv)
end

----------------------------------------�������ܲ��� ����------------------------------------



-- ������guid
function AppSpellMgr:getPlayerGuid()
	--��Ʒ������guidת���guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--��ü��ܹ�������ӵ����
function AppSpellMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end

return AppSpellMgr