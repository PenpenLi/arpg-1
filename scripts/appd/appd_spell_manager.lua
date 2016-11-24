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


----------------------------------------------����-----------------------------------------------
-- ����Ƿ�������
function AppSpellMgr:hasMount()
	return self:getMountLevel() > 0
end

-- ��ǰ����
function AppSpellMgr:getMountLevel()
	return self:GetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 0)
end

-- ���õ�ǰ����
function AppSpellMgr:setMountLevel(level)
	self:SetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 0, level)
end

-- ����ܷ�����
function AppSpellMgr:canRaise()
	return self:getMountStar() < 10
end

-- ����ܷ�����
function AppSpellMgr:canUpgrade()
	return self:getMountLevel() < #tb_mount_upgrade and self:getMountStar() == 10
end

-- ��ǰ�Ǽ�
function AppSpellMgr:getMountStar()
	return self:GetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 1)
end

-- ���õ�ǰ�Ǽ�
function AppSpellMgr:setMountStar(star)
	self:SetUInt16(SPELL_INT_FIELD_MOUNT_LEVEL, 1, star)
end

-- ��ǰ���Ǿ���
function AppSpellMgr:getTrainExp()
	return self:GetUInt32(SPELL_INT_FIELD_MOUNT_TRAIN_EXP)
end

-- ���õ�ǰ���Ǿ���
function AppSpellMgr:setTrainExp(value)
	self:SetUInt32(SPELL_INT_FIELD_MOUNT_TRAIN_EXP, value)
end

-- ���ӵ�ǰ���Ǿ���
function AppSpellMgr:addTrainExp(value)
	local prev = self:getTrainExp()
	self:SetUInt32(SPELL_INT_FIELD_MOUNT_TRAIN_EXP, value + prev)
end

-- ���ף��ֵ
function AppSpellMgr:getBlessExp()
	return self:GetUInt32(SPELL_INT_FIELD_MOUNT_BLESS_EXP)
end

-- ����ף��ֵ
function AppSpellMgr:setBlessExp(value)
	self:SetUInt32(SPELL_INT_FIELD_MOUNT_BLESS_EXP, value)
end

-- �������＼��
function AppSpellMgr:activeMountSpell(spellId)
	for i = SPELL_INT_FIELD_MOUNT_SPELL_START, SPELL_INT_FIELD_MOUNT_SPELL_END-1 do
		if self:GetUInt16(i, SHORT_SPELL_ID) == 0 then
			self:SetUInt16(i, SHORT_SPELL_ID, spellId)
			self:SetUInt16(i, SHORT_SPELL_LV, 1)
			break
		end
	end
end

-- �Ƿ���ڵ�ǰ�û�����
function AppSpellMgr:hasIllusion(illuId)
	
	local count = self:GetUInt32(SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT)
	local size = SPELL_INT_FIELD_MOUNT_ILLUSION_START + SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT * MAX_ILLUSION_ATTR_COUNT
	
	for i = SPELL_INT_FIELD_MOUNT_ILLUSION_START, size, MAX_ILLUSION_ATTR_COUNT do
		if self:GetUInt32(ILLUSION_ATTR_ID + i) == 0 then
			return false
		end
		if self:GetUInt32(ILLUSION_ATTR_ID + i) == illuId then
			return true
		end
	end
	
	return false
end


-- ����û�
function AppSpellMgr:onActiveIllusion(illuId)

	local count = self:GetUInt32(SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT)
	
	-- �ӻû�id
	local size = SPELL_INT_FIELD_MOUNT_ILLUSION_START + count * MAX_ILLUSION_ATTR_COUNT
	self:SetUInt32(ILLUSION_ATTR_ID + size, illuId)
	
	outFmtInfo("active illusion %d", illuId)

	-- �ӹ���ʱ��
	local config = tb_mount_illusion[illuId]
	local expire = 0
	if config.last > 0 then
		expire = os.time() + config.last * 24 * 3600
	end
	self:SetUInt32(ILLUSION_ATTR_EXPIRE + size, expire)
	
	-- �Ӽ���
	local config = tb_mount_illusion[illuId]
	local st = size + ILLUSION_ATTR_SPELL_START
	for _, spellId in pairs(config.spells) do
		self:SetUInt16(st, SHORT_SPELL_ID, spellId)
		self:SetUInt16(st, SHORT_SPELL_LV, 1)
		st = st + 1
	end

	self:SetUInt32(SPELL_INT_FIELD_MOUNT_ILLUSION_COUNT, count + 1)
end


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