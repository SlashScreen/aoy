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

local Chili --- @type Chili
local root_window --- @type Window
local root_panel --- @type LayoutPanel
local progress_bar --- @type Progressbar
local test_label --- @type Label

--- @package
--- @alias JobInfo {active: boolean, label_handle: Label}

local MAX_JOBS = 5 --- @type integer
local jobs = {} --- @type JobInfo[]
local is_factory = {} --- @type table<UnitDefID, boolean>

for def_id, def in pairs(UnitDefs) do
	if def.customParams.is_factory then
		is_factory[def_id] = true
	end
end

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

	root_panel = Chili.Control:New({
		name = "RootPanel",
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
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
		parent = root_panel,
	})

	test_label = Chili.Label:New({
		name = "TestLabel",
		caption = "wheeee!",
		y = 40,
		height = 20,
		parent = root_panel,
	})

	for i = 1, MAX_JOBS, 1 do
		local info = { active = false } --- @type JobInfo
		info.label_handle = Chili.Label:New({
			name = "JobLabel" .. i,
			caption = "job",
			y = 40 + (i * 25),
			height = 20,
			parent = root_panel,
		})
		jobs[i] = info
	end

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

local function rerender_jobs()
	for _, value in ipairs(jobs) do
		value.label_handle:SetCaption("Job active:" .. tostring(value.active))
	end
end

function widget:CommandsChanged()
	Spring.Echo("Commands changed")
	local selected_units = Spring.GetSelectedUnits() --- @type UnitID[]
	if #selected_units == 0 then
		return
	end

	local selected_unit = selected_units[1] --- @type UnitID
	local selected_unit_def_id = Spring.GetUnitDefID(selected_unit)
	if is_factory[selected_unit_def_id] then
		Spring.Echo("Selected factory")
		rerender_jobs()
	end
end
