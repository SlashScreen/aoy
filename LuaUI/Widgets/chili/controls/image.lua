--//=============================================================================

--- Image module

--- Image fields.
-- Inherits from Control.
-- @see button.Button
-- @table Image
-- @tparam {r,g,b,a} color color, (default {1,1,1,1})
-- @string[opt=nil] file path
-- @bool[opt=true] keepAspect aspect should be kept
-- @tparam {func1,func2} OnClick function listeners to be invoked on click (default {})
---@class Image : Button
---@field classname string The class name
---@field defaultWidth number Default width (64)
---@field defaultHeight number Default height (64)
---@field padding number[] Padding {left,top,right,bottom}
---@field color table Color Color tint {r,g,b,a}
---@field file string? Primary image file path
---@field file2 string? Secondary image file path
---@field flip boolean Whether to flip primary image vertically
---@field flip2 boolean Whether to flip secondary image vertically
---@field keepAspect boolean Whether to maintain aspect ratio
---@field useRTT boolean Whether to use render-to-texture
---@field OnClick function[] Click event listeners
---@field width number Control width
---@field height number Control height
Image = Button:Inherit({
	classname = "image",

	defaultWidth = 64,
	defaultHeight = 64,
	padding = { 0, 0, 0, 0 },
	color = { 1, 1, 1, 1 },

	file = nil,
	file2 = nil,

	flip = true,
	flip2 = true,

	keepAspect = true,

	useRTT = false,

	OnClick = {},
})

local this = Image
local inherited = this.inherited

---Creates a new Image instance
---@param obj table Configuration object
---@return Image image The created image
function Image:New(obj)
	return inherited.New(self, obj)
end

--//=============================================================================

---Draws texture maintaining aspect ratio
---@param x number Left position
---@param y number Top position
---@param w number Width
---@param h number Height
---@param tw number Texture width
---@param th number Texture height
---@param flipy boolean Whether to flip vertically
---@return nil
local function _DrawTextureAspect(x, y, w, h, tw, th, flipy)
	local twa = w / tw
	local tha = h / th

	local aspect = 1
	if twa < tha then
		aspect = twa
		y = y + h * 0.5 - th * aspect * 0.5
		h = th * aspect
	else
		aspect = tha
		x = x + w * 0.5 - tw * aspect * 0.5
		w = tw * aspect
	end

	local right = math.ceil(x + w)
	local bottom = math.ceil(y + h)
	x = math.ceil(x)
	y = math.ceil(y)

	gl.TexRect(x, y, right, bottom, false, flipy)
end

---Draws the image control
---@return nil
function Image:DrawControl()
	if not (self.file or self.file2) then
		return
	end
	gl.Color(self.color)

	if self.keepAspect then
		if self.file2 then
			TextureHandler.LoadTexture(0, self.file2, self)
			local texInfo = gl.TextureInfo(self.file2) or { xsize = 1, ysize = 1 }
			local tw, th = texInfo.xsize, texInfo.ysize
			_DrawTextureAspect(0, 0, self.width, self.height, tw, th, self.flip2)
		end
		if self.file then
			TextureHandler.LoadTexture(0, self.file, self)
			local texInfo = gl.TextureInfo(self.file) or { xsize = 1, ysize = 1 }
			local tw, th = texInfo.xsize, texInfo.ysize
			_DrawTextureAspect(0, 0, self.width, self.height, tw, th, self.flip)
		end
	else
		if self.file2 then
			TextureHandler.LoadTexture(0, self.file2, self)
			gl.TexRect(0, 0, self.width, self.height, false, self.flip2)
		end
		if self.file then
			TextureHandler.LoadTexture(0, self.file, self)
			gl.TexRect(0, 0, self.width, self.height, false, self.flip)
		end
	end
	gl.Texture(0, false)
end

--//=============================================================================

---Check if image is interactive
---@return boolean|nil isActive Whether image has click handlers
function Image:IsActive()
	local onclick = self.OnClick
	if onclick and onclick[1] then
		return true
	end
end

---Hit test for the image
---@return Image|boolean self Returns self if hit test succeeds
function Image:HitTest()
	--FIXME check if there are any eventhandlers linked (OnClick,OnMouseUp,...)
	return self:IsActive() and self
end

---Handles mouse down event
---@param ... any Additional arguments
---@return Image|Object|boolean self Returns self if handled
function Image:MouseDown(...)
	--// we don't use `this` here because it would call the eventhandler of the button class,
	--// which always returns true, but we just want to do so if a calllistener handled the event
	return Control.MouseDown(self, ...) or self:IsActive() and self
end

---Handles mouse up event
---@param ... any Additional arguments
---@return Image|Object|boolean self Returns self if handled
function Image:MouseUp(...)
	return Control.MouseUp(self, ...) or self:IsActive() and self
end

---Handles mouse click event
---@param ... any Additional arguments
---@return Image|Object|boolean self Returns self if handled
function Image:MouseClick(...)
	return Control.MouseClick(self, ...) or self:IsActive() and self
end

--//=============================================================================
