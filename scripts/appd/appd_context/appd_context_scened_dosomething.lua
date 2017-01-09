function PlayerInfo:CallScenedDoSomething(typ, data, str)
	call_scened_appd_to_send_do_something(self:GetScenedFD(), self:GetGuid(), typ, data, str)
end

-- 场景服发过来要应用服做点事
function PlayerInfo:DoGetScenedDoSomething  ( ntype, data, str)
	if SCENED_APPD_ENTER_VIP_INSTANCE == ntype then
		self:checkVipMapTeleport(data, str)
	elseif SCENED_APPD_ENTER_TRIAL_INSTANCE == ntype then
		self:checkTrialMapTeleport()
	elseif SCENED_APPD_ENTER_RES_INSTANCE == ntype then
		--进入资源副本
		self:checkResMapTeleport(data)
	elseif SCENED_APPD_PASS_RES_INSTANCE == ntype then
		--通关资源副本
		self:passResInstance(data)
	elseif SCENED_APPD_PASS_TRIAL_INSTANCE == ntype then
		self:passTrialInstance(data)
	elseif SCENED_APPD_PASS_VIP_INSTANCE == ntype then
		self:passVipInstance(data, tonumber(str))
	elseif SCENED_APPD_USE_ITEM == ntype then
		-- 判断如果道具不是药品就不使用了
		if tb_item_template[data].type == ITEM_TYPE_MEDICINE then
			UseHpItem(self, data, 1)
		end
	elseif SCENED_APPD_USE_RESPAWN_ITEM == ntype then
		useRespawn(self)
	elseif SCENED_APPD_ADD_ENEMY == ntype then
		self:AddEnemy(str, data)
	elseif SCENED_APPD_ADD_MAIL == ntype then
		local desc = tb_mail[data].desc
		local name = tb_mail[data].name
		AddGiftPacksData(self:GetGuid(),0,GIFT_PACKS_TYPE_ITEM_GIVE,os.time(),os.time() + 86400*30, name, desc, str, "系统")
	end
end
