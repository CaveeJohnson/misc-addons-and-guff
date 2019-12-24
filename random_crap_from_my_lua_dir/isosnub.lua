isosnub = isosnub or {}

-- util + class
do
	local numbers = {1, 5, 10, 50, 100, 500, 1000}
	local num_count = #numbers
	local chars = {"I", "V", "X", "L", "C", "D", "M"}

	function isosnub.romanNumeral(s)
		s = tonumber(s)
		if not s or s ~= s or s > 1e4 then return "error" end

		s = math.floor(s)
		if s <= 0 then return s end

		local ret = ""

		for i = num_count, 1, -1 do
			local num = numbers[i]

			while s - num >= 0 and s > 0 do
				ret = ret .. chars[i]
				s = s - num
			end

			for j = 1, i - 1 do
				local n2 = numbers[j]

				if s - (num - n2) >= 0 and s < num and s > 0 and num - n2 ~= n2 then
					ret = ret .. chars[j] .. chars[i]
					s = s - (num - n2)

					break
				end
			end
		end

		return ret
	end
end

function isosnub.typeCheck(expected, n, var)
	if type(var) ~= expected then
		isosnub.typeError(debug.getinfo(2).name, n, expected, var, 4)
	end
end

function isosnub.typeError(f, n, expected, var, level)
	error(string.format("bad argument #%d to '%s' (%s expected, got %s)", n, f, expected, type(var)), level or 3)
end

function isosnub.getSet(meta, var, expected, get, set)
	local name = var:gsub("^(%l)", string.upper)

	local get_name = (get or "get") .. name
	meta[get_name] = function(o)
		return o[var]
	end

	local set_name = (set or "set") .. name
	meta[set_name] = function(o, val)
		if expected then
			isosnub.typeCheck(expected, 1, val)
		end

		o[var] = val
		return o -- chaining support
	end
end

function isosnub.isSet(meta, var, expected)
	isosnub.getSet(meta, var, expected, "is")
end

function isosnub.hasSet(meta, var, expected)
	isosnub.getSet(meta, var, expected, "has")
end


-- resources

isosnub.resources = isosnub.resources or {}

local generators = isosnub.resources.generators or {}
isosnub.resources.generators = generators

local cache = isosnub.resources.cache or {}
isosnub.resources.cache = cache

do
	local color_mat = Material("color")

	local PNG_HEADER = "^\x89\x50\x4E\x47"
	local JPG_HEADER = "^\xFF\xD8"

	local formats = {
		jpg = true,
		png = true,
		dat = true,
	}

	if CLIENT then
		file.CreateDir("isosnub_href")
	end

	generators["href"] = function(url)
		local state    = nil
		local material = nil

		local uid = url:match("([^/]+)$"):gsub("[^%.]+$", ""):gsub("[^%w]", "_"):Trim("_"):Trim() -- victory royale

		for f in pairs(formats) do
			local path = "isosnub_href/" .. uid .. "." .. f

			if file.Exists(path, "DATA") then
				material = Material("../data/" .. path)

				if material:IsError() then
					material = nil
				else
					state = true
					break
				end
			end
		end

		if not state then
			http.Fetch(url, function(body, sz, headers, code)
				if code >= 400 and code < 600 then
					ErrorNoHalt("\n href-resource: got error on fetch: http code " .. tostring(code) .. "\n\n")
					return
				end

				if sz <= 4 then
					ErrorNoHalt("\n href-resource: got error on fetch: tiny size\n\n")
					return
				end

				local png = body:match(PNG_HEADER)
				local jpg = body:match(JPG_HEADER)
				if not (png or jpg) then
					ErrorNoHalt("\n href-resource: got error on fetch: unknown format '" .. body:sub(1, 8) .. "'\n\n")
					return
				end

				local ext = (jpg and "jpg") or (png and "png") or "dat"
				local path = uid .. "." .. ext

				file.Write("isosnub_href/" .. path, body)

				material = Material("../data/isosnub_href/" .. path)
				if not material:IsError() then
					state = true
				else
					ErrorNoHalt("\n href-resource: failed to load material after save??\n\n")
				end
			end, function(err)
				ErrorNoHalt("\n href-resource: got error on fetch: " .. err .. "\n\n")
			end)
		end

		return function(x, y, w, h)
			if not (state and material) then
				local delta = math.abs(math.sin(CurTime() * 10)) * 55

				surface.SetDrawColor(200 + delta, 180 + delta, 200 + delta, 255)
				surface.SetMaterial(color_mat)
			else
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(material)
			end

			surface.DrawTexturedRect(x, y, w, h)
		end
	end
