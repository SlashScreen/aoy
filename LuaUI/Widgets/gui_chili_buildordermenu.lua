---Gets the widget information.
---@return table { version: string, name: string, desc: string, author: string, date: string, license: string, layer: number, enabled: boolean, handler: boolean }
function widget:GetInfo()
	return {
		version = "0.1",
		name = "Chili Build Order Menu",
		desc = "Build/Order menu implemented with chili ui",
		author = "Adrianulima",
		date = "WIP",
		license = "GNU GPL, v2 or later",
		layer = 1,
		enabled = true, --false,
		handler = true,
	}
end

---@type number
local vsx, vsy = Spring.GetViewGeometry()
---@type number
local widgetScale = (0.5 + (vsx * vsy / 5700000))

local REMOVE_DEFAULT_MENU = false

--------------------------------------------------------------------------------
-- Hotkeys
VFS.Include("luaui/configs/build_hotkeys_config.lua")
---@type function
local sGetKeySymbol = Spring.GetKeySymbol

---Gets the key symbol for a given key code.
---@param k number Key code
---@return string Key symbol
local function getKeySymbol(k)
	if k >= 97 and k <= 122 then
		return string.char(k):upper()
	end
	-- basically unused
	local keySymbol = sGetKeySymbol(k)
	return keySymbol:sub(1, 1):upper() .. keySymbol:sub(2)
end

---@type table<string, table<number, string>>
local nameToKeySymbols = {}
for unitDefID = 1, #UnitDefs do
	---@type table
	local ud = UnitDefs[unitDefID]
	---@type string
	local trimmedName = ud.name
	if trimmedName:find("_up", -5) then
		trimmedName = trimmedName:sub(1, -5)
	end
	if nameToKeyCode[trimmedName] then
		nameToKeySymbols[ud.name] = {}
		for i = 1, #nameToKeyCode[trimmedName] do
			nameToKeySymbols[ud.name][i] = getKeySymbol(nameToKeyCode[trimmedName][i])
		end
	end
end

---@type table<number, Label>
local hotkeyLabels = {}
--------------------------------------------------------------------------------
-- Localize
---@type function
local sForceLayoutUpdate = Spring.ForceLayoutUpdate
---@type function
local sSetActiveCommand = Spring.SetActiveCommand
---@type function
local sGetCmdDescIndex = Spring.GetCmdDescIndex
---@type function
local sGetActiveCommand = Spring.GetActiveCommand
---@type function
local sGetWindowGeometry = Spring.GetWindowGeometry

---@type function
local stringfind = string.find
---@type function
local stringsub = string.sub
---@type function
local stringgsub = string.gsub
---@type function
local mathceil = math.ceil
---@type function
local mathmax = math.max
---@type function
local mathmin = math.min

---@type function
glGetTextWidth = gl.GetTextWidth

-- Chili classes
---@type table
local Chili
---@type Window
local Window
---@type Image
local Image
---@type Button
local Button
---@type Grid
local Grid
---@type Label
local Label
---@type ScrollPanel
local ScrollPanel
local color2incolor

-- Global vars
---@type Window
local orderWindow, buildWindow
---@type Grid
local orderGrid, buildGrid
---@type boolean
local updateRequired
---@type string
local tooltip
---@type number
local btWidth
---@type table<string, any>
local chiliCache = {}
---@type number
local vsx, vsy = sGetWindowGeometry()

---@type function
local sGetConfigInt = Spring.GetConfigInt
---@type number
local buildOrderUI = sGetConfigInt("evo_buildorderui", 2)
---@type boolean
local showCost = sGetConfigInt("evo_showcost", 1) == 1
---@type boolean
local showTechReq = sGetConfigInt("evo_showtechreq", 1) == 1
---@type boolean
local showHotkeys = sGetConfigInt("evo_showhotkeys", 1) == 1
WG.buildOrderUI = { updateConfigInt = false }

---@type number
local fontSize = 12 * widgetScale

