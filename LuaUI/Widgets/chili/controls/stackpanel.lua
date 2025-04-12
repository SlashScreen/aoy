--//=============================================================================

--- StackPanel module
--- A panel that automatically arranges child controls in a vertical or horizontal stack.
--- @class StackPanel: LayoutPanel
--- @field orientation string Stack direction ("vertical" or "horizontal")
--- @field resizeItems boolean Resize items to fill width/height
--- @field autosize boolean Automatically size to fit content
--- @field itemPadding [number, number, number, number] Padding between items
--- @field itemMargin [number, number, number, number] Margin around items
--- @field minItemWidth number Minimum item width
--- @field minItemHeight number Minimum item height
--- @field centerItems boolean Center items in cross direction
--- @field OnResize function[] Resize event listeners

StackPanel = LayoutPanel:Inherit({
	classname = "stackpanel",
	orientation = "vertical",
	resizeItems = false,
	autosize = true,

	itemPadding = { 5, 5, 5, 5 },
	itemMargin = { 0, 0, 0, 0 },

	minItemWidth = 1,
	minItemHeight = 1,

	centerItems = false,

	OnResize = {},
})

local this = StackPanel
local inherited = this.inherited

--- Creates a new StackPanel instance
--- @param obj table Table of properties
--- @return StackPanel The newly created stack panel
function StackPanel:New(obj)
	obj = inherited.New(self, obj)
	return obj
end

--- Updates the stack panel layout
--- @return boolean True if layout was updated
function StackPanel:UpdateLayout()
	-- Validate children
	if not self.children[1] then
		return false
	end

	local cn = self.children
	local orientation = self.orientation
	local itemMargin = self.itemMargin
	local itemPadding = self.itemPadding

	-- Reset positions
	local curPos = 0
	for i = 1, #cn do
		local child = cn[i]

		-- Position child
		if orientation == "vertical" then
			child.x = itemMargin[1] + itemPadding[1]
			child.y = curPos + itemMargin[2] + itemPadding[2]

			if self.resizeItems then
				child.width = self.clientArea[3] - itemMargin[1] - itemMargin[3] - itemPadding[1] - itemPadding[3]
			end

			curPos = child.y + child.height + itemMargin[4] + itemPadding[4]
		else
			child.x = curPos + itemMargin[1] + itemPadding[1]
			child.y = itemMargin[2] + itemPadding[2]

			if self.resizeItems then
				child.height = self.clientArea[4] - itemMargin[2] - itemMargin[4] - itemPadding[2] - itemPadding[4]
			end

			curPos = child.x + child.width + itemMargin[3] + itemPadding[3]
		end

		-- Center in cross direction if enabled
		if self.centerItems then
			if orientation == "vertical" then
				local space = self.clientArea[3]
					- child.width
					- itemMargin[1]
					- itemMargin[3]
					- itemPadding[1]
					- itemPadding[3]
				child.x = child.x + space / 2
			else
				local space = self.clientArea[4]
					- child.height
					- itemMargin[2]
					- itemMargin[4]
					- itemPadding[2]
					- itemPadding[4]
				child.y = child.y + space / 2
			end
		end
	end

	-- Update size if autosize enabled
	if self.autosize then
		if orientation == "vertical" then
			self.height = curPos
		else
			self.width = curPos
		end
		self:CallListeners(self.OnResize, self.width, self.height)
		return true
	end

	return false
end

--- Adds a child control to the stack
--- @param child Control Control to add
--- @param dontUpdateLayout boolean? Don't update layout after adding
function StackPanel:AddChild(child, dontUpdateLayout)
	inherited.AddChild(self, child, true)

	if not dontUpdateLayout then
		self:UpdateLayout()
		self:Invalidate()
	end
end

--- Removes a child control from the stack
--- @param child Control Control to remove
--- @param dontUpdateLayout boolean? Don't update layout after removing
function StackPanel:RemoveChild(child, dontUpdateLayout)
	inherited.RemoveChild(self, child, true)

	if not dontUpdateLayout then
		self:UpdateLayout()
		self:Invalidate()
	end
end

--//=============================================================================
