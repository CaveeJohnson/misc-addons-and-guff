local SpawnClasses = {
	["info_player_deathmatch"] = true,
	["info_player_rebel"] = true,
	["gmod_player_start"] = true,
	["info_player_start"] = true,
	["info_player_allies"] = true,
	["info_player_axis"] = true,
	["info_player_counterterrorist"] = true,
	["info_player_terrorist"] = true,
}

local LastThink = CurTime()
local Spawns 	= {}

local function ScanEntities()
	Spawns = {}

	for k, v in next, ents.GetAll() do
		if not v or not IsValid(v) or k < 1 then continue end

		local Class = v:GetClass()
		if SpawnClasses[Class] then
			Spawns[#Spawns+1] =  v
		end
	end
end

local maxs = Vector(4164, -4247, 431)
local mins = Vector(585, -7418, -246)
local _ang = Angle(0, 180, 0)
local _pos = Vector(508, -6305, -135)

local downtownv4 = (game.GetMap() == "rp_downtown_v4c_v2")

function GAMEMODE:Think()
	local State = self.BaseClass:Think()

	if LastThink < CurTime() - 5 then
		BaseWars.UTIL.WriteCrashRollback()

		for k, v in next, ents.GetAll() do
			if v:IsOnFire() then
				v:Extinguish()
			end
		end

		if downtownv4 then
			for k, v in ipairs(player.GetHumans()) do
				if not v:IsAdmin() and not v.supersecret then
					if v:GetPos():WithinAABox(mins, maxs) then
						v:SetVelocity(Vector(-500, 0, -1))
						v:SetPos(_pos)
						v:SetAngles(_ang)
						v:EmitSound("npc/metropolice/vo/getoutofhere.wav")

						--[[if HAM and ACH_Secret1 then
							ACH_Secret1:Check(v)
						end]]
					end
				end
			end
		end

		if BaseWars.Config.SpawnBuilding == 0 then return end

		for k, s in next, Spawns do
			if not s or not IsValid(s) then
				ScanEntities()

				return State
			end

			local Ents = ents.FindInSphere(s:GetPos(), 256)
			if #Ents < 2 then
				continue
			end

			for _, v in next, Ents do
				if v.BeingRemoved or v.NoFizz then
					continue
				end

				local Owner = v:CPPIGetOwner()
				if not Owner or not IsValid(Owner) or not Owner:IsPlayer() or (BaseWars.Config.SpawnBuilding == 1 and Owner:IsAdmin()) then
					continue
				end

				if v:GetClass() == "prop_physics" or v:GetClass() == "gmod_light" or v:GetClass() == "gmod_lamp" or v:GetClass() == "gmod_wheel" then
					v.BeingRemoved = true
					SafeRemoveEntity(v)

					Owner:Notify(BaseWars.LANG.DontBuildSpawn, BASEWARS_NOTIFICATION_ERROR)
				end
			end
		end

		LastThink = CurTime()
	end

	return State
end
