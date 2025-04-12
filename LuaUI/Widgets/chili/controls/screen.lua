--- Screen module
--- A control that serves as a container for other controls, handling input events and layout.
--- @class Screen: Object
--- @field x number X position
--- @field y number Y position
--- @field width number Width of the screen
--- @field height number Height of the screen
--- @field activeControl Control? Currently active control
--- @field focusedControl Control? Currently focused control
--- @field hoveredControl Control? Currently hovered control
--- @field currentTooltip Control? Currently displayed tooltip
--- @field private _lastHoveredControl Control? Last hovered control
--- @field private _lastClicked number Last click time
--- @field private _lastClickedX number Last clicked X position
--- @field private _lastClickedY number Last clicked Y position
--- @field preserveChildrenOrder boolean Preserve the order of child controls (default true)

Screen = Object:Inherit({
	--Screen = Control:Inherit{
	classname = "screen",
	x = 0,
	y = 0,
	width = 0,
	height = 0,

	preserveChildrenOrder = true,

	activeControl = nil,
	focusedControl = nil,
	hoveredControl = nil,
	currentTooltip = nil,
	_lastHoveredControl = nil,

	_lastClicked = Spring.GetTimer(),
	_lastClickedX = 0,
	_lastClickedY = 0,
})

local this = Screen
local inherited = this.inherited

--//=============================================================================

---@param obj table
function Screen:New(obj)
	local vsx, vsy = gl.GetViewSizes()
	if (obj.width or -1) <= 0 then
		obj.width = vsx
	end
	if (obj.height or -1) <= 0 then
		obj.height = vsy
	end

	obj = inherited.New(self, obj)

	TaskHandler.RequestGlobalDispose(obj)
	obj:RequestUpdate()

	return obj
end

---@param obj Object
function Screen:OnGlobalDispose(obj)
	if CompareLinks(self.activeControl, obj) then
		self.activeControl = nil
	end

	if CompareLinks(self.hoveredControl, obj) then
		self.hoveredControl = nil
	end

	if CompareLinks(self._lastHoveredControl, obj) then
		self._lastHoveredControl = nil
	end

	if CompareLinks(self.focusedControl, obj) then
		self.focusedControl = nil
	end
end

--//=============================================================================

--FIXME add new coordspace Device (which does y-invert)

---@param x number
---@param y number
function Screen:ParentToLocal(x, y)
	return x, y
end

---@param x number
---@param y number
function Screen:LocalToParent(x, y)
	return x, y
end

---@param x number
---@param y number
function Screen:LocalToScreen(x, y)
	return x, y
end

---@param x number
---@param y number
function Screen:ScreenToLocal(x, y)
	return x, y
end

---@param x number
---@param y number
function Screen:ScreenToClient(x, y)
	return x, y
end

---@param x number
---@param y number
function Screen:ClientToScreen(x, y)
	return x, y
end

---@param x number
---@param y number
---@param w number
---@param h number
function Screen:IsRectInView(x, y, w, h)
	return (x <= self.width) and (x + w >= 0) and (y <= self.height) and (y + h >= 0)
end

--//=============================================================================

---@param w number
---@param h number
function Screen:Resize(w, h)
	self.width = w
	self.height = h
	self:CallChildren("RequestRealign")
end

--//=============================================================================

---@param ... any
function Screen:Update(...)
	--//FIXME create a passive MouseMove event and use it instead?
	self:RequestUpdate()
	local hoveredControl = UnlinkSafe(self.hoveredControl)
	local activeControl = UnlinkSafe(self.activeControl)
	if hoveredControl and not activeControl then
		local x, y = Spring.GetMouseState()
		y = select(2, gl.GetViewSizes()) - y
		local cx, cy = hoveredControl:ScreenToLocal(x, y)
		hoveredControl:MouseMove(cx, cy, 0, 0)
	end
end

---@param x number
---@param y number
---@param ... any
---@return boolean?
function Screen:IsAbove(x, y, ...)
	local activeControl = UnlinkSafe(self.activeControl)
	if activeControl then
		return true
	end

	y = select(2, gl.GetViewSizes()) - y
	local hoveredControl = inherited.IsAbove(self, x, y, ...)

	--// tooltip
	if not CompareLinks(hoveredControl, self._lastHoveredControl) then
		if self._lastHoveredControl then
			self._lastHoveredControl:MouseOut()
		end
		if hoveredControl then
			hoveredControl:MouseOver()
		end

		self.hoveredControl = MakeWeakLink(hoveredControl, self.hoveredControl)
		if hoveredControl then
			local control = hoveredControl
			--// find tooltip in hovered control or its parents
			while (not control.tooltip) and control.parent do
				control = control.parent
			end
			self.currentTooltip = control.tooltip
		else
			self.currentTooltip = nil
		end
		self._lastHoveredControl = self.hoveredControl
	elseif self._lastHoveredControl then
		self.currentTooltip = self._lastHoveredControl.tooltip
	end

	return not not hoveredControl
end

---@param control Control?
function Screen:FocusControl(control)
	--UnlinkSafe(self.activeControl)
	if not CompareLinks(control, self.focusedControl) then
		local focusedControl = UnlinkSafe(self.focusedControl)
		if focusedControl then
			focusedControl.state.focused = false
			focusedControl:FocusUpdate() --rename FocusLost()
		end
		self.focusedControl = nil
		if control then
			self.focusedControl = MakeWeakLink(control, self.focusedControl)
			self.focusedControl.state.focused = true
			self.focusedControl:FocusUpdate() --rename FocusGain()
		end
	end
end

---@param x number
---@param y number
---@param ... any
---@return boolean?
function Screen:MouseDown(x, y, ...)
	y = select(2, gl.GetViewSizes()) - y

	local activeControl = inherited.MouseDown(self, x, y, ...)
	self:FocusControl(activeControl)
	self.activeControl = MakeWeakLink(activeControl, self.activeControl)
	return not not activeControl
end

---@param x number
---@param y number
---@param ... any
---@return boolean?
function Screen:MouseUp(x, y, ...)
	y = select(2, gl.GetViewSizes()) - y

	local activeControl = UnlinkSafe(self.activeControl)
	if activeControl then
		local cx, cy = activeControl:ScreenToLocal(x, y)
		local now = Spring.GetTimer()
		local obj

		local hoveredControl = inherited.IsAbove(self, x, y, ...)

		if CompareLinks(hoveredControl, activeControl) then
			--//FIXME send this to controls too, when they didn't `return self` in MouseDown!
			if
				(math.abs(x - self._lastClickedX) < 3)
				and (math.abs(y - self._lastClickedY) < 3)
				and (Spring.DiffTimers(now, self._lastClicked) < 0.45) --FIXME 0.45 := doubleClick time (use spring config?)
			then
				obj = activeControl:MouseDblClick(cx, cy, ...)
			end
			if obj == nil then
				obj = activeControl:MouseClick(cx, cy, ...)
			end
		end
		self._lastClicked = now
		self._lastClickedX = x
		self._lastClickedY = y

		obj = activeControl:MouseUp(cx, cy, ...) or obj
		self.activeControl = nil
		return not not obj
	else
		return (not not inherited.MouseUp(self, x, y, ...))
	end
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param ... any
---@return boolean?
function Screen:MouseMove(x, y, dx, dy, ...)
	y = select(2, gl.GetViewSizes()) - y
	local activeControl = UnlinkSafe(self.activeControl)
	if activeControl then
		local cx, cy = activeControl:ScreenToLocal(x, y)
		local obj = activeControl:MouseMove(cx, cy, dx, -dy, ...)
		if obj == false then
			self.activeControl = nil
		elseif (not not obj) and (obj ~= activeControl) then
			self.activeControl = MakeWeakLink(obj, self.activeControl)
			return true
		else
			return true
		end
	end

	return (not not inherited.MouseMove(self, x, y, dx, -dy, ...))
end

---@param x number
---@param y number
---@param ... any
---@return boolean?
function Screen:MouseWheel(x, y, ...)
	y = select(2, gl.GetViewSizes()) - y
	local activeControl = UnlinkSafe(self.activeControl)
	if activeControl then
		local cx, cy = activeControl:ScreenToLocal(x, y)
		local obj = activeControl:MouseWheel(cx, cy, ...)
		if obj == false then
			self.activeControl = nil
		elseif (not not obj) and (obj ~= activeControl) then
			self.activeControl = MakeWeakLink(obj, self.activeControl)
			return true
		else
			return true
		end
	end

	return (not not inherited.MouseWheel(self, x, y, ...))
end

---@param ... any
---@return boolean?
function Screen:KeyPress(...)
	local focusedControl = UnlinkSafe(self.focusedControl)
	if focusedControl then
		return (not not focusedControl:KeyPress(...))
	end
	return (not not inherited:KeyPress(...))
end

---@param ... any
---@return boolean?
function Screen:TextInput(...)
	local focusedControl = UnlinkSafe(self.focusedControl)
	if focusedControl then
		return (not not focusedControl:TextInput(...))
	end
	return (not not inherited:TextInput(...))
end

--//=============================================================================
