----------------------------------------------------------------------------------------------------------------------------------------------
--玩家封装
PlayerInfo = class('PlayerInfo', BinLogObject)

local guidMgr = require 'share.guid_manager'

--将所有的发包及解包功能附加到该类
require('share.protocols'):extend(PlayerInfo)

--构造函数
function PlayerInfo:ctor( offlineObjects )
	--如果是离线数据,则使用这东西，会把所有机关数据引用到这个地方
	self.offlineObjects = offlineObjects
end

--获得会话id
function PlayerInfo:GetSessionId()
	return playerLib.GetFD(self.ptr)
end

--最重要的操作结果
function PlayerInfo:CallOptResult( typed, reason, data )
	--碰上字符串数组自动拼接	
	if type(data) == 'table' then
		data = string.join('|', data)
	else
		data = tostring(data) or ''
	end
	self:call_operation_failed(typed, reason, data)
end

--获得玩家所在的场景fd
function PlayerInfo:GetScenedFD()
	return self:GetUInt32(PLAYER_FIELD_FD)
end

-- 获得屏蔽人员个数
function PlayerInfo:GetBlockCounts()
	return self:GetUInt32(PLAYER_INT_FIELD_BLOCK_COUNT)
end

-- 增加屏蔽人员个数
function PlayerInfo:AddBlockCounts()
	return self:AddUInt32(PLAYER_INT_FIELD_BLOCK_COUNT, 1)
end

-- 减少屏蔽人员个数
function PlayerInfo:SubBlockCounts()
	return self:SubUInt32(PLAYER_INT_FIELD_BLOCK_COUNT, 1)
end

-- 设置屏蔽列表的str
function PlayerInfo:SetBlockGuids(val)
	self:SetStr(PLAYER_STRING_FIELD_BLOCK_GUIDS, val)
end

-- 是否有坐骑
function PlayerInfo:IsMountActived()
	local level = self:GetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 0)
	return level > 0
end

function PlayerInfo:SetMountLevel(level)
	self:SetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 0, level)
end

function PlayerInfo:SetMountStar(star)
	self:SetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 1, star)
end

--[[
rewardDict :  {{itemId, count},{itemId1, count1}}
--]]
function PlayerInfo:AppdAddItems(rewardDict, money_oper_type, item_oper_type, deadline)
	deadline = deadline or 0
	self:PlayerAddItems(rewardDict, money_oper_type, item_oper_type, deadline)
	-- 获得信息
	local dict = changeTableStruct(rewardDict)
	local list = Change_To_Item_Reward_Info(dict)
	self:call_item_notice (list)
end

--[[
有可能场景服发来的增加道具的接口也是这个
rewardDict :  {{itemId, count},{itemId1, count1}}
--]]
function PlayerInfo:PlayerAddItems(rewardDict, money_oper_type, item_oper_type, deadline)
	money_oper_type = money_oper_type or MONEY_CHANGE_SELECT_LOOT
	item_oper_type  = item_oper_type  or LOG_ITEM_OPER_TYPE_LOOT
	deadline	= deadline or 0
	
	local itemDict = {}
	-- 先把资源和经验加了, 放背包的道具第二步算
	for _, itemInfo in pairs(rewardDict) do
		
		local itemId = itemInfo[ 1 ]
		local count  = itemInfo[ 2 ]		
		if IsResource(itemId) then
			-- 加人物资源
			local moneyType = GetMoneyType(itemId)
			self:AddMoney(moneyType, money_oper_type, count)
		elseif itemId == Item_Loot_Exp then
			-- 加经验 发送到场景服
			self:CallScenedDoSomething(APPD_SCENED_ADD_EXP, count)
		else
			if tb_item_template[itemId] then
				table.insert(itemDict, {itemId, count})
			end
		end
	end

	-- 加道具的时候判断是否背包满了
	if #itemDict > 0 then
		local indx = -1
		local itemMgr = self:getItemMgr()
		-- 放得下的先放
		for i = 1, #itemDict do
			local entry = itemDict[ i ][ 1 ]
			local count = itemDict[ i ][ 2 ]
			-- 判断背包是否放的下
			if not itemMgr:canHold(BAG_TYPE_MAIN_BAG, entry, count, 1, 0) then
				indx = i
				break
			end
			local bind = tb_item_template[entry].bind_type
			self:AddItemByEntry(entry, count, nil, item_oper_type, bind, true, true, 0, deadline)
		end
		
		-- 放不下的存邮件
		if indx > 0 then
			local mailItem = {}
			for i = indx, #itemDict do
				table.insert(mailItem, itemDict[ i ][ 1 ])
				table.insert(mailItem, itemDict[ i ][ 2 ])
			end
			
			local itemConfig = string.join(",", mailItem)
			local data = GetMailEntryId(GIFT_PACKS_TYPE_BAG_FULL, 0)
			local desc = tb_mail[data].desc
			local name = tb_mail[data].name
			local giftType = tb_mail[data].source
			AddGiftPacksData(self:GetGuid(),0,giftType,os.time(),os.time() + 86400*30, name, desc, itemConfig, "系统")
		end
	end
