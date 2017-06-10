---------------------------------------------------------------------------------
--------------------------以下代码为自动生成，请勿手工改动-----------------------
---------------------------------------------------------------------------------


tb_quest = {
	--  id:int	任务id
	--  type:int	任务类型
	--  belongSet:int	所属日常任务集合
	--  belongLvRangeId:int	所属日常任务等级段ID
	--  chapterName:string	章节名
	--  chapter:int	章节
	--  questName:string	任务名
	--  level:int	需要等级
	--  start:int	是否是初始任务
	--  chapterLast:int	章节最后一个任务
	--  moduleId:int	需要模块id
	--  targetsPosition:array	任务目标位置
	--  targets:array	任务目标
	--  popup:int	奖励弹出方式
	--  rewards:array	任务奖励
	--  nextid:int	下一个主线任务id
	--  acitveIds:array	额外激活的任务id
	--  guide_id:int	开启引导
	--  afterAccept:array	任务接取后需要做的事
	--  afterFinish:array	任务完成后需要做的事
	[10101] = {id = 10101,type = 0,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 1,questName = "女王任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,302,7},{2,302,7}},targets = {{55,1402,1},{54,99}},popup = 2,rewards = {{{1403,1}}},nextid = 10102,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[10102] = {id = 10102,type = 0,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 1,questName = "女王任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,302,7},{2,302,7}},targets = {{55,1402,10},{54,500}},popup = 2,rewards = {{{1406,1}}},nextid = 10103,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[10103] = {id = 10103,type = 0,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 1,questName = "女王任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{55,1406,99}},popup = 2,rewards = {{{1406,3}}},nextid = 10104,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[10104] = {id = 10104,type = 0,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 1,questName = "女王任务",level = 1,start = 0,chapterLast = 1,moduleId = 0,targetsPosition = {},targets = {{1,101}},popup = 2,rewards = {{{1404,1}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20101] = {id = 20101,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "击杀小怪",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{10}},targets = {{22,0,5}},popup = 0,rewards = {},nextid = 0,acitveIds = {20102},guide_id = 1,afterAccept = {},afterFinish = {},},
	[20102] = {id = 20102,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "收集礼物",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{50,1001001}},popup = 0,rewards = {{{104,500}}},nextid = 0,acitveIds = {20103},guide_id = 2,afterAccept = {},afterFinish = {},},
	[20103] = {id = 20103,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "击杀小怪",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{55,1402,1}},popup = 0,rewards = {{{104,500}}},nextid = 0,acitveIds = {20104},guide_id = 3,afterAccept = {},afterFinish = {},},
	[20104] = {id = 20104,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "击杀小怪",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{10}},targets = {{22,0,5}},popup = 0,rewards = {},nextid = 0,acitveIds = {20105},guide_id = 4,afterAccept = {},afterFinish = {},},
	[20105] = {id = 20105,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "打败BOSS",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{50,1001002}},popup = 2,rewards = {{{2001,1},{104,500}}},nextid = 0,acitveIds = {20106},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20106] = {id = 20106,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "装备武器",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,102,2}},targets = {{24,1,0}},popup = 2,rewards = {{{104,500}}},nextid = 0,acitveIds = {20107},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20107] = {id = 20107,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "收集礼物",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{56,1402,5}},popup = 2,rewards = {{{104,500}}},nextid = 0,acitveIds = {20108},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20108] = {id = 20108,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "强化装备",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,206,1}},targets = {{17,0,1}},popup = 2,rewards = {{{104,500}}},nextid = 0,acitveIds = {20109},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20109] = {id = 20109,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "装备熔炼",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{1,8}},popup = 0,rewards = {{{1401,6}}},nextid = 0,acitveIds = {20110},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20110] = {id = 20110,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "装备熔炼",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,102,3}},targets = {{51,1}},popup = 2,rewards = {{{104,500}}},nextid = 0,acitveIds = {20111},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20111] = {id = 20111,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "装备神兵",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{1,10}},popup = 0,rewards = {{{104,500},{201,10}}},nextid = 0,acitveIds = {20112},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20112] = {id = 20112,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "装备神兵",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,202,0}},targets = {{11,1}},popup = 2,rewards = {{{104,300},{211,5}}},nextid = 0,acitveIds = {20113},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20113] = {id = 20113,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "神兵升阶",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,202,0}},targets = {{12,0,1}},popup = 2,rewards = {{{104,500}}},nextid = 0,acitveIds = {20114},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20114] = {id = 20114,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "打败BOSS",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{58,1}},popup = 2,rewards = {{{1401,11}}},nextid = 0,acitveIds = {20115},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20115] = {id = 20115,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "打败BOSS",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {},targets = {{1,12}},popup = 0,rewards = {{{1401,11}}},nextid = 0,acitveIds = {20116},guide_id = 0,afterAccept = {},afterFinish = {},},
	[20116] = {id = 20116,type = 1,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "斗剑比试",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{2,503,1}},targets = {{43,1}},popup = 2,rewards = {{{104,500}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[30001] = {id = 30001,type = 4,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "环任务",level = 100,start = 1,chapterLast = 0,moduleId = 0,targetsPosition = {{3,1,118,146,6008}},targets = {{19,6008}},popup = 0,rewards = {},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[30002] = {id = 30002,type = 4,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "环任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{3,1001,133,148,6005}},targets = {{19,6005}},popup = 0,rewards = {},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[30003] = {id = 30003,type = 4,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "环任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{1,1001,185,98}},targets = {{22,7001,4}},popup = 0,rewards = {},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[30004] = {id = 30004,type = 4,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "环任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{4,1001,134,109,20}},targets = {{20,20,3}},popup = 0,rewards = {},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[30005] = {id = 30005,type = 4,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "环任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{1,1001,155,30}},targets = {{22,7010,5}},popup = 0,rewards = {},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[30006] = {id = 30006,type = 4,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "环任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{3,1001,135,23,6003}},targets = {{19,6003}},popup = 0,rewards = {},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50001] = {id = 50001,type = 5,belongSet = 0,belongLvRangeId = 0,chapterName = "",chapter = 0,questName = "日常任务",level = 30,start = 1,chapterLast = 0,moduleId = 0,targetsPosition = {{3,1,118,146,6008}},targets = {{19,6008}},popup = 0,rewards = {},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50002] = {id = 50002,type = 5,belongSet = 1,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{3,1001,133,148,6005}},targets = {{19,6005}},popup = 2,rewards = {{{104,30000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50003] = {id = 50003,type = 5,belongSet = 2,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{1,1001,185,98}},targets = {{22,7001,4}},popup = 2,rewards = {{{104,30000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50004] = {id = 50004,type = 5,belongSet = 2,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{4,1001,134,109,20}},targets = {{20,20,3}},popup = 2,rewards = {{{104,30000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50005] = {id = 50005,type = 5,belongSet = 3,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{1,1001,155,30}},targets = {{22,7010,5}},popup = 2,rewards = {{{104,30000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50006] = {id = 50006,type = 5,belongSet = 3,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{6,401,1,1,1201}},targets = {{49,1201,5}},popup = 2,rewards = {{{104,30000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50007] = {id = 50007,type = 5,belongSet = 4,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{6,401,1,1,1201}},targets = {{49,1201,5}},popup = 2,rewards = {{{104,60000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50008] = {id = 50008,type = 5,belongSet = 5,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{6,401,1,1,1201}},targets = {{49,1201,5}},popup = 2,rewards = {{{104,60000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
	[50009] = {id = 50009,type = 5,belongSet = 6,belongLvRangeId = 1,chapterName = "",chapter = 0,questName = "日常任务",level = 1,start = 0,chapterLast = 0,moduleId = 0,targetsPosition = {{6,401,1,1,1201}},targets = {{49,1201,5}},popup = 2,rewards = {{{104,90000}}},nextid = 0,acitveIds = {},guide_id = 0,afterAccept = {},afterFinish = {},},
}
