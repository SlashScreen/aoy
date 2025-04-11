--//=============================================================================

--- TabBarItem is a button that can be used in a TabBar.
--- @class TabBarItem: Button
--- @field caption string Tab name
--- @field height string Tab height

TabBarItem = Button:Inherit({
	classname = "tabbaritem",
	caption = "tab",
	height = "100%",
})

local this = TabBarItem
local inherited = this.inherited

--//=============================================================================

function TabBarItem:SetCaption(caption)
	--FIXME inform parent
	if self.caption == caption then
		return
	end
	self.caption = caption
	self:Invalidate()
end

--//=============================================================================

function TabBarItem:MouseDown(...)
	if not self.parent then
		return
	end
	self.parent:Select(self.caption)
	inherited.MouseDown(self, ...)
	return self
end

--//=============================================================================
