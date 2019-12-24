local models = {
	[ 1] = "models/props_lab/cactus.mdl",
	[ 2] = "models/props_junk/popcan01a.mdl",
	[ 3] = "models/props_junk/garbage_plasticbottle003a.mdl",
	[ 4] = "models/props_junk/plasticbucket001a.mdl",
	[ 5] = "models/props_interiors/pot02a.mdl",
	[ 6] = "models/props_junk/shoe001a.mdl",
	[ 7] = "models/props_lab/bindergreen.mdl",
	[ 8] = "models/props_interiors/pot01a.mdl",
	[ 9] = "models/props_c17/doll01.mdl",
	[10] = "models/props_combine/breenclock.mdl",
	[11] = "models/gibs/wood_gib01a.mdl",
	[12] = "models/gibs/wood_gib01b.mdl",
	[13] = "models/gibs/wood_gib01c.mdl",
	[14] = "models/gibs/wood_gib01d.mdl",
	[15] = "models/gibs/wood_gib01e.mdl",
	[16] = "models/props_c17/trappropeller_lever.mdl",
	[17] = "models/props_lab/huladoll.mdl",
	[18] = "models/props_lab/tpplug.mdl"
}

local names = {
	["models/props_lab/cactus.mdl"                    ] = "a desert plant",
	["models/props_junk/popcan01a.mdl"                ] = "a metal cylinder",
	["models/props_junk/garbage_plasticbottle003a.mdl"] = "a plastic cylinder",
	["models/props_junk/plasticbucket001a.mdl"        ] = "a plastic container",
	["models/props_interiors/pot02a.mdl"              ] = "a cooking utensil",
	["models/props_junk/shoe001a.mdl"                 ] = "a lone shoe",
	["models/props_lab/bindergreen.mdl"               ] = "a paper binder",
	["models/props_interiors/pot01a.mdl"              ] = "a ceramic pot",
	["models/props_c17/doll01.mdl"                    ] = "a broken doll",
	["models/props_combine/breenclock.mdl"            ] = "an adorned clock",
	["models/gibs/wood_gib01a.mdl"                    ] = "a chunk of plywood",
	["models/gibs/wood_gib01b.mdl"                    ] = "a chunk of plywood",
	["models/gibs/wood_gib01c.mdl"                    ] = "a chunk of plywood",
	["models/gibs/wood_gib01d.mdl"                    ] = "a chunk of plywood",
	["models/gibs/wood_gib01e.mdl"                    ] = "a chunk of plywood",
	["models/props_c17/trappropeller_lever.mdl"       ] = "a small lever",
	["models/props_lab/huladoll.mdl"                  ] = "a dashboard ornament",
	["models/props_lab/tpplug.mdl"                    ] = "a plug"
}

