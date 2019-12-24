do
	function net.WriteCTakeDamageInfo(info)
		assert(type(info) == "CTakeDamageInfo", string.format("bad argument #1 to 'WriteCTakeDamageInfo' (CTakeDamageInfo expected, got %s)", type(info)))

		net.WriteInt(info:GetDamage(),     32)
		net.WriteInt(info:GetDamageType(), 32)
		net.WriteInt(info:GetMaxDamage(),  32)
		net.WriteInt(info:GetAmmoType(),   32)

		net.WriteVector(info:GetDamageForce())
		net.WriteVector(info:GetDamagePosition())
		net.WriteVector(info:GetReportedPosition())

		net.WriteEntity(info:GetInflictor())
		net.WriteEntity(info:GetAttacker())
	end

	function net.ReadCTakeDamageInfo()
		local info = DamageInfo()

		info:SetDamage(net.ReadInt(32))
		info:SetDamageType(net.ReadInt(32))
		info:SetMaxDamage(net.ReadInt(32))
		info:SetAmmoType(net.ReadInt(32))

		info:SetDamageForce(net.ReadVector())
		info:SetDamagePosition(net.ReadVector())
		info:SetReportedPosition(net.ReadVector())

		local inf = net.ReadEntity()
		if IsValid(inf) then info:SetInflictor(inf) end

		local attk = net.ReadEntity()
		if IsValid(attk) then info:SetAttacker(attk) end

		return info
	end
end

if SERVER then
	util.AddNetworkString("sharedTakeDamage")

	GAMEMODE.__EntityTakeDamage = GAMEMODE.__EntityTakeDamage or GAMEMODE.EntityTakeDamage

	function GAMEMODE:EntityTakeDamage(targ, info, ...)
		if targ.PreTakeDamage and targ:PreTakeDamage(info) then
			return true
		end

		local res = self.__EntityTakeDamage(self, targ, info, ...)
		if res then return true end

		hook.Run("EntityTakeDamageFinal", targ, info, ...)

		net.Start("sharedTakeDamage")
			net.WriteEntity(targ)
			net.WriteCTakeDamageInfo(info)
		net.Broadcast()

		hook.Run("SharedEntityTakeDamage", targ, info, ...)
	end

	return
else
	net.Receive("sharedTakeDamage", function()
		local targ = net.ReadEntity()
		if not IsValid(targ) then return end

		local info = net.ReadCTakeDamageInfo()

		hook.Run("SharedEntityTakeDamage", targ, info)
		if targ.SharedOnTakeDamage then targ:SharedOnTakeDamage(info) end
	end)
end

local hits = {}

local default_color = Color(200, 200, 200, 255)
local crit_color    = Color(255,   0,   0, 255)
local gravity       = Vector(0, 0, -20)

local tag = "bw-18.backports.hitnumbers"
local main_font = tag--ext:getTag()

surface.CreateFont(main_font, {
	font = "Roboto",
	weight = 1000,
	size = 64,
	shadow = true,
})

local function getHitPos(ent, dmginfo)
	local info_pos  = dmginfo:GetDamagePosition()
	local info_pos2 = dmginfo:GetReportedPosition()
	return
		(info_pos  and info_pos:LengthSqr() ~= 0  and info_pos ) or
		(info_pos2 and info_pos2:LengthSqr() ~= 0 and info_pos2) or
		ent:LocalToWorld(ent:OBBCenter())
end

local none = Color(0, 0, 0, 0)
local function mixColor(incol, adcol)
	adcol = adcol or none

	return Color(
		incol.r + adcol.r,
		incol.g + adcol.g,
		incol.b + adcol.b,
		incol.a + adcol.a)
end

local colorLookup = {
	[DMG_ACID     ] = Color(- 50,  200, - 50,    0),

	[DMG_NERVEGAS ] = Color(-100,  255, - 30,    0),
	[DMG_POISON   ] = Color(-100,  255, - 30,    0),
	[DMG_PARALYZE ] = Color(-100,  255, - 30,    0),

	[DMG_DROWN    ] = Color(-255, -255,  255, -100),
	[DMG_SHOCK    ] = Color(-100, -100,  255,    0),
}
--  DMG_BURN ENERGYBEAM PLASMA RADIATION CRUSH VEHICLE CLUB FALL

local function rnSign()
	return math.random() < 0.5 and -1 or 1
end

local dist_sqr = 2048 * 2048

local function SharedEntityTakeDamage(ent, dmginfo)
	if LocalPlayer():GetPos():DistToSqr(ent:GetPos()) > dist_sqr then return end

	local dmg = dmginfo:GetDamage()
	if dmg == 0 then return end

	local col = mixColor(default_color)
	local types = {}

	for damage_type, color in pairs(colorLookup) do
		if dmginfo:IsDamageType(damage_type) then
			col             = mixColor(col, color)
			types[#types + 1] = damage_type
		end
	end

	local crit = dmg >= 100
	col = crit and mixColor(crit_color) or col

	if ent == LocalPlayer() then col.a = 35 end

	local data = {
		pos   = getHitPos(ent, dmginfo),
		vel   = --dmginfo:GetDamageForce() * 0.1
			Vector(
				math.random(5, 15) * rnSign(),
				math.random(5, 15) * rnSign(),
				15),

		dmg   = dmg,
		crit  = crit,
		col   = col,
		types = types,

		start = CurTime(),
		txt   = "-" .. tostring(dmg),

		scale = crit and math.min(3, 1 + dmg / 1800) or 1,
	}

	hits[#hits + 1] = data
end
hook.Add("SharedEntityTakeDamage", tag, SharedEntityTakeDamage)

local function PostDrawTranslucentRenderables(depth, sky)
	if sky then return end

	local new = {}
	local i = 0

	surface.SetFont(main_font)

	local eye_pos = EyePos()
	local ft = FrameTime()

	for _, v in ipairs(hits) do
		local render_ang = (v.pos - eye_pos):Angle()
		render_ang:RotateAroundAxis(render_ang:Up(), -90)
		render_ang:RotateAroundAxis(render_ang:Forward(), 90)

		local base_scale = v.scale
		local scale = base_scale - (((CurTime() - v.start) / 2) * base_scale)

		cam.Start3D2D(v.pos, render_ang, 0.2 * (scale + 0.1))
			--debugoverlay.Cross(v.pos, 10, 0.1, Color(255, 255, 255, 50), true)
			local w, h = surface.GetTextSize(v.txt)
			surface.SetTextColor(v.col)
			surface.SetTextPos(0 - w / 2, 0 - h / 2)

			surface.DrawText(v.txt)

			v.pos = v.pos + v.vel * ft
			v.vel = v.vel + gravity * ft

			if CurTime() < v.start + 2 then
				i = i + 1
				new[i] = v
			end
		cam.End3D2D()
	end

	hits = new
end
hook.Add("PostDrawTranslucentRenderables", tag, PostDrawTranslucentRenderables)