--Horizontal
if buildOrderUI == 0 or buildOrderUI == nil then
	Config = {
		ordermenu = {
			name = "ordermenu",
			rows = 13,
			columns = 2,
			x = "0%",
			y = "35%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 }, -- outer panel
		},
		buildmenu = {
			name = "buildmenu",
			rows = 3,
			columns = 10,
			x = "21.2%",
			y = "57.5%",
			width = "60%",
			height = "20%",
			orientation = "horizontal",
			--maxWidth = 420,
			padding = { 5, 5, 5, 5 },
		},
		labels = {
			captionFontMaxSize = fontSize,
			queueFontSize = fontSize, --32 (MaDDoX)
			costFontSize = fontSize,
		},
		hiddenCMDs = {
			timewait = true,
			deathwait = true,
			squadwait = true,
			gatherwait = true,
			loadonto = true,
			selfd = false,
			settargetnoground = true,
		},
	}
end

--Compact Horizontal
if buildOrderUI == 1 then
	Config = {
		ordermenu = {
			name = "ordermenu",
			rows = 13,
			columns = 2,
			x = "0%",
			y = "35%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 }, -- outer panel
		},
		buildmenu = {
			name = "buildmenu",
			rows = 3,
			columns = 10,
			x = "32%",
			y = "66%",
			width = "40%",
			height = "15%",
			orientation = "horizontal",
			--maxWidth = 420,
			padding = { 5, 5, 5, 5 },
		},
		labels = {
			captionFontMaxSize = fontSize,
			queueFontSize = fontSize, --32 (MaDDoX)
			costFontSize = fontSize,
		},
		hiddenCMDs = {
			timewait = true,
			deathwait = true,
			squadwait = true,
			gatherwait = true,
			loadonto = true,
			selfd = false,
			settargetnoground = true,
		},
	}
end

--Traditional
if buildOrderUI == 2 then
	Config = {
		ordermenu = {
			name = "ordermenu",
			rows = 6,
			columns = 4,
			x = "0%",
			y = "24%",
			width = "50%",
			height = "25%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 }, -- outer panel
		},
		buildmenu = {
			name = "buildmenu",
			rows = 5,
			columns = 5,
			x = "0%",
			y = "50%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 },
		},
		labels = {
			captionFontMaxSize = fontSize,
			queueFontSize = fontSize, --32 (MaDDoX)
			costFontSize = fontSize,
		},
		hiddenCMDs = {
			timewait = true,
			deathwait = true,
			squadwait = true,
			gatherwait = true,
			loadonto = true,
			selfd = false,
			settargetnoground = true,
		},
	}
end

--Traditional (SxS)
if buildOrderUI == 3 then
	Config = {
		ordermenu = {
			name = "ordermenu",
			rows = 13,
			columns = 2,
			x = "0%",
			y = "35%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 }, -- outer panel
		},
		buildmenu = {
			name = "buildmenu",
			rows = 7,
			columns = 5,
			x = "21%",
			y = "35%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 },
		},
		labels = {
			captionFontMaxSize = fontSize,
			queueFontSize = fontSize, --32 (MaDDoX)
			costFontSize = fontSize,
		},
		hiddenCMDs = {
			timewait = true,
			deathwait = true,
			squadwait = true,
			gatherwait = true,
			loadonto = true,
			selfd = false,
			settargetnoground = true,
		},
	}
end

--Right Side
if buildOrderUI == 4 then
	Config = {
		ordermenu = {
			name = "ordermenu",
			rows = 13,
			columns = 2,
			x = "0%",
			y = "35%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 }, -- outer panel
		},
		buildmenu = {
			name = "buildmenu",
			rows = 7,
			columns = 5,
			x = "79.75%",
			y = "35%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 },
		},
		labels = {
			captionFontMaxSize = fontSize,
			queueFontSize = fontSize, --32 (MaDDoX)
			costFontSize = fontSize,
		},
		hiddenCMDs = {
			timewait = true,
			deathwait = true,
			squadwait = true,
			gatherwait = true,
			loadonto = true,
			selfd = false,
			settargetnoground = true,
		},
	}
end

--Right Side Compact
if buildOrderUI == 5 then
	Config = {
		ordermenu = {
			name = "ordermenu",
			rows = 13,
			columns = 2,
			x = "0%",
			y = "35%",
			width = "50%",
			height = "50%",
			orientation = "horizontal",
			maxWidth = 390,
			padding = { 5, 5, 5, 5 }, -- outer panel
		},
		buildmenu = {
			name = "buildmenu",
			rows = 7,
			columns = 5,
			x = "85%",
			y = "35%",
			width = "15%",
			height = "30%",
			orientation = "horizontal",
			padding = { 5, 5, 5, 5 },
		},
		labels = {
			captionFontMaxSize = fontSize,
			queueFontSize = fontSize, --32 (MaDDoX)
			costFontSize = fontSize,
		},
		hiddenCMDs = {
			timewait = true,
			deathwait = true,
			squadwait = true,
			gatherwait = true,
			loadonto = true,
			selfd = false,
			settargetnoground = true,
		},
	}