end

-- 玩家加道具
function PlayerInfo:PlayerAddItem(itemId, count, item_oper_type, deadline)

	item_oper_type  = item_oper_type  or LOG_ITEM_OPER_TYPE_LOOT
	deadline = deadline or 0
	
	if IsResource(itemId) or itemId == Item_Loot_Exp  then
		return
	else
		if tb_item_template[itemId] then
			-- 加道具
			local bind = tb_item_template[itemId].bind_type
			self:AddItemByEntry(itemId, count, nil, item_oper_type, bind, true, true, 0, deadline)
		end
	end
end

-- 骑乘状态
function PlayerInfo:rideFlag()
	return self:GetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 2)
end

-- 幻化id
function PlayerInfo:GetCurrIllusionId()
	return self:GetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 3)
end

-- 设置幻化id
function PlayerInfo:SetCurrIllusionId(illuId)
	self:SetByte(PLAYER_INT_FIELD_MOUNT_LEVEL, 3, illuId)
end

-- 是否骑乘
function PlayerInfo:isRide()
	return self:IsMountActived() and self:rideFlag() > 0
end

-- 设置VIP等级
function PlayerInfo:SetVIP(vipLevel, time)
	
	if vipLevel > VIP_MAX_LEVEL then
		return
	end
	
	self:SetUInt32(PLAYER_FIELD_VIP_LEVEL, vipLevel)
	self:SetUInt32(PLAYER_FIELD_VIP_TIME_OUT, time)
end

-- 是否达到该vip等级
function PlayerInfo:isVIP(vipLevel)
	return self:GetUInt32(PLAYER_FIELD_VIP_LEVEL) >= vipLevel and self:GetUInt32(PLAYER_FIELD_VIP_TIME_OUT) >= os.time()
end

-- 获得vip等级
function PlayerInfo:GetVIP()
	local vipLevel = self:GetUInt32(PLAYER_FIELD_VIP_LEVEL)
	if self:GetUInt32(PLAYER_FIELD_VIP_TIME_OUT) < os.time() then
		vipLevel = 0
	end
	return vipLevel
end

-- 玩家是否还活着
function PlayerInfo:IsAlive ()
	return self:GetUInt32(PLAYER_FIELD_DEATH_STATE) == DEATH_STATE_ALIVE
end
	
--获得玩家主下标的flag标志
function PlayerInfo:GetPlayerFlags (index)
	return self:GetBit(PLAYER_FIELD_FLAGS, index)
end

--设置玩家主下标的flag标志
function PlayerInfo:SetPlayerFlags ( index)
	self:SetBit(PLAYER_FIELD_FLAGS, index)
end

-- 获得帮派guid
function PlayerInfo:GetFactionId ()
	return self:GetStr(PLAYER_STRING_FIELD_FACTION_GUID)
end

--设置帮派guid
function PlayerInfo:SetFactionId (factionId)
	self:SetStr(PLAYER_STRING_FIELD_FACTION_GUID, factionId)
end

-- 获得帮派名字
function PlayerInfo:GetFactionName ()
	return self:GetStr(PLAYER_STRING_FIELD_FACTION_NAME)
end

--设置帮派名字
function PlayerInfo:SetFactionName (name)
	self:SetStr(PLAYER_STRING_FIELD_FACTION_NAME, name)
end



--设置玩家主下标的flag标志
function PlayerInfo:UnSetPlayerFlags (index)
	self:UnSetBit(PLAYER_FIELD_FLAGS, index)
end

--把某玩家标志位变成1
function PlayerInfo:SetFlags ( index)
	self:SetBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

--把某玩家标志位变成0
function PlayerInfo:UnSetFlags ( index)
	self:UnSetBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

--获取某玩家标志位
function PlayerInfo:GetFlags ( index)
	return self:GetBit(PLAYER_APPD_INT_FIELD_FLAG, index)
end

--设置显示用装备的模板下标
function PlayerInfo:SetEquipment ( pos, val)
	if(self:GetEquipment(pos) ~= val)then
		self:SetUInt32(PLAYER_FIELD_EQUIPMENT + pos, val)
	end
end

--获得显示用装备的模板下标
function PlayerInfo:GetEquipment ( pos)
	return self:GetUInt32(PLAYER_FIELD_EQUIPMENT + pos)
end

--获取MaxHp
function PlayerInfo:GetMaxHp ()
	return self:GetDouble(PLAYER_FIELD_MAXHEALTH)
end


function PlayerInfo:GetMoveSpd ()
	return self:GetDouble(PLAYER_FIELD_MOVESPEED)
end

--获取Hp
function PlayerInfo:GetHp ()
	return self:GetDouble(PLAYER_FIELD_HEALTH)
end

--获取MapId
function PlayerInfo:GetMapId ()
	return self:GetUInt32(PLAYER_FIELD_MAP_ID)
end

