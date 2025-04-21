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
--- @type Window
local root_window
--- @type LayoutPanel
local root_panel
--- @type Progressbar
local progress_bar
--- @type Label
local test_label

function widget:Initialize()
	Chili = WG.Chili

	if not Chili then
		Spring.Echo("Chili not found, disabling widget")
		return
	end

	root_window = Chili.Window:New({
		name = "RootWindow",
		parent = Chili.Screen0,
	})

	root_panel = Chili.LayoutPanel:New({
		name = "RootPanel",
		x = 10,
		y = 10,
	})
	root_window:AddChild(root_panel)

	progress_bar = Chili.Progressbar:New({
		name = "BuildingProgressBar",
		x = 0,
		y = 15,
		width = 200,
		height = 20,
		value = 0,
		maxValue = 100,
	})
	root_panel:AddChild(progress_bar)

	test_label = Chili.Label:New({
		name = "TestLabel",
		caption = "wheeee!",
		y = 40,
		height = 20,
	})
	root_panel:AddChild(test_label)

	root_window:Show()
end

function widget:Shutdown()
	if root_window then
		progress_bar:Dispose()
		test_label:Dispose()
		root_panel:Dispose()
		root_window:Dispose()
	end
end

function widget:CommandsChanged() end
