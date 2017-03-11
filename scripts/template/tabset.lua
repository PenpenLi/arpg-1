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

tb_quest_daily_list = {}
for id, config in ipairs(tb_char_level) do
	local elements = {}
	for _, val in ipairs(config.dailyQuests) do
		table.insert(elements, val)
	end
	
	local before = tb_quest_daily_list[id-1]
	if before then
		for _, val in ipairs(before) do
			table.insert(elements, val)
		end
	end
	
	tb_quest_daily_list[id] = elements
end

--print(#tb_faction_shop_list)