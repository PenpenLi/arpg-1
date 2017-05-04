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
	[1001001] = {id = 1001001,mapid = 2004,name = "第一关",born = {22,22},monsters = {{8001,3,28,39},{8002,3,41,26},{8003,3,27,11},{8004,3,9,26},{8005,3,14,39}},count = 15,is_boss_section = 0,relateId = 2001001,nextId = 1001002,},
	[1001002] = {id = 1001002,mapid = 2004,name = "第二关",born = {22,22},monsters = {{8101,3,28,39},{8102,3,41,26},{8103,3,27,11},{8104,3,9,26},{8105,3,14,39}},count = 15,is_boss_section = 0,relateId = 2001002,nextId = 0,},
	[2001001] = {id = 2001001,mapid = 2004,name = "第一关BOSS",born = {22,22},monsters = {{8801,1,28,39}},count = 1,is_boss_section = 1,relateId = 1001001,nextId = 0,},
	[2001002] = {id = 2001002,mapid = 2004,name = "第二关BOSS",born = {22,22},monsters = {{8802,1,28,39}},count = 1,is_boss_section = 1,relateId = 1001002,nextId = 0,},
}
