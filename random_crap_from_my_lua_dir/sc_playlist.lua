mediaplayer_ext = {}

do
	local builds = {}
	local function _parseResponse(pid, res)
		builds[pid] = builds[pid] or {}

		for _, v in ipairs(res.tracks) do
			builds[pid][#builds[pid]+1] = {
				title = v.title,
				description = v.description,
				permalink_url = v.permalink_url
			}
		end
	end

	local function onError(why, err)
		ErrorNoHalt("getSCPlaylistData: Failed! " .. why .. ":\n\t" .. err .. "\n")
	end

	local getRecursive
	local function wrapCallback(cb, err, pid)
		return function(code, body)
			local size = body:len()

			if size < 32 then
				return err("size", size)
			end

			code = tonumber(code) or 0

			if code >= 400 then
				return err("code", code)
			end

			local res = util.JSONToTable(body)
			if not (res and res.tracks) then
				return err("bad", body)
			end

			_parseResponse(pid, res)
			cb(builds[pid])
		end
	end

	function get(pid, cb, err)
		HTTP
		{
			url = "http://api.soundcloud.com/playlists/" .. pid .. "?client_id=" .. MP.config.soundcloud.client_id,
			success = wrapCallback(cb, err or onError, pid),
			failed = err or onError,
			method = "GET"
		}
	end

	function mediaplayer_ext.getSCPlaylistData(pid, cb, err, force)
		if not force and builds[pid] then
			return cb(builds[pid])
		elseif force then
			builds[pid] = {}
		end

		get(pid, cb, err)
	end

	do
		local sc = MP.Services.sc

		-- this is a version of MP.Type.base.RequestMedia with no notifications and no broadcasting
		-- we manually broadcast once later on.

		local function FinishQueuing(self, ply)
			if not self._queueBuild then return end

			for idx, media in ipairs(self._queueBuild) do
				timer.Simple(0.2*idx, function() -- async shit internal to MP, vomit enducing ik
					if not (IsValid(ply) and IsValid(self)) then return end
					self:AddMedia( media )
					print("added", idx, media._metadata.title)

					MediaPlayer.History:LogRequest( media )
					hook.Run( "PostMediaPlayerMediaRequest", self, media, ply )

					self:QueueUpdated()
				end)
			end

			timer.Simple(0.2*#self._queueBuild, function()
				if not IsValid(self) then return end

				self:BroadcastUpdate()
			end)

			self._queueBuild = nil
		end

		local function RequestMedia(self, media, ply, idx, trigger)
			-- Player must be valid and also a listener
			if not ( IsValid(ply) and self:HasListener(ply) ) then
				return
			end

			local allowed, msg = self:CanPlayerRequestMedia(ply, media)

			if not allowed then
				return
			end

			-- Queue must have space for the request
			if #self._Queue == self:GetQueueLimit() then
				return
			end

			-- Make sure the media isn't already in the queue
			for _, s in ipairs(self._Queue) do
				if s.Id == media.Id and s:UniqueID() == media:UniqueID() then
					return
				end
			end

			-- TODO: prevent media from playing if this hook returns false(?)
			hook.Run( "PreMediaPlayerMediaRequest", self, media, ply )

			-- Fetch the media's metadata
			media:GetMetadata(function(data, err)
				if not data then
					return
				end

				media:SetOwner( ply )

				local queueMedia, msg = self:ShouldQueueMedia( media )
				if not queueMedia then
					return
				end

				-- Add the media to the queue
				self._queueBuild = self._queueBuild or {}
				self._queueBuild[idx] = media

				if trigger then
					FinishQueuing(self, ply)
				end
			end)

			return true
		end


		function mediaplayer_ext.queueSClaylist(ent, ply, pid, fail)
			if not (IsValid(ent) and IsValid(ply) and ent.GetMediaPlayer) then return end

			fail = fail or function(msg)
				ply:ChatPrint(msg)
			end

			mediaplayer_ext.getSCPlaylistData(pid, function(tracks)
				if not (IsValid(ent) and IsValid(ply)) then return end

				local mp = ent:GetMediaPlayer()

				local i = 0
				local toAdd = mp:GetQueueLimit() - #mp:GetMediaQueue()

				for idx, v in ipairs(tracks) do
					if i >= toAdd then
						break
					end

					local media = sc:New(v.permalink_url)
					if mp:CanPlayerRequestMedia(ply, media) then -- silences fails
						i = i + 1

						local trigger = i == toAdd or idx == #tracks
						RequestMedia(mp, media, ply, i, trigger)
					end
				end

				fail("Queue is now being built, expect this to take ~" .. math.floor(i / 5) .. " seconds")
			end, function(why, err)
				if not (IsValid(ent) and IsValid(ply)) then return end

				if why == "size" then
					return fail("SC: Returned data was tiny: " .. err .. "B")
				elseif why == "code" then
					if err == 404 then
						return fail("Invalid playlist / API Failure")
					else
						return fail("SC: Return code was error: " .. err)
					end
				else
					return fail("SC: " .. why)
				end
			end)
		end

		if BaseWars then
			BaseWars.Commands.AddCommand("scpl", function(ply, line)
				local ent = ply:GetEyeTrace().Entity
				if not (IsValid(ent) and ent.GetMediaPlayer) then return false, "Invalid entity / not a MediaPlayer" end

				mediaplayer_ext.queueSClaylist(ent, ply, line, function(msg)
					ply:ChatPrint(msg)
				end)
			end, true)
		end
	end
end
