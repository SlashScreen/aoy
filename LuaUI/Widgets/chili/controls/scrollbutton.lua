--- ScrollButton module
--- A specialized button control used for scrollbar functionality.
--- @class ScrollButton: Button
--- @field axis string Scroll direction ("horizontal" or "vertical")
--- @field position number Current scroll position (0-1)
--- @field step number Step size for incremental scrolling
--- @field minSize number Minimum button size relative to scrollbar
--- @field maxSize number Maximum button size relative to scrollbar
--- @field OnScroll function[] Scroll event listeners
--- @field OnMinimize function[] Minimize event listeners
--- @field borderColor Color Border color (default {1,1,1,0.6})
--- @field backgroundColor Color Background color (default {0.8,0.8,0.8,0.85})
--- @field focusColor Color Color when focused (default {0.9,0.9,0.9,0.85})

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
--- @param obj table Table of scrollbutton properties
--- @return ScrollButton The newly created scrollbutton
function ScrollButton:New(obj)
	obj = inherited.New(self, obj)
	return obj
end

--- Sets the scroll position
--- @param pos number New position (0-1)
--- @param noscroll boolean? Don't trigger scroll event
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
--- @param delta number Amount to scroll
--- @param noscroll boolean? Don't trigger scroll event
function ScrollButton:ScrollBy(delta, noscroll)
	self:SetPosition(self.position + delta, noscroll)
end

--- Steps scroll position
--- @param up boolean Step direction
function ScrollButton:Step(up)
	local delta = up and -self.step or self.step
	self:ScrollBy(delta)
end

--- Sets button size based on content
--- @param contentSize number Total content size
--- @param viewSize number Visible view size
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
--- @param x number X coordinate
--- @param y number Y coordinate
--- @param ... any Additional args
--- @return boolean True if handled
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
--- @param x number X coordinate
--- @param y number Y coordinate
--- @param dx number X movement
--- @param dy number Y movement
--- @param ... any Additional args
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
--- @param x number X coordinate
--- @param y number Y coordinate
--- @param ... any Additional args
function ScrollButton:MouseUp(x, y, ...)
	if not self._dragging then
		return
	end

	self._dragging = false
	self._dragStart = nil

	inherited.MouseUp(self, x, y, ...)
	return self
end
