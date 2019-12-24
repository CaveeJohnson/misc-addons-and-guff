local scrW, scrH = ScrW(), ScrH()

function OpenMOTD(time)
	time = tonumber(time) or 10

	local frame = vgui.Create("DFrame")
	frame:SetSize(scrW * 0.9, scrH * 0.9)
	frame:SetTitle("MOTD")
	frame:Center()
	frame:ShowCloseButton(false)
	frame:MakePopup()

	local motd = frame:Add("DHTML")
	motd:Dock(FILL)
	motd:OpenURL([[http://hexahedron.pw/forums/showthread.php?tid=17&pid=41#pid41]])

	local closebutton = frame:Add("DButton")
	closebutton:Dock(BOTTOM)
	closebutton:SetText("Closable in ... " .. time .. " seconds")
	closebutton:SetEnabled(false)

	closebutton.OnMousePressed = function(self)
		if not self:IsEnabled() then
			closebutton.pressed = (closebutton.pressed or 0) + 1
			if closebutton.pressed >= 10 then
				timer.Destroy("closebutton")
				closebutton:SetText("Close")
				closebutton:SetEnabled(true)
				surface.PlaySound("vo/citadel/br_whatittakes.wav")
			end
		else
			frame:Remove()
		end
	end

	timer.Create("closebutton", 1, time, function()
		if not IsValid(closebutton) then timer.Destroy("closebutton") return end
		local amount = timer.RepsLeft("closebutton")

		if amount == 0 then
			closebutton:SetEnabled(true)
			closebutton:SetText("Close")
			return
		end

		closebutton:SetText("Closable in ... " .. amount .. " second" .. (amount > 1 and "s" or ""))
	end)

end
hook.Add("PostRender", "OpenMOTD", function()
	OpenMOTD()
	hook.Remove("PostRender", "OpenMOTD")
end)
