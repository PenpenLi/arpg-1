--礼包信息
GiftPacksInfo = class('GiftPacksInfo', BinLogObject)

--礼包信息个数加1
function GiftPacksInfo:Next()
	local cur_num = self:GetAttackStrutCount()
	if(cur_num >= MAX_GIFTPACKS_INFO_COUNT-1)then		--礼包信息最多保留MAX_GIFTPACKS_INFO_COUNT
		self:SetAttackStrutCount(0)	
	else
		self:AddUInt32(MAX_GIFTPACKS_INFO_INT_NOW_INDEX, 1)
	end
end	

--礼包信息int开始下标
function GiftPacksInfo:Start()
	return GIFTPACKS_INT_FIELD_BEGIN + self:GetAttackStrutCount() * MAX_GIFTPACKS_INFO_INT
end

--礼包信息string开始下标
function GiftPacksInfo:StringStart()
	return GIFTPACKS_STRING_FIELD_BEGIN + self:GetAttackStrutCount() * MAX_GIFTPACKS_INFO_STRING 
end

--获得礼包信息当前索引
function GiftPacksInfo:GetAttackStrutCount()
	return self:GetUInt32(MAX_GIFTPACKS_INFO_INT_NOW_INDEX)
end

--设置礼包信息当前索引
function GiftPacksInfo:SetAttackStrutCount( val)
	self:SetUInt32(MAX_GIFTPACKS_INFO_INT_NOW_INDEX, val)
end

--获取礼包ID
function GiftPacksInfo:GetGiftPacksID()
	return self:GetUInt32(self:Start() + GIFTPACKS_INFO_INT_ID)
end

--设置礼包ID
function GiftPacksInfo:SetGiftPacksID(val)
	self:SetUInt32(self:Start() + GIFTPACKS_INFO_INT_ID, val)
end

--获取礼包发放时间
function GiftPacksInfo:GetGiftPacksStartTime()
	return self:GetUInt32(self:Start() + GIFTPACKS_INFO_INT_START_TIME)
end

--设置礼包领取时间
function GiftPacksInfo:SetGiftPacksStartTime(val)
	self:SetUInt32(self:Start() + GIFTPACKS_INFO_INT_START_TIME, val)
end

--获取礼包结束时间
function GiftPacksInfo:GetGiftPacksEndTime()
	return self:GetUInt32(self:Start() + GIFTPACKS_INFO_INT_END_TIME)
end

--设置礼包结束时间
function GiftPacksInfo:SetGiftPacksEndTime(val)
	self:SetUInt32(self:Start() + GIFTPACKS_INFO_INT_END_TIME, val)
end

--获取礼包类型
function GiftPacksInfo:GetGiftPacksType()
	return self:GetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE,0)
end

--设置礼包类型
function GiftPacksInfo:SetGiftPacksType(val)
	self:SetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE, 0 ,val)
end

--获取礼包领取状态
function GiftPacksInfo:GetGiftPacksReceive()
	return self:GetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE,1)
end

--设置礼包领取状态
function GiftPacksInfo:SetGiftPacksReceive(val)
	self:SetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE, 1 ,val)
end

--获取礼包阅读状态
function GiftPacksInfo:GetGiftPacksRead()
	return self:GetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE,2)
end

--设置礼包阅读状态
function GiftPacksInfo:SetGiftPacksRead(val)
	self:SetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE, 2 ,val)
end

--获取礼包是否删除
function GiftPacksInfo:GetGiftPacksIsDelete()
	return self:GetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE,3)
end

--设置礼包是否删除
function GiftPacksInfo:SetGiftPacksIsDelete(val)
	self:SetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE, 3 ,val)
end

--获取礼包名称
function GiftPacksInfo:GetGiftPacksName()
	return self:GetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_NAME)
end

--设置礼包名称
function GiftPacksInfo:SetGiftPacksName(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_NAME,val)
end

--获取礼包说明
function GiftPacksInfo:GetGiftPacksDesc()
	return self:GetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_DESC)
end

