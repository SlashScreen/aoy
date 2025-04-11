--//=============================================================================

--- Trackbar module
--- A control that provides slider/range input functionality.

--- Trackbar fields
-- Inherits from Control.
-- @see control.Control
-- @table Trackbar
-- @number[opt=0] min Minimum value
-- @number[opt=1] max Maximum value
-- @number[opt=0] value Current value
-- @number[opt=0.1] step Step size
-- @string[opt="horizontal"] orientation Bar orientation ("horizontal" or "vertical")
-- @tparam {r,g,b,a} color Bar color
-- @tparam {r,g,b,a} backgroundColor Background color
-- @bool[opt=true] showValue Show numeric value
-- @string[opt="%.1f"] valueFormatString Format string for displayed value
-- @tparam function{} OnChange Value change event listeners

Trackbar = Control:Inherit({
	classname = "trackbar",
	min = 0,
	max = 100,
	value = 50,
	step = 0.1,

	orientation = "horizontal",

	color = { 0.5, 1, 0.5, 0.8 },
	backgroundColor = { 0.1, 0.1, 0.1, 0.8 },

	showValue = true,
	valueFormatString = "%.1f",

	OnChange = {},
})

local this = Trackbar
local inherited = this.inherited

local function FormatNum(num)
	if num == 0 then
		return "0"
	else
		local strFormat = string.format
		local absNum = math.abs(num)
		if absNum < 0.01 then
			return strFormat("%.3f", num)
		elseif absNum < 1 then
			return strFormat("%.2f", num)
		elseif absNum < 10 then
			return strFormat("%.1f", num)
		else
			return strFormat("%.0f", num)
		end
	end
end

--- Creates a new Trackbar instance
-- @function Trackbar:New
-- @param obj Table of trackbar properties
-- @return Trackbar The newly created trackbar
function Trackbar:New(obj)
	obj = inherited.New(self, obj)

	-- Ensure value is within bounds
	obj.value = math.min(obj.max, math.max(obj.min, obj.value))

	-- Create value label if needed
	if obj.showValue then
		obj:AddChild(Label:New({
			caption = string.format(obj.valueFormatString, obj.value),
			right = 5,
			y = 2,
		}))
	end

	return obj
end

function Trackbar:_Clamp(v)
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

function Trackbar:_GetPercent(x, y)
	if x then
		local pl, pt, pr, pb = unpack4(self.hitpadding)
		if x < pl then
			return 0
		end
		if x > self.width - pr then
			return 1
		end

		local cx = x - pl
		local barWidth = self.width - (pl + pr)

		return (cx / barWidth)
	else
		return (self.value - self.min) / (self.max - self.min)
	end
end

--- Sets the minimum and maximum value of the track bar
-- @int[opt=0] min minimum value
-- @int[opt=1] max maximum value (why is 1 the default?)
function Trackbar:SetMinMax(min, max)
	self.min = tonumber(min) or 0
	self.max = tonumber(max) or 1
	self:SetValue(self.value)
end

--- Sets the current value
-- @function Trackbar:SetValue
-- @param value New value
-- @param skipEvent Don't trigger change event
function Trackbar:SetValue(value, skipEvent)
	-- Clamp to bounds and step
	value = math.min(self.max, math.max(self.min, value))
	if self.step > 0 then
		value = math.floor((value - self.min) / self.step + 0.5) * self.step + self.min
	end

	if value == self.value then
		return
	end

	self.value = value

	-- Update value label
	if self.showValue then
		self.children[1]:SetCaption(string.format(self.valueFormatString, value))
	end

	if not skipEvent then
		self:CallListeners(self.OnChange, value)
	end

	self:Invalidate()
end

function Trackbar:DrawControl()
	-- Draw background
	gl.Color(self.backgroundColor)
	gl.Rect(0, 0, self.width, self.height)

	-- Draw value bar
	local rel = self:ValueToRelative(self.value)
	gl.Color(self.color)

	if self.orientation == "horizontal" then
		gl.Rect(0, 0, self.width * rel, self.height)
	else
		gl.Rect(0, self.height * (1 - rel), self.width, self.height)
	end
end

function Trackbar:HitTest()
	return self
end

function Trackbar:MouseDown(x, y, ...)
	if not self:HitTest(x, y) then
		return false
	end

	self._dragging = true
	self:UpdateValueFromMouse(x, y)
	return self
end

function Trackbar:MouseMove(x, y, dx, dy, ...)
	if not self._dragging then
		return
	end

	self:UpdateValueFromMouse(x, y)
	return self
end

function Trackbar:UpdateValueFromMouse(x, y)
	local rel
	if self.orientation == "horizontal" then
		rel = math.min(1, math.max(0, x / self.width))
	else
		rel = 1 - math.min(1, math.max(0, y / self.height))
	end

	self:SetValue(self:RelativeToValue(rel))
end

function Trackbar:MouseUp(x, y, ...)
	if not self._dragging then
		return
	end

	self._dragging = false
	self:UpdateValueFromMouse(x, y)
	return self
end

--- Gets the relative position for a value
-- @function Trackbar:ValueToRelative
-- @param value Value to convert
-- @return number Relative position (0-1)
function Trackbar:ValueToRelative(value)
	return (value - self.min) / (self.max - self.min)
end

--- Gets the value for a relative position
-- @function Trackbar:RelativeToValue
-- @param rel Relative position (0-1)
-- @return number Value at position
function Trackbar:RelativeToValue(rel)
	return self.min + rel * (self.max - self.min)
end
