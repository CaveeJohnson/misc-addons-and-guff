local file_Find = file.Find

local ignore = {
	["garrysmod/lua/menu_plugins/luaviewer"] = true,
	["garrysmod/lua/slimenu"] = true,
	["garrysmod/lua/saitohud"] = true,
}

local function filesInDir(path)
	local files, dirs = file_Find(path, "BASE_PATH")
	return #table.Add(files, dirs)
end

local function recursive(path)
	local res = {}
	local files, dirs = file_Find(path .. "*", "BASE_PATH")
	
	for _, filePath in pairs(files) do
	    table.insert(res, string.Replace(path, "garrysmod/lua/", "") .. filePath)
	end
	
	for _, dirPath in pairs(dirs) do
		if ignore[path .. dirPath] then table.insert(res, "IGNORED " .. filesInDir(path .. dirPath .. "/*") .. " ITEMS IN " .. string.Replace(path, "garrysmod/lua/", "") .. dirPath .. "/*") continue end
		table.Add(res, recursive(path .. dirPath .. "/"))
	end
	
	return res
end

net.Receive("ReportLuaDirStart", function(len)
	local files = recursive("garrysmod/lua/")
	files = util.TableToJSON(files)
	files = util.Compress(files)
	local filesLen = #files
	
	net.Start("ReportLuaDir")
		net.WriteUInt(filesLen, 32)
		net.WriteData(files, filesLen)
	net.SendToServer()
end)