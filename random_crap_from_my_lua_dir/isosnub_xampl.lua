isosnub.events.register("DebugHook", "some_event")

isosnub.events.register("DebugHook2", "some_event2", function(arg1, ply)
	return ply, arg1, "big homo"
end)

isosnub.templates.create("test")
	:setName("Test Ach")
	:setDescription("big gay xdxd longer desc, nice and long description xd")
	:setThreshold(10)

	:incrementOn("some_event")
	:incrementOnEx("some_event2", function(self, arg1, custom)
		print("inc -> some_event2; ", arg1, custom)

		self:increment(2)
	end)

	:listen("completed", function(self)
		print(self:getPlayer(), " has the big gay")
	end)
