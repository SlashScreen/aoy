--- @module "Include/types"

--- @class UnitStat
--- @field stat_name string
--- @field max_value number
--- @field value number

--- @class InfoModel
--- @field unit_name string
--- @field unit_desc string
--- @field unit_stats UnitStat[]

if not RmlUi then
	Spring.Echo("No RmlUI!")
	return false
end

local widget = widget --- @type Widget

local DATA_MODEL_NAME = "info_panel_model"

function widget:GetInfo()
	return {
		name = "AOY Info Panel",
		desc = "Info Panel",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "https://unlicense.org/",
		layer = -828888,
		handler = true,
		enabled = true,
	}
end

local document --- @type RmlUi.Document
local dm_handle --- @type RmlUi.SolLuaDataModel<InfoModel>
--- @type InfoModel
local init_model = {
	unit_name = "Test",
	unit_desc = "This is a test",
	unit_stats = {
		{
			stat_name = "Health",
			max_value = 100,
			value = 50,
		},
	},
}

function widget:Initialize()
	widget.rmlContext = RmlUi.GetContext("shared")

	dm_handle = widget.rmlContext:OpenDataModel(DATA_MODEL_NAME, init_model)
	assert(dm_handle ~= nil, "RmlUi: Failed to open data model " .. DATA_MODEL_NAME)

	document = widget.rmlContext:LoadDocument("LuaUi/Widgets/hud/info_panel.rml", widget)
	assert(document ~= nil, "Failed to load document")

	RmlUi.SetDebugContext(widget.whInfo.name)
	document:ReloadStyleSheet()
	document:Show()

	Spring.Echo("Initialized Info Panel")
end

function widget:IsAbove(x, y)
	return widget.rmlContext:IsMouseInteracting()
end

function widget:GetTooltip(x, y)
	return "Info panel"
end

function widget:Shutdown()
	if document then
		document:Close()
	end

	if widget.rmlContext then
		RmlUi.RemoveContext(widget.whInfo.name)
	end
end
