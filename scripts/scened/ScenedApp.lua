require('util.functions')
local protocols = require('share.protocols')
local ScenedApp = class('ScenedApp',require('util.app_base'))

function ScenedApp:ctor( )
	super(self)	
	
	--self.objMgr = require('scened.scened_obj_manager').new()
	self.http = require('scened.ScenedHttp').new()
end

function ScenedApp:update( diff )
	if self.http then
		--奔跑吧,http服务
		self.http:update()
	end
	--update函数被子类重写了,只好手工再调用
	self.super.update(self, diff)
end

--发公告
function ScenedApp:SendNotice( id, content, data )
	local data = data or ""
	local content = content or ""
	call_appd_send_notice(id, content, data)
end

--发聊天信息
function ScenedApp:SendChat( c_type, guid, content, to_guid , to_name)
	local to_guid = to_guid or ""
	local to_name = to_name or ""
	call_appd_send_chat(c_type, guid, content, to_guid, to_name)
end

--grid广播包
function ScenedApp:Broadcast(unit, pkt)
	mapLib.Broadcast(unit.ptr, pkt.ptr)
end

return ScenedApp
