if not RmlUi then
	Spring.Echo("No RmlUI!")
	return false
end

local widget = widget --- @type Widget

local DATA_MODEL_NAME = "minimap_model"
local MINIMAP_ELEMENT_ID = "map-panel"

function widget:GetInfo()
	return {
		name = "AOY Minimap Panel",
		desc = "Minimap Panel",
		author = "Slashscreen",
		date = "Present Day, Present Time",
		license = "https://unlicense.org/",
		layer = -828888,
		handler = true,
		enabled = true,
	}
end

local document --- @type RmlUi.Document
local dm_handle --- @type RmlUi.SolLuaDataModel<table>
local init_model = {}

--- @param x integer
--- @param y integer
--- @param width integer
--- @param height integer
local function set_minimap_geo(x, y, width, height)
	--[[Spring.SendCommands(
		"minimap geo " .. tostring(x) .. " " .. tostring(y) .. " " .. tostring(width) .. " " .. tostring(height)
	)]]
	gl.ConfigMiniMap(x, y, width, height)
end

--- @param element RmlUi.Element
local function match_minimap_to_element(element)
	local x_offset = (element.client_width - element.client_height) / 2 -- Used to keep it centered
	set_minimap_geo(
		element.absolute_left + x_offset,
		document.client_height - element.absolute_top - element.client_height,
		element.client_height,
		element.client_height
	)
end

function widget:Initialize()
	--- @type RmlUi.Context
	widget.rmlContext = RmlUi.GetContext("shared") or error("failed to get context")

	dm_handle = widget.rmlContext:OpenDataModel(DATA_MODEL_NAME, init_model)
	assert(dm_handle ~= nil, "RmlUi: Failed to open data model " .. DATA_MODEL_NAME)

	document = widget.rmlContext:LoadDocument("LuaUi/Widgets/hud/minimap_panel.rml", widget) --[[@as RmlUi.Document]]
	assert(document ~= nil, "Failed to load document")

	--RmlUi.SetDebugContext(widget.whInfo.name)
	document:ReloadStyleSheet()
	document:Show()

	--gl.SetSlaveMode(true)
	gl.SlaveMiniMap(true)

	local minimap_element = document:GetElementById(MINIMAP_ELEMENT_ID)
	match_minimap_to_element(minimap_element)
	Spring.SetConfigInt("HardwareCursor", 1)

	--gl.DrawMiniMap()

	Spring.Echo("Initialized Minimap")
end

function widget:DrawScreenPost()
	--Spring.Echo("Draw post " .. os.clock())
	gl.DrawMiniMap()
end

function widget:Shutdown()
	if document then
		document:Close()
	end

	if widget.rmlContext then
		RmlUi.RemoveContext(widget.whInfo.name)
	end
end
