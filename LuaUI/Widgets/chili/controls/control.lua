--//=============================================================================

--- Control module
-- This module defines a Control, which is a base UI element that provides common functionality for layout, rendering, and interaction.

--- Control fields.
-- Inherits from Object.
-- @see object.Object
-- @table Control
-- @tparam {left,top,right,bottom} padding Table of padding values for the control's content area. Default is {5,5,5,5}.
-- @number[opt=1.5] borderThickness Thickness of the control's border in pixels.
-- @tparam {r,g,b,a} borderColor Primary border color in RGBA format. Default is {1,1,1,0.6}.
-- @tparam {r,g,b,a} borderColor2 Secondary border color in RGBA format. Default is {0,0,0,0.8}.
-- @tparam {r,g,b,a} backgroundColor Background color of the control in RGBA format. Default is {0.8,0.8,1,0.4}.
-- @tparam {r,g,b,a} focusColor Color used to indicate focus in RGBA format. Default is {0.2,0.2,1,0.6}.
-- @bool[opt=false] autosize Whether the control automatically adjusts its size based on its content.
-- @bool[opt=false] draggable Whether the control can be dragged.
-- @bool[opt=false] resizable Whether the control can be resized.
-- @int[opt=10] minWidth Minimum width of the control.
-- @int[opt=10] minHeight Minimum height of the control.
-- @int[opt=1e9] maxWidth Maximum width of the control.
-- @int[opt=1e9] maxHeight Maximum height of the control.
-- @tparam {func1,func2,...} OnResize Listeners triggered when the control is resized. Default is an empty table.

local fontfile = LUAUI_DIRNAME .. "fonts/" .. Spring.GetConfigString("ui_font", "JosefinSans-SemiBold.ttf")
local fontfile2 = LUAUI_DIRNAME .. "fonts/" .. Spring.GetConfigString("ui_font2", "JosefinSans-Bold.ttf")

Control = Object:Inherit({
	classname = "control",
	padding = { 5, 5, 5, 5 },
	borderThickness = 1.5,
	borderColor = { 1.0, 1.0, 1.0, 0.6 },
	borderColor2 = { 0.0, 0.0, 0.0, 0.8 },
	backgroundColor = { 0.8, 0.8, 1.0, 0.4 },
	focusColor = { 0.2, 0.2, 1.0, 0.6 },

	autosize = false,
	savespace = true, --// iff autosize==true, it shrinks the control to the minimum needed space, if disabled autosize _normally_ only enlarges the control
	resizeGripSize = { 11, 11 },
	dragGripSize = { 10, 10 },

	dragUseGrip = false,
	draggable = false,
	resizable = false,
	tweakDragUseGrip = false,
	tweakDraggable = false,
	tweakResizable = false,

	minWidth = 10,
	minHeight = 10,
	maxWidth = 1e9,
	maxHeight = 1e9,

	fixedRatio = false,
	tooltip = nil, --// JUST TEXT

	font = {
		font = fontfile2,
		size = 14,
		shadow = false,
		outline = false,
		outlineWidth = 3,
		outlineWeight = 3,
		color = { 1, 1, 1, 1 },
		outlineColor = { 0, 0, 0, 1 },
		autoOutlineColor = true,
	},

	state = {
		focused = false,
		hovered = false,
		checked = false,
		selected = false, --FIXME implement
		pressed = false,
		enabled = true, --FIXME implement
	},

	skin = nil,
	skinName = nil,

	drawcontrolv2 = nil, --// disable backward support with old DrawControl gl state (with 2.1 self.xy translation isn't needed anymore)

	useRTT = ((gl.CreateFBO and gl.BlendFuncSeparate) ~= nil),
	useDLists = (gl.CreateList ~= nil) and false, --FIXME broken in combination with RTT (wrong blending)

	OnResize = {},
})

local this = Control
local inherited = this.inherited

--//=============================================================================

--- Creates a new Control instance.
-- Initializes the control, applies themes and skins, and sets up its children.
-- @tparam table obj Table containing properties to initialize the control.
-- @return Control The newly created control instance.
function Control:New(obj)
	--// backward compability
	BackwardCompa(obj)

	if obj.DrawControl then
		obj._hasCustomDrawControl = true
	end

	--// load the skin for this control
	obj.classname = self.classname
	theme.LoadThemeDefaults(obj)
	SkinHandler.LoadSkin(obj, self)

	--// we want to initialize the children ourself (see downwards)
	local cn = obj.children
	obj.children = nil

	obj = inherited.New(self, obj)

	if obj._hasCustomDrawControl then
		if not obj.drawcontrolv2 then
			local w = obj._widget or { whInfo = { name = "unknown" } }
			local fmtStr = [[You are using a custom %s::DrawControl in widget "%s".
	Please note that with Chili 2.1 the (self.x, self.y) translation is moved a level up and does not need to be done in DrawControl anymore.
	When you adjusted your code set `drawcontrolv2 = true` in the respective control to disable this message.]]
			Spring.Log("Chili", "warning", fmtStr:format(obj.name, w.whInfo.name))
		else
			obj._hasCustomDrawControl = false
		end
	end

	local p = obj.padding
	if obj.clientWidth then
		obj.width = obj.clientWidth + p[1] + p[3]
	end
	if obj.clientHeight then
		obj.height = obj.clientHeight + p[2] + p[4]
	end

	--// create font
	obj.font = Font:New(obj.font)
	obj.font:SetParent(obj)

	obj:DetectRelativeBounds()
	obj:AlignControl()

	--// add children after UpdateClientArea! (so relative width/height can be applied correctly)
	if cn then
		for i = 1, #cn do
			obj:AddChild(cn[i], true)
		end
	end

	return obj
end

--- Removes the control and cleans up resources.
-- Deletes associated display lists, textures, and frame buffer objects.
function Control:Dispose(...)
	gl.DeleteList(self._all_dlist)
	self._all_dlist = nil

	gl.DeleteList(self._children_dlist)
	self._children_dlist = nil

	gl.DeleteList(self._own_dlist)
	self._own_dlist = nil

	gl.DeleteTexture(self._tex_all)
	self._tex_all = nil
	gl.DeleteTexture(self._tex_children)
	self._tex_children = nil

	if gl.DeleteFBO then
		gl.DeleteRBO(self._stencil_all)
		self._stencil_all = nil
		gl.DeleteRBO(self._stencil_children)
		self._stencil_children = nil
		gl.DeleteFBO(self._fbo_all)
		self._fbo_all = nil
		gl.DeleteFBO(self._fbo_children)
		self._fbo_children = nil
	end

	inherited.Dispose(self, ...)
	self.font:SetParent()
