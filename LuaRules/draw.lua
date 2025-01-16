local commandCursors = {
	Attack = "attack",
	Move = "move",
}

Spring.AssignMouseCursor("", "cursordefend", true)

for commandName, cursor in pairs(commandCursors) do
	if Spring.AssignMouseCursor(commandName, "cursor" .. cursor, true) then
		Spring.Echo("DID ASSIGN", commandName, "cursor" .. cursor)
	else
		Spring.Echo("DIDNT ASSIGN", commandName, "cursor" .. cursor)
	end
end
--
VFS.Include("LuaGadgets/gadgets.lua", nil, VFS.BASE)
