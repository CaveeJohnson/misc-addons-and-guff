aowl.AddCommand({"ss", "screenshot"}, function(player, line, target, quality)
	if not Discord or not Discord.Backend.API or not Discord.SS then
		return false, 'Discord Integration is missing (or not initialized)'
	end

	local ent = easylua.FindEntity(target)
	if ent and IsValid(ent) and ent:IsPlayer() then
		Discord.SS:Request(ent, quality)
	else
		return false, 'Target not found (or it was invalid)'
	end
end, "moderators")