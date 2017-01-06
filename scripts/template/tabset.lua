tb_faction_shop_list = {}

for id,config in ipairs(tb_faction_shop) do
	local lev = config.lev
	if not tb_faction_shop_list[lev] then
		tb_faction_shop_list[lev] = {}
	end
	table.insert(tb_faction_shop_list[lev],config)
end

--print(#tb_faction_shop_list)