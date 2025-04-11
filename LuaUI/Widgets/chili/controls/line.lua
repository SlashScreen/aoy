--//=============================================================================

--- Line module
--- A control that draws lines between points with customizable style.

--- Line fields
-- Inherits from Control.
-- @see control.Control
-- @table Line
-- @tparam table points Array of line points {x1,y1, x2,y2, ...}
-- @tparam {r,g,b,a} color Line color (default {1,1,1,1})
-- @number[opt=1] width Line width
-- @bool[opt=false] style Line style ("solid", "dashed", "dotted")
-- @number[opt=5] dashLength Length of dashes
-- @number[opt=5] dotSpacing Spacing between dots
-- @bool[opt=false] relative Points are relative to control position

Line = Control:Inherit({
	classname = "line",
	points = {},
	color = { 1, 1, 1, 1 },
	width = 1,
	style = "solid",

	dashLength = 5,
	dotSpacing = 5,
	relative = false,
})

local this = Line
local inherited = this.inherited

--- Creates a new Line instance
-- @function Line:New
-- @param obj Table of line properties
-- @return Line The newly created line
function Line:New(obj)
	obj = inherited.New(self, obj)
	return obj
end

--- Sets line points
-- @function Line:SetPoints
-- @param points Array of points {x1,y1, x2,y2, ...}
function Line:SetPoints(points)
	self.points = points
	self:Invalidate()
end

--- Adds a point to the line
-- @function Line:AddPoint
-- @param x X coordinate
-- @param y Y coordinate
function Line:AddPoint(x, y)
	table.insert(self.points, x)
	table.insert(self.points, y)
	self:Invalidate()
end

--- Clears all points
-- @function Line:ClearPoints
function Line:ClearPoints()
	self.points = {}
	self:Invalidate()
end

--- Draws the line
-- @function Line:DrawControl
function Line:DrawControl()
	if #self.points < 4 then
		return
	end -- Need at least 2 points

	gl.Color(self.color)
	gl.LineWidth(self.width)

	-- Draw based on style
	if self.style == "solid" then
		gl.BeginEnd(GL.LINE_STRIP, function()
			for i = 1, #self.points, 2 do
				local x = self.points[i]
				local y = self.points[i + 1]
				if not self.relative then
					x = x - self.x
					y = y - self.y
				end
				gl.Vertex(x, y)
			end
		end)
	elseif self.style == "dashed" then
		-- Draw dashed line segments
		for i = 1, #self.points - 2, 2 do
			local x1 = self.points[i]
			local y1 = self.points[i + 1]
			local x2 = self.points[i + 2]
			local y2 = self.points[i + 3]

			if not self.relative then
				x1 = x1 - self.x
				y1 = y1 - self.y
				x2 = x2 - self.x
				y2 = y2 - self.y
			end

			local dx = x2 - x1
			local dy = y2 - y1
			local len = math.sqrt(dx * dx + dy * dy)
			local nx = dx / len
			local ny = dy / len

			local dash = 0
			while dash < len do
				local dashEnd = math.min(dash + self.dashLength, len)
				gl.BeginEnd(GL.LINES, function()
					gl.Vertex(x1 + nx * dash, y1 + ny * dash)
					gl.Vertex(x1 + nx * dashEnd, y1 + ny * dashEnd)
				end)
				dash = dash + self.dashLength * 2
			end
		end
	elseif self.style == "dotted" then
		-- Draw dots along line
		for i = 1, #self.points - 2, 2 do
			local x1 = self.points[i]
			local y1 = self.points[i + 1]
			local x2 = self.points[i + 2]
			local y2 = self.points[i + 3]

			if not self.relative then
				x1 = x1 - self.x
				y1 = y1 - self.y
				x2 = x2 - self.x
				y2 = y2 - self.y
			end

			local dx = x2 - x1
			local dy = y2 - y1
			local len = math.sqrt(dx * dx + dy * dy)
			local nx = dx / len
			local ny = dy / len

			local dot = 0
			while dot < len do
				gl.PointSize(self.width)
				gl.BeginEnd(GL.POINTS, function()
					gl.Vertex(x1 + nx * dot, y1 + ny * dot)
				end)
				dot = dot + self.dotSpacing
			end
		end
	end

	gl.LineWidth(1)
	gl.PointSize(1)
end

--- Handles hit testing
-- @function Line:HitTest
-- @param x X coordinate
-- @param y Y coordinate
-- @return boolean True if hit
function Line:HitTest(x, y)
	if not self:IsDescendantOf(screen0) then
		return false
	end

	-- Check each line segment
	for i = 1, #self.points - 2, 2 do
		local x1 = self.points[i]
		local y1 = self.points[i + 1]
		local x2 = self.points[i + 2]
		local y2 = self.points[i + 3]

		if not self.relative then
			x1 = x1 - self.x
			y1 = y1 - self.y
			x2 = x2 - self.x
			y2 = y2 - self.y
		end

		-- Check if point is within tolerance of line segment
		local tolerance = self.width + 2
		if PointLineDistance(x, y, x1, y1, x2, y2) <= tolerance then
			return self
		end
	end

	return false
end

--//=============================================================================
