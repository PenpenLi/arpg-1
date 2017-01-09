
local OpcodeHandlerFuncTable = {}
OpcodeHandlerFuncTable [CMSG_JUMP_START] = ScenedContext.Hanlde_Jump_Start
-- OpcodeHandlerFuncTable [MSG_JUMP_END] = ScenedContext.Hanlde_Jump_End
-- OpcodeHandlerFuncTable [MSG_TELEPORT] = ScenedContext.Hanlde_Teleport
OpcodeHandlerFuncTable [CMSG_FORCEINTO] = ScenedContext.Handle_ForceInto

OpcodeHandlerFuncTable[CMSG_RIDE_MOUNT] 		= ScenedContext.Handle_Ride
OpcodeHandlerFuncTable[CMSG_CHANGE_BATTLE_MODE] = ScenedContext.Hanlde_Change_Battle_Mode

OpcodeHandlerFuncTable[CMSG_ENTER_VIP_INSTANCE] = ScenedContext.Hanlde_Enter_VIP_Instance

OpcodeHandlerFuncTable[CMSG_ENTER_TRIAL_INSTANCE] = ScenedContext.Hanlde_Enter_Trial_Instance

OpcodeHandlerFuncTable[CMSG_TELEPORT_MAIN_CITY] = ScenedContext.Hanlde_Teleport_Main_City

OpcodeHandlerFuncTable[CMSG_USE_BROADCAST_GAMEOBJECT] = ScenedContext.Handle_Use_Broadcast_gameobject

OpcodeHandlerFuncTable[CMSG_WORLD_BOSS_FIGHT] = ScenedContext.Handle_World_Boss_Fight

OpcodeHandlerFuncTable[CMSG_ROLL_WORLD_BOSS_TREASURE] = ScenedContext.Handle_Roll_WorldBoss_Treasure

OpcodeHandlerFuncTable[CMSG_RES_INSTANCE_ENTER] = ScenedContext.Hanlde_Enter_Res_Instance

OpcodeHandlerFuncTable[CMSG_CHANGE_LINE] = ScenedContext.Hanlde_Change_Line


return OpcodeHandlerFuncTable