end

--//=============================================================================

--- Sets the control's parent object.
-- Updates the control's alignment and layout based on the new parent.
-- @tparam object.Object obj The new parent object.
function Control:SetParent(obj)
	inherited.SetParent(self, obj)
	if obj then
		self:RequestRealign()
	end
end

--- Adds a child object to the control.
-- Updates the layout of the control to accommodate the new child.
-- @tparam object.Object obj The child object to add.
-- @param dontUpdate If true, the layout will not be updated immediately.
function Control:AddChild(obj, dontUpdate)
	inherited.AddChild(self, obj)
	if not dontUpdate then
		self:RequestRealign()
	end
end

--- Removes a child object from the control.
-- Updates the layout of the control after removing the child.
-- @tparam object.Object obj The child object to remove.
-- @return boolean True if the child was successfully removed, false otherwise.
function Control:RemoveChild(obj)
	local found = inherited.RemoveChild(self, obj)
	if found then
		self:RequestRealign()
	end
	return found
end

--//=============================================================================

--- Gets the maximum constraints for a child control.
-- @tparam Control child The child control to get constraints for.
-- @return number,number,number,number Returns minimum x, minimum y, maximum width, maximum height.
function Control:_GetMaxChildConstraints(child)
	return 0, 0, self.clientWidth, self.clientHeight
end

--- Detects and processes relative bounds for the control.
-- Processes coordinates and dimensions that are specified relative to the parent.
-- Sets up internal state for handling relative positioning.
function Control:DetectRelativeBounds()
	--// we need min 2 x-dim coords to define a rect!
	local numconstraints = 0
	if self.x then
		numconstraints = numconstraints + 1
	end
	if self.right then
		numconstraints = numconstraints + 1
	end
	if self.width then
		numconstraints = numconstraints + 1
	end
	if numconstraints < 2 then
		if numconstraints == 0 then
			self.x = 0
			self.width = self.defaultWidth or 0
		else
			if self.width then
				self.x = 0
			else
				self.width = self.defaultWidth or 0
			end
		end
	end

	--// we need min 2 y-dim coords to define a rect!
	numconstraints = 0
	if self.y then
		numconstraints = numconstraints + 1
	end
	if self.bottom then
		numconstraints = numconstraints + 1
	end
	if self.height then
		numconstraints = numconstraints + 1
	end
	if numconstraints < 2 then
		if numconstraints == 0 then
			self.y = 0
			self.height = self.defaultHeight or 0
		else
			if self.height then
				self.y = 0
			else
				self.height = self.defaultHeight or 0
			end
		end
	end

	--// check which constraints are relative
	self._givenBounds = {
		left = self.x,
		top = self.y,
		width = self.width,
		height = self.height,
		right = self.right,
		bottom = self.bottom,
	}
	local rb = {
		left = IsRelativeCoord(self.x) and self.x,
		top = IsRelativeCoord(self.y) and self.y,
		width = IsRelativeCoord(self.width) and self.width,
		height = IsRelativeCoord(self.height) and self.height,
		right = self.right,
		bottom = self.bottom,
	}
	self._relativeBounds = rb
	self._isRelative = (rb.left or rb.top or rb.width or rb.height or rb.right or rb.bottom) and true

	--// initialize relative constraints with 0
	self.x = ((not rb.left) and self.x) or 0
	self.y = ((not rb.top) and self.y) or 0
	self.width = ((not rb.width) and self.width) or 0
	self.height = ((not rb.height) and self.height) or 0
	--self.right  = (type(self.right)=='number')and(self.right>0)and(self.right) or 0
	--self.bottom = (type(self.bottom)=='number')and(self.bottom>0)and(self.bottom) or 0
end

--- Gets the relative box coordinates for the control.
-- Calculates the control's position and size relative to its parent.
-- @param savespace If true, uses minimum dimensions instead of actual dimensions.
-- @return table Returns {x, y, width, height} with calculated values.
function Control:GetRelativeBox(savespace)
	local t = { self.x, self.y, self.width, self.height }
	if savespace then
		t = { 0, 0, self.minWidth, self.minHeight }
	end

	if not self._isRelative then
		return t
	end

	local p = self.parent
	if not p then
		return t
	end

	--// FIXME use pl & pt too!!!
	local pl, pt, pw, ph = p:_GetMaxChildConstraints(self)

	local givBounds = self._givenBounds
	local relBounds = self._relativeBounds
	local left = self.x
	local top = self.y
	local width = (savespace and self.minWidth) or self.width
	local height = (savespace and self.minHeight) or self.height

	--// ProcessRelativeCoord is defined in util.lua
	if relBounds.left then
		left = ProcessRelativeCoord(relBounds.left, pw)
	end
	if relBounds.top then
		top = ProcessRelativeCoord(relBounds.top, ph)
	end
	if relBounds.width then
		width = ProcessRelativeCoord(relBounds.width, pw)
	end
	if relBounds.height then
		height = ProcessRelativeCoord(relBounds.height, ph)
	end

	if relBounds.right then
		if not givBounds.left then
			left = pw - width - ProcessRelativeCoord(relBounds.right, pw)
		else
			width = pw - left - ProcessRelativeCoord(relBounds.right, pw)
		end
	end
	if relBounds.bottom then
		if not givBounds.top then
			top = ph - height - ProcessRelativeCoord(relBounds.bottom, ph)
		else
			height = ph - top - ProcessRelativeCoord(relBounds.bottom, ph)
		end
	end

	return { left, top, width, height }
end

--- Updates the control's client area.
-- Recalculates the dimensions of the content area based on padding and size.
-- @bool dontRedraw If true, the control will not be redrawn immediately.
function Control:UpdateClientArea(dontRedraw)
	local padding = self.padding

	self.clientWidth = self.width - padding[1] - padding[3]
	self.clientHeight = self.height - padding[2] - padding[4]

	self.clientArea = {
		padding[1],
		padding[2],
		self.clientWidth,
		self.clientHeight,
	}

	if self.parent and (self.parent:InheritsFrom("control")) then
		--FIXME sometimes this makes self:RequestRealign() redundant! try to reduce the Align() calls somehow
		self.parent:RequestRealign()
	end
	if (self.width ~= self._oldwidth_uca) or (self.height ~= self._oldheight_uca) then
		self:RequestRealign()
		self._oldwidth_uca = self.width
		self._oldheight_uca = self.height
	end

	if not dontRedraw then
		self:Invalidate()
	end --FIXME only when RTT!
	self:CallListeners(self.OnResize) --FIXME more arguments and filter unchanged resizes
