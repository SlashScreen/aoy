--//=============================================================================

--- TabPanel module

--- @class TabPanel : LayoutPanel
--- @field public tabs table<string, table> A table containing the tabs in the tab panel. Each tab has a `name` (string) and a `children` field (table of Controls).
--- @field public currentTab Control The currently visible tab.
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

---Creates a new TabPanel instance
---@param obj table Configuration object
---@return TabPanel panel The created panel
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

---Add a new tab to the TabPanel
---@param tab table Tab definition (must have .name and .children)
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

---Change the currently visible tab
---@param tabname string Name of the tab to show
function TabPanel:ChangeTab(tabname)
	if not tabname or not self.tabIndexMapping[tabname] then
		return
	end
	self.currentFrame:SetVisibility(false)
	self.currentFrame = self.tabIndexMapping[tabname]
	self.currentFrame:SetVisibility(true)
end
--//=============================================================================
