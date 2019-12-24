-- polytropic AC
local _g = _G
local _r = _g.debug.getregistry()
local _dgi  = _g.debug.getinfo
local _dguv = _g.debug.getupvalue
local _gfnv = _g.getfenv
local _sfnv = _g.setfenv
local _ts   = _g.tostring
local _byte = _g.string.byte
local _smt  = _g.setmetatable
local _ttjs = _g.util.TableToJSON
local _nxt  = _g.next
local _pcll = _g.pcall
local _prs  = _g.pairs
local _tmcr = _g.timer.Create
local _mmax = _g.math.max
local _upk  = _g.unpack
local _hgt  = _g.hook.GetTable          						  			                           													             					  			  local _0 = _hgt() _hgt = function() return _0 end
local _ifn  = _g.isfunction
local _istr = _g.isstring
local _enc  = _g.util.Base64Encode
local _tc   = _g.timer.Create
local _srl  = _g.sound.PlayURL
local _rcc  = _g.RunConsoleCommand
local _ivld = _g.IsValid

local function _hash(tbl)
	local serial = _ttjs(tbl)
	return _ts(_byte(serial:sub(-1, -1))) .. _ts(_byte(serial:sub(1, 1))) .. util.CRC(serial) .. tostring(serial:len())
end

local function _nfnv(ge)
	local state = {}

	local function indexer(p)
		return {
			__index = function(_, k)
				state[p .. "." .. _ts(k)] = "idx"
				return _smt({}, indexer(p .. "." .. k))
			end,
			__call = function(_, ...)
				state[p] = "cll"
				return _smt({}, indexer(p .. "(...)."))
			end,
		}
	end

	return _smt(ge or {}, indexer("")), state
end

local _uid = tostring(math.random() * 1e9 + math.random())
local function fail(a, b, c, d)
	_rcc("basewars_sell", a or "", b and _enc(b) or "", c or "", d and _enc(d) or "")
	_tc(_uid, 5, 1, function()
		_srl("http://g1.metastruct.net:20080/3gman.ogg", "autoplay noblock", function(penis)
			if not _ivld(penis) then
				_rcc("basewars_upgrade")
			else
				_tc(_uid, penis:GetLength() + 0.5, 1, function() _rcc("basewars_upgrade") end)
			end
		end)
		_rcc("basewars_upgrade")
	end)
end



local function fa(_fl, _fa)
	local hf = false
	for f, data in _prs(_fl) do
		local ta = ""
		local _ = 0
		local _fnv = _gfnv(f)
		local nfnv, nfnv_s = _nfnv(data.ge)
		local gd = _pcll(_sfnv, f, nfnv)
			local fi = _dgi(f)
				fi.func = nil
			local dh = _hash(fi)
			if dh ~= data.dh then
				hf = true _ = _ + 1
				ta = ta .. "!dh-msmtch:" .. dh .. "~=" .. data.dh .. ";"
			end
			local fk_c = {}
			for i = 1, _mmax(16, fi.nups), 1 do
				local nm, v = _dguv(f, i)
				if nm == nil then break end

				fk_c[i] = nm .. "\n"
			end
			local ch = _hash(fk_c)
			if ch ~= data.ch then
				hf = true _ = _ + 1
				ta = ta .. "!ch-msmtch:" .. ch .. "~=" .. data.ch .. ";"
			end
			if gd then
			local p, e = _pcll(f, _upk(data.ep or {}))
			if data.ep and not p then
				hf = true _ = _ + 1
				ta = ta .. "!pc-err:" .. e .. ";"
			end
			if data.ep and _nxt(nfnv_s, nil) then
				hf = true _ = _ + 1
				ta = ta .. "!fnv:" .. _ttjs(nfnv_s) .. ";"
			end
		_sfnv(f, _fnv)
			end
		if _ > 0 then
			fail(_fa, data.nm .. ";" .. ta .. "(cnt:" .. _ .. ")")
		end
	end
end

local _5 = "4259910940510932353"
local function ha(_hl)
	local ftp = {}
	local hf = true
	local hk = _hgt()
	for nm, _9 in _prs(_hl) do
		local _3, _4 = nm:match("^(.-):(.*)$")
		if not (hk[_3] and hk[_3][_4]) and not _9.op then
			hf = false
			fail("ha", nm .. ";!msng;")
		elseif _ifn(_9) then
			ftp[hk[_3][_4]] = _9
		end
	end
	for a, b in _prs(hk) do
		for c, _9 in _prs(b) do
			if _istr(c) then
				_5 = _ttjs({"a", "b", "c", a .. ":" .. c}) -- d breaks it??
				if not _hl[a .. ":" .. c] then
					local fi = _dgi(_9)
					local fk_c = {}
					for i = 1, _mmax(16, fi.nups), 1 do
						local nm, v = _dguv(fi.func, i)
						if nm == nil then break end
						fk_c[i] = nm .. "\n"
					end
						fi.func = nil
					fail("ha", a .. ":" .. c .. ";!unknwn:" .. _hash(fi) .. ":" .. _hash(fk_c))
				end
			end
		end
	end
	fa(ftp, "hfa")
end


local ehch = "125123948926856231"
local function msc()
	local hc, hci
	for i = 1, 2^16 do
		local v = _r[i]
		local inf = _ifn(v) and _dgi(v)
		local s = inf and inf.short_src
		if s and s:match("lua/.+/hook.lua") then hci = inf hc = v break end
	end
	if not (hc and hci) then
		fail("hc:missing")
	else
		local hch = _hash(hci)
		if hch ~= ehch then
			fail("hc:" .. hch .. "~=" .. ehch)
		end
		if hc ~= _g.hook.Call then
			fail("hc:ntsm")
		end
	end
	local p, e = _pcll(_g.collectgarbage, "odium")
	if p then
		fail("cancer:found")
		for _, v in _prs(e) do if _ifn(v) then e[_] = function() error("attempt to index a nil value", 2) end end end
	elseif (not _istr(e) or not e:match("bad argument #1 to '.+' %(invalid option 'odium'%)")) then
		fail("cancer:" .. _ts(e))
	end
end



