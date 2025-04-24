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
local MAX_COLUMNS_PER_ROW = 3

-- this can be overwritten later to change what code exampleEventHook calls
local eventCallback = function(ev, row, column)
	if ev.parameters.button == BUTTON_LEFT_MOUSE then
		Spring.Echo("Clicked row " .. row .. " column " .. column)
	end
end

local dm_handle
local init_model = {
	button_hook = eventCallback,

	actions = {
		{
			{ name = "test 1,1", row = 1, column = 1, visible = true },
			{ name = "test 1,2", row = 1, column = 2, visible = true },
			{ name = "test 1,3", row = 1, column = 3, visible = true },
		},
		{
			{ name = "test 2,1", row = 2, column = 1, visible = true },
			{ name = "test 2,2", row = 2, column = 2, visible = true },
			{ name = "test 2,3", row = 2, column = 3, visible = true },
		},
		{
			{ name = "test 3,1", row = 3, column = 1, visible = true },
			{ name = "test 3,2", row = 3, column = 2, visible = true },
			{ name = "test 3,3", row = 3, column = 3, visible = false },
		},
	},
}

function widget:Initialize()
	Spring.Echo("Initializing RmlUI thing")
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
