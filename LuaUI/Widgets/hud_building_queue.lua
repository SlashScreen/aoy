--- @module "chili/typedefs.lua"

function widget:GetInfo()
	return {
		version = "0.1",
		name = "Building Queue",
		desc = "Queue for buildings",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "GNU GPL, v2 or later",
		layer = 1,
		enabled = true,
		handler = true,
	}
end

--- @type Chili
local Chili
--- @type StackPanel
local queue_panel
--- @type Progressbar
local progress_bar

function widget:Initialize()
	Chili = WG.Chili

	if not Chili then
		Spring.Echo("Chili not found, disabling widget")
		return
	end

	Spring.Echo("Attempting to initialize queue")

	queue_panel = Chili.StackPanel:New({
		name = "BuildingQueuePanel",
		x = 10,
		y = 10,
		width = 200,
		height = 400,
		resizeItems = false,
		itemMargin = { 0, 0, 0, 0 },
	})

	progress_bar = Chili.Progressbar:New({
		name = "BuildingProgressBar",
		x = 10,
		y = 420,
		width = 200,
		height = 20,
		value = 0,
		maxValue = 100,
	})

	queue_panel:AddChild(progress_bar)
end

function widget:Shutdown()
	if queue_panel then
		queue_panel:Dispose()
		progress_bar:Dispose()
	end
end

function widget:CommandsChanged() end
