local function BlockInteraction(ply, ent, ret)
	if ent then
		if not BaseWars.Ents:Valid(ent) then return false end

		local Classes = BaseWars.Config.PhysgunBlockClasses

		local class = ent:GetClass()
		if class:find("_door") or class:find("func_") then return false end
		if Classes[class] then return false end

		local Owner = ent.CPPIGetOwner and ent:CPPIGetOwner()

		if BaseWars.Ents:ValidPlayer(ply) and ply:InRaid() then return false end
		if BaseWars.Ents:ValidPlayer(Owner) and Owner:InRaid() then return false end
	elseif ply:InRaid() then
		return false
	end

	return ret == nil or ret
end

local function IsAdmin(ply, ent, ret)
	if BlockInteraction(ply, ent, ret) == false then return false end

	return ply:IsAdmin()
end

function GAMEMODE:PhysgunPickup(ply, ent)
	local Ret = self.BaseClass:PhysgunPickup(ply, ent)
	--if ent:IsVehicle() then return IsAdmin(ply, ent, Ret) end

	ent.beingPhysgunned = ent.beingPhysgunned or {}

	local found = false
	for k, v in ipairs(ent.beingPhysgunned) do
		if v == ply then found = true break end
	end

	if not found then
		ent.beingPhysgunned[#ent.beingPhysgunned + 1] = ply
	end

	return BlockInteraction(ply, ent, Ret)
end
