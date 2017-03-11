function PlayerInfo:Hanlde_Limit_Activity_Receive( pkt )
	local limit_acti = self:getLimitActivityInfo()
	if not limit_acti then
		return
	end
	limit_acti:ReceiveFunc(self, pkt.id, pkt.type)
end

--背包扩展
function PlayerInfo:Hanlde_Bag_Extension( pkt )
	
	self:DoBagExtension(pkt.bag_id, pkt.extension_type, pkt.bag_pos)
end

--仓库存钱
function PlayerInfo:Hanlde_Warehouse_Save_Money( pkt )

	local money = pkt.money
	local money_gold = pkt.money_gold
	local money_bills = pkt.money_bills	--绑定元宝

	if self:GetMoney(MONEY_TYPE_SILVER) < money then
		return
	end
	if self:GetMoney(MONEY_TYPE_GOLD_INGOT) < money_gold then
		return
	end
	if self:GetMoney(MONEY_TYPE_BIND_GOLD) < money_bills then
		return
	end
	--仓库可存储上限1亿
	local maxMoney = 100000000
	if(money > maxMoney)then
		money = maxMoney
	end
	if (self:GetMoney(MONEY_TYPE_SILVER_WAREHOUSE) + money) > maxMoney then
		money = maxMoney - self:GetMoney(MONEY_TYPE_SILVER_WAREHOUSE)
	end

	if self:SubMoney(MONEY_TYPE_SILVER,MONEY_CHANGE_WAREHOUSE_HANLD,money) then
		self:AddMoney(MONEY_TYPE_SILVER_WAREHOUSE,MONEY_CHANGE_WAREHOUSE_HANLD,money)
	end
	if self:SubMoney(MONEY_TYPE_GOLD_INGOT,MONEY_CHANGE_WAREHOUSE_HANLD,money_gold) then
		self:AddMoney(MONEY_TYPE_GOLD_WAREHOUSE,MONEY_CHANGE_WAREHOUSE_HANLD,money_gold)
	end
	if self:SubMoney(MONEY_TYPE_BIND_GOLD,MONEY_CHANGE_WAREHOUSE_HANLD,money_bills) then
		self:AddMoney(MONEY_TYPE_BIND_GOLD_WAREHOUSE,MONEY_CHANGE_WAREHOUSE_HANLD,money_bills)
	end
end

--仓库取钱
function PlayerInfo:Hanlde_Warehouse_Take_Money( pkt )
	
	local money = pkt.money
	local money_gold = pkt.money_gold
	local money_bills = pkt.money_bills
	if self:GetFlags(PLAYER_APPD_INT_FIELD_FLAGS_SAFETY_CODE_CHECK) == false then
		return
	end
	if self:GetMoney(MONEY_TYPE_SILVER_WAREHOUSE) < money then
		return
	end
	if self:GetMoney(MONEY_TYPE_GOLD_WAREHOUSE) < money_gold then
		return
	end
	if self:GetMoney(MONEY_TYPE_BIND_GOLD_WAREHOUSE) < money_bills then
		return
	end
	if self:SubMoney(MONEY_TYPE_SILVER_WAREHOUSE,MONEY_CHANGE_WAREHOUSE_HANLD,money) then
		self:AddMoney(MONEY_TYPE_SILVER,MONEY_CHANGE_WAREHOUSE_HANLD,money)
	end
	if self:SubMoney(MONEY_TYPE_GOLD_WAREHOUSE,MONEY_CHANGE_WAREHOUSE_HANLD,money_gold) then
		self:AddMoney(MONEY_TYPE_GOLD_INGOT,MONEY_CHANGE_WAREHOUSE_HANLD,money_gold)
	end
	if self:SubMoney(MONEY_TYPE_BIND_GOLD_WAREHOUSE,MONEY_CHANGE_WAREHOUSE_HANLD,money_bills) then
		self:AddMoney(MONEY_TYPE_BIND_GOLD,MONEY_CHANGE_WAREHOUSE_HANLD,money_bills)
	end
