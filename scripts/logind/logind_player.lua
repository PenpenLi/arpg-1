LogindPlayer = class('LogindPlayer', BinLogObject)

function LogindPlayer:GetAccount()
	return self:GetStr(PLAYER_STRING_FIELD_ACCOUNT)
end

function LogindPlayer:DefereSuccess()
	local slavehoder = self:GetSlavehoder()
	if(slavehoder > 0)then
		self:SetUInt32(PLAYER_FIELD_SLAVEHODER, -slavehoder)
	end
end

--获取某玩家标志位
function LogindPlayer:GetFlags(index)
	return self:GetBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

function LogindPlayer:UnSetFlags(index)
	return self:UnSetBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end


--获取某玩家礼包标志位
function LogindPlayer:GetGiftFlags(index)
	return self:GetBit(PLAYER_APPD_INT_FIELD_GIFT_FLAG, index)
end

--获取MapId
function LogindPlayer:GetMapId()
	return self:GetUInt32(PLAYER_FIELD_MAP_ID)
end

--设置传送的地图id和坐标
function LogindPlayer:SetTeleportInfo(mapid, posx, posy, general_id)
	self:SetUInt32(PLAYER_EXPAND_INT_TO_MAP, mapid)
	self:SetFloat(PLAYER_EXPAND_INT_TO_POS_X, posx)
	self:SetFloat(PLAYER_EXPAND_INT_TO_POS_Y, posy)
	self:SetUInt32(PLAYER_FIELD_INSTANCE_ID, 0)
	--outDebug('guid = '..self:GetGuid()..' name = '..self:GetName()..' mapid = '..mapid..' posx = '..posx..' posy = '..posy)
	if(general_id)then
		self:SetStr(PLAYER_STRING_FIELD_TELEPORT_GUID, general_id)
	end
end

--pk服，根据跨服类型选择要传送到的地图id
function LogindPlayer:SelectKuafuMapid(warid, kuafu_type, number)
	if(kuafu_type == KUAFU_TYPE_FENGLIUZHEN)then	
		local general_id = string.format("flz_%d", warid)		--warid即房间id
		self:SetTeleportInfo(KUAFU_FENGLIUZHEN_MAPID, 30, 30, general_id)
		
	end
	
	return true
end

--离线做些什么
function LogindPlayer:Logout()
	
end

--付费等级计算
function LogindPlayer:DoPayLevel()
	local pay_table = {0,5000,20000,50000,100000,200000,500000,800000,1000000,1500000,2000000}
	local rechage = self:GetUInt32(PLAYER_APPD_INT_FIELD_RECHARGE_SUM)
	local pay_level = #pay_table - 1
	for i = 1,#pay_table do
		if(rechage < pay_table[i])then
			pay_level = i - 2
			break
		end
	end
	return pay_level
end


--合服数据处理
function DoMergeSomething()

end

--初始化新玩家属性
function LogindPlayer:SetNewPlayerAttr()
	local config = tb_char_level[1]
	if config then
		for _,val in ipairs(config.prop)do
			if val[1] == EQUIP_ATTR_HP then
				self:SetDouble(PLAYER_FIELD_MAXHEALTH, val[2])
				self:SetDouble(PLAYER_FIELD_HEALTH, val[2])
				self:SetDouble(PLAYER_EXPAND_INT_NEXT_LEVEL_XP, config.next_exp)
			end
		end
	end
end