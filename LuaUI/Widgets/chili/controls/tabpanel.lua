--//=============================================================================

--- TabPanel and TabBar modules
--- Controls for creating tabbed interfaces with selectable pages.

--- TabBar fields
-- Inherits from Control.
-- @see control.Control
-- @table TabBar
-- @tparam table tabs Array of tab items
-- @int[opt=1] selected Index of selected tab
-- @bool[opt=false] vertical Tabs are arranged vertically
-- @tparam {r,g,b,a} selectedColor Selected tab color
-- @tparam function{} OnChange Tab change event listeners

--- TabPanel fields
-- Inherits from Control.
-- @see control.Control
-- @table TabPanel
-- @tparam TabBar tabBar The tab bar control
-- @tparam table tabs Array of tab pages
-- @int[opt=1] currentTab Index of current tab page
-- @tparam function{} OnTabChange Tab change event listeners

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
-- @function TabBar:New
-- @param obj Table of properties
-- @return TabBar The newly created tab bar
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
-- @function TabBar:AddTab
-- @param tabData Tab data/properties
-- @return table Created tab button
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
-- @function TabBar:Select
-- @param index Tab index to select
function TabBar:Select(index)
	if self.selected == index then
		return
	end

	self.selected = index
	self:Invalidate()

	self:CallListeners(self.OnChange, index)
end

--- Creates a new TabPanel instance
-- @function TabPanel:New
-- @param obj Table of properties
-- @return TabPanel The newly created tab panel
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
-- @function TabPanel:AddTab
-- @string caption Tab caption
-- @param children Child controls
-- @return table Created tab page
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

--- TabPanel fields.
-- Inherits from LayoutPanel.
-- @see layoutpanel.LayoutPanel
-- @table TabPanel
-- @tparam {tab1,tab2,...} tabs contained in the tab panel, each tab has a .name (string) and a .children field (table of Controls)(default {})
-- @tparam chili.Control currentTab currently visible tab
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

--//=============================================================================

function TabPanel:ChangeTab(tabname)
	if not tabname or not self.tabIndexMapping[tabname] then
		return
	end
	self.currentFrame:SetVisibility(false)
	self.currentFrame = self.tabIndexMapping[tabname]
	self.currentFrame:SetVisibility(true)
end
--//=============================================================================
