local PLAYER = debug.getregistry().Player

if SERVER then
	function PLAYER:SetDev(bool)
		local state = tobool(bool)
		self._in_dev = state
		self:SetNWBool("_in_dev", state)
	end
end

function PLAYER:InDev()
	return SERVER and (self._in_dev or false) or self:GetNWBool("_in_dev")
end

