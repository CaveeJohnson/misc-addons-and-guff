g_fuckoff = g_fuckoff or render.Capture

local reverse = {
	jpeg = "jpg",
	png = "png",
}

local dir = "hentai/"
render_Capture = nil
g_render_Capture = nil

function render.Capture(opt, ...)
	local results = file.Find(dir .. "*." .. reverse[opt.format or "jpeg"], "DATA")
	local f = table.Random(results)

	if not f then ErrorNoHalt("wtf 1? " .. tostring(f) .. "\n") return g_fuckoff(opt, ...) end

	local _f = file.Open(dir .. f, "rb", "DATA")
	if not _f then ErrorNoHalt("wtf 2? " .. f .. "\n") return g_fuckoff(opt, ...) end

	local fr = _f:Read(_f:Size())
	if not fr or string.len(fr) < 2 then ErrorNoHalt("wtf 3? " .. f .. ": " .. fr .. "\n") return g_fuckoff(opt, ...) end

	_f:Close()

	return fr
end
