-- *types

--- @module "Include/types"

--- @class Model
--- @field button_hook function
--- @field actions ActionButton[][]

--- @class ActionButton
--- @field name string
--- @field visible boolean
--- @field id integer
--- @field disabled boolean

-- *heading

if not RmlUi then
	Spring.Echo("No RmlUI!")
	return false
end
widget.rmlContext = nil

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

-- *constants

local BUTTON_LEFT_MOUSE = 0
local BUTTON_RIGHT_MOUSE = 2
local MAX_COLUMNS_PER_ROW = 6
local MAX_ROWS = 5
local CUT_OUT_HIDDEN = true

-- *members

local document
local needs_update = false
local unit_commands --- @type UnitOrder[]
local dm_handle --- @type DatamodelHandle<Model>
local DATA_MODEL_NAME = "action_panel_model"
local init_model = { --- @type Model
	---@param ev RmlEvent
	---@param id CommandID
	---@param disabled boolean
	button_hook = function(ev, id, disabled)
		if disabled then
			return
		end

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
	end,
	actions = {},
}

-- *setup

-- populate actions table programmatically
for _r = 1, MAX_ROWS do
	local row = {} --- @type ActionButton[]
	for _i = 1, MAX_COLUMNS_PER_ROW do
		local item = { name = "placefolder", visible = true, id = 0, disabled = false }
		table.insert(row, item)
	end
	table.insert(init_model.actions, row)
end

-- *local functions

local function override_default_menu()
	local function layoutHandler(xIcons, yIcons, cmdCount, commands)
		unit_commands = commands

		widgetHandler:CommandsChanged()

		return "", xIcons, yIcons, {}, {}, {}, {}, {}, {}, {}, { [1337] = 9001 }
	end

	widgetHandler:ConfigLayoutHandler(layoutHandler)
end

local function clear_menu()
	for _, row in pairs(dm_handle:__GetTable().actions) do
		for _, value in pairs(row) do
			value.visible = false
		end
	end
	dm_handle:__SetDirty("actions")
	Spring.Echo("menu cleared")
end

---rerender current commands
local function rerender()
	clear_menu()

	-- Gather visible commands
	local commands = {} --- @type UnitOrder[]
	for _, command in ipairs(unit_commands) do
		if
			(CUT_OUT_HIDDEN and not (command.name == "" or command.hidden))
			or ((not CUT_OUT_HIDDEN) and (not command.name == ""))
		then
			table.insert(commands, command)
		end
	end
	local cmd_count = #commands

	--- Renders the buttons
	local function loop()
		local actions = dm_handle:__GetTable().actions

		for row = 1, MAX_ROWS do
			for column = 1, MAX_COLUMNS_PER_ROW do
				local i = ((row - 1) * MAX_COLUMNS_PER_ROW) + column
				if i > cmd_count then
					return
				end

				local command = commands[i]

				local entry = actions[row][column]

				entry.name = command.name
				entry.visible = not command.hidden
				entry.disabled = command.disabled
				entry.id = command.id
			end
		end
	end

	loop()

	dm_handle:__SetDirty("actions")
end

-- *widget override

function widget:Initialize()
	widget.rmlContext = RmlUi.CreateContext(widget.whInfo.name)

	dm_handle = widget.rmlContext:OpenDataModel(DATA_MODEL_NAME, init_model)
	assert(dm_handle ~= nil, "RmlUi: Failed to open data model " .. DATA_MODEL_NAME)

	document = widget.rmlContext:LoadDocument("LuaUi/Widgets/hud/action_panel.rml", widget)
	assert(document ~= nil, "Failed to load document")

	override_default_menu()

	RmlUi.SetDebugContext(widget.whInfo.name)
	document:ReloadStyleSheet()
	document:Show()
end

function widget:CommandsChanged()
	needs_update = true
end

function widget:Update()
	if not needs_update then
		return
	end
	rerender()
	needs_update = false
end

function widget:Shutdown()
	if document then
		document:Close()
	end

	if widget.rmlContext then
		RmlUi.RemoveContext(widget.whInfo.name)
	end
end
