--世界变量binlog
local GlobalCounter = class('GlobalCounter', assert(BinLogObject))

function GlobalCounter:ctor( )
end

--获取全服银子数量
function GlobalCounter:GetAllPlayerMoney()
	return self:GetDouble(GLOBALCOUNTER_INT_FIELD_ALL_SILVER)
end

--设置全服银子数量
function GlobalCounter:SetAllPlayerMoney(val)
	self:SetDouble(GLOBALCOUNTER_INT_FIELD_ALL_SILVER, val)
end

return GlobalCounter