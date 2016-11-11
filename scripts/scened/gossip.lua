--地图传送
function Script_WorldMap_Teleport(player,map_id,p_x,p_y)
	print("Script_WorldMap_Teleport")
	playerLib.Teleport(player, map_id, p_x, p_y, 0, "")
	
	--[[
	local map_info = tb_map_info[map_id]
	if not map_info then
		outFmtError("Script_WorldMap_Teleport: %d tb_map_info config not find!",map_id)
		return
	end

	local player_lv = playerInfo:GetLevel()
	if player_lv < map_info.min_level then
		outFmtDebug("Script_WorldMap_Teleport: player %s level %d < %d is too low!", playerInfo:GetPlayerGuid(), player_lv, map_info.min_level)
		return		
	end
	
	if p_x == 0 or p_y == 0 then
		p_x = map_info.into_point[1]
		p_y = map_info.into_point[2]
	end

	--if not playerInfo:GetPVPState() then
	--end
	]]
end


-- 找到本地图的所有人传送到某一个组队副本中
function DoForceInto(playerInfo)
	--[[
	local toMapId = 103
	local toX = 25
	local toY = 21

	--local ownerGuid = playerInfo:GetPlayerGuid()

	local map_ptr = unitLib.GetMap(playerInfo.ptr)
	local mapId = mapLib.GetMapID(map_ptr)
	local targetUnits = mapLib.GetAllPlayer(map_ptr)

	for _, target in pairs(targetUnits) do
		playerLib.Teleport(target, toMapId, toX, toY, 0, "")
	end
	]]
end


--接受任务的回调
function DoAcceptQuest(map, player, questid)
	local playerInfo = UnitInfo:new{ptr = player}
	local timenow = os.time()
	--支线任务判断
	local zhixian_config = tb_quest_zhixian_open[questid]
	if zhixian_config then
		for _,zhixian_id in ipairs(zhixian_config.zhixian_id) do
			assert(tb_quest_zhixian_condition[zhixian_id] ~= nil)
			playerLib.AcceptQuest(player, zhixian_id)
		end
	end
	--接受任务跟随判断
	local template = tb_quest_template[questid]
	if template and template.param0 then
		local follow_entry = template.param0[2] --跟随模板
		if follow_entry and follow_entry ~= 0 then
			local posx, posy = unitLib.GetPos(player)
			local dst_x = posx + randInt(-5, 5)
			local dst_y = posy + randInt(-5, 5)
			if(mapLib.IsCanRun(map, dst_x, dst_y) == 0)then
				dst_x = posx
				dst_y = posy
			end			
			local toward_rand = randIntD(1, 628)/100 -- 给个随机的朝向把
			local tempCreature = mapLib.AddCreature(map, {templateid = follow_entry, level = playerInfo:GetLevel(), x = dst_x, y = dst_y, toward = toward_rand, active_grid = true, npcflag = {UNIT_NPC_FLAG_GOSSIP}})
			if(tempCreature ~= nil)then
				local creatureInfo = UnitInfo:new{ptr = tempCreature}
				creatureInfo:SetUnitFlags(UNIT_FIELD_FLAGS_QUEST_FOLLOW_CREATUR)	--设置成任务跟随宠物
				unitLib.SetMoveSpeed(tempCreature, unitLib.GetMoveSpeed(player))
				creatureLib.MonsterMove(tempCreature, FOLLOW_MOTION_TYPE, player)				
				creatureLib.SetMonsterHost(tempCreature, player)
			end
		end
	end

	--处理雕飞buff的任务
	for _, id in ipairs(tb_game_set[105].value) do
		if(questid == id)then
			SpelladdBuff(player, BUFF_DIAO_FLY, player, 1, 120) --2分钟就够了
			break
		end
	end

end

