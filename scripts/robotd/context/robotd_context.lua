--玩家封装
PlayerInfo = class('PlayerInfo', BinLogObject)

--将所有的发包及解包功能附加到该类
require('share.protocols'):extend(PlayerInfo)

--构造函数
function PlayerInfo:ctor(account, fd, robot_ptr)
	self.objMgr = require('robotd.robotd_object_manager').new(self)	
	self.account = account
	self.fd = fd
	self.ptr = robot_ptr
	self.unit_nil_time = 0
	self.generalWarFailsTimes = 0
	self.generalWarTime = 0
	self.isWipeOut = false
	self:UnitMgrInit()
	self:ItemMgrInit()
	self:ActionInit()
	
	self.questStart = false
end

-- 重置些事情
function PlayerInfo:Reset()
	self.questStart = false
end

--打印调试信息
function PlayerInfo:GetDebugInfo()
	local x,y = self:GetPos()
	local unit_guid = ""
	local instance_id = 0
	if(self.my_unit)then
		unit_guid = self.my_unit:GetGuid()
		instance_id = self.my_unit:GetInstanceID()
	end
	local result = string.format("player guid : %s %s,  mapid %u, pos %u,%u, Instance %u, level %u \n", self:GetGuid(), unit_guid, self:GetMapID(), x, y, instance_id, self:GetLevel())

	return result..self:GetActionDebugInfo()
end

--登出
function PlayerInfo:Logout()
	self.objMgr:Logout()
end

--关闭游戏服连接
function PlayerInfo:Close()
	closeContext(self.ptr)
end

--心跳
function PlayerInfo:Update(diff)
	--乱发包
	--self:call_rand_packet()
	
	--没登录成功就没必要有下面的事了
	if(not playerLib.isLoginOk(self.ptr))then
		return
	end

	if(self.my_unit)then
		self:ActionUpdate(diff)
	else
		--要精灵数据超时，也许是同步问题导致的，到内存里再找一下。
		self.unit_nil_time = self.unit_nil_time + diff
		if(self.unit_nil_time > 30000)then
			self:FindMyUnit()
			if(self.my_unit == nil)then
				outFmtInfo('PlayerInfo:Update %s FindMyUnit is nil', self:GetGuid())
				self.unit_nil_time = 0
				self:Close()
			end
		end
	end
end

--机器人连接跨服成功
function PlayerInfo:RobotWarConn()
	self:ActionWarConn()
end

--机器人断开跨服连接
function PlayerInfo:RobotWarClose()
	self:ActionWarClose()
end

--获取地图ID
function PlayerInfo:GetMapID()
	if(self.my_unit == nil)then
		return 0
	end
	return self.my_unit:GetMapID()
end

--获取坐标
function PlayerInfo:GetPos()
	if(self.my_unit == nil)then
		return 0,0
	end
	return self.my_unit:GetPos()
end

--设置坐标
function PlayerInfo:SetPos(x, y)
	if(self.my_unit == nil)then
		return
	end
	return self.my_unit:SetPos(x, y)
end

--获取玩家名字
function PlayerInfo:GetName()
	return self:GetStr(BINLOG_STRING_FIELD_NAME)
end

--获取杀怪数
function PlayerInfo:GetKillMonster()
	return self:GetUInt32(PLAYER_FIELD_KILL_MONSTER)
end

--获取货币
function PlayerInfo:GetMoney(type)
	return self:GetDouble(PLAYER_FIELD_MONEY + type * 2)
end

--获取元宝
function PlayerInfo:GetGold()
	return self:GetMoney(MONEY_TYPE_GOLD)
end

--获取绑定元宝
function PlayerInfo:GetBindGold()
	return self:GetMoney(MONEY_TYPE_BIND_GOLD)
end
--获取银两
function PlayerInfo:GetSilver()
	return self:GetMoney(MONEY_TYPE_SILVER)
end

