if CLIENT then

	function surface.DrawShadowedText(font, text, color,  x, y, x_offset, y_offset)
		surface.SetFont(font)
		surface.SetTextColor(0, 0, 0, 192)
		local _x, _y = surface.GetTextSize(text)
		surface.SetTextPos(x - (_x * 0.5) - x_offset, y - (_y * 0.5) - y_offset)
		surface.DrawText(text)

		surface.SetTextColor(color)
		surface.SetTextPos(x - (_x * 0.5), y - (_y * 0.5))
		surface.DrawText(text)
	end
	
end

if SERVER then

	local META = FindMetaTable("Player")

	META.SetBodyGroup = function(self, ...)
		self:SetSaveValue("SetBodyGroup", ...)
	end

	META.Revive = function(self)
		if not self:Alive() then
			local pos, ang = self:GetPos(), self:EyeAngles()
			self:Spawn()
			self:SetPos(pos) self:SetEyeAngles(ang)
		end
	end

end