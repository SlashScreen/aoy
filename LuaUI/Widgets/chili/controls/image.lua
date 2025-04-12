--//=============================================================================

--- Image module
--- A control for displaying images and textures with various sizing and rendering options.
---@class Image: Control
---@field file string Path to image file
---@field keepAspect boolean Maintain aspect ratio
---@field autosize boolean Size to match image dimensions
---@field imageLoadType "stretch" | "file" | "icon" Loading mode
---@field color Color Tint color (default {1,1,1,1})
---@field uvCoords {left: number, topY: number, right: number, bottom: number}? UV coordinates for texture mapping
---@field texRect {left: number, topY: number, right: number, bottom: number}? Source rectangle in texture
---@field flipY boolean Flip texture vertically
---@field tile boolean Tile the texture
---@field defaultWidth number Default width (default 64)
---@field defaultHeight number Default height (default 64)

Image = Control:Inherit({
	classname = "image",
	file = "",
	keepAspect = false,
	autosize = false,

	imageLoadType = "stretch", -- stretch, file, icon

	color = { 1, 1, 1, 1 },

	uvCoords = nil, -- {left, top, right, bottom}
	texRect = nil, -- {left, top, right, bottom}

	flipY = false,
	tile = false,

	defaultWidth = 64,
	defaultHeight = 64,
})

local this = Image
local inherited = this.inherited

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

--- Creates a new Image instance
--- @param obj table Table of image properties
--- @return Image The newly created image
function Image:New(obj)
	if obj.file and not obj.width and not obj.height then
		obj.autosize = true
	end

	obj = inherited.New(self, obj)

	obj:LoadImage(obj.file)
	obj:RequestUpdate()

	return obj
end

--- Updates the client area and image dimensions.
--- @param dontUpdateChildren boolean? If true, child controls won't be updated.
function Image:UpdateClientArea(dontUpdateChildren)
	inherited.UpdateClientArea(self, dontUpdateChildren)
	if self.image then
		local w = self.clientArea[3]
		local h = self.clientArea[4]

		if self.keepAspect then
			local aspect = self.imageWidth / self.imageHeight
			if w < h * aspect then
				h = w / aspect
			else
				w = h * aspect
			end
		end

		self._imageWidth = w
		self._imageHeight = h
	end
end

--- Loads an image file
--- @param file string Path to image file
function Image:LoadImage(file)
	if not file then
		return
	end

	if self.imageLoadType == "icon" then
		self.file = file
		self.width = self.width or self.defaultWidth
		self.height = self.height or self.defaultHeight
		return
	end

	local fileExists = VFS.FileExists(file)
	if not fileExists then
		Spring.Log("Chili", "error", "Image file not found: " .. tostring(file))
		return
	end

	self.file = file
	local texInfo = gl.TextureInfo(file) or { xsize = 1, ysize = 1 }

	if self.autosize then
		self:Resize(texInfo.xsize, texInfo.ysize)
	end
end

--- Updates image layout
function Image:UpdateLayout()
	local texInfo = gl.TextureInfo(self.file)
	if not texInfo then
		return
	end

	if self.autosize then
		self:Resize(texInfo.xsize, texInfo.ysize)
	elseif self.keepAspect then
		local w = self.width
		local h = self.height

		local aspect = texInfo.xsize / texInfo.ysize
		if w / h > aspect then
			w = h * aspect
		else
			h = w / aspect
		end

		self:Resize(w, h)
	end
end

--- Draws the image
function Image:DrawControl()
	if not self.file or self.file == "" then
		return
	end

	gl.Color(self.color)

	if self.imageLoadType == "icon" then
		-- Draw icon
		gl.PushMatrix()
		gl.Scale(self.width / 96, self.height / 96, 1)
		gl.Texture(":" .. self.file)
		gl.TexRect(0, 0, 96, 96)
		gl.Texture(false)
		gl.PopMatrix()
		return
	end

	-- Setup texture coordinates
	local uv = self.uvCoords
	local tex = self.texRect

	if tex then
		local texInfo = gl.TextureInfo(self.file)
		if texInfo then
			local tw, th = texInfo.xsize, texInfo.ysize

			uv = {
				tex[1] / tw,
				tex[2] / th,
				tex[3] / tw,
				tex[4] / th,
			}
		end
	end

	-- Draw texture
	gl.Texture(self.file)

	if self.tile then
		local w, h = self.width, self.height
		local tw, th = gl.TextureInfo(self.file)
		if tw and th then
			gl.BeginEnd(GL.QUADS, function()
				for x = 0, w, tw do
					for y = 0, h, th do
						gl.MultiTexCoord(0, 0, 1)
						gl.Vertex(x, y)
						gl.MultiTexCoord(0, 1, 1)
						gl.Vertex(math.min(x + tw, w), y)
						gl.MultiTexCoord(0, 1, 0)
						gl.Vertex(math.min(x + tw, w), math.min(y + th, h))
						gl.MultiTexCoord(0, 0, 0)
						gl.Vertex(x, math.min(y + th, h))
					end
				end
			end)
		end
	else
		if uv then
			if self.flipY then
				gl.TexRect(0, 0, self.width, self.height, uv[1], uv[4], uv[3], uv[2])
			else
				gl.TexRect(0, 0, self.width, self.height, uv[1], uv[2], uv[3], uv[4])
			end
		else
			if self.flipY then
				gl.TexRect(0, 0, self.width, self.height, 0, 1, 1, 0)
			else
				gl.TexRect(0, 0, self.width, self.height)
			end
		end
	end

	gl.Texture(false)
end

--- Disposes of the image control
function Image:Dispose(...)
	if self._tex_loaded then
		gl.DeleteTexture(self.file)
	end
	inherited.Dispose(self, ...)
end

---@return boolean?
function Image:IsActive()
	local onclick = self.OnClick
	if onclick and onclick[1] then
		return true
	end
end

---@param x any?
---@param y any?
function Image:HitTest(x, y)
	--FIXME check if there are any eventhandlers linked (OnClick,OnMouseUp,...)
	return self:IsActive() and self
end

---@param ... any
function Image:MouseDown(...)
	--// we don't use `this` here because it would call the eventhandler of the button class,
	--// which always returns true, but we just want to do so if a calllistener handled the event
	return Control.MouseDown(self, ...) or self:IsActive() and self
end

---@param ... any
function Image:MouseUp(...)
	return Control.MouseUp(self, ...) or self:IsActive() and self
end

---@param ... any
function Image:MouseClick(...)
	return Control.MouseClick(self, ...) or self:IsActive() and self
end

--//=============================================================================
