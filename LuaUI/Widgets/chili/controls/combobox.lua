--//=============================================================================

--- ComboBox module
--- A control that provides dropdown selection functionality.

--- ComboBox fields
-- Inherits from Control.
-- @see control.Control
-- @table ComboBox
-- @tparam table items Array of dropdown items
-- @int[opt=1] selected Index of selected item
-- @number[opt=100] maxDropDownHeight Maximum height of dropdown
-- @bool[opt=false] expanded Dropdown is expanded
-- @tparam {r,g,b,a} color Text color
-- @tparam {r,g,b,a} backgroundColor Background color
-- @tparam {r,g,b,a} selectedColor Selected item color
-- @tparam function{} OnSelect Item selection event listeners

ComboBox = Control:Inherit({
	classname = "combobox",
	items = {},
	selected = 1,
	maxDropDownHeight = 100,
	expanded = false,

	color = { 1, 1, 1, 1 },
	backgroundColor = { 0, 0, 0, 0.8 },
	selectedColor = { 0.4, 0.4, 1, 0.8 },

	OnSelect = {},
})

local this = ComboBox
local inherited = this.inherited

--- Creates a new ComboBox instance
-- @function ComboBox:New
-- @param obj Table of combobox properties
-- @return ComboBox The newly created combobox
function ComboBox:New(obj)
	obj = inherited.New(self, obj)

	-- Create dropdown button
	obj._dropButton = Button:New({
		caption = "▼",
		right = 0,
		width = 20,
		height = "100%",
		OnClick = {
			function()
				obj:ToggleDropDown()
			end,
		},
	})
	obj:AddChild(obj._dropButton)

	return obj
end

--- Toggles dropdown visibility
-- @function ComboBox:ToggleDropDown
function ComboBox:ToggleDropDown()
	if self.expanded then
		self:CollapseDropDown()
	else
		self:ExpandDropDown()
	end
end

--- Expands the dropdown
-- @function ComboBox:ExpandDropDown
function ComboBox:ExpandDropDown()
	if self.expanded then
		return
	end
	self.expanded = true

	-- Create dropdown panel
	self._dropPanel = Window:New({
		x = self.x,
		y = self.y + self.height,
		width = self.width,
		height = math.min(self.maxDropDownHeight, #self.items * 20),
		backgroundColor = self.backgroundColor,
		parent = screen0,
	})

	-- Create item buttons
	for i, item in ipairs(self.items) do
		local button = Button:New({
			x = 0,
			y = (i - 1) * 20,
			width = "100%",
			height = 20,
			caption = item,
			backgroundColor = (i == self.selected) and self.selectedColor or { 0, 0, 0, 0 },
			OnClick = {
				function()
					self:Select(i)
				end,
			},
		})
		self._dropPanel:AddChild(button)
	end
end

--- Collapses the dropdown
-- @function ComboBox:CollapseDropDown
function ComboBox:CollapseDropDown()
	if not self.expanded then
		return
	end

	self.expanded = false
	if self._dropPanel then
		self._dropPanel:Dispose()
		self._dropPanel = nil
	end
end

--- Selects an item
-- @function ComboBox:Select
-- @param index Item index to select
function ComboBox:Select(index)
	if self.selected == index then
		return
	end

	self.selected = index
	self:CollapseDropDown()
	self:Invalidate()

	self:CallListeners(self.OnSelect, index, self.items[index])
end

--- Gets selected item index
-- @function ComboBox:GetSelected
-- @return number Selected index
function ComboBox:GetSelected()
	return self.selected
end

--- Gets selected item text
-- @function ComboBox:GetSelectedItem
-- @return string Selected item text
function ComboBox:GetSelectedItem()
	return self.items[self.selected]
end

--- Sets dropdown items
-- @function ComboBox:SetItems
-- @param items Array of items
function ComboBox:SetItems(items)
	self.items = items
	self.selected = 1
	self:Invalidate()
	if self.expanded then
		self:CollapseDropDown()
		self:ExpandDropDown()
	end
end

--- Draws the combobox
-- @function ComboBox:DrawControl
function ComboBox:DrawControl()
	-- Draw background
	gl.Color(self.backgroundColor)
	gl.Rect(0, 0, self.width, self.height)

	-- Draw selected item
	local text = self.items[self.selected] or ""
	gl.Color(self.color)
	self.font:Print(text, 5, (self.height - self.font:GetLineHeight()) / 2, 14)
end

--- Handles lost focus
-- @function ComboBox:FocusUpdate
-- @param ... Args
function ComboBox:FocusUpdate(...)
	inherited.FocusUpdate(self, ...)
	if not self:IsFocused() then
		self:CollapseDropDown()
	end
end

--- Closes the dropdown window.
-- Disposes of the dropdown window and resets the pressed state.
function ComboBox:_CloseWindow()
	if self._dropDownWindow then
		self._dropDownWindow:Dispose()
		self._dropDownWindow = nil
	end
	if self.state.pressed then
		self.state.pressed = false
		self:Invalidate()
		return self
	end
end

--- Updates the focus state of the ComboBox.
-- Closes the dropdown window if the ComboBox loses focus.
function ComboBox:FocusUpdate()
	if not self.state.focused then
		self:_CloseWindow()
	end
end

--- Handles the mouse up event.
-- Overrides the Button:MouseUp method to prevent changes to the pressed state.
-- @param ... Additional arguments passed to the event.
-- @return ComboBox Returns the ComboBox instance.
function ComboBox:MouseUp(...)
	self:Invalidate()
	return self
end
