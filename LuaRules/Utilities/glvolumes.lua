--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--- GL Volume Drawing Utilities
--- Provides functions for drawing 3D volumes and shapes using OpenGL
--- @module gl.Utilities

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Exported Functions:
--  gl.Utilities.DrawMyBox(minX,minY,minZ, maxX,maxY,maxZ)
--  gl.Utilities.DrawMyCylinder(x,y,z, height,radius,divs)
--  gl.Utilities.DrawMyHollowCylinder(x,y,z, height,radius,innerRadius,divs)
--  gl.Utilities.DrawGroundRectangle(x1,z1,x2,z2)
--  gl.Utilities.DrawGroundCircle(x,z,radius)
--  gl.Utilities.DrawGroundHollowCircle(x,z,radius,innerRadius)
--  gl.Utilities.DrawVolume(vol_dlist)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if not gl then
	return
end

gl.Utilities = gl.Utilities or {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local min = math.min
local max = math.max
local sin = math.sin
local cos = math.cos
local floor = math.floor
local TWO_PI = math.pi * 2

local glVertex = gl.Vertex

GL.KEEP = 0x1E00
GL.INCR_WRAP = 0x8507
GL.DECR_WRAP = 0x8508
GL.INCR = 0x1E02
GL.DECR = 0x1E03
GL.INVERT = 0x150A

local stencilBit1 = 0x01
local stencilBit2 = 0x10

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- Draws a 3D box using quads
--- @param minX number Minimum X coordinate
--- @param minY number Minimum Y coordinate
--- @param minZ number Minimum Z coordinate
--- @param maxX number Maximum X coordinate
--- @param maxY number Maximum Y coordinate
--- @param maxZ number Maximum Z coordinate
function gl.Utilities.DrawMyBox(minX, minY, minZ, maxX, maxY, maxZ)
	gl.BeginEnd(GL.QUADS, function()
		--// top
		glVertex(minX, maxY, minZ)
		glVertex(minX, maxY, maxZ)
		glVertex(maxX, maxY, maxZ)
		glVertex(maxX, maxY, minZ)
		--// bottom
		glVertex(minX, minY, minZ)
		glVertex(maxX, minY, minZ)
		glVertex(maxX, minY, maxZ)
		glVertex(minX, minY, maxZ)
	end)
	gl.BeginEnd(GL.QUAD_STRIP, function()
		--// sides
		glVertex(minX, maxY, minZ)
		glVertex(minX, minY, minZ)
		glVertex(minX, maxY, maxZ)
		glVertex(minX, minY, maxZ)
		glVertex(maxX, maxY, maxZ)
		glVertex(maxX, minY, maxZ)
		glVertex(maxX, maxY, minZ)
		glVertex(maxX, minY, minZ)
		glVertex(minX, maxY, minZ)
		glVertex(minX, minY, minZ)
	end)
end

--- Draws a 3D triangle with sides
--- @param x1 number First vertex X coordinate
--- @param z1 number First vertex Z coordinate
--- @param x2 number Second vertex X coordinate
--- @param z2 number Second vertex Z coordinate
--- @param x3 number Third vertex X coordinate
--- @param z3 number Third vertex Z coordinate
--- @param minY number Minimum Y coordinate for height
--- @param maxY number Maximum Y coordinate for height
function gl.Utilities.DrawMy3DTriangle(x1, z1, x2, z2, x3, z3, minY, maxY)
	gl.BeginEnd(GL.TRIANGLES, function()
		--// top
		glVertex(x1, maxY, z1)
		glVertex(x2, maxY, z2)
		glVertex(x3, maxY, z3)
		--// bottom
		glVertex(x1, minY, z1)
		glVertex(x3, minY, z3)
		glVertex(x2, minY, z2)
	end)
	gl.BeginEnd(GL.QUAD_STRIP, function()
		--// sides
		glVertex(x1, maxY, z1)
		glVertex(x1, minY, z1)
		glVertex(x2, maxY, z2)
		glVertex(x2, minY, z2)
		glVertex(x3, maxY, z3)
		glVertex(x3, minY, z3)
		glVertex(x1, maxY, z1)
		glVertex(x1, minY, z1)
	end)
end

--- Creates lookup tables for sin/cos values
--- @param divs number Number of divisions for the circle
--- @return table sinTable Table of sine values
--- @return table cosTable Table of cosine values
local function CreateSinCosTable(divs)
	local sinTable = {}
	local cosTable = {}

	local divAngle = TWO_PI / divs
	local alpha = 0
	local i = 1
	repeat
		sinTable[i] = sin(alpha)
		cosTable[i] = cos(alpha)

		alpha = alpha + divAngle
		i = i + 1
	until alpha >= TWO_PI
	sinTable[i] = 0.0 -- sin(TWO_PI)
	cosTable[i] = 1.0 -- cos(TWO_PI)

	return sinTable, cosTable
end

--- Draws a cylinder
--- @param x number Center X coordinate
--- @param y number Center Y coordinate
--- @param z number Center Z coordinate
--- @param height number Height of the cylinder
--- @param radius number Radius of the cylinder
--- @param divs number? Optional number of divisions (default 25)
function gl.Utilities.DrawMyCylinder(x, y, z, height, radius, divs)
	divs = divs or 25
	local sinTable, cosTable = CreateSinCosTable(divs)
	local bottomY = y - (height / 2)
	local topY = y + (height / 2)

	gl.BeginEnd(GL.TRIANGLE_STRIP, function()
		--// top
		for i = #sinTable, 1, -1 do
			glVertex(x + radius * sinTable[i], topY, z + radius * cosTable[i])
			glVertex(x, topY, z)
		end

		--// degenerate
		glVertex(x, topY, z)
		glVertex(x, bottomY, z)
		glVertex(x, bottomY, z)

		--// bottom
		for i = #sinTable, 1, -1 do
			glVertex(x + radius * sinTable[i], bottomY, z + radius * cosTable[i])
			glVertex(x, bottomY, z)
		end

		--// degenerate
		glVertex(x, bottomY, z)
		glVertex(x, bottomY, z + radius)
		glVertex(x, bottomY, z + radius)

		--// sides
		for i = 1, #sinTable do
			local rx = x + radius * sinTable[i]
			local rz = z + radius * cosTable[i]
			glVertex(rx, topY, rz)
			glVertex(rx, bottomY, rz)
		end
	end)
end

--- Draws a circle in 2D
--- @param x number Center X coordinate
--- @param y number Center Y coordinate
--- @param radius number Radius of the circle
--- @param divs number? Optional number of divisions (default 25)
function gl.Utilities.DrawMyCircle(x, y, radius, divs)
	divs = divs or 25
	local sinTable, cosTable = CreateSinCosTable(divs)

	gl.BeginEnd(GL.LINE_LOOP, function()
		for i = #sinTable, 1, -1 do
			glVertex(x + radius * sinTable[i], y + radius * cosTable[i], 0)
		end
	end)
end

--- Draws a hollow cylinder with inner and outer radius
--- @param x number Center X coordinate
--- @param y number Center Y coordinate
--- @param z number Center Z coordinate
--- @param height number Height of the cylinder
--- @param radius number Outer radius
--- @param inRadius number Inner radius (when < 1 treated as relative to radius, when >= 1 treated as absolute)
--- @param divs number? Optional number of divisions (default 25)
function gl.Utilities.DrawMyHollowCylinder(x, y, z, height, radius, inRadius, divs)
	divs = divs or 25
	local sinTable, cosTable = CreateSinCosTable(divs)
	local bottomY = y - (height / 2)
	local topY = y + (height / 2)

	gl.BeginEnd(GL.TRIANGLE_STRIP, function()
		--// top
		for i = 1, #sinTable do
			local sa = sinTable[i]
			local ca = cosTable[i]
			glVertex(x + inRadius * sa, topY, z + inRadius * ca)
			glVertex(x + radius * sa, topY, z + radius * ca)
		end

		--// sides
		for i = 1, #sinTable do
			local rx = x + radius * sinTable[i]
			local rz = z + radius * cosTable[i]
			glVertex(rx, topY, rz)
			glVertex(rx, bottomY, rz)
		end

		--// bottom
		for i = 1, #sinTable do
			local sa = sinTable[i]
			local ca = cosTable[i]
			glVertex(x + radius * sa, bottomY, z + radius * ca)
			glVertex(x + inRadius * sa, bottomY, z + inRadius * ca)
		end

		if inRadius > 0 then
			--// inner sides
			for i = 1, #sinTable do
				local rx = x + inRadius * sinTable[i]
				local rz = z + inRadius * cosTable[i]
				glVertex(rx, bottomY, rz)
				glVertex(rx, topY, rz)
			end
		end
	end)
end

local heightMargin = 2000
local minheight, maxheight = Spring.GetGroundExtremes() --the returned values do not change even if we terraform the map
local averageGroundHeight = (minheight + maxheight) / 2
local shapeHeight = heightMargin + (maxheight - minheight) + heightMargin

local box = gl.CreateList(gl.Utilities.DrawMyBox, 0, -0.5, 0, 1, 0.5, 1)
--- Draws a rectangle on the ground plane
--- @param x1 number|table First X coordinate or table with {x1,z1,x2,z2}
--- @param z1 number First Z coordinate (if not using table)
--- @param x2 number Second X coordinate (if not using table)
--- @param z2 number Second Z coordinate (if not using table)
function gl.Utilities.DrawGroundRectangle(x1, z1, x2, z2)
	if type(x1) == "table" then
		local rect = x1
		x1, z1, x2, z2 = rect[1], rect[2], rect[3], rect[4]
	end
	gl.PushMatrix()
	gl.Translate(x1, averageGroundHeight, z1)
	gl.Scale(x2 - x1, shapeHeight, z2 - z1)
	gl.Utilities.DrawVolume(box)
	gl.PopMatrix()
end

local triangles = {}
function gl.Utilities.DrawGroundTriangle(args)
	if not triangles[args] then
		triangles[args] = gl.CreateList(
			gl.Utilities.DrawMy3DTriangle,
			args[1],
			args[2],
			args[3],
			args[4],
			args[5],
			args[6],
			-0.5,
			0.5
		)
	end
	gl.PushMatrix()
	gl.Translate(0, averageGroundHeight, 0)
	gl.Scale(1, shapeHeight, 1)
	gl.Utilities.DrawVolume(triangles[args])
	gl.PopMatrix()
end

local cylinder = gl.CreateList(gl.Utilities.DrawMyCylinder, 0, 0, 0, 1, 1, 35)
--- Draws a circle on the ground plane
--- @param x number Center X coordinate
--- @param z number Center Z coordinate
--- @param radius number Radius of the circle
function gl.Utilities.DrawGroundCircle(x, z, radius)
	gl.PushMatrix()
	gl.Translate(x, averageGroundHeight, z)
	gl.Scale(radius, shapeHeight, radius)
	gl.Utilities.DrawVolume(cylinder)
	gl.PopMatrix()
end

local circle = gl.CreateList(gl.Utilities.DrawMyCircle, 0, 0, 1, 35)
function gl.Utilities.DrawCircle(x, y, radius)
	gl.PushMatrix()
	gl.Translate(x, y, 0)
	gl.Scale(radius, radius, 1)
	gl.Utilities.DrawVolume(circle)
	gl.PopMatrix()
end

-- See comment in DrawMergedVolume
--- Draws a merged circle on the ground plane that works with stencil buffer
--- @param x number Center X coordinate
--- @param z number Center Z coordinate
--- @param radius number Radius of the circle
function gl.Utilities.DrawMergedGroundCircle(x, z, radius)
	gl.PushMatrix()
	gl.Translate(x, averageGroundHeight, z)
	gl.Scale(radius, shapeHeight, radius)
	gl.Utilities.DrawMergedVolume(cylinder)
	gl.PopMatrix()
end

local hollowCylinders = {
	[0] = cylinder,
}
local function GetHollowCylinder(radius, innerRadius)
	if innerRadius >= 1 then
		innerRadius = min(innerRadius / radius, 1.0)
	end
	innerRadius = floor(innerRadius * 100 + 0.5) / 100

	if not hollowCylinders[innerRadius] then
		hollowCylinders[innerRadius] = gl.CreateList(gl.Utilities.DrawMyHollowCylinder, 0, 0, 0, 1, 1, innerRadius, 35)
	end
	return hollowCylinders[innerRadius]
end

--// when innerRadius is < 1, its value is treated as relative to radius
--// when innerRadius is >=1, its value is treated as absolute value in elmos
--- Draws a hollow circle on the ground plane
--- @param x number Center X coordinate
--- @param z number Center Z coordinate
--- @param radius number Outer radius
--- @param innerRadius number Inner radius (when < 1 treated as relative to radius, when >= 1 treated as absolute)
function gl.Utilities.DrawGroundHollowCircle(x, z, radius, innerRadius)
	local hollowCylinder = GetHollowCylinder(radius, innerRadius)
	gl.PushMatrix()
	gl.Translate(x, averageGroundHeight, z)
	gl.Scale(radius, shapeHeight, radius)
	gl.Utilities.DrawVolume(hollowCylinder)
	gl.PopMatrix()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- Draws a volume using stencil buffer
--- @param vol_dlist number Display list containing the volume geometry
function gl.Utilities.DrawVolume(vol_dlist)
	gl.DepthMask(false)
	if gl.DepthClamp then
		gl.DepthClamp(true)
	end
	gl.StencilTest(true)

	gl.Culling(false)
	gl.DepthTest(true)
	gl.ColorMask(false, false, false, false)
	gl.StencilOp(GL.KEEP, GL.INCR, GL.KEEP)
	--gl.StencilOp(GL.KEEP, GL.INVERT, GL.KEEP)
	gl.StencilMask(1)
	gl.StencilFunc(GL.ALWAYS, 0, 1)

	gl.CallList(vol_dlist)

	gl.Culling(GL.FRONT)
	gl.DepthTest(false)
	gl.ColorMask(true, true, true, true)
	gl.StencilOp(GL.ZERO, GL.ZERO, GL.ZERO)
	gl.StencilMask(1)
	gl.StencilFunc(GL.NOTEQUAL, 0, 1)

	gl.CallList(vol_dlist)

	if gl.DepthClamp then
		gl.DepthClamp(false)
	end
	gl.StencilTest(false)
	-- gl.DepthTest(true)
	gl.Culling(false)
end

-- Make sure that you start with a clear stencil and that you
-- clear it using gl.Clear(GL.STENCIL_BUFFER_BIT, 0)
-- after finishing all the merged volumes
--- Draws a merged volume using stencil buffer tricks
--- Make sure to clear the stencil buffer before and after using this
--- @param vol_dlist number Display list containing the volume geometry
function gl.Utilities.DrawMergedVolume(vol_dlist)
	gl.DepthMask(false)
	if gl.DepthClamp then
		gl.DepthClamp(true)
	end
	gl.StencilTest(true)

	gl.Culling(false)
	gl.DepthTest(true)
	gl.ColorMask(false, false, false, false)
	gl.StencilOp(GL.KEEP, GL.INVERT, GL.KEEP)
	--gl.StencilOp(GL.KEEP, GL.INVERT, GL.KEEP)
	gl.StencilMask(1)
	gl.StencilFunc(GL.ALWAYS, 0, 1)

	gl.CallList(vol_dlist)

	gl.Culling(GL.FRONT)
	gl.DepthTest(false)
	gl.ColorMask(true, true, true, true)
	gl.StencilOp(GL.KEEP, GL.INCR, GL.INCR)
	gl.StencilMask(3)
	gl.StencilFunc(GL.EQUAL, 1, 3)

	gl.CallList(vol_dlist)

	if gl.DepthClamp then
		gl.DepthClamp(false)
	end
	gl.StencilTest(false)
	-- gl.DepthTest(true)
	gl.Culling(false)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
