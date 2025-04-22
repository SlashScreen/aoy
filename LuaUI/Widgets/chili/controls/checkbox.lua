--// =============================================================================

---@class Checkbox : Control
---@field caption string
---@field checked boolean
---@field textAlign "left"|"center"|"right"|"linecenter"
---@field boxAlign "left"|"center"|"right"
---@field boxsize integer
---@field textColor ColorTable
---@field OnChange CallbackFun[] listener functions for checked state changes
Checkbox = Control:Inherit({
	classname = "checkbox",
	checked = true,
	caption = "text",
	textalign = "left",
	textoffset = 0,
	valign = "linecenter",
	boxalign = "right",
	boxsize = 10,
	noFont = false,

	textColor = { 0, 0, 0, 1 },

	defaultWidth = 70,
	defaultHeight = 18,

	OnChange = {},
})

local this = Checkbox
local inherited = this.inherited

--// =============================================================================

function Checkbox:New(obj)
	obj = inherited.New(self, obj)
	obj.state.checked = obj.checked
	return obj
end

--// =============================================================================

--- Toggles the checked state
function Checkbox:Toggle()
	self:CallListeners(self.OnChange, not self.checked)
	self.checked = not self.checked
	self.state.checked = self.checked
	self:Invalidate()
end

function Checkbox:SetToggle(value)
	self:CallListeners(self.OnChange, value)
	self.checked = value
	self.state.checked = self.checked
	self:Invalidate()
end

--// =============================================================================

function Checkbox:DrawControl()
	--// gets overriden by the skin/theme
end

--// =============================================================================

function Checkbox:HitTest()
	return self
end

function Checkbox:MouseDown()
	self:Toggle()
	return self
end

--// =============================================================================
