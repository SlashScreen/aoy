if not RmlUi then
	Spring.Echo("No RmlUI!")
	return false
end

local widget = widget --- @type Widget

local DATA_MODEL_NAME = "minimap_model"

function widget:GetInfo()
	return {
		name = "RML Minimap Panel",
		desc = "Minimap Panel",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "https://unlicense.org/",
		layer = -828888,
		handler = true,
		enabled = true,
	}
end

local init_model = {}

function widget:Initialize()
	widget.rmlContext = RmlUi.GetContext("shared") --[[@as RmlContext]]

	dm_handle = widget.rmlContext:OpenDataModel(DATA_MODEL_NAME, init_model)
	assert(dm_handle ~= nil, "RmlUi: Failed to open data model " .. DATA_MODEL_NAME)

	document = widget.rmlContext:LoadDocument("LuaUi/Widgets/hud/minimap_panel.rml", widget)
	assert(document ~= nil, "Failed to load document")

	RmlUi.SetDebugContext(widget.whInfo.name)
	document:ReloadStyleSheet()
	document:Show()

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
