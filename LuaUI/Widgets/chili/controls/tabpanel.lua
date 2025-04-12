--//=============================================================================

--- @class TabBar: Control
--- @field tabs TabBarItem[] Array of tab items
--- @field selected integer Index of selected tab
--- @field vertical boolean Tabs are arranged vertically
--- @field selectedColor Color Selected tab color
--- @field defaultWidth number Default tab width
--- @field defaultHeight number Default tab height
--- @field OnChange function[] Tab change event listeners

--- @class TabPanel: Control
--- @field tabs TabBarItem[] Array of tab pages
--- @field currentTab integer Index of current tab page
--- @field OnTabChange function[] Tab change event listeners

TabBar = Control:Inherit({
	classname = "tabbar",
	tabs = {},
	selected = 1,
	vertical = false,

	selectedColor = { 1, 0.7, 0.1, 0.8 },
	defaultWidth = 70,
	defaultHeight = 20,

	OnChange = {},
})

TabPanel = Control:Inherit({
	classname = "tabpanel",
	tabs = {},
	currentTab = 1,

	OnTabChange = {},
})

local this = TabBar
local inherited = this.inherited

--- Creates a new TabBar instance
--- @param obj table Table of properties
--- @return TabBar The newly created tab bar
function TabBar:New(obj)
	obj = inherited.New(self, obj)

	obj.tabs = {}
	if obj._tabs then
		for i = 1, #obj._tabs do
			obj:AddTab(obj._tabs[i])
		end
	end

	return obj
end