end

--- Aligns the control based on its relative bounds.
-- Updates the control's position and size to match its constraints.
function Control:AlignControl()
	local newBox = self:GetRelativeBox()
	self:_UpdateConstraints(newBox[1], newBox[2], newBox[3], newBox[4])
end

--- Requests a realignment of the control.
-- Marks the control for realignment during the next update cycle.
-- @bool savespace If true, the control will shrink to its minimum size.
function Control:RequestRealign(savespace)
	if not self._inRealign then
		self._realignRequested = true
		self.__savespace = savespace
		self:RequestUpdate()
	end
end

function Control:DisableRealign()
	self._realignDisabled = (self._realignDisabled or 0) + 1
end

function Control:EnableRealign()
	self._realignDisabled = ((self._realignDisabled or 0) > 1 and self._realignDisabled - 1) or nil
	if self._realignRequested then
		self:Realign()
		self._realignRequested = nil
	end
end

function Control:Realign(savespace)
	if not self._realignDisabled then
		if not self._inRealign then
			self._savespace = savespace or self.savespace
			self._inRealign = true
			self:AlignControl() --FIXME still needed?
			local childrenAligned = self:UpdateLayout()
			self._realignRequested = nil
			if not childrenAligned then
				self:RealignChildren()
			end
			self._inRealign = nil
			self._savespace = nil
		end
	else
		self:RequestRealign(savespace)
	end
end

function Control:UpdateLayout()
	if self.autosize then
		self:RealignChildren(true)

		local neededWidth, neededHeight = self:GetChildrenMinimumExtents()

		local relativeBox = self:GetRelativeBox(self._savespace or self.savespace)
		neededWidth = math.max(relativeBox[3], neededWidth)
		neededHeight = math.max(relativeBox[4], neededHeight)

		neededWidth = neededWidth - self.padding[1] - self.padding[3]
		neededHeight = neededHeight - self.padding[2] - self.padding[4]

		if self.debug then
			local cminextW, cminextH = self:GetChildrenMinimumExtents()
			Spring.Echo(
				"Control:UpdateLayout",
				self.name,
				"GetChildrenMinimumExtents",
				cminextW,
				cminextH,
				"GetRelativeBox",
				relativeBox[3],
				relativeBox[4],
				"savespace",
				self._savespace
			)
		end

		self:Resize(neededWidth, neededHeight, true, true)
		self:RealignChildren()
		self:AlignControl() --FIXME done twice!!! (1st in Realign)
		return true
	end
end

function Control:RealignChildren(savespace)
	self:CallChildren("Realign", savespace)
end

--- Gets the minimum extents needed for the control.
-- Calculates the minimum space needed for this control and its children.
-- @return number,number Returns the maximum right and bottom coordinates needed.
function Control:GetMinimumExtents()
	local maxRight, maxBottom = 0, 0
	if self.autosize then
		--// FIXME handle me correctly!!! (:= do the parent offset)
		maxRight, maxBottom = self:GetChildrenMinimumExtents()
	end

	if not self._isRelative then
		local right = self.x + self.width
		local bottom = self.y + self.height

		maxRight = math.max(maxRight, right)
		maxBottom = math.max(maxBottom, bottom)
	else
		local cgb = self._givenBounds
		local crb = self._relativeBounds

		local left, width, right = 0, 0, 0
		if not crb.width then
			if self.autosize then
				width = self.width or 0
			else
				width = cgb.width or 0
			end
		end
		if not crb.left then
			left = cgb.left or 0
		end
		if not IsRelativeCoord(crb.right) then
			right = crb.right or 0
		end
		local totalWidth = left + width + right

		local top, height, bottom = 0, 0, 0
		if not crb.height then
			height = cgb.height or 0
		end
		if not crb.top then
			top = cgb.top or 0
		end
		if not IsRelativeCoord(crb.bottom) then
			bottomt = crb.bottom or 0
		end
		local totalHeight = top + height + bottom

		--[[
    if (crb.width) then width = cgb.width or 0 end
    if (crb.left)  then left  = cgb.left or 0 end
    if (IsRelativeCoord(cgb.right)) then right = cgb.right or 0 end

    ...
--]]

		totalWidth = math.max(totalWidth, self.minWidth)
		totalHeight = math.max(totalHeight, self.minHeight)

		totalWidth = math.min(totalWidth, self.maxWidth)
		totalHeight = math.min(totalHeight, self.maxHeight)

		maxRight = math.max(maxRight, totalWidth)
		maxBottom = math.max(maxBottom, totalHeight)
	end

	return maxRight, maxBottom
end

--- Gets the minimum extents needed for all children.
-- Calculates the minimum space needed to contain all child controls.
-- @return number,number Returns the minimum width and height needed.
function Control:GetChildrenMinimumExtents()
	local minWidth = 0
	local minHeight = 0

	local cn = self.children
	for i = 1, #cn do
		local c = cn[i]
		if c.GetMinimumExtents then
			local width, height = c:GetMinimumExtents()
			minWidth = math.max(minWidth, width)
			minHeight = math.max(minHeight, height)
		end
	end

	if minWidth + minHeight > 0 then
		local padding = self.padding
		minWidth = minWidth + padding[1] + padding[3]
		minHeight = minHeight + padding[2] + padding[4]
	end

	return minWidth, minHeight
end

--- Gets the current extents of the control.
-- Calculates the actual space currently occupied by this control and its children.
-- @return number,number,number,number Returns minLeft, minTop, maxRight, maxBottom coordinates.
function Control:GetCurrentExtents()
	local minLeft, minTop, maxRight, maxBottom = self:GetChildrenCurrentExtents()

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

