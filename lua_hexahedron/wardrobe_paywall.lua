local PLAYER = debug.getregistry().Player

local hrs_wardrobe = 10
do
	function PLAYER:hasWardrobeAccess()
		local hours = self:GetPlayTime() / 3600

		return hours >= hrs_wardrobe
	end

	function PLAYER:remainingForWardrobeAccess()
		local hours = self:GetPlayTime() / 3600

		return math.max(0, hrs_wardrobe - hours)
	end
end

hook.Add("Wardrobe_AccessAllowed", "wardrobe.restricted.users", function(ply)
	if not (ply:IsAdmin() or ply:hasWardrobeAccess()) then
		return false, string.format("You do not have wardrobe access, %d hours needed (%d left)", hrs_wardrobe, ply:remainingForWardrobeAccess())
	end
end)

local hrs_vip = 30
do
	function PLAYER:hasVIPAccess()
		local hours = self:GetPlayTime() / 3600

		return hours >= hrs_vip
	end

	function PLAYER:remainingForVIPAccess()
		local hours = self:GetPlayTime() / 3600

		return math.max(0, hrs_vip - hours)
	end
end

if CLIENT then return end

assert(luadata, "luadata is required for wardrobe restrictions")

if aowl then
	local tbl = {
		players    = "donators",
		helpers    = "viphelpers",
		moderators = "vipmoderators",
	}

	-- local tbl2 = {
	-- 	donators      = "players",
	-- 	viphelpers    = "helpers",
	-- 	vipmoderators = "moderators",
	-- }

	local function check_for_upgrades(ply)
		if ply:hasWardrobeAccess() then
			ply:SetNWBool("wardrobe", true)

			if ply._restrict_loaded then
				ply:ChatPrint(string.format("You have recieved Wardrobe Access for playing for %d hours.", hrs_wardrobe))
			end
		end

		local new = tbl[ply:GetUserGroup()]

		if new and ply:hasVIPAccess() then
			ply:SetUserGroup(new, true)
			ply:ChatPrint(string.format("You have recieved VIP for playing for %d hours.", hrs_vip))

			return true
		end

		return false
	end

	hook.Add("PlayerInitialSpawn", "restricted.users", function(ply)
		timer.Simple(1, function()
			if not IsValid(ply) or ply:IsBot() then return end

			check_for_upgrades(ply)
			ply._restrict_loaded = true
		end)
	end)

	timer.Create("restricted.users", 300, 0, function()
		for _, v in ipairs(player.GetHumans()) do
			check_for_upgrades(v)
		end
	end)

	aowl.AddCommand("vip,donate,time,donor,getvip", function(ply)
		if not check_for_upgrades(ply) then
			if not ply:hasVIPAccess() then
				ply:ChatPrint(string.format("To get VIP, you need %d hours of playtime (%d left)", hrs_vip, ply:remainingForVIPAccess()))
			else
				ply:ChatPrint(string.format("You already have VIP, vip needs %d hours of playtime", hrs_vip))
			end
		end
	end)
end