--获取Position
function PlayerInfo:GetPosition ()
	return self:GetFloat(PLAYER_FIELD_POS_X), self:GetFloat(PLAYER_FIELD_POS_Y)
end

--获取性别
function PlayerInfo:GetGender ()
	return self:GetByte(PLAYER_FIELD_BYTES_0, 0)
end

--获得在线时长
function PlayerInfo:GetOnlineTime ()
	return self:GetUInt32(PLAYER_FIELD_ONLINE_TIME)
end

--设置在线时长
function PlayerInfo:SetOnlineTime ( val)
	self:SetUInt32(PLAYER_FIELD_ONLINE_TIME, val)
end

--获取阵营
function PlayerInfo:GetFaction ()
	return self:GetByte(PLAYER_FIELD_BYTES_0, 1)
end

function PlayerInfo:GetRace ()
	return self:GetByte(PLAYER_FIELD_BYTES_0,2)
end

--获取头像
function PlayerInfo:GetHead ()
	return self:GetByte(PLAYER_FIELD_BYTES_3, 0)
end

--获得头发
function PlayerInfo:GetHair ()
	return self:GetByte(PLAYER_FIELD_BYTES_3,1)
end

--获取攻击模式
function PlayerInfo:GetAttackMode ()
	return self:GetByte(PLAYER_FIELD_BYTES_3, 3)
end

--获得pvp状态
function PlayerInfo:GetPVPState ()
	return self:GetBit(PLAYER_SCENED_INT_FLAGS, PLAYER_SCENED_FLAS_PVP_STATE)
end

--获取是否挂机
function PlayerInfo:GetHungUp ()
	return self:GetBit(PLAYER_SCENED_INT_FLAGS, PLAYER_SCENED_FLAS_HUNG_UP)
end

--获取等级
function PlayerInfo:GetLevel ()
	return self:GetUInt32(PLAYER_FIELD_LEVEL)
end

--获取经验
function PlayerInfo:GetExp ()
	return self:GetDouble(PLAYER_EXPAND_INT_XP)
end

--获取战斗力
function PlayerInfo:GetForce ()
	return self:GetDouble(PLAYER_FIELD_FORCE)
end

--获取付费等级
function PlayerInfo:GetPayLevel ()
	return self:GetByte(PLAYER_FIELD_BYTES_2, 1)
end

--设置付费等级
function PlayerInfo:SetPayLevel (val)
	return self:SetByte(PLAYER_FIELD_BYTES_2, 1, val)
end

--获取免费复活次数
function PlayerInfo:GetFreeReliveCount ()
	return self:GetByte(PLAYER_FIELD_BYTES_2, 2)
end

--设置免费复活次数
function PlayerInfo:SetFreeReliveCount (val)
	return self:SetByte(PLAYER_FIELD_BYTES_2, 2, val)
end

--获取称号
function PlayerInfo:GetTitle ()
	return self:GetByte(PLAYER_FIELD_BYTES_2, 3)
end

--获取平台信息
function PlayerInfo:GetPingTaiInfo ()
	return self:GetStr(PLAYER_APPD_STRING_FIELD_PINGTAI_INFO)
end

-- 判断钱是否足够
function PlayerInfo:checkMoneyEnough(moneyType, cost)
	local value = self:GetMoney(moneyType)
	return value >= cost and cost >= 0
end

-- 判断钱是否足够
function PlayerInfo:checkMoneyEnoughs(costTable, times)
	times = times or 1
	
	-- 判断重复
	local reps = {} 	
	for _, res in pairs(costTable) do
		if reps[res[ 1 ]] ~= nil then
			outFmtError("designer has type invalid data")
			return false
		end
		reps[res[ 1 ]] = 1
	end
	
	-- 检测是否可扣
	for _, res in pairs(costTable) do
		if not self:checkMoneyEnough(res[ 1 ], res[ 2 ] * times) then
			return false
		end
	end
	
	return true
end


-- 判断钱是否足够(绑定元宝不够用元宝)
-- 返回
-- true, costTable
-- false, nil
function PlayerInfo:checkMoneyEnoughIfUseGoldIngot(costTable, times)
	times = times or 1
	
	-- 判断重复
	local reps = {} 	
	for _, res in pairs(costTable) do
		if reps[res[ 1 ]] ~= nil then
			outFmtError("designer has type invalid data")
			return false, nil
		end
		reps[res[ 1 ]] = 1
	end
	
	
	-- 先把不能扣的绑定元宝转成元宝
	local cost2 = {}
	-- 检测是否可扣
	for _, res in pairs(costTable) do
		-- 不能有负的
		if res[ 2 ] < 0 then
			return false, nil
		end
		if not self:checkMoneyEnough(res[ 1 ], res[ 2 ] * times) then
			if res[ 1 ] ~= MONEY_TYPE_BIND_GOLD then
				return false, nil
			end
			local prev = self:GetMoney(res[ 1 ])
			local need = res[ 2 ] * times - prev
			-- 加元宝的
			AddTempInfoIfExist(cost2, MONEY_TYPE_GOLD_INGOT, need)
			-- 加绑定元宝
			if prev > 0 then
				AddTempInfoIfExist(cost2, MONEY_TYPE_BIND_GOLD , prev)
			end
		else
			AddTempInfoIfExist(cost2, res[ 1 ], res[ 2 ] * times)
		end
	end
	
	
	-- 检测是否可扣
	for _, res in pairs(cost2) do
		if not self:checkMoneyEnough(res[ 1 ], res[ 2 ]) then
			return false, nil
		end
	end
	
	return true, cost2