--任务完成的回调
function DoCompleteQuest(map, player, questid)
	local playerInfo = UnitInfo:new{ptr = player}
	
	--若是转生任务则自动帮忙接受下一个任务
	for i = 1, #tb_grade_up_1 do
		if tb_grade_up_1[i].guide_mission_id == questid and i < #tb_grade_up_1 then
			playerLib.AcceptQuest(player, tb_grade_up_1[i+1].guide_mission_id)
		end
	end
	
	--支线任务判断
	local quest_config = tb_quest_zhixian_follow[questid]
	if(quest_config)then
		for _,zhixian_id in ipairs(quest_config.follow_id) do
			local can_accept = true
			local condition_config = tb_quest_zhixian_condition[zhixian_id]
			if condition_config then
				for _,quest_id in ipairs(condition_config.condition_id) do
					if playerInfo:GetQuestCompleteListFlag(quest_id) == false then
						can_accept = false
						break
					end
				end
			end
			if can_accept then
				playerLib.AcceptQuest(player, zhixian_id)
			end
		end	
	end
	
	--校验完成任务删除跟随	
	local template = tb_quest_template[questid]
	if template and template.param0 then
		local follow_entry = template.param0[2] --跟随模板
		if follow_entry and follow_entry ~= 0 then
			--移除要删除的跟随怪物
			local petTab = playerLib.GetPetTable(player)
			for _, pet_ptr in pairs(petTab) do
				local petInfo = UnitInfo:new{ptr = pet_ptr}	
				if petInfo:GetUnitFlags(UNIT_FIELD_FLAGS_QUEST_FOLLOW_CREATUR) then
					mapLib.RemoveWorldObject(map, pet_ptr) 					
				end
			end
			
		end
	end

	--雕飞任务buff
	for _, id in ipairs(tb_game_set[105].value) do
		if(questid == id)then
			if(unitLib.HasBuff(player, BUFF_DIAO_FLY))then
				unitLib.RemoveBuff(player, BUFF_DIAO_FLY)
			end
			break
		end
	end
	
	--完成任务后某系统开启做点什么
	playerInfo:ActivedSystemToDoSomething(questid)
end

--使用任务物品
function Script_Use_QuestItem(user, map, item_entryid)
	
end

--处理江湖密令任务奖励
function DoTokenReward(player_ptr, quest_id, multiple)
	local playerInfo = UnitInfo:new{ptr = player_ptr}
	local player_lv = playerInfo:GetLevel()
	local config = tb_jianghu_reward[player_lv]
	if not config then
		outFmtDebug("DoTokenReward:player %s level %d is not find config!", playerInfo:GetPlayerGuid(), player_lv)
		return
	end
	local star_lv = playerInfo:GetTokenStarLv()
	local xp = config.reward_exp * star_lv * multiple
	local silver = config.reward_money * star_lv * multiple
	if(xp > 0)then --经验
		playerLib.AddExp(player_ptr, xp)
	end	
	if(silver > 0)then --铜钱
		playerInfo:AddMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_QUEST, silver)
	end
	--道具
	for i = 1, #config.reward_daoju, 2 do
		playerLib.AddItem(player_ptr, config.reward_daoju[i], config.reward_daoju[i+1]*multiple, ITEM_BIND_NONE, LOG_ITEM_OPER_TYPE_QUEST)
	end
	playerInfo:SetTokenRefreshCount(0) --刷星次数清0
	playerInfo:SetTokenStarLv(randIntD(1,10))
end

--处理任务奖励，经验，银子，绑定元宝
function DoQuestRewardScript(player, quest_id, xp, silver, taolue, bind_gold, all_flag, special_flag)	
	--任务表有没有
	local quest_config = tb_quest_template[quest_id]
	--江湖密令任务奖励不走这里
	if not quest_config or quest_config.quest_type == QUEST_TYPE_TOKEN then
		return 
	end

	local playerInfo = UnitInfo:new{ptr = player}
	local fcm = playerInfo:GetFCMLoginTime()
	local isfcm = false
	--防沉迷部分
	if(fcm >=300 and fcm ~= MAX_UINT32_NUM) then
		return 
	elseif(fcm >= 180 and fcm ~= MAX_UINT32_NUM) then
		isfcm = true		
	end
	
	if(isfcm)then
		xp = xp * 0.5
		silver = silver * 0.5
		bind_gold = bind_gold * 0.5
	end
		
	if(xp > 0)then
		playerLib.AddExp(player, xp)
	end	
	if(silver > 0)then
		playerInfo:AddMoney(MONEY_TYPE_SILVER, MONEY_CHANGE_QUEST, silver)   --增加铜钱
	end
	if(bind_gold > 0)then
		playerInfo:AddMoney(MONEY_TYPE_BIND_GOLD, MONEY_CHANGE_QUEST, bind_gold)
	end
		
end

