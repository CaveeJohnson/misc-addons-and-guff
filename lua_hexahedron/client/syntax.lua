local tag = "syntax"
local prefix = "[!|/|%.]"

local types = {
	-- luadev
	["l"] 		= 		{txt = "server", 		color = Color(200, 35, 35)},
	["lm"] 		= 		{txt = "self", 			color = Color(77, 193, 255)},
	["lc"] 		= 		{txt = "clients",		color = Color(82, 134, 255)},
	["ls"]		=		{txt = "shared",		color = Color(108, 255, 82)},
	["print"]	= 		{txt = "server print", 	color = Color(255, 138, 245)},
	["keys"]	= 		{},
	["table"] 	= 		{},
	-- glib/gcompute
	["p"]		= 		{txt = "server print", 	color = Color(255, 138, 245)},
	["pm2"]		=		{txt = "self print", 	color =	Color(255, 200, 138)},
	["pc"]		=		{txt = "clients print",	color = Color(138, 230, 255)},
}

hook.Add("OnPlayerChat", tag, function(ply, txt)
	if not IsValid(ply) then return end
	local args = string.Explode(" ", txt)
	local word = args[1]:sub(2)
	local type = types[word]
	if args[1]:sub(1, 1):match(prefix) and type then
		chat.AddText(team.GetColor(ply:Team()), ply:Nick(), (type.color and type.color or Color(144, 195, 212)), "@" .. (type.txt and type.txt or word), Color(200, 200, 200), ": " .. table.concat(args, " ", 2))
		return true
	end
end)
