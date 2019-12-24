-- duplicator support

local SMALL_PLATE  = 1
local NORMAL_PLATE = 2
local BIG_PLATE    = 3
local HUGE_PLATE   = 4
local HOLYSHIT_PLATE = 5

-- image resolution, also makes text smaller, think of it like DPI
local GLOBAL_SCALE = 2

local models = {
	[SMALL_PLATE]  = {"models/hunter/plates/plate1x1.mdl", 1, "Small"},
	[NORMAL_PLATE] = {"models/hunter/plates/plate2x2.mdl", 2, "Normal"},
	[BIG_PLATE]    = {"models/hunter/plates/plate3x3.mdl", 3, "Large"},
	[HUGE_PLATE]   = {"models/hunter/plates/plate4x4.mdl", 4, "Huge"},
	[HOLYSHIT_PLATE] = {"models/hunter/plates/plate16x16.mdl", 16, "Holy Shit"},
}

local TOOLPROP_WHITELIST = {
	["weld"] = true,
	["precision"] = true,
	["camera"] = true,
	["nocollide"] = true,
	["remover"] = true,

	["remove"] = true,
	["keepupright"] = true,
	["extinguish"] = true,
}

-- allowed forms, example bad.example.com
-- example
-- bad.example
-- bad.example.com
--
-- you can blacklist danbooru while not safebooru (same domain)
-- for example
local DOMAIN_BLACKLIST = {

}

local DRAW_WEPS = {
	["weapon_physgun"] = true,
	["gmod_tool"] = true,
}

local HTML_FORMAT = [[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<style>
		html, body {
			margin: 0;
		}

		img {
			text-align: center;
			position: absolute;
			margin: auto;
			top: 0;
			right: 0;
			bottom: 0;
			left: 0;

			max-width: 100%;
			max-height: 100%;
		}
	</style>
</head>
<body>
	<img src="{URL}"></img>
</body>
</html>
]]

setfenv(1, _G)

local CLASS_NAME = "canvas"
local tag = "Canvas"

