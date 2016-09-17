#类型名称，注释

#
null_action,both,0,/*无效动作*/,STATUS_NEVER,False

#
ping_pong,both,1,/*测试连接状态*/,STATUS_NEVER,False

#
forced_into,c2s,2,/*踢掉在线的准备强制登陆*/,STATUS_NEVER,False

#
get_session,c2s,3,/*获得Session对象*/,STATUS_NEVER,False
	sessionkey,String,False,/**/
	account,String,False,/*玩家id*/
	version,String,False,/*版本*/

#
route_trace,both,4,/*网关服数据包路由测试*/,STATUS_NEVER,False
	val,String,False,/**/

#
write_client_log,c2s,5,/*记录客户端日志*/,STATUS_NEVER,False
	type,uint32,False,/*类型*/
	uid,String,False,/*uid*/
	guid,String,False,/*guid*/
	log,String,False,/*内容*/

#
operation_failed,s2c,6,/*操作失败*/,STATUS_NEVER,False
	type,uint16,False,/*操作类型*/
	reason,uint16,False,/*失败原因*/
	data,String,False,/*预留参数*/

#
sync_mstime,both,7,/*同步时间*/,STATUS_LOGGEDIN,False
	mstime_now,uint32,False,/*服务器运行的毫秒数*/
	time_now,uint32,False,/*自然时间*/
	open_time,uint32,False,/*自然时间的服务器启动时间*/

#对象更新
ud_object,s2c,8,/*对象更新*/,STATUS_NEVER,True

#对象更新控制协议
ud_control,c2s,9,/*对象更新控制协议*/,STATUS_NEVER,False

#对象更新控制协议结果
ud_control_result,s2c,10,/*对象更新控制协议结果*/,STATUS_NEVER,True

#GRID的对象更新
grid_ud_object,s2c,11,/*GRID的对象更新*/,STATUS_NEVER,True

#
versions_requirements,both,12,/*版本需求*/,STATUS_NEVER,False
	versions,String,False,/**/
	comment,String,False,/**/
	create_time,uint32,False,/**/

#匹配结果
macthing_result,s2c,13,/*匹配结果*/,STATUS_NEVERSTATUS_NEVER,False
	info,macthing_info,False,/*匹配信息结构体*/

#游戏服转发送给世界服
transpond_to_world,c2s,14,/*游戏服转发送给世界服*/,STATUS_NEVER,False
	pkt,ByteArray,False,/**/
	guid,String,False,/*玩家GUID*/

#世界服发给游戏服转发到客户端
send_to_client,s2c,15,/*世界服发给游戏服转发到客户端*/,STATUS_NEVER,False
	pkt,ByteArray,False,/**/
	guid,String,False,/*玩家GUID*/

#添加监听
add_watch,c2s,16,/*添加监听*/,STATUS_NEVER,False
	guid,String,False,/*要监听GUID*/

#删除监听
delete_watch,c2s,17,/*删除监听*/,STATUS_NEVER,False
	guid,String,False,/*要监听GUID*/


world_gm_command,c2s,18,/*GM命令*/,STATUS_NEVER,False
	gm_commands,String,False,/*字符串string*/