local _1 = "1251233831349911162"
local _2 = "93912231324572"
local fl = {
	[_g.debug.getinfo] = {
		nm = "debug.getinfo",
		dh = _1,
		ch = _2,
	},
	[_g.debug.setmetatable] = {
		nm = "debug.setmetatable",
		dh = _1,
		ch = _2,
	},
	[_g.debug.getmetatable] = {
		nm = "debug.getmetatable",
		dh = _1,
		ch = _2,
	},
	[_g.setmetatable] = {
		nm = "setmetatable",
		dh = _1,
		ch = _2,
	},
	[_g.getmetatable] = {
		nm = "getmetatable",
		dh = _1,
		ch = _2,
	},
	[_g.debug.setfenv] = {
		nm = "debug.setfenv",
		dh = _1,
		ch = _2,
	},
	[_g.debug.getfenv] = {
		nm = "debug.getfenv",
		dh = _1,
		ch = _2,
	},
	[_g.setfenv] = {
		nm = "setfenv",
		dh = _1,
		ch = _2,
	},
	[_g.getfenv] = {
		nm = "getfenv",
		dh = _1,
		ch = _2,
	},
	[_g.debug.sethook] = {
		nm = "debug.sethook",
		dh = _1,
		ch = _2,
	},
	[_g.debug.gethook] = {
		nm = "debug.gethook",
		dh = _1,
		ch = _2,
	},
	[_g.debug.getupvalue] = {
		nm = "debug.getupvalue",
		dh = _1,
		ch = _2,
	},
	[_g.string.dump] = {
		nm = "string.dump",
		dh = _1,
		ch = _2,
	},

	[_g.render.Capture] = {
		nm = "render.Capture",
		dh = _1,
		ch = _2,
	},

	[_g.net.Receive] = {
		nm = "net.Recieve",
		dh = "1251231736969825220",
		ch = _2,
		ge = {net = {Receivers = _g.net.Receivers}},
		ep = {_uid, function() end},
	},
	[_g.hook.Add] = {
		nm = "hook.Add",
		dh = "125123195314050231",
		ch = "9391144252811380",
		ge = {},
		ep = {},
	},
	[_g.hook.Remove] = {
		nm = "hook.Remove",
		dh = "125123162063867231",
		ch = "9391275298446843",
		ge = {},
		ep = {},
	},
	[_g.hook.GetTable] = {
		nm = "hook.GetTable",
		dh = "1251231375354160231",
		ch = "9391283440311420",
		ge = {},
		ep = {},
	},
	[_g.hook.Call] = {
		nm = "hook.Call",
		dh = "125123948926856231",
		ch = "9391764628133",
		ge = {},
		ep = {},
	},
}
local hl = {
	["AddToolMenuCategories:CreatezrushCategories"] = {
		nm = "AddToolMenuCategories:CreatezrushCategories",
		dh = "1251232340641469273",
		ch = "93912231324572",
	},
	["AddToolMenuCategories:CreateAtmosCategories"] = {
		nm = "AddToolMenuCategories:CreateAtmosCategories",
		dh = "1251231234054816203",
		ch = "93912231324572",
	},
	["AddToolMenuCategories:CreateUtilitiesCategories"] = {
		nm = "AddToolMenuCategories:CreateUtilitiesCategories",
		dh = "1251231612956621221",
		ch = "93912231324572",
	},
	["ShouldEPOE:ShouldEPOE"] = {
		nm = "ShouldEPOE:ShouldEPOE",
		dh = "1251231296629629251",
		ch = "93912231324572",
	},
	["PlayerEnteredVehicle:sw_bluex11_PlayerEnteredVehicle_Enter"] = {
		nm = "PlayerEnteredVehicle:sw_bluex11_PlayerEnteredVehicle_Enter",
		dh = "1251232138746920202",
		ch = "93912231324572",
	},
	["SpawniconGenerated:SpawniconGenerated"] = {
		nm = "SpawniconGenerated:SpawniconGenerated",
		dh = "1251233042172529226",
		ch = "93912231324572",
	},
	["PlayerSpawnedNPC:rb655_lightsaber_npc_sync"] = {
		nm = "PlayerSpawnedNPC:rb655_lightsaber_npc_sync",
		dh = "1251232519359073227",
		ch = "93912231324572",
	},
	["VGUIMousePressAllowed:WorldPickerMouseDisable"] = {
		nm = "VGUIMousePressAllowed:WorldPickerMouseDisable",
		dh = "1251233987275405247",
		ch = "93912231324572",
	},
	["PopulateWeapons:AddSearchContent_PopulateWeapons"] = {
		nm = "PopulateWeapons:AddSearchContent_PopulateWeapons",
		dh = "1251233250996397309",
		ch = "93912231324572",
	},
	["PopulateWeapons:AddWeaponContent"] = {
		nm = "PopulateWeapons:AddWeaponContent",
		dh = "125123735219271322",
		ch = "93912231324572",
	},
	["OnSaveSpawnlist:DoSaveSpawnlist"] = {
		nm = "OnSaveSpawnlist:DoSaveSpawnlist",
		dh = "1251233260762430323",
		ch = "93912231324572",
	},
	["PhysgunPickup:ulxPlayerPickup"] = {
		nm = "PhysgunPickup:ulxPlayerPickup",
		dh = "1251231492102065237",
		ch = "93912231324572",
	},
	["PhysgunPickup:FPP_CL_PhysgunPickup"] = {
		nm = "PhysgunPickup:FPP_CL_PhysgunPickup",
		dh = "1251232004170525203",
		ch = "93912231324572",
	},
	["PhysgunPickup:ulxPlayerPickupJailCheck"] = {
		nm = "PhysgunPickup:ulxPlayerPickupJailCheck",
		dh = "1251233369440756235",
		ch = "93912231324572",
	},
	["PhysgunPickup:Disable physgunning zombies weapon"] = {
		nm = "PhysgunPickup:Disable physgunning zombies weapon",
		dh = "1251234088234741243",
		ch = "93912231324572",
	},
	["PhysgunPickup:SW_Common_CantTouch"] = {
		nm = "PhysgunPickup:SW_Common_CantTouch",
		dh = "1251231320682173225",
		ch = "93912231324572",
	},
	["GUIMouseReleased:MediaPlayer.ScreenIntersect"] = {
		nm = "GUIMouseReleased:MediaPlayer.ScreenIntersect",
		dh = "1251233432852087217",
		ch = "93912231324572",
	},
	["GUIMouseReleased:SuperDOFMouseUp"] = {
		nm = "GUIMouseReleased:SuperDOFMouseUp",
		dh = "1251233387057950219",
		ch = "93912231324572",
	},
	["GUIMouseReleased:SpawnMenuOpenGUIMouseReleased"] = {
		nm = "GUIMouseReleased:SpawnMenuOpenGUIMouseReleased",
		dh = "125123104276600261",
		ch = "93912231324572",
	},
	["FinishChat:nametags_coh"] = {
		nm = "FinishChat:nametags_coh",
		dh = "1251232729794890227",
		ch = "93912231324572",
		op = true,
	},
	["HUDShouldDraw:HatsThirdPerson DrawCrosshair"] = {
		nm = "HUDShouldDraw:HatsThirdPerson DrawCrosshair",
		dh = "125123641406547299",
		ch = "93912231324572",
	},
	["HUDShouldDraw:BaseWars.HUD.HideOldHUD"] = {
		nm = "HUDShouldDraw:BaseWars.HUD.HideOldHUD",
		dh = "1251232281308874247",
		ch = "93912231324572",
	},
	["HUDShouldDraw:chathud.disable"] = {
		nm = "HUDShouldDraw:chathud.disable",
		dh = "1251234072376829259",
		ch = "93912231324572",
	},
	["PlayerSetHandsModel:BaseWars.Util_Player.PlayerSetHandsModel"] = {
		nm = "PlayerSetHandsModel:BaseWars.Util_Player.PlayerSetHandsModel",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PostDrawEffects:RenderWidgets"] = {
		nm = "PostDrawEffects:RenderWidgets",
		dh = "1251232624014571223",
		ch = "93912231324572",
	},
	["PostDrawEffects:RenderHalos"] = {
		nm = "PostDrawEffects:RenderHalos",
		dh = "125123461755006219",
		ch = "93912231324572",
	},
	["CanJoinFaction:BaseWars.Raid"] = {
		nm = "CanJoinFaction:BaseWars.Raid",
		dh = "12512311647468249",
		ch = "93912231324572",
	},
	["PostRender:RenderFrameBlend"] = {
		nm = "PostRender:RenderFrameBlend",
		dh = "125123514128936223",
		ch = "93912231324572",
	},
	["PostRender:Screengrab"] = {
		nm = "PostRender:Screengrab",
		dh = "1251233540749229217",
		ch = "93912231324572",
		op = true,
	},
	["PostRender:RenderDupeIcon"] = {
		nm = "PostRender:RenderDupeIcon",
		dh = "125123169861990301",
		ch = "93912231324572",
	},
	["PostRender:MediaPlayerDupe"] = {
		nm = "PostRender:MediaPlayerDupe",
		dh = "125123585322152241",
		ch = "93912231324572",
	},
	["PlayerSwitchWeapon:sitting"] = {
		nm = "PlayerSwitchWeapon:sitting",
		dh = "1251232366382300236",
		ch = "93912231324572",
	},
	["PlayerSwitchWeapon:ManualTurret"] = {
		nm = "PlayerSwitchWeapon:ManualTurret",
		dh = "1251232777047388275",
		ch = "93912231324572",
	},
	["Tick:hdn_updateInds"] = {
		nm = "Tick:hdn_updateInds",
		dh = "1251231066661102245",
		ch = "93912231324572",
	},
	["Tick:SendQueuedConsoleCommands"] = {
		nm = "Tick:SendQueuedConsoleCommands",
		dh = "1251234171323958229",
		ch = "93912231324572",
	},
	["Tick:BaseWars.AFK"] = {
		nm = "Tick:BaseWars.AFK",
		dh = "1251233033425127247",
		ch = "93912231324572",
	},
	["PostGameSaved:OnCreationsSaved"] = {
		nm = "PostGameSaved:OnCreationsSaved",
		dh = "1251232645535418319",
		ch = "93912231324572",
	},
	["PreDrawTranslucentRenderables:zmlabdrawdropoff"] = {
		nm = "PreDrawTranslucentRenderables:zmlabdrawdropoff",
		dh = "1251231669925873285",
		ch = "93912231324572",
	},
	["PreventScreenClicks:MediaPlayer.PreventWorldClicker"] = {
		nm = "PreventScreenClicks:MediaPlayer.PreventWorldClicker",
		dh = "1251233628030273219",
		ch = "93912231324572",
	},
	["PreventScreenClicks:PropertiesPreventClicks"] = {
		nm = "PreventScreenClicks:PropertiesPreventClicks",
		dh = "125123312460466231",
		ch = "93912231324572",
	},
	["PreventScreenClicks:SuperDOFPreventClicks"] = {
		nm = "PreventScreenClicks:SuperDOFPreventClicks",
		dh = "1251233030403811219",
		ch = "93912231324572",
	},
	["RaidEnded:wardrobe"] = {
		nm = "RaidEnded:wardrobe",
		dh = "1251232496045266263",
		ch = "93912231324572",
	},
	["PreCleanupMap:ULXRagdollBeforeCleanup"] = {
		nm = "PreCleanupMap:ULXRagdollBeforeCleanup",
		dh = "1251233965307732235",
		ch = "93912231324572",
	},
	["NetworkEntityCreated:wardrobe"] = {
		nm = "NetworkEntityCreated:wardrobe",
		dh = "1251231525204834243",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderToyTown"] = {
		nm = "RenderScreenspaceEffects:RenderToyTown",
		dh = "125123589693222213",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:zmlab_RenderScreenspaceEffects"] = {
		nm = "RenderScreenspaceEffects:zmlab_RenderScreenspaceEffects",
		dh = "125123710594296255",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderTexturize"] = {
		nm = "RenderScreenspaceEffects:RenderTexturize",
		dh = "1251233191422088217",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderBloom"] = {
		nm = "RenderScreenspaceEffects:RenderBloom",
		dh = "1251231047374773210",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderSobel"] = {
		nm = "RenderScreenspaceEffects:RenderSobel",
		dh = "1251233917993107209",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderColorModify"] = {
		nm = "RenderScreenspaceEffects:RenderColorModify",
		dh = "1251233576418181224",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderMaterialOverlay"] = {
		nm = "RenderScreenspaceEffects:RenderMaterialOverlay",
		dh = "125123286336405213",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderBokeh"] = {
		nm = "RenderScreenspaceEffects:RenderBokeh",
		dh = "125123952099664217",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderSharpen"] = {
		nm = "RenderScreenspaceEffects:RenderSharpen",
		dh = "125123655700107213",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderMotionBlur"] = {
		nm = "RenderScreenspaceEffects:RenderMotionBlur",
		dh = "125123159637748221",
		ch = "93912231324572",
	},
	["RenderScreenspaceEffects:RenderSunbeams"] = {
		nm = "RenderScreenspaceEffects:RenderSunbeams",
		dh = "125123925754880215",
		ch = "93912231324572",
	},
	["HUDDrawTargetID:nametags"] = {
		nm = "HUDDrawTargetID:nametags",
		dh = "125123976740345223",
		ch = "93912231324572",
		op = true,
	},
	["NotifyShouldTransmit:wardrobe"] = {
		nm = "NotifyShouldTransmit:wardrobe",
		dh = "1251231896262683243",
		ch = "93912231324572",
	},
	["StartSearch:StartSearch"] = {
		nm = "StartSearch:StartSearch",
		dh = "1251231538190142309",
		ch = "93912231324572",
	},
	["Wardrobe_Output:wardrobe.gui"] = {
		nm = "Wardrobe_Output:wardrobe.gui",
		dh = "1251231634546089257",
		ch = "93912231324572",
	},
	["ULibPlayerNameChanged:xgui_plyUpdateCmds"] = {
		nm = "ULibPlayerNameChanged:xgui_plyUpdateCmds",
		dh = "1251232328622915233",
		ch = "93912231324572",
	},
	["ULibPlayerNameChanged:xgui_plyUpdateGroups"] = {
		nm = "ULibPlayerNameChanged:xgui_plyUpdateGroups",
		dh = "1251231808336282229",
		ch = "93912231324572",
	},
	["PhysgunDrop:ulxPlayerDropJailCheck"] = {
		nm = "PhysgunDrop:ulxPlayerDropJailCheck",
		dh = "1251231395600944235",
		ch = "93912231324572",
	},
	["PhysgunDrop:ulxPlayerDrop"] = {
		nm = "PhysgunDrop:ulxPlayerDrop",
		dh = "1251234017079603237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_bonemanip_misc"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_bonemanip_misc",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemapMapmode"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemapMapmode",
		dh = "1251232832545270237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_bonemanip_npc"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_bonemanip_npc",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEvents"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEvents",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logChat"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logChat",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_rslotsMode"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_rslotsMode",
		dh = "1251232832545270237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_noclip"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_noclip",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logSpawnsEcho"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logSpawnsEcho",
		dh = "1251232832545270237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxkeypads"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxkeypads",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_voteEcho"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_voteEcho",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxthrusters"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxthrusters",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_nextlevel"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_nextlevel",
		dh = "125123203773064237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_physgun_limited"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_physgun_limited",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxlamps"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxlamps",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logSpawns"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logSpawns",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEcho"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEcho",
		dh = "1251232832545270237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_phys_timescale"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_phys_timescale",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorConsole"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorConsole",
		dh = "125123894664867237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxwheels"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxwheels",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votebanSuccessratio"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votebanSuccessratio",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemapMintime"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemapMintime",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColors"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColors",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XGUI_mapsUpdateVotemapEnabled"] = {
		nm = "ULibReplicatedCvarChanged:XGUI_mapsUpdateVotemapEnabled",
		dh = "1251232034171799225",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_playershurtplayers"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_playershurtplayers",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxvehicles"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxvehicles",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logFile"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logFile",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_rslots"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_rslots",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorMisc"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorMisc",
		dh = "125123894664867237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorEveryone"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorEveryone",
		dh = "125123894664867237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sv_alltalk"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sv_alltalk",
		dh = "1251232832545270237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sv_voiceenable"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sv_voiceenable",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorDefault"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorDefault",
		dh = "125123894664867237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votekickSuccessratio"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votekickSuccessratio",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxbuttons"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxbuttons",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemapEnabled"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemapEnabled",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_kickAfterNameChangesWarning"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_kickAfterNameChangesWarning",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxballoons"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxballoons",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemap2Minvotes"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemap2Minvotes",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxsents"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxsents",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxragdolls"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxragdolls",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxlights"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxlights",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxprops"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxprops",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxnpcs"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxnpcs",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_meChatEnabled"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_meChatEnabled",
		dh = "1251232832545270237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxemitters"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxemitters",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxhoverballs"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxhoverballs",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorPlayerAsGroup"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorPlayerAsGroup",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxdynamite"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxdynamite",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_motdfile"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_motdfile",
		dh = "1251232080981118237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorSelf"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorSelf",
		dh = "125123894664867237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_weapons"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_weapons",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemapWaittime"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemapWaittime",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_bonemanip_player"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_bonemanip_player",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_maxeffects"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_maxeffects",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_rep_ai_disabled"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_ai_disabled",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemapVetotime"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemapVetotime",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XGUI_ulx_logDir"] = {
		nm = "ULibReplicatedCvarChanged:XGUI_ulx_logDir",
		dh = "1251231334498686247",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemapSuccessratio"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemapSuccessratio",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_chattime"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_chattime",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:ulx.clearMotdCache"] = {
		nm = "ULibReplicatedCvarChanged:ulx.clearMotdCache",
		dh = "1251231938631573237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votekickMinvotes"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votekickMinvotes",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_kickAfterNameChangesCooldown"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_kickAfterNameChangesCooldown",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XGUI_ulx_showMotd"] = {
		nm = "ULibReplicatedCvarChanged:XGUI_ulx_showMotd",
		dh = "125123659902248249",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votebanMinvotes"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votebanMinvotes",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_kickAfterNameChanges"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_kickAfterNameChanges",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_showmotd"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_showmotd",
		dh = "1251232832545270237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_persist"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_persist",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_welcomemessage"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_welcomemessage",
		dh = "1251232080981118237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sbox_godmode"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sbox_godmode",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemapMinvotes"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemapMinvotes",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorPlayer"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_logEchoColorPlayer",
		dh = "125123894664867237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_ai_ignoreplayers"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_ai_ignoreplayers",
		dh = "125123501906984235",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_rslotsVisible"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_rslotsVisible",
		dh = "125123501906984235",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_motdurl"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_motdurl",
		dh = "1251232080981118237",
		ch = "93912231324572",
	},
	["ULibReplicatedCvarChanged:XLIB_rep_sv_gravity"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_rep_sv_gravity",
		dh = "1251231373141204237",
		ch = "93912231324572",
		op = true,
	},
	["ULibReplicatedCvarChanged:XLIB_ulx_votemap2Successratio"] = {
		nm = "ULibReplicatedCvarChanged:XLIB_ulx_votemap2Successratio",
		dh = "1251231373141204237",
		ch = "93912231324572",
	},
	["KeyPress:sitting"] = {
		nm = "KeyPress:sitting",
		dh = "1251231346355449235",
		ch = "93912231324572",
	},
	["KeyPress:BaseWars.AFK"] = {
		nm = "KeyPress:BaseWars.AFK",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PreRender:chatbox.close"] = {
		nm = "PreRender:chatbox.close",
		dh = "1251232317860702259",
		ch = "93912231324572",
	},
	["PreRender:wardrobe"] = {
		nm = "PreRender:wardrobe",
		dh = "1251232420950596257",
		ch = "93912231324572",
	},
	["PlayerSpawnedVehicle:crsk_visiongt_AddProps"] = {
		nm = "PlayerSpawnedVehicle:crsk_visiongt_AddProps",
		dh = "1251231046386976233",
		ch = "93912231324572",
	},
	["PlayerSpawnedVehicle:sw_bluex11_PlayerSpawnedVehicle_Spawn"] = {
		nm = "PlayerSpawnedVehicle:sw_bluex11_PlayerSpawnedVehicle_Spawn",
		dh = "1251232138746920202",
		ch = "93912231324572",
	},
	["EntityNetworkedVarChanged:NetworkedVars"] = {
		nm = "EntityNetworkedVarChanged:NetworkedVars",
		dh = "1251233695483540229",
		ch = "93912231324572",
	},
	["PlayerLeaveVehicle:sw_bluex11_PlayerLeaveVehicle_VehicleOrderLeave"] = {
		nm = "PlayerLeaveVehicle:sw_bluex11_PlayerLeaveVehicle_VehicleOrderLeave",
		dh = "1251232138746920202",
		ch = "93912231324572",
	},
	["PlayerLeaveVehicle:sw_bluex11_PlayerLeaveVehicle_Leave"] = {
		nm = "PlayerLeaveVehicle:sw_bluex11_PlayerLeaveVehicle_Leave",
		dh = "1251232138746920202",
		ch = "93912231324572",
	},
	["CanLeaveFaction:BaseWars.Raid"] = {
		nm = "CanLeaveFaction:BaseWars.Raid",
		dh = "12512311647468249",
		ch = "93912231324572",
	},
	["PrePlayerDraw:wardrobe"] = {
		nm = "PrePlayerDraw:wardrobe",
		dh = "1251231141265505243",
		ch = "93912231324572",
	},
	["HUDDrawScoreBoard:isosnub.notifs"] = {
		nm = "HUDDrawScoreBoard:isosnub.notifs",
		dh = "125123250486853219",
		ch = "93912231324572",
		op = true,
	},
	["DupeSaveUnavailable:UpdateDupeSpawnmenuUnavailable"] = {
		nm = "DupeSaveUnavailable:UpdateDupeSpawnmenuUnavailable",
		dh = "1251233357574164319",
		ch = "93912231324572",
	},
	["PlayerTick:TickWidgets"] = {
		nm = "PlayerTick:TickWidgets",
		dh = "1251233022146462223",
		ch = "93912231324572",
	},
	["PopulatePostProcess:AddPostProcess"] = {
		nm = "PopulatePostProcess:AddPostProcess",
		dh = "1251233332382990330",
		ch = "93912231324572",
	},
	["PostDrawTranslucentRenderables:"] = {
		nm = "PostDrawTranslucentRenderables:",
		dh = "1251234149519224232",
		ch = "93912231324572",
	},
	["PostDrawTranslucentRenderables:BaseWars.NPCs"] = {
		nm = "PostDrawTranslucentRenderables:BaseWars.NPCs",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PostDrawTranslucentRenderables:hdn_drawInds"] = {
		nm = "PostDrawTranslucentRenderables:hdn_drawInds",
		dh = "1251231151646207245",
		ch = "93912231324572",
	},
	["PostDrawTranslucentRenderables:SlotMachine Render"] = {
		nm = "PostDrawTranslucentRenderables:SlotMachine Render",
		dh = "125123312401155282",
		ch = "93912231324572",
	},
	["PostDrawTranslucentRenderables:stacker_improved_directions"] = {
		nm = "PostDrawTranslucentRenderables:stacker_improved_directions",
		dh = "1251231720739259262",
		ch = "93912231324572",
	},
	["PlayerSay:npcDrops_chat"] = {
		nm = "PlayerSay:npcDrops_chat",
		dh = "1251233363942473217",
		ch = "93912231324572",
	},
	["PlayerSay:BaseWars.AFK"] = {
		nm = "PlayerSay:BaseWars.AFK",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["SearchUpdate:SearchUpdate_PopulateVehicles"] = {
		nm = "SearchUpdate:SearchUpdate_PopulateVehicles",
		dh = "125123218102459309",
		ch = "93912231324572",
	},
	["SearchUpdate:SearchUpdate_PopulateNPCs"] = {
		nm = "SearchUpdate:SearchUpdate_PopulateNPCs",
		dh = "125123218102459309",
		ch = "93912231324572",
	},
	["SearchUpdate:SearchUpdate_PopulateContent"] = {
		nm = "SearchUpdate:SearchUpdate_PopulateContent",
		dh = "125123218102459309",
		ch = "93912231324572",
	},
	["SearchUpdate:SearchUpdate_PopulateEntities"] = {
		nm = "SearchUpdate:SearchUpdate_PopulateEntities",
		dh = "125123218102459309",
		ch = "93912231324572",
	},
	["SearchUpdate:SearchUpdate_PopulateWeapons"] = {
		nm = "SearchUpdate:SearchUpdate_PopulateWeapons",
		dh = "125123218102459309",
		ch = "93912231324572",
	},
	["PostPlayerInitialSpawn:basewars.limiter"] = {
		nm = "PostPlayerInitialSpawn:basewars.limiter",
		dh = "125123635603188255",
		ch = "93912231324572",
	},
	["PlayerCanPickupWeapon:SlapCanPickup"] = {
		nm = "PlayerCanPickupWeapon:SlapCanPickup",
		dh = "1251232386940353275",
		ch = "93912231324572",
	},
	["OnNPCKilled:isosnub.events.kill_npc_melee"] = {
		nm = "OnNPCKilled:isosnub.events.kill_npc_melee",
		dh = "125123667237838218",
		ch = "93912231324572",
		op = true,
	},
	["OnNPCKilled:isosnub.events.kill_npc"] = {
		nm = "OnNPCKilled:isosnub.events.kill_npc",
		dh = "125123667237838218",
		ch = "93912231324572",
		op = true,
	},
	["OnNPCKilled:DropShipOnNPCKilled"] = {
		nm = "OnNPCKilled:DropShipOnNPCKilled",
		dh = "1251231541081733217",
		ch = "93912231324572",
	},
	["OnRenderPlayerNametags:nametags_coh"] = {
		nm = "OnRenderPlayerNametags:nametags_coh",
		dh = "1251231701737017229",
		ch = "93912231324572",
		op = true,
	},
	["UCLAuthed:XGUI_PermissionsChanged"] = {
		nm = "UCLAuthed:XGUI_PermissionsChanged",
		dh = "1251233432495875251",
		ch = "93912231324572",
	},
	["DupeSaveAvailable:UpdateDupeSpawnmenuAvailable"] = {
		nm = "DupeSaveAvailable:UpdateDupeSpawnmenuAvailable",
		dh = "1251233446469074319",
		ch = "93912231324572",
	},
	["BW_PostTagParse:prestige"] = {
		nm = "BW_PostTagParse:prestige",
		dh = "1251232998943339253",
		ch = "93912231324572",
	},
	["ULibLocalPlayerReady:InitXGUI"] = {
		nm = "ULibLocalPlayerReady:InitXGUI",
		dh = "1251233038378536251",
		ch = "93912231324572",
	},
	["PopulateEntities:AddEntityContent"] = {
		nm = "PopulateEntities:AddEntityContent",
		dh = "125123593465436324",
		ch = "93912231324572",
	},
	["PopulateEntities:AddSearchContent_PopulateEntities"] = {
		nm = "PopulateEntities:AddSearchContent_PopulateEntities",
		dh = "1251233250996397309",
		ch = "93912231324572",
	},
	["PlayerDisconnected:BaseWars.Factions.Clean"] = {
		nm = "PlayerDisconnected:BaseWars.Factions.Clean",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PlayerDisconnected:ULXJailDisconnectedCheck"] = {
		nm = "PlayerDisconnected:ULXJailDisconnectedCheck",
		dh = "1251234125905276235",
		ch = "93912231324572",
	},
	["PlayerDisconnected:ULXRagdollDisconnectedCheck"] = {
		nm = "PlayerDisconnected:ULXRagdollDisconnectedCheck",
		dh = "1251231020017326235",
		ch = "93912231324572",
	},
	["PlayerDisconnected:ULXMaulDisconnectedCheck"] = {
		nm = "PlayerDisconnected:ULXMaulDisconnectedCheck",
		dh = "1251233280315002235",
		ch = "93912231324572",
	},
	["ReceiveDM:chatbox.dm_receive"] = {
		nm = "ReceiveDM:chatbox.dm_receive",
		dh = "1251232145525981259",
		ch = "93912231324572",
	},
	["PostRenderVGUI:MediaPlayerDupe"] = {
		nm = "PostRenderVGUI:MediaPlayerDupe",
		dh = "1251231915785262241",
		ch = "93912231324572",
	},
	["CalcMainActivity:sitting"] = {
		nm = "CalcMainActivity:sitting",
		dh = "1251233998190314235",
		ch = "93912231324572",
	},
	["EntityRemoved:nocollide_fix"] = {
		nm = "EntityRemoved:nocollide_fix",
		dh = "1251233315603905290",
		ch = "93912231324572",
	},
	["EntityRemoved:DoDieFunction"] = {
		nm = "EntityRemoved:DoDieFunction",
		dh = "1251234047986093229",
		ch = "93912231324572",
	},
	["CanPlayerUseTag:chathud.restrict"] = {
		nm = "CanPlayerUseTag:chathud.restrict",
		dh = "125123134771676257",
		ch = "93912231324572",
	},
	["canPocket:PocketM9KWeapons"] = {
		nm = "canPocket:PocketM9KWeapons",
		dh = "1251232599667616317",
		ch = "93912231324572",
	},
	["PlayerSpawnedSWEP:rb655_lightsaber_swep_sync"] = {
		nm = "PlayerSpawnedSWEP:rb655_lightsaber_swep_sync",
		dh = "1251233443034350227",
		ch = "93912231324572",
	},
	["PlayerCanHearPlayersVoice:ULXGag"] = {
		nm = "PlayerCanHearPlayersVoice:ULXGag",
		dh = "1251232602557170237",
		ch = "93912231324572",
	},
	["UCLChanged:xgui_RefreshBansMenu"] = {
		nm = "UCLChanged:xgui_RefreshBansMenu",
		dh = "1251231566956189225",
		ch = "93912231324572",
	},
	["UCLChanged:ULXGroupNamesUpdate"] = {
		nm = "UCLChanged:ULXGroupNamesUpdate",
		dh = "1251231355907282235",
		ch = "93912231324572",
	},
	["UCLChanged:xgui_RefreshGroups"] = {
		nm = "UCLChanged:xgui_RefreshGroups",
		dh = "12512325814152231",
		ch = "93912231324572",
	},
	["UCLChanged:xgui_RefreshPlayerCmds"] = {
		nm = "UCLChanged:xgui_RefreshPlayerCmds",
		dh = "125123554153354233",
		ch = "93912231324572",
	},
	["CanTool:SW_Common_ToolReload"] = {
		nm = "CanTool:SW_Common_ToolReload",
		dh = "125123963795020225",
		ch = "93912231324572",
	},
	["CanTool:SW_Common_Tool"] = {
		nm = "CanTool:SW_Common_Tool",
		dh = "1251232261830087225",
		ch = "93912231324572",
	},
	["CanTool:FPP_CL_CanTool"] = {
		nm = "CanTool:FPP_CL_CanTool",
		dh = "1251232398433995203",
		ch = "93912231324572",
	},
	["PostDrawOpaqueRenderables:PermaPropsViewer"] = {
		nm = "PostDrawOpaqueRenderables:PermaPropsViewer",
		dh = "1251232196513733217",
		ch = "93912231324572",
	},
	["PostDrawOpaqueRenderables:npcDrops draw"] = {
		nm = "PostDrawOpaqueRenderables:npcDrops draw",
		dh = "1251231563215917217",
		ch = "93912231324572",
	},
	["PostDrawOpaqueRenderables:overDrawNPC"] = {
		nm = "PostDrawOpaqueRenderables:overDrawNPC",
		dh = "1251232057832604287",
		ch = "93912231324572",
	},
	["GetFallDamage:rb655_lightsaber_no_fall_damage"] = {
		nm = "GetFallDamage:rb655_lightsaber_no_fall_damage",
		dh = "1251233905081830227",
		ch = "93912231324572",
	},
	["NeedsDepthPass:NeedsDepthPass_Bokeh"] = {
		nm = "NeedsDepthPass:NeedsDepthPass_Bokeh",
		dh = "1251231483871887217",
		ch = "93912231324572",
	},
	["PreDrawHalos:zmlab_AddHalos"] = {
		nm = "PreDrawHalos:zmlab_AddHalos",
		dh = "125123154528947264",
		ch = "93912231324572",
	},
	["PreDrawHalos:AddPhysgunHalos"] = {
		nm = "PreDrawHalos:AddPhysgunHalos",
		dh = "1251231202753302237",
		ch = "93912231324572",
	},
	["PreDrawHalos:BaseWars_NPC_Glow"] = {
		nm = "PreDrawHalos:BaseWars_NPC_Glow",
		dh = "1251232219252766237",
		ch = "93912231324572",
	},
	["PreDrawHalos:BaseWars.AntiRDM.PreDrawHalos"] = {
		nm = "PreDrawHalos:BaseWars.AntiRDM.PreDrawHalos",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PreDrawHalos:PropertiesHover"] = {
		nm = "PreDrawHalos:PropertiesHover",
		dh = "1251233933651534231",
		ch = "93912231324572",
	},
	["PreDrawHalos:stacker_improved_predrawhalos"] = {
		nm = "PreDrawHalos:stacker_improved_predrawhalos",
		dh = "1251232332638299262",
		ch = "93912231324572",
	},
	["OnDamagedByExplosion:DisableSound"] = {
		nm = "OnDamagedByExplosion:DisableSound",
		dh = "1251232152201724227",
		ch = "93912231324572",
		op = true,
	},
	["PlayerDeath:ULXCheckFireDeath"] = {
		nm = "PlayerDeath:ULXCheckFireDeath",
		dh = "12512357518433235",
		ch = "93912231324572",
	},
	["PlayerDeath:playerDeathTest"] = {
		nm = "PlayerDeath:playerDeathTest",
		dh = "1251231777552884227",
		ch = "93912231324572",
		op = true,
	},
	["PlayerDeath:NewSound"] = {
		nm = "PlayerDeath:NewSound",
		dh = "125123757139848227",
		ch = "93912231324572",
		op = true,
	},
	["PlayerDeath:ULXCheckMaulDeath"] = {
		nm = "PlayerDeath:ULXCheckMaulDeath",
		dh = "125123729493212235",
		ch = "93912231324572",
	},
	["AddToolMenuTabs:M9KSettings"] = {
		nm = "AddToolMenuTabs:M9KSettings",
		dh = "1251234281963164236",
		ch = "93912231324572",
	},
	["PopulateVehicles:AddEntityContent"] = {
		nm = "PopulateVehicles:AddEntityContent",
		dh = "1251231351079171324",
		ch = "93912231324572",
	},
	["PopulateVehicles:AddSearchContent_PopulateVehicles"] = {
		nm = "PopulateVehicles:AddSearchContent_PopulateVehicles",
		dh = "1251233250996397309",
		ch = "93912231324572",
	},
	["PlayerIsRaidable:BaseWars.Raidability.PrinterCheck"] = {
		nm = "PlayerIsRaidable:BaseWars.Raidability.PrinterCheck",
		dh = "1251233547354842237",
		ch = "93912231324572",
	},
	["InitPostEntity:EPOE_autologin"] = {
		nm = "InitPostEntity:EPOE_autologin",
		dh = "1251231033979042237",
		ch = "93912231324572",
	},
	["InitPostEntity:cnTicker"] = {
		nm = "InitPostEntity:cnTicker",
		dh = "125123806999701259",
		ch = "93912231324572",
	},
	["InitPostEntity:FPP_Menu"] = {
		nm = "InitPostEntity:FPP_Menu",
		dh = "1251233032210414205",
		ch = "93912231324572",
	},
	["InitPostEntity:zrush_LoadFonts"] = {
		nm = "InitPostEntity:zrush_LoadFonts",
		dh = "1251231533433075312",
		ch = "93912231324572",
	},
	["InitPostEntity:BaseWars.InitPostEntity"] = {
		nm = "InitPostEntity:BaseWars.InitPostEntity",
		dh = "1251234221557610237",
		ch = "93912231324572",
	},
	["InitPostEntity:RemoveProps"] = {
		nm = "InitPostEntity:RemoveProps",
		dh = "1251233275363291263",
		ch = "93912231324572",
	},
	["InitPostEntity:ULibLocalPlayerReady"] = {
		nm = "InitPostEntity:ULibLocalPlayerReady",
		dh = "1251232090260868223",
		ch = "93912231324572",
	},
	["InitPostEntity:FPP_Start"] = {
		nm = "InitPostEntity:FPP_Start",
		dh = "1251231077461245210",
		ch = "93912231324572",
	},
	["InitPostEntity:awarn_ULXCompatability"] = {
		nm = "InitPostEntity:awarn_ULXCompatability",
		dh = "125123155481538235",
		ch = "93912231324572",
	},
	["InitPostEntity:xp.do_hook"] = {
		nm = "InitPostEntity:xp.do_hook",
		dh = "125123948682848258",
		ch = "93912231324572",
	},
	["InitPostEntity:CreateVoiceVGUI"] = {
		nm = "InitPostEntity:CreateVoiceVGUI",
		dh = "1251233248759532233",
		ch = "93912231324572",
	},
	["InitPostEntity:atmosFirstJoinLightmaps"] = {
		nm = "InitPostEntity:atmosFirstJoinLightmaps",
		dh = "1251232472293484201",
		ch = "93912231324572",
	},
	["ChatTextChanged:nametags_coh"] = {
		nm = "ChatTextChanged:nametags_coh",
		dh = "1251231068905607227",
		ch = "93912231324572",
		op = true,
	},
	["PopulateMenuBar:MediaPlayerOptions_MenuBar"] = {
		nm = "PopulateMenuBar:MediaPlayerOptions_MenuBar",
		dh = "125123329905044226",
		ch = "93912231324572",
	},
	["PopulateMenuBar:NPCOptions_MenuBar"] = {
		nm = "PopulateMenuBar:NPCOptions_MenuBar",
		dh = "1251232845376551205",
		ch = "93912231324572",
	},
	["PopulateMenuBar:DisplayOptions_MenuBar"] = {
		nm = "PopulateMenuBar:DisplayOptions_MenuBar",
		dh = "1251231097336916204",
		ch = "93912231324572",
	},
	["PostPlayerDraw:rb655_lightsaber"] = {
		nm = "PostPlayerDraw:rb655_lightsaber",
		dh = "1251233236212769247",
		ch = "93912231324572",
	},
	["PostPlayerDraw:nametags"] = {
		nm = "PostPlayerDraw:nametags",
		dh = "125123402954510224",
		ch = "93912231324572",
		op = true,
	},
	["StartChat:nametags_coh"] = {
		nm = "StartChat:nametags_coh",
		dh = "1251232472343941227",
		ch = "93912231324572",
		op = true,
	},
	["DupeSaved:DuplicationSavedSpawnMenu"] = {
		nm = "DupeSaved:DuplicationSavedSpawnMenu",
		dh = "1251232126014422320",
		ch = "93912231324572",
	},
	["SpawnMenuOpen:FPPMenus"] = {
		nm = "SpawnMenuOpen:FPPMenus",
		dh = "125123252308955209",
		ch = "93912231324572",
	},
	["UpdateAnimation:nametags"] = {
		nm = "UpdateAnimation:nametags",
		dh = "125123109283081223",
		ch = "93912231324572",
		op = true,
	},
	["OpenToolbox:OpenToolbox"] = {
		nm = "OpenToolbox:OpenToolbox",
		dh = "1251232511649167311",
		ch = "93912231324572",
	},
	["EPOE:EPOE_CLI"] = {
		nm = "EPOE:EPOE_CLI",
		dh = "1251232617921568240",
		ch = "93912231324572",
	},
	["EPOE:EPOE_GUI"] = {
		nm = "EPOE:EPOE_GUI",
		dh = "1251232162625216245",
		ch = "93912231324572",
	},
	["PlayerAuth:BaseWars.AFK.PlayerAuth"] = {
		nm = "PlayerAuth:BaseWars.AFK.PlayerAuth",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["ContentSidebarSelection:SidebarToolboxSelection"] = {
		nm = "ContentSidebarSelection:SidebarToolboxSelection",
		dh = "1251232825301042325",
		ch = "93912231324572",
	},
	["SpawnlistContentChanged:ShowSaveButton"] = {
		nm = "SpawnlistContentChanged:ShowSaveButton",
		dh = "1251231156942717311",
		ch = "93912231324572",
	},
	["RaidStart:wardrobe"] = {
		nm = "RaidStart:wardrobe",
		dh = "1251233626144413262",
		ch = "93912231324572",
	},
	["PostDrawHUD:ZRUSH.PostDrawHUD.CL.MachineCrateBuilder"] = {
		nm = "PostDrawHUD:ZRUSH.PostDrawHUD.CL.MachineCrateBuilder",
		dh = "125123277523258293",
		ch = "93912231324572",
	},
	["OnGamemodeLoaded:CreateMenuBar"] = {
		nm = "OnGamemodeLoaded:CreateMenuBar",
		dh = "1251231990771572223",
		ch = "93912231324572",
	},
	["OnGamemodeLoaded:CreateSpawnMenu"] = {
		nm = "OnGamemodeLoaded:CreateSpawnMenu",
		dh = "1251232592489692261",
		ch = "93912231324572",
	},
	["HUDPaintBackground:HatsThirdPerson DrawCrosshair"] = {
		nm = "HUDPaintBackground:HatsThirdPerson DrawCrosshair",
		dh = "1251232122609199299",
		ch = "93912231324572",
	},
	["SendDM:chatbox.dm_send"] = {
		nm = "SendDM:chatbox.dm_send",
		dh = "1251231495969939259",
		ch = "93912231324572",
	},
	["PlayerInitialSpawn:BaseWars.Factions.Teams"] = {
		nm = "PlayerInitialSpawn:BaseWars.Factions.Teams",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PlayerInitialSpawn:showMotd"] = {
		nm = "PlayerInitialSpawn:showMotd",
		dh = "1251231076806139237",
		ch = "93912231324572",
	},
	["PlayerInitialSpawn:ULXWelcome"] = {
		nm = "PlayerInitialSpawn:ULXWelcome",
		dh = "125123334407576237",
		ch = "93912231324572",
	},
	["PlayerInitialSpawn:BaseWars.AFK.PlayerInitialSpawn"] = {
		nm = "PlayerInitialSpawn:BaseWars.AFK.PlayerInitialSpawn",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["CAMI.SteamIDHasAccess:ULXCamiSteamidHasAccess"] = {
		nm = "CAMI.SteamIDHasAccess:ULXCamiSteamidHasAccess",
		dh = "1251231036457797241",
		ch = "93912231324572",
	},
	["RenderScene:RenderStereoscopy"] = {
		nm = "RenderScene:RenderStereoscopy",
		dh = "1251232661371625221",
		ch = "93912231324572",
	},
	["RenderScene:RenderSuperDoF"] = {
		nm = "RenderScene:RenderSuperDoF",
		dh = "1251233309974854219",
		ch = "93912231324572",
	},
	["RenderScene:nametags"] = {
		nm = "RenderScene:nametags",
		dh = "1251233195709285223",
		ch = "93912231324572",
		op = true,
	},
	["Wardrobe_AccessAllowed:wardrobe.adminonly"] = {
		nm = "Wardrobe_AccessAllowed:wardrobe.adminonly",
		dh = "125123280344914249",
		ch = "93912231324572",
	},
	["Wardrobe_AccessAllowed:extensions.ulx"] = {
		nm = "Wardrobe_AccessAllowed:extensions.ulx",
		dh = "1251232675800915253",
		ch = "93912231324572",
	},
	["Wardrobe_AccessAllowed:wardrobe.whitelist"] = {
		nm = "Wardrobe_AccessAllowed:wardrobe.whitelist",
		dh = "1251231374732461251",
		ch = "93912231324572",
	},
	["Wardrobe_AccessAllowed:wardrobe.specificModels"] = {
		nm = "Wardrobe_AccessAllowed:wardrobe.specificModels",
		dh = "1251231052356667251",
		ch = "93912231324572",
	},
	["DrawOverlay:sandbox_search_progress"] = {
		nm = "DrawOverlay:sandbox_search_progress",
		dh = "1251232683310723253",
		ch = "93912231324572",
	},
	["DrawOverlay:DragNDropPaint"] = {
		nm = "DrawOverlay:DragNDropPaint",
		dh = "1251231105758327259",
		ch = "93912231324572",
	},
	["DrawOverlay:DrawNumberScratch"] = {
		nm = "DrawOverlay:DrawNumberScratch",
		dh = "1251232543623179215",
		ch = "93912231324572",
	},
	["DrawOverlay:VGUIShowLayoutPaint"] = {
		nm = "DrawOverlay:VGUIShowLayoutPaint",
		dh = "125123708031385233",
		ch = "93912231324572",
	},
	["GUIMousePressed:SuperDOFMouseDown"] = {
		nm = "GUIMousePressed:SuperDOFMouseDown",
		dh = "125123729562822219",
		ch = "93912231324572",
	},
	["GUIMousePressed:SpawnMenuOpenGUIMousePressed"] = {
		nm = "GUIMousePressed:SpawnMenuOpenGUIMousePressed",
		dh = "1251232199939041261",
		ch = "93912231324572",
	},
	["GUIMousePressed:PropertiesClick"] = {
		nm = "GUIMousePressed:PropertiesClick",
		dh = "1251232048652055231",
		ch = "93912231324572",
	},
	["AllowPlayerPickup:SW_Common_CantPickUp"] = {
		nm = "AllowPlayerPickup:SW_Common_CantPickUp",
		dh = "1251232221737441225",
		ch = "93912231324572",
	},
	["Think:atmosStormThink"] = {
		nm = "Think:atmosStormThink",
		dh = "1251232145077221204",
		ch = "93912231324572",
	},
	["Think:InputManagerThink"] = {
		nm = "Think:InputManagerThink",
		dh = "125123889450859244",
		ch = "93912231324572",
	},
	["Think:crsk_visiongt_SyncChanges"] = {
		nm = "Think:crsk_visiongt_SyncChanges",
		dh = "1251231266093023233",
		ch = "93912231324572",
	},
	["Think:luadev1_watchlist"] = {
		nm = "Think:luadev1_watchlist",
		dh = "1251231958039409251",
		ch = "93912231324572",
	},
	["Think:sw_bluex11_Think_VehicleOrderThink"] = {
		nm = "Think:sw_bluex11_Think_VehicleOrderThink",
		dh = "1251232138746920202",
		ch = "93912231324572",
	},
	["Think:rb655_lightsaber_ugly_fixes"] = {
		nm = "Think:rb655_lightsaber_ugly_fixes",
		dh = "1251231639930771247",
		ch = "93912231324572",
	},
	["Think:preventdefocusclick"] = {
		nm = "Think:preventdefocusclick",
		dh = "1251233503747438237",
		ch = "93912231324572",
	},
	["Think:DOFThink"] = {
		nm = "Think:DOFThink",
		dh = "1251233208914580205",
		ch = "93912231324572",
	},
	["Think:DragNDropThink"] = {
		nm = "Think:DragNDropThink",
		dh = "1251233746219494259",
		ch = "93912231324572",
	},
	["Think:RealFrameTime"] = {
		nm = "Think:RealFrameTime",
		dh = "1251233328501173215",
		ch = "93912231324572",
	},
	["Think:NotificationThink"] = {
		nm = "Think:NotificationThink",
		dh = "1251233909995925235",
		ch = "93912231324572",
	},
	["Think:sandbox_queued_search"] = {
		nm = "Think:sandbox_queued_search",
		dh = "1251231533757916253",
		ch = "93912231324572",
	},
	["Think:ss_should_draw_both_sides"] = {
		nm = "Think:ss_should_draw_both_sides",
		dh = "1251233611988661255",
		ch = "93912231324572",
	},
	["Think:zrush_NotificationsMover"] = {
		nm = "Think:zrush_NotificationsMover",
		dh = "1251233520325835263",
		ch = "93912231324572",
	},
	["Think:ZRUSH.Think.CL.MachineCrateBuilder"] = {
		nm = "Think:ZRUSH.Think.CL.MachineCrateBuilder",
		dh = "1251231315321050294",
		ch = "93912231324572",
	},
	["Think:chathud"] = {
		nm = "Think:chathud",
		dh = "1251231180082521259",
		ch = "93912231324572",
	},
	["Think:BaseWars.Menu.Open"] = {
		nm = "Think:BaseWars.Menu.Open",
		dh = "125123562642442257",
		ch = "93912231324572",
	},
	["Think:workshop.mounting"] = {
		nm = "Think:workshop.mounting",
		dh = "1251234230408885243",
		ch = "93912231324572",
	},
	["Think:HatsThirdPerson BindDetection"] = {
		nm = "Think:HatsThirdPerson BindDetection",
		dh = "1251232540291520300",
		ch = "93912231324572",
	},
	["Think:ZRUSH.Think.VFX.UPDATER"] = {
		nm = "Think:ZRUSH.Think.VFX.UPDATER",
		dh = "1251231415493762281",
		ch = "93912231324572",
	},
	["Think:wardrobe"] = {
		nm = "Think:wardrobe",
		dh = "125123788822584243",
		ch = "93912231324572",
	},
	["PopulateToolMenu:PopulatezrushMenus"] = {
		nm = "PopulateToolMenu:PopulatezrushMenus",
		dh = "1251232517967398273",
		ch = "93912231324572",
	},
	["PopulateToolMenu:FPPMenus"] = {
		nm = "PopulateToolMenu:FPPMenus",
		dh = "1251233555368061209",
		ch = "93912231324572",
	},
	["PopulateToolMenu:PopulateAtmosMenus"] = {
		nm = "PopulateToolMenu:PopulateAtmosMenus",
		dh = "1251231661973815203",
		ch = "93912231324572",
	},
	["PopulateToolMenu:sw_bluex11_PopulateToolMenu_VehicleOrderMenu"] = {
		nm = "PopulateToolMenu:sw_bluex11_PopulateToolMenu_VehicleOrderMenu",
		dh = "1251232138746920202",
		ch = "93912231324572",
	},
	["PopulateToolMenu:stacker_improvedAdminUtilities"] = {
		nm = "PopulateToolMenu:stacker_improvedAdminUtilities",
		dh = "12512330617188262",
		ch = "93912231324572",
	},
	["PopulateToolMenu:ZINVmenu"] = {
		nm = "PopulateToolMenu:ZINVmenu",
		dh = "1251234292713301207",
		ch = "93912231324572",
	},
	["PopulateToolMenu:V92APBJokerToolMenu"] = {
		nm = "PopulateToolMenu:V92APBJokerToolMenu",
		dh = "1251231078904304233",
		ch = "93912231324572",
	},
	["PopulateToolMenu:AddSToolsToMenu"] = {
		nm = "PopulateToolMenu:AddSToolsToMenu",
		dh = "1251233952403214269",
		ch = "93912231324572",
	},
	["PopulateToolMenu:PopulateUtilityMenus"] = {
		nm = "PopulateToolMenu:PopulateUtilityMenus",
		dh = "125123654721526221",
		ch = "93912231324572",
	},
	["PopulateToolMenu:NPCSpawner Options"] = {
		nm = "PopulateToolMenu:NPCSpawner Options",
		dh = "125123555500067235",
		ch = "93912231324572",
	},
	["PopulateToolMenu:hdn_spawnMenu"] = {
		nm = "PopulateToolMenu:hdn_spawnMenu",
		dh = "125123792111603245",
		ch = "93912231324572",
	},
	["EntityFireBullets:NewPerspective BulletCorrection"] = {
		nm = "EntityFireBullets:NewPerspective BulletCorrection",
		dh = "1251234272687797299",
		ch = "93912231324572",
	},
	["Wardrobe_Loaded:wardrobe.legs"] = {
		nm = "Wardrobe_Loaded:wardrobe.legs",
		dh = "125123647316793251",
		ch = "93912231324572",
	},
	["Wardrobe_PostSetModel:wardrobe"] = {
		nm = "Wardrobe_PostSetModel:wardrobe",
		dh = "1251234233386906257",
		ch = "93912231324572",
		op = true,
	},
	["XLIBDoAnimation:xlib_runAnims"] = {
		nm = "XLIBDoAnimation:xlib_runAnims",
		dh = "1251233039424486239",
		ch = "93912231324572",
	},
	["PreDrawViewModel:wardrobe"] = {
		nm = "PreDrawViewModel:wardrobe",
		dh = "1251231382937100243",
		ch = "93912231324572",
	},
	["GravGunPunt:FPP_CL_GravGunPunt"] = {
		nm = "GravGunPunt:FPP_CL_GravGunPunt",
		dh = "1251231754720296203",
		ch = "93912231324572",
	},
	["player_changename:ULibNameCheck"] = {
		nm = "player_changename:ULibNameCheck",
		dh = "1251232256284216233",
		ch = "93912231324572",
	},
	["SetupMove:sitting"] = {
		nm = "SetupMove:sitting",
		dh = "125123917541676235",
		ch = "93912231324572",
	},
	["PlayerDeathSound:DeFlatline"] = {
		nm = "PlayerDeathSound:DeFlatline",
		dh = "125123824708480227",
		ch = "93912231324572",
		op = true,
	},
	["CanDrive:DisableMediaPlayerDriving"] = {
		nm = "CanDrive:DisableMediaPlayerDriving",
		dh = "1251233402992101211",
		ch = "93912231324572",
	},
	["ShouldDrawLocalPlayer:HatsThirdPerson DrawLocalPly"] = {
		nm = "ShouldDrawLocalPlayer:HatsThirdPerson DrawLocalPly",
		dh = "1251232328222286299",
		ch = "93912231324572",
	},
	["PlayerBindPress:chatbox.bind"] = {
		nm = "PlayerBindPress:chatbox.bind",
		dh = "1251233684649609259",
		ch = "93912231324572",
	},
	["PlayerBindPress:rb655_sabers_force"] = {
		nm = "PlayerBindPress:rb655_sabers_force",
		dh = "1251233339188303229",
		ch = "93912231324572",
	},
	["PlayerBindPress:BaseWars.AFK"] = {
		nm = "PlayerBindPress:BaseWars.AFK",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PlayerBindPress:PlayerOptionInput"] = {
		nm = "PlayerBindPress:PlayerOptionInput",
		dh = "12512331152094241",
		ch = "93912231324572",
	},
	["PlayerBindPress:Keypad"] = {
		nm = "PlayerBindPress:Keypad",
		dh = "1251232154299795216",
		ch = "93912231324572",
	},
	["LuaDevProcess:easylua"] = {
		nm = "LuaDevProcess:easylua",
		dh = "1251231884137830249",
		ch = "93912231324572",
	},
	["EntityTakeDamage:GuardUp"] = {
		nm = "EntityTakeDamage:GuardUp",
		dh = "1251233602292017263",
		ch = "93912231324572",
	},
	["EntityTakeDamage:DukesUp"] = {
		nm = "EntityTakeDamage:DukesUp",
		dh = "1251233252744772263",
		ch = "93912231324572",
	},
	["EntityTakeDamage:rb655_sabers_armor"] = {
		nm = "EntityTakeDamage:rb655_sabers_armor",
		dh = "125123216447656227",
		ch = "93912231324572",
	},
	["EntityTakeDamage:PoisonChildChecker"] = {
		nm = "EntityTakeDamage:PoisonChildChecker",
		dh = "125123526154413263",
		ch = "93912231324572",
	},
	["PostReloadToolsMenu:BuildUndoUI"] = {
		nm = "PostReloadToolsMenu:BuildUndoUI",
		dh = "125123717558661219",
		ch = "93912231324572",
	},
	["PostReloadToolsMenu:BuildCleanupUI"] = {
		nm = "PostReloadToolsMenu:BuildCleanupUI",
		dh = "1251234067935479225",
		ch = "93912231324572",
	},
	["Initialize:npcDrops Init"] = {
		nm = "Initialize:npcDrops Init",
		dh = "1251233025965462215",
		ch = "93912231324572",
	},
	["Initialize:InitMediaPlayer"] = {
		nm = "Initialize:InitMediaPlayer",
		dh = "1251231345280874211",
		ch = "93912231324572",
	},
	["Initialize:rb655_fix_convars"] = {
		nm = "Initialize:rb655_fix_convars",
		dh = "1251233564704735247",
		ch = "93912231324572",
	},
	["Initialize:gScoreboard.FontCreations"] = {
		nm = "Initialize:gScoreboard.FontCreations",
		dh = "1251232188237158269",
		ch = "93912231324572",
	},
	["CanPlayerUnfreeze:SW_Common_CantUnfreeze"] = {
		nm = "CanPlayerUnfreeze:SW_Common_CantUnfreeze",
		dh = "1251234202435502225",
		ch = "93912231324572",
	},
	["OnPlayerChat:BU3OpenAdminMenu"] = {
		nm = "OnPlayerChat:BU3OpenAdminMenu",
		dh = "1251232004984876261",
		ch = "93912231324572",
	},
	["OnPlayerChat:chathud.tagpanic"] = {
		nm = "OnPlayerChat:chathud.tagpanic",
		dh = "1251233228920556259",
		ch = "93912231324572",
	},
	["OnPlayerChat:wardrobe"] = {
		nm = "OnPlayerChat:wardrobe",
		dh = "1251233285862045257",
		ch = "93912231324572",
		op = true,
	},
	["OnPlayerChat:NewPerspective ChatCommands"] = {
		nm = "OnPlayerChat:NewPerspective ChatCommands",
		dh = "1251231449016140299",
		ch = "93912231324572",
	},
	["ScoreboardShow:gScoreboard.ScoreboardShow"] = {
		nm = "ScoreboardShow:gScoreboard.ScoreboardShow",
		dh = "1251231241934722267",
		ch = "93912231324572",
	},
	["ScoreboardHide:gScoreboard.ScoreboardHide"] = {
		nm = "ScoreboardHide:gScoreboard.ScoreboardHide",
		dh = "1251232482419542267",
		ch = "93912231324572",
	},
	["OnContextMenuOpen:MP.ShowSidebar"] = {
		nm = "OnContextMenuOpen:MP.ShowSidebar",
		dh = "1251231406758919207",
		ch = "93912231324572",
	},
	["OnContextMenuOpen:HatsThirdPerson ContextOpen"] = {
		nm = "OnContextMenuOpen:HatsThirdPerson ContextOpen",
		dh = "125123287315652299",
		ch = "93912231324572",
	},
	["PlayerSpawn:BaseWars.Util_Player.EnableFlashlight"] = {
		nm = "PlayerSpawn:BaseWars.Util_Player.EnableFlashlight",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["PlayerSpawn:ULXRagdollSpawnCheck"] = {
		nm = "PlayerSpawn:ULXRagdollSpawnCheck",
		dh = "1251231082283844235",
		ch = "93912231324572",
	},
	["PlayerSpawn:BaseWars.Util_Player.Spawn"] = {
		nm = "PlayerSpawn:BaseWars.Util_Player.Spawn",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["CalcView:!!!111_rb655_lightsaber_3rdperson"] = {
		nm = "CalcView:!!!111_rb655_lightsaber_3rdperson",
		dh = "1251232212330163229",
		ch = "93912231324572",
	},
	["CalcView:HatsThirdPerson CalcView"] = {
		nm = "CalcView:HatsThirdPerson CalcView",
		dh = "1251231458605790299",
		ch = "93912231324572",
	},
	["PopulateContent:AddCustomContent"] = {
		nm = "PopulateContent:AddCustomContent",
		dh = "1251231586518929323",
		ch = "93912231324572",
	},
	["PopulateContent:AddonProps"] = {
		nm = "PopulateContent:AddonProps",
		dh = "1251233162702470329",
		ch = "93912231324572",
	},
	["PopulateContent:AddSearchContent_PopulateContent"] = {
		nm = "PopulateContent:AddSearchContent_PopulateContent",
		dh = "1251233250996397309",
		ch = "93912231324572",
	},
	["PopulateContent:GameProps"] = {
		nm = "PopulateContent:GameProps",
		dh = "1251233679776203327",
		ch = "93912231324572",
	},
	["CAMI.PlayerHasAccess:ULXCamiPlayerHasAccess"] = {
		nm = "CAMI.PlayerHasAccess:ULXCamiPlayerHasAccess",
		dh = "1251231704153386241",
		ch = "93912231324572",
	},
	["OnEntityCreated:ULibPlayerAuthCheck"] = {
		nm = "OnEntityCreated:ULibPlayerAuthCheck",
		dh = "1251232336205364223",
		ch = "93912231324572",
	},
	["OnContextMenuClose:MP.HideSidebar"] = {
		nm = "OnContextMenuClose:MP.HideSidebar",
		dh = "1251231935524049207",
		ch = "93912231324572",
	},
	["OnContextMenuClose:HatsThirdPerson ContextClose"] = {
		nm = "OnContextMenuClose:HatsThirdPerson ContextClose",
		dh = "1251231094960654299",
		ch = "93912231324572",
	},
	["PopulateNPCs:AddSearchContent_PopulateNPCs"] = {
		nm = "PopulateNPCs:AddSearchContent_PopulateNPCs",
		dh = "1251233250996397309",
		ch = "93912231324572",
	},
	["PopulateNPCs:AddNPCContent"] = {
		nm = "PopulateNPCs:AddNPCContent",
		dh = "1251232967105485316",
		ch = "93912231324572",
	},
	["ContextMenuCreated:MediaPlayer.Scroll"] = {
		nm = "ContextMenuCreated:MediaPlayer.Scroll",
		dh = "1251231488647544217",
		ch = "93912231324572",
	},
	["Wardrobe_Notification:wardrobe.gui"] = {
		nm = "Wardrobe_Notification:wardrobe.gui",
		dh = "1251233404645120257",
		ch = "93912231324572",
	},
	["PostCleanupMap:ULXRagdollAfterCleanup"] = {
		nm = "PostCleanupMap:ULXRagdollAfterCleanup",
		dh = "1251234068578673235",
		ch = "93912231324572",
	},
	["PostCleanupMap:CleanEverythingCheck"] = {
		nm = "PostCleanupMap:CleanEverythingCheck",
		dh = "1251233649907373263",
		ch = "93912231324572",
	},
	["OnReloaded:xp.do_hook"] = {
		nm = "OnReloaded:xp.do_hook",
		dh = "125123948682848258",
		ch = "93912231324572",
	},
	["ChatShouldHandle:chatexp.compat"] = {
		nm = "ChatShouldHandle:chatexp.compat",
		dh = "1251232239073131257",
		ch = "93912231324572",
	},
	["OnTextEntryLoseFocus:XGUI_LoseKeyboardFocus"] = {
		nm = "OnTextEntryLoseFocus:XGUI_LoseKeyboardFocus",
		dh = "1251232902159653251",
		ch = "93912231324572",
	},
	["OnTextEntryLoseFocus:SpawnMenuKeyboardFocusOff"] = {
		nm = "OnTextEntryLoseFocus:SpawnMenuKeyboardFocusOff",
		dh = "125123665528504261",
		ch = "93912231324572",
	},
	["SpawnlistOpenGenericMenu:SpawnlistOpenGenericMenu"] = {
		nm = "SpawnlistOpenGenericMenu:SpawnlistOpenGenericMenu",
		dh = "1251232020940820317",
		ch = "93912231324572",
	},
	["OnTextEntryGetFocus:SpawnMenuKeyboardFocusOn"] = {
		nm = "OnTextEntryGetFocus:SpawnMenuKeyboardFocusOn",
		dh = "1251231033746889261",
		ch = "93912231324572",
	},
	["OnTextEntryGetFocus:XGUI_GetKeyboardFocus"] = {
		nm = "OnTextEntryGetFocus:XGUI_GetKeyboardFocus",
		dh = "1251233878501732250",
		ch = "93912231324572",
	},
	["VGUIMousePressed:TextEntryLoseFocus"] = {
		nm = "VGUIMousePressed:TextEntryLoseFocus",
		dh = "125123909197185207",
		ch = "93912231324572",
	},
	["VGUIMousePressed:DermaDetectMenuFocus"] = {
		nm = "VGUIMousePressed:DermaDetectMenuFocus",
		dh = "125123247004108209",
		ch = "93912231324572",
	},
	["CreateMove:rb655_lightsaber_no_fall_damage"] = {
		nm = "CreateMove:rb655_lightsaber_no_fall_damage",
		dh = "125123335315218227",
		ch = "93912231324572",
	},
	["CreateMove:BaseWars.AFK"] = {
		nm = "CreateMove:BaseWars.AFK",
		dh = "1251232104290378247",
		ch = "93912231324572",
	},
	["CreateMove:ManualTurret"] = {
		nm = "CreateMove:ManualTurret",
		dh = "1251233143670135275",
		ch = "93912231324572",
	},
	["CreateMove:Keypad"] = {
		nm = "CreateMove:Keypad",
		dh = "1251232887714140217",
		ch = "93912231324572",
	},
	["HUDPaint:PlayerOptionDraw"] = {
		nm = "HUDPaint:PlayerOptionDraw",
		dh = "1251232536980018241",
		ch = "93912231324572",
	},
	["HUDPaint:BoxHUDText"] = {
		nm = "HUDPaint:BoxHUDText",
		dh = "1251232422430946317",
		ch = "93912231324572",
	},
	["HUDPaint:zmlab_methdropoff_indicator2d"] = {
		nm = "HUDPaint:zmlab_methdropoff_indicator2d",
		dh = "125123340607606279",
		ch = "93912231324572",
	},
	["HUDPaint:BaseWars.AFK.Paint"] = {
		nm = "HUDPaint:BaseWars.AFK.Paint",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["HUDPaint:BaseWars.Notify.Paint"] = {
		nm = "HUDPaint:BaseWars.Notify.Paint",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["HUDPaint:DrawRecordingIcon"] = {
		nm = "HUDPaint:DrawRecordingIcon",
		dh = "1251233895118297219",
		ch = "93912231324572",
	},
	["HUDPaint:LookEnt.Paint"] = {
		nm = "HUDPaint:LookEnt.Paint",
		dh = "1251232436833508267",
		ch = "93912231324572",
	},
	["HUDPaint:atmosHUDPaint"] = {
		nm = "HUDPaint:atmosHUDPaint",
		dh = "125123636875305203",
		ch = "93912231324572",
	},
	["HUDPaint:zrush_useindicator_HUDPaint"] = {
		nm = "HUDPaint:zrush_useindicator_HUDPaint",
		dh = "125123928979684271",
		ch = "93912231324572",
	},
	["HUDPaint:CSayHelperDraw"] = {
		nm = "HUDPaint:CSayHelperDraw",
		dh = "1251233212004790231",
		ch = "93912231324572",
		op = true,
	},
	["HUDPaint:rsp_draw_safezone"] = {
		nm = "HUDPaint:rsp_draw_safezone",
		dh = "1251233626415066251",
		ch = "93912231324572",
	},
	["HUDPaint:SlotMachine Info"] = {
		nm = "HUDPaint:SlotMachine Info",
		dh = "1251232827021351283",
		ch = "93912231324572",
	},
	["HUDPaint:BaseWars.DrawBomb_EndGame"] = {
		nm = "HUDPaint:BaseWars.DrawBomb_EndGame",
		dh = "125123202951235277",
		ch = "93912231324572",
	},
	["HUDPaint:FPP_HUDPaint"] = {
		nm = "HUDPaint:FPP_HUDPaint",
		dh = "12512356268067205",
		ch = "93912231324572",
	},
	["HUDPaint:BaseWars.Raid.Paint"] = {
		nm = "HUDPaint:BaseWars.Raid.Paint",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["HUDPaint:ZRUSH.Think.CL.ConnectionRender"] = {
		nm = "HUDPaint:ZRUSH.Think.CL.ConnectionRender",
		dh = "1251232839605990295",
		ch = "93912231324572",
	},
	["HUDPaint:chathud.draw"] = {
		nm = "HUDPaint:chathud.draw",
		dh = "1251231930453213259",
		ch = "93912231324572",
	},
	["HUDPaint:MiniMap"] = {
		nm = "HUDPaint:MiniMap",
		dh = "125123648085499259",
		ch = "93912231324572",
	},
	["HUDPaint:BaseWars.HUD.Paint"] = {
		nm = "HUDPaint:BaseWars.HUD.Paint",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["HUDPaint:BaseWars.PlayTime_Money.Paint"] = {
		nm = "HUDPaint:BaseWars.PlayTime_Money.Paint",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["HUDPaint:hdn_debugHUD"] = {
		nm = "HUDPaint:hdn_debugHUD",
		dh = "1251231207489709245",
		ch = "93912231324572",
	},
	["HUDPaint:BaseWars.AntiRDM.Paint"] = {
		nm = "HUDPaint:BaseWars.AntiRDM.Paint",
		dh = "1251231431229251236",
		ch = "93912231324572",
	},
	["CanCreateFaction:BaseWars.Raid"] = {
		nm = "CanCreateFaction:BaseWars.Raid",
		dh = "12512311647468249",
		ch = "93912231324572",
	},
	["WeaponEquip:npcDrops pickupSwep"] = {
		nm = "WeaponEquip:npcDrops pickupSwep",
		dh = "1251234008075702217",
		ch = "93912231324572",
	},
	["OnPlayerChat:wardrobe.gui"] = {
		nm = "OnPlayerChat:wardrobe.gui",
		dh = "1251232768995375251",
		ch = "93912231324572",
		op = true,
	},
	["ShouldDisableLegs:GML::Support::Prone"] = {
		nm = "ShouldDisableLegs:GML::Support::Prone",
		dh = "125123916389332245",
		ch = "9391145491049012",
		op = true,
	},
	["ShouldDisableLegs:GML::Support::MorphMod"] = {
		nm = "ShouldDisableLegs:GML::Support::MorphMod",
		dh = "1251231414617975245",
		ch = "93912231324572",
		op = true,
	},
	["RenderScreenspaceEffects:GML:Render::Vehicle"] = {
		nm = "RenderScreenspaceEffects:GML:Render::Vehicle",
		dh = "125123679187529245",
		ch = "9391194173840810",
		op = true,
	},
	["PostDrawTranslucentRenderables:GML:Render::Foot"] = {
		nm = "PostDrawTranslucentRenderables:GML:Render::Foot",
		dh = "1251232415336779245",
		ch = "9391194173840810",
		op = true,
	},
	["GetVMenuTabs:GMLTabs"] = {
		nm = "GetVMenuTabs:GMLTabs",
		dh = "125123797002750255",
		ch = "93912231324572",
		op = true,
	},
	["UpdateAnimation:GML:UpdateAnimation"] = {
		nm = "UpdateAnimation:GML:UpdateAnimation",
		dh = "1251232134304070245",
		ch = "9391194173840810",
		op = true,
	},
	["SetModel:GML::SetModel::Hook"] = {
		nm = "SetModel:GML::SetModel::Hook",
		dh = "1251233664872411243",
		ch = "93912231324572",
		op = true,
	},
	["CalcView:GML::CalcView::ViewCorrection::Vehicle"] = {
		nm = "SetModel:GML::SetModel::Hook",
		dh = "1251234109595241245",
		ch = "939178805987815",
		op = true,
	},
}


for f,v in _prs(fl) do fl[_dgi(_dgi).func(f).func] = v end



local ok, err

ok, err = _pcll(fa, fl, "fa")
if not ok then fail("fa-inc", err) end

ok, err = _pcll(ha, hl)
if not ok then fail("ha-inc", err) end

ok, err = _pcll(msc)
if not ok then fail("msc-inc", err) end
