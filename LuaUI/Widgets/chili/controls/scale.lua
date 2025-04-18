---@class Scale : Control
---@field classname string The class name
---@field min number Minimum value
---@field max number Maximum value
---@field step number Step size between values
---@field logBase number Base for logarithmic scale
---@field defaultWidth number Default width
---@field defaultHeight number Default height
---@field fontsize number Font size in pixels
---@field scaleFunction function|nil Custom scale function (takes 0-1, returns 0-1)
---@field color number[] Scale color {r,g,b,a}
Scale = Control:Inherit({
	classname = "scale",
	min = -50,
	max = 50,
	step = 10,
	logBase = 1.5,

	defaultWidth = 90,
	defaultHeight = 12,
	fontsize = 8,
	scaleFunction = nil, -- function that can be used to rescale graph - takes 0-1 and must return 0-1
	color = { 0, 0, 0, 1 },
})

local this = Scale

--//=============================================================================

--//=============================================================================

local glVertex = gl.Vertex

local function defaultTransform(x)
	return (math.log(1 + x * 140) / math.log(141))
end

---Draws the scale lines
---@param self Scale Scale instance
---@return nil
local function drawScaleLines(self)
	local hline = self.y + self.height
	local h1 = self.y + self.fontsize
	local h2 = self.y + self.height

	glVertex(0, hline)
	glVertex(self.width, hline)

	if self.scaleFunction == nil then
		local scale = self.width / (self.max - self.min)

		for v = self.min, self.max, self.step do
			local xp = scale * (v - self.min)
			glVertex(xp, h1)
			glVertex(xp, h2)
		end
	else
		local center = self.width * 0.5
		local halfWidth = 0.5 * self.width
		local lastXp = -1
		for v = 0, self.max, self.step do
			local xp = self.scaleFunction(v / self.max) * halfWidth + center
			glVertex(xp, h1)
			glVertex(xp, h2)
			if xp - lastXp < 2 then
				glVertex(xp, h1)
				glVertex(self.width, h1)
				glVertex(xp, h2)
				glVertex(self.width, h2)
				break
			end
			lastXp = xp
		end

		local lastXp = 99999
		for v = 0, self.min, -self.step do
			local xp = center - self.scaleFunction(v / self.min) * halfWidth
			glVertex(xp, h1)
			glVertex(xp, h2)
			if lastXp - xp <= 2 then
				glVertex(xp, h1)
				glVertex(0, h1)
				glVertex(xp, h2)
				glVertex(0, h2)
				break
			end
			lastXp = xp
		end
	end
end

function Scale:DrawControl()
	gl.Color(self.color)
	gl.BeginEnd(GL.LINES, drawScaleLines, self)

	local font = self.font

	if self.min <= 0 and self.max >= 0 then
		local scale = self.width / (self.max - self.min)
		font:Print(0, scale * (0 - self.min), 0, "center", "ascender")
	end

	font:Print(self.min, 0, 0, "left", "ascender")
	font:Print("+" .. self.max, self.width, 0, "right", "ascender")
end

--//=============================================================================

function Scale:HitTest()
	return false
end

--//=============================================================================
