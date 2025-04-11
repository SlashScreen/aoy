--- Grid module
--- A layout control that arranges child controls in a grid pattern.
--- Note that, for whatever reason, this is not implemented and does not work. Sorry!
--- @class Grid: LayoutPanel
--- @field resizeItems boolean Resize items to fill cells
--- @field itemPadding number[] Padding inside cells

Grid = LayoutPanel:Inherit({
	classname = "grid",
	resizeItems = true,
	itemPadding = { 0, 0, 0, 0 },
})

local this = Grid
local inherited = this.inherited