end

function isosnub.resources.getDrawFunc(ref, force)
	if SERVER then return end
	if cache[ref] and not force then return cache[ref] end

	local scheme, path = ref:match("^(.-):(.+)$")
	local generator = generators[scheme]

	if not generator then
		error(string.format("getDrawFunc: icon scheme was invalid: '%s'", scheme))
	end

	cache[ref] = generator(path)
	return cache[ref]
end


-- achievement objects

isosnub.templates = isosnub.templates or {}

local list = isosnub.templates.list or {}
isosnub.templates.list = list

local list_count = table.Count(list)

local achMeta = {}
do
	isosnub.achievementMeta = achMeta

	isosnub.getSet(achMeta, "name"        , "string" )
	isosnub.getSet(achMeta, "description" , "string" )
	isosnub.getSet(achMeta, "threshold"   , "number" )
	isosnub.getSet(achMeta, "count"       , "number" )
	isosnub.getSet(achMeta, "currentTier" , "number" )
	isosnub.getSet(achMeta, "maxTier"     , "number" )
	isosnub.getSet(achMeta, "completedAt" , "number" )
	isosnub.getSet(achMeta, "dependencies", "table"  )
	isosnub.getSet(achMeta, "listeners"   , "table"  )
	isosnub.getSet(achMeta, "hooks"       , "table"  )
	isosnub.getSet(achMeta, "player"      , "Player" )
	isosnub.isSet (achMeta, "hidden"      , "boolean")
	isosnub.isSet (achMeta, "tiered"      , "boolean")
	isosnub.isSet (achMeta, "completed"   , "boolean")

	-- instance related
	function achMeta:getOtherForInstance(id)
		return isosnub.getFor(id, self:getPlayer())
	end


	-- tier related
	function achMeta:setThresholdFunction(f)
		isosnub.typeCheck("function", 1, f)

		self.threshold_function = f
		self:setTiered(true)

		return self
	end

	function achMeta:getThresholdFunction()
		return self.threshold_function
	end

	function achMeta:getRealThreshold()
		local const = self.threshold

		if self:isTiered() or (not const or const <= 0) then
			local f = self:getThresholdFunction()
			if not f then return 1 end

			return f(self, self:getCurrentTier() or 1) or 1
		end

		return const
	end


	-- icon related
	function achMeta:setIcon(ref)
		isosnub.typeCheck("string", 1, ref)

		self.icon_ref  = ref
		self.icon_draw = isosnub.resources.getDrawFunc(ref)

		return self
	end

	function achMeta:getIconRef()
		return self.icon_ref
	end

	function achMeta:getIconDrawFunc()
		return self.icon_draw
	end


	-- dependency related
	function achMeta:isUnlocked()
		if not self.dependencies then return true end

		for id in pairs(self.dependencies) do
			local inst = self:getOtherForInstance(id)

			if inst and not inst:isCompleted() then return false end
		end

		return true
	end

	function achMeta:getUnlockRequirements()
		if not self.dependencies then return end
		if self._requirements then return self._requirements end

		local req = "Requires " -- todo: lang
		for id in pairs(self.dependencies) do
			if list[id] then
				req = list[id]:getName() .. ", "
			end
		end

		req = utf8.sub(req, 1, -3)

		self._requirements = req
		return req
	end

	function achMeta:addDependency(id)
		isosnub.typeCheck("string", 1, id)

		self.dependencies = self.dependencies or {}
		self.dependencies[id] = true

		self._requirements = nil

		return self
	end

	function achMeta:removeDependency(id)
		isosnub.typeCheck("string", 1, id)

		if self.dependencies then
			self.dependencies[id] = nil

			if not next(self.dependencies) then
				self.dependencies = nil
			end

			self._requirements = nil
		end

		return self
	end

	-- handle completion, events
	function achMeta:increment(amt)
		if self:isCompleted() or not self:isUnlocked() then return self end

		local current = self:getCount() or 0
		local new = current + (amt or 1)
		self:setCount(new)

		--[[MsgC(SERVER and Color(0, 255, 255) or Color(255, 0, 255), "ISOSNUB ",
			Color(255, 255, 100), " DEBUG: incremented ach -> ", self:getPlayer(), ", ", self:getCount(), ":", self:getRealThreshold(), "\n")]]

		if new >= self:getRealThreshold() then
			if self:isTiered() then
				local next_tier = (self:getCurrentTier() or 1) + 1
				if not self:getMaxTier() or next_tier <= self:getMaxTier() then
					self:setCurrentTier(next_tier)
					self:setCount(0)

					self:emit("tierup")
				else
					self:setCompleted(true)
					self:emit("completed")
				end
			else
				self:setCompleted(true)
				self:emit("completed")
			end
		else
			self:emit("progress", new)
		end

		return self
	end

	function achMeta:listen(event, f)
		isosnub.typeCheck("string", 1, event)
		isosnub.typeCheck("function", 2, f)

		self.listeners = self.listeners or {}
		self.listeners[event] = f

		return self
	end

	function achMeta:emit(event, ...)
		--[[MsgC(SERVER and Color(0, 255, 255) or Color(255, 0, 255), "ISOSNUB ",
			Color(255, 255, 100), " DEBUG: event -> ", self:getPlayer(), ", ", event, "\n")]]

		if self.listeners and self.listeners[event] then
			self.listeners[event](self, ...)
		end

		isosnub.events.callInternal(event, self, ...)

		if SERVER then
			self:getPlayer().__isosnub_shouldsave = true

			net.Start("isosnub_event")
				net.WriteString(self.id)
				net.WriteString(event)
				net.WriteUInt(select("#", ...), 8)

				for _, v in ipairs({...}) do
					net.WriteType(v)
				end

				self:writeToNetwork()
			net.Send(self:getPlayer()) -- TODO: change if networking changes
		end

		return self
	end


	-- hook listeners
	function achMeta:emitHook(game_event, ...)
		if self:isCompleted() or not self:isUnlocked() then return self end

		--[[MsgC(SERVER and Color(0, 255, 255) or Color(255, 0, 255), "ISOSNUB ",
			Color(255, 255, 100), " DEBUG: event -> ", self:getPlayer(), ", ", game_event, "\n")]]

		if self.hooks and self.hooks[game_event] then
			self.hooks[game_event](self, ...)
		end

		return self
	end

	function achMeta:incrementOn(game_event, amt, on_client)
		isosnub.typeCheck("string", 1, game_event)
		if amt ~= nil then isosnub.typeCheck("number", 2, amt) end
		if on_client ~= nil then isosnub.typeCheck("boolean", 3, on_client) end

		if CLIENT and not on_client then return self end

		self.hooks = self.hooks or {}
		self.hooks[game_event] = function(this)
			this:increment(amt)
		end

		return self
	end

	function achMeta:incrementOnEx(game_event, f, on_client)
		isosnub.typeCheck("string", 1, game_event)
		isosnub.typeCheck("function", 2, f)
		if on_client ~= nil then isosnub.typeCheck("boolean", 3, on_client) end

		if CLIENT and not on_client then return self end

		self.hooks = self.hooks or {}
		self.hooks[game_event] = f

		return self
	end


	-- networking

	function achMeta:writeToNetwork()
		net.WriteUInt(self:getCount() or 0, 32)
		net.WriteUInt(self:getCurrentTier() or 1, 8)
		net.WriteBool(self:isCompleted() or false)
	end

	function achMeta:readFromNetwork()
		self:setCount(net.ReadUInt(32))
		self:setCurrentTier(net.ReadUInt(8))
		self:setCompleted(net.ReadBool())
	end

	if CLIENT then
		surface.CreateFont("isosnub.name", {
			font = "Segoe UI",
			size = 18,
			antialias = true
		})

		surface.CreateFont("isosnub.desc", {
			font = "Segoe UI",
			size = 13,
			antialias = true
		})

		surface.CreateFont("isosnub.num", {
			font = "Consolas",
			size = 10,
			antialias = false
		})

		surface.CreateFont("isosnub.completed", {
			font = "Segoe UI",
			weight = 5000,
			size = 32,
			antialias = true
		})

		local hidden_icon_draw  = isosnub.resources.getDrawFunc("href:https://b.catgirlsare.sexy/OKth.png")
		local default_icon_draw = isosnub.resources.getDrawFunc("href:https://b.catgirlsare.sexy/TMRW.png")

		function achMeta:drawCard(show_hidden, x, y, w, h)
			local name      = self:getName()         or "unnamed"
			local desc      = self:getDescription()  or "no description"
			local icon_draw = self:getIconDrawFunc() or default_icon_draw

			local tier = self:getCurrentTier() or 0
			if self:isTiered() and tier > 1 then
				name = name .. " " .. isosnub.romanNumeral(tier)
			end

			if self:isHidden() and not show_hidden then
				name = "Secret Achievement"
				desc = "An achievement full of mystery, what could it mean?"

				icon_draw = hidden_icon_draw
			end

			local rx, ry = x - w, y - h

			surface.SetDrawColor(0, 0, 0, 240)
			surface.DrawRect(x - w, y - h, w, h)

			rx, ry = rx + 2, ry + 2
			icon_draw(rx, ry, h - 4, h - 4)

			rx = rx + h

			if not self._markup then
				self._markup = markup.Parse("<font=isosnub.desc>" .. desc .. "</font>", w - h - 4)
			end

			draw.SimpleText(name, "isosnub.name", rx, ry, Color(255, 255, 255, 255))
			self._markup:Draw(rx, ry + 20)

			local bar_size = 10
			local bar_w = w - h - 6

			rx, ry = rx + 2, y - 2

			surface.SetDrawColor(255, 127, 80, 25)
			surface.DrawRect(rx, ry - bar_size - 2, bar_w, bar_size)

			local count, threshold = self:getCount(), self:getRealThreshold()
			local perc = count / threshold

			surface.SetDrawColor(255, 127, 80, 75)
			surface.DrawRect(rx, ry - bar_size - 2, bar_w * perc, bar_size)

			draw.SimpleTextOutlined(count .. " / " .. threshold, "isosnub.num", rx, ry - math.floor(bar_size / 2) - 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
		end
	end
end

function isosnub.templates.get(id)
	return list[id]
end

function isosnub.templates.getList()
	return list, list_count
end

local m = {__index = achMeta}
function isosnub.templates.create(id)
	isosnub.typeCheck("string", 1, id)

	list_count = list_count + 1

	local obj = {
		id = id,
	}
	obj._meta = {__index = obj}

	list[id] = setmetatable(obj, m)

	return obj
end

function isosnub.templates.makeInstance(id, ply)
	isosnub.typeCheck("string", 1, id)
	isosnub.typeCheck("Player", 2, ply)

	local template = list[id]
	if not list[id] then error(string.format("makeInstance: attempting to get non-existing template '%s'"), id) end

	return setmetatable({
		player = ply
	}, template._meta)
end

function isosnub.templates.makeInstanceList(ply)
	isosnub.typeCheck("Player", 1, ply)

	local instance = {}

	for id, template in pairs(list) do
		instance[id] = setmetatable({
			player = ply
		}, template._meta)
	end

	return instance
end


-- instances
function isosnub.getListFor(ply)
	return ply.__isosnub_instance or isosnub.setupFor(ply)
end

function isosnub.getFor(id, ply)
	return isosnub.getListFor(ply)[id]
end

function isosnub.setupFor(ply)
	isosnub.typeCheck("Player", 1, ply)

	local instance = isosnub.templates.makeInstanceList(ply)
	ply.__isosnub_instance = instance

	if CLIENT and ply == LocalPlayer() then
		net.Start("isosnub_sync")
			--net.WriteEntity(ply)
		net.SendToServer()
	end

	return instance
end

if SERVER then

file.CreateDir("isosnub")

function isosnub.loadFor(ply)
	isosnub.typeCheck("Player", 1, ply)

	--[[MsgC(SERVER and Color(0, 255, 255) or Color(255, 0, 255), "ISOSNUB ",
			Color(255, 255, 100), "Loading for ", ply, "\n")]]

	local instance = isosnub.setupFor(ply)

	local data = file.Read("isosnub/" .. ply:SteamID64() .. ".txt")
	if not data then return end

	data = util.JSONToTable(data)
	if not data then return end

	net.Start("isosnub_sync")
		--net.WriteEntity(ply)
		net.WriteUInt(table.Count(instance), 16)
		for id, ach in pairs(instance) do
			net.WriteString(id)

			if data[id] then
				ach:setCount      (data[id].count or 0)
				ach:setCurrentTier(data[id].tier or 1)
				ach:setCompleted  (data[id].completed or false)
			else
				ach:setCount      (0)
				ach:setCurrentTier(1)
				ach:setCompleted  (false)
			end

			ach:writeToNetwork()
		end
	net.Send(ply)
end

function isosnub.saveFor(ply)
	isosnub.typeCheck("Player", 1, ply)

	--[[MsgC(SERVER and Color(0, 255, 255) or Color(255, 0, 255), "ISOSNUB ",
			Color(255, 255, 100), "Saving for ", ply, "\n")]]

	local data = {}
	local instance = isosnub.getListFor(ply)

	for id, ach in pairs(instance) do
		local ach_data = {}

		if ach:getCount() and ach:getCount() > 0 then
			ach_data.count = ach:getCount()
		end

		if ach:getCurrentTier() and ach:getCurrentTier() > 1 then
			ach_data.tier = ach:getCurrentTier()
		end

		if ach:isCompleted() then
			ach_data.completed = true
		end

		if next(ach_data) then
			data[id] = ach_data
		end
	end

	if next(data) then
		local serial = util.TableToJSON(data)
		file.Write("isosnub/" .. ply:SteamID64() .. ".txt", serial)
	end
end

function isosnub.sendSync(ply, _)
	net.Start("isosnub_sync")
		--net.WriteEntity(ply)
		local instance = isosnub.getListFor(ply)

		net.WriteUInt(table.Count(instance), 16)
		for id, ach in pairs(instance) do
			net.WriteString(id)
			ach:writeToNetwork()
		end
	net.Send(ply)
end


timer.Create("isosnub_autosave", 30, 0, function()
	for _, v in ipairs(player.GetAll()) do
		if v.__isosnub_shouldsave then isosnub.saveFor(v) end
	end
end)


hook.Add("Shutdown", "isosnub.save", function()
	for _, v in ipairs(player.GetAll()) do
		isosnub.saveFor(v)
	end
end)

hook.Add("PlayerDisconnected", "isosnub.save", isosnub.saveFor)
hook.Add("PlayerInitialSpawn", "isosnub.load", isosnub.loadFor)

end


-- events

isosnub.events = isosnub.events or {}

local events = isosnub.events.list or {}
isosnub.events.list = events

function isosnub.events.call(game_event, ply, args)
	local instance = isosnub.getListFor(ply)
	-- todo: cache? this must be slow

	for id, ach in pairs(instance) do
		ach:emitHook(game_event, unpack(args))
	end
end

-- might be useful, may think BUT THIS IS POINTLESS
-- but if this is optimized in the future = gains made
function isosnub.events.callForList(game_event, plys, args)
	for _, ply in ipairs(plys) do
		isosnub.events.call(game_event, ply, args)
	end
end

function isosnub.events.register(incoming, outgoing, converter)
	isosnub.typeCheck("string", 1, incoming)
	isosnub.typeCheck("string", 2, outgoing)
	if converter then isosnub.typeCheck("function", 3, converter) end

	events[incoming] = events[incoming] or {}
	events[incoming][outgoing] = "isosnub.events." .. outgoing

	local f = function(...)
		local args
		if converter then
			args = {converter(...)}

			if not args[1] then return end -- converter says no
		else
			args = {...}
		end

		local ply = table.remove(args, 1)
		if not (IsValid(ply) and ply:IsPlayer()) then
			error(string.format("isosnub.events[%s->%s]: invalid player?! please check converter function...", incoming, outgoing))
		end

		isosnub.events.call(outgoing, ply, args)
	end

	hook.Add(incoming, events[incoming][outgoing], f)
end

function isosnub.events.remove(incoming, outgoing)
	isosnub.typeCheck("string", 1, incoming)
	isosnub.typeCheck("string", 2, outgoing)

	if not (events[incoming] and events[incoming][outgoing]) then return end

	hook.Remove(incoming, events[incoming][outgoing])

	events[incoming][outgoing] = nil
	if not next(events[incoming]) then
		events[incoming] = nil
	end
end

function isosnub.events.callInternal(event, ach, ...)
	-- todo: other shit

	if CLIENT then
		local complete = event == "completed"
		local tierup   = event == "tierup"
		local count    = ach:getCount() or 0
		local cur_frac = count / ach:getRealThreshold()

		if not ach._nextNotif or tierup then
			ach._nextNotif = 0
		end

		if
			complete or             -- complete
			tierup or               -- new tier
			cur_frac > ach._nextNotif    -- after a certain point
			or math.random() > 0.97 -- few random
		then
			ach._nextNotif = ach._nextNotif or math.huge
			if cur_frac < 0.333 then
				ach._nextNotif = 0.333
			elseif cur_frac < 0.666 then
				ach._nextNotif = 0.666
			elseif cur_frac < 0.9 then
				ach._nextNotif = 0.9
			else
				ach._nextNotif = math.huge
			end

			isosnub.performNotification(ach.id, (complete and "completed") or (tierup and "next tier"))
		end
	end
end


-- handle networking

if SERVER then
	util.AddNetworkString("isosnub_event")
	util.AddNetworkString("isosnub_sync")

	-- has to be explicitly enabled on an event, allows for 'gaming' it, so as such
	-- reliance on it for anything with a major reward is a BAD idea, anything
	-- that has a reward and is endlessly tiered is also A REALLY FUCKING BAD IDEA
	-- but don't be too scared of it; since this is so bespoke and also has
	-- basic security (they cant even see the serverside code (well they wont when finished xd))
	-- and very few people will either 1: be able to 2: care about it enough
	-- to make exploits for 1-2 specific servers.

	net.Receive("isosnub_event", function(_, ply)
		error("todo: client -> server hook trigger; also needs basic security ; " .. ply:Nick())
	end)

	net.Receive("isosnub_sync", function(_, ply)
		--local ply = net.ReadEntity() -- not send self, for syncing other people
		-- disabled for now, see above/below

		isosnub.sendSync(ply, ply)
	end)
else
	net.Receive("isosnub_event", function()
		--local ply = net.ReadEntity()
		local ply = LocalPlayer()
		-- disabled for security and reduced complexity
		-- not in scope; but 99% of framework is there

		local id    = net.ReadString() -- instance id
		local event = net.ReadString() -- event name
		local count = net.ReadUInt(8)  -- amt of arguments to read

		local args = {} -- argument table
		for i = 1, count do
			table.insert(args, net.ReadType()) -- read arg
		end

		local ach = isosnub.getFor(id, ply) -- get
		if not ach then ErrorNoHalt(string.format("isosnub_event: non-existing instance firing?! '%s'\n", id)) return end

		ach:readFromNetwork()
		ach:emit(event, unpack(args)) -- send
	end)

	net.Receive("isosnub_sync", function()
		--local ply = net.ReadEntity()
		local ply = LocalPlayer() -- see above

		local count = net.ReadUInt(16)
		for i = 1, count do
			local id = net.ReadString()

			local ach = isosnub.getFor(id, ply)
			if not ach then ErrorNoHalt(string.format("isosnub_sync: non-existing instance synced?! '%s'\n", id)) return end

			ach:readFromNetwork() -- it can read itsself back in
		end
	end)
end

-- client only stuff

if CLIENT then


do
	local notifs = {}

	function isosnub.performNotification(id, special)
		local ach = isosnub.getFor(id, LocalPlayer())

		if special then
			surface.PlaySound("ambient/machines/thumper_hit.wav")
		else
			surface.PlaySound("npc/roller/mine/rmine_chirp_quest1.wav")
		end

		notifs[id] = {
			special = special,
			ach     = ach,
			start   = CurTime()
		}
	end

	local rotatedText
	do
		local mat = Matrix()
		local ang = Angle (0, 0, 0)
		local pos = Vector(0, 0, 0)
		local scl = Vector(0, 0, 0)

		function rotatedText(txt, font, x, y, col, a, sc, col2)
			sc = sc or 1

			pos.x = x
			pos.y = y

			mat:Identity()
			mat:Translate(pos)
				ang.y = a
				mat:SetAngles(ang)

				scl.x = sc
				scl.y = sc
				mat:SetScale(scl)
			mat:Translate(-pos)

			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)
				cam.PushModelMatrix(mat)
					draw.SimpleTextOutlined(txt, font, x, y, col or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, col2 or color_black)
				cam.PopModelMatrix()
			render.PopFilterMag()
			render.PopFilterMin()
		end
	end

	hook.Add("HUDDrawScoreBoard", "isosnub.notifs", function()
		local w, h = 256, 72
		local x, y = ScrW() - 8, ScrH() - 8

		local life = 8
		local ct   = CurTime()

		local needs_remove = false

		for id, v in pairs(notifs) do
			local dx = 0

			if ct > v.start + life then
				v.remove = true
				needs_remove = true
			end
			if ct > v.start + (life - 2) then
				dx = (ct - v.start - (life - 2)) * 200
			end

			v.ach:drawCard(v.completed, x + dx, y, w, h)
			local rx, ry = x - (w / 2) + dx, y - (h / 2) - 2

			if v.special then
				local tm = 0.4

				local ang, scale = 11, 1.5
				local elapsed = ct - v.start
				local elapsed_frac = math.min(tm, elapsed) / tm

				scale = scale * (2 - elapsed_frac)
				ang = ang * elapsed_frac

				local alpha = 255 - (85 * math.min(0, elapsed - tm))
				rotatedText(v.special:upper(), "isosnub.completed", rx, ry, Color(255, 50, 50, alpha), ang, scale, Color(0, 0, 0, alpha))
			end

			y = y - h - 2
		end

		if needs_remove then
			local new = {}

			for id, v in pairs(notifs) do
				if not v.remove then new[id] = v end
			end

			notifs = new
		end
	end)
