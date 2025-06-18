local UPDATES_PER_SECOND = 25
local GL_QUADS = GL.QUADS
local BAR_WIDTH = 80
local BAR_HEIGHT = 20
local MAX_HEALTHBARS = 512

--- @diagnostic disable-next-line
local widget = handler:NewWidget() --- @type Widget

function widget:GetInfo()
	return {
		name = "AOY Health Bars",
		desc = "Health Bars",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "https://unlicense.org/",
		layer = -828888,
		handler = true,
		enabled = true,
	}
end

local shader = gl.CreateShader({
	fragment = VFS.LoadFile("LuaUI/Widgets/Shaders/health_bar.frag.glsl"),
	vertex = VFS.LoadFile("LuaUI/Widgets/Shaders/health_bar.vert.glsl"),
})

local timer = 0.0
local visible_units = {} --- @type UnitID[]
-- TODO: Figure out how to structure this
local bars_to_draw = {} --- @type {id: UnitID, x: number, y: number, progress: number}[]
local inst_vbo = {} --- @type VBO

local GetVisibleUnits = Spring.GetVisibleUnits
local GetUnitHealth = Spring.GetUnitHealth
local GetUnitViewPosition = Spring.GetUnitViewPosition
local glVertex = gl.Vertex
local glUniform = gl.Uniform
local glBeginEnd = gl.BeginEnd

--[[
TODO:
- Progress bars
- Only when damaged or when key is pressed
]]

--#region hot loops

-- Every frame
local function draw_bars()
	local num_bars = #bars_to_draw
	gl.UseShader(shader)
	inst_vbo:DrawArrays(GL.QUADS, num_bars * 4, 0, num_bars, 0)
	gl.UseShader(0)
end

-- Every update frame (1/UPDATES_PER_SECOND)
local function update_bar_info()
	for _, bar in ipairs(bars_to_draw) do
		local id = bar.id

		local health, max_healh = GetUnitHealth(id)
		bar.progress = health / max_healh

		local x, y, _ = GetUnitViewPosition(id, true)
		if x then
			bar.x = x
			bar.y = y
		end
	end
end

--- @param unit_id UnitID
local function add_bar(unit_id)
	table.insert(bars_to_draw, {
		id = unit_id,
		x = 0,
		y = 0,
		progress = 1.0,
	})
end

local function merge_tables(t1, t2)
	for _, value in ipairs(t2) do
		table.insert(t1, value)
	end
end

local function update_all_buffers()
	local data = {}

	for _, bar in ipairs(bars_to_draw) do
		merge_tables(data, {
			bar.x,
			bar.y,

			BAR_WIDTH,
			BAR_HEIGHT,

			bar.progress,
		})
	end

	inst_vbo:Upload(data)
end

-- TODO: Too many loops.
local function process_visible_units()
	-- build set
	local visible_set = {} --- @type table<UnitID, true>

	for _, id in ipairs(visible_units) do
		table.insert(visible_set, true)
	end

	-- gather to add and remove
	local to_remove = {} --- @type integer[]
	local present_set = {} --- @type table<UnitID, true>

	for index, bar in ipairs(bars_to_draw) do -- gather remove
		if not visible_set[bar.id] then
			table.insert(to_remove, index)
		end
		present_set[bar.id] = true
	end

	for _, id in ipairs(visible_units) do -- try add
		if not present_set[id] then -- if not present then add
			add_bar(id)
		end
	end

	-- remove in reverse to prevent ordering issues
	for i = #to_remove, 1, -1 do
		table.remove(bars_to_draw, i)
	end

	update_all_buffers()
end

--#endregion bar management
--#region widget

function widget:Initialize()
	local vbo = gl.GetVBO(GL.ARRAY_BUFFER, true)
	if vbo == nil then
		return
	end
	vbo:Define(MAX_HEALTHBARS, {
		{ id = 0, name = "pos", size = 2, type = GL.INT },
		{ id = 1, name = "width", size = 1, type = GL.UNSIGNED_INT },
		{ id = 2, name = "height", size = 1, type = GL.UNSIGNED_INT },
		{ id = 3, name = "progress", size = 1 },
	})
	inst_vbo = vbo
end

function widget:Update(dt)
	timer = timer + (dt or (1 / 20))
	if timer > 1 / UPDATES_PER_SECOND then
		timer = 0.0
		visible_units = GetVisibleUnits(-1, nil, false) --- @diagnostic disable-line

		process_visible_units()

		update_bar_info()
	end
end

function widget:DrawWorld()
	-- TODO: Push and pop whatever
	draw_bars()
end

function widget:Shutdown()
	gl.DeleteShader(shader)
end

--#endregion

return widget
