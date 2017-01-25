---------------------------------------------------------------------------------
--------------------------以下代码为自动生成，请勿手工改动-----------------------
---------------------------------------------------------------------------------


tb_quest = {
	--  id:int	任务id
	--  type:int	任务类型
	--  chapterName:string	章节名
	--  chapter:int	章节
	--  questName:string	任务名
	--  level:int	需要等级
	--  moduleId:int	需要模块id
	--  targets:array	任务目标
	--  rewards:array	任务奖励
	--  nextid:int	下一个主线任务id
	--  acitveIds:array	额外激活的任务id
	[1] = {id = 1,type = 0,chapterName = "第一章",chapter = 1,questName = "主线1",level = 1,moduleId = 0,targets = {{1,2}},rewards = {},nextid = 10020,acitveIds = {20040,20020},},
	[10020] = {id = 10020,type = 0,chapterName = "第一章",chapter = 1,questName = "主线2",level = 1,moduleId = 0,targets = {{22,2002,4},{4,1,5},{22,2003,4}},rewards = {{{10001,1}},{{10011,1}}},nextid = 10030,acitveIds = {20010,20030},},
	[10030] = {id = 10030,type = 0,chapterName = "第二章",chapter = 2,questName = "主线3",level = 1,moduleId = 0,targets = {{2,1999}},rewards = {{{50001,1}}},nextid = 10040,acitveIds = {},},
	[10040] = {id = 10040,type = 0,chapterName = "第二章",chapter = 2,questName = "主线4",level = 1,moduleId = 0,targets = {{19,1012}},rewards = {{{50001,5}}},nextid = 10050,acitveIds = {},},
	[10050] = {id = 10050,type = 0,chapterName = "第三章",chapter = 3,questName = "主线5",level = 1,moduleId = 0,targets = {{20,8,3}},rewards = {{{50001,6}}},nextid = 10060,acitveIds = {},},
	[10060] = {id = 10060,type = 0,chapterName = "第三章",chapter = 3,questName = "主线6",level = 1,moduleId = 0,targets = {{20,9,1}},rewards = {{{50001,7}}},nextid = 10070,acitveIds = {},},
	[10070] = {id = 10070,type = 0,chapterName = "第四章",chapter = 4,questName = "主线7",level = 1,moduleId = 0,targets = {{8,0,1}},rewards = {{{50001,8}}},nextid = 10080,acitveIds = {},},
	[10080] = {id = 10080,type = 0,chapterName = "第四章",chapter = 4,questName = "主线8",level = 1,moduleId = 0,targets = {{9,1}},rewards = {{{50001,12}}},nextid = 10090,acitveIds = {},},
	[10090] = {id = 10090,type = 0,chapterName = "第五章",chapter = 5,questName = "主线9",level = 1,moduleId = 0,targets = {{13,0,3}},rewards = {{{50001,13}}},nextid = 10100,acitveIds = {},},
	[10100] = {id = 10100,type = 0,chapterName = "第五章",chapter = 5,questName = "主线10",level = 1,moduleId = 0,targets = {{14,3}},rewards = {{{50001,14}}},nextid = 10110,acitveIds = {},},
	[10110] = {id = 10110,type = 0,chapterName = "第五章",chapter = 5,questName = "主线11",level = 1,moduleId = 0,targets = {{15,0,3}},rewards = {{{50001,15}}},nextid = 10120,acitveIds = {},},
	[10120] = {id = 10120,type = 0,chapterName = "第五章",chapter = 5,questName = "主线12",level = 1,moduleId = 0,targets = {{16,1}},rewards = {{{50001,16}}},nextid = 10130,acitveIds = {},},
	[10130] = {id = 10130,type = 0,chapterName = "第五章",chapter = 5,questName = "主线13",level = 1,moduleId = 0,targets = {{17,0,3}},rewards = {{{50001,17}}},nextid = 10140,acitveIds = {},},
	[10140] = {id = 10140,type = 0,chapterName = "第五章",chapter = 5,questName = "主线14",level = 1,moduleId = 0,targets = {{18,0,3}},rewards = {{{50001,18}}},nextid = 10150,acitveIds = {},},
	[10150] = {id = 10150,type = 0,chapterName = "第五章",chapter = 5,questName = "主线15",level = 1,moduleId = 0,targets = {{6,0,1}},rewards = {{{50001,19}}},nextid = 10160,acitveIds = {},},
	[10160] = {id = 10160,type = 0,chapterName = "第五章",chapter = 5,questName = "主线16",level = 1,moduleId = 0,targets = {{7,1}},rewards = {{{50001,20}}},nextid = 10170,acitveIds = {},},
	[10170] = {id = 10170,type = 0,chapterName = "第五章",chapter = 5,questName = "主线17",level = 1,moduleId = 0,targets = {},rewards = {{{50001,21}}},nextid = 0,acitveIds = {},},
	[20010] = {id = 20010,type = 1,chapterName = "",chapter = 0,questName = "支线1",level = 1,moduleId = 0,targets = {{1,6}},rewards = {{{50001,22}}},nextid = 0,acitveIds = {},},
	[20020] = {id = 20020,type = 1,chapterName = "",chapter = 0,questName = "支线2",level = 1,moduleId = 0,targets = {{22,2003,4},{4,1,5},{22,2007,10}},rewards = {{{50001,1},{50002,1}}},nextid = 0,acitveIds = {},},
	[20030] = {id = 20030,type = 1,chapterName = "",chapter = 0,questName = "支线3",level = 1,moduleId = 0,targets = {{1,10}},rewards = {{{50001,1}}},nextid = 0,acitveIds = {},},
	[20040] = {id = 20040,type = 1,chapterName = "",chapter = 0,questName = "支线4",level = 1,moduleId = 0,targets = {{1,12}},rewards = {{{50001,1}}},nextid = 0,acitveIds = {},},
	[20050] = {id = 20050,type = 1,chapterName = "",chapter = 0,questName = "支线5",level = 5,moduleId = 0,targets = {{10,0}},rewards = {{{50001,9}}},nextid = 0,acitveIds = {20060},},
	[20060] = {id = 20060,type = 1,chapterName = "",chapter = 0,questName = "支线6",level = 5,moduleId = 0,targets = {{11,0}},rewards = {{{50001,10}}},nextid = 0,acitveIds = {20070},},
	[20070] = {id = 20070,type = 1,chapterName = "",chapter = 0,questName = "支线7",level = 5,moduleId = 0,targets = {{12,0,3}},rewards = {{{50001,11}}},nextid = 0,acitveIds = {},},
	[20080] = {id = 20080,type = 1,chapterName = "",chapter = 0,questName = "支线8",level = 5,moduleId = 0,targets = {{3}},rewards = {{{50001,2}}},nextid = 0,acitveIds = {20090},},
	[20090] = {id = 20090,type = 1,chapterName = "",chapter = 0,questName = "支线9",level = 5,moduleId = 0,targets = {{4,1,5}},rewards = {{{50001,3}}},nextid = 0,acitveIds = {20100},},
	[20100] = {id = 20100,type = 1,chapterName = "",chapter = 0,questName = "支线10",level = 5,moduleId = 0,targets = {{4,2,5}},rewards = {{{50001,4}}},nextid = 0,acitveIds = {},},
}
