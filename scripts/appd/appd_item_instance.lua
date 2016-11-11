local AppItemInstance = {
	--商品列表
	good_type_listcache = {}
}

--鉴定物品
function AppItemInstance:itemAppaisal(item)
	local entry = item:getEntry()
	local item_tempate = tb_item_template[entry]
	if not item_tempate then return end
	
	local attr_config = item_tempate.basic_properties

	if item_tempate.type == ITEM_TYPE_EQUIP then
		--生成基础属性
		self:createBaseAtrr(item, item_tempate.type, attr_config)

		--重算下战斗力
		self:resetItemForce(item)
	end
	
	
	--标志为已鉴定
	if not item:isAppaisal() then item:setApparisal() end
end


--获得物品属性 ps：这里只获得pk属性相关的，不包括特殊属性
function AppItemInstance:getItemCalculAttr( item )
	local attrs = {}

	for i = 1, MAX_EQUIP_ATTR - 1 do
		attrs[i] = item.item:GetAttr(GetAttrKey({[1] = i})[1])
	end
	--汇总属性前先把固定属性加到基础属性
	for i = EQUIP_ATTR_HP, EQUIP_ATTR_CRIT_DEF do		
		attrs[i] = attrs[i] + attrs[ i + MAX_BASE_ATTR ]
	end	
	return attrs
	
end

--物品属性重算
function AppItemInstance:itemCalculAttr( )
	local attrs = {}					--汇总所有属性
	for i = EQUIP_ATTR_HP, EQUIP_ATTR_CRIT_DEF do
		attrs[i] = 0
	end
	
	--遍历装备包裹
	local func = function( ptr )
		local item = require("appd.appd_item").new(ptr)	
		local temp_attrs = self:getItemCalculAttr(item)
		self:resetItemForce(item)					
		--汇总到总属性
		for j = EQUIP_ATTR_HP, EQUIP_ATTR_CRIT_DEF do
			attrs[j] = attrs[j] + temp_attrs[j]
		end		
	end
	self.itemMgr:ForEachBagItem(BAG_TYPE_EQUIP, func)
	
	return attrs
end

--套装属性重算
function AppItemInstance:suitCalculAttr( base_attr )
	local attrs = {}					--汇总属性
	local suit_attrs = {}				--套装属性
	local other = {}					--其他属性（特殊属性之类的 MAX_EEQUIP_OTHER ）
	for i = 1, MAX_EQUIP_ATTR - 1, 1 do
		attrs[i] = 0
	end
	for i = 1, MAX_EEQUIP_OTHER - 1, 1 do
		other[i] = 0
	end
	
	local suit_id_config = {}				--记录已经处理过的套装id {[id] = 1,}
	--遍历装备包裹
	local func = function( ptr )
		local item = require("appd.appd_item").new(ptr)
		local entry = item:getEntry()
		local item_config = tb_item_template[entry]
		for _, id in ipairs(item_config.suit_id) do
			if id ~= 0 and not suit_id_config[id] then
				suit_id_config[id] = 1		--标记为已处理
				--先清空
				for j = 1, MAX_EQUIP_ATTR - 1 do
					suit_attrs[j] = 0				
				end					
				local flag = true
				--取出套装配置
				local config = tb_suit[id]
				for _, entry in ipairs(config.ingredient) do
					local items = self:getItemByEntry(BAG_TYPE_EQUIP, entry)
					if #items == 0 then
						flag = false
						break
					end
				end
				if flag then
					--给套装属性
					local attr_config = config.pro
					for j = 1, #attr_config, 2 do
						--属性值
						suit_attrs[ attr_config[j] ] = suit_attrs[ attr_config[j] ] + attr_config[j+1]				
					end
					
					--汇总到总属性
					for j = 1, MAX_EQUIP_ATTR - 1 do
						attrs[j] = attrs[j] + suit_attrs[j]
					end
				end					
			end
		
		end	
	end
	self.itemMgr:ForEachBagItem(BAG_TYPE_EQUIP, func)
	
	return attrs, other
end

--生成物品基础属性
function AppItemInstance:createBaseAtrr(item, typed, attr_config)
	self:clearBaseAtrr(item)	--清除老的基础属性
	local length = #attr_config
	if length < 1 then return end
	--[[
	if typed == 1 then
		--装备,必须有2条属性以上
		if length < 2 then return end
	end
	]]
	for i = 1,#attr_config do
		--outFmtDebug("att config %s,%s",attr_config[i][1],attr_config[i][2])
		item:setAttr(attr_config[i][1], attr_config[i][2])
	end
end

--清空物品基础属性
function AppItemInstance:clearBaseAtrr(item)
	item:clearAttr()				--清空所有非特殊属性对	
end

--重算物品战斗力
function AppItemInstance:resetItemForce(item)
	--[[
	local temp_attrs = self:getItemCalculAttr(item)
	--强加加成
	local streng_lv = item:getStrongLv()
	if streng_lv > 0 then
		for i = EQUIP_ATTR_HP,EQUIP_ATTR_CRIT_DEF
		do
			temp_attrs[i] = temp_attrs[i] + math.floor(item:getAttr(i) * tb_equip_intensify[streng_lv].prop_rate /10000)
		end
	end
	local force = DOCalculForce( temp_attrs )		--计算战斗力
	local cur_force = item:getAttr(ITEM_OTHER_ATTR_FORCE)
	if cur_force == 0 or cur_force ~= force then
		item:setAttr(ITEM_OTHER_ATTR_FORCE, force)		--更新物品战斗力		
	end	
	self.itemMgr:SavePtr(item.item)
	]]
end

--查找商品列表
function AppItemInstance:findGoodsList(type_id)
	if(self.good_type_listcache[type_id] == nil)then
		self.good_type_listcache[type_id] = {}
		for _,good in pairs(tb_goods)do
			if(type_id == good.type)then
				table.insert(self.good_type_listcache[type_id],good.id)
				
			end
		end
	end
	return self.good_type_listcache[type_id]
end

--删掉所有失效物品
function AppItemInstance:delFailTimeItem()
	local timenow = os.time()
	for bag_type = 0, MAX_BAG-1 do
		local bag_size = self:getBagSize(bag_type)
		for i = 1, bag_size do
			local item = self:getBagItemByPos(bag_type, i-1)
			if item and ( (item:getFailTime() ~= 0 and item:getFailTime() <= timenow) or item:getCount() == 0 ) then
				WriteItemLog(self:getOwner(), LOG_ITEM_OPER_TYPE_DEL_FAILTIME, item:getEntry(), item:getCount(), item:isBind())
				self:delItemObj(item)
			end
		end
	end
end

--扩展该方法
function AppItemInstance.extend(self)
	for k,v in pairs(AppItemInstance) do self[k] = v end
end

return AppItemInstance