--//=============================================================================

--- Panel module
--- A basic container control that can hold and arrange other controls.
--- @class Panel: Control
--- @field padding [number, number, number, number] Internal padding from edges (default {5,5,5,5})
--- @field margin [number, number, number, number] External margin around panel (default {0,0,0,0})
--- @field resizeItems boolean Resize child items to fit
--- @field autosize boolean Automatically size to fit content
--- @field backgroundColor Color Background color
--- @field borderColor Color Border color
--- @field borderWidth number Border thickness

Panel = Control:Inherit({
	classname = "panel",
	padding = { 5, 5, 5, 5 },
	margin = { 0, 0, 0, 0 },
	backgroundColor = { 0, 0, 0, 0.5 },
	borderColor = { 1, 1, 1, 0.5 },
	borderWidth = 0,
	resizeItems = false,
	autosize = false,
})

local this = Panel
local inherited = this.inherited

--- Creates a new Panel instance
-- @function Panel:New
-- @param obj Table of panel properties
-- @return Panel The newly created panel
function Panel:New(obj)
	obj = inherited.New(self, obj)
	return obj
end

--- Draws the panel background and border
-- @function Panel:DrawControl
function Panel:DrawControl()
	-- Draw background
	if self.backgroundColor then
		gl.Color(self.backgroundColor)
		gl.Rect(0, 0, self.width, self.height)
	end

	-- Draw border
	if self.borderWidth > 0 then
		gl.Color(self.borderColor)
		gl.LineWidth(self.borderWidth)
		gl.Shape(GL.LINE_LOOP, {
			{ 0, 0 },
			{ self.width, 0 },
			{ self.width, self.height },
			{ 0, self.height },
		})
		gl.LineWidth(1)
	end
end

--- Updates panel layout
-- @function Panel:UpdateLayout
-- @return boolean True if layout was updated
function Panel:UpdateLayout()
	local contentWidth = 0
	local contentHeight = 0

	-- Calculate content size from children
	for i = 1, #self.children do
		local child = self.children[i]
		local childRight = child.x + child.width
		local childBottom = child.y + child.height

		contentWidth = math.max(contentWidth, childRight)
		contentHeight = math.max(contentHeight, childBottom)
	end

	-- Add padding
	contentWidth = contentWidth + self.padding[1] + self.padding[3]
	contentHeight = contentHeight + self.padding[2] + self.padding[4]

	-- Update size if autosize enabled
	if self.autosize then
		self.width = contentWidth
		self.height = contentHeight
		return true
	end

	return false
end

--- Handle hit testing for mouse events
-- @function Panel:HitTest
-- @param x X coordinate to test
-- @param y Y coordinate to test
-- @return Control Child control at coordinates or self
function Panel:HitTest(x, y)
	local children = self.children

	-- Check children first
	for i = #children, 1, -1 do
		local c = children[i]
		if c:HitTest(x, y) then
			return c
		end
	end

	-- Then check self
	if self._hitTest then
		return self._hitTest(self, x, y)
	end

	return self:IsPixelInView(x, y) and self
end

--//=============================================================================
