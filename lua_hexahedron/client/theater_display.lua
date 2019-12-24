theater = theater or {}

theater.displays = {
	rp_downtown_v4c_v2 = {
		{
			w = 170, h = 96,
			pos = Vector(-1315.14, 957.78, 22.268268),
			ang = Angle(0, 0, 90),
			bg  = true,
		},

		{
			w = 140, h = 78.75,
			pos = Vector(-1513.589966, 999.031250, -95.705505),
			ang = Angle(0, 180, 90),
			bg  = false,
		},

		{
			w = 140, h = 78.75,
			pos = Vector(-2009.5926513672, 1658.96875, 67.435836791992),
			ang = Angle(0, 0, 90),
			bg  = false,
		},
	}
}

local l = theater.displays[game.GetMap()]
if not l then
	theater.drawDisplays = function() end

	return
end

local HTMLMAT_STYLE_THEATER_DISPLAY = 'htmlmat.style.theater_display'
AddHTMLMaterialStyle( HTMLMAT_STYLE_THEATER_DISPLAY, {
	width = 1920,
	height = 1080,
	css = [[
img {
	-webkit-filter: blur(8px) grayscale(0.2) brightness(0.8);
	-webkit-transform: translate(-50%, -50%) scale(1.05, 1.05);
}]]
}, HTMLMAT_STYLE_COVER_IMG )

function theater.drawDisplays()
	local ent = ents.FindByClass("theater_screen")[1]
	if not IsValid(ent) then return end

	local thumbnail = ent.GetMediaThumbnail and ent:GetMediaThumbnail() or "https://i.ytimg.com/vi/0OhJHg0S5wE/maxresdefault.jpg"
	local title     = ent.GetMediaTitle and ent:GetMediaTitle() or "Error!"
	local nxt       = ent.GetNextMediaTitle and ent:GetNextMediaTitle() or "None"

	if thumbnail == "" then thumbnail = nil end

	for i, v in ipairs(l) do
		local w, h = v.w, v.h

		if v.bg ~= false then
			cam.Start3D2D(v.pos, v.ang, 1)
				surface.SetDrawColor(color_black)
				surface.DrawRect(0, 0, w - 1, h - 1)

				if thumbnail then
					DrawHTMLMaterial(thumbnail, HTMLMAT_STYLE_THEATER_DISPLAY, w, h)
				end
			cam.End3D2D()
		end


		local scale = w / 1060
		cam.Start3D2D(v.pos, v.ang, scale)
			local tw, th = w / scale, h / scale
			draw.SimpleTextOutlined("Currently Playing:", "MediaTitle",
				tw/2, th * 0.4 + 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, color_black)

			draw.SimpleTextOutlined(title, "DermaLarge",
				tw/2, th * 0.4 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)

			draw.SimpleTextOutlined("Next Up:", "MediaTitle",
				tw/2, th * 0.6 + 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, color_black)

			draw.SimpleTextOutlined(nxt, "DermaLarge",
				tw/2, th * 0.6 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)

			if v.bg ~= false then
				draw.SimpleTextOutlined("www.hexahedron.pw", "Default",
					tw - 11, 11, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
			end
		cam.End3D2D()
	end
end

hook.Add("PostDrawTranslucentRenderables", "theater.displays", function() local s, a = pcall(theater.drawDisplays) if not s then print(s, a) end end)
