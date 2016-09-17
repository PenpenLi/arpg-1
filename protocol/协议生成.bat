@set root_path=%~dp0

@set tool_exe=%root_path%\CodeBuilder\GZCodeBuilder.exe
@set protocol_dir=%root_path%
@set server_path=%root_path%\..\..\
@set server_net=%server_path%\src\svrcore\protocol
@set robot_net=%server_path%\src\robotd\handler
@set w_server_net=%server_path%\src\logind\world
@set lua_h_dir=%server_path%\contrib\scripts\share


@echo 生成服务端c代码
%tool_exe% -f %protocol_dir%\Cow.Msg -t %server_net% -o %server_net%
@echo 生成服务端世界服协议c代码
%tool_exe% -f %protocol_dir%\proto.msg -t %w_server_net% -o %w_server_net%
@echo 生成lua代码
%tool_exe% -f %protocol_dir%\Cow.Msg -t %lua_h_dir% -o %lua_h_dir%
@echo 生成机器人协议
%tool_exe% -f %protocol_dir%\Cow.Msg -t %robot_net% -o %robot_net%

pause