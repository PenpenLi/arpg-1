local protocols = require('share.protocols')

--进入打坐
function ScenedContext:Hanlde_Dazuo_Start( pkt )
	if not self:IsAlive() then --死亡不允许打坐
		return
	end
	--在跨服地图不允许打坐
	local mapid = self:GetMapID()
	if IsKuafuMapID(mapid) then
		return
	end
	if self:GetDaZuoTime() == 0 then	--不在打坐，则打坐
		self:StartDaZuo()
	else
		self:CancelDaZuo()
	end
end

--领取打坐的经验韬略奖励
function ScenedContext:Hanlde_Dazuo_Receive(pkt)
	self:ReceiveDaZuo()
end

--开始挂机
function ScenedContext:Hanlde_Start_Hung_Up(pkt)
	if self:IsAlive() then 		
		--记录挂机开始时间
		if not self:GetHungUp() then
			self:SetHungUpStartTime(os.time())
			self:SetHungUp()
			--playerLib.SendToAppdDoSomething(player_ptr, SCENED_APPD_FUXINGJIANGLIN)
		end
	else
		if self:GetHungUp() then
			self:UnSetHungUp() 
		end
	end
end

--停止挂机
function ScenedContext:Hanlde_Stop_Hung_Up(pkt)
	if self:GetHungUp() then
		self:UnSetHungUp()
	end
	
	--记录挂机时长
	if self:GetHungUpStartTime() ~= 0 then
		local times = math.floor((os.time() - self:GetHungUpStartTime())/60)
		if(times > 0)then
			self:AddHungUpTime(times)
			self:AddHungUpDailyTime(times)
		end
		self:SetHungUpStartTime(0)
	end
end

