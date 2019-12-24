net._Receive = net._Receive or net.Receive

local ignore = {
	["basewars.afk"] = true,

	["chatexp"] = true,
	["nametags_coh"] = true,
	["nametags_coh_start"] = true,
	["nametags_coh_finish"] = true,

	["textscreens_download"] = true,

	["tfa_base_muzzle_mp"] = true,

	["pac_in_editor_posang"] = true,
	["pac_update_playerfilter"] = true,

	["tab_lounge_countryflag"] = true,

	["instrumentnetwork"] = true,

	["keypad"] = true,
	["keypad_wire"] = true,
}

local log_interject = false

function g_net_log_function(net_name, net_len, sending_ply)
	if not net.log_enabled or ignore[net_name] then log_interject = false return end

	local size = utf8.len(sending_ply:Nick() .. "(" .. sending_ply:SteamID() .. ")")

	MsgC(
		Color(190, 150, 150), os.date("%H:%M:%S"), color_white, " - ",
		Color(100, 160, 120), sending_ply:Nick(),
		color_white, "(", Color(100, 100, 100), sending_ply:SteamID(), color_white, string.format(")%s->", (" "):rep(math.max(0, 48-size))),
		Color(150, 100, 150), net_name,
		color_white, "[", Color(100, 200, 100), net_len, color_white, "]\n"
	)

	log_interject = true
end

local loggers = {}

function loggers.Data(sz, data)
	local output = data
	if sz > 32 then
		output = string.format("truncated [%d]", sz)
	end

	MsgC(
		color_white, "   ",
		Color(200, 100, 200), "Data",
		color_white, "->",
		Color(100, 120, 100), output .. "\n"
	)
end

function loggers.UInt(sz, data)
	MsgC(
		color_white, "   ",
		Color(200, 100, 200), "UInt",
		color_white, "[",
		Color(100, 200, 100), tostring(sz),
		color_white, "]",
		color_white, "->",
		Color(100, 170, 100), tostring(data) .. "\n"
	)
end

function loggers.Int(sz, data)
	MsgC(
		color_white, "   ",
		Color(200, 100, 200), "Int",
		color_white, "[",
		Color(100, 200, 100), tostring(sz),
		color_white, "]",
		color_white, "->",
		Color(100, 170, 100), tostring(data) .. "\n"
	)
end

function loggers.Table(_, data)
	local output = "empty"
	if next(data) then
		local n = 0

		for _ in pairs(data) do
			n = n + 1
			if n > 32 then n = ">32" break end
		end

		output = tostring(n)
	end

	MsgC(
		color_white, "   ",
		Color(150, 150, 150), "Table",
		color_white, "[",
		Color(100, 200, 100), output,
		color_white, "]\n"
	)
end

function g_net_log_function_reader(net_type, type_size, result)
	if not log_interject then return end

	if loggers[net_type] then
		loggers[net_type](type_size, result)
	else
		MsgC(
			color_white, "   ",
			Color(200, 100, 200), net_type,
			color_white, "->",
			Color(100, 170, 100), tostring(result) .. "\n"
		)
	end
end

local function hook_reader(net_type)
	local fun = "Read" .. net_type
	local old = "_Read" .. net_type

	net[old] = net[old] or net[fun]

	net[fun] = function(sz, ...)
		local res = net[old](sz, ...)
		g_net_log_function_reader(net_type, sz, res)

		return res
	end
end

hook_reader("String")
hook_reader("Bool")
hook_reader("UInt")
hook_reader("Int")
hook_reader("Bit")
hook_reader("Vector")
hook_reader("Angle")
hook_reader("Float")
hook_reader("Matrix")
hook_reader("Normal")
hook_reader("Table")
hook_reader("Color")
hook_reader("Data")
hook_reader("Entity")

net._overwritten = net._overwritten or {}

function net.Receive(name, callback)
	name = name:lower()

    net._Receive(name, function(len, ply)
        g_net_log_function(name, len, ply)
        callback(len, ply)
	end)

	net._overwritten[name] = callback
end

for name, callback in pairs(net.Receivers) do
	name = name:lower()

	if not net._overwritten[name] then
		net.Receivers[name] = function(len, ply)
			g_net_log_function(name, len, ply)
			callback(len, ply)
		end

		net._overwritten[name] = callback
	else
		net.Receivers[name] = function(len, ply)
			g_net_log_function(name, len, ply)
			net._overwritten[name](len, ply)
		end
	end
end