--- Adds a new tab
--- @param tabData table Tab data/properties
--- @return table Created tab button
function TabBar:AddTab(tabData)
	local tab = Button:New({
		x = #self.tabs * self.defaultWidth,
		width = self.defaultWidth,
		height = self.defaultHeight,
		caption = tabData.caption or "",
		OnClick = {
			function()
				self:Select(#self.tabs + 1)
			end,
		},
	})

	table.insert(self.tabs, tab)
	self:AddChild(tab)

	return tab
end

--- Selects a tab
--- @param index number Tab index to select
function TabBar:Select(index)
	if self.selected == index then
		return
	end

	self.selected = index
	self:Invalidate()

	self:CallListeners(self.OnChange, index)
end

--- Creates a new TabPanel instance
--- @param obj table Table of properties
--- @return TabPanel The newly created tab panel
function TabPanel:New(obj)
	obj = inherited.New(self, obj)

	-- Create tab bar
	obj.tabBar = TabBar:New({
		x = 0,
		y = 0,
		right = 0,
		height = 20,
		OnChange = {
			function(self, tabIndex)
				obj:SelectTab(tabIndex)
			end,
		},
	})
	obj:AddChild(obj.tabBar)

	-- Create tab pages
	obj.tabPages = {}
	if obj.tabs then
		for i = 1, #obj.tabs do
			local tab = obj.tabs[i]
			obj:AddTab(tab.caption, tab.children)
		end
	end

	return obj
end

--- Adds a new tab page
--- @param caption string Tab caption
--- @param children table Child controls
--- @return table Created tab page
function TabPanel:AddTab(caption, children)
	-- Add tab button
	self.tabBar:AddTab({ caption = caption })

	-- Create tab page
	local page = Control:New({
		x = 0,
		y = 25,
		right = 0,
		bottom = 0,
		visible = (#self.tabPages == 0),
	})

	-- Add child controls
	if children then
		for i = 1, #children do
			page:AddChild(children[i])
		end
	end

	table.insert(self.tabPages, page)
	self:AddChild(page)

	return page
end

--- Selects a tab page
-- @function TabPanel:SelectTab
-- @param index Tab index to select
function TabPanel:SelectTab(index)
	if self.currentTab == index then
		return
	end

	-- Hide current tab
	if self.tabPages[self.currentTab] then
		self.tabPages[self.currentTab].visible = false
	end

	self.currentTab = index

	-- Show new tab
	if self.tabPages[index] then
		self.tabPages[index].visible = true
	end

	self:CallListeners(self.OnTabChange, index)
end

--//=============================================================================

--- TabPanel module
--- A control that organizes content into selectable tabs
---@class TabPanel: LayoutPanel
---@field tabs TabItem[] Array of tab items
---@field currentTab number Currently selected tab index
---@field tabHeight number Height of tab bar
---@field tabWidth number Width of individual tabs
---@field minTabWidth number Minimum tab width
---@field adjustHeight boolean Whether to adjust height to content
---@field padding number[] Padding around content [left,top,right,bottom]
---@field tabBarColor Color Tab bar background color [r,g,b,a]
---@field tabSelectedColor Color Selected tab color [r,g,b,a]
---@field contentBorderColor Color Content border color [r,g,b,a]
---@field OnTabChange function[] Called when selected tab changes

---@class TabItem
---@field caption string Tab label text
---@field control Control Content control for tab
---@field width number? Custom tab width
---@field font Font? Custom font for tab
---@field color Color? Custom tab color

TabPanel = LayoutPanel:Inherit({
	classname = "tabpanel",
	orientation = "vertical",
	resizeItems = false,
	itemPadding = { 0, 0, 0, 0 },
	itemMargin = { 0, 0, 0, 0 },
	barHeight = 40,
	tabs = {},
	currentTab = {},
})

local this = TabPanel
local inherited = this.inherited

--//=============================================================================

--- Creates a new TabPanel instance
---@param obj table Table with tab panel properties
---@return TabPanel The created tab panel
function TabPanel:New(obj)
	obj = inherited.New(self, obj)

	local tabNames = {}
	for i = 1, #obj.tabs do
		tabNames[i] = obj.tabs[i].name
	end
	obj:AddChild(TabBar:New({
		tabs = tabNames,
		x = 0,
		y = 0,
		right = 0,
		height = obj.barHeight,
	}))

	obj.currentTab = Control:New({
		x = 0,
		y = obj.barHeight,
		right = 0,
		bottom = 0,
		padding = { 0, 0, 0, 0 },
	})
	obj:AddChild(obj.currentTab)
	obj.tabIndexMapping = {}
	for i = 1, #obj.tabs do
		local tabName = obj.tabs[i].name
		local tabFrame = Control:New({
			padding = { 0, 0, 0, 0 },
			x = 0,
			y = 0,
			right = 0,
			bottom = 0,
			children = obj.tabs[i].children,
		})
		obj.tabIndexMapping[tabName] = tabFrame
		obj.currentTab:AddChild(tabFrame)
		if i == 1 then
			obj.currentFrame = tabFrame
		else
			tabFrame:SetVisibility(false)
		end
	end
	obj.children[1].OnChange = {
		function(tabbar, tabname)
			obj:ChangeTab(tabname)
		end,
	}
	return obj
end

--- Adds a new tab page
--- @param tab table
function TabPanel:AddTab(tab)
	local tabbar = self.children[1]
	tabbar:AddChild(
		TabBarItem:New({ caption = tab.name, defaultWidth = tabbar.minItemWidth, defaultHeight = tabbar.minItemHeight }) --FIXME: implement an "Add Tab in TabBar too"
	)
	local tabFrame = Control:New({
		padding = { 0, 0, 0, 0 },
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		children = tab.children,
	})
	self.tabIndexMapping[tab.name] = tabFrame
	self.currentTab:AddChild(tabFrame)
	tabFrame:SetVisibility(false)
end

--- Changes the current tab to the specified tab name
---@param tabname string
function TabPanel:ChangeTab(tabname)
	if not tabname or not self.tabIndexMapping[tabname] then
		return
	end
	self.currentFrame:SetVisibility(false)
	self.currentFrame = self.tabIndexMapping[tabname]
	self.currentFrame:SetVisibility(true)
end
