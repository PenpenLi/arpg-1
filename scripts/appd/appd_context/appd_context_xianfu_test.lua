function PlayerInfo:EnterXianfuTest()
	local gerneralId = string.format("%s%d", self:GetGuid(), os.time())
	local mapid = 2018
	local offsetX = randInt(-3, 3)
	local offsetY = randInt(-3, 3)
	local pos = tb_kuafu_xianfu_tst_base[ 1 ].bornPos[ 1 ]
	-- ������
	call_appd_teleport(self:GetScenedFD(), self:GetGuid(), pos[ 1 ] + offsetX, pos[ 2 ] + offsetY, mapid, gerneralId)
end