if not RmlUi then
	Spring.Echo("No RmlUI!")
	return false
end

function widget:GetInfo()
	return {
		name = "RML Action Panel",
		desc = "Action Panel",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "https://unlicense.org/",
		layer = -828888,
		handler = true,
		enabled = true,
	}
end

local document
widget.rmlContext = nil

local BUTTON_LEFT_MOUSE = 0
local MAX_COLUMNS_PER_ROW = 4
local MAX_ROWS = 3

-- this can be overwritten later to change what code exampleEventHook calls
local eventCallback = function(ev, row, column)
	if ev.parameters.button == BUTTON_LEFT_MOUSE then
		Spring.Echo("Clicked row " .. row .. " column " .. column)
	end
end

--- @class Model
--- @field button_hook function
--- @field actions ActionButton[][]

--- @class ActionButton
--- @field name string
--- @field row integer
--- @field column integer
--- @field visible boolean

local dm_handle --- @type Model
--- @type Model
local init_model = {
	button_hook = eventCallback,

	actions = {
		{
			{ name = "test 1,1", row = 1, column = 1, visible = true },
			{ name = "test 1,2", row = 1, column = 2, visible = true },
			{ name = "test 1,3", row = 1, column = 3, visible = true },
			{ name = "test 1,4", row = 1, column = 4, visible = false },
		},
		{
			{ name = "test 2,1", row = 2, column = 1, visible = true },
			{ name = "test 2,2", row = 2, column = 2, visible = true },
			{ name = "test 2,3", row = 2, column = 3, visible = true },
			{ name = "test 2,4", row = 1, column = 4, visible = false },
		},
		{
			{ name = "test 3,1", row = 3, column = 1, visible = true },
			{ name = "test 3,2", row = 3, column = 2, visible = true },
			{ name = "test 3,3", row = 3, column = 3, visible = true },
			{ name = "test 3,4", row = 1, column = 4, visible = false },
		},
	},
}

--- @class UnitOrder
--- @field type integer
--- @field action string
--- @field id integer
--- @field tooltip string
--- @field cursor string
--- @field showUnique boolean
--- @field params table
--- @field name string
--- @field onlyTexture boolean
--- @field disabled boolean
--- @field hidden boolean
--- @field queueing boolean
--- @field texture string

local function clear_menu()
	for _, row in pairs(dm_handle.actions) do
		for _, value in pairs(row) do
			value.visible = false
		end
	end
	Spring.Echo("menu cleared")
end

local function layoutHandler(xIcons, yIcons, cmdCount, commands)
	local debug_text = ""
	for _, value in pairs(commands) do
		debug_text = debug_text .. value.name .. ", "
	end
	Spring.Echo(debug_text)

	clear_menu()
	local column = 1
	local row = 1
	for i = 1, cmdCount, 1 do
		--- @type UnitOrder
		local command = commands[i]
		--- @type ActionButton
		local entry = dm_handle.actions[row][column]

		entry.name = "[" .. command.name .. "]"
		entry.visible = not (command.hidden or command.disabled)

		row = math.floor(i / MAX_ROWS) + 1
		column = (i % MAX_COLUMNS_PER_ROW) + 1
		Spring.Echo("Set entry " .. tostring(row) .. ", " .. tostring(column))
	end
	return "", xIcons, yIcons, {}, {}, {}, {}, {}, {}, {}, { [1337] = 9001 }
end

local function OverrideDefaultMenu()
	widgetHandler:ConfigLayoutHandler(layoutHandler)
end

function widget:Initialize()
	widget.rmlContext = RmlUi.CreateContext(widget.whInfo.name)

	dm_handle = widget.rmlContext:OpenDataModel("action_panel_model", init_model)
	if not dm_handle then
		Spring.Echo("RmlUi: Failed to open data model ", "action_panel_model")
		return
	end

	document = widget.rmlContext:LoadDocument("LuaUi/Widgets/hud/action_panel.rml", widget)
	if not document then
		Spring.Echo("Failed to load document")
		return
	end

	OverrideDefaultMenu()

	RmlUi.SetDebugContext(widget.whInfo.name)
	document:ReloadStyleSheet()
	document:Show()
end

function widget:Shutdown()
	if document then
		document:Close()
	end
	if widget.rmlContext then
		RmlUi.RemoveContext(widget.whInfo.name)
	end
end
