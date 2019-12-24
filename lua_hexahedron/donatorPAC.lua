local tag = "donatorPAC"

if SERVER then
	hook.Add("PrePACConfigApply", tag, function(ply)
		return ply:IsAdmin() or ply:GetNWBool("wardrobe"), "You require wardrobe access to use PAC."
	end)
else
	hook.Add("PrePACEditorOpen", tag, function(ply)
		return ply:IsAdmin() or ply:GetNWBool("wardrobe"), "You require wardrobe access to use PAC."
	end)
end
