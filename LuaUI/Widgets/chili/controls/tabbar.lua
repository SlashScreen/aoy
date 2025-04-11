--//=============================================================================

--- TabBar
--- A TabBar is a horizontal or vertical bar of tabs. Each tab can be selected, and the selected tab can be used to display different content.
--- @class TabBar: LayoutPanel
--- @field orientation string Orientation of the tab bar ("horizontal" or "vertical")
--- @field resizeItems boolean Resize items to fill width/height
--- @field centerItems boolean Center items in cross direction
--- @field padding [number, number, number, number] Padding between items
--- @field itemPadding [number, number, number, number] Padding around items
--- @field itemMargin [number, number, number, number] Margin around items
--- @field minItemWidth number Minimum item width
--- @field minItemHeight number Minimum item height
--- @field tabs string[] List of tab names
--- @field selected string? Selected tab name
--- @field OnChange function[] Tab change event listeners

TabBar = LayoutPanel:Inherit({
	classname = "tabbar",
	orientation = "horizontal",
	resizeItems = false,
	centerItems = false,
	padding = { 0, 0, 0, 0 },
	itemPadding = { 0, 0, 0, 0 },
	itemMargin = { 0, 0, 0, 0 },
	minItemWidth = 70,
	minItemHeight = 20,
	tabs = {},
	selected = nil,
	OnChange = {},
})

local this = TabBar
local inherited = this.inherited

--//=============================================================================

function TabBar:New(obj)
	obj = inherited.New(self, obj)
	if obj.tabs then
		for i = 1, #obj.tabs do
			obj:AddChild(
				TabBarItem:New({
					caption = obj.tabs[i],
					defaultWidth = obj.minItemWidth,
					defaultHeight = obj.minItemHeight,
				}) --FIXME inherit font too
			)
		end
	end

	if not obj.children[1] then
		obj:AddChild(TabBarItem:New({ caption = "tab" }))
	end

	obj:Select(obj.selected)

	return obj
end

--//=============================================================================

function TabBar:SetOrientation(orientation)
	inherited.SetOrientation(self, orientation)
end

--//=============================================================================

function TabBar:Select(tabname)
	for i = 1, #self.children do
		local c = self.children[i]
		if c.caption == tabname then
			if self.selected_obj then
				self.selected_obj.state.selected = false
				self.selected_obj:Invalidate()
			end
			c.state.selected = true
			self.selected_obj = c
			c:Invalidate()
			self:CallListeners(self.OnChange, tabname)
			return true
		end
	end

	if not self.selected_obj then
		local c = self.children[1]
		c.state.selected = true
		self.selected_obj = c
		self.selected_obj:Invalidate()
		self:CallListeners(self.OnChange, c.caption)
	end

	return false
end

--//=============================================================================
