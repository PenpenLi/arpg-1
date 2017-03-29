
--客户端完成当前引导
function PlayerInfo:Hanlde_Finish_Now_Guide(pkt)
	self:SetGuideIdLast(self:GetGuideIdNow())
end