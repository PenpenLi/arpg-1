require("appd.appd_internal_pack")
local Packet = require 'util.packet'

--场景服发送使用物品结果
local function on_scened_use_item_result( pkt )
	local ret, player_guid, item_entry, result, count = unpack_user_item_result(pkt)
	if not ret then
		return
	end
	
	ScenedUseItemResult(player_guid, item_entry, count, result)
end

--场景服玩家拾取战利品
local function on_scened_loot_select( pkt )
	local ret, player_guid, item_entry, bind, count, failtime = unpack_loot_select(pkt)
	if not ret then
		return
	end
	--模板里没有的道具
	if not tb_item_template[item_entry] then 
		outFmtDebug("loot_select: player %s not find %d in template!", player_guid, item_entry)
		return 
	end	
	
	local player = app.objMgr:getObj(player_guid)
	if not player then
		outFmtDebug("loot_select:player %s not online item_entry %d count %d", player_guid, item_entry, count)
		return
	end
	local bind = tb_item_template[itemId].bind_type
	player:AddItemByEntry(item_entry, count, nil, LOG_ITEM_OPER_TYPE_LOOT, bind, true, true, 0, failtime)
end

--场景服做任务给物品
local function on_scened_quest_add_item( pkt )
	local ret, player_guid, item_entry, count, bind, stronglv, failtime, logtype = unpack_quest_add_item(pkt)
	if not ret then
		return
	end
	
	local player = app.objMgr:getObj(player_guid)
	if not player then
		outFmtDebug("quest_add_item:player %s not online item_entry %d count %d", player_guid, item_entry, count)
		return
	end
	player:PlayerAddItems({{item_entry, count}}, nil, logtype)
	--player:AddItemByEntry(item_entry, count, nil, logtype, bind, true, true, stronglv, failtime)
end

local function on_scened_add_items(pkt)
	local ret, player_guid, itemDict, logtype = unpack_add_items(pkt)
	if not ret then
		return
	end
	
	local player = app.objMgr:getObj(player_guid)
	if not player then
		outFmtDebug("on_scened_quest_add_item:player %s not online", player_guid)
		return
	end
	player:PlayerAddItems(itemDict, nil, logtype)
end

--场景服通知应用服玩家升级了
local function on_scened_player_upgrade( pkt )
	local ret, player_guid, prevLevel, player_lv = unpack_player_upgrade(pkt)
	if not ret then
		return
	end
	
	local player = app.objMgr:getObj(player_guid)
	if not player then
		outFmtDebug("on_scened_player_upgrade:player %s not online player_lv %d", player_guid, player_lv)
		return
	end
	
	-- 处理升级以后的逻辑
	local gender = player:GetGender()
	local config = tb_char_skill[gender]
	for _, info in pairs(config.unlocks) do
		if prevLevel < info[ 1 ] and info[ 1 ] <= player_lv then
			player:activeBaseSpell(info[ 2 ], SPELL_ACTIVE_BY_LEVEL)
		end
	end
	
	-- FIXME:解锁坐骑 先在这里处理
	if prevLevel < 8 and 8 <= player_lv then
		player:activeMount()
	end
	
	-- 到C++中改变等级列表
	playerLevelChanged(player_guid, prevLevel, player_lv)
	
	-- 等级解锁任务
	for level = prevLevel + 1, player_lv do
		player:AddLevelActiveQuest(level)
	end
	--[[
	-- 如技能解锁
	local socialSysInfo = player:getSocialSystem()
	if socialSysInfo then
		socialSysInfo:ProceedUpgrade(player, FRIEND_OPT_PLAYER_UPGRADE, player_lv)
	end
	]]
end

local function on_scened_add_gift_packs( pkt )
	local ret, player_guid, id, gift_type, start_time, end_time, gift_name, gift_desc, item_config, item_from = unpack_add_gift_packs(pkt)
	if not ret then
		return
	end
	
	AddGiftPacksData(player_guid,id,gift_type,start_time,end_time,gift_name,gift_desc,item_config,item_from)
