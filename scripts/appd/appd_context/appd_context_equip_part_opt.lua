--[[
装备部位操作
]]

--强化
function PlayerInfo:strength (part, isUseMaterial)
	if part < 0 or part >= MAX_EQUIP_PART_NUMBER then
		return
	end

	--TODO: 从配置表读取数据
	--TODO: 依次判断是否达到最高等级 -> 判断金币够不 -> 判断是否成功
	local success = false
	if isUseMaterial then
		--TODO 判断包裹里是否有材料, 有的话扣除并置为true
	else
		--TODO 通过概率来确定是否成功
	end

	--TODO 由于测试需要, 把他置为成功
	success = true
	--TODO 如果成功, 先扣金币
	if success then
		self:getLogicalMgr():addStrengthLevel(part, 1)
		--self:getLogicalMgr():setGemLevel(part, 0, 12)
		--self:getLogicalMgr():setGemExp(part, 0, -23)		
		--self:getLogicalMgr():SetStr(4, "CCCBB")		

		self:getLogicalMgr():SetInt16 (200, 0, -9)

		-- 发送属性改变
		playerLib.SendAttr(self.ptr)
	else
		--TODO 如果失败, 扣一半金币
		self:CallOptResult(OPERTE_TYPE_STRENGTH, STRENGTH_OPERTE_FAIL)
	end
end