end


-- 扣除钱
function PlayerInfo:costMoneys(oper_type, costTable, times)
	times = times or 1
	if times < 1 then
		return false
	end
	-- 判断是否可扣除
	if not self:checkMoneyEnoughs(costTable, times) then
		return false
	end
	
	-- 实际扣除
	for _, res in pairs(costTable) do
		self:SubMoney(res[ 1 ], oper_type, res[ 2 ] * times)
	end
	
	return true
end

--获取金钱数量
function PlayerInfo:GetMoney ( money_type)
	return playerLib.GetMoney(self.ptr,money_type)
end

--金钱减少
function PlayerInfo:SubMoney ( money_type, oper_type, val, p1, p2, p3, p4, p5)
	if(val <= 0)then
		return false
	end
	val = -1 * val
	if(p1 == nil)then
		p1 = ""
	end
	if(p2 == nil)then
		p2 = 0
	end
	if(p3 == nil)then
		p3 = 0
	end
	if(p4 == nil)then
		p4 = 0
	end
	if(p5 == nil)then
		p5 = 0
	end
	return playerLib.ModifyMoney(self.ptr, money_type, oper_type, val, p1, p2, p3, p4, p5)
end

--金钱增加
function PlayerInfo:AddMoney ( money_type, oper_type, val, p1, p2, p3, p4, p5)
	if(val <= 0)then
		return false
	end
	if(p1 == nil)then
		p1 = ""
	end
	if(p2 == nil)then
		p2 = 0
	end
	if(p3 == nil)then
		p3 = 0
	end
	if(p4 == nil)then
		p4 = 0
	end
	if(p5 == nil)then
		p5 = 0
	end
	return playerLib.ModifyMoney(self.ptr, money_type, oper_type, val, p1, p2, p3, p4, p5)
end

--获取元宝和绑元数量
function PlayerInfo:GetGoldMoney ()
	return self:GetMoney(MONEY_TYPE_GOLD_INGOT) + self:GetMoney(MONEY_TYPE_BIND_GOLD)
end

--消耗元宝和绑元
function PlayerInfo:SubGoldMoney (log_type,val)
	if(self:GetMoney(MONEY_TYPE_BIND_GOLD) >= val)then
		return self:SubMoney(MONEY_TYPE_BIND_GOLD,log_type,val)
	else
		local money = val - self:GetMoney(MONEY_TYPE_BIND_GOLD)
		if(self:GetMoney(MONEY_TYPE_BIND_GOLD) > 0 and self:SubMoney(MONEY_TYPE_BIND_GOLD,log_type,self:GetMoney(MONEY_TYPE_BIND_GOLD)) == false)then
			return false
		end
		return self:SubMoney(MONEY_TYPE_GOLD_INGOT,log_type,money)
	end
	return false
end

--玩家消费行为
function PlayerInfo:OnConsumption(money_type,val)
	local limit_acti = self:getLimitActivityInfo()
	if limit_acti then
		return limit_acti:OnConsumption(self, money_type, val)
	end
end

-- 处理消费元宝统计
function PlayerInfo:DoGlodConsumeStatistics ( val)
	-- 添加七天内累计消费
	local cur_tm = os.time()
	if cur_tm <= DoHowLongKaiFuTime(7) then
		local count = self:GetKfhdTotalConsumeNum()
		count = count + val
		if count > MAX_UINT32_NUM then
			count = MAX_UINT32_NUM
		end
		self:SetKfhdTotalConsumeNum(count)
	end
end

--获得角色创建时间
function PlayerInfo:GetCharCreateTime ()
	return self:GetUInt32(PLAYER_EXPAND_INT_CREATE_TIME)
end

--返回在线时长
function PlayerInfo:GetDailyOnlineTime ()
	return self:GetUInt32(PLAYER_APPD_INT_FIELD_DAILY_TIME)
end

--设置在线时长
function PlayerInfo:SetDailyOnlineTime ( val)
	self:SetUInt32(PLAYER_APPD_INT_FIELD_DAILY_TIME, val)
end

-- 获得系统邮件的序号
function PlayerInfo:GetSystemMailSeq()
	return self:GetUInt32(PLAYER_INT_FIELD_SYSTEM_MAIL_ID)
end

-- 设置系统邮件的序号
function PlayerInfo:SetSystemMailSeq(val)
	return self:SetUInt32(PLAYER_INT_FIELD_SYSTEM_MAIL_ID, val)
end