--- Gets the current extents of all children.
-- Calculates the actual space currently occupied by child controls.
-- @return number,number,number,number Returns minLeft, minTop, maxRight, maxBottom coordinates.
function Control:GetChildrenCurrentExtents()
	local minLeft = 0
	local minTop = 0
	local maxRight = 0
	local maxBottom = 0

	local cn = self.children
	for i = 1, #cn do
		local c = cn[i]
		if c.GetCurrentExtents then
			local left, top, right, bottom = c:GetCurrentExtents()
			minLeft = math.min(minLeft, left)
			minTop = math.min(minTop, top)
			maxRight = math.max(maxRight, right)
			maxBottom = math.max(maxBottom, bottom)
		end
	end

	return minLeft, minTop, maxRight, maxBottom
end

--- Sets the control's position and size.
-- Updates the control's bounds and optionally adjusts its client area.
-- @int x X-coordinate of the control.
-- @int y Y-coordinate of the control.
-- @int w Width of the control.
-- @int h Height of the control.
-- @param clientArea If true, the dimensions include the client area.
-- @bool dontUpdateRelative If true, relative constraints will not be updated.
function Control:SetPos(x, y, w, h, clientArea, dontUpdateRelative)
	local changed = false
	local redraw = false

	--//FIXME add an API for relative constraints changes
	if x and (type(x) == "number") then
		if self.x ~= x then
			self.x = x
			changed = true
		end
		if not dontUpdateRelative then
			if self._relativeBounds.left ~= x then
				self._relativeBounds.left = false
				self._givenBounds.left = x
				self._relativeBounds.right = false
				self._givenBounds.right = false
				changed = true
			end
		end
	end

	if y and (type(y) == "number") then
		if self.y ~= y then
			self.y = y
			changed = true
		end
		if not dontUpdateRelative then
			if self._relativeBounds.top ~= y then
				self._relativeBounds.top = false
				self._givenBounds.top = y
				self._relativeBounds.bottom = false
				self._givenBounds.bottom = false
				changed = true
			end
		end
	end

	if w and (type(w) == "number") then
		w = clientArea and (w + self.padding[1] + self.padding[3]) or w
		w = math.max(w, self.minWidth)
		w = math.min(w, self.maxWidth)
		if self.width ~= w then
			self.width = w
			changed = true
			redraw = true
		end
		if not dontUpdateRelative then
			if self._relativeBounds.width ~= w then
				self._relativeBounds.width = IsRelativeCoord(w) and w
				self._givenBounds.width = w
				changed = true
				redraw = true
			end
		end
	end

	if h and (type(h) == "number") then
		h = clientArea and (h + self.padding[2] + self.padding[4]) or h
		h = math.max(h, self.minHeight)
		h = math.min(h, self.maxHeight)
		if self.height ~= h then
			self.height = h
			changed = true
			redraw = true
		end
		if not dontUpdateRelative then
			if self._relativeBounds.height ~= h then
				self._relativeBounds.height = IsRelativeCoord(h) and h
				self._givenBounds.height = h
				changed = true
				redraw = true
			end
		end
	end

	if changed or not self.clientArea then
		self:UpdateClientArea(not redraw)
	end
end

--- Sets the control's relative position
-- @int x x-coordinate
-- @int y y-coordinate
-- @int w width
-- @int h height
-- @param clientArea TODO
-- @bool dontUpdateRelative TODO
function Control:SetPosRelative(x, y, w, h, clientArea, dontUpdateRelative)
	local changed = false
	local redraw = false

	--//FIXME add an API for relative constraints changes
	if x then
		if not IsRelativeCoord(x) then
			if self.x ~= x then
				self.x = x
				changed = true
			end
		end
		if not dontUpdateRelative then
			if self._relativeBounds.left ~= x then
				self._relativeBounds.left = IsRelativeCoord(x) and x
				self._givenBounds.left = x
				changed = true
			end
		end
	end

	if y then
		if not IsRelativeCoord(y) then
			if self.y ~= y then
				self.y = y
				changed = true
			end
		end
		if not dontUpdateRelative then
			if self._relativeBounds.top ~= y then
				self._relativeBounds.top = IsRelativeCoord(y) and y
				self._givenBounds.top = y
				changed = true
			end
		end
	end

	if w then
		if not IsRelativeCoord(w) then
			w = clientArea and (w + self.padding[1] + self.padding[3]) or w
			w = math.max(w, self.minWidth)
			w = math.min(w, self.maxWidth)
			if self.width ~= w then
				self.width = w
				changed = true
				redraw = true
			end
		end
		if not dontUpdateRelative then
			if self._relativeBounds.width ~= w then
				self._relativeBounds.width = IsRelativeCoord(w) and w
				self._givenBounds.width = w
				changed = true
				redraw = true
			end
		end
	end

	if h then
		if not IsRelativeCoord(h) then
			h = clientArea and (h + self.padding[2] + self.padding[4]) or h
			h = math.max(h, self.minHeight)
			h = math.min(h, self.maxHeight)
			if self.height ~= h then
				self.height = h
				changed = true
				redraw = true
			end
		end
		if not dontUpdateRelative then
			if self._relativeBounds.height ~= h then
				self._relativeBounds.height = IsRelativeCoord(h) and h
				self._givenBounds.height = h
				changed = true
				redraw = true
			end
		end
	end

	if changed or not self.clientArea then
		self:UpdateClientArea(not redraw)
	end
end

--- Resize the control
-- @int w width
-- @int h height
-- @param clientArea TODO
-- @bool dontUpdateRelative TODO
function Control:Resize(w, h, clientArea, dontUpdateRelative)
	self:SetPosRelative(nil, nil, w, h, clientArea, dontUpdateRelative)
end

--- Updates internal constraints based on new position and size.
-- Internal method used to update the control's position and size constraints.
-- @number x New X-coordinate.
-- @number y New Y-coordinate.
-- @number w New width.
-- @number h New height.
function Control:_UpdateConstraints(x, y, w, h)
	--// internal used
	self:SetPos(x, y, w, h, false, true)
end

function Control:StartResizing(x, y)
	--//FIXME the x,y aren't needed check how drag is handled!
	self.resizing = {
		mouse = { x, y },
		size = { self.width, self.height },
		pos = { self.x, self.y },
	}
end

function Control:StopResizing(x, y)
	self.resizing = false
end

function Control:StartDragging(x, y)
	self.dragging = true
end

function Control:StopDragging(x, y)
	self.dragging = false
end

