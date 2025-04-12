--//=============================================================================

--- Checkbox module

---@class Checkbox : Control
---@field classname string The class name
---@field checked boolean Checkbox checked state
---@field caption string Caption to appear in the checkbox
---@field textalign "left"|"right"|"center" Text alignment
---@field boxalign "left"|"right" Box alignment
---@field boxsize number Box size in pixels
---@field textColor table<number,number> Text color {r,g,b,a}
---@field defaultWidth number Default width
---@field defaultHeight number Default height
---@field OnChange function[] Listener functions for checked state changes
Checkbox = Control:Inherit({
	classname = "checkbox",
	checked = true,
	caption = "text",
	textalign = "left",
	boxalign = "right",
	boxsize = 10,

	textColor = { 0, 0, 0, 1 },

	defaultWidth = 70,
	defaultHeight = 18,

	OnChange = {},
})

local this = Checkbox
local inherited = this.inherited

--//=============================================================================

---Creates a new Checkbox instance
---@param obj table Configuration object
---@return Checkbox checkbox The created checkbox
function Checkbox:New(obj)
	obj = inherited.New(self, obj)
	obj.state.checked = obj.checked
	return obj
end

--//=============================================================================

--- Toggles the checked state of the checkbox
---@return nil
function Checkbox:Toggle()
	self:CallListeners(self.OnChange, not self.checked)
	self.checked = not self.checked
	self.state.checked = self.checked
	self:Invalidate()
end

--//=============================================================================

---Draws the checkbox control (overridden by skin/theme)
---@return nil
function Checkbox:DrawControl()
	--// gets overriden by the skin/theme
end

--//=============================================================================

---Hit test - returns self since entire checkbox area is clickable
---@return Checkbox self
function Checkbox:HitTest()
	return self
end

---Handles mouse down event by toggling state
---@return Checkbox self
function Checkbox:MouseDown()
	self:Toggle()
	return self
end

--//=============================================================================
