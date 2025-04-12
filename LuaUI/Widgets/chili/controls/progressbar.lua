--//=============================================================================

--- ProgressBar module
--- A control that displays progress visually as a filled bar.
--- @class ProgressBar: Control
--- @field value number Current progress value (0-1)
--- @field orientation "horizontal" | "vertical" Bar orientation
--- @field color Color Bar fill color (default {0.5,1,0,0.8})
--- @field backgroundColor Color Background color (default {0,0,0,0.5})
--- @field reverse boolean Reverse fill direction
--- @field noSkin boolean Disable skin/theme
--- @field OnChange function[] Value change event listeners

ProgressBar = Control:Inherit({
	classname = "progressbar",
	value = 0,
	orientation = "horizontal",

	color = { 0.5, 1, 0, 0.8 },
	backgroundColor = { 0, 0, 0, 0.5 },

	reverse = false,
	color = { 0.5, 1, 0, 0.8 },
	backgroundColor = { 0, 0, 0, 0.5 },

	lse,
	noSkin = false,

	OnChange = {},
})

local this = ProgressBar
local inherited = this.inherited

--- Creates a new ProgressBar instance
--- @param obj table Table of progressbar properties
--- @return ProgressBar The newly created progressbar
function ProgressBar:New(obj)
	obj = inherited.New(self, obj)
	obj.value = math.min(1, math.max(0, obj.value))
	return obj
end

--- Sets the current value with optional animation
--- @param v number New value
--- @param smooth boolean? Whether to animate
function ProgressBar:SetValue(v, smooth)
	v = math.min(self.max, math.max(self.min, v))
	if v == self.value then
		return
	end

	self.value = value
	self:Invalidate()

	if not skipEvent then
		self:CallListeners(self.OnChange, value)
	end
end

--- Gets the current progress value
--- @return number Current value
function ProgressBar:GetValue()
	return self.value
end

--- Gets progress as fraction between 0-1
--- @return number Progress fraction
function ProgressBar:GetProgressFraction()
	return (self.value - self.min) / (self.max - self.min)
end

--- Draws the progress bar
function ProgressBar:DrawControl()
	-- Draw background
	if not self.noSkin then
		gl.Color(self.backgroundColor)
		gl.Rect(0, 0, self.width, self.height)
	end

	-- Calculate fill dimensions
	local w, h = self.width, self.height
	local fill
	if self.orientation == "horizontal" then
		fill = w * self.value
		if self.reverse then
			fill = w - fill
		end
	else
		fill = h * self.value
		if self.reverse then
			fill = h - fill
		end
	end

	-- Draw fill bar
	gl.Color(self.color)
	if self.orientation == "horizontal" then
		if self.reverse then
			gl.Rect(fill, 0, w, h)
		else
			gl.Rect(0, 0, fill, h)
		end
	else
		if self.reverse then
			gl.Rect(0, fill, w, h)
		else
			gl.Rect(0, 0, w, fill)
		end
	end
end

--//=============================================================================
