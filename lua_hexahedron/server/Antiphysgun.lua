local tag = "Antiphysgun"

hook.Add("PlayerEnteredVehicle", tag, function(ply, veh)
	if IsValid(veh:GetParent()) then
		local prop = veh:GetParent()
		if prop.VehicleName then return end
		local phys = prop:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
		prop.sittingPeople = (prop.sittingPeople or 0) + 1
		prop.PhysgunDisabled = true
	end
end)

hook.Add("PlayerLeaveVehicle", tag, function(ply, veh)
	if IsValid(veh:GetParent()) then
		local prop = veh:GetParent()
		prop.sittingPeople = (prop.sittingPeople or 0) - 1
		if prop.sittingPeople <= 0 then
			prop.sittingPeople = nil
			prop.PhysgunDisabled = false
		end
	end
end)