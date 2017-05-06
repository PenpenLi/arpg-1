---------------------------------------------------------------------------------
--------------------------以下代码为自动生成，请勿手工改动-----------------------
---------------------------------------------------------------------------------


tb_risk_data = {
	--  id:int	ID
	--  mapid:int	地图ID
	--  name:string	关卡名称
	--  born:array	出生位置
	--  monsters:array	刷新怪物
	--  count:int	怪物数量
	--  is_boss_section:int	是否是boss关卡
	--  relateId:int	关联的关卡id
	--  nextId:int	下一个关卡id
	--  itemReward:array	道具数量(金币和经验)/分钟
	--  suitCount:int	分钟/件
	--  dropid:int	装备掉落包id
	[1001001] = {id = 1001001,mapid = 2004,name = "第一关",born = {22,22},monsters = {{8001,3,28,39},{8002,3,41,26},{8003,3,27,11},{8004,3,9,26},{8005,3,14,39}},count = 15,is_boss_section = 0,relateId = 2001001,nextId = 1001002,itemReward = {{3,1000},{104,100}},suitCount = 20,dropid = 2,},
	[1001002] = {id = 1001002,mapid = 2004,name = "第二关",born = {22,22},monsters = {{8006,3,28,39},{8007,3,41,26},{8008,3,27,11},{8009,3,9,26},{8010,3,14,39}},count = 15,is_boss_section = 0,relateId = 2001002,nextId = 1001003,itemReward = {{3,1000},{104,100}},suitCount = 20,dropid = 2,},
	[1001003] = {id = 1001003,mapid = 2004,name = "第三关",born = {22,22},monsters = {{8011,3,28,39},{8012,3,41,26},{8013,3,27,11},{8014,3,9,26},{8015,3,14,39}},count = 15,is_boss_section = 0,relateId = 2001003,nextId = 0,itemReward = {{3,1000},{104,100}},suitCount = 20,dropid = 2,},
	[2001001] = {id = 2001001,mapid = 2004,name = "第一关BOSS",born = {22,22},monsters = {{8900,1,28,39}},count = 1,is_boss_section = 1,relateId = 1001001,nextId = 0,itemReward = {},suitCount = 0,dropid = 0,},
	[2001002] = {id = 2001002,mapid = 2004,name = "第二关BOSS",born = {22,22},monsters = {{8901,1,28,39}},count = 1,is_boss_section = 1,relateId = 1001002,nextId = 0,itemReward = {},suitCount = 0,dropid = 0,},
	[2001003] = {id = 2001003,mapid = 2004,name = "第三关BOSS",born = {22,22},monsters = {{8902,1,28,39}},count = 1,is_boss_section = 1,relateId = 1001003,nextId = 0,itemReward = {},suitCount = 0,dropid = 0,},
}
