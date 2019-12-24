local tag = "serverRestart"

if SERVER then

	util.AddNetworkString(tag)

	timer.Create("serverRestart-timer", 43200, 0, function()
		local oldhostname = GetHostName()
		if SetHostName then
			SetHostName("UK/EU Official Hexahedron BaseWars | Restarting...")
		end

		if aowl and aowl.CountDown then
			aowl.CountDown(60, "Automatic server restart", function()
				if oldhostname and SetHostName then
					SetHostName(oldhostname)
				end
				timer.Simple(0, function()
					game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
				end)
			end)
		end

		BaseWars.UTIL.RefundAll() -- People tend to leave halfway through because hurr durp automatic

		net.Start(tag)
		net.Broadcast()

		if aowl then return end
		timer.Simple(60, function()
			if oldhostname and SetHostName then
				SetHostName(oldhostname)
			end
			timer.Simple(0, function()
				game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
			end)
		end)
	end)

	return
end

--[[
local scrW, scrH = ScrW(), ScrH()

local function FormatTime(time)
	local seconds = time
	local minutes = math.floor((seconds / 60) % 60)
	local millisecs = math.floor((seconds - math.floor(seconds)) * 100)
	millisecs = millisecs > 99 and 99 or millisecs
	seconds = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", minutes, seconds, millisecs)
end
]]

net.Receive(tag, function()
	local time = CurTime()

	chat.AddText(color_white, "[WARNING] ", Color(255, 0, 0), "AUTOMATIC SERVER RESTART IN 1 MINUTE")

	--[[surface.PlaySound("ambient/alarms/alarm_citizen_loop1.wav")
	
	hook.Add("HUDPaint", tag, function() -- Unused countdown
		surface.SetDrawColor(color_black)
		surface.DrawRect(scrW * 0.5 - ((scrW * 0.32) * 0.5), (scrH * 0.06), (scrW * 0.32), (scrH * 0.06))

		surface.SetDrawColor(color_white)
		surface.DrawRect(scrW * 0.5 - ((scrW * 0.315) * 0.5), (scrH * 0.065), (scrW * 0.315), (scrH * 0.05))

		surface.SetDrawColor(Color(255, 0, 0))
		surface.DrawRect(scrW * 0.5 - ((scrW * 0.315) * 0.5), (scrH * 0.065), (scrW * (0.315 - (CurTime() - time) * 0.00525)), (scrH * 0.05))

		surface.SetFont("DermaLarge")
		local stringtime = FormatTime(time - CurTime() + 60)
		local x, y = surface.GetTextSize(stringtime)
		surface.SetTextColor(Color(255, 0, 0))
		surface.SetTextPos(scrW * 0.5 - (x * 0.5),  (scrH * 0.03))
		surface.DrawText(stringtime)

		if (time - CurTime() + 60) < 10 then
			LocalPlayer():ScreenFade(2, Color(255, 0, 0, 255), 8, 0)
		end

		if (time - CurTime() + 60) < 0 then
			hook.Remove("HUDPaint", tag)
			RunConsoleCommand("stopsound")
		end
	end)]]
end)