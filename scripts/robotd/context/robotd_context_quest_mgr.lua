
-- 进行下一个任务
function PlayerInfo:DoNextQuest()
	
	if not self.quest then
		outFmtDebug("		quest binlogObject not init")
		return
	end
	
	local questInfo = self.quest:GetMainQuestInfo()
	if not questInfo then
		outFmtDebug("		no main quest")
		return
	end
	
	if self.questStart then
		outFmtDebug("		self.questStart true")
		return
	end
	
	local config = tb_quest[questInfo.questId]
	local targets = config.targets
	-- 找任务目标
	for indx, target in ipairs(targets) do
		local targetType = target[ 1 ]
		local stepInfo	 = questInfo.steps[indx]
		if stepInfo.stepState == 0 and Quest_Function[targetType] then
			return Quest_Function[targetType](self, questInfo.questId, indx)
		end
	end
	
	if questInfo.state == QUEST_STATUS_COMPLETE then
		outFmtDebug("		send for finish questId = %d", questInfo.questId)
		self:AutoSendFinishQuest(questInfo.questId)
		return
	end
	
	outFmtDebug("		no deal target for questId = %d", questInfo.questId)

	return 
end

-- 装备神兵
function PlayerInfo:RobotEquipDivine(questId, indx)
	if not self.spellMgr then
		outFmtDebug("spellMgr not attach")
		return
	end
	local config = tb_quest[questId]
	local stepParams = config.targetsPosition[indx]
	
	local questOperate = {}
	questOperate.type = config.targets[indx][ 1 ]
	questOperate.questId = questId
	
	local divineId = config.targets[indx][ 2 ]
	local divineDict = self.spellMgr:getDivineIdList()
	
	local need = 0
	
	for _, divId in ipairs(divineDict) do
		if divineId == 0 or divId == divineId then
			need = divId
			break
		end
	end
	
	-- 存在神兵 装备
	if need > 0 then
		--divine_active ( id :number )
		questOperate.callback = function()
			outFmtDebug("call_divine_switch divineId = %d", need)
			self:call_divine_switch(divineId)
			-- 发送完成任务命令
			self:AutoSendFinishQuest(questId)
		end
	else
		-- 判断是否要购买
		if divineId == 0 then
			-- 没法购买
			outFmtDebug("not divineId to buy for questId = %d", questId)
			return
		else
			-- 激活神兵
			outFmtDebug("call_divine_active divineId = %d", need)
			self:call_divine_active (divineId)
			return
		end
	end
	
	return questOperate
end

-- 和NPC讲话
function PlayerInfo:TalkWithNPC(questId, indx)
	local config = tb_quest[questId]
	local stepParams = config.targetsPosition[indx]
	
	local questOperate = {}
	questOperate.type 		= config.targets[indx][ 1 ]
	questOperate.mapid		= stepParams[ 2 ]
	questOperate.x			= stepParams[ 3 ]
	questOperate.y			= stepParams[ 4 ]
	questOperate.objcet_id	= stepParams[ 5 ]
	questOperate.questId = questId

	local entry = questOperate.objcet_id
	questOperate.callback 	= function()
		outFmtDebug("call_talk_with_npc entry = %d, questId = %d", entry, questId)
		self:call_talk_with_npc (questOperate.objcet_id ,questId)
	end

	-- 寻路
	self.questStart = true

	return questOperate
end

-- 使用采集物
function PlayerInfo:RobotUseGameObject(questId, indx)
	local config = tb_quest[questId]
	local stepParams = config.targetsPosition[indx]
	
	local questOperate = {}
	questOperate.type 		= config.targets[indx][ 1 ]
	questOperate.mapid		= stepParams[ 2 ]
	questOperate.x			= stepParams[ 3 ]
	questOperate.y			= stepParams[ 4 ]
	questOperate.objcet_id	= stepParams[ 5 ]
	questOperate.questId = questId
	
	-- 寻路
	self.questStart = true
	
	return questOperate
end

-- 杀怪
function PlayerInfo:RobotKillMonster(questId, indx)
	local config = tb_quest[questId]
	local stepParams = config.targetsPosition[indx]
	
	local questOperate = {}
	questOperate.type 		= config.targets[indx][ 1 ]
	questOperate.objcet_id	= config.targets[indx][ 2 ]
	questOperate.mapid		= stepParams[ 2 ]
	questOperate.x			= stepParams[ 3 ]
	questOperate.y			= stepParams[ 4 ]
	questOperate.questId = questId
	
	-- 判断任务是否完成
	questOperate.IsFinishMethod = function()
		local vist = not self.quest:GetQuestIndxById(questId)
		if not vist then
			vist = self.quest:CheckQuestIsFinished(questId)
			if vist then
				self:AutoSendFinishQuest(questId)
			end
		end
		return vist
	end
	
	-- 寻路
	self.questStart = true
	
	return questOperate
end

