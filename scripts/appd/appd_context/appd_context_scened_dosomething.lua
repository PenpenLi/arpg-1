function PlayerInfo:CallScenedDoSomething(typ, data, str)
	call_scened_appd_to_send_do_something(self:GetScenedFD(), self:GetGuid(), typ, data, str)
end

-- 场景服发过来要应用服做点事
function PlayerInfo:DoGetScenedDoSomething  ( ntype, data, str)

end
