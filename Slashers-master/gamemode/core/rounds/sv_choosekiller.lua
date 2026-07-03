-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:48
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-07-26 14:45:37

local GM = GM or GAMEMODE

function GM.ROUND:ChooseKiller()
	local candidates = {}
	for _, v in ipairs(player.GetAll()) do
		if not v:IsBot() then
			table.insert(candidates, v)
		end
	end

	if #candidates == 0 then
		-- No real players, fall back to a random bot
		local bots = {}
		for _, v in ipairs(player.GetAll()) do
			if v:IsBot() then
				table.insert(bots, v)
			end
		end
		return table.Random(bots)
	end

	return table.Random(candidates)
end