--设置礼包说明
function GiftPacksInfo:SetGiftPacksDesc(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_DESC,val)
end

--获取礼包来源
function GiftPacksInfo:GetGiftPacksFrom()
	return self:GetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_FROM)
end

--设置礼包来源
function GiftPacksInfo:SetGiftPacksFrom(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_FROM,val)
end

--获取礼包物品
function GiftPacksInfo:GetGiftPacksItem(pos)
	local start
	if(pos == nil)then
		start = GIFTPACKS_STRING_FIELD_BEGIN + self:StringStart()
	else
		start = GIFTPACKS_STRING_FIELD_BEGIN + pos * MAX_GIFTPACKS_INFO_STRING
	end
	
	return self:GetStr(start + GIFTPACKS_INFO_STRING_GIFT_ITEM)
end

--设置礼包物品
function GiftPacksInfo:SetGiftPacksItem(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_ITEM,val)
end

--判断礼包是否已存在
function GiftPacksInfo:IsGiftPacksInfo(id)
	for i = 0, MAX_GIFTPACKS_INFO_COUNT -1
	do
		local start = GIFTPACKS_INT_FIELD_BEGIN + MAX_GIFTPACKS_INFO_INT * i
		local index = start + GIFTPACKS_INFO_INT_ID
		if(self:GetUInt32(index) ~= 0 and self:GetUInt32(index) == id)then
			return start
		end
	end
	return -1
end

--添加一个礼包信息
function GiftPacksInfo:AddGiftPacksInfo( id, gift_type, start_time, end_time, gift_name, gift_desc, item_config, item_from)
	if(id ~= 0 and self:IsGiftPacksInfo(id) ~= -1)then	--判断是否已经有礼包了
		return 0
	end
	self:SetGiftPacksID(id)
	self:SetGiftPacksStartTime(start_time)
	self:SetGiftPacksEndTime(end_time)
	self:SetGiftPacksType(gift_type)
	self:SetGiftPacksReceive(0)
	self:SetGiftPacksRead(0)
	self:SetGiftPacksIsDelete(0)
	self:SetGiftPacksName(gift_name)
	self:SetGiftPacksDesc(gift_desc)
	self:SetGiftPacksItem(item_config)
	self:SetGiftPacksFrom(item_from)
	self:Next()
	return 1
end

