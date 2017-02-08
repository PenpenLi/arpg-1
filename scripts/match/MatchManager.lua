local taskHash = {}
local removed = {}


function MarkUserMatchTask(id, task)
	if (removed[id] == 1) then
		outFmtError("Mark error !! userid = %d has already removed", id)
	end
	taskHash[id] = task
end


function UnmarkUserMatchTask(id)
	if (not taskHash[id]) then
		outFmtError("repeat remove !! userid = %d has already removed", id)
	end
	
	taskHash[id] = nil
	removed[id] = 1
end


function getMatchTask(id)
	return taskHash[id]
end