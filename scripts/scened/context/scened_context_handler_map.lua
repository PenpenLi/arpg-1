
local OpcodeHandlerFuncTable = {}
OpcodeHandlerFuncTable [CMSG_JUMP_START] = ScenedContext.Hanlde_Jump_Start
-- OpcodeHandlerFuncTable [MSG_JUMP_END] = ScenedContext.Hanlde_Jump_End
--OpcodeHandlerFuncTable [MSG_TELEPORT] = ScenedContext.Hanlde_Teleport
OpcodeHandlerFuncTable [CMSG_FORCEINTO] = ScenedContext.Handle_ForceInto

OpcodeHandlerFuncTable[CMSG_RIDE_MOUNT] 		= ScenedContext.Handle_Ride
OpcodeHandlerFuncTable[CMSG_CHANGE_BATTLE_MODE] = ScenedContext.Hanlde_Change_Battle_Mode

OpcodeHandlerFuncTable[CMSG_ENTER_VIP_INSTANCE] = ScenedContext.Hanlde_Enter_VIP_Instance

OpcodeHandlerFuncTable[CMSG_ENTER_TRIAL_INSTANCE] = ScenedContext.Hanlde_Enter_Trial_Instance

OpcodeHandlerFuncTable[CMSG_TELEPORT_MAIN_CITY] = ScenedContext.Hanlde_Teleport_Main_City




return OpcodeHandlerFuncTable