local Packet = require 'util.packet'

--通知应用服发公告
function call_appd_send_notice( id, content, data )
	local pkt = Packet.new(INTERNAL_OPT_NOTICE)
	pkt:writeU32(id)
	pkt:writeUTF(content)
	pkt:writeUTF(data)
	app:sendToAppd(pkt)
	pkt:delete()
end

--通知应用服发送聊天信息
function call_appd_send_chat(c_type, guid, content, to_guid, to_name)
	local pkt = Packet.new(INTERNAL_OPT_CHAT)
	pkt:writeByte(c_type)
	pkt:writeUTF(guid)
	pkt:writeUTF(content)
	pkt:writeUTF(to_guid)
	pkt:writeUTF(to_name)
	app:sendToAppd(pkt)
	pkt:delete()
end


-- 通知应用服加道具
function call_appd_add_items(guid, itemDict, logtype)
	local pkt = Packet.new(INTERNAL_OPT_ADD_ITEMS)
	pkt:writeUTF(guid)
	pkt:writeU16(#itemDict)
	for i = 1, #itemDict do
		local config = itemDict[ i ]
		pkt:writeU32(config[ 1 ])
		pkt:writeU32(config[ 2 ])
	end
	pkt:writeByte(logtype)
	app:sendToAppd(pkt)
	pkt:delete()
end


-- 通知登录服 跨服数据
function call_scene_login_to_kuafu_back(login_fd, guid)
	local pkt = Packet.new(INTERNAL_OPT_KUAFU_BACK)
	pkt:writeUTF(guid)
	app:sendToConnection(login_fd, pkt)
	pkt:delete()
end