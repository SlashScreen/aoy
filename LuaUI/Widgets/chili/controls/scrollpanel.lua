--//=============================================================================

--- ScrollPanel module
--- A container control that provides scrolling functionality for content that exceeds its bounds.
--- @class ScrollPanel: Control
--- @field horizontal boolean Enable horizontal scrolling (default true)
--- @field vertical boolean Enable vertical scrolling (default true)
--- @field smoothScroll boolean Use smooth scrolling (default true)
--- @field smoothScrollSpeed number Scroll animation speed (default 1)
--- @field scrollbarSize number Width of scrollbars (default 12)
--- @field scrollbarScale number Scale of scrollbar relative to content (default 50)
--- @field scrollPosX number Current horizontal scroll position (default 0)
--- @field scrollPosY number Current vertical scroll position (default 0)
--- @field backgroundColor Color Background color (default {0,0,0,0.5})
--- @field borderColor Color Border color (default {0.3,0.3,0.3,1})
--- @field ignoreMouseWheel boolean Ignore mouse wheel input (default true)
--- @field OnScroll function[] Scroll event listeners

ScrollPanel = Control:Inherit({
	classname = "scrollpanel",
	horizontal = true,
	vertical = true,

	smoothScroll = true,
	smoothScrollSpeed = 1,

	scrollbarSize = 12,
	scrollbarScale = 50,

	scrollPosX = 0,
	scrollPosY = 0,

	backgroundColor = { 0, 0, 0, 0.5 },
	borderColor = { 0.3, 0.3, 0.3, 1 },

	ignoreMouseWheel = true,

	OnScroll = {},
})

local this = ScrollPanel
local inherited = this.inherited

--- Creates a new ScrollPanel instance
--- @param obj table Table of scrollpanel properties
--- @return ScrollPanel The newly created scrollpanel
function ScrollPanel:New(obj)
	obj = inherited.New(self, obj)

	-- Create scrollbars
	if obj.horizontal then
		obj._hScrollbar = ScrollButton:New({
			x = 0,
			bottom = 0,
			height = obj.scrollbarSize,
			right = obj.vertical and obj.scrollbarSize or 0,
			axis = "horizontal",
			parent = obj,
			OnScroll = {
				function(_, pos)
					obj:SetScrollPos(pos, nil)
				end,
			},
		})
	end

	if obj.vertical then
		obj._vScrollbar = ScrollButton:New({
			right = 0,
			y = 0,
			width = obj.scrollbarSize,
			bottom = obj.horizontal and obj.scrollbarSize or 0,
			axis = "vertical",
			parent = obj,
			OnScroll = {
				function(_, pos)
					obj:SetScrollPos(nil, pos)
				end,
			},
		})
	end

	return obj
end

---@param x number
local function smoothstep(x)
	return x * x * (3 - 2 * x)
end

--- Sets the scroll position
--- @param x number? Horizontal position (0-1) or nil
--- @param y number? Vertical position (0-1) or nil
function ScrollPanel:SetScrollPos(x, y)
	local contentWidth = self:GetContentWidth()
	local contentHeight = self:GetContentHeight()

	-- Update horizontal scroll
	if x then
		x = math.max(0, math.min(1, x))
		if self.scrollPosX ~= x then
			self.scrollPosX = x
			self:RequestRealign()
		end
	end

	-- Update vertical scroll
	if y then
		y = math.max(0, math.min(1, y))
		if self.scrollPosY ~= y then
			self.scrollPosY = y
			self:RequestRealign()
		end
	end

	self:CallListeners(self.OnScroll, self.scrollPosX, self.scrollPosY)
end

---@param ... any
function ScrollPanel:Update(...)
	local trans = 1
	if self.smoothScroll and self._smoothScrollEnd then
		local trans = Spring.DiffTimers(Spring.GetTimer(), self._smoothScrollEnd)
		trans = trans / self.smoothScrollTime

		if trans >= 1 then
			self.scrollPosX = self._newScrollPosX
			self.scrollPosY = self._newScrollPosY
			self._smoothScrollEnd = nil
		else
			for n = 1, 3 do
				trans = smoothstep(trans)
			end
			self.scrollPosX = self._oldScrollPosX * (1 - trans) + self._newScrollPosX * trans
			self.scrollPosY = self._oldScrollPosY * (1 - trans) + self._newScrollPosY * trans
			self:InvalidateSelf()
		end
	end

	inherited.Update(self, ...)
end

---@return number
function ScrollPanel:GetContentWidth()
	local width = 0
	for i = 1, #self.children do
		local c = self.children[i]
		if c ~= self._hScrollbar and c ~= self._vScrollbar then
			width = math.max(width, c.x + c.width)
		end
	end
	return width
end

---@return number
function ScrollPanel:GetContentHeight()
	local height = 0
	for i = 1, #self.children do
		local c = self.children[i]
		if c ~= self._hScrollbar and c ~= self._vScrollbar then
			height = math.max(height, c.y + c.height)
		end
	end
	return height
end

