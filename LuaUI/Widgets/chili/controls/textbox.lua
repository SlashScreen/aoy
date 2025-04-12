--- TextBox module
--- A control for displaying and optionally editing multi-line text.
--- @class TextBox: Control
--- @field text string Current text content
--- @field selStart integer? Start of text selection
--- @field selEnd integer? End of text selection
--- @field cursor integer Current cursor position
--- @field editable boolean Text can be edited
--- @field multiline boolean Allow multiple lines
--- @field textColor Color Text color (default {1,1,1,1})
--- @field selectedTextColor Color Selected text color (default {1,1,1,1})
--- @field selectionColor Color Selection background color (default {0,0.5,1,0.3})
--- @field passwordInput boolean Mask text input as password
--- @field selectable boolean Text can be selected
--- @field OnTextInput function[] Text input event listeners
--- @field OnTextChange function[] Text change event listeners
--- @field OnSelectText function[] Text selection event listeners

TextBox = Control:Inherit({
	classname = "textbox",
	text = "",
	selStart = nil,
	selEnd = nil,
	cursor = 1,

	editable = true,
	multiline = false,

	textColor = { 1, 1, 1, 1 },
	selectedTextColor = { 1, 1, 1, 1 },
	selectionColor = { 0, 0.5, 1, 0.3 },

	passwordInput = false,
	selectable = true,

	OnTextInput = {},
	OnTextChange = {},
	OnSelectText = {},
})

local this = TextBox
local inherited = this.inherited

--- Creates a new TextBox instance
--- @param obj table Table of textbox properties
--- @return TextBox The newly created textbox
function TextBox:New(obj)
	obj = inherited.New(self, obj)
	obj:RequestFocus()
	return obj
end

--- Sets the text content
--- @param newText string Text to set
function TextBox:SetText(newText)
	if self.text == newText then
		return
	end

	self.text = newText or ""
	self.cursor = utf8.len(self.text) + 1
	self.selStart = nil
	self.selEnd = nil

	self:CallListeners(self.OnTextChange, self.text)
	self:Invalidate()
end

--- Gets the current text
--- @return string Current text
function TextBox:GetText()
	return self.text
end

--- Gets selected text
--- @return string? Selected text or nil
function TextBox:GetSelection()
	if not self.selStart then
		return nil
	end

	local s = math.min(self.selStart, self.selEnd)
	local e = math.max(self.selStart, self.selEnd)
	return self.text:sub(s, e - 1)
end

--- Handle text input events
--- @param char string Character input
--- @param ... any Additional args
--- @return boolean True if handled
function TextBox:TextInput(char, ...)
	if not self.editable then
		return false
	end

	local text = self.text
	if self.selStart then
		-- Replace selection
		text = text:sub(1, self.selStart - 1) .. text:sub(self.selEnd)
		self.cursor = self.selStart
		self.selStart = nil
		self.selEnd = nil
	end

	-- Insert character
	text = text:sub(1, self.cursor - 1) .. char .. text:sub(self.cursor)
	self.text = text
	self.cursor = self.cursor + 1

	self:CallListeners(self.OnTextInput, char)
	self:CallListeners(self.OnTextChange, self.text)
	self:Invalidate()

	return self
end

--- Draws the textbox
function TextBox:DrawControl()
	local text = self.text
	if self.passwordInput then
		text = string.rep("*", #text)
	end

	-- Draw selection if any
	if self.selStart then
		local s = math.min(self.selStart, self.selEnd)
		local e = math.max(self.selStart, self.selEnd)

		local preText = text:sub(1, s - 1)
		local selText = text:sub(s, e - 1)

		local x = self.font:GetTextWidth(preText)
		local w = self.font:GetTextWidth(selText)

		gl.Color(self.selectionColor)
		gl.Rect(x, 0, x + w, self.font:GetLineHeight())
	end

	-- Draw cursor if focused
	if self.state.focused then
		local preText = text:sub(1, self.cursor - 1)
		local x = self.font:GetTextWidth(preText)

		gl.Color(1, 1, 1, Spring.GetGameFrame() % 30 < 15 and 1 or 0)
		gl.Rect(x, 1, x + 1, self.font:GetLineHeight() - 1)
	end

	-- Draw text
	gl.Color(self.textColor)
	self.font:Print(text, 0, 0)
end

local function Split(s, separator)
	local results = {}
	for part in s:gmatch("[^" .. separator .. "]+") do
		results[#results + 1] = part
	end
	return results
end

-- remove first n elemets from t, return them
local function Take(t, n)
	local removed = {}
	for i = 1, n do
		removed[#removed + 1] = table.remove(t, 1)
	end
	return removed
end

-- appends t1 to t2 in-place
local function Append(t1, t2)
	local l = #t1
	for i = 1, #t2 do
		t1[i + l] = t2[i]
	end
end

--- Updates the textbox layout
function TextBox:UpdateLayout()
	local font = self.font
	local padding = self.padding
	local width = self.width - padding[1] - padding[3]
	local height = self.height - padding[2] - padding[4]
	if self.autoHeight then
		height = 1e9
	end

	self._wrappedText = font:WrapText(self.text, width, height)

	if self.autoHeight then
		local textHeight, textDescender, numLines = font:GetTextHeight(self._wrappedText)
		textHeight = textHeight - textDescender

		if self.autoObeyLineHeight then
			if numLines > 1 then
				textHeight = numLines * font:GetLineHeight()
			else
				--// AscenderHeight = LineHeight w/o such deep chars as 'g','p',...
				textHeight = math.min(math.max(textHeight, font:GetAscenderHeight()), font:GetLineHeight())
			end
		end

		self:Resize(nil, textHeight, true, true)
	end
end
