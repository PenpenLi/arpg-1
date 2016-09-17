--------------------------------------------------------------------------------------------------
--BinLog封装
require ('util.functions')

local BinLogObject = class('BinLogObject')

function BinLogObject:GetBit(index, offset)
	return binLogLib.GetBit(self.ptr, index, offset)
end
	
function BinLogObject:SetBit (index, offset)
	binLogLib.SetBit(self.ptr, index, offset)
end

function BinLogObject:UnSetBit (index, offset)
	binLogLib.UnSetBit(self.ptr, index, offset)
end

function BinLogObject:GetByte (index, offset)
	return binLogLib.GetByte(self.ptr, index, offset)
end

function BinLogObject:AddByte (index, offset, value)
	binLogLib.AddByte(self.ptr, index, offset, value)
end

function BinLogObject:SubByte (index, offset, value)
	binLogLib.SubByte(self.ptr, index, offset, value)
end

function BinLogObject:SetByte (index, offset, value)
	binLogLib.SetByte(self.ptr, index, offset, value)
end

function BinLogObject:GetUInt16 (index, offset)
	return binLogLib.GetUInt16(self.ptr, index, offset)
end

function BinLogObject:AddUInt16 (index, offset, value)
	binLogLib.AddUInt16(self.ptr, index, offset, value)
end

function BinLogObject:SubUInt16 (index, offset, value)
	binLogLib.SubUInt16(self.ptr, index, offset, value)
end

function BinLogObject:SetUInt16 (index, offset, value)
	binLogLib.SetUInt16(self.ptr, index, offset, value)
end

function BinLogObject:GetUInt32 (index)
	return binLogLib.GetUInt32(self.ptr, index)
end

function BinLogObject:SetUInt32 (index, value)
	binLogLib.SetUInt32(self.ptr, index, value)
end

function BinLogObject:AddUInt32 (index, value)
	binLogLib.AddUInt32(self.ptr, index, value)
end

function BinLogObject:SubUInt32 (index, value)
	binLogLib.SubUInt32(self.ptr, index, value)
end

function BinLogObject:GetInt32 (index)
	return binLogLib.GetInt32(self.ptr, index)
end

function BinLogObject:SetInt32 (index, value)
	binLogLib.SetInt32(self.ptr, index, value)
end

function BinLogObject:AddInt32 (index, value)
	binLogLib.AddInt32(self.ptr, index, value)
end

function BinLogObject:SubInt32 (index, value)
	binLogLib.SubInt32(self.ptr, index, value)
end

function BinLogObject:GetDouble (index)
	return binLogLib.GetDouble(self.ptr, index)
end

function BinLogObject:SetDouble (index, value)
	binLogLib.SetDouble(self.ptr, index, value)
end

function BinLogObject:AddDouble (index, value)
	binLogLib.AddDouble(self.ptr, index, value)
end

function BinLogObject:SubDouble (index, value)
	binLogLib.SubDouble(self.ptr, index, value)
end

function BinLogObject:GetFloat (index)
	return binLogLib.GetFloat(self.ptr, index)
end

function BinLogObject:SetFloat (index, value)
	binLogLib.SetFloat(self.ptr, index, value)
end

function BinLogObject:SetStr (index,value)
	binLogLib.SetStr(self.ptr, index,value)
end

function BinLogObject:GetStr (index)
	return binLogLib.GetStr(self.ptr, index)
end

--获取当前整数下标数量
function BinLogObject:GetUInt32Len ()
	return binLogLib.GetUInt32Len(self.ptr)
end

--获取当前字符串下标数量
function BinLogObject:GetStrLen ()
	return binLogLib.GetStrLen(self.ptr)
end

--获得GUID
function BinLogObject:GetGuid ()
	return self:GetStr(BINLOG_STRING_FIELD_GUID)
end

--获取名称
function BinLogObject:GetName ()
	return self:GetStr(BINLOG_STRING_FIELD_NAME)
end
--设置名称
function BinLogObject:SetName (name)
	self:SetStr(BINLOG_STRING_FIELD_NAME, name)
end

--获取所有者
function BinLogObject:GetOwner ()
	return self:GetStr(BINLOG_STRING_FIELD_OWNER)
end
--设置所有者
function BinLogObject:SetOwner (owner)
	self:SetStr(BINLOG_STRING_FIELD_OWNER, owner)
end

--获取版本号
function BinLogObject:GetVersion ()
	return self:GetStr(BINLOG_STRING_FIELD_VERSION)
end
--设置版本号
function BinLogObject:SetVersion (version)
	self:SetStr(BINLOG_STRING_FIELD_VERSION, version)
end

--设置binlog size
function BinLogObject:SetBinlogMaxSize( value )
	binLogLib.SetBinlogMaxSize(self.ptr, value)
end

return BinLogObject
