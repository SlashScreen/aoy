--//=============================================================================

--- EditBox module
--- A text input control that allows users to enter and edit text.
--- @class EditBox: Control
--- @field text string Current text content
--- @field hint string Hint text shown when empty
--- @field selectable boolean Text can be selected
--- @field multiline boolean Allow multiple lines
--- @field editable boolean Text can be edited
--- @field cursorColor Color Color of text cursor (default {0,0,1,0.7})
--- @field selectionColor Color Color of selected text (default {0,0,1,0.3})
--- @field OnTextInput function[] Text input event listeners
--- @field OnKeyPress function[] Key press event listeners
--- @field OnEnterPress function[] Enter key press listeners
--- @field defaultWidth number Default width of the control
--- @field defaultHeight number Default height of the control
--- @field padding number[] Padding around the text (default {3,3,3,3})
--- @field cursorPos number Current cursor position in the string
--- @field selStart number? Start position of selected text
--- @field selEnd number? End position of selected text

EditBox = Control:Inherit({
	classname = "editbox",
	text = "",
	hint = "",

	defaultWidth = 70,
	defaultHeight = 20,
	padding = { 3, 3, 3, 3 },

	selectable = true,
	editable = true,
	multiline = false,

	cursorPos = 1,
	selStart = nil,
	selEnd = nil,

	cursorColor = { 0, 0, 1, 0.7 },
	selectionColor = { 0, 0, 1, 0.3 },

	OnTextInput = {},
	OnKeyPress = {},
	OnEnterPress = {},
})

local this = EditBox
local inherited = this.inherited

--- Creates a new EditBox instance
-- @function EditBox:New
-- @param obj Table of editbox properties
-- @return EditBox The newly created editbox
function EditBox:New(obj)
	obj = inherited.New(self, obj)
	obj:UpdateLayout()
	return obj
end

--- Sets the editbox text
-- @function EditBox:SetText
-- @string newText Text to set
function EditBox:SetText(newText)
	if self.text == newText then
		return
	end
	self.text = newText or ""
	self.cursor = utf8.len(self.text) + 1
	self.selStart = nil
	self.selEnd = nil
	self:Invalidate()
end

--- Gets the current text
-- @function EditBox:GetText
-- @return string Current text
function EditBox:GetText()
	return self.text
end

--- Handle text input events
-- @function EditBox:TextInput
-- @string char Character being input
-- @param ... Additional args
-- @return boolean True if handled
function EditBox:TextInput(char, ...)
	if not self.editable then
		return false
	end

	local text = self.text
	if self.selStart then
		text = text:sub(1, self.selStart - 1) .. text:sub(self.selEnd)
		self.cursor = self.selStart
		self.selStart = nil
		self.selEnd = nil
	end

	text = text:sub(1, self.cursor - 1) .. char .. text:sub(self.cursor)
	self.text = text
	self.cursor = self.cursor + 1

	self:Invalidate()
	return self
end

--- Handle key press events
-- @function EditBox:KeyPress
-- @param key Key being pressed
-- @param mods Modifier keys
-- @param isRepeat Is key repeat
-- @param label Key label
-- @param ... Additional args
-- @return boolean True if handled
function EditBox:KeyPress(key, mods, isRepeat, label, ...)
	-- Handle key commands (copy, paste, etc)
	if mods.ctrl then
		if key == Spring.KEYSYMS.V then
			-- Paste
			local text = Spring.GetClipboard()
			if text then
				self:TextInput(text)
			end
			return self
		elseif key == Spring.KEYSYMS.C then
			-- Copy
			if self.selStart then
				Spring.SetClipboard(self.text:sub(self.selStart, self.selEnd - 1))
			end
			return self
		elseif key == Spring.KEYSYMS.X then
			-- Cut
			if self.selStart then
				Spring.SetClipboard(self.text:sub(self.selStart, self.selEnd - 1))
				self:TextInput("")
			end
			return self
		end
	end

	if key == Spring.KEYSYMS.LEFT then
		if self.cursor > 1 then
			self.cursor = self.cursor - 1
			if not mods.shift then
				self.selStart = nil
				self.selEnd = nil
			end
			self:Invalidate()
		end
		return self
	elseif key == Spring.KEYSYMS.RIGHT then
		if self.cursor <= utf8.len(self.text) then
			self.cursor = self.cursor + 1
			if not mods.shift then
				self.selStart = nil
				self.selEnd = nil
			end
			self:Invalidate()
		end
		return self
	elseif key == Spring.KEYSYMS.BACKSPACE then
		if not self.editable then
			return false
		end

		if self.selStart then
			self:TextInput("")
			return self
		end

		if self.cursor > 1 then
			local text = self.text
			self.text = text:sub(1, self.cursor - 2) .. text:sub(self.cursor)
			self.cursor = self.cursor - 1
			self:Invalidate()
		end
		return self
	elseif key == Spring.KEYSYMS.DELETE then
		if not self.editable then
			return false
		end

		if self.selStart then
			self:TextInput("")
			return self
		end

		if self.cursor <= utf8.len(self.text) then
			local text = self.text
			self.text = text:sub(1, self.cursor - 1) .. text:sub(self.cursor + 1)
			self:Invalidate()
		end
		return self
	elseif key == Spring.KEYSYMS.RETURN or key == Spring.KEYSYMS.NUMPADENTER then
		self:CallListeners(self.OnEnterPress, self.text)
		return self
	end

	return inherited.KeyPress(self, key, mods, isRepeat, label, ...)
