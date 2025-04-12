--//=============================================================================

--- Button module

---@class Button : Control
---@field classname string The class name
---@field caption string Button caption
---@field defaultWidth number Default width
---@field defaultHeight number Default height
---@field onClick function|nil Click handler
---@field OnClick function[] Click event listeners
---@field OnMouseUp function[] Mouse up listeners
---@field OnMouseDown function[] Mouse down listeners
Button = Control:Inherit({
	classname = "button",
	caption = "button",
	defaultWidth = 70,
	defaultHeight = 20,
})

local this = Button
local inherited = this.inherited

--//=============================================================================

--- Sets the caption of the button
-- @string caption new caption of the button
function Button:SetCaption(caption)
	if self.caption == caption then
		return
	end
	self.caption = caption
	self:Invalidate()
end

--//=============================================================================

function Button:DrawControl()
	--// gets overriden by the skin/theme
end

--//=============================================================================

---Hit test - returns self since entire button area is clickable
---@return Button self
function Button:HitTest(x, y)
	return self
end

---Handles mouse down events
---@return Button self
function Button:MouseDown(...)
	self.state.pressed = true
	inherited.MouseDown(self, ...)
	self:Invalidate()
	return self
end

function Button:MouseUp(...)
	if self.state.pressed then
		self.state.pressed = false
		inherited.MouseUp(self, ...)
		self:Invalidate()
		return self
	end
end

--//=============================================================================
