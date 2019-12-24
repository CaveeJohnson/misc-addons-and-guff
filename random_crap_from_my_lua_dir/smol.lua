local function size(a, delta)
	if IsValid(a) and a:IsPlayer() then a:SetViewOffset(Vector(0, 0, 35 + delta)) a:SetViewOffsetDucked(Vector(0, 0, 18 + delta)) a:SetHull(Vector(-16, -16, 0), Vector(16, 16, 35 + delta)) a:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 18 + delta)) end
end

koba:SetModelScale(0.6, 1)
size(koba, 4)

--[[
	size(eclipse, 6)
size(potato, 9)
size(rudy, 25)
]]
