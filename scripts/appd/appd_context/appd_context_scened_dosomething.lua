function PlayerInfo:CallScenedDoSomething(typ, data, str)
	call_scened_appd_to_send_do_something(self:GetScenedFD(), self:GetGuid(), typ, data, str)
end

-- 场景服发过来要应用服做点事
function PlayerInfo:DoGetScenedDoSomething  ( ntype, data, str)
	if SCENED_APPD_ENTER_VIP_INSTANCE == ntype then
		self:checkVipMapTeleport(data, str)
	elseif SCENED_APPD_USE_ITEM == ntype then
		-- 是否需要判断如果道具不是药品就不使用了
		UseHpItem(self, data, 1)
	elseif SCENED_APPD_USE_RESPAWN_ITEM == ntype then
		-- 是否需要判断如果道具不是药品就不使用了
		if not useRespawn(self) then
			-- TODO: 告诉场景服 自动回城
		end
	end
end
