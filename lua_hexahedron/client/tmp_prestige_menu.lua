if not prestige then return end

local function prestigeModal(me)
	local window = vgui.Create("DFrame")
	window:SetTitle("Prestige Menu")
	window:SetDraggable(false)
	window:SetBackgroundBlur(true)
	window:SetDrawOnTop(true)
	window:ShowCloseButton(false)
	--[[window.Paint = function()
		surface.SetDrawColor(0,0,0,225)
		surface.DrawRect(0,0, window:GetWide(), window:GetTall())
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0,0,window:GetWide(), window:GetTall())
		surface.SetDrawColor(255,150,0,200)
		surface.DrawRect(0, 25, window:GetWide(), 2)
	end]]

	local innerpanel = vgui.Create("DPanel", window)
		innerpanel:SetDrawBackground(false)


	local buttonPanel = vgui.Create("DPanel", window)
		buttonPanel:SetTall(30)
		buttonPanel:SetDrawBackground(false)


	local ButtonPrestige = vgui.Create("DButton", buttonPanel)
		ButtonPrestige:SetText("Prestige Now")
		ButtonPrestige:SizeToContents()
		ButtonPrestige:SetTall(20)
		ButtonPrestige:SetWide(100)
		ButtonPrestige:SetPos(5,5)
		ButtonPrestige:SetDrawBorder(false)

		ButtonPrestige.DoClick = function()
			net.Start("prestige_attempt")
			net.SendToServer()
		end


	local ButtonClose = vgui.Create("DButton", buttonPanel)
		ButtonClose:SetText("Close")
		ButtonClose:SizeToContents()
		ButtonClose:SetTall(20)
		ButtonClose:SetWide(100)
		ButtonClose:SetPos(5,5)
		ButtonClose:MoveRightOf(ButtonPrestige, 5)
		ButtonClose:SetDrawBorder(false)

		ButtonClose.DoClick = function()
			window:Close()
		end

	local pTokens = vgui.Create("DLabel", innerpanel)
		local gNR = prestige.getNextReset(me)
		pTokens:SetText("You'll get " .. prestige.nextLevelTokens(me, gNR/100) ..
			" prestige tokens.\nYou will be reset back to level " .. (gNR/100) * 5 ..
			".\nIncrease in prestige to rank ".. prestige.getNextReset(me)/100 ..
			".\nStarting money will increase to £" .. BaseWars.NumberFormat(BaseWars.Config.StartMoney * ((gNR/100) + 1) + 1000))
		pTokens:SizeToContents()
		pTokens:SetContentAlignment(5)
		--pTokens:SetTextColor(Color(255,150,0,255))


	local w,h = pTokens:GetSize()
	w = math.min(w, 400)
	window:SetSize(w + 150, h + 55 + 75 + 10)
	window:Center()

	innerpanel:StretchToParent(5,25,5,45)

	pTokens:Center()

	buttonPanel:SetWide(ButtonPrestige:GetWide() + 5 + ButtonClose:GetWide() + 10)
	buttonPanel:CenterHorizontal()
	buttonPanel:AlignBottom(8)

	window:MakePopup()
	window:DoModal()
end

local function generateShopRow(item, icon, ranks, cost)
	local row = vgui.Create("DPanel")
		row:SetHeight(50)
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, 4)

		local frac = math.random()
		row.Paint = function(self, w, h)
			DPanel.Paint(self, w, h)

			draw.SimpleText(
				item or "UNKNOWN",
				"DermaLarge",
				50, 2,
				color_black,
				TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
			)

			draw.SimpleText(
				cost and "Price: " .. cost or "Price: 0",
				"DermaDefault",
				50, h - 8,
				color_black,
				TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM
			)

			local th = 24
			local thmid = h / 2 - th / 2
			local start = 50 + 150
			local sz = w - start - 150 - 30
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(start - 1, thmid - 1, sz + 2, th + 2)

			surface.SetDrawColor(100, 0, 0)
			surface.DrawRect(start + 1, thmid + 1, (sz - 2) * frac, th - 2)
		end

	local img = vgui.Create("DImage", row)
		img:SetImage(icon or "icon16/tick.png")
		img:SetSize(32, 32)
		img:Dock(LEFT)
		img:DockMargin(9, 9, 9, 9)

	local up = vgui.Create("DButton", row)
		up:SetWidth(150)
		up:Dock(RIGHT)
		up:DockMargin(6, 6, 6, 6)

		up:SetText("Upgrade")
		up:SetEnabled(false)
		up.Think = function(self)
			DButton.Think(self)

			self:SetEnabled(false)
		end
		up.DoClick = function(self)
			--
		end

	return row
