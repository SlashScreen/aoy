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
local Chili = WG.Chili
--- @type StackPanel
local queue_panel
--- @type Progressbar
local progress_bar

function widget:Initialize() end

function widget:Shutdown() end
