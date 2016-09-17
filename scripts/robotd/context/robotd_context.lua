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
	self:ActionInit()
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
	if(self:GetGMLevel() == 0)then
		--没有权限就不用发了
		--assert(false)
		return false
	end
	
	self:call_chat(CHAT_TYPE_WORLD , "" ,comm)
end
function PlayerInfo:GetKuafuJoin()
	return self:GetFlags(PLAYER_FLAG_KUAFU_JOIN)
end

require("robotd.context.robotd_context_unit_mgr")
require("robotd.context.robotd_context_hanlder")
require("robotd.context.robotd_context_action_mgr")

return PlayerInfo