--玩家登录做点什么,或者场景服启动做点什么？
function PlayerInfo:Login()
	local isPkServer = globalGameConfig:IsPKServer()
	if isPkServer then
		--战斗服登录
		self:LoginPk()
		return
	end
	
	--0点重置	
	self:DoResetDaily()

	local current_time = os.time()

	--登入时重设装备下标
	self:UpdatePlayerEquipment()

	--是否新手玩家
	if(self:GetFlags(PLAYER_APPD_INT_FIELD_FLAGS_NEW_PLAYER) == false)then
		--置为老玩家
		self:SetFlags(PLAYER_APPD_INT_FIELD_FLAGS_NEW_PLAYER)
	else
		--发送玩家属性到场景服
		playerLib.SendAttr(self.ptr)
	end

	self:socialLogIn()
	self:factionLogin()
	
	self:GetOfflineMail()
	globalSystemMail:checkIfHasSystemMail(self)
end

--pk服玩家登陆做点啥
function PlayerInfo:LoginPk()
 end 

--玩家下线后
function PlayerInfo:Logout ()
	--清空好友申请列表
	self:socialLogOut()
	self:factionLogOut()
end

--有多少个物品
function PlayerInfo:CountItem (entry, bag_id, bind_type, fail_time)
	local itemMgr = self:getItemMgr()
	if(bag_id == nil)then
		bag_id = BAG_TYPE_MAIN_BAG
	end
	
	return itemMgr:countItem(bag_id, entry, bind_type, fail_time)	
end

--根据物品模板扣除物品
function PlayerInfo:SubItemByEntry( entry, count )
	local itemMgr = self:getItemMgr()
	return itemMgr:delItem(entry, count) ~= SUB_ITEM_FAIL
end
	
--所有包裹共有多少个物品
function PlayerInfo:CountAllItem(entry, bind_type)
	local itemMgr = self:getItemMgr()
	return itemMgr:countAllItem(entry, bind_type)
end


--获取充值总数
function PlayerInfo:GetRechageSum ()
	return self:GetUInt32(PLAYER_APPD_INT_FIELD_RECHARGE_SUM)
end

--获取最后充值ID
function PlayerInfo:GetRechageID ()
	return self:GetStr(PLAYER_STRING_FIELD_RECHARGE_ID)
end

--设置最后充值ID
function PlayerInfo:SetRechageID (val)
	self:SetStr(PLAYER_STRING_FIELD_RECHARGE_ID,val)
end

--获取最后一笔充值时间
function PlayerInfo:GetRechageLastTime ()
	return self:GetUInt32(PLAYER_APPD_INT_FIELD_LAST_RECHARGE_TIME)
end

--设置最后一笔充值时间
function PlayerInfo:SetRechageLastTime ( val)
	self:SetUInt32(PLAYER_APPD_INT_FIELD_LAST_RECHARGE_TIME, val)
end

--充值后
function PlayerInfo:DoAddRechargeSum (recharge_id,val,recharge_time)
	if(self:GetRechageLastTime() <= recharge_time and self:GetRechageID() ~= recharge_id)then
		self:AddUInt32(PLAYER_APPD_INT_FIELD_RECHARGE_SUM,val)
		self:SetRechageLastTime(recharge_time)
		self:SetRechageID(recharge_id)
		--self:AddUInt32(PLAYER_HT_INT_FIELD_RECHARGE_COUNT,1)

		--限时活动充值
		local limit_acti = self:getLimitActivityInfo()
		if limit_acti then
			limit_acti:OnRecharge(self, val, recharge_id, recharge_time)
		end

		--设置下付费等级
		local pay_table = {0,5000,20000,50000,100000,200000,500000,800000,1000000,1500000,2000000}
		local rechage = self:GetRechageSum()
		local pay_level = #pay_table - 1
		for i = 1,#pay_table do
			if(rechage < pay_table[i])then
				pay_level = i - 2
				break
			end
		end
		if(pay_level ~= self:GetPayLevel())then
			self:SetPayLevel(pay_level)
		end
		
		local vipLev = 0
		for k,v in ipairs(tb_vip_base) do
			local cz = v.chongzhi
			if rechage >= cz then
				vipLev = v.id
			else
				break
			end
		end
		
		local tm = os.time() + 30 * 24 * 3600
		self:SetVIP(vipLev,tm)
		
	end
end

--私聊后做点什么
function PlayerInfo:DoAfterChatWhisper ( friendGuid)
	
end

--获取玩家账号
function PlayerInfo:GetAccount ()
	return self:GetStr(PLAYER_STRING_FIELD_ACCOUNT)
end

