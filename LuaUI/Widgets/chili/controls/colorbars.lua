--//=============================================================================

--- Colorbars module
-- This module defines a Colorbars control, which is a UI element that allows users to adjust RGBA color values interactively.

--- Colorbar fields.
-- Inherits from Control.
-- @see control.Control
-- @table Colorbars
-- @tparam {r,g,b,a} color The RGBA color table, where each value is between 0 and 1. Default is {1,1,1,1} (white).
-- @tparam {func1,func2,...} OnChange A list of listener functions that are triggered when the color changes. Default is an empty table.
Colorbars = Control:Inherit({
	classname = "colorbars",
	color = { 1, 1, 1, 1 },

	defaultWidth = 100,
	defaultHeight = 20,

	OnChange = {},
})

local this = Colorbars
local inherited = this.inherited

--//=============================================================================

--- Sets the new color.
-- Updates the color value and triggers the OnChange listeners.
-- @tparam {r,g,b,a} c The new RGBA color table.
function Colorbars:SetColor(c)
	self:CallListeners(self.OnChange, c)
	self.value = c
	self:Invalidate()
end

--//=============================================================================

local GL_LINE_LOOP = GL.LINE_LOOP
local GL_LINES = GL.LINES
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glTranslate = gl.Translate
local glVertex = gl.Vertex
local glRect = gl.Rect
local glColor = gl.Color
local glBeginEnd = gl.BeginEnd

--- Draws the Colorbars control.
-- This method renders the color bars and the preview area. It is intended to be overridden by the skin or theme to define the appearance.
function Colorbars:DrawControl()
	local barswidth = self.width - (self.height + 4)

	local color = self.color
	local step = self.height / 7

	-- Draw individual color bars for R, G, B, and A channels
	local rX1, rY1, rX2, rY2 = 0, 0 * step, color[1] * barswidth, 1 * step
	local gX1, gY1, gX2, gY2 = 0, 2 * step, color[2] * barswidth, 3 * step
	local bX1, bY1, bX2, bY2 = 0, 4 * step, color[3] * barswidth, 5 * step
	local aX1, aY1, aX2, aY2 = 0, 6 * step, (color[4] or 1) * barswidth, 7 * step

	glColor(1, 0, 0, 1)
	glRect(rX1, rY1, rX2, rY2)

	glColor(0, 1, 0, 1)
	glRect(gX1, gY1, gX2, gY2)

	glColor(0, 0, 1, 1)
	glRect(bX1, bY1, bX2, bY2)

	glColor(1, 1, 1, 1)
	glRect(aX1, aY1, aX2, aY2)

	-- Draw the color preview area
	glColor(self.color)
	glRect(barswidth + 2, self.height, self.width - 2, 0)

	gl.BeginEnd(
		GL.TRIANGLE_STRIP,
		theme.DrawBorder_,
		barswidth + 2,
		0,
		self.width - barswidth - 4,
		self.height,
		1,
		self.borderColor,
		self.borderColor2
	)
end

--//=============================================================================

--- Performs a hit test to determine if the Colorbars control was clicked.
-- @return Colorbars Returns the Colorbars instance if the hit test is successful.
function Colorbars:HitTest()
	return self
end

--- Handles the mouse down event.
-- Adjusts the color value based on the mouse position.
-- @number x The X-coordinate of the mouse click.
-- @number y The Y-coordinate of the mouse click.
-- @return Colorbars Returns the Colorbars instance.
function Colorbars:MouseDown(x, y)
	local step = self.height / 7
	local yp = y / step
	local r = yp % 2
	local barswidth = self.width - (self.height + 4)

	if (x <= barswidth) and (r <= 1) then
		local barIdx = (yp - r) / 2 + 1
		local newvalue = x / barswidth
		if newvalue > 1 then
			newvalue = 1
		elseif newvalue < 0 then
			newvalue = 0
		end
		self.color[barIdx] = newvalue
		self:SetColor(self.color)
		return self
	end
end

--- Handles the mouse move event.
-- Adjusts the color value interactively while the mouse is dragged.
-- @number x The current X-coordinate of the mouse.
-- @number y The current Y-coordinate of the mouse.
-- @number dx The change in X-coordinate since the last event.
-- @number dy The change in Y-coordinate since the last event.
-- @number button The mouse button being held down.
-- @return Colorbars Returns the Colorbars instance.
function Colorbars:MouseMove(x, y, dx, dy, button)
	if button == 1 then
		return self:MouseDown(x, y)
	end
end

--//=============================================================================
