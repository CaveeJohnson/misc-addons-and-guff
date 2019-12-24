if CLIENT then return end
g_opt_in = g_opt_in or {}

concommand.Add("vs_opt_in", function(ply)
	g_opt_in[ply:SteamID64()] = true
	ply:PrintMessage(HUD_PRINTCONSOLE, "opted in (vs_opt_out)")
end)

concommand.Add("vs_opt_out", function(ply)
	g_opt_in[ply:SteamID64()] = true
	ply:PrintMessage(HUD_PRINTCONSOLE, "opted out (vs_opt_in)")
end)

local white = {
	["STEAM_0:0:55932074"] = true
}

concommand.Add("vs_play", function(ply, _, args)
	if not IsValid(ply) then return end

	if not (ply:IsAdmin() or white[ply:SteamID()]) then
		ply:PrintMessage(HUD_PRINTCONSOLE, "you do not have access to this command")

		return
	end

	local url = args[1]
	if not (url and url:len() > 12) then
		ply:PrintMessage(HUD_PRINTCONSOLE, string.format("'%s': not a valid url", url or "nothing"))

		return
	end
	ply:PrintMessage(HUD_PRINTCONSOLE, string.format("now playing '%s'", url))

	local exec = string.format([=[if vistest_play then vistest_play("%s") end]=], url)
	for _, v in ipairs(player.GetHumans()) do
		if not (IsValid(v) and g_opt_in[v:SteamID64()]) then continue end
		v:SendLua(exec)
		v:ChatPrint(string.format("Current track played by %s", ply:Nick()))
	end
end)
