--- ScrollButton module
--- A specialized button control used for scrollbar functionality.

--- ScrollButton fields
-- Inherits from Button.
-- @see button.Button
-- @table ScrollButton
-- @string[opt="horizontal"] axis Scroll direction ("horizontal" or "vertical")
-- @number[opt=0] position Current scroll position (0-1)
-- @number[opt=0.1] step Step size for incremental scrolling
-- @number[opt=0.1] minSize Minimum button size relative to scrollbar
-- @number[opt=1.0] maxSize Maximum button size relative to scrollbar
-- @tparam function{} OnScroll Scroll event listeners
-- @tparam function{} OnMinimize Minimize event listeners

ScrollButton = Button:Inherit({
	classname = "scrollbutton",

	axis = "horizontal",
	position = 0,
	step = 0.1,
	minSize = 0.1,
	maxSize = 1.0,

	borderColor = { 1, 1, 1, 0.6 },
	backgroundColor = { 0.8, 0.8, 0.8, 0.85 },
	focusColor = { 0.9, 0.9, 0.9, 0.85 },

	OnScroll = {},
	OnMinimize = {},
})

local this = ScrollButton
local inherited = this.inherited

--- Creates a new ScrollButton instance
-- @function ScrollButton:New
-- @param obj Table of scrollbutton properties
-- @return ScrollButton The newly created scrollbutton
function ScrollButton:New(obj)
	obj = inherited.New(self, obj)
	return obj
end

--- Sets the scroll position
-- @function ScrollButton:SetPosition
-- @param pos New position (0-1)
-- @param noscroll Don't trigger scroll event
function ScrollButton:SetPosition(pos, noscroll)
	pos = math.min(1, math.max(0, pos))
	if self.position == pos then
		return
	end

	self.position = pos
	if not noscroll then
		self:CallListeners(self.OnScroll, pos)
	end

	self:InvalidateSelf()
end

--- Scrolls by relative amount
-- @function ScrollButton:ScrollBy
-- @param delta Amount to scroll
-- @param noscroll Don't trigger scroll event
function ScrollButton:ScrollBy(delta, noscroll)
	self:SetPosition(self.position + delta, noscroll)
end

--- Steps scroll position
-- @function ScrollButton:Step
-- @param up Step direction
function ScrollButton:Step(up)
	local delta = up and -self.step or self.step
	self:ScrollBy(delta)
end

--- Sets button size based on content
-- @function ScrollButton:SetContentSize
-- @param contentSize Total content size
-- @param viewSize Visible view size
function ScrollButton:SetContentSize(contentSize, viewSize)
	local ratio = math.min(1, viewSize / contentSize)
	ratio = math.max(self.minSize, math.min(self.maxSize, ratio))

	if self.axis == "horizontal" then
		self.width = self.parent.width * ratio
	else
		self.height = self.parent.height * ratio
	end

	self:InvalidateSelf()

	if ratio >= 1 then
		self:CallListeners(self.OnMinimize, true)
	else
		self:CallListeners(self.OnMinimize, false)
	end
end

--- Handles mouse down events
-- @function ScrollButton:MouseDown
-- @param x X coordinate
-- @param y Y coordinate
-- @param ... Additional args
-- @return boolean True if handled
function ScrollButton:MouseDown(x, y, ...)
	if not self:HitTest(x, y) then
		return false
	end

	self._dragging = true
	if self.axis == "horizontal" then
		self._dragStart = x - self.x
	else
		self._dragStart = y - self.y
	end

	inherited.MouseDown(self, x, y, ...)
	return self
end

--- Handles mouse move events during drag
-- @function ScrollButton:MouseMove
-- @param x X coordinate
-- @param y Y coordinate
-- @param dx X movement
-- @param dy Y movement
-- @param ... Additional args
function ScrollButton:MouseMove(x, y, dx, dy, ...)
	if not self._dragging then
		return
	end

	local pos
	if self.axis == "horizontal" then
		local dragX = x - self._dragStart
		pos = dragX / (self.parent.width - self.width)
	else
		local dragY = y - self._dragStart
		pos = dragY / (self.parent.height - self.height)
	end

	self:SetPosition(pos)

	inherited.MouseMove(self, x, y, dx, dy, ...)
end

--- Handles mouse up events
-- @function ScrollButton:MouseUp
-- @param x X coordinate
-- @param y Y coordinate
-- @param ... Additional args
function ScrollButton:MouseUp(x, y, ...)
	if not self._dragging then
		return
	end

	self._dragging = false
	self._dragStart = nil

	inherited.MouseUp(self, x, y, ...)
	return self
end