--- Converts local coordinates to client area coordinates.
-- @number x X-coordinate in local space.
-- @number y Y-coordinate in local space.
-- @return number,number Returns coordinates relative to client area.
function Control:LocalToClient(x, y)
	local ca = self.clientArea
	return x - ca[1], y - ca[2]
end

--- Converts client area coordinates to local coordinates.
-- @number x X-coordinate in client area.
-- @number y Y-coordinate in client area.
-- @return number,number Returns coordinates relative to control.
function Control:ClientToLocal(x, y)
	local ca = self.clientArea
	return x + ca[1], y + ca[2]
end

--- Converts parent coordinates to client area coordinates.
-- @number x X-coordinate in parent space.
-- @number y Y-coordinate in parent space.
-- @return number,number Returns coordinates relative to client area.
function Control:ParentToClient(x, y)
	local ca = self.clientArea
	return x - self.x - ca[1], y - self.y - ca[2]
end

--- Converts client area coordinates to parent coordinates.
-- @number x X-coordinate in client area.
-- @number y Y-coordinate in client area.
-- @return number,number Returns coordinates relative to parent.
function Control:ClientToParent(x, y)
	local ca = self.clientArea
	return x + self.x + ca[1], y + self.y + ca[2]
end

--- Checks if coordinates are within the client area.
-- @number x X-coordinate to check.
-- @number y Y-coordinate to check.
-- @return boolean Returns true if the point is in the client area.
function Control:InClientArea(x, y)
	local clientArea = self.clientArea
	return x >= clientArea[1]
		and y >= clientArea[2]
		and x <= clientArea[1] + clientArea[3]
		and y <= clientArea[2] + clientArea[4]
end

--- Requests a redraw of the control.
-- Marks the control for redrawing during the next update cycle.
function Control:Invalidate()
	self._needRedraw = true
	self._needRedrawSelf = nil
	self:RequestUpdate()
end

--- Requests a redraw of the control.
function Control:InvalidateSelf()
	self._needRedraw = true
	self._needRedrawSelf = true
	self:RequestUpdate()
end

function Control:InstantUpdate()
	if self:IsInView() then
		if self._needRedraw then
			self:Update()
		else
			self._in_update = true
			self:_UpdateChildrenDList()
			self:_UpdateAllDList()
			self._in_update = false
		end
	end
end

function Control:Update()
	if self._realignRequested then
		self:Realign(self.__savespace)
		self._realignRequested = false
	end

	if self._needRedraw then
		if self:IsInView() then
			self._in_update = true
			self:_UpdateOwnDList()
			if not self._needRedrawSelf then
				self:_UpdateChildrenDList()
			end
			self:_UpdateAllDList()
			self._in_update = false

			self._needRedraw = false
			self._needRedrawSelf = false
			self._redrawSelfCounter = (self._redrawSelfCounter or 0) + 1
		end
	end
end

function Control:_CheckIfRTTisAppreciated()
	if (self.width <= 0) or (self.height <= 0) then
		return false
	end

	if self._cantUseRTT or not self.useRTT then
		return false
	end

	if self:InheritsFrom("window") then
		if self._usingRTT then
			return (((self._redrawSelfCounter or 1) / (self._redrawCounter or 1)) < 0.2)
		else
			return (((self._redrawSelfCounter or 1) / (self._redrawCounter or 1)) < 0.1)
		end
	else
		if (self._redrawCounter or 0) > 300 then
			return (((self._redrawSelfCounter or 1) / (self._redrawCounter or 1)) < 0.03)
		end
	end
end

function Control:_UpdateOwnDList()
	if not self.parent then
		return
	end
	if not self:IsInView() then
		return
	end
	if not self.useDLists then
		return
	end

	gl.DeleteList(self._own_dlist)
	self._own_dlist = gl.CreateList(self.DrawControl, self)
end

function Control:_UpdateChildrenDList()
	if not self.parent then
		return
	end
	if not self:IsInView() then
		return
	end

	if self:InheritsFrom("scrollpanel") and not self._cantUseRTT then
		local contentX, contentY, contentWidth, contentHeight = unpack4(self.contentArea)
		if (contentWidth <= 0) or (contentHeight <= 0) then
			return
		end
		self:CreateViewTexture("children", contentWidth, contentHeight, self.DrawChildrenForList, self, true)
	end

	--FIXME
	--if self.useDLists then
	--	self._children_dlist = gl.CreateList(self.DrawChildrenForList, self, true)
	--end
end

function Control:_UpdateAllDList()
	if not self.parent then
		return
	end
	if not self:IsInView() then
		return
	end

	local RTT = self:_CheckIfRTTisAppreciated()

	gl.DeleteList(self._all_dlist)

	if RTT then
		self._usingRTT = true
		self:CreateViewTexture("all", self.width, self.height, self.DrawForList, self)
	else
		local suffix_name = "all"
		local texname = "_tex_" .. suffix_name
		local texStencilName = "_stencil_" .. suffix_name
		local fboName = "_fbo_" .. suffix_name
		local texw = "_texw_" .. suffix_name
		local texh = "_texh_" .. suffix_name
		if gl.DeleteFBO then
			gl.DeleteFBO(self[fboName])
			gl.DeleteTexture(self[texname])
			gl.DeleteRBO(self[texStencilName])
		end
		self[texStencilName] = nil
		self[texname] = nil
		self[fboName] = nil
		self[texw] = nil
		self[texh] = nil
		self._usingRTT = false

		--FIXME
		--if self.useDLists then
		--	self._all_dlist = gl.CreateList(self.DrawForList,self)
		--end
	end

	if self.parent and not self.parent._needRedraw and self.parent._UpdateAllDList then
		TaskHandler.RequestInstantUpdate(self.parent)
	end
end