function GiftPacksInfo:GetGiftPacksFromType(player,id,oper_type)
	--切割下ID串
	local id_tokens = lua_string_split(id,",")
	local id_paras = {0}
	for i = 1, #id_tokens 
	do
		id_paras[i] = tonumber(id_tokens[i])
		if(id_paras[i] == nil)then
			break
		end
	end
	
	for i = 1,#id_paras do				
		local start = GIFTPACKS_INT_FIELD_BEGIN + id_paras[i] * MAX_GIFTPACKS_INFO_INT
		if(id_paras[i]  < 0 and id_paras[i] > MAX_GIFTPACKS_INFO_COUNT)then
			outDebug('not giftpacks id=='..id_paras[i])
			return
		end
		--解析物品集合
		local item_config = self:GetGiftPacksItem(id_paras[i])
		local tokens = lua_string_split(item_config,",")
		if(oper_type == GIFT_PACKS_OPER_TYPE_RECEIVE)then		--领取
			if(self:GetByte(start + GIFTPACKS_INFO_INT_BYTE,1) == 1)then
				outDebug('giftpacks is have')
				return
			end
			self:SetByte(start + GIFTPACKS_INFO_INT_BYTE,1,1)
			
			local paras = {0}
			for j = 1, #tokens 
			do
				paras[j] = tonumber(tokens[j])
				if(paras[j] == nil)then
					paras[j] = 0
				end
			end
			--有物品时候执行
			if(#paras > 1)then
				for k = 1, #paras, 3
				do
					--校验下
					if(#paras < k+2)then
						break
					end
					local entry = paras[k]
					local count = paras[k+1]
					local failtime = paras[k+2]					
					player:AddItemByEntry(entry, count, MONEY_CHANGE_MAIL, LOG_ITEM_OPER_TYPE_GIFT_PACKS, ITEM_BIND_NONE, true, true, 0, failtime)					
				end
			end			
		elseif(oper_type == GIFT_PACKS_OPER_TYPE_READ)then	--已读
			if(self:GetByte(start + GIFTPACKS_INFO_INT_BYTE,2) == 0)then
				self:SetByte(start + GIFTPACKS_INFO_INT_BYTE,2,1)
			end
		elseif(oper_type == GIFT_PACKS_OPER_TYPE_DELETE)then	--删除
			if(self:GetByte(start + GIFTPACKS_INFO_INT_BYTE,3) == 0 and (self:GetByte(start + GIFTPACKS_INFO_INT_BYTE,1) == 1 or #tokens <= 1))then
				self:SetByte(start + GIFTPACKS_INFO_INT_BYTE,3,1)
			end
		end	
	end
end
	
function AddGiftPacksData(guid,id,gift_type,start_time,end_time,gift_name,gift_desc,item_config,item_from)
	if(guid == "")then
		return
	end
	local data = {}
	data.name = 'AddGiftPacksData'
	data.callback_guid = guid
	data.id = id
	data.gift_type = gift_type
	data.start_time = start_time
	data.end_time = end_time
	data.gift_name = gift_name
	data.gift_desc = gift_desc
	data.item_config = item_config
	data.item_from = item_from
	function data.fun (data, objs)		
		local player = objs[data.callback_guid]
		if not player then return end
		local gift = player:getGiftPacksInfo()
		if not gift then return end
		gift:AddGiftPacksInfo(data.id, data.gift_type, data.start_time, data.end_time, data.gift_name, data.gift_desc, data.item_config, data.item_from)
	end
	GetObjects(data)
end

function DoGetGiftPacksInfo()
	--获取礼包数据
	local result = app.dbAccess:SearchGiftPacksInfo()
	for _k,_v in pairs(result) do
		if(_v.u_end_time < os.time())then
			app.dbAccess:SaveGiftPacksStatus(GIFT_PACKS_STATUS_START,GIFT_PACKS_STATUS_END,_v.to_id,_v.id,_v.server_name)	--时间过了，那就直接发放结束
		else
			if(_v.i_audience_type == GIFT_PACKS_AUDIENCE_TYPE_ONE)then	--个人礼包
				AddGiftPacksData(_v.to_id,_v.id,_v.i_gift_type,_v.u_start_time,_v.u_end_time,_v.gift_name,_v.gift_desc,_v.s_item_config,"")
				app.dbAccess:SaveGiftPacksStatus(GIFT_PACKS_STATUS_START,GIFT_PACKS_STATUS_OK,_v.to_id,_v.id,_v.server_name)
			elseif(_v.i_audience_type == GIFT_PACKS_AUDIENCE_TYPE_ALL or _v.i_audience_type == GIFT_PACKS_AUDIENCE_TYPE_ALL_ONLINE)then	--全服礼包
				--全服礼包就不采用回调方式
				if(_v.id == 0)then	--全服礼包不允许接受为ID为0的
					return
				end
				
				--取所有在线玩家
				app.objMgr:foreachAllPlayer(function ( player)		
					local gift = player:getGiftPacksInfo()								
					if gift and player:GetCharCreateTime() < _v.u_start_time then						
						gift:AddGiftPacksInfo(_v.id,_v.i_gift_type,_v.u_start_time,_v.u_end_time,_v.gift_name,_v.gift_desc,_v.s_item_config,"")					
					end					
				end)

				if(_v.i_audience_type == GIFT_PACKS_AUDIENCE_TYPE_ALL_ONLINE)then	--如果是全服在线礼包就将状态置一下				
					app.dbAccess:SaveGiftPacksStatus(GIFT_PACKS_STATUS_START,GIFT_PACKS_STATUS_OK,_v.to_id,_v.id,_v.server_name)
				end
			end
		end
	end
end

return GiftPacksInfo
