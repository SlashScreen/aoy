--//=============================================================================

--- Label module
--- A control for displaying static text with various formatting options.
--- @class Label: Control
--- @field caption string Text to display
--- @field autosize boolean Automatically size to fit text
--- @field autoObeyLineHeight boolean Adjust height to match line height
--- @field align "left" | "center" | "right" Horizontal text alignment
--- @field valign "top" | "center" | "bottom" Vertical text alignment
--- @field textColor Color Text color (default {1,1,1,1})
--- @field shadow boolean Draw text shadow

Label = Control:Inherit({
	classname = "label",
	caption = "",

	autosize = false,
	autoObeyLineHeight = false,

	align = "left",
	valign = "top",

	textColor = { 1, 1, 1, 1 },
	shadow = false,
})

local this = Label
local inherited = this.inherited

--- Creates a new Label instance
--- @param obj table Table of label properties
--- @return Label The newly created label
function Label:New(obj)
	obj = inherited.New(self, obj)
	obj:UpdateLayout()
	return obj
end

--- Sets the label text
--- @param newCaption string Text to display
function Label:SetCaption(newCaption)
	if self.caption == newCaption then
		return
	end
	self.caption = newCaption
	self:UpdateLayout()
	self:Invalidate()
end

--- Updates the label layout
function Label:UpdateLayout()
	local font = self.font

	if self.autosize then
		local w = font:GetTextWidth(self.caption)
		local h, d, numLines = font:GetTextHeight(self.caption)

		if self.autoObeyLineHeight then
			h = math.ceil(numLines * font:GetLineHeight())
		else
			h = math.ceil(h - d)
		end

		local x = self.x
		local y = self.y

		-- Handle vertical alignment
		if self.valign == "center" then
			y = y + (self.height - h) * 0.5
		elseif self.valign == "bottom" then
			y = y + self.height - h
		end

		-- Handle horizontal alignment
		if self.align == "right" then
			x = x + self.width - w
		elseif self.align == "center" then
			x = x + (self.width - w) * 0.5
		end

		w = w + self.padding[1] + self.padding[3]
		h = h + self.padding[2] + self.padding[4]

		self:_UpdateConstraints(x, y, w, h)
	end
end

--- Draws the label
function Label:DrawControl()
	local font = self.font

	-- Calculate position
	local x = 0
	local y = 0
	local w = self.width
	local h = self.height
	local th, td = font:GetTextHeight(self.caption)

	-- Handle vertical alignment
	if self.valign == "center" then
		y = y + (h - th) * 0.5
	elseif self.valign == "bottom" then
		y = y + h - th
	elseif self.valign == "top" then
		y = y + self.padding[2]
	end

	-- Handle horizontal alignment
	if self.align == "right" then
		x = x + w - font:GetTextWidth(self.caption) - self.padding[3]
	elseif self.align == "center" then
		x = x + (w - font:GetTextWidth(self.caption)) * 0.5
	elseif self.align == "left" then
		x = x + self.padding[1]
	end

	-- Draw shadow if enabled
	if self.shadow then
		gl.Color(0, 0, 0, self.textColor[4])
		font:Print(self.caption, x + 1, y + 1)
	end

	-- Draw text
	gl.Color(self.textColor)
	font:Print(self.caption, x, y)
end

--//=============================================================================