--- Sets up render-to-texture for the control.
-- Internal method to configure RTT rendering state.
-- @param fnc The function to call for rendering.
-- @param self_ The control instance.
-- @param drawInContentRect Whether to draw in content rect space.
-- @param ... Additional arguments for the render function.
function Control:_SetupRTT(fnc, self_, drawInContentRect, ...)
	gl.Clear(GL.COLOR_BUFFER_BIT, 0, 0, 0, 1)
	gl.Clear(GL.STENCIL_BUFFER_BIT, 0)

	--// no need to push/pop cause gl.ActiveFBO already does so
	gl.MatrixMode(GL.MODELVIEW)
	gl.Translate(-1, 1, 0)
	if not drawInContentRect then
		gl.Scale(2 / self.width, -2 / self.height, 1)
		gl.Translate(-self.x, -self.y, 0)
	else
		local clientX, clientY, clientWidth, clientHeight = unpack4(self.clientArea)
		local contentX, contentY, contentWidth, contentHeight = unpack4(self.contentArea)
		gl.Scale(2 / contentWidth, -2 / contentHeight, 1)
		gl.Translate(-(clientX - self.scrollPosX), -(clientY - self.scrollPosY), 0)
	end

	gl.Color(1, 1, 1, 1)
	gl.AlphaTest(false)
	gl.StencilTest(true)
	gl.StencilFunc(GL.EQUAL, 0, 0xFF)
	gl.StencilOp(GL.KEEP, GL.KEEP, GL.KEEP)

	gl.BlendFuncSeparate(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE_MINUS_SRC_ALPHA)
	fnc(self_, ...)
	--[[
		--//Render a red quad to indicate that RTT is used for the respective control
		gl.Color(1,0,0,0.5)
		if not drawInContentRect then
			gl.Rect(self.x,self.y,self.x+50,self.y+50)
		else
			gl.Rect(0,0,50,50)
		end
		gl.Color(1,1,1,1)
--]]
	gl.Blending("reset")

	gl.StencilTest(false)
end

local staticRttTextureParams = {
	min_filter = GL.NEAREST,
	mag_filter = GL.NEAREST,
	wrap_s = GL.CLAMP,
	wrap_t = GL.CLAMP,
	border = false,
}
local staticDepthStencilTarget = {
	format = GL_DEPTH24_STENCIL8,
}

--- Creates a texture from the control's view.
-- @string suffix_name Suffix for the texture name.
-- @number width Width of the texture.
-- @number height Height of the texture.
-- @param fnc Function to render the content.
-- @param ... Additional arguments for the render function.
function Control:CreateViewTexture(suffix_name, width, height, fnc, ...)
	if not gl.CreateFBO or not gl.BlendFuncSeparate then
		self._cantUseRTT = true
		self._usingRTT = false
		return
	end

	local texname = "_tex_" .. suffix_name
	local texw = "_texw_" .. suffix_name
	local texh = "_texh_" .. suffix_name
	local texStencilName = "_stencil_" .. suffix_name
	local fboName = "_fbo_" .. suffix_name

	local fbo = self[fboName] or gl.CreateFBO()
	local texColor = self[texname]
	local texStencil = self[texStencilName]

	if (width ~= self[texw]) or (height ~= self[texh]) then
		self[texw] = width
		self[texh] = height
		fbo.color0 = nil
		fbo.stencil = nil
		gl.DeleteTexture(texColor)
		gl.DeleteRBO(texStencil)

		texColor = gl.CreateTexture(width, height, staticRttTextureParams)
		texStencil = gl.CreateRBO(width, height, staticDepthStencilTarget)

		fbo.color0 = texColor
		fbo.stencil = texStencil
	end

	if (not (fbo and texColor and texStencil)) or (not gl.IsValidFBO(fbo)) then
		gl.DeleteFBO(fbo)
		gl.DeleteTexture(texColor)
		gl.DeleteRBO(texStencil)
		self[texw] = nil
		self[texh] = nil
		self[texStencilName] = nil
		self[texname] = nil
		self[fboName] = nil
		self._cantUseRTT = true
		self._usingRTT = false
		return
	end

	EnterRTT()
	self._inrtt = true
	gl.ActiveFBO(fbo, true, Control._SetupRTT, self, fnc, ...)
	self._inrtt = false
	LeaveRTT()

	self[texname] = texColor
	self[texStencilName] = texStencil
	self[fboName] = fbo
end

--- Draws content within the client area.
-- @param fnc The function to call for drawing.
-- @param ... Additional arguments for the draw function.
function Control:_DrawInClientArea(fnc, ...)
	local clientX, clientY, clientWidth, clientHeight = unpack4(self.clientArea)

	gl.PushMatrix()
	gl.Translate(clientX, clientY, 0)

	local sx, sy = self:LocalToScreen(clientX, clientY)
	sy = select(2, gl.GetViewSizes()) - (sy + clientHeight)

	if PushLimitRenderRegion(self, sx, sy, clientWidth, clientHeight) then
		fnc(...)
		PopLimitRenderRegion(self, sx, sy, clientWidth, clientHeight)
	end

	gl.PopMatrix()
end

--- Checks if the control is currently visible in the view.
-- @return boolean Returns true if the control is in view.
function Control:IsInView()
	if UnlinkSafe(self.parent) then
		return self.parent:IsRectInView(self.x, self.y, self.width, self.height)
	end
	return false
end

--- Checks if a child control is visible in the view.
-- @tparam Control child The child control to check.
-- @return boolean Returns true if the child is in view.
function Control:IsChildInView(child)
	return self:IsRectInView(child.x, child.y, child.width, child.height)
end

--- Checks if a rectangle is visible in the view.
-- @number x X-coordinate of the rectangle.
-- @number y Y-coordinate of the rectangle.
-- @number w Width of the rectangle.
-- @number h Height of the rectangle.
-- @return boolean Returns true if the rectangle is in view.
function Control:IsRectInView(x, y, w, h)
	if not self.parent then
		return false
	end

	local rect1 = { x, y, w, h }
	local rect2 = { 0, 0, self.clientArea[3], self.clientArea[4] }
	local inview = AreRectsOverlapping(rect1, rect2)

	if not inview then
		return false
	end

	local px, py = self:ClientToParent(x, y)
	return (self.parent):IsRectInView(px, py, w, h)
end

--- Draws children within the client area with view checking.
-- @param event The drawing event to pass to children.
function Control:_DrawChildrenInClientArea(event)
	self:_DrawInClientArea(self.CallChildrenInverseCheckFunc, self, self.IsChildInView, event or "Draw")
end

--- Draws children within the client area without view checking.
-- @param event The drawing event to pass to children.
function Control:_DrawChildrenInClientAreaWithoutViewCheck(event)
	self:_DrawInClientArea(self.CallChildrenInverse, self, event or "Draw")
end

--- Draws the control's background.
-- This method is intended to be overridden by themes or skins.
function Control:DrawBackground()
	--// gets overriden by the skin/theme
