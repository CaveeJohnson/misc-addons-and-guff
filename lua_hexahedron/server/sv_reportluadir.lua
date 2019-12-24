util.AddNetworkString("ReportLuaDir")
util.AddNetworkString("ReportLuaDirStart")

local LawnGreen = Color(124, 252, 0, 255)
local function Log(msg)
	MsgC(LawnGreen, "[LuaScan] ", color_white, msg, "\n")
end

ReportLuaDir = ReportLuaDir or {}
ReportLuaDir.cache = ReportLuaDir.cache or {}
local function fileExists(filePath)
	if ReportLuaDir.cache[filePath] then return ReportLuaDir.cache[filePath] end
	ReportLuaDir.cache[filePath] = file.Exists("garrysmod/lua/" .. filePath, "BASE_PATH")
	return ReportLuaDir.cache[filePath]
end

local ongoing = false
net.Receive("ReportLuaDir", function(len, ply)
	local filesLen = net.ReadUInt(32)
	if not filesLen or filesLen <= 0 then return Log("Response data length is invalid or 0!!!!") end
	local files = net.ReadData(filesLen)
	if not files then return Log("Files data is invalid!!!!") end
	files = util.Decompress(files)
	if not files then return Log("Files decompressed data is invalid!!!!") end
	files = util.JSONToTable(files)
	
	local found = {}
	for _, filePath in pairs(files) do
		if fileExists(filePath) then continue end
		table.insert(found, filePath)
	end
	
	if #found > 0 then
		Log("ReportLuaDir for " .. ply:Name() .. ":")
		if #found > 20 then
			Log("Too many results, storing in ply.ReportLuaDir variable. (" .. #found .. ")")
			ply.ReportLuaDir = found
		else
			Log("Results:")
			PrintTable(found)
		end
		Log("End of ReportLuaDir for " .. ply:Name())
	else
		Log("Nothing out of ordinary for " .. ply:Name())
	end
	ply.Scanning = false
end)

aowl.AddCommand("scanlua", function(ply, line, target)
	if ongoing then return Log("ReportLuaDir is still ongoing.") end
	Log("Starting ReportLuaDir")
	if target then
		target = easylua.FindEntity(target)
		if not target or not target:IsPlayer() then
			return print("Invalid player to scan")
		end
		Log("ReportLuaDir is targetting player " .. target:Name())
	end
	
	ongoing = true
	for _, ply in pairs(IsValid(target) and {target} or player.GetAll()) do
		ply.Scanning = true
	end
	
	net.Start("ReportLuaDirStart")
	net.Send(target and {target} or player.GetAll())
	
	timer.Simple(5, function()
		for _, ply in pairs(IsValid(target) and {target} or player.GetAll()) do
			if ply.Scanning then
				Log("After 5 seconds, no response from " .. ply:Name())
			end
			ply.Scanning = nil
		end
		ongoing = false
	end)
end,  "moderators")