local ActionBase = require('robotd.action.action')
local ActionScenedPathfinding = class('ActionScenedPathfinding', ActionBase)

--获取类型
function ActionScenedPathfinding:GetType()
	return ROBOT_ACTION_TYPE_SCENED
end

--初始化变量
function ActionScenedPathfinding:Initialize(mapid, x, y)
	self.to_mapid = mapid
	self.to_x = x
	self.to_y = y
	
end

--获取类型名
function ActionScenedPathfinding:GetName()
	return 'ActionScenedPathfinding'
end

--心跳
function ActionScenedPathfinding:Update(diff)
	--精灵对象还没加入地图
	if(self.player:GetMapID() == 0)then
		return true
	end
	local x,y = self.player:GetPos()
	local mapid = self.player:GetMapID()
	--同图寻路
	if(mapid == self.to_mapid)then
		if(math.floor(x) == self.to_x and math.floor(y) == self.to_y)then
			return false, 1
		end
		--如果是障碍点
		local is_canRun = mapLib.IsCanRun(self.to_mapid, self.to_x, self.to_y)
		if(is_canRun == false)then
			outFmtDebug("ActionScenedPathfinding:Update create pos can't run %u %u %u", self.to_mapid, self.to_x, self.to_y)
			local pos_tab = mapLib.RandomPos(self.to_mapid,1, self.to_x, self.to_y,4)
			is_canRun = mapLib.IsCanRun(self.to_mapid,pos_tab[1].x,pos_tab[1].y)
			if(is_canRun)then
				self.to_x = pos_tab[1].x
				self.to_y = pos_tab[1].y
			end
		end

		self:PushAction('robotd.action.scened.action_scened_goto', self.to_mapid, self.to_x, self.to_y)
		return true
	end
	
	--通天塔特殊处理
	if(IsTongTianTaMap(mapid) == true or IsTongTianTaMap(self.to_mapid) == true)then
		--从外面进入通天塔
		if(IsTongTianTaMap(mapid) == false)then
			local temp_map = map_limit_template.getTableById(self.to_mapid)
			if(temp_map ~= nil)then
				--outFmtInfo('===============ActionScenedPathfinding:Goto TongTianTa Template Pass')
				self.player:call_teleport(self.to_mapid ,temp_map.reborn_x ,temp_map.reborn_y ,"" ,1)
				self:SetWaitTimeInterval(1000)
			end
			return true
		end

		--从通天塔里出去,为啥不是退出副本而是传回长安？
		if(IsTongTianTaMap(self.to_mapid) == false)then
			--outFmtInfo('===============ActionScenedPathfinding:Exit TongTianTa')
			local temp_map = map_limit_template.getTableById(ZHUCHENG_DITU_ID)
			if(temp_map ~= nil)then
				--outFmtInfo('===============ActionScenedPathfinding:Goto TongTianTa Template Pass')
				self.player:call_teleport(ZHUCHENG_DITU_ID ,temp_map.reborn_x ,temp_map.reborn_y ,"" ,1)
				self:SetWaitTimeInterval(2000)
				return true
			end
		end
	end

	--其他副本的退出处理
	if(bossInfo[toint(mapid)] ~= nil and bossInfo[toint(self.to_mapid)] == nil)then
		self.player:call_instance_exit()
		self:SetWaitTimeInterval(2000)
		return true
	end

	--今晚八点半的退出
	if(toint(mapid) == KUAFU_MILLION_WAR_MAPID)then
		self.player:call_instance_exit()
		self:SetWaitTimeInterval(2000)
		return true
	end

	--outFmtInfo('===============ActionScenedPathfinding:no TongTianTa')
	--跨图寻路,先找到传送点，然后使用游戏对象
	local tele_pos = self:FindTeleObject()
	if(tele_pos == nil)then
		outFmtInfo('ActionScenedPathfinding:Update tele_pos == nil %u  %u', self.player:GetMapID(), self.to_mapid)
		return false, 2
	end
	
	self:PushAction('robotd.action.scened.action_scened_use_game_object', tele_pos.objcet_id, tele_pos.mapid, tele_pos.x, tele_pos.y)
	
	return true
end

--寻找下一个要去的地图传送点
function ActionScenedPathfinding:FindTeleObject()	
	--当前地图所有的传送点
	local tele_pos = map_object_tele_pos[self.player:GetMapID()]
	--已经寻过的地图
	self.old_map = {}
	for	i, v in ipairs(tele_pos) do		
		if(self:IsToMapObject(v))then
			return v
		end
	end
	return nil
end

function ActionScenedPathfinding:IsToMapObject(temp)
	if(temp.to_mapid == self.to_mapid)then
		return true
	end
	local node = map_object_tele_pos[temp.to_mapid]	
	if(not node)then
		outFmtInfo('ActionScenedPathfinding:IsToMapObject nod is nil ,temp_to_mapid: %u self_to_map:%u', temp.to_mapid, self.to_mapid)
	end
	assert(node)
	for	i, v in ipairs(node) do
		--不等于过来的传送点，还没走过的路
		if(v.to_mapid ~= temp.mapid	and self.old_map[temp.mapid] == nil )then
			self.old_map[temp.mapid] = temp.mapid
			if(self:IsToMapObject(v))then	
				return true
			end
		end
		self.old_map[temp.mapid] = nil
	end
	return false
end

return ActionScenedPathfinding
