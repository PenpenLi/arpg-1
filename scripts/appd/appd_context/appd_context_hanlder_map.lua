--函数包路由表
local hanlders = {}

hanlders[CMSG_LIMIT_ACTIVITY_RECEIVE] = PlayerInfo.Hanlde_Limit_Activity_Receive
hanlders[CMSG_BAG_EXTENSION] = PlayerInfo.Hanlde_Bag_Extension
hanlders[CMSG_WAREHOUSE_SAVE_MONEY] = PlayerInfo.Hanlde_Warehouse_Save_Money
hanlders[CMSG_WAREHOUSE_TAKE_MONEY] = PlayerInfo.Hanlde_Warehouse_Take_Money
hanlders[CMSG_RECEIVE_GIFT_PACKS] = PlayerInfo.Hanlde_Receive_Gift_Packs
hanlders[CMSG_QUERY_PLAYER_INFO] = PlayerInfo.Hanlde_Query_Player_Info
hanlders[CMSG_USE_GOLD_OPT] = PlayerInfo.Hanlde_Use_Gold
hanlders[CMSG_BAG_ITEM_USER] = PlayerInfo.Hanlde_Bag_Item_User
hanlders[CMSG_BAG_EXCHANGE_POS] = PlayerInfo.Hanlde_Bag_Exchange_Pos
hanlders[CMSG_BAG_DESTROY] = PlayerInfo.Hanlde_Bag_Destroy
hanlders[CMSG_BAG_ITEM_SPLIT] = PlayerInfo.Hanlde_Bag_Item_Split
hanlders[CMSG_NPC_GET_GOODS_LIST] = PlayerInfo.Hanlde_Npc_Get_Goods_List
hanlders[CMSG_STORE_BUY] = PlayerInfo.Handle_Store_Buy
hanlders[CMSG_NPC_SELL] = PlayerInfo.Hanlde_Npc_Sell
hanlders[CMSG_NPC_REPURCHASE] = PlayerInfo.Hanlde_Npc_Rrpurchase
hanlders[MSG_CHAT_NOTICE] = PlayerInfo.Handle_Chat_Notice
hanlders[MSG_CHAT_HORN] = PlayerInfo.Handle_Chat_Horn
hanlders[MSG_CHAT_WHISPER] = PlayerInfo.Handle_Chat_Whisper
hanlders[MSG_CHAT_WORLD] = PlayerInfo.Handle_Chat_World

hanlders[CMSG_MALL_BUY] = PlayerInfo.Handle_Mall_Buy

hanlders[CMSG_GOLD_RESPAWN] = PlayerInfo.Handle_Gold_Respawn

hanlders[CMSG_STRENGTH] = PlayerInfo.Handle_Strength
hanlders[CMSG_CREATE_FACTION] = PlayerInfo.Handle_Faction_Create
hanlders[CMSG_FACTION_UPGRADE] = PlayerInfo.Handle_Faction_Upgrade
hanlders[CMSG_FACTION_JOIN] = PlayerInfo.Hanlde_Faction_Apply
hanlders[CMSG_RAISE_BASE_SPELL] = PlayerInfo.Handle_Raise_BaseSpell
hanlders[CMSG_UPGRADE_ANGER_SPELL] = PlayerInfo.Handle_Upgrade_AngleSpell

hanlders[CMSG_RAISE_MOUNT] = PlayerInfo.Handle_Raise_Mount
hanlders[CMSG_UPGRADE_MOUNT] = PlayerInfo.Handle_Upgrade_Mount
hanlders[CMSG_UPGRADE_MOUNT_ONE_STEP] = PlayerInfo.Handle_Upgrade_Mount_One_Step
hanlders[CMSG_ILLUSION_MOUNT_ACTIVE] = PlayerInfo.Handle_Illusion_Active
hanlders[CMSG_ILLUSION_MOUNT] = PlayerInfo.Handle_Illusion

hanlders[CMSG_STRENGTH] = PlayerInfo.strength
hanlders[CMSG_GEM] = PlayerInfo.gem

hanlders[CMSG_DIVINE_ACTIVE] = PlayerInfo.Handle_Divine_Active
hanlders[CMSG_DIVINE_UPLEV] = PlayerInfo.Handle_Divine_UpLev
hanlders[CMSG_DIVINE_SWITCH] = PlayerInfo.Handle_Divine_Switch


hanlders[CMSG_SWEEP_VIP_INSTANCE] = PlayerInfo.Handle_Sweep_Vip_Instance

hanlders[CMSG_HANG_UP] = PlayerInfo.Handle_Hang_Up

hanlders[CMSG_HANG_UP_SETTING] = PlayerInfo.Handle_Hang_Up_Setting

hanlders[CMSG_SWEEP_TRIAL_INSTANCE] = PlayerInfo.Handle_Sweep_Trial

hanlders[CMSG_RESET_TRIAL_INSTANCE] = PlayerInfo.Handle_Reset_Trial 

hanlders[CMSG_SOCIAL_ADD_FRIEND] = PlayerInfo.Handle_Add_Friend 
hanlders[CMSG_SOCIAL_SUREADD_FRIEND] = PlayerInfo.Handle_Sure_Add_Friend
hanlders[CMSG_SOCIAL_GIFT_FRIEND] = PlayerInfo.Handle_Gift_Friend
hanlders[CMSG_SOCIAL_RECOMMEND_FRIEND] = PlayerInfo.Handle_Recommend_Friend
hanlders[CMSG_SOCIAL_REVENGE_ENEMY] = PlayerInfo.Handle_Revenge_Enemy
hanlders[CMSG_SOCIAL_DEL_FRIEND] = PlayerInfo.Handle_Remove_Friend


return hanlders
