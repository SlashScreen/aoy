--//=============================================================================

--- StackPanel module

---@class StackPanel : LayoutPanel
---@field classname string The class name
---@field orientation "vertical"|"horizontal" Panel orientation
---@field resizeItems boolean Whether to resize items
---@field itemPadding number[] Item padding {left,top,right,bottom}
---@field itemMargin number[] Item margin {left,top,right,bottom}
StackPanel = LayoutPanel:Inherit({
	classname = "stackpanel",
	orientation = "vertical",
	resizeItems = true,
	itemPadding = { 0, 0, 0, 0 },
	itemMargin = { 5, 5, 5, 5 },
})

local this = StackPanel
local inherited = this.inherited

--//=============================================================================

---Creates a new StackPanel instance
---@param obj table Configuration object
---@return StackPanel panel The created panel
function StackPanel:New(obj)
	if obj.orientation == "horizontal" then
		obj.rows, obj.columns = 1, nil
	else
		obj.rows, obj.columns = nil, 1
	end
	obj = inherited.New(self, obj)
	return obj
end

--//=============================================================================

---Sets the panel orientation
---@param orientation "vertical"|"horizontal" New orientation
---@return nil
function StackPanel:SetOrientation(orientation)
	if orientation == "horizontal" then
		self.rows, self.columns = 1, nil
	else
		self.rows, self.columns = nil, 1
	end

	inherited.SetOrientation(self, orientation)
end

--//=============================================================================