end

function Control:DrawDragGrip()
	--// gets overriden by the skin/theme
end

function Control:DrawResizeGrip()
	--// gets overriden by the skin/theme
end

--- Draws the control's border.
-- This method is intended to be overridden by themes or skins.
function Control:DrawBorder()
	--// gets overriden by the skin/theme ??????
end

--- Draws UI grips for dragging and resizing.
-- Renders visual indicators for drag and resize handles when appropriate.
function Control:DrawGrips() -- FIXME this thing is a hack, fix it - todo ideally make grips appear only when mouse hovering over it
	local drawResizeGrip = self.resizable
	local drawDragGrip = self.draggable and self.dragUseGrip
	--[[if IsTweakMode() then
	drawResizeGrip = drawResizeGrip or self.tweakResizable
	drawDragGrip   = (self.tweakDraggable and self.tweakDragUseGrip)
	end--]]

	if drawResizeGrip then
		self:DrawResizeGrip()
	end
	if drawDragGrip then
		self:DrawDragGrip()
	end
end

function Control:DrawControl()
	self:DrawBackground()
	self:DrawBorder()
end

function Control:DrawForList()
	self._redrawCounter = (self._redrawCounter or 0) + 1
	if not self._in_update and not self._usingRTT and self:_CheckIfRTTisAppreciated() then
		self:InvalidateSelf()
	end

	if self._tex_all and not self._inrtt then
		gl.PushMatrix()
		gl.Translate(self.x, self.y, 0)
		gl.BlendFuncSeparate(GL.ONE, GL.SRC_ALPHA, GL.ZERO, GL.SRC_ALPHA)
		gl.Color(1, 1, 1, 1)
		gl.Texture(0, self._tex_all)
		gl.TexRect(0, 0, self.width, self.height)
		gl.Texture(0, false)
		gl.BlendFuncSeparate(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE_MINUS_SRC_ALPHA)
		gl.PopMatrix()
		return
	elseif self._all_dlist then
		gl.PushMatrix()
		gl.Translate(self.x, self.y, 0)
		gl.CallList(self._all_dlist)
		gl.PopMatrix()
		return
	end

	gl.PushMatrix()
	gl.Translate(self.x, self.y, 0)

	if self._own_dlist then
		gl.CallList(self._own_dlist)
	else
		if self._hasCustomDrawControl then
			gl.Translate(-self.x, -self.y, 0)
			self:DrawControl()
			gl.Translate(self.x, self.y, 0)
		else
			self:DrawControl()
		end
	end

	local clientX, clientY, clientWidth, clientHeight = unpack4(self.clientArea)
	if (clientWidth > 0) and (clientHeight > 0) then
		if self._tex_children then
			gl.BlendFuncSeparate(GL.ONE, GL.SRC_ALPHA, GL.ZERO, GL.SRC_ALPHA)
			gl.Color(1, 1, 1, 1)
			gl.Texture(0, self._tex_children)
			local contX, contY, contWidth, contHeight = unpack4(self.contentArea)

			local s = self.scrollPosX / contWidth
			local t = 1 - self.scrollPosY / contHeight
			local u = s + clientWidth / contWidth
			local v = t - clientHeight / contHeight
			gl.TexRect(clientX, clientY, clientX + clientWidth, clientY + clientHeight, s, t, u, v)
			gl.Texture(0, false)
			gl.BlendFuncSeparate(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE_MINUS_SRC_ALPHA)
		elseif self._children_dlist then
			self:_DrawInClientArea(gl.CallList, self._children_dlist)
		else
			self:DrawChildrenForList()
		end

		if self.DrawControlPostChildren then
			self:DrawControlPostChildren()
		end
	end

	self:DrawGrips()
	gl.PopMatrix()
end

--- Draws the control.
-- Renders the control's background, border, and children.
function Control:Draw()
	self._redrawCounter = (self._redrawCounter or 0) + 1
	if not self._in_update and not self._usingRTT and self:_CheckIfRTTisAppreciated() then
		self:InvalidateSelf()
	end

	if self._tex_all then
		gl.PushMatrix()
		gl.Translate(self.x, self.y, 0)
		gl.BlendFunc(GL.ONE, GL.SRC_ALPHA)
		gl.Color(1, 1, 1, 1)
		gl.Texture(0, self._tex_all)
		gl.TexRect(0, 0, self.width, self.height)
		gl.Texture(0, false)
		gl.Blending("reset")
		gl.PopMatrix()
		return
	elseif self._all_dlist then
		gl.PushMatrix()
		gl.Translate(self.x, self.y, 0)
		gl.CallList(self._all_dlist)
		gl.PopMatrix()
		return
	end

	gl.PushMatrix()
	gl.Translate(self.x, self.y, 0)

	if self._own_dlist then
		gl.CallList(self._own_dlist)
	else
		if self._hasCustomDrawControl then
			gl.Translate(-self.x, -self.y, 0)
			self:DrawControl()
			gl.Translate(self.x, self.y, 0)
		else
			self:DrawControl()
		end
	end

	if self._children_dlist then
		self:_DrawInClientArea(gl.CallList, self._children_dlist)
	else
		self:DrawChildren()
	end

	if self.DrawControlPostChildren then
		self:DrawControlPostChildren()
	end

	self:DrawGrips()
	gl.PopMatrix()
end

--- Handles tweak mode drawing.
-- Special drawing mode for UI editing/tweaking.
function Control:TweakDraw()
	if next(self.children) then
		self:_DrawChildrenInClientArea("TweakDraw")
	end
end

function Control:DrawChildren()
	if next(self.children) then
		self:_DrawChildrenInClientArea("Draw")
	end
end

function Control:DrawChildrenForList()
	if next(self.children) then
		self:_DrawChildrenInClientAreaWithoutViewCheck("DrawForList")
	end
end

local function InLocalRect(cx, cy, w, h)
	return (cx >= 0) and (cy >= 0) and (cx <= w) and (cy <= h)
end