end

--------------------------------------------------------------------------------
-- Helpers
local function deepEquals(t1, t2, ignore_mt)
	if t1 == t2 then
		return true
	end
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then
		return false
	end
	-- non-table types can be directly compared
	if ty1 ~= "table" and ty2 ~= "table" then
		return t1 == t2
	end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then
		return t1 == t2
	end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not deepEquals(v1, v2) then
			return false
		end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not deepEquals(v1, v2) then
			return false
		end
	end
	return true
end --deepEquals

---Processes a relative coordinate.
---@param code string|number Coordinate code
---@param total number Total value
---@return number Processed coordinate
local function processRelativeCoord(code, total)
	---@type number?
	local num = tonumber(code)
	if type(code) == "string" then
		---@type number
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
end --processRelativeCoord

---Creates a grid window.
---@param config table Configuration table
---@return Grid g, Window w The grid and the window
local function createGridWindow(config)
	---@type ScrollPanel
	local scroll = ScrollPanel:New({
		name = "scroll_" .. config.name,
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = config.padding,
	})
	---@type Grid
	local grid = Grid:New({
		name = "grid_" .. config.name,
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		rows = config.rows,
		columns = config.columns,
		orientation = config.orientation,
		padding = { 0, 0, 0, 0 },
	})
	---@type Window
	local gridWindow = Window:New({
		name = "window_" .. config.name,
		parent = Chili.Screen0,
		x = config.x,
		y = config.y,
		height = config.height,
		width = config.width,
		maxWidth = config.maxWidth,
		children = { grid },
		bringToFrontOnClick = true,
		dockable = false,
		draggable = false,
		resizable = false,
		tweakDraggable = true,
		tweakResizable = false,
		padding = config.padding,
	})

	local function updateGrid()
		---@type number
		local rowsNeeded = math.ceil(#grid.children / grid.columns)
		if rowsNeeded > grid.rows then
			---@type number
			local ratio = (gridWindow.height / config.rows) / (gridWindow.width / config.columns)
			grid:SetPos(nil, nil, nil, (grid.width / grid.columns) * ratio * rowsNeeded)
			grid.rows = rowsNeeded
			if grid.parent and grid.parent.name == gridWindow.name then
				gridWindow:RemoveChild(grid)
				gridWindow:AddChild(scroll)
				scroll:AddChild(grid)
			end
		elseif rowsNeeded <= config.rows then
			grid:SetPos(nil, nil, nil, gridWindow.height - gridWindow.padding[2] - gridWindow.padding[4])
			grid.rows = config.rows
			if scroll.parent and scroll.parent.name == gridWindow.name then
				scroll:RemoveChild(grid)
				gridWindow:RemoveChild(scroll)
				gridWindow:AddChild(grid)
			end
		end
	end

	grid.updateGrid = updateGrid
	gridWindow:Hide()
	return grid, gridWindow
end --createGridWindow

---Applies the highlight handler to a button.
---@param button Button The button to apply the handler to
---@param cmd table The command associated with the button
---@return Button The button
local function applyHighlightHandler(button, cmd)
	---@type Color
	local selected = { 0.85, 0.65, 0, 0.5 }
	---@type Color
	local hovered = { 0.75, 0.75, 0.75, 0.25 }
	---@type Color
	local out = { 0, 0, 0, 0 }
	---@type Color
	local disabled = { 0, 0, 0, 0.6 }

	---@type Image
	local highlight = chiliCache["highlight" .. button.cmdID]
		or Image:New({
			name = "highlight" .. button.cmdID,
			parent = button,
			file = "LuaUI/Images/button-highlight.dds",
			width = "100%",
			height = "100%",
			fixedRatio = false,
			keepAspect = false,
			color = out,
		})
	chiliCache["highlight" .. button.cmdID] = highlight
	---@param cmdID number
	local function updateSelection(cmdID)
		---@param color Color
		local function checkColor(color)
			if highlight.color ~= color then
				highlight.color = color
				highlight:Invalidate()
			end
		end

		if cmd.disabled then
			checkColor(disabled)
			if button.state.hovered then
				tooltip = string.gsub(cmd.tooltip, "Metal cost %d*\nEnergy cost %d*\n", "")
			end
		elseif button.cmdID == cmdID then
			checkColor(selected)
		elseif button.state.hovered then
			tooltip = string.gsub(cmd.tooltip, "Metal cost %d*\nEnergy cost %d*\n", "")
			checkColor(hovered)
		else
			checkColor(out)
		end
	end
	button.updateSelection = updateSelection
	updateSelection()
	return button
end --applyHighlightHandler

---Applies the state handler to a button.
---@param button Button The button to apply the handler to
---@param cmd table The command associated with the button
---@return Button The button
local function applyStateHandler(button, cmd)
	---@type number
	local stateCount = #cmd.params - 1
	---@type number
	local state = cmd.params[1] + 1

	---@param c number
	local function curve(c)
		return -0.5 * c * (c - 4)
	end -- makes yellow more vivid
	---@param i number
	---@return Color
	local function getStateColor(i)
		local g = (i - 1) / (stateCount - 1)
		return (i == state) and { curve(1 - g), curve(g), 0, 1 } or { 0.9, 0.9, 0.9, 0.3 }
	end

	---@type table<number, Image>
	local stateButtons = {}
	for i = 1, stateCount do
		---@type number
		local pad = 7
		---@type number
		local sx = (100 - pad * (stateCount + 3)) / stateCount
		---@type number
		local px = pad + i * pad + (i - 1) * sx
		stateButtons[i] = chiliCache["stateButton_" .. cmd.id .. "_" .. i]
			or Image:New({
				name = "stateButton_" .. cmd.id .. "_" .. i,
				parent = button,
				file = "LuaUI/Images/button-highlight.dds",
				x = px .. "%",
				y = "75%",
				width = sx .. "%",
				maxHeight = 6,
				keepAspect = false,
				color = getStateColor(i),
			})
		chiliCache["stateButton_" .. cmd.id .. "_" .. i] = stateButtons[i]
	end
	---@type function
	local oldUpdateSelection = button.updateSelection
	---@param cmdID number
	local function updateSelection(cmdID)
		oldUpdateSelection(cmdID)
		for i = 1, stateCount do
			stateButtons[i].color = getStateColor(i)
		end
	end
	button.updateSelection = updateSelection
	return button
end --applyStateHandler
--------------------------------------------------------------------------------
---Initializes the controls.
local function InitializeControls()
	orderGrid, orderWindow = createGridWindow(Config.ordermenu)
	buildGrid, buildWindow = createGridWindow(Config.buildmenu)
end --InitializeControls

---Handles the action command.
---@param self Button The button
---@param x number The x coordinate
---@param y number The y coordinate
---@param mouse number The mouse button
---@param mods table The modifiers
local function ActionCommand(self, x, y, mouse, mods)
	local index = sGetCmdDescIndex(self.cmdID)
	if index then
		local left, right = mouse == 1, mouse == 3
		local alt, ctrl, meta, shift = mods.alt, mods.ctrl, mods.meta, mods.shift
		sSetActiveCommand(index, mouse, left, right, alt, ctrl, meta, shift)
	end
end --ActionCommand

---Adds an order command.
---@param cmd table The command
local function addOrderCommand(cmd)
	---@type Button
	local button = chiliCache["button" .. cmd.id]
		or Button:New({
			name = "button" .. cmd.id,
			--parent = orderGrid,
			cmdID = cmd.id,
			caption = cmd.name,
			textPadding = 9, --8, (MaDDoX)
			padding = { 0, 0, 0, 0 },
			margin = { 2, 2, 2, 2 },
			OnClick = { function() end },
			OnMouseDown = { ActionCommand },
		})
	if cmd.name == "Repair" then
		button:SetCaption("Build")
	else
		button:SetCaption(cmd.name)
	end
	chiliCache["button" .. cmd.id] = button
	local s = (btWidth - button.textPadding * 2) / glGetTextWidth(button.caption)
	button.font:SetSize(mathmin(s, Config.labels.captionFontMaxSize))
	applyHighlightHandler(button, cmd)
	orderGrid:AddChild(button)
end --addOrderCommand

---Adds a state command.
---@param cmd table The command
local function addStateCommand(cmd)
	---@type Button
	local button = chiliCache["button" .. cmd.id]
		or Button:New({
			name = "button" .. cmd.id,
			cmdID = cmd.id,
			caption = cmd.params[cmd.params[1] + 2],
			textPadding = 12, --8,
			padding = { 0, 0, 0, 0 },
			margin = { 2, 2, 2, 2 },
			OnClick = { function() end },
			OnMouseDown = { ActionCommand },
		})
	button:SetCaption(cmd.params[cmd.params[1] + 2])
	chiliCache["button" .. cmd.id] = button
	local s = (btWidth - button.textPadding * 2) / glGetTextWidth(button.caption)
	button.font:SetSize(mathmin(s, Config.labels.captionFontMaxSize))
	applyHighlightHandler(button, cmd)
	applyStateHandler(button, cmd)
	orderGrid:AddChild(button)
end --addStateCommand

---Adds a build command.
---@param cmd table The command
local function addBuildCommand(cmd)
	---@type Image
	local image = chiliCache["button" .. cmd.id]
		or Image:New({
			name = "button" .. cmd.id,
			cmdID = cmd.id,
			width = "100%",
			height = "100%",
			file = "#" .. cmd.id * -1,
			padding = { 0, 0, 0, 0 },
			margin = { 2, 2, 2, 2 },
			OnClick = { function() end },
			OnMouseDown = { ActionCommand },
		})
	chiliCache["button" .. cmd.id] = image

	if cmd.params[1] then
		if not chiliCache["queueLabel" .. cmd.id] then
			chiliCache["queueLabel" .. cmd.id] = Label:New({
				name = "queueLabel" .. cmd.id,
				parent = image,
				right = "5%",
				y = "5%",
				align = "right",
				valign = "top",
				--caption = tostring(cmd.params[1] or ''),
				font = {
					size = Config.labels.queueFontSize,
					outline = true,
					shadow = true,
					outlineWidth = 4,
					outlineWeight = 4,
				},
			})
		end
	end
	if chiliCache["queueLabel" .. cmd.id] then
		chiliCache["queueLabel" .. cmd.id]:SetCaption(tostring(cmd.params[1] or ""))
	end

	local str = ""
	if showCost then
		local s, e = 0, 0
		local comma = color2incolor(1, 1, 1) .. ","
		s, e = stringfind(cmd.tooltip, "Uses %+%d* Supply")
		if s then
			str = str .. color2incolor(1, 0.5, 0) .. stringsub(cmd.tooltip, s + 6, e - 7) .. comma
		end
		s, e = stringfind(cmd.tooltip, "Energy cost %d*")
		str = str .. color2incolor(1, 1, 0) .. stringsub(cmd.tooltip, s + 12, e) .. comma
		s, e = stringfind(cmd.tooltip, "Metal cost %d*")
		str = str .. color2incolor(0.53, 0.77, 0.89) .. stringsub(cmd.tooltip, s + 11, e) .. comma
	end
	local techReqColors =
		{ color2incolor(1, 0.5, 0), color2incolor(0, 0.8, 1), color2incolor(1, 0, 1), color2incolor(0, 1, 0) }
	if showTechReq and cmd.disabled then
		if stringfind(cmd.tooltip, "Requires") and not stringfind(cmd.tooltip, "Provides") then
			local s, e = stringfind(cmd.tooltip, "tech%d*")
			if s then
				local techLevel = stringsub(cmd.tooltip, s + 4, e)
				str = techReqColors[tonumber(techLevel) + 1] .. "T" .. techLevel .. "\n" .. str
			end
		end
	end
	if str ~= "" then
		if not chiliCache["costLabel" .. cmd.id] then
			chiliCache["costLabel" .. cmd.id] = Label:New({
				name = "costLabel" .. cmd.id,
				parent = image,
				x = "5%",
				bottom = "5%",
				valign = "bottom",
				--caption = metalCost .. line .. energyCost,
				font = {
					size = Config.labels.costFontSize,
					outline = true,
					shadow = true,
					outlineWidth = 4,
					outlineWeight = 4,
				},
			})
		end
		chiliCache["costLabel" .. cmd.id]:SetCaption(str:sub(1, -2))
	elseif chiliCache["costLabel" .. cmd.id] then
		chiliCache["costLabel" .. cmd.id]:SetCaption(str)
	end

	if
		showHotkeys
		and widgetHandler.orderList["EvoRTS Build Hotkeys"]
		and widgetHandler.orderList["EvoRTS Build Hotkeys"] ~= 0
	then
		if nameToKeySymbols[cmd.name] then
			if not chiliCache["hotkeyLabel" .. cmd.id] then
				chiliCache["hotkeyLabel" .. cmd.id] = Label:New({
					name = "hotkeyLabel" .. cmd.id,
					parent = image,
					x = "5%",
					y = "5%",
					valign = "top",
					--caption = metalCost .. line .. energyCost,
					font = {
						size = Config.labels.costFontSize,
						outline = true,
						shadow = true,
						outlineWidth = 4,
						outlineWeight = 4,
					},
				})
			end
			-- chiliCache['hotkeyLabel' .. cmd.id]:SetCaption(color2incolor(1,1,1) .. nameToKeySymbols[cmd.name])
			local function updateLabel()
				local str = color2incolor(1, 1, 1)
				local leng = #nameToKeySymbols[cmd.name]
				local getLengKeysPressed = WG.buildHotkeys and #WG.buildHotkeys.keysPressed or 0
				local matching = true
				for i = 1, leng do
					if i <= getLengKeysPressed and matching then
						if nameToKeySymbols[cmd.name][i] == WG.buildHotkeys.keysPressed[i] then
							str = str .. color2incolor(0, 1, 0)
						else
							matching = false
						end
					end
					str = str .. nameToKeySymbols[cmd.name][i]
					if i < leng then
						str = str .. color2incolor(1, 1, 1) .. " + "
					end
				end
				chiliCache["hotkeyLabel" .. cmd.id]:SetCaption(str)
			end
			chiliCache["hotkeyLabel" .. cmd.id].updateLabel = updateLabel
			updateLabel()
			hotkeyLabels[cmd.id] = chiliCache["hotkeyLabel" .. cmd.id]
		end
	elseif chiliCache["hotkeyLabel" .. cmd.id] then
		chiliCache["hotkeyLabel" .. cmd.id].updateLabel = nil
		chiliCache["hotkeyLabel" .. cmd.id]:SetCaption("")
	end

	applyHighlightHandler(image, cmd)
	buildGrid:AddChild(image)
end --addBuildCommand

---Processes a command.
---@param cmd table The command
---@return number The grid number
local function processCommand(cmd)
	if UnitDefNames[cmd.name] then
		return 3
	elseif #cmd.params > 1 then
		return 1
	else
		return 2
	end
end --processCommand

---@type table
local lastCommands
---Processes all commands.
---@param flush boolean Whether to flush the commands
local function processAllCommands(flush)
	if (deepEquals(lastCommands, widgetHandler.commands)) and not flush then
		return
	end
	lastCommands = widgetHandler.commands

	buildGrid:ClearChildren()
	orderGrid:ClearChildren()
	--chiliCache = {} -- clears all cached chili elements

	---@type number
	local haveCmd = 0
	---@type table<number, table>
	local commands = { [1] = {}, [2] = {}, [3] = {} }
	for _, cmd in ipairs(lastCommands) do
		if cmd.name ~= "" and not (Config.hiddenCMDs[cmd.name] or Config.hiddenCMDs[cmd.action]) then
			local grid = processCommand(cmd)
			haveCmd = mathmax(haveCmd, grid)
			commands[grid][#commands[grid] + 1] = cmd
		end
	end

	---@type table<number, function>
	local gridFunc = { [1] = addStateCommand, [2] = addOrderCommand, [3] = addBuildCommand }
	for grid, cmds in ipairs(commands) do
		for i = 1, #cmds do
			gridFunc[grid](cmds[i])
		end
	end

	orderGrid.updateGrid()
	buildGrid.updateGrid()

	if haveCmd > 0 and orderWindow.hidden then
		orderWindow:Show()
	elseif haveCmd == 0 and orderWindow.visible then
		orderWindow:Hide()
	end
	if haveCmd > 2 and buildWindow.hidden then
		buildWindow:Show()
	elseif haveCmd <= 2 and buildWindow.visible then
		buildWindow:Hide()
	end
end --processAllCommands

---Updates the selection.
local function updateSelection()
	tooltip = nil
	---@type number
	local _, cmdID = sGetActiveCommand()
	for _, bt in ipairs(buildGrid.children) do
		if bt.updateSelection then
			bt.updateSelection(cmdID)
		end
	end
	for _, bt in ipairs(orderGrid.children) do
		if bt.updateSelection then
			bt.updateSelection(cmdID)
		end
	end
end --updateSelection

---Updates the label.
local function updateLabel()
	for _, label in pairs(hotkeyLabels) do
		if label.updateLabel then
			label.updateLabel()
		end
	end
end --updateLabel

---Overrides the default menu.
local function OverrideDefaultMenu()
	---@param xIcons number
	---@param yIcons number
	---@param cmdCount number
	---@param commands table
	local function layoutHandler(xIcons, yIcons, cmdCount, commands)
		widgetHandler.commands = commands
		widgetHandler.commands.n = cmdCount
		widgetHandler:CommandsChanged()
		local customCmds = widgetHandler.customCommands
		return "", xIcons, yIcons, {}, customCmds, {}, {}, {}, {}, {}, { [1337] = 9001 }
	end
	widgetHandler:ConfigLayoutHandler(layoutHandler)
	sForceLayoutUpdate()
end --OverrideDefaultMenu
--------------------------------------------------------------------------------
---Initializes the widget.
function widget:Initialize()
	if not WG.Chili then
		Spring.Echo("No chili detected.")
		widgetHandler:RemoveWidget()
		return
	end

	Spring.Echo("Chili detected, initializing UI.")
	if REMOVE_DEFAULT_MENU then
		OverrideDefaultMenu()
	end
	
	Chili = WG.Chili
	Window = Chili.Window
	Grid = Chili.Grid
	Image = Chili.Image
	Button = Chili.Button
	Label = Chili.Label
	ScrollPanel = Chili.ScrollPanel
	color2incolor = Chili.color2incolor

	btWidth = processRelativeCoord(Config.ordermenu.width, vsx / Config.ordermenu.columns)

	InitializeControls()
end --Initialize

---Handles the commands changed event.
function widget:CommandsChanged()
	updateRequired = true
end --CommandsChanged

---Updates the widget.
function widget:Update()
	if WG["topbar"] and WG["topbar"].showingQuit() then
		return
	end
	if updateRequired then
		processAllCommands()
		updateRequired = false
	end
	updateSelection()

	if WG.buildHotkeys and WG.buildHotkeys.hasUpdated then
		updateLabel()
		WG.buildHotkeys.hasUpdated = false
	end
	if WG.buildOrderUI and WG.buildOrderUI.updateConfigInt then
		WG.buildOrderUI.updateConfigInt = false
		showCost = sGetConfigInt("evo_showcost", 1) == 1
		showTechReq = sGetConfigInt("evo_showtechreq", 1) == 1
		showHotkeys = sGetConfigInt("evo_showhotkeys", 1) == 1
		processAllCommands(true)
	end
end --Update

---Handles the world tooltip event.
---@param ttType number The tooltip type
---@param data1 number The first data parameter
---@param data2 number The second data parameter
---@param data3 number The third data parameter
---@return string The tooltip
function widget:WorldTooltip(ttType, data1, data2, data3)
	return tooltip
end --WorldTooltip

---Handles the view resize event.
---@param newX number The new x coordinate
---@param newY number The new y coordinate
function widget:ViewResize(newX, newY)
	vsx, vsy = Spring.GetViewGeometry()
	widgetScale = (0.5 + (vsx * vsy / 5700000))
	if Config then
		Config.labels = {
			captionFontMaxSize = fontSize,
			queueFontSize = fontSize, --32 (MaDDoX)
			costFontSize = fontSize,
		}
	end
	-- TODO: implement config for this resize and make a reusable helper function to handle it
	Config.buildmenu.height = buildWindow.width * (Config.buildmenu.rows / Config.buildmenu.columns)
	buildWindow:SetPos(nil, nil, nil, Config.buildmenu.height)
end --ViewResize

---Handles the shutdown event.
function widget:Shutdown()
	orderWindow:Dispose()
	buildWindow:Dispose()
	widgetHandler:ConfigLayoutHandler(nil)
	chiliCache = nil
	sForceLayoutUpdate()
end --Shutdown
