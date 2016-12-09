local AppInstanceMgr = class("AppInstanceMgr", BinLogObject)

function AppInstanceMgr:ctor()
	
end

function AppInstanceMgr:checkIfCanEnter(mapid)

	-- TODO:�ж�VIP�Ƿ���������
	print("vip level not satisfy")
	
	-- �жϽ�������Ƿ��㹻
	-- ÿ����Ϣ4��byte[0:ͨ���Ѷ�,1:��ǰ�Ѷ�,2:��ս����,3:�������]
	local config = tb_map_vip[mapid]
	local indx = INSTANCE_INT_FIELD_VIP_START + config.indx - 1
	local times = self:GetByte(indx, 2)
	local x 	= config.x
	local y 	= config.y
	
	if times == config.times then
		outFmtError("try time is not fit for mapid %d", mapid)
		return
	end
	
	self:AddByte(indx, 2, 1)
	
	local player = self:getOwner()
	local hard = self:GetByte(indx, 1)
	-- ������
	call_appd_teleport(player:GetScenedFD(), player:GetGuid(), x, y, mapid, ""..hard)
end




-- ������guid
function AppInstanceMgr:getPlayerGuid()
	--��Ʒ������guidת���guid
	if not self.owner_guid then
		self.owner_guid = guidMgr.replace(self:GetGuid(), guidMgr.ObjectTypePlayer)
	end
	return self.owner_guid
end

--��ø�����������ӵ����
function AppInstanceMgr:getOwner()
	local playerguid = self:getPlayerGuid()
	return app.objMgr:getObj(playerguid)
end

return AppInstanceMgr