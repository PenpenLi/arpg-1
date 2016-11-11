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
		data = string.join(',', data)
	else
		data = tostring(data) or ''
	end
	self:call_operation_failed(typed, reason, data)
end

--获得玩家所在的场景fd
function PlayerInfo:GetScenedFD()
	return self:GetUInt32(PLAYER_FIELD_FD)
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
end

--pk服玩家登陆做点啥
function PlayerInfo:LoginPk()
 end 

--玩家下线后
function PlayerInfo:Logout ()
	
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
require("appd/appd_context/appd_context_equip_part_opt")

require("appd/appd_context/handler/faction_handler")
require("appd/appd_context/handler/chat_handler")
require("appd/appd_context/handler/equip_part_opt_handler")

require("appd/appd_context/appd_context_hanlder")

return PlayerInfo
