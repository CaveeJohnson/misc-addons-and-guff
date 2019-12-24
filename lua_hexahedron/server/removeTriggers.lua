local bad = {}
local enable = {}
local solid = {}
local remove = {}

local map = game.GetMap()

if map == "Basewars_Evocity_v2" then
	bad = {
		-- elevator triggers
		2775,
		2592,
		2667,
		-- admin base teleporter
		2534,
		2469,
	}

	enable = {
		2555,
	}

	solid = {
		2553,
	}

	remove = {
		-- buttons in admin room
		2556,
		2557, 
		2751,
		2750,
	}
elseif map == "rp_downtown_v4c_v2" then
	remove = {
		2594,
	}
end

local function disableBadEntities()
	for _, v in ipairs(bad) do
		local e = ents.GetMapCreatedEntity(v)

		e:Fire("disable")
	end

	for _, v in ipairs(enable) do
		local e = ents.GetMapCreatedEntity(v)

		e:Fire("enable")
	end

	for _, v in ipairs(solid) do
		local e = ents.GetMapCreatedEntity(v)

		e:SetSolidFlags(FSOLID_TRIGGER)
	end

	for _, v in ipairs(remove) do
		local e = ents.GetMapCreatedEntity(v)

		e:Fire("kill")
	end
	
	for _, e in ipairs(ents.FindByClass("trigger_remove")) do
		e:Fire("kill")
	end
end

hook.Add("InitPostEntity", "badTriggers", disableBadEntities)
hook.Add("PostCleanupMap", "badTriggers", disableBadEntities)