end

--- Handle mouse down events
-- @function EditBox:MouseDown
-- @param x Mouse x position
-- @param y Mouse y position
-- @param ... Additional args
-- @return boolean True if handled
function EditBox:MouseDown(x, y, ...)
	if not self:CheckMouseOver(x, y) then
		return false
	end

	local text = self.text
	local cursorPos = 1

	-- Find character position under mouse
	local cx = x - self.padding[1]
	for i = 1, utf8.len(text) do
		local w = self.font:GetTextWidth(text:sub(1, i))
		if w > cx then
			cursorPos = i
			break
		end
		cursorPos = i + 1
	end

	self.cursor = cursorPos
	self.selStart = cursorPos
	self.selEnd = cursorPos
	self:Invalidate()

	inherited.MouseDown(self, x, y, ...)
	return self
end

--- Handle mouse move events for text selection
-- @function EditBox:MouseMove
-- @param x Mouse x position
-- @param y Mouse y position
-- @param dx X movement delta
-- @param dy Y movement delta
-- @param ... Additional args
-- @return boolean True if handled
function EditBox:MouseMove(x, y, dx, dy, ...)
	if not self.selStart then
		return false
	end

	local text = self.text
	local cursorPos = 1

	-- Find character position under mouse
	local cx = x - self.padding[1]
	for i = 1, utf8.len(text) do
		local w = self.font:GetTextWidth(text:sub(1, i))
		if w > cx then
			cursorPos = i
			break
		end
		cursorPos = i + 1
	end

	if cursorPos < self.selStart then
		self.selEnd = self.selStart
		self.selStart = cursorPos
	else
		self.selEnd = cursorPos
	end

	self.cursor = cursorPos
	self:Invalidate()

	inherited.MouseMove(self, x, y, dx, dy, ...)
	return self
end

--- Handle mouse up events
-- @function EditBox:MouseUp
-- @param x Mouse x position
-- @param y Mouse y position
-- @param ... Additional args
-- @return boolean True if handled
function EditBox:MouseUp(x, y, ...)
	if not self.selStart then
		return false
	end

	-- Clear selection if no text selected
	if self.selStart == self.selEnd then
		self.selStart = nil
		self.selEnd = nil
	end

	inherited.MouseUp(self, x, y, ...)
	return self
end

function EditBox:Dispose(...)
	Control.Dispose(self)
	self.hintFont:SetParent()
end

function EditBox:HitTest(x, y)
	return self
end

function EditBox:UpdateLayout()
	local font = self.font

	--FIXME
	if self.autosize then
		local w = font:GetTextWidth(self.text)
		local h, d, numLines = font:GetTextHeight(self.text)

		if self.autoObeyLineHeight then
			h = math.ceil(numLines * font:GetLineHeight())
		else
			h = math.ceil(h - d)
		end

		local x = self.x
		local y = self.y

		if self.valign == "center" then
			y = math.round(y + (self.height - h) * 0.5)
		elseif self.valign == "bottom" then
			y = y + self.height - h
		elseif self.valign == "top" then
		else
		end

		if self.align == "left" then
		elseif self.align == "right" then
			x = x + self.width - w
		elseif self.align == "center" then
			x = math.round(x + (self.width - w) * 0.5)
		end

		w = w + self.padding[1] + self.padding[3]
		h = h + self.padding[2] + self.padding[4]

		self:_UpdateConstraints(x, y, w, h)
	end
