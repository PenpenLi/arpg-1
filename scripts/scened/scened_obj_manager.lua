local ObjectManager = require('util.object_manager')
local ScenedObjectManager = class('ScenedObjectManager', ObjectManager)

function ScenedObjectManager:ctor()
	--binlog对象对照类型前缀索引
	
	self.binlogTypes = {}
	
	--self.binlogTypes[guidMgr.ObjectTypeUnit] = ScenedContext --生物

	super(self)
end

return ScenedObjectManager
