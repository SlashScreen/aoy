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
local DATA_MODEL_NAME = "action_panel_model"
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
local needs_update = false

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

local unit_commands --- @type UnitOrder[]

local function clear_menu()
	for r, row in pairs(dm_handle.actions) do
		for a, value in pairs(row) do
			value.visible = false
			Spring.Echo("keys are " .. r .. ", " .. a)
		end
	end
	Spring.Echo("menu cleared")
end

local function layoutHandler(xIcons, yIcons, cmdCount, commands)
	unit_commands = commands
	widgetHandler:CommandsChanged()
	return "", xIcons, yIcons, {}, {}, {}, {}, {}, {}, {}, { [1337] = 9001 }
end

local function OverrideDefaultMenu()
	widgetHandler:ConfigLayoutHandler(layoutHandler)
end

function widget:Initialize()
	widget.rmlContext = RmlUi.CreateContext(widget.whInfo.name)

	dm_handle = widget.rmlContext:OpenDataModel(DATA_MODEL_NAME, init_model)
	assert(dm_handle ~= nil, "RmlUi: Failed to open data model " .. DATA_MODEL_NAME)

	document = widget.rmlContext:LoadDocument("LuaUi/Widgets/hud/action_panel.rml", widget)
	assert(document ~= nil, "Failed to load document")

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

function widget:CommandsChanged()
	needs_update = true
end

function widget:Update()
	if not needs_update then
		clear_menu()
		return
	end

	if true then
		return
	end

	Spring.Echo("Commands Changed")
	local commands = unit_commands
	local cmd_count = #commands

	local debug_text = ""
	for _, value in pairs(commands) do
		debug_text = debug_text .. value.name .. ", "
	end
	Spring.Echo(debug_text)

	local actions = dm_handle.actions

	local function loop()
		for row = 1, MAX_ROWS do
			for column = 1, MAX_COLUMNS_PER_ROW do
				local i = ((row - 1) * MAX_COLUMNS_PER_ROW) + column
				if i > cmd_count then
					return
				end

				Spring.Echo(i .. " " .. row .. ", " .. column)

				local command = commands[i] --- @type UnitOrder
				local entry = actions[row][column]

				entry.name = command.name
				entry.visible = not (command.hidden or command.disabled)

				Spring.Echo(
					"Set entry "
						.. row
						.. ", "
						.. column
						.. " name: "
						.. command.name
						.. " visible: "
						.. tostring(entry.visible)
				)
			end
		end
	end
	loop()
	needs_update = false
end
