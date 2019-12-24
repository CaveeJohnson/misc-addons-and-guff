
function easylua.EndEntity(spawn, reinit)

	ENT.Model = ENT.Model or Model("models/props_borealis/bluebarrel001.mdl")

	if not ENT.Base then -- there can be Base without Type but no Type without base without redefining every function so um
		ENT.Base = "base_anim"
		ENT.Type = ENT.Type or "anim"
	end

	scripted_ents.Register(ENT, ENT.ClassName)
	baseclass.Set(ENT.ClassName, ENT) -- why doesnt this get done by default

	for key, entity in pairs(ents.FindByClass(ENT.ClassName)) do
		--table.Merge(entity:GetTable(), ENT)
		if reinit then
			entity:Initialize()
		end
	end

	if SERVER and spawn then
		create(ENT.ClassName)
	end

	ENT = nil
end
