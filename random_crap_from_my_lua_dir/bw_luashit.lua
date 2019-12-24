hook.Add("Think","luadev_cmdsinit",function()
hook.Remove("Think","luadev_cmdsinit")

local function add(cmd,callback)
	if BaseWars and BaseWars.Commands.AddCommand then
		BaseWars.Commands.AddCommand(cmd,function(ply,script,param_a,...)
			if not ply:IsSuperAdmin() then return false, "fuck off" end

			local a,b

			easylua.End() -- nesting not supported

			local ret,why = callback(ply,script,param_a,...)
			if not ret then
				if why == false then
					a, b = false, why or "not found: " .. tostring(param_a or "none")
				elseif isstring(why) then
					ply:ChatPrint("FAILED: " .. tostring(why))
					a, b = false, tostring(why)
				end
			end

			easylua.Start(ply)
			return a,b

		end, true)
	end
end

local function X(ply,i) return luadev.GetPlayerIdentifier(ply,'cmd:'..i) end

add("l", function(ply, line, target)
	if not line or line=="" then return false,"invalid script" end
	return RunString(line)
end)

add("ls", function(ply, line, target)
	if not line or line=="" then return false,"invalid script" end

	RunString(line)
	return all:SendLua(line)
end)

add("lc", function(ply, line, target)
	if not line or line=="" then return end
	return all:SendLua(line)
end)

end)
