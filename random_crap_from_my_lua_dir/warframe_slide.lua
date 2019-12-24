local tag = "warframe_slide"

setfenv(1, _G) -- need to run this because easylua fucks it up for clients

local w_slide
local w_slide_tilt

if SERVER then
	resource.AddFile("sound/warframe/KneeSlideLoopDefault.ogg")

	hook.Add("GetFallDamage", tag, function(ply, speed)
		if ply:GetInfoNum(tag, 1) == 1 and ply:KeyDown(IN_DUCK) then -- a bit hacky, can't use IsSliding because only changes on ground after pressing ctrl
			return 0
		end
	end)
else
	w_slide = CreateClientConVar(tag, 1, true, true)
	w_slide_tilt = CreateClientConVar(tag .. "_tilt", 1)

	local a = 0
	hook.Add("CalcView", tag, function(ply, origin, angles, ...)
		if w_slide and not w_slide:GetBool() then return end
		if w_slide_tilt and not w_slide_tilt:GetBool() then return end

		local w    = ply:GetActiveWeapon()
		local view = {}
		view.origin = origin
		view.angles = angles

		local time = FrameTime() * 5
		local sliding = ply:GetNWBool("is_sliding")
		local y = sliding and 600 or 0

		local av = ply:GetAimVector()
		local vel = ply:GetVelocity()
		local velDot = math.Clamp(av:Dot(vel) / 300, 0, 1)

		y = y * velDot

		a = math.Approach(a, y, (a - y) * time)

		if a >= 1 then
			local allow = true
			if w.GetIronsights then allow = not w:GetIronsights() end

			if allow then
				view.angles.r = view.angles.r + (a * -0.03)

				return view
			end
		end
	end)
end

local function removeSound(ply)
	if SERVER then return end

	if IsValid(ply.bullet_sound) then
		ply.bullet_sound:Stop()
		ply.bullet_sound = nil
	end
end


FindMetaTable("Player").IsSliding = FindMetaTable("Player").IsSliding or function(ply)
	return SERVER and (ply.is_sliding or false) or ply:GetNWBool("is_sliding")
end

hook.Add("SetupMove", tag, function(ply, cmove, ccmd)
	if not IsFirstTimePredicted() then return end
	if ply.IsSitting and ply:IsSitting() then return end
	if (SERVER and ply:GetInfoNum(tag, 1) == 0) or (CLIENT and w_slide and not w_slide:GetBool()) then return end

	local pressing_shift = bit.band(cmove:GetButtons(), IN_SPEED)
	local crouching = bit.band(cmove:GetButtons(), IN_DUCK)
	local jumping = bit.band(cmove:GetButtons(), IN_JUMP)

	if cmove:GetVelocity():Length2DSqr() > 13000 and ply:IsOnGround() and ply:GetMoveType() == MOVETYPE_WALK and crouching ~= 0 and not ply:IsSliding() then
		ply.is_sliding = CurTime()
		ply.sliding_angle = ply:GetVelocity()
		ply:SetNWBool("is_sliding", true)
		if CLIENT then
			if ply.is_playing then return end

			removeSound(ply)
			ply.is_playing = true
			sound.PlayFile("sound/warframe/KneeSlideLoopDefault.ogg", "", function(station)
				if IsValid(station) then
					ply.bullet_sound = station
					ply.bullet_sound:SetVolume(0.5)
				end
				ply.is_playing = false
			end)
		end
	end

	if (ply:GetInfoNum("warframe_bulletjump", 1) == 0 and jumping ~= 0 or jumping == 0) and crouching ~= 0 and ply:IsSliding() and cmove:GetVelocity():Length2DSqr() > 2000 then
		local ang = (ply.sliding_angle * math.Max(1.65 * ((ply.is_sliding or 0) + 2.2  - CurTime()), 0))
		local vel = cmove:GetVelocity()
		if not ply:IsOnGround() and not ply.is_sliding_air then
			ply.is_sliding_air = CurTime()
		end

		cmove:SetVelocity(Vector(ang.x, ang.y, 0) - Vector(vel.x, vel.y, ((ply.is_sliding_air or 0) - CurTime()) * -GetConVar("sv_gravity"):GetInt()))
	else
		ply.is_sliding_air = nil
		ply.is_sliding = nil
		ply:SetNWBool("is_sliding", false)
		if CLIENT then
			removeSound(ply)
		end
	end
end)

hook.Add("CalcMainActivity", tag, function(ply , vel)
	if (SERVER and ply:GetInfoNum(tag, 1) == 0) or (CLIENT and w_slide and not w_slide:GetBool()) then return end

	local seq = ply:LookupSequence("sit_zen")
	if not seq then return end

	local left_leg = ply:LookupBone("ValveBiped.Bip01_L_Calf")
	if not left_leg then return end

	local right_leg = ply:LookupBone("ValveBiped.Bip01_R_Calf")
	if not right_leg then return end

	if ply:IsSliding() and vel:Length2DSqr() > 3000 then
		return -1, seq
	end
end)
