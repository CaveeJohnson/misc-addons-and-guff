if game.GetMap() ~= "Basewars_Evocity_v2" then return end

local function action(ply, sound, time, counter)
	ply:SendLua([[surface.PlaySound("]] .. sound .. [[")]])
	timer.Simple(time, function()
		if IsValid(ply) then
			if ply.adminwarning == 2 then ply:Kick() return end
			ply:SetPos(Vector(3048.1616210938, 4508.3979492188, 183.19297790527))
			ply.adminwarning = counter
		end
	end)
end


timer.Create("Fuckoffjews", 7, 0, function()
	for _, v in next, ents.FindInBox(Vector(-8677.984375, -7930.96875, 456.03125), Vector(-7784.287109375, -7408.1557617188, 667.96166992188)) do
		if IsValid(v) and v:IsPlayer() and not v:IsAdmin() then
			if not v.adminwarning then
				action(v, "vo/k_lab/br_tele_03.wav", 1.3, 1)
			elseif v.adminwarning == 1 then
				action(v, "vo/citadel/br_mock01.wav", 6, 2)
			elseif v.adminwarning == 2 then
				action(v, "vo/citadel/br_whatittakes.wav", 3, nil)
			end
		end
	end
end)