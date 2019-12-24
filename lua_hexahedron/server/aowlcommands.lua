if not aowl and aowl.AddCommand then return end

aowl.AddCommand({"mostprops", "most"}, function(pl)
	local props = {}

	for k, v in next, ents.FindByClass("prop_*") do

		local Owner = BaseWars.Ents:ValidOwner(v)
		if Owner then

			props[Owner] = (props[Owner] or 0) + 1

		end

	end

	local Big, Name = 0, "Nobody"
	for k, v in next, props do

		if v > Big then

			Big = v
			Name  = k:Nick()

		end

	end

	PrintMessage(3, pl:Nick() .. " requested most props.")
	PrintMessage(3, "Most props: " .. Big .. " | " .. Name)
end)

aowl.AddCommand({"findlag", "props"}, function(pl)
	local props, props2 = {}, {}

	for k, v in next, ents.FindByClass("prop_*") do

		local Owner = BaseWars.Ents:ValidOwner(v)
		if Owner then

			props[Owner] = (props[Owner] or 0) + 1

			local Phys = v:GetPhysicsObject()
			if not BaseWars.Ents:Valid(Phys) or not Phys:IsMotionEnabled() then continue end

			props2[Owner] = (props2[Owner] or 0) + 1

		end

	end

	PrintMessage(3, pl:Nick() .. " requested lag detection.")

	for k, v in SortedPairsByValue(props, true) do

		if not props2[k] and v < 20 then continue end

		PrintMessage(3, k:Nick())
		PrintMessage(3, "\t" .. v .. " total | " .. (props2[k] or "none") .. " unfrozen.")

	end
end)

aowl.AddCommand({"freeze", "freezeall", "fa"}, function(pl)

	PrintMessage(3, (IsValid(pl) and pl:Nick() or "Unknown") .. " froze all props.")
	BaseWars.UTIL.FreezeAll()

end, "moderators")

aowl.AddCommand({"name", "nick"}, function(pl, line, target, nick)

	if not target then pl:ChangeNick() return end

	local ent = easylua.FindEntity(target:Trim())

	if pl:CheckUserGroupLevel("moderators") and ent and IsValid(ent) then

		if nick then nick = nick:Trim() end

		ent:ChangeNick(nick)

	else

        pl:ChangeNick(line)

	end

end, "donators")

-- Prometheus
/*aowl.AddCommand("donate", function(pl)

	pl:SendLua( [[ gui.OpenURL( "http://steamcommunity.com/profiles/76561198109939061" ) ]] )

	pl:ChatPrint( "Opened owner's profile, add him on steam." )
	pl:ChatPrint( "Then when he comes online you can talk with him about donating." )

end, "players")*/

aowl.AddCommand({"fuckshadows", "removeshadows", "killshadows"}, function( ply )
	if not IsValid(ply) then return end
	for _, ent in ipairs(ents.FindByClass("prop_physics")) do 
		if ent:CPPIGetOwner() == me then 
			ent:DrawShadow(false) 
		end
	end
end, "developers" )

-- oplexz's shite
aowl.AddCommand("refund", function(ply, target)

	if not target then BaseWars.UTIL.RefundAll( ply ) return end

	local ent = easylua.FindEntity(target)

	if not ent:IsPlayer() then return false, aowl.TargetNotFound(target)

	elseif ent:IsPlayer() then BaseWars.UTIL.RefundAll( ent ) end

end, "developers")

aowl.AddCommand("ropes", function()

	for _, rope in ipairs( ents.FindByClass( "keyframe_rope" ) ) do
		rope:Remove()
	end

end, "moderators")
-- end oplexz's shite

do
	local no = function(ent, hid)
		return function(ply, ...)
			if not IsValid(ent) then
				hook.Remove("PlayerSay", hid)

				return
			end

			if ply == ent then
				return ""
			end
		end
	end

	aowl.AddCommand({"mute", "off", "quiet"}, function(ply, line, target)
		local ent = easylua.FindEntity(target)
		if not ent:IsPlayer() then
			return false, aowl.TargetNotFound(target)
		end

		if istable(ent) then
			for _, v in ipairs(player.GetAll()) do
				if not ent.func(v) then continue end
				local hid = "aowl_mute_" .. v:SteamID64()

				hook.Add("PlayerSay", hid, no(v, hid))
				v.aowl_muted = true
			end
		else
			local hid = "aowl_mute_" .. ent:SteamID64()

			hook.Add("PlayerSay", hid, no(ent, hid))
			ent.aowl_muted = true
		end
	end, "moderators")

	aowl.AddCommand({"unmute", "on"}, function(ply, line, target)
		local ent = easylua.FindEntity(target)
		if not ent:IsPlayer() then
			return false, aowl.TargetNotFound(target)
		end

		if istable(ent) then
			for _, v in ipairs(player.GetAll()) do
				if not ent.func(v) then continue end
				local hid = "aowl_mute_" .. v:SteamID64()

				hook.Remove("PlayerSay", hid)
				ent.aowl_muted = nil
			end
		else
			local hid = "aowl_mute_" .. ent:SteamID64()

			hook.Remove("PlayerSay", hid)
			ent.aowl_muted = nil
		end
	end, "moderators")
end