end

local blurTex = Material("pp/blurscreen")
local function blurRect(pan, x, y, ex, ey)
	surface.SetMaterial(blurTex)	
	surface.SetDrawColor(255, 255, 255, 255)	
	render.UpdateScreenEffectTexture()

	surface.SetMaterial(blurTex)

	local px, py = pan:LocalToScreen(0, 0)
	render.SetScissorRect(px + x, py + y, px + ex, py + ey, true)
		for i = 1, 6 do
			blurTex:SetFloat("$blur", 1 * i)
			blurTex:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(-px, -py, ScrW(), ScrH())
		end
	render.SetScissorRect(0, 0, 0, 0, false)
end

local function makePrestigeMenu()
	if prestige.frame then prestige.frame:Remove() end
	local ply = LocalPlayer()

	prestige.frame = vgui.Create("DFrame")
	local f = prestige.frame
		f:SetDeleteOnClose(false)
		f:SetSize(800, 500)
		f:SetTitle("Prestige Menu")

	prestige.frame.shop = vgui.Create("DScrollPanel", f)
	local sh = prestige.frame.shop
		sh:Dock(FILL)
		sh:DockMargin(0, 12, 0, 4)
		if ply:GetPrestigeRank() < 1 then
			sh.PaintOver = function(self, w, h)
				blurRect(self, 0, 0, w, h)

				surface.SetDrawColor(255, 255, 255, 60)
				surface.DrawRect(0, h / 2 - 50, w, 100)

				draw.SimpleText(
					"PRESTIGE PERKS LOCKED",
					"DermaLarge",
					w / 2, h / 2 - 20,
					color_black,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
				)

				draw.SimpleText(
					"ASCEND TO UNLOCK",
					"DermaLarge",
					w / 2, h / 2 + 20,
					color_black,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
				)
			end
			--sh:SetEnabled(false)
		end

	prestige.frame.top = vgui.Create("DPanel", f)
	local tp = prestige.frame.top
		tp:SetHeight(40)
		tp:Dock(TOP)

		tp.Paint = function(self, w, h)
			DPanel.Paint(self, w, h)

			draw.SimpleText(
				"Prestige Rank: " .. string.Comma(ply:GetPrestigeRank()),
				"DermaDefault",
				w - 4, 4,
				color_black,
				TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP
			)

			draw.SimpleText(
				"Tokens: " .. string.Comma(ply:GetPrestigeTokens()),
				"DermaDefault",
				w - 4, h - 18,
				color_black,
				TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP
			)
		end

	prestige.frame.top.attempt = vgui.Create("DButton", tp)
	local at = prestige.frame.top.attempt
		at:SetWidth(150)
		at:Dock(LEFT)
		at:DockMargin(4, 4, 4, 4)

		at:SetText("Attempt Ascension")
		at:SetEnabled(prestige.getNextReset(ply) <= ply:GetLevel())
		at.Think = function(self)
			DButton.Think(self)

			self:SetEnabled(prestige.getNextReset(ply) <= ply:GetLevel())
		end
		at.DoClick = function(self)
			prestigeModal(ply)
		end

		for i = 0, 10 do
			local test = generateShopRow()
			sh:AddItem(test)
		end

	f:Center()
	f:MakePopup()
end

concommand.Add("prestige_menu", makePrestigeMenu)

local function createNotExist()
	if not IsValid(prestige.frame) then
		makePrestigeMenu()
		return true
	end
end

local a
hook.Add("Think", "prestige_menu", function()
	local me = LocalPlayer()

    local wep = me:GetActiveWeapon()
	if wep ~= NULL and wep.CW20Weapon and wep.dt.State == (CW_CUSTOMIZE or 4) then return end

	if input.IsKeyDown(KEY_F4) then
		if not a then
			a = true

			if createNotExist() then return end
			if prestige.frame:IsVisible() then
				prestige.frame:Close()
			else
				prestige.frame:Show()
			end
		end
	else
		a = nil
	end
end)
