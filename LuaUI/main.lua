Spring.Echo("IM LUAUI aehoo")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    main.lua
--  brief:   the entry point from gui.lua, relays call-ins to the widget manager
--  author:  Dave Rodgers
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
LUAUI_DIRNAME = "LuaUI/"
LUAUI_VERSION = "LuaUI v0.3"

Spring.SendCommands({ "ctrlpanel " .. LUAUI_DIRNAME .. "ctrlpanel.txt" })

VFS.Include(LUAUI_DIRNAME .. "utils.lua", utilFile)

WG = {}
Spring.Utilities = {}
VFS.Include("LuaRules/Utilities/glvolumes.lua")
VFS.Include("LuaUI/fonts.lua")

include("setupdefs.lua")
include("savetable.lua")

include("debug.lua")
include("layout.lua") -- contains a simple LayoutButtons()
include("widgets.lua") -- the widget handler

--------------------------------------------------------------------------------
--
-- print the header
--

if RestartCount == nil then
	RestartCount = 0
else
	RestartCount = RestartCount + 1
end

do
	local restartStr = ""
	if RestartCount > 0 then
		restartStr = "  (" .. RestartCount .. " Restarts)"
	end
	Spring.SendCommands({ "echo " .. LUAUI_VERSION .. restartStr })
end

--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--  A few helper functions
--

function Say(msg)
	Spring.SendCommands({ "say " .. msg })
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--  Update()  --  called every frame
--

activePage = 0

forceLayout = true

function Update()
	local currentPage = Spring.GetActivePage()
	if forceLayout or (currentPage ~= activePage) then
		Spring.ForceLayoutUpdate() --  for the page number indicator
		forceLayout = false
	end
	activePage = currentPage

	fontHandler.Update()

	widgetHandler:Update()

	return
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--  WidgetHandler fixed calls
--

function Shutdown()
	return widgetHandler:Shutdown()
end

function ConfigureLayout(command)
	return widgetHandler:ConfigureLayout(command)
end

function CommandNotify(id, params, options)
	return widgetHandler:CommandNotify(id, params, options)
end

function DrawScreen(vsx, vsy)
	widgetHandler:SetViewSize(vsx, vsy)
	return widgetHandler:DrawScreen()
end

function KeyPress(key, mods, isRepeat, label, unicode)
	return widgetHandler:KeyPress(key, mods, isRepeat, label, unicode)
end

function KeyRelease(key, mods, label, unicode)
	return widgetHandler:KeyRelease(key, mods, label, unicode)
end

function MouseMove(x, y, dx, dy, button)
	return widgetHandler:MouseMove(x, y, dx, dy, button)
end

function MousePress(x, y, button)
	return widgetHandler:MousePress(x, y, button)
end

function MouseRelease(x, y, button)
	return widgetHandler:MouseRelease(x, y, button)
end

function IsAbove(x, y)
	return widgetHandler:IsAbove(x, y)
end

function GetTooltip(x, y)
	return widgetHandler:GetTooltip(x, y)
end

function AddConsoleLine(msg, priority)
	return widgetHandler:AddConsoleLine(msg, priority)
end

function GroupChanged(groupID)
	return widgetHandler:GroupChanged(groupID)
end

--
-- The unit (and some of the Draw) call-ins are handled
-- differently (see LuaUI/widgets.lua / UpdateCallIns())
--

--------------------------------------------------------------------------------
