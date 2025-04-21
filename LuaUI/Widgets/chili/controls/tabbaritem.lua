--//=============================================================================

---@class TabBarItem : Button
---@field height string|number Item height
TabBarItem = Button:Inherit({
	caption = "tab",
	height = "100%",
})

local this = TabBarItem
local inherited = this.inherited

--//=============================================================================

---Set the caption of the TabBarItem
---@param caption string The new caption
function TabBarItem:SetCaption(caption)
	--FIXME inform parent
	if self.caption == caption then
		return
	end
	self.caption = caption
	self:Invalidate()
end

--//=============================================================================

---Handle mouse down event for TabBarItem
---@param ... any
---@return TabBarItem|nil
function TabBarItem:MouseDown(...)
	if not self.parent then
		return
	end
	self.parent:Select(self.caption)
	inherited.MouseDown(self, ...)
	return self
end

--//=============================================================================