function ScrollPanel:UpdateScrollbars()
	local contentWidth = self:GetContentWidth()
	local contentHeight = self:GetContentHeight()

	if self._hScrollbar then
		self._hScrollbar:SetContentSize(contentWidth, self.clientWidth)
	end

	if self._vScrollbar then
		self._vScrollbar:SetContentSize(contentHeight, self.clientHeight)
	end
end

function ScrollPanel:UpdateClientArea()
	inherited.UpdateClientArea(self)

	-- Adjust client area for scrollbars
	if self._vScrollbar and self._vScrollbar.visible then
		self.clientArea[3] = self.clientArea[3] - self.scrollbarSize
	end

	if self._hScrollbar and self._hScrollbar.visible then
		self.clientArea[4] = self.clientArea[4] - self.scrollbarSize
	end

	self:UpdateScrollbars()
end

---@param x number
---@param y number
function ScrollPanel:LocalToClient(x, y)
	local ca = self.clientArea
	return x - ca[1] + self.scrollPosX, y - ca[2] + self.scrollPosY
end

---@param x number
---@param y number
function ScrollPanel:ClientToLocal(x, y)
	local ca = self.clientArea
	return x + ca[1] - self.scrollPosX, y + ca[2] - self.scrollPosY
end

---@param x number
---@param y number
function ScrollPanel:ParentToClient(x, y)
	local ca = self.clientArea
	return x - self.x - ca[1] + self.scrollPosX, y - self.y - ca[2] + self.scrollPosY
end

---@param x number
---@param y number
function ScrollPanel:ClientToParent(x, y)
	local ca = self.clientArea
	return x + self.x + ca[1] - self.scrollPosX, y + self.y + ca[2] - self.scrollPosY
end

function ScrollPanel:GetCurrentExtents()
	local left = self.x
	local top = self.y
	local right = self.x + self.width
	local bottom = self.y + self.height

	if left < minLeft then
		minLeft = left
	end
	if top < minTop then
		minTop = top
	end

	if right > maxRight then
		maxRight = right
	end
	if bottom > maxBottom then
		maxBottom = bottom
	end

	return minLeft, minTop, maxRight, maxBottom
end

function ScrollPanel:_DetermineContentArea()
	local minLeft, minTop, maxRight, maxBottom = self:GetChildrenCurrentExtents()

	self.contentArea = {
		0,
		0,
		maxRight,
		maxBottom,
	}

	local contentArea = self.contentArea
	local clientArea = self.clientArea

	if self.verticalScrollbar then
		if contentArea[4] > clientArea[4] then
			if not self._vscrollbar then
				self.padding[3] = self.padding[3] + self.scrollbarSize
			end
			self._vscrollbar = true
		else
			if self._vscrollbar then
				self.padding[3] = self.padding[3] - self.scrollbarSize
			end
			self._vscrollbar = false
		end
	end

	if self.horizontalScrollbar then
		if contentArea[3] > clientArea[3] then
			if not self._hscrollbar then
				self.padding[4] = self.padding[4] + self.scrollbarSize
			end
			self._hscrollbar = true
		else
			if self._hscrollbar then
				self.padding[4] = self.padding[4] - self.scrollbarSize
			end
			self._hscrollbar = false
		end
	end

	self:UpdateClientArea()

	local contentArea = self.contentArea
	local clientArea = self.clientArea
	if contentArea[4] < clientArea[4] then
		contentArea[4] = clientArea[4]
	end
	if contentArea[3] < clientArea[3] then
		contentArea[3] = clientArea[3]
	end
end

function ScrollPanel:UpdateLayout()
	--self:_DetermineContentArea()
	self:RealignChildren()
	local before = ((self._vscrollbar and 1) or 0) + ((self._hscrollbar and 2) or 0)
	self:_DetermineContentArea()
	local now = ((self._vscrollbar and 1) or 0) + ((self._hscrollbar and 2) or 0)
	if before ~= now then
		self:RealignChildren()
	end

	self.scrollPosX = clamp(0, self.contentArea[3] - self.clientArea[3], self.scrollPosX)

	local oldClamp = self.clampY or 0
	self.clampY = self.contentArea[4] - self.clientArea[4]

	if self.verticalSmartScroll and self.scrollPosY >= oldClamp then
		self.scrollPosY = self.clampY
	else
		self.scrollPosY = clamp(0, self.clampY, self.scrollPosY)
	end

	return true
end

---@param x number
---@param y number
---@param w number
---@param h number
function ScrollPanel:IsRectInView(x, y, w, h)
	if not self.parent then
		return false
	end

	if self._inrtt then
		return true
	end

	--//FIXME 1. don't create tables 2. merge somehow into Control:IsRectInView
	local cx = x - self.scrollPosX
	local cy = y - self.scrollPosY

	local rect1 = { cx, cy, w, h }
	local rect2 = { 0, 0, self.clientArea[3], self.clientArea[4] }
	local inview = AreRectsOverlapping(rect1, rect2)

	if not inview then
		return false
	end

	local px, py = self:ClientToParent(x, y)
	return (self.parent):IsRectInView(px, py, w, h)
