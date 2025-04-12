--//=============================================================================

--- Checks if the UI is in tweak mode.
--- @return boolean is_tweak_mode True if in tweak mode, false otherwise.
function IsTweakMode()
	return widgetHandler.tweakMode
end

--//=============================================================================

--// some needed gl constants
GL_DEPTH24_STENCIL8 = 0x88F0
GL_KEEP = 0x1E00
GL_INCR_WRAP = 0x8507
GL_DECR_WRAP = 0x8508

--//=============================================================================

--- Unpacks the first four elements of a table.
--- @param t table The table to unpack.
--- @return any a The first element.
--- @return any b The second element.
--- @return any c The third element.
--- @return any d The fourth element.
function unpack4(t)
	return t[1], t[2], t[3], t[4]
end

--- Clamps a number between a minimum and maximum value.
--- @param min number The minimum value.
--- @param max number The maximum value.
--- @param num number The number to clamp.
--- @return number n The clamped number.
function clamp(min, max, num)
	if num < min then
		return min
	elseif num > max then
		return max
	end
	return num
end

--- Expands a rectangle by a given margin.
--- @param rect table The rectangle to expand.
--- @param margin table The margin to expand by.
--- @return table r The expanded rectangle.
function ExpandRect(rect, margin)
	return {
		rect[1] - margin[1], --//left
		rect[2] - margin[2], --//top
		rect[3] + margin[1] + margin[3], --//width
		rect[4] + margin[2] + margin[4], --//height
	}
end

--- Checks if a point is within a rectangle.
--- @param rect table The rectangle to check.
--- @param x number The x coordinate of the point.
--- @param y number The y coordinate of the point.
--- @return boolean is_within True if the point is within the rectangle, false otherwise.
function InRect(rect, x, y)
	return x >= rect[1] and y >= rect[2] and x <= rect[1] + rect[3] and y <= rect[2] + rect[4]
end

--- Processes a relative coordinate.
--- @param code any The coordinate code.
--- @param total number The total value.
--- @return number c The processed coordinate.
function ProcessRelativeCoord(code, total)
	local num = tonumber(code)

	if type(code) == "string" then
		local percent = tonumber(code:sub(1, -2)) or 0
		if percent < 0 then
			percent = 0
		elseif percent > 100 then
			percent = 100
		end
		return math.floor(total * percent / 100)
	elseif num and ((1 / num) < 0) then
		return math.floor(total + num)
	else
		return math.floor(num or 0)
	end
end

--- Checks if a coordinate is relative.
--- @param code any The coordinate code.
--- @return boolean is_relative True if the coordinate is relative, false otherwise.
function IsRelativeCoord(code)
	local num = tonumber(code)

	if type(code) == "string" then
		return true
	elseif num and ((1 / num) < 0) then
		return true
	else
		return false
	end
end

--- Checks the type of a relative coordinate.
--- @param code any The coordinate code.
--- @return "relative" | "negative" | "default" t The type of the coordinate ("relative", "negative", or "default").
function IsRelativeCoordType(code)
	local num = tonumber(code)

	if type(code) == "string" then
		return "relative"
	elseif num and ((1 / num) < 0) then
		return "negative"
	else
		return "default"
	end
end

--//=============================================================================

--- Checks if a value is an object.
--- @param v any The value to check.
--- @return boolean is_obj True if the value is an object, false otherwise.
function IsObject(v)
	return ((type(v) == "metatable") or (type(v) == "userdata")) and v.classname
end

--- Checks if a value is a number.
--- @param v any The value to check.
--- @return boolean is_number True if the value is a number, false otherwise.
function IsNumber(v)
	return (type(v) == "number")
end

---@param v any
---@return boolean
function isnumber(v)
	return (type(v) == "number")
end

---@param v any
---@return boolean
function istable(v)
	return (type(v) == "table")
end

---@param v any
---@return boolean
function isstring(v)
	return (type(v) == "string")
end

---@param v any
---@return boolean
function isindexable(v)
	local t = type(v)
	return (t == "table") or (t == "metatable") or (t == "userdata")
end

---@param v any
---@return boolean
function isfunc(v)
	return (type(v) == "function")
end

--//=============================================================================

local curScissor = { 1, 1, 1e9, 1e9 }
local stack = { curScissor }
local stackN = 1

local pool = {}