--获取仓库的银子
function PlayerInfo:GetSilverWareHouse()
	return self:GetMoney(MONEY_TYPE_SILVER_WAREHOUSE)
end

--获取某玩家标志位
function PlayerInfo:GetFlags(off)
	return self:GetBit(PLAYER_FIELD_FLAGS_BEGIN + math.floor(off / 32), math.fmod(off, 32));
end

--获得坐骑entry
function PlayerInfo:GetMountEntry()
	return self:GetUInt32(PLAYER_FIELD_MOUNT_ENTRY)
end

--获取gm命令权限等级
function PlayerInfo:GetGMLevel()
	return self:GetByte(PLAYER_FIELD_BYTES_2, 0) % 10
end

--获取等级
function PlayerInfo:GetLevel()
	return self:GetUInt32(PLAYER_FIELD_LEVEL)
end

--获取等级
function PlayerInfo:GetZhuanShengLevel()
	return self:GetUInt32(PLAYER_FIELD_ZHUANSHENG_LEVEL)
end

--发送gm命令
function PlayerInfo:SendGmCommand(comm)
	--outFmtDebug("PlayerInfo:SendGmCommand gmlv:%s %s ===================== ",self:GetGMLevel(),comm)
	--if(self:GetGMLevel() == 0)then
		--没有权限就不用发了
		--assert(false)
	--	return false
	--end
	
	self:call_chat_by_channel(CHAT_TYPE_WORLD, comm)
end

function PlayerInfo:GetKuafuJoin()
	return self:GetFlags(PLAYER_FLAG_KUAFU_JOIN)
end

