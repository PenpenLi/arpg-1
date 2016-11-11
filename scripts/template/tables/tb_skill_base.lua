---------------------------------------------------------------------------------
--------------------------以下代码为自动生成，请勿手工改动-----------------------
---------------------------------------------------------------------------------


tb_skill_base = {
	--  id:int	技能ID
	--  name:string	技能名称
	--  is_initiative:int	技能类型
	--  skill_type:int	技能种类
	--  skill_slot:int	技能槽位
	--  type:int	技能目标类型2
	--  target_type:int	施放范围类型
	--  pre:int	前置技能
	--  is_end:int	连招终结技
	--  follow:array	后续技能
	--  time_change:array	计时切换技能
	--  singleCD:int	冷却时间
	--  groupCD:int	公共CD
	--  self_cd:int	技能自身CD
	--  group:int	技能族
	--  skill_percent:int	技能触发概率万分比
	--  uplevel_id:array	升级ID
	--  magic_type:int	施放消耗类型
	--  nuqi_change:int	怒气变化
	--  attack_mast:array	技能范围掩码
	--  is_fix:int	固定施法方向
	--  isUnitBallistic:int	是否unit弹道
	--  condition_skill:int	激活前置技能
	--  lock_type:int	技能锁定类型
	--  need_save:int	技能CD保存
	[1] = {id = 1,name = "轻功",is_initiative = 11,skill_type = 1,skill_slot = 7,type = 0,target_type = 0,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 10000,groupCD = 958,self_cd = 1000,group = 0,skill_percent = 10000,uplevel_id = {},magic_type = 0,nuqi_change = 0,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 0,need_save = 0,},
	[2] = {id = 2,name = "梯云纵",is_initiative = 11,skill_type = 1,skill_slot = 7,type = 0,target_type = 0,pre = 0,is_end = 0,follow = {},time_change = {2000,4},singleCD = 8000,groupCD = 1250,self_cd = 1000,group = 0,skill_percent = 10000,uplevel_id = {},magic_type = 0,nuqi_change = 0,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 4,lock_type = 0,need_save = 0,},
	[3] = {id = 3,name = "骑乘",is_initiative = 11,skill_type = 1,skill_slot = 8,type = 0,target_type = 0,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 3000,groupCD = 750,self_cd = 750,group = 0,skill_percent = 10000,uplevel_id = {},magic_type = 0,nuqi_change = 0,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 0,need_save = 0,},
	[4] = {id = 4,name = "打坐",is_initiative = 11,skill_type = 1,skill_slot = 9,type = 0,target_type = 0,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 500,groupCD = 500,self_cd = 0,group = 0,skill_percent = 10000,uplevel_id = {},magic_type = 0,nuqi_change = 0,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 0,need_save = 0,},
	[5] = {id = 5,name = "武当剑法一段",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 0,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 1,skill_percent = 10000,uplevel_id = {5,5},magic_type = 0,nuqi_change = 5,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[6] = {id = 6,name = "武当剑法二段",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 0,pre = 5,is_end = 0,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 1,skill_percent = 10000,uplevel_id = {6,6},magic_type = 0,nuqi_change = 5,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[7] = {id = 7,name = "武当剑法三段",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 1,pre = 6,is_end = 1,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 1,skill_percent = 10000,uplevel_id = {7,7},magic_type = 0,nuqi_change = 5,attack_mast = {4294967295,4294967295,4160618495,3791618015,65027587,62},is_fix = 1,isUnitBallistic = 0,condition_skill = 0,lock_type = 0,need_save = 0,},
	[8] = {id = 8,name = "峨眉剑法一段",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 0,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 2,skill_percent = 10000,uplevel_id = {8,8},magic_type = 0,nuqi_change = 0,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[9] = {id = 9,name = "峨眉剑法二段",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 0,pre = 8,is_end = 0,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 2,skill_percent = 10000,uplevel_id = {9,9},magic_type = 0,nuqi_change = 0,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[10] = {id = 10,name = "峨眉剑法三段",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 1,pre = 9,is_end = 1,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 2,skill_percent = 10000,uplevel_id = {10,10},magic_type = 0,nuqi_change = 0,attack_mast = {4294967295,4294967295,4160618495,3791618015,65027587,62},is_fix = 1,isUnitBallistic = 0,condition_skill = 0,lock_type = 0,need_save = 0,},
	[11] = {id = 11,name = "真气剑",is_initiative = 1,skill_type = 1,skill_slot = 2,type = 2,target_type = 2,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 10000,groupCD = 700,self_cd = 10000,group = 0,skill_percent = 10000,uplevel_id = {11,11},magic_type = 0,nuqi_change = 0,attack_mast = {1835232,896,112,3584,29360128,0,14336,0,1792,0,57344,0,469762048},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[12] = {id = 12,name = "真气剑",is_initiative = 1,skill_type = 1,skill_slot = 2,type = 2,target_type = 2,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 10000,groupCD = 700,self_cd = 10000,group = 0,skill_percent = 10000,uplevel_id = {12,12},magic_type = 0,nuqi_change = 0,attack_mast = {1835232,896,112,3584,29360128,0,14336,0,1792,0,57344,0,469762048},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[13] = {id = 13,name = "剑气纵横",is_initiative = 1,skill_type = 1,skill_slot = 3,type = 6,target_type = 1,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 60000,groupCD = 700,self_cd = 60000,group = 0,skill_percent = 10000,uplevel_id = {13,13},magic_type = 0,nuqi_change = 0,attack_mast = {4294967295,4294967295,4160618495,3791618015,65027587,62},is_fix = 1,isUnitBallistic = 0,condition_skill = 0,lock_type = 0,need_save = 0,},
	[14] = {id = 14,name = "剑气纵横",is_initiative = 1,skill_type = 1,skill_slot = 3,type = 6,target_type = 1,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 60000,groupCD = 700,self_cd = 60000,group = 0,skill_percent = 10000,uplevel_id = {14,14},magic_type = 0,nuqi_change = 0,attack_mast = {4294967295,4294967295,4160618495,3791618015,65027587,62},is_fix = 1,isUnitBallistic = 0,condition_skill = 0,lock_type = 0,need_save = 0,},
	[1001] = {id = 1001,name = "玄冥神掌",is_initiative = 1,skill_type = 2,skill_slot = 4,type = 2,target_type = 3,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 15000,groupCD = 1000,self_cd = 15000,group = 0,skill_percent = 10000,uplevel_id = {1001,1001},magic_type = 0,nuqi_change = 0,attack_mast = {1835233,1984,508,16256,267911168,0,130816,0,32752,0,1048064,0,2130706432},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[1002] = {id = 1002,name = "龙象般若功",is_initiative = 1,skill_type = 2,skill_slot = 5,type = 2,target_type = 4,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 20000,groupCD = 1000,self_cd = 20000,group = 0,skill_percent = 10000,uplevel_id = {1002,1002},magic_type = 0,nuqi_change = 0,attack_mast = {4294967295,4294967295,4160618495,3791618015,65027587,62},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[10001] = {id = 10001,name = "怪物技能1",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 0,pre = 0,is_end = 0,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 0,skill_percent = 10000,uplevel_id = {5,5},magic_type = 0,nuqi_change = 5,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
	[10002] = {id = 10002,name = "怪物技能2",is_initiative = 1,skill_type = 1,skill_slot = 1,type = 2,target_type = 0,pre = 5,is_end = 0,follow = {},time_change = {},singleCD = 400,groupCD = 400,self_cd = 400,group = 0,skill_percent = 10000,uplevel_id = {6,6},magic_type = 0,nuqi_change = 5,attack_mast = {},is_fix = 0,isUnitBallistic = 0,condition_skill = 0,lock_type = 1,need_save = 0,},
}