---@return table t
local function GetVector4()
	if not pool[1] then
		return { 0, 0, 0, 0 }
	end
	local t = pool[#pool]
	pool[#pool] = nil
	return t
end

---@param t table
local function FreeVector4(t)
	pool[#pool + 1] = t
end

---@param _ any
---@param x number
---@param y number
---@param w number
---@param h number
---@return boolean pushed True if the scissor was pushed, false otherwise.
local function PushScissor(_, x, y, w, h)
	local right = x + w
	local bottom = y + h
	if right > curScissor[3] then
		right = curScissor[3]
	end
	if bottom > curScissor[4] then
		bottom = curScissor[4]
	end
	if x < curScissor[1] then
		x = curScissor[1]
	end
	if y < curScissor[2] then
		y = curScissor[2]
	end

	w = right - x
	h = bottom - y
	if (w < 0) or (h < 0) then
		--// scissor is null space -> don't render at all
		return false
	end

	--curScissor = {x,y,right,bottom}
	curScissor = GetVector4()
	curScissor[1] = x
	curScissor[2] = y
	curScissor[3] = right
	curScissor[4] = bottom
	stackN = stackN + 1
	stack[stackN] = curScissor

	gl.Scissor(x, y, w, h)
	return true
end

local function PopScissor()
	FreeVector4(curScissor)
	stack[stackN] = nil
	stackN = stackN - 1
	curScissor = stack[stackN]
	assert(stackN >= 1)
	if stackN == 1 then
		gl.Scissor(false)
	else
		local x, y, right, bottom = unpack4(curScissor)
		local w = right - x
		local h = bottom - y
		gl.Scissor(x, y, w, h)
	end
end

---@param obj any
---@param x number
---@param y number
---@param w number
---@param h number
---@return boolean pushed True if the stencil mask was pushed, false otherwise.
local function PushStencilMask(obj, x, y, w, h)
	obj._stencilMask = (obj.parent._stencilMask or 0) + 1
	if obj._stencilMask > 255 then
		obj._stencilMask = 0
	end

	gl.ColorMask(false)

	gl.StencilFunc(GL.ALWAYS, 0, 0xFF)
	gl.StencilOp(GL_KEEP, GL_INCR_WRAP, GL_INCR_WRAP)

	if not obj.scrollPosY then
		gl.Rect(0, 0, w, h)
	else
		local contentX, contentY, contentWidth, contentHeight = unpack4(obj.contentArea)
		gl.Rect(0, 0, contentWidth, contentHeight)
	end

	gl.ColorMask(true)
	gl.StencilFunc(GL.EQUAL, obj._stencilMask, 0xFF)
	gl.StencilOp(GL_KEEP, GL_KEEP, GL_KEEP)
	return true
end

---@param obj any
---@param x number
---@param y number
---@param w number
---@param h number
local function PopStencilMask(obj, x, y, w, h)
	gl.ColorMask(false)

	gl.StencilFunc(GL.ALWAYS, 0, 0xFF)
	gl.StencilOp(GL_KEEP, GL_DECR_WRAP, GL_DECR_WRAP)

	if not obj.scrollPosY then
		gl.Rect(0, 0, w, h)
	else
		local contentX, contentY, contentWidth, contentHeight = unpack4(obj.contentArea)
		gl.Rect(0, 0, contentWidth, contentHeight)
	end

	gl.ColorMask(true)
	gl.StencilFunc(GL.EQUAL, obj.parent._stencilMask or 0, 0xFF)
	gl.StencilOp(GL_KEEP, GL_KEEP, GL_KEEP)
	--gl.StencilTest(false)

	obj._stencilMask = nil
end

function EnterRTT()
	inRTT = true
end

function LeaveRTT()
	inRTT = false
end

---@return boolean is_in_rtt
function AreInRTT()
	return inRTT
end

---@param ... any
---@return boolean limit_pushed
function PushLimitRenderRegion(...)
	if inRTT then
		return PushStencilMask(...)
	else
		return PushScissor(...)
	end
end

---@param ... any
function PopLimitRenderRegion(...)
	if inRTT then
		PopStencilMask(...)
	else
		PopScissor(...)
	end
end

--//=============================================================================

---@param rect1 table
---@param rect2 table
---@return boolean is_overlapping
function AreRectsOverlapping(rect1, rect2)
	return (rect1[1] <= rect2[1] + rect2[3])
		and (rect1[1] + rect1[3] >= rect2[1])
		and (rect1[2] <= rect2[2] + rect2[4])
		and (rect1[2] + rect1[4] >= rect2[2])
end

--//=============================================================================

local oldPrint = print

---@param ... any
function print(...)
	oldPrint(...)
	io.flush()
end

--//=============================================================================

---@param r any
---@param g any
---@param b any
---@param a any
---@return table color
function _ParseColorArgs(r, g, b, a)
	local t = type(r)

	if t == "table" then
		return r
	else
		return { r, g, b, a }
	end
end

--//=============================================================================

---@param str string
---@return number
function string:findlast(str)
	local i
	local j = 0
	repeat
		i = j
		j = self:find(str, i + 1, true)
	until not j
	return i
end

---@return string
function string:GetExt()
	local i = self:findlast(".")
	if i then
		return self:sub(i)
	end
end

--//=============================================================================

local type = type
local pairs = pairs

function table:clear()
	for i, _ in pairs(self) do
		self[i] = nil
	end
end

---@param fun function
---@return table
function table:map(fun)
	local newTable = {}
	for key, value in pairs(self) do
		newTable[key] = fun(key, value)
	end
	return newTable
end

---@return table
function table:shallowcopy()
	local newTable = {}
	for k, v in pairs(self) do
		newTable[k] = v
	end
	return newTable
end

---@return table
function table:arrayshallowcopy()
	local newArray = {}
	for i = 1, #self do
		newArray[i] = self[i]
	end
	return newTable
end

---@param t table
function table:arrayappend(t)
	for i = 1, #t do
		self[#self + 1] = t[i]
	end
end

---@param fun function
function table:arraymap(fun)
	for i = 1, #self do
		newTable[i] = fun(self[i])
	end
end

---@param fun function
---@param state any
function table:fold(fun, state)
	for key, value in pairs(self) do
		fun(state, key, value)
	end
end

---@param fun function
---@return any
function table:arrayreduce(fun)
	local state = self[1]
	for i = 2, #self do
		state = fun(state, self[i])
	end
	return state
end

--- removes and returns element from array
--- array, T element -> T element
---@param element any
function table:arrayremovefirst(element)
	for i = 1, #self do
		if self[i] == element then
			return self:remove(i)
		end
	end
end

---@param element any
---@return any
function table:ifind(element)
	for i = 1, #self do
		if self[i] == element then
			return i
		end
	end
	return false
end

---@return number
function table:sum()
	local r = 0
	for i = 1, #self do
		r = r + self[i]
	end
	return r
end

---@param table2 table
---@return table
function table:merge(table2)
	for i, v in pairs(table2) do
		if type(v) == "table" then
			local sv = type(self[i])
			if (sv == "table") or (sv == "nil") then
				if sv == "nil" then
					self[i] = {}
				end
				table.merge(self[i], v)
			end
		elseif self[i] == nil then
			self[i] = v
		end
	end
	return self
end

---@param table2 table
---@return boolean
function table:iequal(table2)
	for i, v in pairs(self) do
		if table2[i] ~= v then
			return false
		end
	end

	for i, v in pairs(table2) do
		if self[i] ~= v then
			return false
		end
	end

	return true
end

---@return number
function table:size()
	local cnt = 0
	for _ in pairs(self) do
		cnt = cnt + 1
	end
	return cnt
end

--//=============================================================================

local weak_meta = { __mode = "v" }

---@return table
function CreateWeakTable()
	local m = {}
	setmetatable(m, weak_meta)
	return m
end

--//=============================================================================

---@param num number
---@param idp number
---@return number
function math.round(num, idp)
	if not idp then
		return math.floor(num + 0.5)
	else
		return ("%." .. idp .. "f"):format(num)
		--local mult = 10^(idp or 0)
		--return math.floor(num * mult + 0.5) / mult
	end
end

--//=============================================================================

---@param c table
---@return table
function InvertColor(c)
	return { 1 - c[1], 1 - c[2], 1 - c[3], c[4] }
end

---@param x number
---@param y number
---@param a number
---@return number
function math.mix(x, y, a)
	return y * a + x * (1 - a)
end

---@param c table
---@param s number
---@return table
function mulColor(c, s)
	return { s * c[1], s * c[2], s * c[3], c[4] }
end

---@param c1 table
---@param c2 table
---@return table
function mulColors(c1, c2)
	return { c1[1] * c2[1], c1[2] * c2[2], c1[3] * c2[3], c1[4] * c2[4] }
end

---@param c1 table
---@param c2 table
---@param a number
---@return table
function mixColors(c1, c2, a)
	return {
		math.mix(c1[1], c2[1], a),
		math.mix(c1[2], c2[2], a),
		math.mix(c1[3], c2[3], a),
		math.mix(c1[4], c2[4], a),
	}
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return string
function color2incolor(r, g, b, a)
	if type(r) == "table" then
		r, g, b, a = unpack4(r)
	end

	local inColor = "\255\255\255\255"
	if r then
		inColor = string.char(255, r * 255, g * 255, b * 255)
	end
	return inColor
end

---@param inColor string
---@return number
---@return number
---@return number
---@return number
function incolor2color(inColor)
	local a = 255
	local r, g, b = inColor:sub(2, 4):byte(1, 3)
	return r / 255, g / 255, b / 255, a / 255
end

--//=============================================================================
