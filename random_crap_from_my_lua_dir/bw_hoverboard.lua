local tag = "bw_hoverboard"

easylua.StartEntity("basewars_hoverboard") do
	ENT.Base = "basewars_base"
	ENT.Type = "anim"
	DEFINE_BASECLASS(ENT.Base)

	ENT.PrintName = "Hoverboard"
	ENT.Model = "models/squad/sf_plates/sf_plate2x5.mdl"

	function ENT:SetupDataTables()
		BaseClass.SetupDataTables(self)

		self:netVar("Entity", "Passenger")
	end

	if SERVER then
		function ENT:Use(_, ply)
			if not (IsValid(ply) and ply:IsPlayer()) then return end
			if self:validPassenger() then return end

			ply:SetNW2Entity("basewars_hoverboard", self)
			self:setPassenger(ply)

			print(self, " -> new passenger ", self:getPassenger())
		end

		local rel_dist_sqr = 512*512

		function ENT:Think()
			BaseClass.Think(self)

			local pass = self:getPassenger()
			if self:validPassenger() and (not pass:Alive() or pass:GetPos():DistToSqr(self:GetPos()) > rel_dist_sqr) then
				pass:SetNW2Entity("basewars_hoverboard", NULL)
				self:setPassenger(NULL)

				print(self, " -> passenger disengaged ", pass)
			end
		end
	end
end easylua.EndEntity()

hook.Add("SetupMove", tag, function(ply, mv, cmd)
	local hoverboard = ply:GetNW2Entity("basewars_hoverboard")
	if not IsValid(hoverboard) then return end

	local movement = Vector()
	local buttons = cmd:GetButtons()
	if bit.band(buttons, IN_MOVELEFT) == IN_MOVELEFT then
		movement = movement + Vector(0, 10, 0)
	end
	if bit.band(buttons, IN_MOVERIGHT) == IN_MOVERIGHT then
		movement = movement + Vector(0, -10, 0)
	end
	if bit.band(buttons, IN_FORWARD) == IN_FORWARD then
		movement = movement + Vector(10, 0, 0)
	end
	if bit.band(buttons, IN_BACK) == IN_BACK then
		movement = movement + Vector(-10, 0, 0)
	end

	if bit.band(buttons, IN_JUMP) == IN_JUMP then
		movement = movement + Vector(0, 0, 10)
	end

	mv:SetVelocity(Vector())
	mv:SetOrigin(hoverboard:LocalToWorld(hoverboard:OBBCenter() + Vector(0, 0, 1)))

	if CLIENT then return end

	--hoverboard:SetAngles(Angle(0, ply:EyeAngles().y, 0))
	hoverboard:GetPhysicsObject():ApplyForceCenter(LocalToWorld(movement, Angle(), Vector(), hoverboard:GetAngles()) * 1000)
end)

hook.Add("CreateMove", tag, function(cmd)
	local hoverboard = LocalPlayer():GetNW2Entity("basewars_hoverboard")
	if not IsValid(hoverboard) then return end

	cmd:ClearMovement()
end)
