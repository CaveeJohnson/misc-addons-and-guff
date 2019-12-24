hook.Add("PlayerSpawnedProp", "AntiSpam", function(ply, _, ent)
	ent:AddCallback("PhysicsCollide", function(ent, data)
		if ent:GetPhysicsObject():IsPenetrating() and data.HitEntity:GetPhysicsObject():IsPenetrating() then
			constraint.NoCollide(ent, data.HitEntity, 0, 0)
		end
	end)
end)
