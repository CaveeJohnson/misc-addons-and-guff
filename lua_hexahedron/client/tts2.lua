tts = {}
tts.main_url = "http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q="
tts.range = 600
tts.range_sqr = tts.range*tts.range


local function _genericHandle(s, ec, es)
	if IsValid(s) then
		s:Play()
	else
		print("TTS: TTS failed, error code and string\n", ec, es)
	end
end

local function _handleToPlayer(ply)
	return function(s, ec, es)
		if IsValid(s) then
			s:Play()
			s:Set3DFadeDistance(tts.range / 2, tts.range)

			local tag = tostring(s)
			hook.Add("Think", tag, function()
				if not IsValid(s) then
					return hook.Remove("Think", tag)
				end

				if s:GetState() ~= GMOD_CHANNEL_PLAYING then
					s:Stop()

					return hook.Remove("Think", tag)
				end

				if not IsValid(ply) then
					s:Stop()

					return hook.Remove("Think", tag)
				end

				s:SetPos(ply:GetPos())
			end)
		else
			print("TTS: TTS failed, error code and string\n", ec, es)
		end
	end
end


local accentTranslate = {
	gb = "en-gb",
	us = "en-us",
	au = "en-au",
	be = "nl-be",
	cn = "zh-cn",
	sr = "sr-sp",
	es = "es-es",
	mx = "es-mx",
	ph = "en-ph",
}

function tts.getAccent(attempt)
	local try = (attempt or "en-gb"):lower()
	try = accentTranslate[try] or try

	return try
end

function tts.say(text, accent)

	local text = text or "invalid tts"
	text = text:gsub("%s","%%20")

	local accent = tts.getAccent(accent)
	sound.PlayURL(tts.main_url .. text .. "&tl=" .. accent, "noblock mono", _genericHandle)
end

function tts.sayply(ply, text, accent)
	local text = text or "invalid tts"
	text = text:gsub("%s","%%20")

	local accent = tts.getAccent(accent)
	sound.PlayURL(tts.main_url .. text .. "&tl=" .. accent, "noblock mono 3d", _handleToPlayer(ply))
end

function tts.sayplyCountry(ply, text)
	local text = text or "invalid tts"
	text = text:gsub("%s","%%20")

	local code = ply.GetCountryCode and ply:GetCountryCode()
	if not code or code == "N/A" or code == "error" then code = "en-gb" end
	code = ply.accentOverride or code

	local accent = tts.getAccent(code)
	sound.PlayURL(tts.main_url .. text .. "&tl=" .. accent, "noblock mono 3d", _handleToPlayer(ply))
end



tts.enabled = CreateClientConVar("tts_enabled", "0", true, true, "Should TTS (text to speech) be enabled?")

hook.Add("OnPlayerChat", "tts", function(ply, text)
	if system.HasFocus() == false or not tts.enabled:GetBool() then return end

	if IsValid(ply) and ply:IsPlayer() and ply:Alive() and not (ply.IsSpec and ply:IsSpec()) and not text:match("^[!|/|%.]") then
		local pos = ply:GetPos()
		local pos2 = LocalPlayer():GetPos()

		if pos2:DistToSqr(pos) <= tts.range_sqr then
			tts.sayplyCountry(ply, text)
		end
	end
end)