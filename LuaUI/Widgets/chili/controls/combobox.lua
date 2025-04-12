--//=============================================================================

--- ComboBox module

---@class ComboBox : Button
---@field classname string The class name
---@field caption string Display caption
---@field defaultWidth number Default width
---@field defaultHeight number Default height
---@field items table<number,string|table> Items in the ComboBox
---@field selected number ID of the selected item
---@field OnSelect function[] Listener functions for selection changes
---@field maxDropDownHeight number Maximum height of dropdown
---@field minDropDownHeight number Minimum height of dropdown
---@field maxDropDownWidth number Maximum width of dropdown
---@field minDropDownWidth number Minimum width of dropdown
ComboBox = Button:Inherit({
	classname = "combobox",
	caption = "combobox",
	defaultWidth = 70,
	defaultHeight = 20,
	items = { "items" },
	selected = 1,
	OnSelect = {},
	maxDropDownHeight = 200,
	minDropDownHeight = 50,
	maxDropDownWidth = 500,
	minDropDownWidth = 50,
})

---@class ComboBoxWindow : Window
local ComboBoxWindow = Window:Inherit({ classname = "combobox_window", resizable = false, draggable = false })

---@class ComboBoxScrollPanel : ScrollPanel
local ComboBoxScrollPanel = ScrollPanel:Inherit({ classname = "combobox_scrollpanel", horizontalScrollbar = false })

---@class ComboBoxStackPanel : StackPanel
local ComboBoxStackPanel = StackPanel:Inherit({
	classname = "combobox_stackpanel",
	autosize = true,
	resizeItems = false,
	borderThickness = 0,
	padding = { 0, 0, 0, 0 },
	itemPadding = { 0, 0, 0, 0 },
	itemMargin = { 0, 0, 0, 0 },
})

---@class ComboBoxItem : Button
local ComboBoxItem = Button:Inherit({ classname = "combobox_item" })

local this = ComboBox
local inherited = this.inherited

---Creates a new ComboBox instance
---@param obj table Configuration object
---@return ComboBox combobox The created combobox
function ComboBox:New(obj)
	obj = inherited.New(self, obj)
	obj:Select(obj.selected or 1)
	return obj
end

---Selects an item by index
---@param itemIdx number Index of item to select
---@return nil
function ComboBox:Select(itemIdx)
	if type(itemIdx) == "number" then
		local item = self.items[itemIdx]
		if not item then
			return
		end
		self.selected = itemIdx
		self.caption = ""

		if type(item) == "string" then
			self.caption = item
		end
		self:CallListeners(self.OnSelect, itemIdx, true)
		self:Invalidate()
	end
	--FIXME add Select(name)
end

---Closes the dropdown window if open
---@return ComboBox|nil self Returns self if window was closed
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

---Handles focus update
---@return nil
function ComboBox:FocusUpdate()
	if not self.state.focused then
		self:_CloseWindow()
	end
end

---Handles mouse down event - opens/closes dropdown
---@param ... any Additional parameters
---@return ComboBox self
function ComboBox:MouseDown(...)
	self.state.pressed = true
	if not self._dropDownWindow then
		local sx, sy = self:LocalToScreen(0, 0)

		local labels = {}
		local labelHeight = 20

		local width = math.max(self.width, self.minDropDownWidth)
		local height = 10
		for i = 1, #self.items do
			local item = self.items[i]
			if type(item) == "string" then
				local newBtn = ComboBoxItem:New({
					caption = item,
					width = "100%",
					height = labelHeight,
					state = { focused = (i == self.selected), selected = (i == self.selected) },
					OnMouseUp = {
						function()
							self:Select(i)
							self:_CloseWindow()
						end,
					},
				})
				labels[#labels + 1] = newBtn
				height = height + labelHeight
				width = math.max(width, self.font:GetTextWidth(item))
			else
				labels[#labels + 1] = item
				item.OnMouseUp = {
					function()
						self:Select(i)
						self:_CloseWindow()
					end,
				}
				width = math.max(width, item.width + 5)
				height = height + item.height -- FIXME: what if this height is relative?
			end
		end

		height = math.max(self.minDropDownHeight, height)
		height = math.min(self.maxDropDownHeight, height)
		width = math.min(self.maxDropDownWidth, width)

		local screen = self:FindParent("screen")
		local y = sy + self.height
		if y + height > screen.height then
			y = sy - height
		end

		self._dropDownWindow = ComboBoxWindow:New({
			parent = screen,
			width = width,
			height = height,
			x = sx - (width - self.width),
			y = y,
			children = {
				ComboBoxScrollPanel:New({
					width = "100%",
					height = "100%",
					children = {
						ComboBoxStackPanel:New({
							width = "100%",
							children = labels,
						}),
					},
				}),
			},
		})
	else
		self:_CloseWindow()
	end

	self:Invalidate()
	return self
end

---Handles mouse up event
---@param ... any Additional parameters
---@return ComboBox self
function ComboBox:MouseUp(...)
	self:Invalidate()
	return self
	-- this exists to override Button:MouseUp so it doesn't modify .state.pressed
end
