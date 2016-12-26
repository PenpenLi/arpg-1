--系统邮箱信息
local GlobalOfflineMail = class('GlobalOfflineMail', assert(BinLogObject))

function GlobalOfflineMail:ctor()
	
end

--礼包信息个数加1
function GlobalOfflineMail:Next()
	local cur_num = self:GetAttackStrutCount()
	if(cur_num >= MAX_OFFLINE_MAIL_INFO_COUNT-1)then		--离线礼包最多保留MAX_OFFLINE_MAIL_INFO_COUNT
		self:SetAttackStrutCount(0)	
	else
		self:AddUInt32(MAX_GIFTPACKS_INFO_INT_NOW_INDEX, 1)
	end
end	

--礼包信息int开始下标
function GlobalOfflineMail:Start()
	return GIFTPACKS_INT_FIELD_BEGIN + self:GetAttackStrutCount() * MAX_GIFTPACKS_INFO_INT
end

--礼包信息string开始下标
function GlobalOfflineMail:StringStart()
	return GIFTPACKS_STRING_FIELD_BEGIN + self:GetAttackStrutCount() * MAX_GIFTPACKS_INFO_STRING 
end

--获得礼包信息当前索引
function GlobalOfflineMail:GetAttackStrutCount()
	return self:GetUInt32(MAX_GIFTPACKS_INFO_INT_NOW_INDEX)
end

--设置礼包信息当前索引
function GlobalOfflineMail:SetAttackStrutCount( val)
	self:SetUInt32(MAX_GIFTPACKS_INFO_INT_NOW_INDEX, val)
end

--获取礼包ID
function GlobalOfflineMail:GetGiftPacksID()
	return self:GetUInt32(self:Start() + GIFTPACKS_INFO_INT_ID)
end

--设置礼包ID
function GlobalOfflineMail:SetGiftPacksID(val)
	self:SetUInt32(self:Start() + GIFTPACKS_INFO_INT_ID, val)
end

--获取礼包发放时间
function GlobalOfflineMail:GetGiftPacksStartTime()
	return self:GetUInt32(self:Start() + GIFTPACKS_INFO_INT_START_TIME)
end

--设置礼包发放时间
function GlobalOfflineMail:SetGiftPacksStartTime(val)
	self:SetUInt32(self:Start() + GIFTPACKS_INFO_INT_START_TIME, val)
end

--获取礼包结束时间
function GlobalOfflineMail:GetGiftPacksEndTime()
	return self:GetUInt32(self:Start() + GIFTPACKS_INFO_INT_END_TIME)
end

--设置礼包结束时间
function GlobalOfflineMail:SetGiftPacksEndTime(val)
	self:SetUInt32(self:Start() + GIFTPACKS_INFO_INT_END_TIME, val)
end

--获取礼包类型
function GlobalOfflineMail:GetGiftPacksType()
	return self:GetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE,0)
end

--设置礼包类型
function GlobalOfflineMail:SetGiftPacksType(val)
	self:SetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE, 0 ,val)
end

--获取礼包领取状态
function GlobalOfflineMail:GetGiftPacksReceive()
	return self:GetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE,1)
end

--设置礼包领取状态
function GlobalOfflineMail:SetGiftPacksReceive(val)
	self:SetByte(self:Start() + GIFTPACKS_INFO_INT_BYTE, 1 ,val)
end

--获取礼包名称
function GlobalOfflineMail:GetGiftPacksName()
	return self:GetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_NAME)
end

--设置礼包名称
function GlobalOfflineMail:SetGiftPacksName(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_NAME,val)
end

--获取礼包说明
function GlobalOfflineMail:GetGiftPacksDesc()
	return self:GetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_DESC)
end

--设置礼包说明
function GlobalOfflineMail:SetGiftPacksDesc(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_DESC,val)
end

--获取礼包所属
function GlobalOfflineMail:GetGiftPacksFrom()
	return self:GetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_FROM)
end

--设置礼包所属
function GlobalOfflineMail:SetGiftPacksFrom(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_FROM,val)
end

--获取礼包物品
function GlobalOfflineMail:GetGiftPacksItem(pos)
	local start
	if(pos == nil)then
		start = GIFTPACKS_STRING_FIELD_BEGIN + self:StringStart()
	else
		start = GIFTPACKS_STRING_FIELD_BEGIN + pos * MAX_GIFTPACKS_INFO_STRING
	end
	
	return self:GetStr(start + GIFTPACKS_INFO_STRING_GIFT_ITEM)
end

--设置礼包物品
function GlobalOfflineMail:SetGiftPacksItem(val)
	self:SetStr(self:StringStart() + GIFTPACKS_INFO_STRING_GIFT_ITEM,val)
end

--添加一个离线邮件
--[[
	gift_type   : 邮件类型
	start_time  : 发放时期
	end_time    : 结束日期
	gift_name   : 邮件名称
	gift_desc   : 邮件说明
	item_config : 邮件奖励
	to_guid     : 邮件所属
]]
function GlobalOfflineMail:AddOfflineMailInfo( gift_type, start_time, end_time, gift_name, gift_desc, item_config, to_guid)
	self:SetSystemMailID(0)
	self:SetSystemMailStartTime(start_time)
	self:SetSystemMailEndTime(end_time)
	self:SetSystemMailType(gift_type)

	self:SetSystemMailName(gift_name)
	self:SetSystemMailDesc(gift_desc)
	self:SetSystemMailItem(item_config)
	self:SetSystemMailFrom(to_guid)
	
	local indx = self:GetAttackStrutCount()
	playerLib.SetOfflineMailIndexByGuid(to_guid, indx)
	
	self:Next()
	
	return 1