function Control:HitTest(x, y)
	if not self.disableChildrenHitTest then
		if self:InClientArea(x, y) then
			local cax, cay = self:LocalToClient(x, y)
			local children = self.children
			for i = 1, #children do
				local c = children[i]
				if c then
					local cx, cy = c:ParentToLocal(cax, cay)
					if InLocalRect(cx, cy, c.width, c.height) then
						local obj = c:HitTest(cx, cy)
						if obj then
							return obj
						end
					end
				end
			end
		end
	end

	if self.NCHitTest then
		local nchit = self:NCHitTest(x, y)
		if nchit then
			return nchit
		end
	end

	if
		self.tooltip
		or (#self.OnMouseDown > 0)
		or (#self.OnMouseUp > 0)
		or (#self.OnClick > 0)
		or (#self.OnDblClick > 0)
		or (#self.OnMouseMove > 0)
		or (#self.OnMouseWheel > 0)
	then
		return self
	end

	return false
end

--- Handles mouse down events.
-- Processes interactions with the control and its children.
-- @number x X-coordinate of the mouse event.
-- @number y Y-coordinate of the mouse event.
-- @param ... Additional arguments for the event.
-- @return object.Object The object that handled the event, or nil if unhandled.
function Control:MouseDown(x, y, ...)
	if self.NCMouseDown then
		local result = self:NCMouseDown(x, y)
		if result then
			return result
		end
	end

	if not self.disableChildrenHitTest then
		if self:InClientArea(x, y) then
			local cx, cy = self:LocalToClient(x, y)
			local obj = inherited.MouseDown(self, cx, cy, ...)
			if obj then
				return obj
			end
		end
	end

	if self.NCMouseDownPostChildren then
		local result = self:NCMouseDownPostChildren(x, y)
		if result then
			return result
		end
	end
end

--- Handles mouse move events.
-- Updates the control's position or size if it is being dragged or resized.
-- @number x Current X-coordinate of the mouse.
-- @number y Current Y-coordinate of the mouse.
-- @number dx Change in X-coordinate since the last event.
-- @number dy Change in Y-coordinate since the last event.
-- @param ... Additional arguments for the event.
-- @return object.Object The object that handled the event, or nil if unhandled.
function Control:MouseMove(x, y, dx, dy, ...)
	if self.dragging then
		self:SetPos(self.x + dx, self.y + dy)
		return self
	elseif self.resizing then
		local oldState = self.resizing
		local deltaMousePosX = x - oldState.mouse[1]
		local deltaMousePosY = y - oldState.mouse[2]

		local w = math.max(self.minWidth, oldState.size[1] + deltaMousePosX)
		local h = math.max(self.minHeight, oldState.size[2] + deltaMousePosY)

		if self.fixedRatio == true then
			local ratioyx = self.height / self.width
			local ratioxy = self.width / self.height
			local oldSize = oldState.size
			local oldxy = oldSize[1] / oldSize[2]
			local oldyx = oldSize[2] / oldSize[1]
			if ratioxy - oldxy < ratioyx - oldyx then
				w = h * oldxy
			else
				h = w * oldyx
			end
		end

		-- fixes resizing components that have a right or bottom bound
		if self._relativeBounds.right ~= nil and type(self._relativeBounds.right) == "number" then
			local deltaW = w - self.width
			self._relativeBounds.right = self._relativeBounds.right - deltaW
			if self._relativeBounds.right < 0 then
				w = w + self._relativeBounds.right
				self._relativeBounds.right = 0
			end
		end
		if self._relativeBounds.bottom ~= nil and type(self._relativeBounds.bottom) == "number" then
			local deltaH = h - self.height
			self._relativeBounds.bottom = self._relativeBounds.bottom - deltaH
			if self._relativeBounds.bottom < 0 then
				h = h + self._relativeBounds.bottom
				self._relativeBounds.bottom = 0
			end
		end
		self:SetPos(nil, nil, w, h)
		return self
	end

	local cx, cy = self:LocalToClient(x, y)
	return inherited.MouseMove(self, cx, cy, dx, dy, ...)
end

--- Handles mouse up events.
-- Finalizes dragging or resizing operations.
-- @number x X-coordinate of the mouse event.
-- @number y Y-coordinate of the mouse event.
-- @param ... Additional arguments for the event.
-- @return object.Object The object that handled the event, or nil if unhandled.
function Control:MouseUp(x, y, ...)
	self.resizing = nil
	self.dragging = nil
	local cx, cy = self:LocalToClient(x, y)
	return inherited.MouseUp(self, cx, cy, ...)
end

--- Handles mouse click events.
-- @number x X-coordinate of the mouse event.
-- @number y Y-coordinate of the mouse event.
-- @param ... Additional arguments for the event.
-- @return object.Object The object that handled the event, or nil if unhandled.
function Control:MouseClick(x, y, ...)
	local cx, cy = self:LocalToClient(x, y)
	return inherited.MouseClick(self, cx, cy, ...)
end

--- Handles mouse double-click events.
-- @number x X-coordinate of the mouse event.
-- @number y Y-coordinate of the mouse event.
-- @param ... Additional arguments for the event.
-- @return object.Object The object that handled the event, or nil if unhandled.
function Control:MouseDblClick(x, y, ...)
	local cx, cy = self:LocalToClient(x, y)
	return inherited.MouseDblClick(self, cx, cy, ...)
end

--- Handles mouse wheel events.
-- @number x X-coordinate of the mouse event.
-- @number y Y-coordinate of the mouse event.
-- @param ... Additional arguments for the event.
-- @return object.Object The object that handled the event, or nil if unhandled.
function Control:MouseWheel(x, y, ...)
	local cx, cy = self:LocalToClient(x, y)
	return inherited.MouseWheel(self, cx, cy, ...)
end

--[[

function Control:KeyPress(...)
  return inherited.KeyPress(self, ...)
end

function Control:TextInput(...)
  return inherited.TextInput(self, ...)
end

--]]

--- Updates focus state of the control.
-- @param ... Additional arguments for focus update.
-- @return any Return value from inherited focus update.
function Control:FocusUpdate(...)
	self:InvalidateSelf()
	return inherited.FocusUpdate(self, ...)
end

--- Handles mouse over events.
-- Updates hover state and triggers visual update.
-- @param ... Additional arguments for the event.
function Control:MouseOver(...)
	inherited.MouseOver(self, ...)
	self.state.hovered = true
	self:InvalidateSelf()
end

--- Handles mouse out events.
-- Updates hover state and triggers visual update.
-- @param ... Additional arguments for the event.
function Control:MouseOut(...)
	inherited.MouseOut(self, ...)
	self.state.hovered = false
	self:InvalidateSelf()
end

--//=============================================================================
