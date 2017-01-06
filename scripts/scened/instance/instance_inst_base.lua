InstanceInstBase = class("InstanceInstBase", Instance_base)

InstanceInstBase.Name = "InstanceInstBase"

InstanceInstBase.Time_Out_Fail_Callback = "instanceFail"

InstanceInstBase.Leave_Callback = "prepareToLeave"

function InstanceInstBase:ctor(  )
	
end

--初始化脚本函数
function InstanceInstBase:OnInitScript(  )
	Instance_base.OnInitScript(self) --调用基类
end


-- 退出倒计时到了准备退出
function InstanceInstBase:prepareToLeave()
	mapLib.ExitInstance(self.ptr)
end


-- 副本失败退出
function InstanceInstBase:instanceFail()
	local state = self.STATE_FAIL
	if self:CheckQuestAfterTargetUpdate() then
		state = self.STATE_FINISH
	end
	self:SetMapState(state)
end

--增加任务
function InstanceInstBase:OnAddQuests(questTable)
	for _, quest in pairs(questTable) do
		local instQuestType = quest[ 1 ]
		if Quest_Func_Table[instQuestType] then
			Quest_Func_Table[instQuestType](self, quest)
		end
	end
end

-- 获得任务空位置
function InstanceInstBase:GetEmptySlot()
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		if self:GetByte(i, 0) == 0 then
			return i
		end
	end
	
	return -1
end


----------------------------------------增加任务 ------------------------------------------
--增加击杀怪物任务
function InstanceInstBase:OnAddKillMonsterQuest(quest)
	if(#quest ~= 3) then
		return
	end
	
	local indx = self:GetEmptySlot()
	
	if indx < 0 then
		return
	end
	
	self:SetByte(indx, 0, quest[ 1 ])
	self:SetByte(indx, 1, quest[ 2 ])
	self:SetUInt16(indx, 1, quest[ 3 ])
end

--增加收集物品任务
function InstanceInstBase:OnAddPickItemQuest(quest)
	
end

--增加激活机关任务
function InstanceInstBase:OnAddActiveMachineQuest(quest)
	
end

--增加守护NPC任务
function InstanceInstBase:OnAddProtectNPCQuest(quest)
	
end

--增加护送NPC任务
function InstanceInstBase:OnAddEscortNPCQuest(quest)
	
end

--增加防守任务
function InstanceInstBase:OnAddDefenseQuest(quest)
	
end

--增加闯关任务
function InstanceInstBase:OnAddBreakThroughQuest(quest)
	
end



--[[
 = 1	-- 击杀怪物
 = 2	-- 收集物品
 = 3	-- 激活机关
 = 4	-- 守护NPC
 = 5	-- 护送NPC
 = 6	-- 防守
 = 7	-- 闯关
]]
Quest_Func_Table = {}
Quest_Func_Table[INSTANCE_QUEST_TYPE_KILL_MONSTER]	= InstanceInstBase.OnAddKillMonsterQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_PICK_ITEM]		= InstanceInstBase.OnAddPickItemQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_ACTIVE_MACHINE]= InstanceInstBase.OnAddActiveMachineQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_PROTECT_NPC]	= InstanceInstBase.OnAddProtectNPCQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_ESCORT_NPC]	= InstanceInstBase.OnAddEscortNPCQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_DEFENSE]		= InstanceInstBase.OnAddDefenseQuest
Quest_Func_Table[INSTANCE_QUEST_TYPE_BREAK_THROUGH]	= InstanceInstBase.OnAddBreakThroughQuest


----------------------------------------任务进度更新情况 ------------------------------------------

-- 一个怪物被玩家杀了
function InstanceInstBase:OneMonsterKilled(entry)
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		if self:GetByte(i, 0) == INSTANCE_QUEST_TYPE_KILL_MONSTER and self:IsFitForQuest(self:GetUInt16(i, 1), entry) then
			local indx = (i - MAP_INT_FIELD_QUESTS_START) / 2
			local prev = self:GetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx)
			self:SetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx, prev + 1)
			return true
		end
	end
	
	return false