end

function AddGiftPacksData(guid, id, gift_type,start_time,end_time,gift_name,gift_desc,item_config,item_from)
	if(guid == "")then
		return
	end
	
	local player = app.objMgr:getObj(guid)
	-- 没有就加离线文件
	if not player then 
		globalOfflineMail:AddOfflineMailInfo( gift_type, start_time, end_time, gift_name, gift_desc, item_config, guid)
		return 
	end
	
	-- 玩家自己加邮件
	local giftPack = player:getGiftPacksInfo()
	giftPack:AddGiftPacksInfo(gift_type, start_time, end_time, gift_name, gift_desc, item_config, "")
end



--服务器启动读取离线邮件
function GlobalOfflineMail:dealOfflineMail()
	local intIndex = GIFTPACKS_INT_FIELD_BEGIN
	local strIndex = GIFTPACKS_STRING_FIELD_BEGIN
	local size = self:GetUInt32Len()
	local curr = os.time()
	
	for i = 0, MAX_OFFLINE_MAIL_INFO_COUNT do
		if intIndex >= size then
			return
		end
		
		-- 时间满足 且 未领取
		if self:GetUInt32(intIndex + GIFTPACKS_INFO_INT_END_TIME) >= curr and self:GetByte(intIndex + GIFTPACKS_INFO_INT_BYTE, 1) == 0 then
			local guid = self:GetStr(strIndex + GIFTPACKS_INFO_STRING_GIFT_FROM)
			playerLib.SetOfflineMailIndexByGuid(guid, i)
		end
		
		intIndex = intIndex + MAX_GIFTPACKS_INFO_INT
		strIndex = strIndex + MAX_GIFTPACKS_INFO_STRING
	end
end

--检测离线邮件是否过期
function GlobalOfflineMail:checkOfflineMailIfExpire()
	local guidTable = playerLib.GetOfflineMailGuidTable()
	for _, guid in pairs(guidTable) do
		local indxTable = playerLib.GetOfflineMailIndiceByGuid(guid)
		for _, indx in pairs(indxTable) do
			local intIndex = GIFTPACKS_INT_FIELD_BEGIN + indx * MAX_GIFTPACKS_INFO_INT
			if self:GetUInt32(intIndex + GIFTPACKS_INFO_INT_END_TIME) < curr then
				playerLib.RemoveOfflineMailIndex(guid, indx)
			end
		end
	end
end

-- 玩家上限读取离线邮件
function GlobalOfflineMail:GetOfflineMail(playerInfo)
	local guid = playerInfo:GetGuid()
	local indxTable = playerLib.GetOfflineMailIndiceByGuid(guid)
	for _, indx in pairs(indxTable) do
		local intIndex = GIFTPACKS_INT_FIELD_BEGIN + indx * MAX_GIFTPACKS_INFO_INT
		local strIndex = GIFTPACKS_STRING_FIELD_BEGIN + indx * MAX_GIFTPACKS_INFO_STRING
		if self:GetUInt32(intIndex + GIFTPACKS_INFO_INT_END_TIME) >= curr and self:GetByte(intIndex + GIFTPACKS_INFO_INT_BYTE, 1) == 0 then
			self:SetByte(intIndex + GIFTPACKS_INFO_INT_BYTE, 1, 1)
			
			--[[
				把所有数据清了吧
			--]]
			for ii = 0, MAX_GIFTPACKS_INFO_INT-1 do
				self:SetUInt32(intIndex + ii, 0)
			end
			
			for ii = 0, MAX_GIFTPACKS_INFO_STRING-1 do
				self:SetStr(strIndex + ii, "")
			end
			
			playerLib.RemoveOfflineMailIndex(guid, indx)
			-- 玩家自己加邮件
			local giftPack = self:getGiftPacksInfo()
			
			local gift_type   = self:GetByte  (intIndex + GIFTPACKS_INFO_INT_BYTE, 0)
			local start_time  = self:GetUInt32(intIndex + GIFTPACKS_INFO_INT_START_TIME)
			local end_time    = self:GetUInt32(intIndex + GIFTPACKS_INFO_INT_END_TIME)
			
			local gift_name   = self:GetStr(strIndex + GIFTPACKS_INFO_STRING_GIFT_NAME)
			local gift_desc   = self:GetStr(strIndex + GIFTPACKS_INFO_STRING_GIFT_DESC)
			local item_config = self:GetStr(strIndex + GIFTPACKS_INFO_STRING_GIFT_ITEM)

			giftPack:AddGiftPacksInfo(gift_type, start_time, end_time, gift_name, gift_desc, item_config, "")
		end
	end
end
--[[
SYSTEM_MAIL_INFO_INT_ID = 0	-- 礼包ID
SYSTEM_MAIL_INFO_INT_START_TIME = 1	-- 发放时间
SYSTEM_MAIL_INFO_INT_END_TIME = 2	-- 结束时间
SYSTEM_MAIL_INFO_INT_TYPE = 3	-- 礼包类型
MAX_SYSTEM_MAIL_INFO_INT = 4
SYSTEM_MAIL_INFO_STRING_NAME = 0	-- 系统邮件名称
SYSTEM_MAIL_INFO_STRING_DESC = 1	-- 系统邮件说明
SYSTEM_MAIL_INFO_STRING_FROM = 2	-- 系统邮件出处，当玩家赠送时填写玩家名字，默认为空，系统赠送
SYSTEM_MAIL_INFO_STRING_ITEM = 3	-- 礼包物品集合
MAX_SYSTEM_MAIL_INFO_STRING = 4
]]

return GlobalOfflineMail