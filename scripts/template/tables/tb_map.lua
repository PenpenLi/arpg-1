---------------------------------------------------------------------------------
--------------------------以下代码为自动生成，请勿手工改动-----------------------
---------------------------------------------------------------------------------


tb_map = {
	--  id:int	地图ID
	--  parentid:int	父级地图ID
	--  name:string	地图名称
	--  tele:array	传送到的坐标
	--  levellimit:int	等级限制
	--  type:int	地图类型
	--  inst_type:int	地图副本类型
	--  inst_sub_type:int	地图子类型
	--  is_instance:int	是否副本地图
	--  shadow:int	影子方向
	--  count:int	副本人数
	--  day_limit:int	日限制
	--  week_limit:int	周限制
	--  enter_mask:int	可进入地图掩码
	--  inst_id:array	可进入此地图的副本或活动id
	--  is_cast:int	允许施法
	--  is_PK:int	允许PK
	--  is_jump:int	允许跳跃
	--  is_ride:int	允许骑乘
	--  is_sit:int	允许打坐
	--  rebornX:int	复活点X
	--  rebornY:int	复活点Y
	--  situ:int	是否原地复活
	[1] = {id = 1,parentid = 1,name = "蜀山",tele = {},levellimit = 0,type = 0,inst_type = 0,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 31,inst_id = {},is_cast = 0,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[1001] = {id = 1001,parentid = 1001,name = "凝碧崖",tele = {65,93},levellimit = 0,type = 1,inst_type = 0,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 1,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[1002] = {id = 1002,parentid = 1002,name = "莽苍山",tele = {107,194},levellimit = 0,type = 1,inst_type = 0,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 1,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[1003] = {id = 1003,parentid = 1003,name = "慈云寺",tele = {},levellimit = 0,type = 1,inst_type = 0,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 1,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[1004] = {id = 1004,parentid = 1004,name = "青螺山",tele = {},levellimit = 0,type = 1,inst_type = 0,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 1,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[1005] = {id = 1005,parentid = 1005,name = "华山",tele = {},levellimit = 0,type = 1,inst_type = 0,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 1,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2001] = {id = 2001,parentid = 2001,name = "桃花迷阵",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 0,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2002] = {id = 2002,parentid = 2002,name = "试炼塔野",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 0,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {1},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2003] = {id = 2003,parentid = 2003,name = "VIP副本1",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 1,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2004] = {id = 2004,parentid = 2004,name = "试炼塔",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 2,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2011] = {id = 2011,parentid = 2011,name = "经验副本1",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 4,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2012] = {id = 2012,parentid = 2012,name = "真气副本2",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 4,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2013] = {id = 2013,parentid = 2013,name = "兽灵副本3",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 4,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2014] = {id = 2014,parentid = 2014,name = "银币副本4",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 4,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2015] = {id = 2015,parentid = 2015,name = "宝石副本5",tele = {},levellimit = 0,type = 2,inst_type = 2,inst_sub_type = 4,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2016] = {id = 2016,parentid = 2016,name = "世界BOSS报名",tele = {},levellimit = 0,type = 2,inst_type = 1,inst_sub_type = 0,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[2017] = {id = 2017,parentid = 2017,name = "世界BOSS战斗",tele = {},levellimit = 0,type = 2,inst_type = 1,inst_sub_type = 3,is_instance = 1,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 3,inst_id = {},is_cast = 1,is_PK = 0,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[3001] = {id = 3001,parentid = 3001,name = "斗剑台",tele = {},levellimit = 0,type = 4,inst_type = 1,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 1,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
	[3002] = {id = 3002,parentid = 3002,name = "封魔战场",tele = {},levellimit = 0,type = 4,inst_type = 1,inst_sub_type = 0,is_instance = 0,shadow = 0,count = 0,day_limit = 0,week_limit = 0,enter_mask = 0,inst_id = {},is_cast = 1,is_PK = 1,is_jump = 1,is_ride = 1,is_sit = 1,rebornX = 0,rebornY = 0,situ = 0,},
}
