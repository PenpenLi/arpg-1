require('util.functions')
local protocols = require('share.protocols')

local AppdApp = class('AppdApp',require('util.app_base'))

function AppdApp:ctor( )
	super(self)
	--对象管理器最重要了
	self.objMgr = require('appd.appd_obj_manager').new()

	--应用服开启http监听
	self.http = require('appd.http').new()

	--后台公告
	self.gmNotice = require('appd.gm_notice').new()
	
	--新版数据库接口
	local isPkServer = globalGameConfig:IsPKServer()
	if not isPkServer then
		self.dbAccess = require('appd.appd_mongo_db').new(getCXXGlobalPtr('MongoWrap'),getCXXGlobalPtr('AsyncMongoDB'))
	else
	end

	--1s一次的心跳
	self.cron:every(1,function ( )
		--后台公告心跳
		self.gmNotice:update()
	end)
	
	self:InitCorn()
end

function AppdApp:update( diff )
	if self.http then
		--奔跑吧,http服务
		self.http:update()
	end
	--update函数被子类重写了,只好手工再调用
	self.super.update(self, diff)
end

-- 定时器初始化
function AppdApp:InitCorn()
	--如果是pk服，下面的都不需要了
	if(globalGameConfig:IsPKServer())then
		return
	end
	
	--0点更新活动定时器
	self.cron:addCron("更新限时活动",'0 0 * * *',function() GetTodayLimitActivityVersion() end)
	
	--0点重置
	self.cron:addCron("0点重置",'0 * * * *',function() 
		self.objMgr:foreachAllPlayer(function(player)	
			player:DoResetDaily()
		end)
	end)
	
	--每隔5s检测下失效物品
	self.cron:every("失效物品检测",5,function()
		self.objMgr:foreachAllPlayer(function(player)	
			local itemMgr = player:getItemMgr()
			if itemMgr then itemMgr:delFailTimeItem() end
		end)		
	end)
	--每隔5min刷新好友信息
	self.cron:every("好友信息刷新",300,function()
		self.objMgr:foreachAllPlayer(function(player)	
			player:RefreshFriendInfo()
		end)
	end)


end

--全服发送通知包
function AppdApp:CallOptResult(typ, reason, data)
	if type(data) == 'table' then
		data = string.join(',', data)
	else
		data = tostring(data) or ''
	end	
	local pkt = protocols.pack_operation_failed(typ, reason, data)
	self:Broadcast(pkt)
	pkt:delete()
end

--发公告
function AppdApp:SendNotice( id, content, data )
	local data = data or ""
	local content = content or ""
	local pkt = protocols.pack_chat_notice(id, content, data)
	self:Broadcast(pkt)
	pkt:delete()
end

--广播包
function AppdApp:Broadcast(pkt)
	self.objMgr:foreachAllPlayer(function(player)
		player:SendPacket(pkt)
	end)
end

return AppdApp
