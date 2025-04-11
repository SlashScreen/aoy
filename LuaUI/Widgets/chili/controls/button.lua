--//=============================================================================

--- Button module
--- A clickable button control with customizable caption and styling.

--- Button fields
-- Inherits from Control.
-- @see control.Control
-- @table Button
-- @string[opt=""] caption Button text
-- @tparam font font Caption font settings
-- @bool[opt=true] toggleable Button can be toggled on/off
-- @bool[opt=false] checked Current toggle state
-- @bool[opt=false] pressed Current pressed state
-- @number[opt=1] borderWidth Border thickness
-- @tparam {r,g,b,a} focusColor Color when focused (default {1,1,1,1})
-- @tparam {r,g,b,a} captionColor Text color (default {1,1,1,0.8})
-- @tparam function{} OnClick Click event listeners
-- @tparam function{} OnMouseUp Mouse up event listeners
-- @tparam function{} OnMouseDown Mouse down event listeners

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
-- @function Button:New
-- @param obj Table of button properties
-- @return Button The newly created button
function Button:New(obj)
	obj = inherited.New(self, obj)
	obj:SetCaption(obj.caption)
	return obj
end

--- Sets the button's caption text
-- @function Button:SetCaption
-- @string caption New caption text
function Button:SetCaption(caption)
	if caption == self.caption then
		return
	end
	self.caption = caption
	self:RequestRealign()
end

--- Draw the button control
-- @function Button:DrawControl
function Button:DrawControl()
	-- Gets overriden by theme
end

--- Handles mouse down events
-- @function Button:MouseDown
-- @param x Mouse x position
-- @param y Mouse y position
-- @param ... Additional args
-- @return boolean True if handled
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
-- @function Button:MouseUp
-- @param x Mouse x position
-- @param y Mouse y position
-- @param ... Additional args
-- @return boolean True if handled
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
-- @function Button:ToggleState
function Button:ToggleState()
	if self.toggleable then
		self.checked = not self.checked
		self:InvalidateSelf()
	end
end

--//=============================================================================
