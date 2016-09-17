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
	pkt:delete()
end