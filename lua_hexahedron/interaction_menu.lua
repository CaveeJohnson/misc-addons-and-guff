local required_default_time_hold = 0.3
local required_dispenser_time_hold = 1
local distance_max = 92


local dist_check = distance_max*distance_max
local function check(ply, ent, printer)
	if not IsValid(ent) then return end
	if not ent.PresetMaxHealth then return end
	if printer and not ent.IsPrinter then return end
	if IsValid(ent:CPPIGetOwner()) and ply ~= ent:CPPIGetOwner() then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > dist_check then return end
	if SERVER and not ent.CurrentValue then return end

	return true
end

if SERVER then

util.AddNetworkString("UpgradePrinter")
util.AddNetworkString("MaxUpgradePrinter")
util.AddNetworkString("SellPrinter")

net.Receive("UpgradePrinter", function(_, ply)
	local ent = net.ReadEntity()
	if not check(ply, ent, true) then return end

	ent:Upgrade(ply)
end)

net.Receive("MaxUpgradePrinter", function(_, ply)
	local ent = net.ReadEntity()
	if not check(ply, ent, true) then return end

	for i = 1, (ent.MaxLevel or 1024) do
		local r = ent:Upgrade(ply, true)
		if r == false then break end
	end
end)

net.Receive("SellPrinter", function(_, ply)
	local ent = net.ReadEntity()
	if not check(ply, ent, false) then return end
	if ply:InRaid() then return end

	BaseWars.UTIL.PayOut(ent, ply)
	ent:Remove()
end)

else

local PrinterPanel
local function OpenPrinterPanel(printer, sellonly)
	if not IsValid(printer) then return end
	if IsValid(PrinterPanel) then PrinterPanel:Close() end

	PrinterPanel = vgui.Create("DFrame")
	PrinterPanel:SetSize(150, (sellonly and 30 or 90) + 34)
	PrinterPanel:Center()
	PrinterPanel:SetTitle("Interaction Menu")
	PrinterPanel:ShowCloseButton(false)
	PrinterPanel:MakePopup()

	function PrinterPanel:Think()
		if not LocalPlayer():KeyDown(IN_USE) then
			self:Close()
		end
	end

	if not sellonly then
		local Upg = vgui.Create("DButton", PrinterPanel)
		Upg:SetText("Upgrade")
		Upg:Dock(TOP)
		Upg:SetSize(150, 30)
		Upg.DoClick = function()
			net.Start("UpgradePrinter")
				net.WriteEntity(printer)
			net.SendToServer()
		end

		local MaxUpg = vgui.Create("DButton", PrinterPanel)
		MaxUpg:SetText("Max Upgrade")
		MaxUpg:Dock(TOP)
		MaxUpg:SetSize(150, 30)
		MaxUpg.DoClick = function()
			net.Start("MaxUpgradePrinter")
				net.WriteEntity(printer)
			net.SendToServer()

			if IsValid(PrinterPanel) then PrinterPanel:Close() end
		end
	end

	local Sell = vgui.Create("DButton", PrinterPanel)
	Sell:SetText("Sell")
	Sell:Dock(TOP)
	Sell:SetSize(150, 30)
	Sell.DoClick = function()
		net.Start("SellPrinter")
			net.WriteEntity(printer)
		net.SendToServer()

		if IsValid(PrinterPanel) then PrinterPanel:Close() end
	end
end

local start, in_menu = 0, false
local target, need_repress = nil, false
hook.Add("Think", "printermenu", function()
	local ply = LocalPlayer()
	local ct = CurTime()

	if not ply:Alive() then
		return
	end

	local e = ply:KeyDown(IN_USE)
	if not e then
		start = ct
		target = nil
		in_menu = false
		need_repress = false
	elseif not need_repress and not in_menu then
		local ent = ply:GetEyeTrace().Entity
		target = target or ent

		if ent ~= target or not check(ply, target, false) then
			start = ct
			target = nil
			in_menu = false
			need_repress = true

			return
		end

        local time_hold = required_default_time_hold
        if IsValid(target) and target:GetClass():match("bw_dispenser_*") then
            time_hold = required_dispenser_time_hold
        end

		if ct - start > time_hold then
            if target.beingPhysgunned then
                if table.HasValue(target.beingPhysgunned, ply) then
                    need_repress = true
                    return
                end
            end

			OpenPrinterPanel(target, not target.IsPrinter)
			in_menu = true
		end
	end
end)

end