end

-- 是否满足这个任务
function InstanceInstBase:IsFitForQuest(dest, entry)
	return dest == entry or dest == 0 and tb_creature_template[entry].monster_type == 0
end


-- 还有几个TODO


----------------------------------------检查任务完成情况 ------------------------------------------

-- 副本时间到了以后或者进度更新后检测任务是否完成
function InstanceInstBase:CheckQuestAfterTargetUpdate(isTimeout)	
	isTimeout = isTimeout or 0
	
	local ret = true
	
	for i = MAP_INT_FIELD_QUESTS_START, MAP_INT_FIELD_QUESTS_END-1, 2 do
		local targetType = self:GetByte(i, 0)
		if targetType > 0 then
			if Quest_Check_Func_Table[targetType] then
				local vist = Quest_Check_Func_Table[targetType](self, i-MAP_INT_FIELD_QUESTS_START, isTimeout)
				if not vist then ret = false end
			end
		end
	end
	
	return ret
end

--检查击杀怪物任务
function InstanceInstBase:OnCheckKillMonsterQuest(indx, isTimeout)
	local offset = MAP_INT_FIELD_QUESTS_START + indx * 2
	local process = self:GetByte(MAP_INT_FIELD_QUESTS_PROCESS_START, indx)
	local target = self:GetByte(offset, 1)
	
	return process >= target
end

--检查收集物品任务
function InstanceInstBase:OnCheckPickItemQuest(indx, isTimeout)
	return false
end

--检查激活机关任务
function InstanceInstBase:OnCheckActiveMachineQuest(indx, isTimeout)
	return false
end

--检查守护NPC任务
function InstanceInstBase:OnCheckProtectNPCQuest(indx, isTimeout)
	return false
end

--检查护送NPC任务
function InstanceInstBase:OnCheckEscortNPCQuest(indx, isTimeout)
	return false
end

--检查防守任务
function InstanceInstBase:OnCheckDefenseQuest(indx, isTimeout)
	return false
end

--检查闯关任务
function InstanceInstBase:OnCheckBreakThroughQuest(indx, isTimeout)
	return false
end

--[[
 = 1	-- 击杀怪物
 = 2	-- 收集物品
 = 3	-- 激活机关
 = 4	-- 守护NPC
 = 5	-- 护送NPC
 = 6	-- 防守
 = 7	-- 闯关
]]
Quest_Check_Func_Table = {}
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_KILL_MONSTER]	= InstanceInstBase.OnCheckKillMonsterQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_PICK_ITEM]		= InstanceInstBase.OnCheckPickItemQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_ACTIVE_MACHINE]= InstanceInstBase.OnCheckActiveMachineQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_PROTECT_NPC]	= InstanceInstBase.OnCheckProtectNPCQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_ESCORT_NPC]	= InstanceInstBase.OnCheckEscortNPCQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_DEFENSE]		= InstanceInstBase.OnCheckDefenseQuest
Quest_Check_Func_Table[INSTANCE_QUEST_TYPE_BREAK_THROUGH]	= InstanceInstBase.OnCheckBreakThroughQuest


--当玩家死亡后触发()
function InstanceInstBase:OnPlayerDeath(player)
	local playerInfo = UnitInfo:new{ptr = player}	
	local timestamp = os.time() + 10
	self:AddTimeOutCallback(self.Leave_Callback, timestamp)
end

-------------------------------------------------------------------------------------------

--当玩家加入后触发
function InstanceInstBase:OnAfterJoinPlayer(player)
	Instance_base.OnAfterJoinPlayer(self, player)
	
	local playerInfo = UnitInfo:new{ptr = player}
	-- 进城修改模式
	playerInfo:ChangeToPeaceModeAfterTeleport()
end

return InstanceInstBase