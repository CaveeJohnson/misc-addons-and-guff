hook.Add("PlayerCanHearPlayersVoice", "Rangelimit", function(listener, talker)
	if listener.InFaction and listener:InFaction() and talker.InFaction and talker:InFaction() and listener:Team() == talker:Team() then return true, false end
	if listener:GetPos():Distance(talker:GetPos()) > 750 then
		return false 
	end
	return true, true
end)