end

function EditBox:Update(...)
	--FIXME add special UpdateFocus event?

	--// redraw every few frames for blinking cursor
	inherited.Update(self, ...)

	if self.state.focused then
		self:RequestUpdate()
		if os.clock() >= (self._nextCursorRedraw or -math.huge) then
			self._nextCursorRedraw = os.clock() + 0.1 --10FPS
			self:Invalidate()
		end
	end
end

function EditBox:_SetCursorByMousePos(x, y)
	local clientX = self.clientArea[1]
	if x - clientX < 0 then
		self.offset = self.offset - 1
		self.offset = math.max(0, self.offset)
		self.cursor = self.offset + 1
	else
		local text = self.text
		-- properly accounts for passworded text where characters are represented as "*"
		-- TODO: what if the passworded text is displayed differently? this is using assumptions about the skin
		if #text > 0 and self.passwordInput then
			text = string.rep("*", #text)
		end
		self.cursor = #text + 1 -- at end of text
		for i = self.offset, #text do
			local tmp = text:sub(self.offset, i)
			if self.font:GetTextWidth(tmp) > (x - clientX) then
				self.cursor = i
				break
			end
		end
	end
end

--- Handles mouse down events.
-- Updates cursor position and selection based on click.
-- @number x X-coordinate of click.
-- @number y Y-coordinate of click.
-- @number button Mouse button that was clicked.
-- @return EditBox Returns self if event was handled.
function EditBox:MouseDown(x, y, ...)
	local _, _, _, shift = Spring.GetModKeyState()
	local cp = self.cursor
	self:_SetCursorByMousePos(x, y)
	if shift then
		if not self.selStart then
			self.selStart = cp
		end
		self.selEnd = self.cursor
	elseif self.selStart then
		self.selStart = nil
		self.selEnd = nil
	end

	self._interactedTime = Spring.GetTimer()
	inherited.MouseDown(self, x, y, ...)
	self:Invalidate()
	return self
end

--- Handles mouse move events while dragging.
-- Updates text selection as mouse moves.
-- @number x Current X-coordinate of mouse.
-- @number y Current Y-coordinate of mouse.
-- @number dx Change in X position.
-- @number dy Change in Y position.
-- @number button Mouse button being held.
-- @return EditBox Returns self if event was handled.
function EditBox:MouseMove(x, y, dx, dy, button)
	if button ~= 1 then
		return inherited.MouseMove(self, x, y, dx, dy, button)
	end

	local _, _, _, shift = Spring.GetModKeyState()
	local cp = self.cursor
	self:_SetCursorByMousePos(x, y)
	if not self.selStart then
		self.selStart = cp
	end
	self.selEnd = self.cursor

	self._interactedTime = Spring.GetTimer()
	inherited.MouseMove(self, x, y, dx, dy, button)
	self:Invalidate()
	return self
end

function EditBox:MouseUp(...)
	inherited.MouseUp(self, ...)
	self:Invalidate()
	return self
end

function EditBox:ClearSelected()
	local left = self.selStart
	local right = self.selEnd
	if left > right then
		left, right = right, left
	end
	self.cursor = right
	local i = 0
	while self.cursor ~= left do
		self.text, self.cursor = Utf8BackspaceAt(self.text, self.cursor)
		i = i + 1
		if i > 100 then
			break
		end
	end
	self.selStart = nil
	self.selEnd = nil
	self:Invalidate()
end

--- Handles key press events.
-- @param key Key code of the pressed key.
-- @param mods Modifier keys being held.
-- @param isRepeat Whether this is a key repeat event.
-- @param label Text label of the key.
-- @param unicode Unicode value of the key.
-- @return boolean True if the key press was handled.
function EditBox:KeyPress(key, mods, isRepeat, label, unicode, ...)
	local cp = self.cursor
	local txt = self.text

	-- enter & return
	if key == Spring.GetKeyCode("enter") or key == Spring.GetKeyCode("numpad_enter") then
		return inherited.KeyPress(self, key, mods, isRepeat, label, unicode, ...) or true

	-- deletions
	elseif key == Spring.GetKeyCode("backspace") then
		if self.selStart == nil then
			if mods.ctrl then
				repeat
					self.text, self.cursor = Utf8BackspaceAt(self.text, self.cursor)
				until self.cursor == 1
					or (
						self.text:sub(self.cursor - 2, self.cursor - 2) ~= " "
						and self.text:sub(self.cursor - 1, self.cursor - 1) == " "
					)
			else
				self.text, self.cursor = Utf8BackspaceAt(self.text, self.cursor)
			end
		else
			self:ClearSelected()
		end
	elseif key == Spring.GetKeyCode("delete") then
		if self.selStart == nil then
			if mods.ctrl then
				repeat
					self.text = Utf8DeleteAt(self.text, self.cursor)
				until self.cursor >= #self.text - 1
					or (
						self.text:sub(self.cursor, self.cursor) == " "
						and self.text:sub(self.cursor + 1, self.cursor + 1) ~= " "
					)
			else
				self.text = Utf8DeleteAt(txt, cp)
			end
		else
			self:ClearSelected()
		end

	-- cursor movement
	elseif key == Spring.GetKeyCode("left") then
		if mods.ctrl then
			repeat
				self.cursor = Utf8PrevChar(txt, self.cursor)
			until self.cursor == 1
				or (txt:sub(self.cursor - 1, self.cursor - 1) ~= " " and txt:sub(self.cursor, self.cursor) == " ")
		else
			self.cursor = Utf8PrevChar(txt, cp)
		end
	elseif key == Spring.GetKeyCode("right") then
		if mods.ctrl then
			repeat
				self.cursor = Utf8NextChar(txt, self.cursor)
			until self.cursor >= #txt - 1
				or (txt:sub(self.cursor - 1, self.cursor - 1) == " " and txt:sub(self.cursor, self.cursor) ~= " ")
		else
			self.cursor = Utf8NextChar(txt, cp)
		end
	elseif key == Spring.GetKeyCode("home") then
		self.cursor = 1
	elseif key == Spring.GetKeyCode("end") then
		self.cursor = #txt + 1

	-- copy & paste
	elseif mods.ctrl and (key == Spring.GetKeyCode("c") or key == Spring.GetKeyCode("x")) then
		local s = self.selStart
		local e = self.selEnd
		if s and e then
			s, e = math.min(s, e), math.max(s, e)
			Spring.SetClipboard(txt:sub(s, e - 1))
		end
		if key == Spring.GetKeyCode("x") and self.selStart ~= nil then
			self:ClearSelected()
		end
	elseif mods.ctrl and key == Spring.GetKeyCode("v") then
		self:TextInput(Spring.GetClipboard())

	-- select all
	elseif mods.ctrl and key == Spring.GetKeyCode("a") then
		self.selStart = 1
		self.selEnd = #txt + 1
	-- character input
	elseif unicode and unicode ~= 0 then
		-- backward compability with Spring <97
		self:TextInput(unicode)
	end

	-- text selection handling
	if
		key == Spring.GetKeyCode("left")
		or key == Spring.GetKeyCode("right")
		or key == Spring.GetKeyCode("home")
		or key == Spring.GetKeyCode("end")
	then
		if mods.shift then
			if not self.selStart then
				self.selStart = cp
			end
			self.selEnd = self.cursor
		elseif self.selStart then
			self.selStart = nil
			self.selEnd = nil
		end
	end

	self._interactedTime = Spring.GetTimer()
	inherited.KeyPress(self, key, mods, isRepeat, label, unicode, ...)
	self:UpdateLayout()
	self:Invalidate()
	return self
end

--- Handles text input events.
-- Inserts or modifies text based on input.
-- @string char The character being input.
-- @return boolean True if the input was handled.
function EditBox:TextInput(utf8char, ...)
	local unicode = utf8char
	if not self.allowUnicode then
		local success
		success, unicode = pcall(string.char, utf8char)
		if success then
			success = not unicode:find("%c")
		end
		if not success then
			unicode = nil
		end
	end

	if unicode then
		local cp = self.cursor
		local txt = self.text
		if self.selStart ~= nil then
			self:ClearSelected()
			txt = self.text
			cp = self.cursor
		end
		self.text = txt:sub(1, cp - 1) .. unicode .. txt:sub(cp, #txt)
		self.cursor = cp + unicode:len()
	end

	self._interactedTime = Spring.GetTimer()
	inherited.TextInput(self, utf8char, ...)
	self:UpdateLayout()
	self:Invalidate()
	return self
end

--//=============================================================================
