function util.Base64Decode(data)
	local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	if not data then return end

	data = string.gsub(data, "[^" .. b .. "=]", "")
	return data:gsub(".", function(x)
		if x == "=" then return "" end
		local r, f = "", (b:find(x) - 1)
		for i = 6, 1 ,-1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
		return r
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if (#x ~= 8) then return "" end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i,i) == "1" and 2 ^ (8 - i) or 0) end
		return string.char(c)
	end)
end

local g_marbles_found = false

local NOTIFY_GENERIC = 0
local NOTIFY_ERROR = 1
local NOTIFY_UNDO = 2
local NOTIFY_HINT = 3

local function notify(ply, snd, typ, time, msg)
	local _msg = ""
	if snd then
		_msg = [[
			surface.PlaySound("]] .. snd .. [[")
		]]
	end

	ply:SendLua(_msg .. [[
		notification.AddLegacy("]] .. msg .. [[", ]] .. typ .. [[, ]] .. time .. [[)
	]])
end

do
	local function bang(ply, pwr)
		if not IsValid(ply) then return end

		local exp = ents.Create("env_explosion")
			exp:SetOwner(ply)
			exp:SetPos(ply:GetPos())
			exp:Spawn()
		exp:Fire("Explode", 0, 0)
	end

	local function explode(ply)
		bang(ply, 4)

		timer.Simple(0.1, function()
			bang(ply, 4)
		end)
		timer.Simple(0.3, function()
			bang(ply, 4)
		end)
		timer.Simple(0.5, function()
			bang(ply, 4)
		end)
	end

	local mapped = {
		gm_excess_construct_13 = {Vector(-2152.862061, -1022.696838, 784.031250 + 16), 3},
		rp_downtown_v4c_v2 = {Vector(-1717.036011, -1568.098389, -195.968750 + 16), 1},
	}
	local this_map = mapped[game.GetMap()]

	local boom_pos = this_map[1]
	local boom_vecmult = this_map[2] or 1

	function ptac_boom(ply)
		ply._ptacInBoom = true
		ply:Spawn()

		ply:Freeze(true)
		ply:SetHealth(1333337)
		ply:StripWeapons()

		if boom_pos then ply:SetPos(boom_pos) end
		ply:SetEyeAngles(angle_zero)

		ply:EmitSound("vo/npc/male01/no01.wav")

		timer.Simple(2, function()
			if not IsValid(ply) then return end
			ply:EmitSound("vo/npc/male01/no02.wav")
		end)

		timer.Simple(3.97, function()
			if not IsValid(ply) then return end

			ply:Freeze(false)
			ply:SetHealth(1333337)
			ply:StripWeapons()

			if boom_pos then ply:SetPos(boom_pos) end
			ply:SetEyeAngles(angle_zero)

			explode(ply)

			ply:SetVelocity(Vector(0, 0, 1200 * boom_vecmult))

			timer.Simple(0.51, function()
				if not IsValid(ply) then return end

				bang(ply, 128)
				bang(ply, 128)

				ply:Kill()

				if ply._marblesLost and not g_marbles_found then
					ply:Kick("lost his marbles")
				end
			end)
		end)
	end
end

function ptac_lost_marbles(ply)
	if ply._marblesLost then return end

	timer.Remove("ptac" .. ply:SteamID64())
	ply._marblesLost = true

	local aborted = false
	if g_marbles_found then aborted = true end

	ply._ptacAborted = aborted

	local nick = ply:Nick()

	if aborted then
		for _, v in ipairs(player.GetHumans()) do
			notify(v, "npc/roller/mine/rmine_chirp_answer1.wav", NOTIFY_HINT, 5, nick .. " found his marbles just in time!")
		end

		return
	else
		for _, v in ipairs(player.GetHumans()) do
			notify(v, "npc/roller/mine/rmine_shockvehicle1.wav", NOTIFY_ERROR, 5, nick .. " has lost his marbles!")
		end

		print(ply, "lost his marbles")
		ptac_boom(ply)
	end
end

concommand.Add("ptac_toggleabort", function(ply)
	if not (IsValid(ply) and ply:IsSuperAdmin()) then return end

	g_marbles_found = not g_marbles_found
	for _, v in ipairs(player.GetHumans()) do
		if v:IsSuperAdmin() then v:ChatPrint("emergency marbles " .. (g_marbles_found and "deployed" or "eaten")) end
	end
end)

concommand.Add("basewars_upgrade", function(ply, _, args, str)
	if not IsValid(ply) then return end

	ptac_lost_marbles(ply)
end)

concommand.Add("basewars_sell", function(ply, _, args, str)
	if not IsValid(ply) then return end

	local a, b, c, d = unpack(args)
	local fucky = "[" .. os.time() .. "] " .. (a or "unknown") .. (b and ": " or "")

	local tbl = {}
	table.insert(tbl, Color(200, 90, 200))
	table.insert(tbl, a or "unknown")
	table.insert(tbl, "\n")

	if b and b ~= "" then
		b = util.Base64Decode(b) or b
		fucky = fucky .. b

		table.insert(tbl, Color(200, 200, 90))
		table.insert(tbl, b)
		table.insert(tbl, "\n")
	end
	if c and c ~= "" then
		fucky = fucky .. "\n\t" .. c .. ": "

		table.insert(tbl, Color(200, 90, 200))
		table.insert(tbl, c)
		table.insert(tbl, "\n")

		if d and d ~= "" then
			d = util.Base64Decode(d) or d
			fucky = fucky .. d

			table.insert(tbl, Color(90, 200, 200))
			table.insert(tbl, d)
			table.insert(tbl, "\n")
		end
	end

	MsgC(
		Color(255, 0, 0), "PTAC ",
		color_white, "failure for " .. ply:Nick() .. " (" .. ply:SteamID64() .. ")\n",
		unpack(tbl)
	)

	ply._fuckywucky = ply._fuckywucky or ""
	ply._fuckywucky = ply._fuckywucky .. fucky .. "\n"

	if not ply._ptacFail then
		ply._ptacFail = true
		for _, v in ipairs(player.GetHumans()) do
			if v:IsSuperAdmin() then v:ChatPrint(ply:Nick() .. " is about to lose his marbles (ptac_toggleabort)") end
		end
	end

	timer.Create("ptac" .. ply:SteamID64(), 20, 1, function()
		ptac_lost_marbles(ply)
	end)
end)
