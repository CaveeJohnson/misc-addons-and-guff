local meta = FindMetaTable("Player")
local range = 120
local range_sqr = range*range

local function blockIfTied(ply)
	if IsValid(ply) and ply.isTiedUp and ply:isTiedUp() then return false end
end

local function blockIfTied2(ply)
	local tied, weps = ply:isTiedUp()
	if tied and not weps then return false end
end

hook.Add("PlayerSpawnProp"      , "tiedUp-Restrictions", blockIfTied)
hook.Add("PlayerSpawnObject"    , "tiedUp-Restrictions", blockIfTied)
hook.Add("CanPlayerSuicide"     , "tiedUp-Restrictions", blockIfTied)
hook.Add("PlayerCanPickupItem"  , "tiedUp-Restrictions", blockIfTied2)
hook.Add("PlayerCanPickupWeapon", "tiedUp-Restrictions", blockIfTied2)

local whitelisted = {
	["bw_weapon"] = true,
}

hook.Add("PlayerUse"            , "tiedUp-Restrictions", function(ply, ent)
	if not IsValid(ply) or not ply.isTiedUp then return false end

	local tied, weps = ply:isTiedUp()
	if tied and weps and IsValid(ent) then
		local class = ent:GetClass()

		if ent:IsWeapon() or whitelisted[class] or class:match("^weapon_") or class:match("^bw_.+kit[v%d]*$") or class:match("^bw_dispenser") then
			return
		end

		return false
	elseif tied then return false end
end)

local function movementLimiter(ply, mv, cmd)
	if not ply:isTiedUp() then return end

	local master = ply:GetNW2Entity("bw_master", NULL)
	if not IsValid(master) then
		if SERVER then ply:unTie() end
	return end

	if not ply:Alive() then
		if SERVER then ply:unTie() end
	return end

	local origin = mv:GetOrigin()
	local master_origin = master:GetPos()
	if origin:DistToSqr(master_origin) <= range_sqr then return end

	local normal = (origin - master_origin):GetNormalized()
	mv:SetOrigin(master_origin + normal * (range - 1))
end
hook.Add("SetupMove", "tiedUp-movement", movementLimiter)

function meta:isTiedUp()
	return self:GetNW2Bool("bw_tiedUp", false), self:GetNW2Bool("bw_wepsAllowed", false)
end

if CLIENT then return end

function meta:tieUp(master, allowWeps)
	self:SetNW2Entity("bw_master", master)
	self:SetNW2Bool("bw_wepsAllowed", allowWeps)

	if IsValid(self.bw_constraint) then
		self.bw_constraint:Remove()
	end

	local bone_pos = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_Spine"))
	local bone_pos2 = master:GetPos()
	if master:IsPlayer() then
		bone_pos2 = master:GetBonePosition(master:LookupBone("ValveBiped.Bip01_L_Hand"))
	end
	self.bw_constraint = constraint.Rope(self, master, 0, 0, self:WorldToLocal(bone_pos), master:WorldToLocal(bone_pos2), range + 60, 0, 0, 3, "cable/rope", false)

	if self:isTiedUp() then
		if not allowWeps then self:StripWeapons() end

		return
	end

	self:SetNW2Bool("bw_tiedUp", true)

	if allowWeps then return end
	self.bw_refundweps = {}

	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		self.bw_lastwep = wep:GetClass()
	end

	for _, v in pairs(self:GetWeapons()) do
		local class = v:GetClass()

		table.insert(self.bw_refundweps, class)
	end

	self:StripWeapons()
end

function meta:unTie()
	self:SetNW2Bool("bw_tiedUp", false)
	self:SetNW2Entity("bw_master", NULL)

	if IsValid(self.bw_constraint) then
		self.bw_constraint:Remove()
	end

	if self.bw_refundweps then
		for _, v in pairs(self.bw_refundweps) do
			self:Give(v)
		end

		self.bw_refundweps = nil
	end

	if self.bw_lastwep then
		self:SelectWeapon(self.bw_lastwep)
		self.bw_lastwep = nil
	end
end