end

--查询玩家
function PlayerInfo:Hanlde_Query_Player_Info( pkt )
	DoQueryPlayerInfo(self, pkt.guid, pkt.flag, pkt.callback_id)
end

--出售商品
function PlayerInfo:Hanlde_Npc_Sell(pkt)
	local npc_id = pkt.npc_id
	local item_guid = pkt.item_guid
	local count = pkt.num
	local itemMgr = self:getItemMgr()
	if(count == 0)then
		outFmtError("Hanlde_Npc_Sell: sell goods count 0")
		return
	end
	
	local item = itemMgr:getItemByGuid(item_guid,BAG_TYPE_MAIN_BAG)
	if(item == nil)then
		return self:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_ITEM_NOT_EXIST)
	end

	if(item:getCount() < count)then
		return
	end	
	--直接删除物品
	itemMgr:delItemObj(item,count)

	--[[ 注释掉回购操作
	if not self.repurchase_pos then self.repurchase_pos = 0 end
	local repurchase_size = itemMgr:getBagSize(BAG_TYPE_REPURCHASE)
	if self.repurchase_pos >= 20 then
		self.repurchase_pos = 0
	end
	--如果回购包裹满了，则删除第一个位置的物品
	if(itemMgr:getEmptyPos(BAG_TYPE_REPURCHASE) == -1)then
		itemMgr:delItemByPos(BAG_TYPE_REPURCHASE,self.repurchase_pos)
		self.repurchase_pos = self.repurchase_pos + 1
	end
	-- outFmtError('npc_sell: item_guid:%s bagpos:%d item_count:%d count:%d', item_guid, itemMgr:getItemBagPosByGuid(BAG_TYPE_MAIN_BAG, item_guid),  item:getCount(), count, self.repurchase_pos)
	--//处理回购包裹
	if(item:getCount() > count)then
		local src_bag = BAG_TYPE_MAIN_BAG
		local src_pos = itemMgr:getItemBagPosByGuid(BAG_TYPE_MAIN_BAG,item_guid)
		local dst_bag = BAG_TYPE_REPURCHASE
		local dst_pos = itemMgr:getEmptyPos(BAG_TYPE_REPURCHASE)
		itemMgr:splitItem(src_bag,src_pos,dst_bag,dst_pos,count)		
	elseif(item:getCount() == count)then
		local src_bag = BAG_TYPE_MAIN_BAG
		local src_pos = itemMgr:getItemBagPosByGuid(BAG_TYPE_MAIN_BAG,item_guid)
		local dst_bag = BAG_TYPE_REPURCHASE
		local dst_pos = itemMgr:getEmptyPos(BAG_TYPE_REPURCHASE)
		itemMgr:exchangePos(src_bag,src_pos,dst_bag,dst_pos)
	end
	]]

	--处理金钱 FIXME 处理金钱的操作需要处理
	--[[
	self:AddMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_NPC_SELL, tb_item_template[item:getEntry()].price*count, "",
		item:getEntry(), count, item:isBind() and ITEM_BIND_GET or ITEM_BIND_NONE ,item:getFailTime() > 0 and 1 or 0)	
	]]
end

