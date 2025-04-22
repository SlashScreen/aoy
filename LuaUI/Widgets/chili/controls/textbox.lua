--- TextBox module

---@class TextBox : Control
---@field text string Text content
---@field autoHeight boolean Whether height adjusts to content
---@field autoObeyLineHeight boolean Whether to obey line height in autosize
---@field align "left"|"center"|"right" Text alignment
---@field valign "top"|"center"|"bottom" Vertical alignment
---@field font table Font configuration
---@field OnTextClick function[] Text click listeners
---@field _wrappedText string[] Wrapped text lines
---@field _lines string[] Lines of text, split by newlines
---@field fontsize number Font size
TextBox = EditBox:Inherit({
	classname = "textbox",

	padding = { 0, 0, 0, 0 },

	text = "line1\nline2",
	autoHeight = true,
	autoObeyLineHeight = true,

	editable = false,
	selectable = false,
	multiline = true,
	noFont = false,
	noHint = true,

	borderColor = { 0, 0, 0, 0 },
	focusColor = { 0, 0, 0, 0 },
	backgroundColor = { 0, 0, 0, 0 },
})

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function TextBox:DrawControl()
	local paddx, paddy = unpack4(self.clientArea)
	local x = paddx
	local y = paddy

	local font = self.font
	font:Draw(self._wrappedText, x, y)

	if self.debug then
		gl.Color(0, 1, 0, 0.5)
		gl.PolygonMode(GL.FRONT_AND_BACK, GL.LINE)
		gl.LineWidth(2)
		gl.Rect(0, 0, self.width, self.height)
		gl.LineWidth(1)
		gl.PolygonMode(GL.FRONT_AND_BACK, GL.FILL)
	end
end
