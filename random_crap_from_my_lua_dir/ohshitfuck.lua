for name, callback in pairs(net.Receivers) do
	local name, func = debug.getupvalue(callback, 2)
	chat.AddText("aaaaa -> ", name, tostring(func))

	return
end
