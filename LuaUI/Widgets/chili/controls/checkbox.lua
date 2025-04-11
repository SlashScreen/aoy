--//=============================================================================

--- Checkbox module
--- A control that can be checked or unchecked to represent a boolean state.
--- @class Checkbox: Control
--- @field caption string label
--- @field checked boolean Current checked state
--- @field boxalign "left" | "right" Box alignment
--- @field boxsize number Size of checkbox box. (default 13)
--- @field textColor Color Text color (default {1,1,1,1})
--- @field checkColor Color Check mark color (default {0.5,1,0.5,1})
--- @field OnChange function[] State change event listeners

Checkbox = Control:Inherit({
	classname = "checkbox",
	caption = "",
	checked = false,
	boxalign = "left",
	boxsize = 13,

	textColor = { 1, 1, 1, 1 },
	checkColor = { 0.5, 1, 0.5, 1 },

	OnChange = {},
})

---@type Checkbox
local this = Checkbox
local inherited = this.inherited

--- Creates a new Checkbox instance
-- @function Checkbox:New
-- @param obj Table of checkbox properties
-- @return Checkbox The newly created checkbox
function Checkbox:New(obj)
	obj = inherited.New(self, obj)
	return obj
end

--- Sets checked state
-- @function Checkbox:SetChecked
-- @param checked New checked state
-- @param nopropagate Don't trigger OnChange event
function Checkbox:SetChecked(checked, nopropagate)
	checked = not not checked -- convert to boolean

	if self.checked == checked then
		return
	end

	self.checked = checked
	self:Invalidate()

	if not nopropagate then
		self:CallListeners(self.OnChange, self.checked)
	end
end

--- Toggle checked state
-- @function Checkbox:Toggle
function Checkbox:Toggle()
	self:SetChecked(not self.checked)
end

--- Draws the checkbox control
-- @function Checkbox:DrawControl
function Checkbox:DrawControl()
	-- Draw box
	local boxSize = self.boxsize
	local boxX = (self.boxalign == "right") and (self.width - boxSize - 2) or 2
	local boxY = (self.height - boxSize) * 0.5

	gl.Color(1, 1, 1, 1)
	gl.BeginEnd(GL.LINE_LOOP, function()
		gl.Vertex(boxX, boxY)
		gl.Vertex(boxX + boxSize, boxY)
		gl.Vertex(boxX + boxSize, boxY + boxSize)
		gl.Vertex(boxX, boxY + boxSize)
	end)

	-- Draw checkmark if checked
	if self.checked then
		gl.Color(self.checkColor)
		gl.BeginEnd(GL.LINE_STRIP, function()
			gl.Vertex(boxX + 2, boxY + boxSize / 2)
			gl.Vertex(boxX + boxSize / 2, boxY + boxSize - 2)
			gl.Vertex(boxX + boxSize - 2, boxY + 2)
		end)
	end

	-- Draw caption
	if self.caption ~= "" then
		local textX = (self.boxalign == "right") and 2 or (boxX + boxSize + 2)
		local textY = (self.height - self.font:GetLineHeight()) * 0.5

		gl.Color(self.textColor)
		self.font:Print(self.caption, textX, textY)
	end
end

--- Handles mouse down events
-- @function Checkbox:MouseDown
-- @param x X coordinate
-- @param y Y coordinate
-- @param ... Additional args
-- @return boolean True if handled
function Checkbox:MouseDown(x, y, ...)
	if self:HitTest(x, y) then
		self:Toggle()
		return self
	end
	return inherited.MouseDown(self, x, y, ...)
end

--- Handle hit testing
-- @function Checkbox:HitTest
-- @param x X coordinate to test
-- @param y Y coordinate to test
-- @return boolean True if hit
function Checkbox:HitTest(x, y)
	return self:IsDescendantOf(screen0) and x >= 0 and x <= self.width and y >= 0 and y <= self.height
end

--//=============================================================================