easylua.StartEntity(CLASS_NAME)
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.ClassName = CLASS_NAME

	ENT.PrintName		= tag
	ENT.Author			= "Q2F2\nZeni\nuser4992"
	ENT.Purpose			= "Display your custom images."
	ENT.Category 		= "Fun + Games"
	ENT.Spawnable 		= true
	ENT.AdminOnly 		= true
	ENT.RenderGroup     = RENDERGROUP_TRANSLUCENT

	local function compressData(data)
		local compressed = util.Compress(data)
		local len        = string.len(compressed)

		return len, compressed
	end

	local URL_START  = "^https?://"
	local PNG_HEADER = "^\x89\x50\x4E\x47"
	local JPG_HEADER = "^\xFF\xD8"
	local GIF_HEADER = "^\x47\x49\x46\x38"

	local URL_PARSE_CACHE_DENY = {}
	local URL_PARSE_CACHE_WAIT = {}

	-- return good, loading
	local function validateUrl(url)
		if CLIENT and system.IsLinux() then return end
		if URL_PARSE_CACHE_DENY[url] then return false, URL_PARSE_CACHE_DENY[url] end

		local is_done = URL_PARSE_CACHE_WAIT[url]
		if is_done ~= nil then
			if not is_done then
				return false, "Loading..."
			end

			return true, nil
		end

		if not url:match(URL_START) then
			URL_PARSE_CACHE_DENY[url] = "Not a valid URL."
			return false, URL_PARSE_CACHE_DENY[url]
		end

		local domain = url:match(URL_START .. "(.-)/")
		if not domain then
			URL_PARSE_CACHE_DENY[url] = "Not a valid URL."
			return false, URL_PARSE_CACHE_DENY[url]
		end

		local domain_seg = domain:Split(".")
		local domain_seg_count = #domain_seg
		if
			DOMAIN_BLACKLIST[domain] or
			(domain_seg_count == 2 and DOMAIN_BLACKLIST[domain_seg[1]]) or
			DOMAIN_BLACKLIST[domain_seg[domain_seg_count-1]] or
			(domain_seg_count > 2 and DOMAIN_BLACKLIST[domain_seg[domain_seg_count-2] ..  "." .. domain_seg[domain_seg_count-1]])
		then
			URL_PARSE_CACHE_DENY[url] = "Blacklisted domain '" .. domain .. "'.'"
			return false, URL_PARSE_CACHE_DENY[url]
		end

		URL_PARSE_CACHE_WAIT[url] = false
		http.Fetch(url, function(body, size, headers, code)
			if code >= 400 and code < 600 then -- bad code
				URL_PARSE_CACHE_DENY[url] = "Failed to validate: http status " .. tostring(code)
				return
			end

			if not (body:match(PNG_HEADER) or body:match(JPG_HEADER) or body:match(GIF_HEADER)) then
				URL_PARSE_CACHE_DENY[url] = "Failed to validate: not a recognised format"
				return
			end

			URL_PARSE_CACHE_WAIT[url] = true
		end, function(err)
			URL_PARSE_CACHE_DENY[url] = "Failed to validate: " .. err
		end)

		return false, "Loading..."
	end

	local NET_REQUEST_MODEL = 1
	local NET_REQUEST_URL   = 2

	function ENT:SetupDataTables()
		self:NetworkVar("String", 0, "URL")
		self:NetworkVar("Int", 0, "SizeIndex")
	end

	function ENT:CanConstruct()
		return false
	end

	function ENT:CanTool(_, _, tool)
		if TOOLPROP_WHITELIST[tool] then return end

		return false
	end

	function ENT:CanProperty(_, prop)
		if TOOLPROP_WHITELIST[prop] then return end

		return false
	end

	if SERVER then
		util.AddNetworkString(tag)

		function ENT:SpawnFunction(ply, tr, ClassName)
			net.Start(tag)
				net.WriteUInt(NET_REQUEST_MODEL, 4)
			net.Send(ply)

			ply.__canvas_didSpawn = true
		end

		function ENT:Initialize()
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
			self:SetUseType(SIMPLE_USE)
			self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end

		local function requestURL(ply, ent)
			net.Start(tag)
				net.WriteUInt(NET_REQUEST_URL, 4)
				net.WriteEntity(ent)
			net.Send(ply)
		end

		function ENT:Use(_, ply)
			local owner = self:CPPIGetOwner()
			if ply ~= owner and not ply:IsAdmin() then ply:ChatPrint("You don't own this!") return end

			requestURL(ply, self)
		end

		function ENT:SetSize(size_index, dont_respawn)
			local mdl = models[size_index]
			if not mdl then return false end

			self:SetModel(mdl[1])
			self:SetSizeIndex(size_index)

			if not dont_respawn then
				self:Spawn()
				self:Activate()
			end

			return true
		end

		net.Receive(tag, function(_, ply)
			local state = net.ReadUInt(4)

			if state == NET_REQUEST_MODEL then
				if not ply.__canvas_didSpawn and hook.Run("PlayerSpawnSENT", ply, CLASS_NAME) == false then return end

				local size_index = net.ReadUInt(4)

				local tr       = ply:GetEyeTrace()
				local SpawnPos = tr.HitPos + tr.HitNormal * 8
				local Angles   = ply:EyeAngles()
				Angles.p = 0

				local ent = ents.Create(CLASS_NAME)
					ent:SetPos(SpawnPos)
					ent:SetAngles(Angles)
					ent:SetSize(size_index, true)
				ent:Spawn()
				ent:Activate()

				hook.Run("PlayerSpawnedSENT", ply, ent)
				if ply.AddCleanup then
					ply:AddCleanup(CLASS_NAME, ent)

					undo.Create(tag)
						undo.AddEntity(ent)
						undo.SetPlayer(ply)
					undo.Finish()
				end

				ply.__canvas_didSpawn = nil
				return ent
			elseif state == NET_REQUEST_URL then
				local ent = net.ReadEntity()
				if not ent:IsValid() then return end

				local owner = ent:CPPIGetOwner()
				if ply ~= owner and not ply:IsAdmin() then return end

				local len = net.ReadUInt(16)
				if not len then return end

				local url = util.Decompress(net.ReadData(len))
				if not url then return end

				ent:SetURL(url)
			end
		end)

		function ENT:recreate()
			local new = ents.Create(CLASS_NAME)
				new:SetPos(self:GetPos())
				new:SetAngles(self:GetAngles())
				new:SetURL(self:GetURL())
				new:SetSize(self:GetSizeIndex(), true)
			new:Spawn()
			new:Activate()

			new:CPPISetOwner(self:CPPIGetOwner())

			self:Remove()
		end

		function g_recreateAllCanvas()
			for _, v in ipairs(ents.FindByClass(CLASS_NAME)) do pcall(v.recreate, v) end
		end

		hook.Add("RaidStart", "canvas-fade", function()
			for _, v in ipairs(ents.FindByClass(CLASS_NAME)) do
				if not IsValid(v:CPPIGetOwner()) or v:CPPIGetOwner():InRaid() then
					v:SetNotSolid(true)
				end
			end
		end)

		hook.Add("RaidEnded", "canvas-fade", function()
			for _, v in ipairs(ents.FindByClass(CLASS_NAME)) do v:SetNotSolid(false) end
		end)
	else
		local hentai = CreateClientConVar("canvas_allow_hentai", "0", true, true, "Should canvas show shortcut for NSFW site and display images from it?")
		local yiff_in_hell = CreateClientConVar("canvas_allow_disgusting_furry_shit", "0", true, true, "ew")
		local gifs = CreateClientConVar("canvas_allow_gif", "1", true, true, "Should canvas show gifs?")
		local enabled = CreateClientConVar("canvas_enabled", "1", true, true, "Should canvas draw at all?")

		language.Add("Undone_" .. tag, "Undone Canvas")
		function ENT:Initialize()
			self:initPanel()
		end

		function ENT:initPanel()
			if CLIENT and system.IsLinux() then return end

			if IsValid(self.image_html) then self.image_html:Remove() end
			if IsValid(self.image_frame) then self.image_frame:Remove() end

			local frame = vgui.Create("DFrame")
				frame:SetSize(480 * GLOBAL_SCALE, 480 * GLOBAL_SCALE)
				frame:SetPaintedManually(true)
				frame:ShowCloseButton(false)
				frame:SetTitle("")
				frame.Paint = function() end

			local html = frame:Add("DHTML")
				frame.html = html

			frame.PerformLayout = function(this, w, h)
				if not IsValid(this.html) then return end

				this.html:SetPos(0, 0)
				this.html:SetSize(w, h)
			end

			self.image_frame = frame
			self.image_html  = html

			local url = self:GetURL()
			if url ~= "" then
				local good, _ = validateUrl(url)

				if good then
					self.image_html:SetHTML(HTML_FORMAT:Replace("{URL}", url))
					self._urlCached = url
				end
			end

			return IsValid(frame) and IsValid(html)
		end

		function ENT:invalidateCache()
			self._urlCached = nil
			self:initPanel()
		end

		local dist_sqr = 1500^2

		function ENT:DrawTranslucent()
			if CLIENT and system.IsLinux() then self:DrawModel() return end

			if not self.GetURL then return end -- late load hack
			if not enabled:GetBool() then
				if IsValid(self.image_html) then self.image_html:Remove() end
				if IsValid(self.image_frame) then self.image_frame:Remove() end

				self:DrawModel()
				return
			end

			--if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > dist_sqr then return end

			local url = self:GetURL()
			if not self.image_frame:IsValid() and not self:initPanel() then error(tag .. ": Failed to created HTML panel") end

			local wep = LocalPlayer():GetActiveWeapon()
			local not_cached = not self._urlCached or self._urlCached ~= url
			if (IsValid(wep) and DRAW_WEPS[wep:GetClass()]) or not_cached then
				render.SetBlend(0.3)
					self:DrawModel()
				render.SetBlend(1)
			else
				self:DestroyShadow()
			end

			local size_index = self:GetSizeIndex()
			if size_index <= 0 then return end

			local _size = models[size_index][2]
			local pos = self:GetPos()
			pos = pos + self:GetForward() * (23.975 * _size)
			pos = pos + self:GetUp() * -1.44
			pos = pos + self:GetRight() * (-23.975 * _size)

			local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetUp(), -90)

			cam.Start3D2D(pos, ang, _size / (10 * GLOBAL_SCALE))
				if url == "" then
					draw.SimpleText("Press E to set URL.", "DermaLarge", 240 * GLOBAL_SCALE, 240 * GLOBAL_SCALE, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				elseif not_cached then
					local good, msg = validateUrl(url)

					if good then
						self.image_html:SetHTML(HTML_FORMAT:Replace("{URL}", url))
						self._urlCached = url
					else
						draw.SimpleText(msg, "DermaLarge", 240 * GLOBAL_SCALE, 240 * GLOBAL_SCALE, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				else
					if not hentai:GetBool() and (
						(url:match("https?://.-%.donmai%.us") and not url:match("https?://safebooru%.donmai%.us")) or
						url:match("gelbooru") or url:match("hentai") or url:match("waifu2x") or url:match("shadbase")
					) then
						draw.SimpleText("NSFW content hidden: canvas_allow_hentai 1", "DermaLarge", 240 * GLOBAL_SCALE, 240 * GLOBAL_SCALE, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					elseif not yiff_in_hell:GetBool() and (
						url:match("e621") or url:match("facdn.net/art")
					) then
						draw.SimpleText("Furry content hidden: canvas_allow_disgusting_furry_shit 1", "DermaLarge", 240 * GLOBAL_SCALE, 240 * GLOBAL_SCALE, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					elseif not gifs:GetBool() and url:match("gif$") then
						draw.SimpleText("GIF hidden: canvas_allow_gifs 1", "DermaLarge", 240 * GLOBAL_SCALE, 240 * GLOBAL_SCALE, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					else
						self.image_frame:PaintManual()
					end
				end
			cam.End3D2D()
		end

		function ENT:SendURL(url)
			net.Start(tag)
				net.WriteUInt(NET_REQUEST_URL, 4)
				net.WriteEntity(self)

				local len, data = compressData(url)
				net.WriteUInt(len, 16)
				net.WriteData(data, len)
			net.SendToServer()
		end

		function ENT:OnRemove()
			if CLIENT and system.IsLinux() then return end

			if self.image_html:IsValid() then
				self.image_html:Remove()
			end

			if self.image_frame:IsValid() then
				self.image_frame:Remove()
			end
		end

		local function createUI()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("Model selection")

			local n = 0
			for k, mdl in ipairs(models) do
				local spawn = frame:Add("SpawnIcon")
				spawn:SetSize(64, 64)
				spawn:Dock(LEFT)
				spawn:SetModel(mdl[1])

				spawn.DoClick = function(self)
					if IsValid(frame) then frame:Remove() end

					net.Start(tag)
						net.WriteUInt(NET_REQUEST_MODEL, 4)
						net.WriteUInt(k, 4)
					net.SendToServer()
				end

				n = n + 1
			end

			frame:SetSize((64 + 2) * n + 4, 64 + 34)

			frame:Center()
			frame:MakePopup()
		end

		local function openBrowser(url, jquery, callback)
			if IsValid(g_canvasBrowser) then g_canvasBrowser:Close() end

			g_canvasBrowser = vgui.Create("DFrame")
			local f = g_canvasBrowser
				f:SetSize(ScrW() - 100, ScrH() - 130)
				f:Center()
				f:MakePopup()
				f:SetVisible(false)
				f:SetDeleteOnClose(true)
				f:SetBackgroundBlur(true)

				f:SetTitle("")

				function f:Paint() end

			f.controls = vgui.Create("DHTMLControls", f)
			local c = f.controls
				c:Dock(TOP)

			f.html = vgui.Create("DHTML", f)
			local h = f.html
				h:Dock(FILL)
				h:SetAllowLua(true)

				h:AddFunction("canvas", "callback", function(href)
					callback(href)
					g_canvasBrowser:Close()
				end)

				function h:OnFinishLoadingDocument(str)
					self:RunJavascript("$('" .. jquery .. "').click(function() {canvas.callback($(this).attr('href'));})")
				end

			c:SetHTML(h)
			c.AddressBar:SetText(url)
			h:OpenURL(url)

			g_canvasBrowser:SetVisible(true)
			g_canvasBrowser:MoveToFront()

			g_canvasBrowser:MakePopup()
			g_canvasBrowser:DoModal()
		end

		function Derma_StringRequest_NoFocus( strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText )

			local Window = vgui.Create( "DFrame" )
			Window:SetTitle( strTitle or "Message Title (First Parameter)" )
			Window:SetDraggable( false )
			Window:ShowCloseButton( false )
			--Window:SetBackgroundBlur( true )
			--Window:SetDrawOnTop( true )

			local InnerPanel = vgui.Create( "DPanel", Window )
			InnerPanel:SetPaintBackground( false )

			local Text = vgui.Create( "DLabel", InnerPanel )
			Text:SetText( strText or "Message Text (Second Parameter)" )
			Text:SizeToContents()
			Text:SetContentAlignment( 5 )
			Text:SetTextColor( color_white )

			local TextEntry = vgui.Create( "DTextEntry", InnerPanel )
			TextEntry:SetText( strDefaultText or "" )
			TextEntry.OnEnter = function() Window:Close() fnEnter( TextEntry:GetValue() ) end

			local ButtonPanel = vgui.Create( "DPanel", Window )
			ButtonPanel:SetTall( 30 )
			ButtonPanel:SetPaintBackground( false )

			local Button = vgui.Create( "DButton", ButtonPanel )
			Button:SetText( strButtonText or "OK" )
			Button:SizeToContents()
			Button:SetTall( 20 )
			Button:SetWide( Button:GetWide() + 20 )
			Button:SetPos( 5, 5 )
			Button.DoClick = function() Window:Close() fnEnter( TextEntry:GetValue() ) end

			local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
			ButtonCancel:SetText( strButtonCancelText or "Cancel" )
			ButtonCancel:SizeToContents()
			ButtonCancel:SetTall( 20 )
			ButtonCancel:SetWide( Button:GetWide() + 20 )
			ButtonCancel:SetPos( 5, 5 )
			ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
			ButtonCancel:MoveRightOf( Button, 5 )

			ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

			local w, h = Text:GetSize()
			w = math.max( w, 400 )

			Window:SetSize( w + 50, h + 25 + 75 + 10 )
			Window:Center()

			InnerPanel:StretchToParent( 5, 25, 5, 45 )

			Text:StretchToParent( 5, 5, 5, 35 )

			TextEntry:StretchToParent( 5, nil, 5, nil )
			TextEntry:AlignBottom( 5 )

			TextEntry:RequestFocus()
			TextEntry:SelectAllText( true )

			ButtonPanel:CenterHorizontal()
			ButtonPanel:AlignBottom( 8 )

			Window:MakePopup()
			--Window:DoModal()

			return Window

		end

		net.Receive(tag, function()
			local state = net.ReadUInt(4)

			if state == NET_REQUEST_MODEL then
				createUI()
			elseif state == NET_REQUEST_URL then
				local ent = net.ReadEntity()
				if not ent:IsValid() then return end

				local pan = Derma_StringRequest_NoFocus("Input your URL",
[[WARNING: This must be THE IMAGE, ONLY THE IMAGE, AND NOTHING BUT THE IMAGE.
This means no google redirects, no blog posts, etc. Good URLs will probably end in a file extension.

Supported formats: PNG, JPG, GIF
NOTE: 'gif services' such as GIPHY are wrap their images in a HTML page, breaking support.]],
					ent:GetURL(),
					function(txt)
						ent:SendURL(txt)
					end
				)

				local sfw = vgui.Create("DButton", pan)
					sfw:SetText("Safebooru")
					sfw:SizeToContents()
					sfw:SetSize(sfw:GetWide() + 6, 20)
					function sfw:DoClick()
						openBrowser(
							"https://safebooru.donmai.us/posts?utf8=✓",
							[[a[href*=".donmai.us/data/"][id!="image-resize-link"]:first]],
							function(txt)
								ent:SendURL(txt)
								pan:Close()
							end
						)
					end

				local is_hentai = hentai:GetBool()

				local dan
				if is_hentai then
					dan = vgui.Create("DButton", pan)
						dan:SetText("Danbooru (NSFW)")
						dan:SizeToContents()
						dan:SetSize(dan:GetWide() + 6, 20)
						function dan:DoClick()
							openBrowser(
								"https://danbooru.donmai.us/posts?utf8=✓&tags=-rating:safe",
								[[a[href*=".donmai.us/data/"][id!="image-resize-link"]:first]],
								function(txt)
									ent:SendURL(txt)
									pan:Close()
								end
							)
						end
				end

				function pan:PerformLayout(w, h)
					DFrame.PerformLayout(self, w, h)

					sfw:SetPos(w - sfw:GetWide() - 2, 2)
					if is_hentai then dan:SetPos(w - dan:GetWide() - 2 - sfw:GetWide() - 2, 2) end
				end
			end
		end)
	end
easylua.EndEntity()

local canvas_order = 3300

local function addProp(name, config)
	config.Order = canvas_order
	canvas_order = canvas_order + 1

	properties.Add(name, config)
end

local function isCanvas(_, ent, ply)
	return IsValid(ent) and IsValid(ply) and ent.GetURL and ent:GetURL() ~= ""
end

local function isCanvas2(_, ent, ply)
	return IsValid(ent) and IsValid(ply) and ent.GetURL
end

addProp(tag .. "-copyurl", {
	MenuLabel =	"Copy URL",
	MenuIcon  = "icon16/link_edit.png",
	Filter    = isCanvas,

	Action    = function(_, ent)
		SetClipboardText(ent:GetURL())
	end
})

addProp(tag .. "-openurl", {
	MenuLabel =	"Open URL",
	MenuIcon  = "icon16/link_go.png",
	Filter    = isCanvas,

	Action    = function(_, ent)
		gui.OpenURL(ent:GetURL())
	end
})

addProp(tag .. "-invalidatecache", {
	MenuLabel =	"Invalidate Cache",
	MenuIcon  = "icon16/error.png",
	Filter    = isCanvas,

	Action    = function(_, ent)
		ent:invalidateCache()
	end
})

addProp(tag .. "-changesize", {
	MenuLabel = "Change Size",
	MenuIcon = "icon16/picture_edit.png",
	Filter = function(_, ent, ply)
		return isCanvas2(_, ent, ply) and (
			ent:CPPIGetOwner() == CPPI.CPPI_NOTIMPLEMENTED or -- fucking retards who dont follow spec :V
			ent:CPPIGetOwner() == ply
		)
	end,

	MenuOpen = function(prop, option, ent)
		local submenu = option:AddSubMenu()

		for index, v in SortedPairsByMemberValue(models, 2) do
			submenu:AddOption(v[3], function()
				prop:MsgStart()
					net.WriteEntity(ent)
					net.WriteUInt(index, 4)
				prop:MsgEnd()
			end):SetChecked(ent:GetSizeIndex() == index)
		end
	end,

	Receive = function(prop, _, ply)
		local ent = net.ReadEntity()
		local size_index = net.ReadUInt(4)

		if not properties.CanBeTargeted(ent, ply) then return end
		if not prop:Filter(ent, ply) then return end

		ent:SetSize(size_index)
	end
})