--背包扩展
function PlayerInfo:DoBagExtension(bag_id,extension_type,bag_pos)
	-- local itemMgr = self:getItemMgr()
	-- if(bag_id == BAG_TYPE_MAIN_BAG)then
		-- --获取背包大小
		-- local bag_size = itemMgr:getBagSize(bag_id)
		-- if(bag_size == nil or bag_size >= MAX_BAG_MAIN_SIZE_EXTENSION)then
			-- return
		-- end
		-- if(bag_size >= bag_pos and extension_type == BAG_EXTENSION_TYPE_GOLD)then
			-- return
		-- end
		-- local bag_game_set = tb_game_set[1]
		-- if(bag_game_set == nil)then
			-- return
		-- end
		-- --程序格式：背包格子所需时长=背包开启时长系数*（当前已开启的背包格子-初始开启格子数-1）*（当前已开启的背包格子-初始开启格子数）+背包开启时间参数
		-- local config = bag_game_set.value
		-- local next_time = math.floor(config[3] * (bag_pos - (config[1]-1)) * (bag_pos - config[1])) + config[4]
		-- --元宝开启
		-- if(extension_type == BAG_EXTENSION_TYPE_GOLD)then
			-- local all_time = self:GetExtensionEndTime() - os.time()
			-- for i = bag_size + 2,bag_pos do
				-- all_time = all_time +  math.floor(config[3] * (i - (config[1]-1)) * (i - config[1])) + config[4]
			-- end
			-- local money = math.ceil((all_time/60 + 1)*config[5])
			-- if(self:GetMoney(MONEY_TYPE_GOLD_INGOT) >= money)then
				-- self:SubMoney(MONEY_TYPE_GOLD_INGOT,MONEY_CHANGE_BAG_EXTENSION,money)					
				-- self:SetExtensionEndTime(os.time() + next_time)
				-- itemMgr:setBagSize(bag_id,bag_pos)
			-- end
		-- elseif(self:GetExtensionEndTime() <= os.time())then	--自动开启
			-- self:SetExtensionEndTime(os.time() + math.floor(config[3] * (bag_size+1 - (config[1]-1)) * (bag_size+1 - config[1])) + config[4])
			-- itemMgr:setBagSize(bag_id,bag_size+1)
		-- end
	-- end
end

--添加物品根据模板来
function PlayerInfo:AddItemByEntry(entry, count, money_log, item_log, item_bind, isAppaisal, isSystem, strong_lv, fail_time, bag_type, pos)
	local itemMgr = self:getItemMgr()						
	itemMgr:addItem(entry, count, item_bind, isAppaisal, isSystem, strong_lv, fail_time, bag_type, pos)
	WriteItemLog(self, item_log,entry,count, item_bind)
end

--使用多个物品
function PlayerInfo:useMulItem(costItemTable,multiple)
	local itemMgr = self:getItemMgr()						
	return itemMgr:useMulItem(costItemTable,multiple)
end

--判断是否同时拥有多个物品
function PlayerInfo:hasMulItem(costItemTable,multiple)
	local itemMgr = self:getItemMgr()						
	return itemMgr:hasMulItem(costItemTable,multiple)
end

-- 扣除多个物品 不够用钱换
function PlayerInfo:useMulItemIfCostMoneyEnabled(costItemTable, multiple)
	multiple = multiple or 1
	
	local ret, items, res = self:checkItemEnoughIfCostMoneyEnabled(costItemTable, multiple)
	if not ret then
		return false
	end
	if not self:useMulItem(items) then
		return false
	end
	if not self:costMoneys(MONEY_CHANGE_USE_ITEM, res) then
		return false
	end
	
	return true
end

-- 判断材料不够花元宝能否满足条件
-- 返回
--	true, realCostItemTable, costMoneyTable
-- false, nil, nil
function PlayerInfo:checkItemEnoughIfCostMoneyEnabled(costItemTable, multiple)
	local itemMgr = self:getItemMgr()	
	
	-- 找一种扣除方案
	local ret, costItem, costIngot = itemMgr:costMoneyEnabledSolution(costItemTable, multiple)
	if not ret then
		return false, nil, nil
	end
	
	-- 如果需要扣钱
	local costResouce = {}
	if costIngot > 0 then
		-- 返回实际的扣除资源值
		ret, costResouce = self:checkMoneyEnoughIfUseGoldIngot({{MONEY_TYPE_BIND_GOLD, costIngot}})
		if not ret then
			return false, nil, nil
		end
	end
	
	return true, costItem, costResouce
end


-- 获取GM等级
function PlayerInfo:GetGmNum()
	return self:GetByte(PLAYER_FIELD_BYTES_5, 0)
end

-- 获取禁言时间
function PlayerInfo:GetGagEndTime()
	return self:GetUInt32(PLAYER_EXPAND_INT_GAG_END_TIME)
end

-- 获取是否禁言中
function PlayerInfo:IsGag()
	return self:GetGagEndTime() > os.time()
end
--//有GM命令权限
function PlayerInfo:GetGMLevel()
	return math.fmod(self:GetGmNum(), 10)
end
--//客服GM权限 
function PlayerInfo:GetFalseGM()
	return math.floor(math.fmod(self:GetGmNum(), 100) / 10)
end
--//美女主播权限 2表示不如排行榜
function PlayerInfo:GetGirlGM()
	return math.floor(self:GetGmNum() / 100)
end