-- 使用物品
function PlayerInfo:RobotUseItem(questId, indx)
	local config = tb_quest[questId]
	local stepParams = config.targetsPosition[indx]
		
	local questOperate = {}
	questOperate.type = config.targets[indx][ 1 ]
	questOperate.questId = questId
	
	local entry = config.targets[indx][ 2 ]
	local item_guid = self.itemMgr:GetItemGuidByEntry(entry)

	questOperate.callback 	= function()
		if item_guid then
			outFmtDebug("call_bag_item_user entry = %d, item_guid = %s, questId = %d", entry, item_guid, questId)
			self:call_bag_item_user (item_guid, 1)
			-- 发送完成任务命令
			self:AutoSendFinishQuest(questId)
		else
			outFmtDebug("not find entry %d in bag", entry)
		end
	end
	
	return questOperate
end

-- 穿戴装备
function PlayerInfo:RobotSuit(questId, indx)
	local config = tb_quest[questId]
	local stepParams = config.targetsPosition[indx]
	
	local questOperate = {}
	questOperate.type = config.targets[indx][ 1 ]
	questOperate.questId = questId
	
	local suitPos = config.targets[indx][ 2 ]
	local suitEntry = config.targets[indx][ 3 ]
	local entry, src_pos = self.itemMgr:GetSuitEntryAndBagPosBySuitPos(suitPos, suitEntry)
	questOperate.callback = function()
		if src_pos then
			local dst_pos = tb_item_template[entry].pos
			outFmtDebug("call_bag_exchange_pos entry = %d, %d, %d, %d", BAG_TYPE_MAIN_BAG, src_pos, BAG_TYPE_EQUIP, dst_pos)
			self:call_bag_exchange_pos (BAG_TYPE_MAIN_BAG, src_pos, BAG_TYPE_EQUIP, dst_pos)
			-- 发送完成任务命令
			self:AutoSendFinishQuest(questId)
		else
			outFmtDebug("not find suitPos %d, suitEntry %d in bag", suitPos, suitEntry)
		end
	end
	
	return questOperate
end

function PlayerInfo:AutoSendFinishQuest(questId)
	local config = tb_quest[questId]
	-- 发送完成任务命令
	if config.popup ~= 0 then
		local questIndx = self.quest:GetQuestIndxById(questId)
		if questIndx then
			outFmtDebug("	call_pick_quest_reward questIndx = %d", questIndx)
			self:call_pick_quest_reward(questIndx)
		end
	end
end

Quest_Function = {
--	[QUEST_TARGET_TYPE_PLAYER_LEVEL] 		= IQuestPlayerLevel,
--	[QUEST_TARGET_TYPE_PLAYER_FORCE] 		= IQuestPlayerForce,
--	[QUEST_TARGET_TYPE_FACTION] 			= IQuestJoinFaction,
--	[QUEST_TARGET_TYPE_FACTION_DONATION] 	= IQuestFactionDonate,
--	[QUEST_TARGET_TYPE_FACTION_ACTIVITY] 	= IQuestJoinFactionActivity,
--	[QUEST_TARGET_TYPE_FIELD_BOSS] 			= IQuestJoinFieldBoss,
--	[QUEST_TARGET_TYPE_WORLD_BOSS] 			= IQuestJoinWorldBoss,
--	[QUEST_TARGET_TYPE_RESOURCE_INSTANCE] 	= IQuestJoinResourceInstance,
--	[QUEST_TARGET_TYPE_TRIAL_INSTANCE] 		= IQuestJoinTrialInstance,
--	[QUEST_TARGET_TYPE_OWN_DIVINE] 			= IQuestOwnDivine,
	[QUEST_TARGET_TYPE_EQUIP_DIVINE] 		= PlayerInfo.RobotEquipDivine,
--	[QUEST_TARGET_TYPE_STRENGTH_DIVINE] 	= IQuestStrengthDivine,
--	[QUEST_TARGET_TYPE_RAISE_SKILL] 		= IQuestRaiseSkill,
--	[QUEST_TARGET_TYPE_TRAIN_MOUNT] 		= IQuestTrainMount,
--	[QUEST_TARGET_TYPE_RAISE_MOUNT_SKILL] 	= IQuestRaiseMountSkill,
--	[QUEST_TARGET_TYPE_FRIEND_DONATION] 	= IQuestFriendDonate,
--	[QUEST_TARGET_TYPE_STRENGTH_SUIT]		= IQuestStrengthSuit,
--	[QUEST_TARGET_TYPE_STRENGTH_GEM] 		= IQuestRaiseGem,
	[QUEST_TARGET_TYPE_TALK] 				= PlayerInfo.TalkWithNPC,
	[QUEST_TARGET_TYPE_PICK_GAME_OBJECT] 	= PlayerInfo.RobotUseGameObject,
--	[QUEST_TARGET_TYPE_CHECK_GAME_OBJECT] 	= IQuestInspect,
	[QUEST_TARGET_TYPE_KILL_MONSTER] 		= PlayerInfo.RobotKillMonster,
	[QUEST_TARGET_TYPE_USE_ITEM] 			= PlayerInfo.RobotUseItem,
	[QUEST_TARGET_TYPE_SUIT]				= PlayerInfo.RobotSuit,
}