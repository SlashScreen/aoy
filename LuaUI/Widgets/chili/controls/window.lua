--- Window module

---@class Window : Control
---@field classname string The class name
---@field draggable boolean Whether window can be dragged
---@field resizable boolean Whether window can be resized
---@field minWidth number Minimum width
---@field minHeight number Minimum height 
---@field defaultWidth number Default width
---@field defaultHeight number Default height
Window = Control:Inherit({
	classname = "window",
	resizable = true,
	draggable = true,

	minWidth = 50,
	minHeight = 50,
	defaultWidth = 400,
	defaultHeight = 300,
})

local this = Window
local inherited = this.inherited

--//=============================================================================
--[[
function Window:UpdateClientArea()
  inherited.UpdateClientArea(self)

  if (not WG['blur_api']) then return end

  if (self.blurId) then
    WG['blur_api'].RemoveBlurRect(self.blurId)
  end

  local screeny = select(2,gl.GetViewSizes()) - self.y

  self.blurId = WG['blur_api'].InsertBlurRect(self.x,screeny,self.x+self.width,screeny-self.height)
end
--]]
--//=============================================================================

---Creates a new Window instance
---@param obj table Configuration object
---@return Window window The created window
function Window:New(obj)
	obj = inherited.New(self, obj)
	obj:BringToFront()
	return obj
end

---Draws the window (overridden by skin/theme)
---@return nil
function Window:DrawControl()
	--// gets overriden by the skin/theme
end

---Handles mouse down event
---@param ... any Additional parameters
---@return any result Result of parent handler
function Window:MouseDown(...)
	self:BringToFront()
	return inherited.MouseDown(self, ...)
end

VFS.Include(CHILI_DIRNAME .. "headers/skinutils.lua", nil, VFS.RAW_FIRST)

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
