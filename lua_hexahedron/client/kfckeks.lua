hook.Add("InitPostEntity", "unknown KFC", function()
	if materials and game.GetMap() == "Basewars_Evocity_v2" then
		materials.ReplaceTexture("decals/unknowninfernosdecal",  "kfcsgtsick/colsanderskfc")
		materials.ReplaceTexture("decals/unknowninfernosdecal1", "kfcsgtsick/colsanderskfc")
	end
end)