end

end










local function wrapDamageForAttack(targ, attacker, inflictor)
	local ply = attacker

	if not (IsValid(ply) and ply:IsPlayer()) then
		ply = inflictor

		if not (IsValid(ply) and ply:IsPlayer()) then
			if IsValid(inflictor) then
				ply = inflictor:CPPIGetOwner()

				if IsValid(ply) and ply:IsPlayer() then
					return ply, targ
				end
			end
		else
			return ply, targ
		end
	else
		return ply, targ
	end
end

isosnub.events.register("OnNPCKilled", "kill_npc", wrapDamageForAttack)

local melee = {
	["weapon_crowbar"] = true,
	["weapon_stunstick"] = true,
	["weapon_fists"] = true,
	["m9k_damascus"] = true,
}

isosnub.events.register("OnNPCKilled", "kill_npc_melee", function(npc, attacker, inflictor)
	local ply
	ply, npc = wrapDamageForAttack(npc, attacker, inflictor)

	if ply and IsValid(ply:GetActiveWeapon()) and melee[ply:GetActiveWeapon():GetClass()] then
		return ply, npc
	end
end)

isosnub.templates.create("kill_zombies_2")
	:setName("Slayer")
	:setDescription("Slaughter the undead.")
	:setThresholdFunction(function(self, tier)
		return math.floor(10 ^ ((tier + 2) / 3))
	end)
	:setIcon("href:https://b.catgirlsare.sexy/j6gK.png")

	:incrementOn("kill_npc")

	:listen("tierup", function(self)
		if CLIENT then return end

		local killed = math.floor(10 ^ ((self:getCurrentTier() + 2) / 3))
		self:getPlayer():GiveMoney(3e3 * killed)
	end)

isosnub.templates.create("kill_zombies_melee")
	:setName("Brutalist")
	:setDescription("Slaughter the undead... with a crowbar.")
	:setThresholdFunction(function(self, tier)
		return math.floor(10 ^ ((tier + 2) / 3))
	end)
	:setIcon("href:https://b.catgirlsare.sexy/IDW3.png")

	:incrementOn("kill_npc_melee")

	:listen("tierup", function(self)
		if CLIENT then return end

		local killed = math.floor(10 ^ ((self:getCurrentTier() + 2) / 3))
		self:getPlayer():GiveMoney(1e4 * killed)
	end)
