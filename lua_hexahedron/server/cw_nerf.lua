--[=[hook.Add("InitPostEntity", "cw_nerf", function()
	weapons.GetStored([[cw_mk11]]).Damage = 30

	hook.Remove("InitPostEntity", "cw_nerf")
end)]=]
