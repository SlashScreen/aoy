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
local BUTTON_RIGHT_MOUSE = 2
local MAX_COLUMNS_PER_ROW = 4
local MAX_ROWS = 3

-- this can be overwritten later to change what code exampleEventHook calls
local eventCallback = function(ev, id)
	--[[ for k, v in pairs(ev.parameters) do
		Spring.Echo(k .. ": " .. v)
	end ]]
	if ev.parameters.button == BUTTON_LEFT_MOUSE then
		local index = Spring.GetCmdDescIndex(id)
		if index == nil then
			Spring.Echo("uh oh sisters")
			return
		end
		Spring.Echo("Clicked id " .. id .. " index " .. index)
		--local x = ev.parameters.mouse_x --- @type integer
		--local y = ev.parameters.mouse_y --- @type integer
		local button = ev.parameters.button --- @type integer

		Spring.SetActiveCommand(
			index,
			button,
			button == BUTTON_LEFT_MOUSE,
			button == BUTTON_RIGHT_MOUSE,
			ev.parameters.alt_key == 1,
			ev.parameters.ctrl_key == 1,
			ev.parameters.meta_key == 1,
			ev.parameters.shift_key == 1
		)
	end
end

--- @class Model
--- @field button_hook function
--- @field actions ActionButton[][]

--- @class ActionButton
--- @field name string
--- @field visible boolean
--- @field id integer

local dm_handle --- @type Model
local DATA_MODEL_NAME = "action_panel_model"
--- @type Model
local init_model = {
	button_hook = eventCallback,

	actions = {
		{
			{ name = "test 1,1", visible = true, id = 0 },
			{ name = "test 1,2", visible = true, id = 0 },
			{ name = "test 1,3", visible = true, id = 0 },
			{ name = "test 1,4", visible = false, id = 0 },
		},
		{
			{ name = "test 2,1", visible = true, id = 0 },
			{ name = "test 2,2", visible = true, id = 0 },
			{ name = "test 2,3", visible = true, id = 0 },
			{ name = "test 2,4", visible = false, id = 0 },
		},
		{
			{ name = "test 3,1", visible = true, id = 0 },
			{ name = "test 3,2", visible = true, id = 0 },
			{ name = "test 3,3", visible = true, id = 0 },
			{ name = "test 3,4", visible = false, id = 0 },
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
	for _, row in pairs(dm_handle:__GetTable().actions) do
		for _, value in pairs(row) do
			value.visible = false
		end
	end
	dm_handle:__SetDirty("actions")
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
		return
	end

	Spring.Echo("Commands Changed")

	clear_menu()

	local commands = unit_commands
	local cmd_count = #commands

	local debug_text = ""
	for _, value in pairs(commands) do
		debug_text = debug_text .. value.name .. ", "
	end
	Spring.Echo(debug_text)

	local actions = dm_handle
		:__GetTable()--[[@as Model]]
		.actions

	local function loop()
		for row = 1, MAX_ROWS do
			for column = 1, MAX_COLUMNS_PER_ROW do
				local i = ((row - 1) * MAX_COLUMNS_PER_ROW) + column
				if i > cmd_count then
					return
				end

				local command = commands[i] --- @type UnitOrder

				local debug_str = ""
				for k, v in pairs(command) do
					debug_str = debug_str .. tostring(k) .. ": " .. tostring(v) .. ", "
				end
				Spring.Echo(debug_str)

				local entry = actions[row][column]

				entry.name = command.name
				entry.visible = not (command.hidden or command.disabled)
				entry.id = command.id
			end
		end
	end
	loop()
	dm_handle:__SetDirty("actions")
	needs_update = false
end
