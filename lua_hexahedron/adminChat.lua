local tag = "adminChat"

if SERVER then

	local authTbl                   = file.Read("cfg/discord.cfg", "GAME"):Split("\n")
	local webhook_token, webhook_id = authTbl[1], authTbl[2]

	local avatar_cache = {}
	local function discordPost(msg, ply)
		local avatar = avatar_cache[ply:SteamID64()]

		local nick   = "[REQUEST] " .. ply:Nick()
		if nick:len() > 32 then
			nick = nick:sub(1, 29) .. "..."
		end


		HTTP({
			success = function(code, body, data)
			end,
			failed = error,
			method = "POST",
			url    = "https://discordapp.com/api/v6/webhooks/" .. webhook_id .. "/" .. webhook_token,
			headers = {
				["Content-Type"]	= "application/json",
				["Content-Length"]	= tostring(#msg),
			},
			parameters = {
				content 	= msg,
				username 	= nick,
				avatar_url 	= avatar
			}
		})
	end

	adminChat = adminChat or {}
	adminChat.blacklist = adminChat.blacklist or {}

	function adminChat.addBlacklist(ply)
		adminChat.blacklist[ply:SteamID()] = true
		return true
	end

	function adminChat.removeBlacklist(ply)
		adminChat.blacklist[ply:SteamID()] = nil
		return true
	end

	util.AddNetworkString(tag)

	hook.Add("PlayerSay", tag, function(ply, txt)
		if ply.IsBanned and ply:IsBanned() then return end
		if (ply.IsMod and ply:IsMod()) or ply:IsAdmin() then return end

		if (txt:Trim():sub(1, 1) == "@") then
			if adminChat.blacklist[ply:SteamID()] then
				ply:ChatPrint("You're temporarily banned from using this.")
				return ""
			end

			if ply._on_adminchat_cooldown and ply._on_adminchat_cooldown >= CurTime() then
				ply:ChatPrint("You're on cooldown for " .. string.NiceTime(ply._on_adminchat_cooldown - CurTime()))
				return ""
			end

			if #txt < 7 or txt:lower():match("^@%s-admin%s-tp%s-$") then
				ply:ChatPrint("Be descriptive with your message and do not say 'admin tp', DESCRIBE WHAT IS WRONG.")

				return ""
			end

			ply._on_adminchat_cooldown = CurTime() + 30
			local data 	= util.Compress(ply:Nick() .. ": " .. txt:Trim())
			local len 	= string.len(data or "")

			local admins = {}
			for num, ply in ipairs(player.GetAll()) do
				if (ply.IsMod and ply:IsMod() or ply:IsAdmin()) then
					table.insert(admins, ply)
				end
			end

			if not avatar_cache[ply:SteamID64()] then
				http.Fetch("http://steamcommunity.com/profiles/" .. ply:SteamID64() .. "?xml=1", function(body)
					local ret = body:match("<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>")
					if ret and ply:IsValid() then
						avatar_cache[ply:SteamID64()] = ret
						discordPost(txt, ply)
					end

					return body
				end)
			else
				discordPost(txt, ply)
			end

			ply:ChatPrint("A message has been sent to the admins: \n" .. txt)

			net.Start(tag)
				net.WriteUInt(len, 16)
				net.WriteData(data, len)
			net.Send(admins)

			return ""
		end
	end)

	return
end

local convar = CreateClientConVar("adminchat_sound", 1, true, false, "Notification sound for when a player needs help.")
hook.Add("InitPostEntity", tag, function()
	hook.Remove("InitPostEntity", tag)

	local ply = LocalPlayer()
	if (IsValid(ply) and (ply.IsMod and ply:IsMod()) or ply:IsAdmin()) then
		convar = GetConVar("adminchat_sound")
	end
end)

net.Receive(tag, function()
	local len   = net.ReadUInt(16)
	local data  = net.ReadData(len)
	local msg 	= util.Decompress(data)
	
	system.FlashWindow()

	if (convar and convar:GetBool()) then
		sound.PlayFile("sound/plats/elevbell1.wav", "", function() end)
	end

	chat.AddText(Color(0, 191, 255), msg)
end)
