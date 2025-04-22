--- Grid module

--- @deprecated Unimplemented
--- @class Grid : LayoutPanel
--- @field resizeItems boolean Whether to resize items automatically
--- @field itemPadding [number, number, number, number] Padding around each item, default {0, 0, 0, 0}
Grid = LayoutPanel:Inherit({
	classname = "grid",
	resizeItems = true,
	itemPadding = { 0, 0, 0, 0 },
})
