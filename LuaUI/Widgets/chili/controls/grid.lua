--- Grid module
--- A layout control that arranges child controls in a grid pattern.

--- Grid fields
-- Inherits from LayoutPanel.
-- @see layoutpanel.LayoutPanel
-- @table Grid
-- @int[opt=1] columns Number of columns in grid
-- @int[opt=1] rows Number of rows in grid
-- @bool[opt=false] autosize Automatically size to fit content
-- @bool[opt=false] resizeItems Resize items to fill cells
-- @bool[opt=true] centerItems Center items in cells
-- @tparam {left,top,right,bottom} itemPadding Padding inside cells
-- @tparam {left,top,right,bottom} itemMargin Margin between cells
-- @int[opt=1] minItemWidth Minimum item width
-- @int[opt=1] minItemHeight Minimum item height
-- @tparam table cellWeight Weight/size ratio for each cell

Grid = LayoutPanel:Inherit({
	classname = "grid",
	columns = 1,
	rows = 1,

	autosize = false,
	resizeItems = false,
	centerItems = true,

	itemPadding = { 5, 5, 5, 5 },
	itemMargin = { 5, 5, 5, 5 },

	minItemWidth = 1,
	minItemHeight = 1,

	cellWeight = nil, -- {col1, col2, ...}, {row1, row2, ...}

	OnResize = {},
})

local this = Grid
local inherited = this.inherited

--- Creates a new Grid instance
-- @function Grid:New
-- @param obj Table of grid properties
-- @return Grid The newly created grid
function Grid:New(obj)
	obj = inherited.New(self, obj)

	-- Initialize cell weights if not provided
	if not obj.cellWeight then
		obj.cellWeight = { {}, {} }
		for i = 1, obj.columns do
			obj.cellWeight[1][i] = 1
		end
		for i = 1, obj.rows do
			obj.cellWeight[2][i] = 1
		end
	end

	return obj
end

--- Updates the grid layout
-- @function Grid:UpdateLayout
-- @return boolean True if layout was updated
function Grid:UpdateLayout()
	if not self.children[1] then
		return false
	end

	local cn = self.children
	local cols = self.columns
	local rows = math.ceil(#cn / cols)

	-- Calculate cell dimensions
	local cellWidth = self.clientArea[3] / cols
	local cellHeight = self.clientArea[4] / rows

	-- Position children in grid
	for i = 1, #cn do
		local child = cn[i]
		local row = math.floor((i - 1) / cols)
		local col = (i - 1) % cols

		local x = col * cellWidth
		local y = row * cellHeight

		-- Apply weights if specified
		if self.cellWeight then
			local colWeight = self.cellWeight[1][col + 1] or 1
			local rowWeight = self.cellWeight[2][row + 1] or 1

			cellWidth = cellWidth * colWeight
			cellHeight = cellHeight * rowWeight
		end

		-- Center in cell if enabled
		if self.centerItems then
			x = x + (cellWidth - child.width) / 2
			y = y + (cellHeight - child.height) / 2
		end

		-- Apply margin and padding
		x = x + self.itemMargin[1] + self.itemPadding[1]
		y = y + self.itemMargin[2] + self.itemPadding[2]

		-- Resize if enabled
		if self.resizeItems then
			child.width = cellWidth
				- self.itemMargin[1]
				- self.itemMargin[3]
				- self.itemPadding[1]
				- self.itemPadding[3]
			child.height = cellHeight
				- self.itemMargin[2]
				- self.itemMargin[4]
				- self.itemPadding[2]
				- self.itemPadding[4]
		end

		child:SetPos(x, y)
	end

	return true
end

--- Sets the number of columns
-- @function Grid:SetColumns
-- @param cols Number of columns
function Grid:SetColumns(cols)
	self.columns = cols
	self:UpdateLayout()
	self:Invalidate()
end

--- Sets cell weights for sizing
-- @function Grid:SetCellWeight
-- @param colWeights Array of column weights
-- @param rowWeights Array of row weights
function Grid:SetCellWeight(colWeights, rowWeights)
	self.cellWeight = { colWeights or {}, rowWeights or {} }
	self:UpdateLayout()
	self:Invalidate()
end

--- Updates client area and triggers layout update.
-- @bool dontUpdateChildren If true, child controls won't be updated.
function Grid:UpdateClientArea(dontUpdateChildren)
	-- ...existing code...
end

--- Sets grid dimensions.
-- Updates the number of rows and columns in the grid.
-- @int numRows New number of rows.
-- @int numCols New number of columns.
function Grid:SetGrid(numRows, numCols)
	-- ...existing code...
end

--- Adds a child to the grid.
-- Places the new child in the next available grid cell.
-- @tparam Control obj The child control to add.
-- @param dontUpdate If true, layout won't be updated immediately.
function Grid:AddChild(obj, dontUpdate)
	-- ...existing code...
end

--- Removes a child from the grid.
-- Updates grid layout after removal.
-- @tparam Control obj The child control to remove.
-- @return boolean True if child was removed successfully.
function Grid:RemoveChild(obj)
	-- ...existing code...
end
