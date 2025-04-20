--//=============================================================================

---@class Line : Control
---@field caption? string text to be displayed on the line(?)
---@field style? "horizontal" | "vertical" style of the line

Line = Control:Inherit({
	classname = "line",
	caption = "line",
	defaultWidth = 100,
	defaultHeight = 1,
	style = "horizontal",
})

local this = Line
local inherited = this.inherited

--//=============================================================================
