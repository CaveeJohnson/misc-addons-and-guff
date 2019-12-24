if game.GetMap() ~= "Basewars_Evocity_v2" then return end

local SPAWN_POSITIONS = {
	--[[
	Map 'center'
	Vector(-3677.9812011719, 222.03326416016,  122),
	Vector(-4048.4907226563, -1093.6495361328, 122),
	Vector(-3490.5473632813, -1027.3239746094, 122),
	Vector(-3018.7001953125, -988.40472412109, 122),
	Vector(88.242515563965,  -875.01031494141, 122),
	Vector(-1762.9434814453, -240.09638977051, 122),
	Vector(-4337.7592773438, 0.7724677324295,  122),
	Vector(-6018.5805664063, -471.66680908203, 122)
	]]
	--bank
	Vector(-6321, -7800, 136),
	Vector(-6321, -7750, 136),
	Vector(-6321, -7700, 136),
	Vector(-6321, -7650, 136),
	Vector(-6321, -7600, 136),
	Vector(-6321, -7550, 136),
	Vector(-6321, -7500, 136),
	--across bank
	Vector(-5709, -7800, 136),
	Vector(-5709, -7750, 136),
	Vector(-5709, -7700, 136),
	Vector(-5709, -7650, 136),
	Vector(-5709, -7550, 136),
	Vector(-5709, -7500, 136),
	Vector(-5709, -7450, 136),
}

local RADIUS
hook.Add("PostGamemodeLoaded", "basewars_spawn", function()
	hook.Remove("PostGamemodeLoaded", "basewars_spawn")

	RADIUS = (BaseWars.Config.SpawnRadius * BaseWars.Config.SpawnRadius) or (256 * 256)

	function GAMEMODE:PlayerSelectSpawn(ply)
		local pos = SPAWN_POSITIONS[math.random(1, #SPAWN_POSITIONS)]
		ply:SetPos(pos)

		ply.spawnpos = pos
	end
end)

hook.Add("PlayerShouldTakeDamage", "basewars_spawn", function(ply, att)
	if att.spawnpos then
		att.spawnpos = nil
	end
	
	if ply.spawnpos then
		if ply:GetPos():DistToSqr(ply.spawnpos) < RADIUS then
			return false
		else
			ply.spawnpos = nil
		end
	end
end)