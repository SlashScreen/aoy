local UPDATES_PER_SECOND = 25
local GL_TRIANGLES = GL.TRIANGLES
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

local shader = nil --- @type integer?

local timer = 0.0
local visible_units = {} --- @type UnitID[]
-- TODO: Figure out how to structure this
local bars_to_draw = {} --- @type {id: UnitID, x: number, y: number, z:number, progress: number}[]
local inst_vao --- @type VAO
local inst_vbo --- @type VBO

local GetVisibleUnits = Spring.GetVisibleUnits
local GetUnitHealth = Spring.GetUnitHealth
local GetUnitPosition = Spring.GetUnitPosition
local glUseShader = gl.UseShader
local glUniformMatrix = gl.UniformMatrix
local table_insert = table.insert
local table_remove = table.remove

--[[
TODO:
- Progress bars
- Only when damaged or when key is pressed
]]

--- @param tbl table
--- @param indent integer?
--- @return string
function DumpTable(tbl, indent)
	indent = indent or 0
	local result = ""
	local prefix = string.rep("  ", indent)
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			result = result .. prefix .. tostring(k) .. ":\n" .. DumpTable(v, indent + 1)
		else
			result = result .. prefix .. tostring(k) .. ": " .. tostring(v) .. "\n"
		end
	end
	return result
end

--#region hot loops

-- Every frame
local function draw_bars()
	local num_bars = #bars_to_draw
	if num_bars == 0 then
		return
	end

	local size_x, size_y = Spring.GetScreenGeometry(0)
	gl.UniformInt("screenDimensions", size_x, size_y)

	gl.Uniform("frontColor", 0.0, 1.0, 0.0)
	gl.Uniform("backColor", 0.1, 0.1, 0.1)

	if shader == nil then
		Spring.Echo("Bar shader nil")
		return
	end
	if not glUseShader(shader) then
		Spring.Echo("Failed to bind health bar shader")
		return
	end
	inst_vao:DrawArrays(GL_TRIANGLES, 6, 0, num_bars, 0)

	--[[ local mouseX, mouseY = Spring.GetMouseState()
	Spring.Echo("Mouse coordinates: (" .. mouseX .. ", " .. mouseY .. ")")
	local desc, args = Spring.TraceScreenRay(mouseX, mouseY, true)
	if desc ~= nil and args ~= nil then
		local x = args[1]
		local y = args[2]
		local z = args[3]
		Spring.Echo("World coordinates: (" .. x .. ", " .. y .. ", " .. z .. ")")
	end --]]

	--Spring.Echo("Dump table: ", DumpTable(inst_vbo:Download()))

	glUseShader(0)
end

-- Every update frame (1/UPDATES_PER_SECOND)
local function update_bar_info()
	for _, bar in ipairs(bars_to_draw) do
		local id = bar.id

		local health, max_healh = GetUnitHealth(id)
		bar.progress = health / max_healh

		local mouseX, mouseY = Spring.GetMouseState()
		Spring.Echo("Mouse coordinates: (" .. mouseX .. ", " .. mouseY .. ")")
		local desc, args = Spring.TraceScreenRay(mouseX, mouseY, true)
		if desc ~= nil and args ~= nil then
			local x = args[1]
			local y = args[2]
			local z = args[3]
			Spring.Echo("World coordinates: (" .. x .. ", " .. y .. ", " .. z .. ")")
			bar.x = x
			bar.y = y
			bar.z = z
		end -- off map

		--[[ local x, y, z = GetUnitPosition(id)
		if x then
			bar.x = x
			bar.y = y
			bar.z = z
		end ]]
	end
end

--- @param unit_id UnitID
local function add_bar(unit_id)
	table_insert(bars_to_draw, {
		id = unit_id,
		x = 0,
		y = 0,
		z = 0,
		progress = 1.0,
	})
end

local function merge_tables(t1, t2)
	for i = 1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
	return t1
end

--- @param o table
local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local function update_all_buffers()
	local data = {} --- @type number[]

	if #bars_to_draw == 0 then
		return
	end

	for _, bar in ipairs(bars_to_draw) do
		merge_tables(data, {
			bar.x,
			bar.y,
			bar.z,
			bar.progress,

			BAR_WIDTH,
			BAR_HEIGHT,
		})
	end

	Spring.Echo("Data: " .. dump(data))

	inst_vbo:Upload(data)
end

-- TODO: Too many loops.
local function process_visible_units()
	-- build set
	local visible_set = {} --- @type table<UnitID, true>

	for _, id in ipairs(visible_units) do
		visible_set[id] = true
	end

	-- gather to add and remove
	local to_remove = {} --- @type integer[]
	local present_set = {} --- @type table<UnitID, true>

	for index, bar in ipairs(bars_to_draw) do -- gather remove
		if not visible_set[bar.id] then
			table_insert(to_remove, index)
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
		table_remove(bars_to_draw, i)
	end

	update_all_buffers()
end

--#endregion bar management
--#region widget

function widget:Initialize()
	shader = gl.CreateShader({
		fragment = VFS.LoadFile("LuaUI/Widgets/Shaders/health_bar.frag.glsl"),
		vertex = VFS.LoadFile("LuaUI/Widgets/Shaders/health_bar.vert.glsl"),
	})
	Spring.Echo("Bar shader initialized to " .. tostring(shader))
	if shader == nil then
		local log = gl.GetShaderLog()
		Spring.Echo("Shader log: \n" .. log)
		if #log == 0 then
			Spring.Echo("Looks like shader linking failed. Make sure your in and out blocks match.")
		end
	end

	local vao = gl.GetVAO()
	if vao == nil then
		Spring.Echo("Failed to initialize Bar VAO")
		return
	end
	inst_vao = vao

	local vbo = gl.GetVBO(GL.ARRAY_BUFFER, true)
	if vbo == nil then
		Spring.Echo("Failed to initialize Bar VBO")
		return
	end
	vbo:Define(MAX_HEALTHBARS, {
		{ id = 0, name = "posAndProgress" }, -- vec4
		{ id = 1, name = "dimensions", size = 2, type = GL.UNSIGNED_INT },
	})
	inst_vbo = vbo

	inst_vao:AttachInstanceBuffer(inst_vbo)
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
	draw_bars()
end

function widget:Shutdown()
	gl.DeleteShader(shader)
	inst_vao:Delete() -- good practice, will be GCed otherwise in some time
	inst_vbo:Delete() -- good practice, will be GCed otherwise in some time
end

--#endregion

return widget