--回购物品
function PlayerInfo:Hanlde_Npc_Rrpurchase(pkt)
	local tokens = lua_string_split(pkt.item_id,",")
	local itemMgr = self:getItemMgr()
	for i = 1,#tokens do
		local item_guid = tokens[i]
		local item = itemMgr:getItemByGuid(item_guid,BAG_TYPE_REPURCHASE)
		if(item)then
			local entry = item:getEntry()
			local count = item:getCount()
			local isbind = item:isBind()
			local failtime = item:getFailTime()
			local price = tb_item_template[entry].price * item:getCount()	--//2013.10.09策划需求，原价回购
			if(itemMgr:canHold(BAG_TYPE_MAIN_BAG,entry,count,isbind,failtime) == false)then
				return self:CallOptResult(OPRATE_TYPE_BAG, BAG_RESULT_BAG_FULL)
			end
			--//回购的价格
			if(self:SubMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_NPC_REPURCHASE, price,"",entry,count,isbind and ITEM_BIND_GET or ITEM_BIND_NONE ,failtime > 0 and 1 or 0))then
				local src_bag = BAG_TYPE_REPURCHASE
				local src_pos = itemMgr:getItemBagPosByGuid(BAG_TYPE_REPURCHASE,item_guid)
				local dst_bag = BAG_TYPE_MAIN_BAG
				local dst_pos = itemMgr:getEmptyPos(BAG_TYPE_MAIN_BAG)
				itemMgr:exchangePos(src_bag,src_pos,dst_bag,dst_pos)
			end 
		end
	end
	--//整理回购包裹
	--GetBags()->GetBag(BAG_TYPE_REPURCHASE)->Compaction();
end


--发公告
function PlayerInfo:Handle_Chat_Notice( pkt )
	app:SendNotice(pkt.id, pkt.content, pkt.data)
end

-- 强化
function PlayerInfo:Handle_Strength(pkt)
	self:strength(pkt.part)
end

-- 使用物品
function PlayerInfo:Hanlde_Bag_Item_User(pkt)
	UseItem(self, pkt.item_guid, pkt.count)
end

function PlayerInfo:Handle_Use_Virtual_Item(pkt)
	local entry = pkt.entry
	if not tb_item_template[entry] or tb_item_template[entry].out_bag ~= 1 then
		return
	end
	
	local questMgr = self:getQuestMgr()
	questMgr:OnUpdate(QUEST_TARGET_TYPE_USE_ITEM, {entry})
end

--交换物品 （穿装备）
function PlayerInfo:Hanlde_Bag_Exchange_Pos(pkt)
	local src_bag = pkt.src_bag
	local src_pos = pkt.src_pos
	local dst_bag = pkt.dst_bag
	local dst_pos = pkt.dst_pos
	local itemMgr = self:getItemMgr()
	itemMgr:exchangePos(src_bag,src_pos,dst_bag,dst_pos)
end

-- 进行挂机
function PlayerInfo:Handle_Hang_Up(pkt)
	local prev = self:GetUInt32(PLAYER_FIELD_HOOK)
	self:SetUInt32(PLAYER_FIELD_HOOK, 1 - prev)
end

-- 挂机设置
-- 不进行任何验证(自己作弊怪谁呀)
function PlayerInfo:Handle_Hang_Up_Setting(pkt)
	self:SetUInt32(PLAYER_FIELD_HOOK_BYTE0, pkt.value0)
	self:SetUInt32(PLAYER_FIELD_HOOK_BYTE1, pkt.value1)
	self:SetUInt32(PLAYER_FIELD_HOOK_SHORT, pkt.value2)
	self:SetUInt32(PLAYER_FIELD_HOOK_BYTE3, pkt.value3)
end


--函数包路由表
local OpcodeHandlerFuncTable = require 'appd.appd_context.appd_context_hanlder_map'

local protocols = require('share.protocols')
--网络包处理方法
packet.register_on_external_packet(function ( player_ptr, pkt )
	local _player = app.objMgr:fromPtr(player_ptr)
	local optcode = packet.optcode(pkt)
	local succeed, args = protocols.unpack_packet(optcode, pkt)
	
	--解包失败记一下日志
	if not succeed then
		logLib.WriteAttackPacker(self:GetGuid(), optcode, ACCACK_PACKET_TYPE_UNPACK, '')
	else
		args.__optcode = optcode		
		if OpcodeHandlerFuncTable[optcode] then
			doxpcall(OpcodeHandlerFuncTable[optcode], _player, args)
		end
	end
end)