InstanceResZhenQi = class("InstanceResZhenQi", InstanceResBase)

InstanceResZhenQi.Name = "InstanceResZhenQi"
InstanceResZhenQi.exit_time = 10
--Ë¢ÐÂ×ø±êÆ«ÒÆÖµ
InstanceResZhenQi.RefreshOffset = 3;

function InstanceResZhenQi:ctor(  )
	
end


function InstanceResZhenQi:InitRes(config)
	outFmtDebug("zhenqi-----------------------")
end


function InstanceResZhenQi:ApplyRefreshMonsterBatch(player,batchIdx)
	outFmtDebug("zhen qi shua guai ************")
	--local batchPos = self:GetRandomMonsterIndex(batchIdx)

	--if batchPos == 0 then
	--	return false,0
	--end
	
	local id = self:GetIndex()
	local config = tb_instance_res[ id ]
	local plev = player:GetLevel()
	local cnt = config.monsternum
	local monsterlist = config.monster
	local monsterposlist = config.monsterInfo

	for i = 1, cnt do

		for j = 1,#monsterlist do
			
			local bornPos = monsterposlist[j]
			local bornX = bornPos[ 1 ] + randInt(0, self.RefreshOffset)
			local bornY = bornPos[ 2 ] + randInt(0, self.RefreshOffset)
			local entry = monsterlist[j]

			local creature = mapLib.AddCreature(self.ptr, 
				{templateid = entry, x = bornX, y = bornY, level=plev, active_grid = true, alias_name = config.name, 
				ainame = "AI_res", npcflag = {}})
			
		end
		
	end
	
	cnt = cnt * #monsterlist
	
	return true,cnt
end

return InstanceResZhenQi