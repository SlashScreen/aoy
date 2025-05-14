-- *types

--- @module "Include/types"

--- @class Model
--- @field button_hook function
--- @field update_tooltip function
--- @field actions ActionButton[][]

--- @class ActionButton
--- @field name string
--- @field visible boolean
--- @field id integer
--- @field disabled boolean
--- @field state -1|integer if -1, no states. 0 index
--- @field state_names string[]
--- @field img string
--- @field only_img boolean
--- @field tooltip string

-- *heading

local widget = widget --- @type Widget

if not RmlUi then
	Spring.Echo("No RmlUI!")
	return false
end
widget.rmlContext = nil --- @type RmlContext

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
local BUTTON_RIGHT_MOUSE = 1

local MAX_COLUMNS_PER_ROW = 6
local MAX_ROWS = 5

local CUT_OUT_HIDDEN = true

local NO_STATE = -1
local DEFAULT_TOOLTIP = "Action menu"

-- *members

local document
local needs_update = false
local unit_commands                     --- @type CommandDescription[]
local dm_handle                         --- @type RmlDatamodelHandle<Model>
local current_tooltip = DEFAULT_TOOLTIP --- @type string?
local DATA_MODEL_NAME = "action_panel_model"
local init_model = {                    --- @type Model
	---@param ev RmlEvent
	---@param id CommandID
	---@param disabled boolean
	button_hook = function(ev, id, disabled)
		if disabled then
			return
		end

		local index = Spring.GetCmdDescIndex(id)
		if index == nil then
			Spring.Echo("uh oh sisters")
			return
		end

		local button = ev.parameters.button --- @type integer

		Spring.SetActiveCommand(
			index,
			button + 1, -- +1 for spring button codes
			button == BUTTON_LEFT_MOUSE,
			button == BUTTON_RIGHT_MOUSE,
			ev.parameters.alt_key == 1,
			ev.parameters.ctrl_key == 1,
			ev.parameters.meta_key == 1,
			ev.parameters.shift_key == 1
		)
	end,
	update_tooltip = function(ev, text)
		if #text == 0 then
			current_tooltip = nil
			return
		end
		current_tooltip = text
	end,
	actions = {},
}

-- *setup

-- populate actions table programmatically
for r = 1, MAX_ROWS do
	local row = {} --- @type ActionButton[]
	for i = 1, MAX_COLUMNS_PER_ROW do
		--- @type ActionButton
		local item = {
			name = "placeholder",
			visible = true,
			id = -1,
			disabled = false,
			state = NO_STATE,
			state_names = {},
			img = "",
			only_img = false,
			tooltip = r .. ", " .. i,
		}
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

---@param command CommandDescription
---@return boolean ok
---@return integer state 0-indexed
---@return string[] names
local function param_info(command)
	if #command.params < 2 or command.type ~= CMDTYPE.ICON_MODE then
		return false, NO_STATE, {}
	end

	local names = {}
	for i = 2, #command.params do
		table.insert(names, command.params[i])
	end

	local state = command.params[1] --[[@as integer]]
	return true, state, names
end

---@param command CommandDescription
---@return boolean
local function should_be_rendered(command)
	if CUT_OUT_HIDDEN then
		if command.hidden then
			return false
		end
	end

	if #command.name == 0 and not command.onlyTexture then
		return false
	end

	return true
end

---rerender current commands
local function rerender()
	clear_menu()

	-- Gather visible commands
	local commands = {} --- @type CommandDescription[]
	for _, command in ipairs(unit_commands) do
		if should_be_rendered(command) then
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

				local ok, state, state_names = param_info(command)
				if ok then
					entry.state = state
					entry.state_names = state_names
				else
					entry.state = NO_STATE
					entry.state_names = {}
				end

				if command.texture and #command.texture ~= 0 then
					entry.img = "/unitpics/" .. command.texture
				else
					entry.img = ""
				end

				entry.only_img = command.onlyTexture
				entry.tooltip = command.tooltip
			end
		end
	end

	loop()

	dm_handle:__SetDirty("actions")
end

-- *widget override

function widget:Initialize()
	widget.rmlContext = RmlUi.GetContext("shared") --[[@as RmlContext]]

	dm_handle = widget.rmlContext:OpenDataModel(DATA_MODEL_NAME, init_model)
	assert(dm_handle ~= nil, "RmlUi: Failed to open data model " .. DATA_MODEL_NAME)

	document = widget.rmlContext:LoadDocument("LuaUi/Widgets/hud/action_panel.rml", widget)
	assert(document ~= nil, "Failed to load document")

	override_default_menu()

	RmlUi.SetDebugContext(widget.whInfo.name)
	document:ReloadStyleSheet()
	document:Show()

	Spring.Echo("Initialized Action Panel")
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

function widget:IsAbove(x, y)
	return widget.rmlContext:IsMouseInteracting()
end

function widget:GetTooltip(x, y)
	return current_tooltip or DEFAULT_TOOLTIP
end

function widget:Shutdown()
	if document then
		document:Close()
	end

	if widget.rmlContext then
		RmlUi.RemoveContext(widget.whInfo.name)
	end
end
