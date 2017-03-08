tb_faction_shop_list = {}

for id,config in ipairs(tb_faction_shop) do
	local lev = config.lev
	if not tb_faction_shop_list[lev] then
		tb_faction_shop_list[lev] = {}
	end
	table.insert(tb_faction_shop_list[lev],config)
end


tb_achieve_type_list = {}

for id,config in ipairs(tb_achieve_base) do
	local achtype = config.achtype
	if not tb_achieve_type_list[achtype] then
		tb_achieve_type_list[achtype] = {}
	end
	table.insert(tb_achieve_type_list[achtype],config.id)
end

--print(#tb_faction_shop_list)