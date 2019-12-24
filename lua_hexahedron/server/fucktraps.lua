local function die(e)
	if e.IsElectronic or e.IsGenerator then
		local a = DamageInfo()
		a:SetDamage(100000)
		a:SetAttacker(game.GetWorld())
		a:SetDamageType(DMG_BLAST)
			e:OnTakeDamage(a)
	else
		SafeRemoveEntity(e)
	end
end

timer.Create("fuck_trap_bases", 5, 0, function()
	for k, v in ipairs(ents.FindByClass"info_teleport_destination") do
		for _, e in ipairs(ents.FindInSphere(v:GetPos(), 100)) do
			if IsValid(e:CPPIGetOwner()) and e:CPPIGetOwner():IsPlayer() then
				die(e)
			end
		end
	end
end)
