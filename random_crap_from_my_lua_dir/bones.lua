function xdxd(ply)
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Calf"), Angle(0, 22.5, 0))
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Calf"), Angle(0, 105.625, 0))
end

hook.Remove("Think", "xdxd", function()
	xdxd(LocalPlayer())
end)
