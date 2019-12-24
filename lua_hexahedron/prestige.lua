prestige = {}
local PLAYER = FindMetaTable("Player")

function PLAYER:GetPrestigeRank()
	return self:GetNW2Int("prestige", 0)
end

function PLAYER:GetPrestigeTokens()
	return self:GetNW2Int("prestige_tokens", 0)
end

function prestige.getNextReset(ply)
	return math.min((ply:GetPrestigeRank() + 1) * 100, BaseWars.Config.LevelSettings.MaxLevel)
end

function prestige.nextLevelTokens(ply, newRank)
	local overLevel  = ply:GetLevel() - prestige.getNextReset(ply)
	local levelLog10 = math.floor(math.log10(overLevel)      * newRank)
	local moneyLog10 = math.floor(math.log10(ply:GetMoney()) * newRank)

	return newRank + math.max(0, moneyLog10) + math.max(0, levelLog10)
end

if CLIENT then
	local p_color = Color(255, 215,   0, 255)

	function prestige.onUpdateRecieve()
		local ply = net.ReadEntity()
		if not IsValid(ply) then return end
		local n   = net.ReadUInt(8)

		surface.PlaySound(string.format("garrysmod/save_load%d.wav", math.random(1, 4)))

		chat.AddText(
			Grey,                      "[", p_color, "Prestige", Grey, "] ",
			team.GetColor(ply:Team()), ply:Nick(),
			Grey,                      " has ascended to prestige rank ",
			NiceGreen,                 n,
			Grey,                      "!"
		)
	end

	net.Receive("prestige", prestige.onUpdateRecieve)

	local gray = Color(128, 128, 128)

	hook.Add("BW_PostTagParse", "prestige", function(tbl, ply, team)
		local rank = ply.GetPrestigeRank and ply:GetPrestigeRank()

		if rank and rank > 0 then
			tbl[#tbl + 1] = gray
			tbl[#tbl + 1] = "{"
			tbl[#tbl + 1] = p_color
			tbl[#tbl + 1] = rank
			tbl[#tbl + 1] = gray
			tbl[#tbl + 1] = "} "
		end
	end)
else
	util.AddNetworkString("prestige")
	util.AddNetworkString("prestige_attempt")

	file.CreateDir("basewars_prestige")

	function prestige.broacastUpdate(ply, n)
		net.Start("prestige")
			net.WriteEntity(ply)
			net.WriteUInt(n, 8)
		net.Broadcast()
	end

	function prestige.onAttemptRecieve(len, ply)
		prestige.attemptAscension(ply)
	end
	net.Receive("prestige_attempt", prestige.onAttemptRecieve)

	function prestige.attemptAscension(ply)
		if ply:GetLevel() < prestige.getNextReset(ply) then return false end

		local newRank = ply:GetPrestigeRank() + 1
		ply:SetPrestigeRank(newRank)

		BaseWars.UTIL.RefundAll(ply)
		ply:SetXP(0)

		local tokens = prestige.nextLevelTokens(ply, newRank)
		ply:SetPrestigeTokens(ply:GetPrestigeTokens() + tokens)

		ply:SetLevel(newRank * 5)
		ply:SetMoney((BaseWars.Config.StartMoney * (newRank + 1)) + 1000)

		prestige.broacastUpdate(ply, newRank)
		return true
	end

	function prestige.loadPlayer(ply)
		file.CreateDir("basewars_prestige/" .. ply:SteamID64())
		local x = tonumber(file.Read("basewars_prestige/" .. ply:SteamID64() .. "/p.txt", "DATA") or 0) or 0
		local y = tonumber(file.Read("basewars_prestige/" .. ply:SteamID64() .. "/t.txt", "DATA") or 0) or 0

		ply:SetNW2Int("prestige", x)
		ply:SetNW2Int("prestige_tokens", y)
	end
	hook.Add("PlayerInitialSpawn", "prestige", prestige.loadPlayer)

	function prestige.savePlayer(ply)
		file.CreateDir("basewars_prestige/" .. ply:SteamID64())
		file.Write("basewars_prestige/" .. ply:SteamID64() .. "/p.txt", ply:GetPrestigeRank())
		file.Write("basewars_prestige/" .. ply:SteamID64() .. "/t.txt", ply:GetPrestigeTokens())
	end

	function PLAYER:SetPrestigeRank(x)
		self:SetNW2Int("prestige", x)
		prestige.savePlayer(self)
	end

	function PLAYER:SetPrestigeTokens(x)
		self:SetNW2Int("prestige_tokens", x)
		prestige.savePlayer(self)
	end
end