local positions = {
	[ 1] = Vector (  4270.1977539062  ,   4022.1437988281  ,    169.3916015625  ),
	[ 2] = Vector (  4231.5336914062  ,   6110.8676757812  ,    521.36346435547 ),
	[ 3] = Vector (  3268.3920898438  ,   5398.1625976562  ,     73.437995910645),
	[ 4] = Vector (   924.53521728516 ,   7575.7280273438  ,    382.49221801758 ),
	[ 5] = Vector (  1275.4848632812  ,   4309.3168945312  ,   1007.9174804688  ),
	[ 6] = Vector (  1474.1744384766  ,   3718.0651855469  ,    453.35006713867 ),
	[ 7] = Vector (- 2405.6342773438  ,    355.93392944336 ,    272.38003540039 ),
	[ 8] = Vector (- 2737.9196777344  ,    144.04150390625 ,     74.381874084473),
	[ 9] = Vector (- 6340.9272460938  , - 3564.4653320312  ,    209.3738861084  ),
	[10] = Vector (- 7708.8779296875  , - 4691.2158203125  ,    812.38989257812 ),
	[11] = Vector (- 6559.8486328125  , - 6630.6494140625  ,    243.50611877441 ),
	[12] = Vector (- 6702.1860351562  , - 7594.1240234375  ,     78.380615234375),
	[13] = Vector (- 3653.6799316406  , - 9124.63671875    ,   1742.3696289062  ),
	[14] = Vector (- 5052.8803710938  , - 7792.5805664062  ,    741.40106201172 ),
	[15] = Vector (- 4930.0498046875  , - 7361.8588867188  ,    246.42306518555 ),
	[16] = Vector (- 7693.8056640625  , - 9445.6796875     ,    333.42373657227 ),
	[17] = Vector (- 9073.947265625   , -10281.916992188   ,     77.463729858398),
	[18] = Vector (- 5400.798828125   , -10714.974609375   ,     76.37100982666 ),
	[19] = Vector (- 5200.8237304688  , - 9022.9482421875  ,   1613.3668212891  ),
	[20] = Vector (- 4433.0024414062  , - 4847.6567382812  ,    311.29284667969 ),
	[21] = Vector (- 5196.2802734375  , - 4684.0844726562  ,    473.40863037109 ),
	[22] = Vector (- 5195.7216796875  , - 4513.732421875   ,    473.36813354492 ),
	[23] = Vector (- 5194.8125        , - 4427.4985351562  ,    473.4182434082  ),
	[24] = Vector (- 7829.0649414062  , - 7954.7622070312  , - 2210.5693359375  ),
	[25] = Vector (- 4405.1176757812  , - 4657.1342773438  ,    231.56192016602 ),
	[26] = Vector (  5003.0405273438  , - 8299.1533203125  ,    310.20251464844 ),
	[27] = Vector (  6307.4643554688  , - 8211.0166015625  ,    205.34071350098 ),
	[28] = Vector (- 7527.8149414062  ,  13367.764648438   ,     34.943885803223),
	[29] = Vector (- 8419.48046875    ,   9941.6943359375  ,    356.18365478516 ),
	[30] = Vector (-11813.448242188   ,   8534.1640625     ,     69.335105895996),
	[31] = Vector (- 8049.0073242188  , - 8870.56640625    , -  122.60292816162 )
}

-- 0xf0ab2240
local area_mins = Vector (-7221.869140625, -4833.95703125, 72.03125)
-- 0xec17c2a8
local area_maxs = Vector (-6594.0668945312, -4462.03125, 231.90237426758)

local function rnd()
	return "<color=255,0,0>" .. ("."):rep(26):gsub(".", function() return string.char(math.random(32, 112)) end):gsub("[<>]", "?") .. "</color>"
end

hook.Add("PlayerSay", "BaseWars.Command.Subcommand_Handler", function(ply, text)
	if text:lower() == "*snap*" then
		if g_nextSecret and CurTime() < g_nextSecret then
			ply:ChatPrint(rnd())

			return ""
		end

		if IsValid(g_secretProp) then
			ply:ChatPrint("The sequence has already begun, this knowledge is not yours to gain.")
		else
			local selected_model = table.Random(models)

			ply:ChatPrint("The sequence begins.")
			ply:ChatPrint("Search for " .. names[selected_model] .. ", carry it to the area designated on the sign at the city-industrial teleporter.")

			g_secretProp = ents.Create("prop_physics")
				g_secretProp:SetModel(selected_model)
				g_secretProp.__isSecret = true
			g_secretProp:Spawn()
			g_secretProp:Activate()
			g_secretProp:SetPos(table.Random(positions))

			print("DEBUG: " .. tostring(g_secretProp))
		end

		return ""
	end

	if text:lower() == "perfectly balanced, as all things should be" then
		if not IsValid(g_secretProp) then ply:Kill() return "" end

		if not g_secretProp:GetPos():WithinAABox(area_mins, area_maxs) then
			ply:Kill()

			return ""
		end

		SafeRemoveEntity(g_secretProp)
		g_secretProp = nil
		g_nextSecret = CurTime() + 3600

		ply:Give("tfa_cso_darkknight_v8")
		ply:GiveAmmo(9999, "AR2", true)

		ply:SetHealth(1e6)

		return ""
	end
end)
