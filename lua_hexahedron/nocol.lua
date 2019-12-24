local classes = {
	mediaplayer_tv = true,
	gmod_light = true,
}

local rm_col = function(ent)
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

local test = function(ent)
	if classes[ent:GetClass()] then
		rm_col(ent)
	end
end

if SERVER then hook.Add("OnEntityCreated", "collsionRemoval", test) end

local test2 = function(ply, prop, ent)
	if classes[ent:GetClass()] and prop == "collision" then
		return false
	end
end

hook.Add("CanProperty", "collsionRemoval", test2)
