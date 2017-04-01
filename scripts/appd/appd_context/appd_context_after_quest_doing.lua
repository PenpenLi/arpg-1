function PlayerInfo:AfterQuestDoing(doing)
	-- 进入仙府体验副本
	if doing == 1 then
		self:EnterXianfuTest()
	end
end