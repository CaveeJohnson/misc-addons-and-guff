local test = function(ply)
	if ply.AFKTime and ply:AFKTime() > 60 * 60 then return ply:AFKTime() end
	return false
end

local test2 = function()
	-- todo: check if incoming player is banned, if so we prefer AFK > banned
	local total = game.MaxPlayers()
	local count = player.GetCount()

	if count >= (total - 1) then
		local worst = 0
		local ply

		local plys = player.GetAll()
		for i = 1, count do
			local v = plys[i]
			local val = test(v)

			if val and val > worst then
				worst = val
				ply = v
			end
		end

		if ply and worst > 0 then
			local time = string.FormattedTime(worst)

			BaseWars.UTIL.RefundAll(ply)
			ply:Kick(string.format("[AFK] Server is full, you have been AFK the longest (%d:%d:%d)", time.h, time.m, time.s))
		end
	end
end

hook.Add("CheckPassword", "afkKickertron9000", test2)
