if not RmlUi then
	Spring.Echo("No RmlUI!")
	return false
end

local widget = widget --- @type Widget

local DATA_MODEL_NAME = "minimap_model"
local MINIMAP_ELEMENT_ID = "widget"

function widget:GetInfo()
	return {
		name = "AOY Minimap Panel",
		desc = "Minimap Panel",
		author = "Vileblood",
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
	Spring.SendCommands(
		"minimap geo " .. tostring(x) .. " " .. tostring(y) .. " " .. tostring(width) .. " " .. tostring(height)
	)
	--gl.ConfigMiniMap(x, y, width, height)
end

--- @param element RmlUi.Element
local function match_minimap_to_element(element)
	set_minimap_geo(element.absolute_left, element.absolute_top, element.client_width, element.client_height)
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

	local minimap_element = document:GetElementById(MINIMAP_ELEMENT_ID)
	match_minimap_to_element(minimap_element)

	--gl.DrawMiniMap()

	Spring.Echo("Initialized Minimap")
end

function widget:IsAbove(x, y)
	return widget.rmlContext:IsMouseInteracting()
end

function widget:GetTooltip(x, y)
	return "Minimap"
end

function widget:Shutdown()
	if document then
		document:Close()
	end

	if widget.rmlContext then
		RmlUi.RemoveContext(widget.whInfo.name)
	end
end