-- []
function PlayerInfo:RandomInt(limit)
	limit = limit or 100
	if limit < 1 then
		limit = 100
	end
	local randDict = {-100000000, -1, 0, limit, limit+1, 100000000}
	local type = randInt(1, #randDict)
	local ret = randDict[type]
	if ret == limit then
		ret = randInt(1, limit)
	end
	
	return ret
end

function PlayerInfo:RandomString(str)
	local indx = randInt(1, 2)
	if indx == 2 then
		str = ""
	end
	return str
end

-- 获得玩家的技能信息
function PlayerInfo:GetSkillInfo()
	local skillIdInfo = {{}}
	local skillLevelInfo = {}
	
	for i = PLAYER_INT_FIELD_SPELL_START, PLAYER_INT_FIELD_SPELL_END-1 do
		local id = self:GetUInt16(i, 0)
		local lv = self:GetByte(i, 2)
		local st = self:GetByte(i, 3)
		if st == 1 then
			table.insert(skillIdInfo[st], id)
		else
			skillIdInfo[st] = id
		end
		skillLevelInfo[st] = lv
	end
	
	return skillIdInfo, skillLevelInfo
end

-- 释放技能
function PlayerInfo:CastSpell(skillId, x, y, caster, target)
	self:call_spell_start (skillId, x, y, caster, target)
end

--停止移动状态
function PlayerInfo:stopMoving(x,y)
	self:call_unit_move (self.my_unit:GetUIntGuid(), x, y, {x, y})
	return self.my_unit:stopMoving(x,y)
end

-- 创建帮派
function PlayerInfo:Send_Create_Faction()
	local name = self:RandomString(self:GetGuid())
	local icon = self:RandomInt(102)
	self:call_create_faction (name ,icon)
end

-- 升级帮派
function PlayerInfo:Send_Faction_Upgrade()
	self:call_faction_upgrade ()
end

-- 加入帮派
function PlayerInfo:Send_Faction_Join()
	local id = self:RandomString(self:GetGuid())
	self:call_faction_join (id)
end

--升级基础技能
function PlayerInfo:Send_Raise_Base_Spell()
	local raiseType = self:RandomInt(10)
	local spellId = self:RandomInt(10000)
	self:call_raise_base_spell(raiseType, spellId)
end

--升级怒气技能
function PlayerInfo:Send_Upgrade_Anger_Spell()
	local spellId = self:RandomInt(10000)
	self:call_upgrade_anger_spell(spellId)
end

--升级坐骑
function PlayerInfo:Send_Raise_Mount()
	self:call_raise_mount()
end

--升星坐骑
function PlayerInfo:Send_Upgrade_Mount()
	local val = randInt(0, 1)
	local useItem = val
	self:call_upgrade_mount(useItem)
end

--一键升星坐骑
function PlayerInfo:Send_Upgrade_Mount_One_Step()
	local val = randInt(0, 1)
	local useItem = val
	self:call_upgrade_mount_one_step(useItem)
end

--
function PlayerInfo:Send_Illusion_Mount_Active()
	local illuId = self:RandomInt(#tb_mount_illusion)
	self:call_illusion_mount_active(illuId)
end

--
function PlayerInfo:Send_Illusion_Mount()
	local illuId = self:RandomInt(#tb_mount_illusion)
	self:call_illusion_mount(illuId)
end

--
function PlayerInfo:Send_Gem()
	local part = self:RandomInt(10)
	self:call_gem(part)
end

--
function PlayerInfo:Send_Divine_Active()
	local id = self:RandomInt(#tb_divine_base)
	self:call_divine_active(id)
end

--
function PlayerInfo:Send_Divine_Uplev()
	local id = self:RandomInt(#tb_divine_base)
	self:call_divine_uplev(id)
end

--
function PlayerInfo:Send_Divine_Switch()
	local id = self:RandomInt(#tb_divine_base)
	self:call_divine_switch(id)
end

--
function PlayerInfo:Send_Sweep_Vip_Instance()
	local id = self:RandomInt(#tb_map_vip)
	self:call_sweep_vip_instance(id)
end

--
function PlayerInfo:Send_Hang_Up()
	self:call_hang_up()
end

--
function PlayerInfo:Send_Hang_Up_Setting()
	self:call_hang_up_setting(0, 0, 0, 0)
end

--
function PlayerInfo:Send_Sweep_Trial_Instance()
	self:call_sweep_trial_instance()
end

--
function PlayerInfo:Send_Reset_Trial_Instance()
	self:call_reset_trial_instance()
end

--
function PlayerInfo:Send_Social_Add_Friend()
	self:call_social_add_friend('')
end

--
function PlayerInfo:Send_Social_Sureadd_Friend()
	self:call_social_sureadd_friend('')
end

--
function PlayerInfo:Send_Social_Gift_Friend()
	self:call_social_gift_friend('', '')
end

--
function PlayerInfo:Send_Social_Recommend_Friend()
	self:call_social_recommend_friend()
end

--
function PlayerInfo:Send_Social_Revenge_Enemy()
	self:call_social_revenge_enemy('')
end

--
function PlayerInfo:Send_Social_Del_Friend()
	self:call_social_del_friend('')
end

--
function PlayerInfo:Send_Social_Clear_Apply()
	self:call_social_clear_apply()
end

--
function PlayerInfo:Send_Social_Add_Friend_Byname()
	self:call_social_add_friend_byname('')
end

--
function PlayerInfo:Send_Chat_By_Channel()
	local channel = self:RandomInt(10)
	self:call_chat_by_channel(channel, 'aaaaaaa')
end

--
function PlayerInfo:Send_Msg_Decline()
	self:call_msg_decline(0, 0)
end

--
function PlayerInfo:Send_Block_Chat()
	self:call_block_chat('')
end

--
function PlayerInfo:Send_Faction_Getlist()
	local page = self:RandomInt(10)
	local num = self:RandomInt(10)
	local grep = self:RandomInt(10)
	self:call_faction_getlist(page, num, grep)
end

--
function PlayerInfo:Send_Faction_Manager()
	local opt_type = self:RandomInt(10)
	local r1 = self:RandomInt(10)
	local r2 = self:RandomInt(10)
	local r3 = ''
	local r4 = ''
	
	self:call_faction_manager(opt_type, r1, r2, r3, r4)
end

--
function PlayerInfo:Send_Faction_Member_Operate()
	local opt_type = self:RandomInt(10)
	local r1 = self:RandomInt(10)
	local r2 = self:RandomInt(10)
	local r3 = ''
	local r4 = ''
	self:call_faction_member_operate(opt_type, r1, r2, r3, r4)
end

--
function PlayerInfo:Send_Faction_Fast_Join()
	self:call_faction_fast_join()
end

--
function PlayerInfo:Send_Read_Mail()
	local indx = self:RandomInt(100)
	self:call_read_mail(indx)
end

--
function PlayerInfo:Send_Pick_Mail()
	local indx = self:RandomInt(100)
	self:call_pick_mail(indx)
end

--
function PlayerInfo:Send_Remove_Mail()
	local indx = self:RandomInt(100)
	self:call_remove_mail(indx)
end

--
function PlayerInfo:Send_Pick_Mail_One_Step()
	self:call_pick_mail_one_step()
end

--
function PlayerInfo:Send_Remove_Mail_One_Step()
	self:call_remove_mail_one_step()
end

--
function PlayerInfo:Send_Cancel_Block_Chat()
	local indx = self:RandomInt(10)
	self:call_cancel_block_chat(indx)
end

--
function PlayerInfo:Send_World_Boss_Enroll()
	self:call_world_boss_enroll()
end

--
function PlayerInfo:Send_Rank_Add_Like()
	local type = self:RandomInt(MAX_RANK_TYPE)
	local guid = self:RandomString(self:GetGuid())
	local num  = self:RandomInt(1)
	self:call_rank_add_like(type, guid, num)
end

--
function PlayerInfo:Send_Res_Instance_Sweep()
	local id = self:RandomInt(#tb_instance_res)
	self:call_res_instance_sweep(id)
end

--
function PlayerInfo:Send_Get_Activity_Reward()
	local id  = self:RandomInt(#tb_activity_base)
	local vip = self:RandomInt(10)
	self:call_get_activity_reward(id, vip)
end

--
function PlayerInfo:Send_Get_Achieve_Reward()
	local id  = self:RandomInt(#tb_achieve_base)
	self:call_get_achieve_reward(id)
end

--
function PlayerInfo:Send_Get_Achieve_All_Reward()
	self:call_get_achieve_all_reward()
end

--
function PlayerInfo:Send_Set_Title()
	local id = self:RandomInt(#tb_title_base)
	self:call_set_title(id)
end

--
function PlayerInfo:Send_Init_Title()
	local id = self:RandomInt(#tb_title_base)
	self:call_init_title(id)
end

--
function PlayerInfo:Send_Welfare_Shouchong_Reward()
	self:call_welfare_shouchong_reward()
end

--
function PlayerInfo:Send_Welfare_Checkin()
	self:call_welfare_checkin()
end

--
function PlayerInfo:Send_Welfare_Checkin_All()
	local id = self:RandomInt(#tb_welfare_checkin_all)
	self:call_welfare_checkin_all(id)
end

--
function PlayerInfo:Send_Welfare_Checkin_Getback()
	local id = self:RandomInt(#tb_welfare_back)
	self:call_welfare_checkin_getback(id)
end

--
function PlayerInfo:Send_Welfare_Level()
	local id = self:RandomInt(#tb_welfare_level)
	self:call_welfare_level(id)
end

--
function PlayerInfo:Send_Welfare_Active_Getback()
	local id = self:RandomInt(100)
	local best = self:RandomInt(1)
	local num = self:RandomInt(100)
	self:call_welfare_active_getback(id, best, num)
end

--
function PlayerInfo:Send_Welfare_Getalllist_Getback()
	local best = self:RandomInt(1)
	self:call_welfare_getalllist_getback(best)
end

--
function PlayerInfo:Send_Welfare_Getall_Getback()
	local best = self:RandomInt(1)
	self:call_welfare_getall_getback(best)
end

--
function PlayerInfo:Send_Pick_Quest_Reward()
	local indx = self:RandomInt(50)
	self:call_pick_quest_reward(indx)
end

--
function PlayerInfo:Send_Use_Virtual_Item()
	local entry = self:RandomInt(50000)
	self:call_use_virtual_item(entry)
end

--
function PlayerInfo:Send_Pick_Quest_Chapter_Reward()
	local indx = self:RandomInt(50)
	self:call_pick_quest_chapter_reward(indx)
end

--
function PlayerInfo:Send_Kuafu_3v3_Match()
	self:call_kuafu_3v3_match()
end

--
function PlayerInfo:Send_Kuafu_3v3_Match_Oper()
	local oper = self:RandomInt(1)
	self:call_kuafu_3v3_match_oper(oper)
end

--
function PlayerInfo:Send_Kuafu_3v3_Buytimes()
	local num = self:RandomInt(10)
	self:call_kuafu_3v3_buytimes(num)
end

--
function PlayerInfo:Send_Kuafu_3v3_Dayreward()
	local id = self:RandomInt(#tb_kuafu3v3_day_reward)
	self:call_kuafu_3v3_dayreward(id)
end

--
function PlayerInfo:Send_Kuafu_3v3_Getranlist()
	self:call_kuafu_3v3_getranlist()
end

--
function PlayerInfo:Send_Kuafu_3v3_Getmyrank()
	self:call_kuafu_3v3_getmyrank()
end

--
function PlayerInfo:Send_Kuafu_3v3_Cancel_Match()
	local type = self:RandomInt(2)
	self:call_kuafu_3v3_cancel_match(type)
end

--
function PlayerInfo:Send_Kuafu_Xianfu_Match()
	local indx = self:RandomInt(3)
	self:call_kuafu_xianfu_match(indx)
end

--
function PlayerInfo:Send_Buy_Xianfu_Item()
	local type = self:RandomInt(3)
	local indx = self:RandomInt(2)
	local count = self:RandomInt(20)
	self:call_buy_xianfu_item(type, indx, count)
end

--
function PlayerInfo:Send_Doujiantai_Fight()
	local rank = self:RandomInt(1000)
	self:call_doujiantai_fight(rank)
end

--
function PlayerInfo:Send_Doujiantai_Buytime()
	local num = self:RandomInt(10)
	self:call_doujiantai_buytime(num)
end

--
function PlayerInfo:Send_Doujiantai_Clearcd()
	self:call_doujiantai_clearcd()
end

--
function PlayerInfo:Send_Doujiantai_First_Reward()
	local id = self:RandomInt(#tb_doujiantai_first)
	self:call_doujiantai_first_reward(id)
end

--
function PlayerInfo:Send_Doujiantai_Get_Enemys_Info()
	self:call_doujiantai_get_enemys_info()
end

--
function PlayerInfo:Send_Doujiantai_Get_Rank()
	local startIdx = self:RandomInt(100)
	local   endIdx = self:RandomInt(100)
	self:call_doujiantai_get_rank(startIdx, endIdx)
end

--
function PlayerInfo:Send_Doujiantai_Refresh_Enemys()
	self:call_doujiantai_refresh_enemys()
end

--
function PlayerInfo:Send_Doujiantai_Top3()
	self:call_doujiantai_top3()
end

--
function PlayerInfo:Send_Submit_Quest_Daily2()
	self:call_submit_quest_daily2()
end


--
function PlayerInfo:Send_Change_Line()
	local lineNo = self:RandomInt(100)
	self:call_change_line(lineNo)
end

--
function PlayerInfo:Send_Show_Map_Line()
	self:call_show_map_line()
end

--
function PlayerInfo:Send_Spell_Start()
	local spellId = self:RandomInt(1000)
	local tx = self:RandomInt(100)
	local ty = self:RandomInt(100)
	local caster = self:RandomInt(1000)
	local target = self:RandomInt(1000)
	
	self:call_spell_start(spellId, tx, ty, caster, target)
end

--
function PlayerInfo:Send_Teleport()
	local uintGuid = self:RandomInt(1000000)
	self:call_teleport(uintGuid)
end

--
function PlayerInfo:Send_Use_Gameobject()
	local uintGuid = self:RandomInt(1000000)
	self:call_use_gameobject(uintGuid)
end

--
function PlayerInfo:Send_Instance_Exit()
	local r = self:RandomInt(3)
	self:call_instance_exit(r)
end

--
function PlayerInfo:Send_Ride_Mount()
	self:call_ride_mount()
end

--
function PlayerInfo:Send_Change_Battle_Mode()
	local mode = self:RandomInt(3)
	self:call_change_battle_mode(mode)
end

--
function PlayerInfo:Send_Jump_Start()
	local tx = self:RandomInt(200)
	local ty = self:RandomInt(200)
	self:call_jump_start(tx, ty)
end

--
function PlayerInfo:Send_Enter_Vip_Instance()
	local id = self:RandomInt(#tb_map_vip)
	local hard = self:RandomInt(3)
	self:call_enter_vip_instance(id, hard)
end

--
function PlayerInfo:Send_Enter_Trial_Instance()
	self:call_enter_trial_instance()
end

--
function PlayerInfo:Send_Teleport_Main_City()
	self:call_teleport_main_city()
end

--
function PlayerInfo:Send_Use_Broadcast_Gameobject()
	local target = self:RandomInt(10000000)
	self:call_use_broadcast_gameobject(target)
end

--
function PlayerInfo:Send_World_Boss_Fight()
	self:call_world_boss_fight()
end

--
function PlayerInfo:Send_Res_Instance_Enter()
	local id = self:RandomInt(#tb_instance_res)
	self:call_res_instance_enter(id)
end

--
function PlayerInfo:Send_Teleport_Map()
	local mapid = self:RandomInt(1008)
	local lineNo = self:RandomInt(10)
	self:call_teleport_map(mapid, lineNo)
end

--
function PlayerInfo:Send_Teleport_Field_Boss()
	local mapid = self:RandomInt(1008)
	local lineNo = self:RandomInt(10)
	self:call_teleport_field_boss(mapid, lineNo)
end

--
function PlayerInfo:Send_Talk_With_Npc()
	local entry = self:RandomInt(40000)
	local questId = self:RandomInt(1000)
	self:call_talk_with_npc(entry, questId)
end

--
function PlayerInfo:Send_Loot_Select()
	local tx = self:RandomInt(200)
	local ty = self:RandomInt(200)
	self:call_loot_select(tx, ty)
end

--
function PlayerInfo:Send_Gold_Respawn()
	self:call_gold_respawn(1)
end

--
function PlayerInfo:Send_Clientsubscription()
	local guid = self:RandomInt(10000000)
	self:call_clientSubscription(guid)
end

--
function PlayerInfo:Send_Use_Jump_Point()
	local id = self:RandomInt(10)
	self:call_use_jump_point(id)
end


function PathfindingGotoFailure(player, mapid)
	local x, y = player:GetPos()
	outFmtError("A player in (%d, %d) find path fail check %d.txt main road", x, y, mapid)
end



require("robotd.context.robotd_context_unit_mgr")
require("robotd.context.robotd_context_hanlder")
require("robotd.context.robotd_context_action_mgr")

require("robotd.context.robotd_context_item_mgr")
require("robotd.context.robotd_context_quest_mgr")
require("robotd.context.robotd_context_test_mgr")

return PlayerInfo
