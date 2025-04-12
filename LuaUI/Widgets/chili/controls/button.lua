--//=============================================================================

--- Button module
--- A clickable button control with customizable caption and styling.
--- @class Button: Control
--- @field caption string Button text
--- @field defaultWidth number Default button width
--- @field defaultHeight number Default button height
--- @field toggleable boolean Button can be toggled on/off
--- @field checked boolean Current toggle state
--- @field pressed boolean Current pressed state
--- @field borderColor Color Border color (default {1,1,1,0.8})
--- @field focusColor Color Color when focused (default {1,1,1,1})
--- @field captionColor Color Text color (default {1,1,1,0.8})
--- @field OnClick function[] Click event listeners
--- @field OnMouseUp function[] Mouse up event listeners
--- @field OnMouseDown function[] Mouse down event listeners

Button = Control:Inherit({
	classname = "button",
	caption = "",
	defaultWidth = 70,
	defaultHeight = 20,

	toggleable = true,
	checked = false,
	pressed = false,

	borderColor = { 1, 1, 1, 0.8 },
	focusColor = { 1, 1, 1, 1 },
	captionColor = { 1, 1, 1, 0.8 },

	OnClick = {},
	OnMouseUp = {},
	OnMouseDown = {},
})

local this = Button
local inherited = this.inherited

--- Creates a new Button instance
--- @param obj table Table of button properties
--- @return Button The newly created button
function Button:New(obj)
	obj = inherited.New(self, obj)
	obj:SetCaption(obj.caption)
	return obj
end

--- Sets the button's caption text
--- @param caption string New caption text
function Button:SetCaption(caption)
	if caption == self.caption then
		return
	end
	self.caption = caption
	self:RequestRealign()
end

--- Draw the button control
function Button:DrawControl()
	-- Gets overriden by theme
end

--- Handles mouse down events
--- @param x number Mouse x position
--- @param y number Mouse y position
--- @param ... any Additional args
--- @return boolean True if handled
function Button:MouseDown(x, y, ...)
	if self:CheckMouseOver(x, y) then
		self.pressed = true
		self:InvalidateSelf()
		inherited.MouseDown(self, x, y, ...)
		return self
	end
	return false
end

--- Handles mouse up events
--- @param x number Mouse x position
--- @param y number Mouse y position
--- @param ... any Additional args
--- @return boolean True if handled
function Button:MouseUp(x, y, ...)
	if self.pressed then
		if self:CheckMouseOver(x, y) then
			self:ToggleState()
			self:CallListeners(self.OnClick, x, y, ...)
		end
		self.pressed = false
		self:InvalidateSelf()
		inherited.MouseUp(self, x, y, ...)
		return self
	end
	return false
end

--- Toggle button checked state
function Button:ToggleState()
	if self.toggleable then
		self.checked = not self.checked
		self:InvalidateSelf()
	end
end

--//=============================================================================
