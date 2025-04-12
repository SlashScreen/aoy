--//=============================================================================

--- Progressbar module

---@class Progressbar : Control
---@field classname string The class name
---@field min number Minimum value
---@field max number Maximum value
---@field value number Current value
---@field color table Color {r,g,b,a}
---@field backgroundColor table Background color {r,g,b,a}
---@field orientation "horizontal"|"vertical" Bar orientation
---@field reverse boolean Whether to fill in reverse direction
---@field noSkin boolean Whether to use skin
---@field OnChange function[] Value change listeners
Progressbar = Control:Inherit({
	classname = "progressbar",

	defaultWidth = 90,
	defaultHeight = 20,

	min = 0,
	max = 100,
	value = 100,

	caption = "",

	color = { 0, 0, 1, 1 },
	backgroundColor = { 1, 1, 1, 1 },

	OnChange = {},
})

local this = Progressbar
local inherited = this.inherited

--//=============================================================================

---Creates a new Progressbar instance
---@param obj table Configuration object
---@return Progressbar bar The created progressbar
function Progressbar:New(obj)
	obj = inherited.New(self, obj)
	obj:SetMinMax(obj.min, obj.max)
	obj:SetValue(obj.value)
	return obj
end

--//=============================================================================

function Progressbar:_Clamp(v)
	if self.min < self.max then
		if v < self.min then
			v = self.min
		elseif v > self.max then
			v = self.max
		end
	else
		if v > self.min then
			v = self.min
		elseif v < self.max then
			v = self.max
		end
	end
	return v
end

--//=============================================================================

--- Sets the new color
-- @tparam {r,g,b,a} c color table
function Progressbar:SetColor(...)
	local color = _ParseColorArgs(...)
	table.merge(color, self.color)
	if not table.iequal(color, self.color) then
		self.color = color
		self:Invalidate()
	end
end

--- Sets the minimum and maximum value of the progress bar
-- @int[opt=0] min minimum value
-- @int[opt=1] max maximum value (why is 1 the default?)
function Progressbar:SetMinMax(min, max)
	self.min = tonumber(min) or 0
	self.max = tonumber(max) or 1
	self:SetValue(self.value)
end

--- Sets the value of the progress bar
-- @int v value of the progress abr
-- @bool[opt=false] setcaption whether the caption should be set as well
---@param v number New value
---@return nil
function Progressbar:SetValue(v, setcaption)
	v = self:_Clamp(v)
	local oldvalue = self.value
	if v ~= oldvalue then
		self.value = v

		if setcaption then
			self:SetCaption(v)
		end

		self:CallListeners(self.OnChange, v, oldvalue)
		self:Invalidate()
	end
end

--- Sets the caption
-- @string str caption to be set
function Progressbar:SetCaption(str)
	if self.caption ~= str then
		self.caption = str
		self:Invalidate()
	end
end

--//=============================================================================

function Progressbar:DrawControl()
	local percent = (self.value - self.min) / (self.max - self.min)
	local x = self.x
	local y = self.y
	local w = self.width
	local h = self.height

	gl.Color(self.backgroundColor)
	gl.Rect(w * percent, y, w, h)

	gl.Color(self.color)
	gl.Rect(0, y, w * percent, h)

	if self.caption then
		(self.font):Print(self.caption, w * 0.5, h * 0.5, "center", "center")
	end
end

--//=============================================================================
