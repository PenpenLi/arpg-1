function PlayerInfo:AfterQuestDoing(doing)
	-- �����ɸ����鸱��
	if doing == 1 then
		self:EnterXianfuTest()
	end
end