-- 移除失效幻化
function PlayerInfo:OnRemoveExpireIllusion()
	local spellMgr = self:getSpellMgr()
	local expiredTable = spellMgr:checkIfIllusionExpired()
	
	-- 移除p对象中和过期幻化有关的数据
	self:PlayerRemoveExpiredIllusion(expiredTable)
end

-- 移除失效神兵
function PlayerInfo:OnRemoveExpireDivine()
	
end

-- 是否自动购买血瓶
function PlayerInfo:isAutoBuyHpItem()
	return self:GetByte(PLAYER_FIELD_HOOK_BYTE1, 2) > 0
end

-- 自动购买血瓶时银两不够是否用元宝
function PlayerInfo:isAutoBuyHpItemUseGold()
	return self:GetByte(PLAYER_FIELD_HOOK_BYTE1, 3) > 0
end

-- 是否 自动使用绑银购买复活丹
function PlayerInfo:isBuyRespawnByBindGold()
	return self:GetByte(PLAYER_FIELD_HOOK_BYTE3, 1) > 0
end

-- 自动购买复活丹时, 绑银不足用元宝
function PlayerInfo:isBuyRespawnByGold()
	return self:GetByte(PLAYER_FIELD_HOOK_BYTE3, 2) > 0
end

-- 是否拒绝接受系统消息
function PlayerInfo:isDeclineSystemMsg()
	return self:GetByte(PLAYER_FIELD_DECLINE_CHANNEL_BYTE0, 0) > 0
end

-- 是否拒绝接受帮派消息
function PlayerInfo:isDeclineFactionMsg()
	return self:GetByte(PLAYER_FIELD_DECLINE_CHANNEL_BYTE0, 1) > 0
end

-- 是否拒绝接受组队消息
function PlayerInfo:isDeclineGroupMsg()
	return self:GetByte(PLAYER_FIELD_DECLINE_CHANNEL_BYTE0, 2) > 0
end

-- 是否拒绝接受世界消息
function PlayerInfo:isDeclineWorldMsg()
	return self:GetByte(PLAYER_FIELD_DECLINE_CHANNEL_BYTE0, 3) > 0
end


-- 获得最后一次参加世界BOSS的id
function PlayerInfo:GetLastJoinID()
	return self:GetUInt32(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_ID)
end

-- 设置最后一次参加世界BOSS的id
function PlayerInfo:SetLastJoinID(id)
	if self:GetLastJoinID() == id then
		return
	end
	self:SetUInt32(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_ID, id)
end

-- 获得最后一次参加世界BOSS的状态
function PlayerInfo:GetLastState()
	return self:GetByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 0)
end

-- 设置最后一次参加世界BOSS的状态
function PlayerInfo:SetLastState(state)
	if self:GetLastState() == state then
		return
	end
	self:SetByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 0, state)
end

-- 获得最后一次参加世界BOSS的分线
function PlayerInfo:GetLastLine()
	return self:GetByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 1)
end

-- 设置最后一次参加世界BOSS的分线
function PlayerInfo:SetLastLine(line)
	if self:GetLastLine() == line then
		return
	end
	self:SetByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 1, line)
end

-- 获得最后一次参加世界BOSS的自身死亡次数
function PlayerInfo:GetLastDeath()
	return self:GetByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 2)
end

-- 增加最后一次参加世界BOSS的自身死亡次数
function PlayerInfo:SetLastDeath(count)
	if self:GetLastDeath() == count then
		return
	end
	self:AddByte(PLAYER_INT_FIELD_WORLD_BOSS_JOIN_STATE, 2, count)
end
--设置角色神兵数量
function PlayerInfo:SetDivineNum(val)
	self:SetUInt32(PLAYER_FIELD_DIVINE_NUM,val)
end
--设置神兵总战力
function PlayerInfo:SetDivineForce(val)
	local old = self:GetUInt32(PLAYER_FIELD_DIVINE_FORCE)
	if old ~= val then
		self:SetUInt32(PLAYER_FIELD_DIVINE_FORCE,val)
	end
end

--设置最好的坐骑信息
function PlayerInfo:SetMountBest(id,lev,start)
	self:SetByte(PLAYER_FIELD_MOUNT_BEST,0,id)
	self:SetByte(PLAYER_FIELD_MOUNT_BEST,1,lev)
	self:SetByte(PLAYER_FIELD_MOUNT_BEST,2,start)
end

--设置坐骑总战力
function PlayerInfo:SetMountForce(val)
	self:SetUInt32(PLAYER_FIELD_MOUNT_FORCE,val)
end

local OFFLINE_MAIL_PATH_FORMAT = __OFFLINE_MAIL_FOLDER__.."/%s.mail"
local OFFLINE_MAIL_INFO = "%u|%u|%u|%s|%s|%s|%s\n"