--转生
function ScenedContext:Hanlde_Zhuan_Sheng(packet)
	local player_level = self:GetLevel()
	local zhuan = packet.zhuan
	if zhuan < 1 and zhuan > 5 then 
		outFmtError("player %s zhuan %d param is wrong!", self:GetPlayerGuid(), zhuan)
		return 
	end
	
	--等级没达到
	if player_level ~= tb_grade_up[zhuan].need_level then
		return					
	end
	
	--一转
	if zhuan == 1 then
		for i = 1, #tb_grade_up_1 do
			local quest_id = tb_grade_up_1[i].guide_mission_id
			if not self:GetQuestCompleteListFlag(quest_id) then
				return --还有任务没有完成
			end
		end
	--二转
	elseif zhuan == 2 then
		if self:GetYuanshenCount() < #tb_grade_up_2 then
			return	--还没满级
		end

	--三转
	elseif zhuan == 3 then
		if not self:IsWuxingMaxLevel() then
			return --还没满级
		end

	--四转
	elseif zhuan == 4 then
		local leijie_count = self:GetLeijieCount()
		if leijie_count < #tb_grade_up_set_4 then
			return
		end

	--五转
	elseif zhuan == 5 then
		local dianmai_count = self:GetDianmaiCount()
		if dianmai_count < #tb_grade_up_5 then
			return
		end
	end
	--恭喜校验通过，可以转生了
	--设置下最大等级
	local max_level = self:GetMaxLevel()
	if zhuan < 5 then
		self:SetMaxLevel( tb_grade_up[zhuan+1].need_level )
	elseif zhuan == 5 then
		self:SetMaxLevel( #tb_char_level )
	end
	if not playerLib.Upgrade(self.ptr, 1) then		-- 转生失败
		self:SetMaxLevel(max_level)
	end

	--发公告
	onSendNotice(20, self:GetPlayerGuid(), self:GetName(), zhuan, tb_grade_up[zhuan].name)
	--下发错误提示
	self:CallOptResult(OPERTE_TYPE_ZHUANSHENG, ZHUANSHENG_OPERATE_BREAK_SUCCESS, zhuan)
end

--进入飞升之路
function ScenedContext:Hanlde_Enter_Feishengzhilu(packet)	
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_ENTER_FEISHENGZHILU player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_FEISHENGZHILU player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	
	--pvp状态下一律不准进
	if(self:GetPVPState())then
		outFmtError("CMSG_ENTER_FEISHENGZHILU player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	local level = self:GetFszlLevel() + 1
	--校验下参数对不对
	if level < 1 or level > #tb_feishengzhilu then
		outFmtError("CMSG_ENTER_FEISHENGZHILU player %s level %d is wrong", self:GetPlayerGuid(), level)
		return
	end
	
	local to_mapid = tb_feishengzhilu[level].map_id
	playerLib.Teleport(player_ptr, to_mapid, tb_map_info[to_mapid].into_point[1], tb_map_info[to_mapid].into_point[2])		
end

--副本挂机操作
function ScenedContext:Hanlde_Fuben_Hung_Up(packet)	
	self:DoFubenHungUp(packet.ntype, packet.count, packet.param)
end

--进入奇遇
function ScenedContext:Hanlde_Enter_Qiyu(packet)
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_ENTER_QIYU player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_QIYU player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	
	--pvp状态下一律不准进
	if(self:GetPVPState())then
		outFmtError("CMSG_ENTER_QIYU player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	local tb = tb_qiyu[packet.qiyu_id]
	if(tb == nil)then
		outFmtError("CMSG_ENTER_QIYU params is wrong!")
		return
	end
	local to_mapid = tb.map
	local qiyu_type = tb.type
	if(qiyu_type == 0)then--单人
		playerLib.Teleport(player_ptr, to_mapid, tb_map_info[to_mapid].into_point[1], tb_map_info[to_mapid].into_point[2])
	else--多人
		playerLib.Teleport(player_ptr, to_mapid, tb_map_info[to_mapid].into_point[1], tb_map_info[to_mapid].into_point[2],0,string.format("qiyu_more_%d",packet.qiyu_id))
	end
			
end

--进入武神擂台
function ScenedContext:Hanlde_Enter_WuShen_LeiTai(packet)
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("Hanlde_Enter_WuShen_LeiTai player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("Hanlde_Enter_WuShen_LeiTai player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	
	--pvp状态下一律不准进
	if self:GetPVPState() then
		outFmtError("Hanlde_Enter_WuShen_LeiTai player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	local config = tb_wushen_map[packet.leitai_id]
	if not config then
		outFmtError("Hanlde_Enter_WuShen_LeiTai config is wrong!")
		return
	end
	--等级限制
	local player_level = self:GetLevel()
	if player_level < config.level[1] or player_level > config.level[2] then
		outFmtError("Hanlde_Enter_WuShen_LeiTai player_level is wrong!")
		return
	end
	
	
	--发到应用服扣除材料
	playerLib.SendToAppdDoSomething(player_ptr, SCENED_APPD_ENTER_WUSHEN_LEITAI_COST,packet.leitai_id)
end


-- 查询副本信息
function ScenedContext:Hanlde_Query_Fuben_Info(packet)
	local type = packet.type
	local level = packet.level
	if type == 1 then --飞升之路排名前三
		local result = ""
		for i=1,MAX_FSZL_RANK do
			local guid = globalCounter:GetFSZLPlayerGuid(level,i)
			local name = globalCounter:GetFSZLPlayerName(level,i)
			result = result..guid..";"..name..";"
		end
		-- 下发数据给客户端显示		
		self:call_query_fuben_info_result(type, result)		
	elseif type == 2 then --副本前十杀怪数排名
		local result = ""
		for i = 1,MAX_FUBEN_RANK do
			local guid = globalCounter:GetFubenPlayerGuid(i)
			local name = globalCounter:GetFubenPlayerName(i)
			local killnum =  globalCounter:GetFubenPlayerKill(i)
			if guid then
				result = result..guid..";"..name..";"..killnum..";"	
			end
		end
		-- 下发数据给客户端显示		
		self:call_query_fuben_info_result(type, result)
	end
end

--进入蟠桃园
function ScenedContext:Hanlde_Enter_Pantaoyuan(packet)
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_ENTER_PANTAOYUAN player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_PANTAOYUAN player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	--人数不能太多
	if globalValue:GetPantaoyuanNum() >200 then
		outFmtError("CMSG_ENTER_PANTAOYUAN player %s is to more!", self:GetPlayerGuid())
		return
	end
	
	local to_mapid = 30
	playerLib.Teleport(player_ptr, to_mapid, Instance_pantaoyuan.PLAYER_POSX, Instance_pantaoyuan.PLAYER_POSY)		
end

-- 开始使用游戏对象
function ScenedContext:Hanlde_Use_Gameobject_Start(packet)	
	self:StartUseGameObject()
end

--接受其他任务
function ScenedContext:Hanlde_Receive_Other_Quest(packet)	
	if(packet.type == QUEST_TYPE_TOKEN)then --江湖密令任务
		self:DoAcceptTokenQuset()
	elseif(packet.type == QUEST_TYPE_XUANSHANG)then --悬赏任务
		self:DoAcceptXuanShangQuset()
	end
end

--完成其他任务
function ScenedContext:Hanlde_Complete_Other_Quest(packet)	
	if(packet.type == QUEST_TYPE_TOKEN)then --江湖密令任务
		self:DoCompleteTokenQuset(packet.quest_id,packet.item_guid,packet.reserve)
	end
end		

-- 全屏秒杀操作
function ScenedContext:Hanlde_Instance_All_Kill_Opt(packet)
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	local allCreatures = mapLib.GetAllCreature(map_ptr)
	if(#allCreatures > 0)then
		playerLib.SendToAppdDoSomething(player_ptr, SCENED_APPD_ALL_KILL_SUB_MONEY)
	else
		--下发错误提示
		self:CallOptResult(OPERTE_TYPE_FUBEN, FUBEN_OPRATE_NO_CREATURES)
	end
end

--进入风流镇酒馆
function ScenedContext:Hanlde_Enter_Fengliuzhen_Pub(packet)
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	-- if mapInfo:GetInstanceType() ~= 0 then
		-- outFmtError("CMSG_ENTER_FENGLIUZHEN_PUB player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		-- return
	-- end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_FENGLIUZHEN_PUB player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	
	--pvp状态下一律不准进
	if(self:GetPVPState())then
		outFmtError("CMSG_ENTER_FENGLIUZHEN_PUB player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	
	local to_mapid = 33
	playerLib.Teleport(player_ptr, to_mapid, tb_map_info[to_mapid].into_point[1], tb_map_info[to_mapid].into_point[2])		
end

--跳跃	
function ScenedContext:Hanlde_Jump_Start(packet)
	local player_ptr = self.ptr
	local dst_x, dst_y = packet.pos_x, packet.pos_y
	if dst_x == 0 or dst_y == 0 then
		outDebug("MSG_JUMP_START  dst_x == 0 or dst_y == 0 !!!")
		return
	end	
	if not self:IsAlive() then
		outDebug("do MSG_JUMP_START but caster is not alive")
		self:CallOptResult(OPRATE_TYPE_JUMP, JUMP_RESULT_DEAD)
		return
	end
	--验证目标点是不是障碍点
	local map_ptr = unitLib.GetMap(player_ptr)
	if map_ptr == nil then
		outDebug("error : do MSG_JUMP_START but map_ptr = nil ")
		--错误返回
		return
	end
	--看看本地图是否允许施法
	if not mapLib.GetCanCastSpell(map_ptr) then
		outDebug("MSG_JUMP_START  this map is cannot cast spell !!!")
		self:CallOptResult(OPRATE_TYPE_JUMP, JUMP_RESULT_MAP_CANT_JUMP)
		return
	end
	--是否有进制跳跃buff
	if not unitLib.IsCanJump(player_ptr) then
		outDebug("MSG_JUMP_START  player is cannot jump !!!")
		self:CallOptResult(OPRATE_TYPE_JUMP, JUMP_RESULT_CANT_JUMP)
		return
	end
	
	--如果是生化危机地图
	local map_id = unitLib.GetMapID(player_ptr)
	if map_id == SHWJ_INSTANCE_MAPID then
		local mapInfo = Select_Instance_Script(map_id):new{ptr = map_ptr}
		mapInfo:StartJump(self,dst_x,dst_y)
		return
	end
	
	--如果是2段跳，判断是否激活了2段跳技能
	if unitLib.HasBuff(player_ptr, BUFF_JUMP_JUMP) then
		if not self:IsActiveSpell(5) then
			outDebug("MSG_JUMP_START  Spell is not Active !!!")
			self:CallOptResult(OPRATE_TYPE_JUMP, JUMP_RESULT_NOT_ACTIVE_SPELL)
			return
		end
	end 
	
	--验证cd
	local cur_time = getMsTime()			--获取服务器运行时间
	local cd_time = self:GetPlayerJumpCd()	-- 玩家跳跃技能cd
	if cur_time < cd_time then
		self:CallOptResult(OPRATE_TYPE_JUMP, JUMP_RESULT_SPELL_CD)
		return
	end
	
	
	--距离验证
	local MAX_CAST_DISTANCE = 20
	local angle = self:GetAngle(dst_x, dst_y)
	local distance = self:GetDistance(dst_x, dst_y)
	local cas_x, cas_y = unitLib.GetPos(player_ptr)
	if distance > MAX_CAST_DISTANCE then
		distance = MAX_CAST_DISTANCE
	end
	
	while(distance > 0)do
		dst_x = cas_x + distance * math.cos(angle)
		dst_y = cas_y + distance * math.sin(angle)
		if mapLib.IsCanRun(map_ptr, dst_x, dst_y) == 1 then
			break
		else
			distance = distance - 0.3
		end
	end
	
	
	if mapLib.IsCanRun(map_ptr, dst_x, dst_y) == 1 then
		Select_Instance_Script(self:GetMapID()):OnStartJump(self)
		--增加BUFF
		SpelladdBuff(player_ptr, BUFF_JUMP_JUMP, player_ptr, 1,tb_buff_template[BUFF_JUMP_JUMP].duration)
		--移动
		local move_path = {}
		table.insert(move_path,dst_x)
		table.insert(move_path,dst_y)
		unitLib.MoveTo(player_ptr, #move_path,table.concat(move_path,","))
		unitLib.CallJumpStart(player_ptr, dst_x, dst_y)
	else
		outFmtError("error : MSG_JUMP_START is not can run x = %d  y = %d",dst_x, dst_y)
		self:CallOptResult(OPRATE_TYPE_JUMP, JUMP_RESULT_WRONG_COORD)
	end
end

-- /*跳跃结束*/
function ScenedContext:Hanlde_Jump_End(packet)
	local player_ptr = self.ptr
	--如果是生化危机地图
	local map_id = unitLib.GetMapID(player_ptr)
	if map_id == SHWJ_INSTANCE_MAPID then
		local mapInfo = Select_Instance_Script(map_id):new{ptr = map_ptr}
		mapInfo:EndJump(self,packet.pos_x, packet.pos_y)
		return
	end
	
	local jump_lv = unitLib.GetBuffLevel(player_ptr,BUFF_JUMP_JUMP)
	if(jump_lv == 2)then			--若是第二次跳，那必须先移动到终点去
		local x,y = unitLib.GetMoveEndPos(player_ptr)
		if(x ~= 0 and y ~= 0)then	--为0的时候是已经走到了
			unitLib.SetPos(player_ptr, x, y, false)
		end
		--BUFF:跳跃落地后，移动速度提升50%、闪避率提升30%，持续5秒
		SpelladdBuff(player_ptr, BUFF_JUMP_DOWN, player_ptr, 1,tb_buff_template[BUFF_JUMP_DOWN].duration)
	end
	
	--设置cd
	local cur_time = getMsTime()
	local cd = tb_skill_base[4].singleCD
	self:SetPlayerJumpCd(cur_time + cd)
	--移除BUFF
	unitLib.RemoveBuff(player_ptr, BUFF_JUMP_JUMP)
	unitLib.CallJumpEnd(player_ptr, packet.pos_x, packet.pos_y)
end

--坐骑骑乘
function ScenedContext:Hanlde_Mount_Riding(packet)
	local player_ptr = self.ptr
	if packet.type == 0 then	--上坐骑
		--当前是战斗状态
		local status = playerLib.GetPlayeCurFightStatus(player_ptr)
		if status == COMBAT_STATE_ENTER then
			self:CallOptResult(OPRATE_TYPE_MOUNT_QICHENG, MOUNT_QICHENG_FIGHT)
			return
		end
		--当前是跳跃状态
		if unitLib.HasBuff(player_ptr, BUFF_JUMP_JUMP) then
			self:CallOptResult(OPRATE_TYPE_MOUNT_QICHENG, MOUNT_QICHENG_JUMP)
			return
		end
		if packet.mount_entry <= 0 then
			return
		end
		playerLib.SendMountJumpDown(player_ptr,packet.mount_entry)
	elseif packet.type == 1 then	--下坐骑
		playerLib.SendMountJumpDown(player_ptr,0)
	end
end

--客户端发起传送
function ScenedContext:Hanlde_Teleport( pkt )
	Script_WorldMap_Teleport(self, pkt.map_id, pkt.pos_x, pkt.pos_y)
end

--打boss传送
function ScenedContext:Hanlde_DaBoss_Teleport( pkt )
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_DABOSS_TELEPORT player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_DABOSS_TELEPORT player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	
	--pvp状态下一律不准进
	if(self:GetPVPState())then
		outFmtError("CMSG_DABOSS_TELEPORT player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	
	local teleport_count = self:GetDaBossTeleportCount()
	if teleport_count >= 50 then
		outFmtError("CMSG_DABOSS_TELEPORT teleport_count is %d", self:GetDaBossTeleportCount())
		return
	end
	teleport_count = teleport_count + 1
	self:SetDaBossTeleportCount(teleport_count)
	playerLib.Teleport(player_ptr, pkt.map_id, pkt.pos_x, pkt.pos_y)
	
end

--进入武林秘境
function ScenedContext:Hanlde_Enter_Wulin( pkt )
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_ENTER_WULIN player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_WULIN player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	
	--pvp状态下一律不准进
	if(self:GetPVPState())then
		outFmtError("CMSG_ENTER_WULIN player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	
	--vip限制 --先不做限制
	local is_vip = false
	for i = 1,MAX_GAME_VIP_TYPE do
		if self:GetVipEndTime(i) > os.time() then
			is_vip = true
		end
	end
	
	if not is_vip then
		if self:GetEntryWuLinCount() >= 1 then
			outFmtError("CMSG_ENTER_WULIN not is_vip and GetEntryWuLinCount = %d", self:GetEntryWuLinCount())
			return
		else
			self:SetEntryWuLinCount(1)
		end
	end
	local to_mapid = pkt.map_id
	playerLib.Teleport(player_ptr, to_mapid, tb_map_info[to_mapid].into_point[1], tb_map_info[to_mapid].into_point[2])
end

--BOSS掉落记录查询
function ScenedContext:Handle_Boss_Drop_Record_Query( pkt )
	local event = {}	
	for i = 1, MAX_DROP_RECORD_INFO_COUNT do
		local ret, player_guid, player_name, item_entry, boss_entry, map_id, tm ,boss_level ,map_cs = globalCounter:GetBossDropRecordInfo( i - 1 )
		if ret then
			local e = boss_drop_event_t.new()
			e.player_guid = player_guid
			e.player_name = player_name
			e.item_entry = item_entry
			e.boss_entry = boss_entry
			e.map_id = map_id
			e.time = tm
			e.boss_level = boss_level
			e.map_cs = map_cs
			table.insert( event, e)
		end
	end
	self:call_boss_drop_event_query_result( event )
end

--查询上次击杀BOSS的玩家信息
function ScenedContext:Handle_Query_Kill_Boss_Playername( pkt )
	local entry = pkt.boss_entry
	if entry == 0 then
		outFmtError("Handle_Query_Kill_Boss_Playername:  boss_entry:%d",entry )
		return
	end 
	--查找被杀BOSS模板位置
	local cursor = globalCounter:FindKillBossPosition( entry )
	local boss_entry, player_name
	if cursor ~= -1 then 
		boss_entry, player_name = globalCounter:GetKillBossInfo(cursor)
	else
		boss_entry, player_name = entry, ""		
	end	
	self:call_query_kill_boss_playername(boss_entry, player_name)
end

--请求BUFF处理
function ScenedContext:Hanlde_Ask_For_Buff( pkt )
	if(unitLib.HasBuff(self.ptr, pkt.data))then
		unitLib.RemoveBuff(self.ptr, pkt.data)
		ClearBuffFlags(self.ptr, pkt.data)
	end
end

--进入日常副本
function ScenedContext:Hanlde_Enter_Daily_Instance( pkt )
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_ENTER_DAILY_INSTANCE player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_DAILY_INSTANCE player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	--pvp状态下一律不准进
	if self:GetPVPState() then
		outFmtError("CMSG_ENTER_DAILY_INSTANCE player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	--发到应用服其他校验、及扣除材料
	playerLib.SendToAppdDoSomething(player_ptr, SCENED_APPD_ENTER_DAILY_INSTANCE, pkt.map_id)
end

--进入塞外伏击副本
function ScenedContext:Hanlde_Enter_Swfj_Instance( pkt )
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_ENTER_DAILY_INSTANCE player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_DAILY_INSTANCE player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	--pvp状态下一律不准进
	if self:GetPVPState() then
		outFmtError("CMSG_ENTER_DAILY_INSTANCE player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	
	--次数判断
	if self:GetSwfjEnterCount() >= tb_swfj[151].num then
		outFmtError("CMSG_ENTER_DAILY_INSTANCE enter count %s is max", self:GetSwfjEnterCount())
		return
	end
	
	local to_mapid = 151
	playerLib.Teleport(player_ptr, to_mapid, tb_map_info[to_mapid].into_point[1], tb_map_info[to_mapid].into_point[2])	
end

--塞外伏击领取经验
function ScenedContext:Hanlde_Get_Swfj_Instance_Reward( pkt )
	local mapid = unitLib.GetMapID(self.ptr)
	if not tb_swfj[mapid] then return end
	local map_ptr = unitLib.GetMap(self.ptr)
	if not map_ptr then return end
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	
	--不在领奖励阶段
	if mapInfo:GetMapState() ~= mapInfo.STATE_GET_EXP then
		return
	end
	--发到应用服其他校验、及扣除材料
	playerLib.SendToAppdDoSomething(self.ptr, SCENED_APPD_SWFJ_INSTANCE_AWARD_SUB_MONEY, pkt.get_type)
end

--塞外伏击建造
function ScenedContext:Hanlde_Swfj_Instance_Jianzao( pkt )
	local mapid = unitLib.GetMapID(self.ptr)
	if not tb_swfj[mapid] then return end
	--判断勇士数量
	local map_ptr = unitLib.GetMap(self.ptr)
	if not map_ptr then return end
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	if mapInfo:GetFubenYongShiCount() >= mapInfo.MAX_YONGSHI_COUNT then
		return
	end
	local cas_x, cas_y = unitLib.GetPos(self.ptr)
	local targets = mapLib.GetCircleTargets(cas_x, cas_y, mapInfo.TA_AND_TA_DISTANCE, self.ptr, TARGET_TYPE_FRIENDLY)
	if #targets > 1 then
		local casterInfo = UnitInfo:new{ptr = self.ptr}
		casterInfo:CallOptResult(OPRATE_TYPE_SWFJ, SWFJ_RESON_HAS_YONGSHI)		
		return
	end
	--发到应用服其他校验、及扣除材料
	playerLib.SendToAppdDoSomething(self.ptr, SCENED_APPD_SWFJ_INSTANCE_JIANZAO, pkt.jianzao_type)
end

--风流镇-荒岛求生操作
function ScenedContext:Hanlde_Hdqs_Other_Opt( pkt )
	local mapid = unitLib.GetMapID(self.ptr)
	if mapid ~= FLZ_INSTANCE_HDQS_MAPID then return end
	local map_ptr = unitLib.GetMap(self.ptr)
	if not map_ptr then return end
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	mapInfo:HdqsPlayerOtherOpt(self.ptr, pkt.opt_type, pkt.opt_data, pkt.reserve)
end

--风流镇生化危机升级科技
function ScenedContext:Hanlde_Shwj_Instance_KeJi_LevelUp( pkt )
	local mapid = unitLib.GetMapID(self.ptr)
	if mapid ~= SHWJ_INSTANCE_MAPID then return end
	local map_ptr = unitLib.GetMap(self.ptr)
	if not map_ptr then return end
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	mapInfo:KeJiLevelUp(self,pkt.opt_type)
end

--风流镇生化危机换子弹
function ScenedContext:Hanlde_Shwj_Instance_HuanZiDan( pkt )
	local mapid = unitLib.GetMapID(self.ptr)
	if mapid ~= SHWJ_INSTANCE_MAPID then return end
	local map_ptr = unitLib.GetMap(self.ptr)
	if not map_ptr then return end
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	mapInfo:HuanZiDan(self)
end

--进入奇遇
function ScenedContext:Hanlde_Faction_FuBen(packet)
	local player_ptr = self.ptr
	local map_ptr = unitLib.GetMap(player_ptr)
	if not map_ptr then return end
	local mapid = unitLib.GetMapID(player_ptr)
	local mapInfo = Select_Instance_Script(mapid):new{ptr = map_ptr}
	--玩家不在世界地图,不让传
	if mapInfo:GetInstanceType() ~= 0 then
		outFmtError("CMSG_ENTER_FACTION_FUBEN player %s not in worldmap, curmapid %d!", self:GetPlayerGuid(), mapid)
		return
	end
	--玩家必须还活着
	if not self:IsAlive() then
		outFmtError("CMSG_ENTER_FACTION_FUBEN player %s is not alive!", self:GetPlayerGuid())
		return 
	end
	
	--pvp状态下一律不准进
	if(self:GetPVPState())then
		outFmtError("CMSG_ENTER_FACTION_FUBEN player %s is pvp state!", self:GetPlayerGuid())
		return
	end
	local lv = self:GetFactionFbCount() + 1
	local tb = tb_bangpai_boss[lv]
	if(tb == nil)then
		outFmtError("CMSG_ENTER_FACTION_FUBEN params is wrong!")
		return
	end
	local to_mapid = tb.map
	playerLib.Teleport(player_ptr, to_mapid, tb_map_info[to_mapid].into_point[1], tb_map_info[to_mapid].into_point[2],0,string.format("faction_boss_%d",lv))
end

function ScenedContext:Handle_ForceInto(pkt)
	print("force into")
	DoForceInto(self)
end


local OpcodeHandlerFuncTable = require 'scened.context.scened_context_handler_map'

--网络包处理方法
packet.register_on_external_packet(function ( player_ptr, pkt )
	local _player = UnitInfo:new{ptr = player_ptr}	
	local optcode = packet.optcode(pkt)
	local succeed, args = protocols.unpack_packet(optcode, pkt)
	
	--解包失败记一下日志
	if not succeed then
		logLib.WriteAttackPacker(_player:GetGuid(), optcode, ACCACK_PACKET_TYPE_UNPACK, '')
	else
		args.__optcode = optcode		
		if OpcodeHandlerFuncTable[optcode] then
			OpcodeHandlerFuncTable[optcode](_player, args)
		end
	end
end)
