materials = materials or {}

materials.Replaced = {}

function materials.MakeInvis(path)
	if check then check(path, "string") end
	if check then check(to, "string", "ITexture", "Material") end

	path = path:lower()

	local mat = Material(path)

	if (not mat:IsError()) then

		materials.Replaced[path] = materials.Replaced[path] or {}

		materials.Replaced[path].OldTexture = materials.Replaced[path].OldTexture or mat:GetTexture("$basetexture")
		materials.Replaced[path].NewTexture = "invis"

		mat:SetUndefined("$basetexture")
		mat:SetInt("$alpha", 1)
		mat:Recompute()

		return true
	end

	return false
end

function materials.ReplaceTexture(path, to)
	if check then check(path, "string") end
	if check then check(to, "string", "ITexture", "Material") end

	path = path:lower()

	local mat = Material(path)

	if (not mat:IsError()) then

		local typ = type(to)
		local tex

		if (typ == "string") then
			tex = Material(to):GetTexture("$basetexture")

		elseif (typ == "ITexture") then
			tex = to
		elseif (typ == "Material") then
			tex = to:GetTexture("$basetexture")

		else
			return false
		end

		materials.Replaced[path] = materials.Replaced[path] or {}

		materials.Replaced[path].OldTexture = materials.Replaced[path].OldTexture or mat:GetTexture("$basetexture")
		materials.Replaced[path].NewTexture = tex

		mat:SetTexture("$basetexture",tex)

		return true
	end

	return false
end

function materials.SetColor(path, color)
	if check then check(path, "string") end
	if check then check(color, "Vector") end

	path = path:lower()

	local mat = Material(path)

	if (not mat:IsError()) then
		materials.Replaced[path] = materials.Replaced[path] or {}
		materials.Replaced[path].OldColor = materials.Replaced[path].OldColor or mat:GetVector("$color")
		materials.Replaced[path].NewColor = color

		mat:SetVector("$color", color)

		return true
	end

	return false
end

function materials.RestoreAll()
	for name, tbl in next, materials.Replaced do
		local ok, msg = pcall(function()
			if tbl.OldTexture then
				materials.ReplaceTexture(name, tbl.OldTexture)
			end

			if tbl.OldColor then
				materials.SetColor(name, tbl.OldColor)
			end
		end)

		if (not ok) then
			print("Failed to restore: " .. tostring(name) .. "(" .. msg .. ")")
		end
	end
end
hook.Add("ShutDown", "material_restore", materials.RestoreAll)