end

function ScrollPanel:DrawControl()
	--// gets overriden by the skin/theme
end

---@param fnc function
---@param ... any
function ScrollPanel:_DrawInClientArea(fnc, ...)
	local clientX, clientY, clientWidth, clientHeight = unpack4(self.clientArea)

	gl.PushMatrix()
	gl.Translate(clientX - self.scrollPosX, clientY - self.scrollPosY, 0)

	local sx, sy = self:LocalToScreen(clientX, clientY)
	sy = select(2, gl.GetViewSizes()) - (sy + clientHeight)

	if PushLimitRenderRegion(self, sx, sy, clientWidth, clientHeight) then
		fnc(...)
		PopLimitRenderRegion(self, sx, sy, clientWidth, clientHeight)
	end

	gl.PopMatrix()
end

---@param x number
---@param y number
---@return boolean
function ScrollPanel:IsAboveHScrollbars(x, y)
	if not self._hscrollbar then
		return false
	end
	return y >= (self.height - self.scrollbarSize) --FIXME
end

---@param x number
---@param y number
---@return boolean
function ScrollPanel:IsAboveVScrollbars(x, y)
	if not self._vscrollbar then
		return false
	end
	return x >= (self.width - self.scrollbarSize) --FIXME
end

---@param x number
---@param y number
---@return ScrollPanel|nil
function ScrollPanel:HitTest(x, y)
	if self:IsAboveVScrollbars(x, y) then
		return self
	end
	if self:IsAboveHScrollbars(x, y) then
		return self
	end

	return inherited.HitTest(self, x, y)
end

---@param x number
---@param y number
---@param ... any
---@return ScrollPanel|boolean
function ScrollPanel:MouseDown(x, y, ...)
	if self:IsAboveVScrollbars(x, y) then
		self._vscrolling = true
		local clientArea = self.clientArea
		local cy = y - clientArea[2]
		self:SetScrollPos(nil, (cy / clientArea[4]) * self.contentArea[4], true, false)
		return self
	end
	if self:IsAboveHScrollbars(x, y) then
		self._hscrolling = true
		local clientArea = self.clientArea
		local cx = x - clientArea[1]
		self:SetScrollPos((cx / clientArea[3]) * self.contentArea[3], nil, true, false)
		return self
	end

	return inherited.MouseDown(self, x, y, ...)
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param ... any
---@return ScrollPanel|boolean
function ScrollPanel:MouseMove(x, y, dx, dy, ...)
	if self._vscrolling then
		local clientArea = self.clientArea
		local cy = y - clientArea[2]
		self:SetScrollPos(nil, (cy / clientArea[4]) * self.contentArea[4], true, false)
		return self
	end
	if self._hscrolling then
		local clientArea = self.clientArea
		local cx = x - clientArea[1]
		self:SetScrollPos((cx / clientArea[3]) * self.contentArea[3], nil, true, false)
		return self
	end

	local old = (self._hHovered and 1 or 0) + (self._vHovered and 2 or 0)
	self._hHovered = self:IsAboveHScrollbars(x, y)
	self._vHovered = self:IsAboveVScrollbars(x, y)
	local new = (self._hHovered and 1 or 0) + (self._vHovered and 2 or 0)
	if new ~= old then
		self:InvalidateSelf()
	end

	return inherited.MouseMove(self, x, y, dx, dy, ...)
end

---@param x number
---@param y number
---@param ... any
---@return ScrollPanel|boolean
function ScrollPanel:MouseUp(x, y, ...)
	if self._vscrolling then
		self._vscrolling = nil
		local clientArea = self.clientArea
		local cy = y - clientArea[2]
		self:SetScrollPos(nil, (cy / clientArea[4]) * self.contentArea[4], true, false)
		return self
	end
	if self._hscrolling then
		self._hscrolling = nil
		local clientArea = self.clientArea
		local cx = x - clientArea[1]
		self:SetScrollPos((cx / clientArea[3]) * self.contentArea[3], nil, true, false)
		return self
	end

	return inherited.MouseUp(self, x, y, ...)
end

--- Handles mouse wheel scrolling
--- @param x number Mouse x position
--- @param y number Mouse y position
--- @param up boolean Wheel direction (true = up)
--- @param value number Wheel delta value
--- @param mods table Key modifiers
--- @return boolean handled True if event was handled
function ScrollPanel:MouseWheel(x, y, up, value, mods)
	if self.ignoreMouseWheel then
		return false
	end

	-- Shift+Wheel = Horizontal scroll
	if mods.shift then
		self:HorizontalScrollbar(x, y, up, value)
		return self
	end

	-- Regular wheel = Vertical scroll
	local dir = up and 1 or -1
	local step = self.scrollbarSize[2] * dir * value

	self.scrollPosY = clamp(0, self.scrollPosY - step, self.maxScrollY)
	self:RequestUpdate()
	return self
end

---@param ... any
function ScrollPanel:MouseOut(...)
	inherited.MouseOut(self, ...)
	self._hHovered = false
	self._vHovered = false
	self:InvalidateSelf()
end