end

local function on_scened_add_number_material( pkt )
	local ret, player_guid, ntype, value = unpack_add_number_material(pkt)
	if not ret then
		return
	end
	
	local player = app.objMgr:getObj(player_guid)
	if not player then
		outFmtDebug("on_scened_add_number_material:player %s not online type %d value %d", player_guid, ntype, value)
		return
	end
	player:AddNumberMaterial( ntype, value)
end

local function on_player_killed( pkt )
	local guid, kill_id, silver = unpack_player_killed(pkt)
	if not ret then return end
	if guid == kill_id then
		return
	end
	local player = app.objMgr:getObj(guid)
	if not player then 
		outFmtDebug("AppdApp::on_player_killed: player = null, %s", guid)
		return 
	end
	local killer = app.objMgr:getObj(kill_id)
	if not killer then 
		outFmtDebug("AppdApp::on_player_killed: killer = null, %s", kill_id)
		return 
	end
	player:DoKillPlayer(killer)
end

--发送给应用服应该做些什么事
local function on_scened_send_to_appd_do_something( pkt )
	local ret, guid, type, data, str = unpack_send_to_appd_do_something(pkt)
	if not ret then return end
	local player = app.objMgr:getObj(guid)
	if not player then 
		outFmtDebug("AppdApp::on_scened_send_to_appd_do_something: player = null, %s", guid)
		return 
	end
	player:DoGetScenedDoSomething(type,data,str)
end

--场景服发给应用服发公告
local function on_scened_send_ontice( pkt )
	local ret, id, content, data = unpack_scened_send_notice(pkt)
	if not ret then return end	
	app:SendNotice(id, content, data)
end

--场景服发送聊天信息
local function on_scened_send_char_info( pkt )
	local ret, c_type, guid, content, to_guid, to_name = unpack_scened_send_char_info(pkt)
	if not ret then return end
	local player = app.objMgr:getObj(guid)
	if not player then 
		outFmtDebug("AppdApp::on_scened_send_char_info: player = null, %s", guid)
		return 
	end
	player:SendChat(c_type, content, to_guid, to_name)
end


local appdInsternalHanlders = {}
appdInsternalHanlders[INTERNAL_OPT_USER_ITEM_RESULT] = on_scened_use_item_result
appdInsternalHanlders[INTERNAL_OPT_LOOT_SELECT] = on_scened_loot_select
appdInsternalHanlders[INTERNAL_OPT_QUEST_ADD_REW_ITEM] = on_scened_quest_add_item
appdInsternalHanlders[INTERNAL_OPT_ADD_ITEMS] = on_scened_add_items

appdInsternalHanlders[INTERNAL_OPT_UPGRADE_LEVEL] = on_scened_player_upgrade
appdInsternalHanlders[INTERNAL_OPT_ADD_GIFT_PACKS] = on_scened_add_gift_packs
appdInsternalHanlders[INTERNAL_OPT_APPD_ADD_NUMBER_MATERIAL] = on_scened_add_number_material
appdInsternalHanlders[INTERNAL_OPT_USER_KILLED] = on_player_killed
appdInsternalHanlders[INTERNAL_OPT_SEND_TO_APPD_DO_SOMETHING] = on_scened_send_to_appd_do_something
appdInsternalHanlders[INTERNAL_OPT_NOTICE] = on_scened_send_ontice
appdInsternalHanlders[INTERNAL_OPT_CHAT] = on_scened_send_char_info

--网络包处理方法
packet.register_on_internal_packet(function ( cid, pkt )
	local optcode = packet.optcode(pkt)
	local f = appdInsternalHanlders[optcode]
	if f then
		f(Packet.new(nil, pkt))
--		pkt:delete()
	else
		--print(cid)
	end
end)
