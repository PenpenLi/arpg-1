
local OpcodeHandlerFuncTable = {}
-- OpcodeHandlerFuncTable [MSG_JUMP_START] = ScenedContext.Hanlde_Jump_Start
-- OpcodeHandlerFuncTable [MSG_JUMP_END] = ScenedContext.Hanlde_Jump_End
--OpcodeHandlerFuncTable [MSG_TELEPORT] = ScenedContext.Hanlde_Teleport
--OpcodeHandlerFuncTable [CMSG_FORCEINTO] = ScenedContext.Handle_ForceInto

OpcodeHandlerFuncTable[CMSG_RIDE_MOUNT] = ScenedContext.Handle_Ride

return OpcodeHandlerFuncTable

