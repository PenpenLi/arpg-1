
local matchProcessor

function initMatch()
	local userMax = 3
	local combineExpandConfig = CombineExpandConfig:new {combineExpandConfig = {2, 4, 6, 10, 12, 14}}
	local matchExpandConfig = MatchExpandConfig:new {matchExpandConfig = {4, 8, 12, 16, 20, 24}}
	local matchConfig = MatchConfig:new {userMax = userMax, matchExpandConfig = matchExpandConfig, combineExpandConfig = combineExpandConfig}
	matchProcessor = MatchProcessor:new {config = matchConfig}
	
	matchProcessor:setNotifier(MatchProcessorNotifier:new{})
end

--[[
	userList = {user1, user2}
--]]
function submitMatchTask(userList)
	local teamPart = TeamPart:new{userList = userList}
	local task = MatchTask:new{teamPart = teamPart}
	task:Mark()
	
	matchProcessor:submitMatch(task)
end

function cancelMatch(id)
	local task = getMatchTask(id)
	if task then
		matchProcessor:cancelMatch(task)
	end
end