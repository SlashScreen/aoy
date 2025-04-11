--- Window module
--- A container control that provides window functionality like dragging, resizing and minimizing.
---@class Window
---@field draggable boolean Window can be dragged
---@field resizable boolean Window can be resized
---@field minimizable boolean Window can be minimized
---@field minWidth number Minimum window width
---@field minHeight number Minimum window height
---@field titleBarHeight number Height of the title bar
---@field titleBarColor Color Title bar color
---@field caption string Window title text
---@field minimized boolean Current minimized state
---@field OnMove function[] Window move event listeners
---@field OnResize function[] Window resize event listeners
---@field OnMinimize function[] Window minimize event listeners

Window = Control:Inherit({
	classname = "window",
	draggable = true,
	resizable = true,
	minimizable = true,

	minWidth = 50,
	minHeight = 50,

	titleBarHeight = 20,
	titleBarColor = { 0.3, 0.3, 0.3, 0.9 },

	caption = "",
	minimized = false,

	OnMove = {},
	OnResize = {},
	OnMinimize = {},
})

local this = Window
local inherited = this.inherited

--- Creates a new Window instance
-- @function Window:New
-- @param obj Table of window properties
-- @return Window The newly created window
function Window:New(obj)
	obj = inherited.New(self, obj)

	-- Create title bar
	if obj.caption and obj.caption ~= "" then
		obj:AddChild(Label:New({
			caption = obj.caption,
			height = obj.titleBarHeight,
			align = "center",
			valign = "center",
		}))
	end

	-- Create minimize button if needed
	if obj.minimizable then
		obj:AddChild(Button:New({
			caption = "-",
			right = 2,
			y = 2,
			width = 16,
			height = 16,
			OnClick = {
				function()
					obj:Minimize()
				end,
			},
		}))
	end

	return obj
end

--- Draws the window
-- @function Window:DrawControl
function Window:DrawControl()
	-- Draw title bar
	if self.caption and self.caption ~= "" then
		gl.Color(self.titleBarColor)
		gl.Rect(0, 0, self.width, self.titleBarHeight)
	end

	-- Draw resize handle
	if self.resizable and not self.minimized then
		gl.Color(1, 1, 1, 0.5)
		gl.BeginEnd(GL.TRIANGLES, function()
			gl.Vertex(self.width - 10, self.height)
			gl.Vertex(self.width, self.height - 10)
			gl.Vertex(self.width, self.height)
		end)
	end
end

--- Minimizes/restores the window
-- @function Window:Minimize
function Window:Minimize()
	self.minimized = not self.minimized

	if self.minimized then
		self._oldHeight = self.height
		self:Resize(nil, self.titleBarHeight)
	else
		self:Resize(nil, self._oldHeight)
	end

	self:CallListeners(self.OnMinimize, self.minimized)
end

--- Handles mouse down events
-- @function Window:MouseDown
-- @param x X coordinate
-- @param y Y coordinate
-- @param button Button pressed
-- @param ... Additional args
-- @return boolean True if handled
function Window:MouseDown(x, y, button, ...)
	-- Check for dragging title bar
	if button == 1 and self.draggable and y < self.titleBarHeight and y >= 0 then
		self._dragging = true
		self._dragStartX = x
		self._dragStartY = y
		return self
	end

	-- Check for resizing
	if button == 1 and self.resizable and not self.minimized and x >= self.width - 10 and y >= self.height - 10 then
		self._resizing = true
		self._resizeStartX = x
		self._resizeStartY = y
		self._resizeStartW = self.width
		self._resizeStartH = self.height
		return self
	end

	return inherited.MouseDown(self, x, y, button, ...)
end

--- Handles mouse move events
-- @function Window:MouseMove
-- @param x X coordinate
-- @param y Y coordinate
-- @param dx X movement
-- @param dy Y movement
-- @param button Button held
function Window:MouseMove(x, y, dx, dy, button)
	-- Handle dragging
	if self._dragging then
		local px = self.x + (x - self._dragStartX)
		local py = self.y + (y - self._dragStartY)
		self:SetPos(px, py)
		self:CallListeners(self.OnMove, px, py)
		return self
	end

	-- Handle resizing
	if self._resizing then
		local w = math.max(self.minWidth, self._resizeStartW + (x - self._resizeStartX))
		local h = math.max(self.minHeight, self._resizeStartH + (y - self._resizeStartY))
		self:Resize(w, h)
		self:CallListeners(self.OnResize, w, h)
		return self
	end

	return inherited.MouseMove(self, x, y, dx, dy, button)
end

--- Handles mouse up events
-- @function Window:MouseUp
-- @param x X coordinate
-- @param y Y coordinate
-- @param button Button released
-- @param ... Additional args
function Window:MouseUp(x, y, button, ...)
	if button == 1 then
		self._dragging = false
		self._resizing = false
	end
	return inherited.MouseUp(self, x, y, button, ...)
end

--- Brings window to front
-- @function Window:BringToFront
function Window:BringToFront()
	if self.parent then
		self.parent:RemoveChild(self)
		self.parent:AddChild(self)
	end
end

VFS.Include(CHILI_DIRNAME .. "headers/skinutils.lua", nil, VFS.RAW_FIRST)

--- Draw debug overlay for window tweaking
-- @function Window:TweakDraw
-- Shows resizable/draggable overlay in tweak mode
function Window:TweakDraw()
	gl.Color(0.6, 1, 0.6, 0.65)

	local w = self.width
	local h = self.height

	if self.resizable or self.tweakResizable then
		TextureHandler.LoadTexture(0, "LuaUI/Widgets/chili/skins/default/tweak_overlay_resizable.png", self)
	else
		TextureHandler.LoadTexture(0, "LuaUI/Widgets/chili/skins/default/tweak_overlay.png", self)
	end
	local texInfo = gl.TextureInfo("LuaUI/Widgets/chili/skins/default/tweak_overlay.png") or { xsize = 1, ysize = 1 }
	local tw, th = texInfo.xsize, texInfo.ysize

	gl.BeginEnd(GL.TRIANGLE_STRIP, _DrawTiledTexture, self.x, self.y, w, h, 31, 31, 31, 31, tw, th, 0)
	gl.Texture(0, false)
end