-- 添加邮件
function AddGiftPacksData(guid, id, gift_type,start_time,end_time,gift_name,gift_desc,item_config,item_from)
	if(guid == "")then
		return
	end
	
	local player = app.objMgr:getObj(guid)
	-- 没有就加离线文件
	if not player then 
		local path = string.format(OFFLINE_MAIL_PATH_FORMAT, guid)
		local fp, err = io.open(path, "a")
		if err then
			outFmtError("save offline mail fail for path = %s", path)
			return
		end
		fp:write(string.format(OFFLINE_MAIL_INFO, gift_type, start_time, end_time, gift_name, gift_desc, item_config, item_from))
		fp:close()
		return 
	end
	
	-- 玩家自己加邮件
	local giftPack = player:getGiftPacksInfo()
	giftPack:AddGiftPacksInfo(gift_type, start_time, end_time, gift_name, gift_desc, item_config, item_from)
end

-- 玩家上线读离线文件
function PlayerInfo:GetOfflineMail()
	local path = string.format(OFFLINE_MAIL_PATH_FORMAT, self:GetGuid())
	local fp, err = io.open(path, "r+")
	if err then
		--outFmtDebug("err for : %s at path %s", err, path)
		return
	end
	
	local giftPack = self:getGiftPacksInfo()
	
	while (true) do
		local content = fp:read("*l")
		if not content or content == "" then
			break
		end
		local values = string.split(content, "|")
		local gift_type, start_time, end_time, gift_name, gift_desc, item_config, item_from
		gift_type = tonumber(values[ 1 ])
		start_time = tonumber(values[ 2 ])
		end_time = tonumber(values[ 3 ])
		gift_name = values[ 4 ]
		gift_desc = values[ 5 ]
		item_config = values[ 6 ]
		item_from = values[ 7 ]
		
		giftPack:AddGiftPacksInfo(gift_type, start_time, end_time, gift_name, gift_desc, item_config, item_from)
	end
	fp:close()
	
	-- 清空文件
	local fp, err = io.open(path, "w+")
	if err then
		--outFmtDebug("clear file err for : %s at path %s", err, path)
		return
	end
	fp:close()
end

-- 等级改变了
function PlayerInfo:OnLevelChanged()
	print("level changed")
	self:factionUpLevel()
	-- 加任务
	local questMgr = self:getQuestMgr()
	questMgr:OnUpdate(QUEST_TARGET_TYPE_PLAYER_LEVEL, {self:GetLevel()})
	questMgr:OnCheckMainQuestActive(self:GetLevel())
end

-- 战力改变了
function PlayerInfo:OnForceChanged()
	print("force changed")
	self:factionUpForce()
	-- 加任务
	local questMgr = self:getQuestMgr()
	questMgr:OnUpdate(QUEST_TARGET_TYPE_PLAYER_FORCE, {self:GetForce()})
end

-- 增加主线任务
function PlayerInfo:AddFirstQuest()
	local questMgr = self:getQuestMgr()
	questMgr:OnAddQuest(INIT_QUEST_ID)
end

-- 获得当前主线任务id
function PlayerInfo:GetMainQuestID()
	return self:GetUInt32(PLAYER_INT_FIELD_MAIN_QUEST_ID)
end

-- 设置当前主线任务id
function PlayerInfo:SetMainQuestID(value)
	self:SetUInt32(PLAYER_INT_FIELD_MAIN_QUEST_ID, value)
end

-- 关闭连接
function PlayerInfo:CloseSession(fd, is_force)
	if is_force == nil then is_force = false end
	is_force = is_force and 1 or 0
	call_opt_cent_destory_conn(fd, is_force)
end
-- 关闭连接
function PlayerInfo:Close(c_type, c_str, is_force)
	if c_str == nil then c_str = "" end
	if is_force == nil then is_force = false end
	if(c_type)then
		self:CallOptResult(OPERTE_TYPE_CLOSE, c_type, c_str)
	end
	self:CloseSession(self:GetSessionId(), is_force)
end

require("appd/appd_context/appd_context_usemoney_opt")
require("appd/appd_context/appd_context_calculAttr")
require("appd/appd_context/appd_context_resetdaily")
require("appd/appd_context/appd_context_scened_dosomething")
require("appd/appd_context/appd_context_other_binlog")
require("appd/appd_context/appd_context_chat")
require("appd/appd_context/appd_context_instance")
require("appd/appd_context/appd_context_equip_part_opt")
require("appd/appd_context/appd_context_spell")
require("appd/appd_context/appd_context_social")
require("appd/appd_context/appd_context_shop")
require("appd/appd_context/appd_context_giftpacks")
require("appd/appd_context/appd_context_achieve_title")

require("appd/appd_context/handler/faction_handler")
require("appd/appd_context/handler/GiftPacksHandler")
require("appd/appd_context/handler/chat_handler")
require("appd/appd_context/handler/equip_part_opt_handler")
require("appd/appd_context/handler/spell_handler")
require("appd/appd_context/handler/instance_handler")
require("appd/appd_context/handler/social_handler")
require("appd/appd_context/handler/shop_handler")
require("appd/appd_context/handler/rank_handler")
require("appd/appd_context/handler/active_handler")
require("appd/appd_context/handler/achieve_title_handler")

require("appd/appd_context/appd_context_hanlder")

return PlayerInfo
