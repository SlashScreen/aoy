--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    gadgets.lua
--  brief:   the gadget manager, a call-in router
--  author:  Dave Rodgers
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.

--- @type
--- | 0 # disabled
--- | 1 # enabled, but can be overridden by gadget.GetInfo().unsafe
--- | 2 # always enabled
local SAFEWRAP = 0

local HANDLER_DIR = "LuaGadgets/"
local GADGETS_DIR = Script.GetName():gsub("US$", "") .. "/Gadgets/"
local SCRIPT_DIR = Script.GetName() .. "/"
local LOG_SECTION = "" -- FIXME: "LuaRules" section is not registered anywhere
local DEBUG_CALLINS = true

local VFSMODE = VFS.ZIP_FIRST
if Spring.IsDevLuaEnabled() then
	VFSMODE = VFS.RAW_FIRST
end

VFS.Include(HANDLER_DIR .. "setupdefs.lua", nil, VFSMODE)
VFS.Include(HANDLER_DIR .. "system.lua", nil, VFSMODE)
VFS.Include(HANDLER_DIR .. "callins.lua", nil, VFSMODE)
VFS.Include(SCRIPT_DIR .. "utilities.lua", nil, VFSMODE)

local actionHandler = VFS.Include(HANDLER_DIR .. "actions.lua", nil, VFSMODE)

--------------------------------------------------------------------------------

function pgl() -- (print gadget list)  FIXME: move this into a gadget
	for k, v in ipairs(gadgetHandler.gadgets) do
		Spring.Log(LOG_SECTION, LOG.ERROR, string.format("%3i  %3i  %s", k, v.ghInfo.layer, v.ghInfo.name))
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  the gadgetHandler object
--

--- @class ActionHandler

--- @class GadgetHandler
--- @field gadgets Gadget[]
--- @field gadget_callin_map table<string, Gadget[]>
--- @field gadget_implemented_callins table<Gadget, string[]>
--- @field orderlist any[]
--- @field knownGadgets string[]
--- @field knownCount integer
--- @field knownChanged boolean
--- @field GG table
--- @field globals table
--- @field CMDIDs table
--- @field xViewSize integer
--- @field yViewSize integer
--- @field xViewSizeOld integer
--- @field yViewSizeOld integer
--- @field actionHandler ActionHandler
--- @field mouseOwner Gadget?
--- @field suppress_sort boolean
gadgetHandler = {

	gadgets = {},
	gadget_callin_map = {},
	gadget_implemented_callins = {},

	orderList = {},

	knownGadgets = {},
	knownCount = 0,
	knownChanged = true,

	GG = {}, -- shared table for gadgets

	globals = {}, -- global vars/funcs

	CMDIDs = {},

	xViewSize = 1,
	yViewSize = 1,
	xViewSizeOld = 1,
	yViewSizeOld = 1,

	actionHandler = actionHandler,
	mouseOwner = nil,

	suppress_sort = false,
}

-- Utility call
local isSyncedCode = (SendToUnsynced ~= nil)
local function IsSyncedCode()
	return isSyncedCode
end

for fn_name, func in pairs(CALLIN_LIST) do
	gadgetHandler.gadget_callin_map[fn_name] = {}
	local function run_loop(...)
		Spring.Echo("Calling callin" .. fn_name)
		local gadgets_list = gadgetHandler.gadget_callin_map[fn_name]
		return func(gadgetHandler, fn_name, gadgets_list, ...)
	end
	_G[fn_name] = run_loop
end

--- @private
--- @param fullpath string
--- @return string? basename
--- @return string dirname
local function Basename(fullpath)
	local _, _, base = string.find(fullpath, "([^\\/:]*)$")
	local _, _, path = string.find(fullpath, "(.*[\\/:])[^\\/:]*$")
	if path == nil then
		path = ""
	end
	return base, path
end

--- Sort the Gadget list, if suppression isn't off
--- @private
function gadgetHandler:SortGadgets()
	if self.suppress_sort then
		return
	end

	local sort_fun = function(g1, g2)
		local l1 = g1.ghInfo.layer
		local l2 = g2.ghInfo.layer
		if l1 ~= l2 then
			return (l1 < l2)
		end
		local n1 = g1.ghInfo.name
		local n2 = g2.ghInfo.name
		local o1 = self.orderList[n1]
		local o2 = self.orderList[n2]
		if o1 ~= o2 then
			return (o1 < o2)
		else
			return (n1 < n2)
		end
	end

	-- sort main list
	table.sort(self.gadgets, sort_fun)
	-- sort all callin maps
	for _, list in pairs(self.gadget_callin_map) do
		table.sort(list, sort_fun)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadgetHandler:Initialize()
	local syncedHandler = Script.GetSynced()

	-- get the gadget names
	local gadgetFiles = VFS.DirList(GADGETS_DIR, "*.lua", VFSMODE)

	-- locad gadgets
	self.suppress_sort = true -- stop sorting until all are done so we only do it once
	for _, gf in ipairs(gadgetFiles) do
		local gadget = self:LoadGadget(gf)
		if gadget then
			self:InsertGadget(gadget)
			local gtype = ((syncedHandler and "SYNCED") or "UNSYNCED")
			local gname = gadget.ghInfo.name
			local gbasename = gadget.ghInfo.basename
			self.knownGadgets[gname] = gf
			Spring.Log(LOG_SECTION, LOG.INFO, string.format("Loaded %s gadget:  %-18s  <%s>", gtype, gname, gbasename))
		end
	end
	self.suppress_sort = false
	self:SortGadgets()
end

--- Create a new Gadget
--- @return Gadget
function gadgetHandler:NewGadget()
	---@diagnostic disable-next-line: missing-fields
	local gadget = {} --- @type Gadget

	return gadget
end

--- Load a Gadget from a file
--- @param filename string
function gadgetHandler:LoadGadget(filename)
	local basename = Basename(filename)
	local text = VFS.LoadFile(filename, VFSMODE)
	if text == nil then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to load: " .. filename)
		return nil
	end
	local chunk, err = loadstring(text, filename)
	if chunk == nil then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to load: " .. basename .. "  (" .. err .. ")")
		return nil
	end

	local env = {
		_G = _G,
		GG = self.GG,
	}
	env.include = function(f)
		return VFS.Include(f, env, VFSMODE)
	end
	--- @return Gadget
	env.NewGadget = function()
		---@diagnostic disable-next-line: missing-fields
		local gadget = {} --- @type Gadget
		env.gadgetHandler = self:WrapGadgetHandler(gadget)
		return gadget
	end

	-- load the system calls into the gadget table
	for k, v in pairs(System) do
		env[k] = v
	end

	setfenv(chunk, env)
	local success, res = pcall(chunk)
	if not success then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to load: " .. basename .. "  (" .. tostring(res) .. ")")
		return nil
	end
	if res == false then -- note that all "normal" gadgets return `nil` implicitly at EOF, so don't do "if not err"
		return nil -- gadget asked for a quiet death
	end
	if res == nil then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to load: " .. basename .. " (Did not return a gadget object)")
		return nil
	end
	local gadget = res --[[@as Gadget]]

	-- raw access to gadgetHandler
	if gadget.GetInfo and gadget:GetInfo().handler then
		env.rawGadgetHandler = self
	end

	self:FinalizeGadget(gadget, filename, basename)
	local name = gadget.ghInfo.name

	err = self:ValidateGadget(gadget)
	if err then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to load: " .. basename .. "  (" .. err .. ")")
		return nil
	end

	local knownInfo = self.knownGadgets[name]
	if knownInfo then
		if knownInfo.active then
			Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to load: " .. basename .. "  (duplicate name)")
			return nil
		end
	else
		-- create a knownInfo table
		knownInfo = {}
		knownInfo.desc = gadget.ghInfo.desc
		knownInfo.author = gadget.ghInfo.author
		knownInfo.basename = gadget.ghInfo.basename
		knownInfo.filename = gadget.ghInfo.filename
		self.knownGadgets[name] = knownInfo
		self.knownCount = self.knownCount + 1
		self.knownChanged = true
	end
	knownInfo.active = true

	local info = gadget.GetInfo and gadget:GetInfo()
	local order = self.orderList[name]
	if ((order ~= nil) and (order > 0)) or ((order == nil) and ((info == nil) or info.enabled)) then
		-- this will be an active gadget
		if order == nil then
			self.orderList[name] = 12345 -- back of the pack
		else
			self.orderList[name] = order
		end
	else
		self.orderList[name] = 0
		self.knownGadgets[name].active = false
		return nil
	end

	return gadget
end

--- @param gadget Gadget
--- @return GadgetHandlerProxy
function gadgetHandler:WrapGadgetHandler(gadget)
	return {
		RaiseGadget = function(_)
			self:RaiseGadget(gadget)
		end,
		LowerGadget = function(_)
			self:LowerGadget(gadget)
		end,
		RemoveGadget = function(_)
			self:RemoveGadget(gadget)
		end,
		GetViewSizes = function(_)
			return self:GetViewSizes()
		end,
		GetHourTimer = function(_)
			return self:GetHourTimer()
		end,
		IsSyncedCode = function(_)
			return IsSyncedCode()
		end,
		RegisterCMDID = function(_, id)
			self:RegisterCMDID(gadget, id)
		end,
		RegisterGlobal = function(_, name, value)
			return self:RegisterGlobal(gadget, name, value)
		end,
		DeregisterGlobal = function(_, name)
			return self:DeregisterGlobal(gadget, name)
		end,
		SetGlobal = function(_, name, value)
			return self:SetGlobal(gadget, name, value)
		end,
		AddChatAction = function(_, cmd, func, help)
			return actionHandler.AddChatAction(gadget, cmd, func, help)
		end,
		RemoveChatAction = function(_, cmd)
			return actionHandler.RemoveChatAction(gadget, cmd)
		end,
		IsMouseOwner = function(_)
			return (self.mouseOwner == gadget)
		end,
		DisownMouse = function(_)
			if self.mouseOwner == gadget then
				self.mouseOwner = nil
			end
		end,
		AddSyncAction = function(_, cmd, func, help)
			if IsSyncedCode() then
				return nil
			end
			return actionHandler.AddSyncAction(gadget, cmd, func, help)
		end,
		RemoveSyncAction = function(_, cmd)
			if IsSyncedCode() then
				return nil
			end
			return actionHandler.RemoveSyncAction(gadget, cmd)
		end,
	}
end

--- Setup gadget metainfo
--- @param gadget Gadget
--- @param filename string
--- @param basename string
function gadgetHandler:FinalizeGadget(gadget, filename, basename)
	---@diagnostic disable-next-line: missing-fields
	local gi = {} --- @type GadgetInfo

	gi.filename = filename
	gi.basename = basename
	if gadget.GetInfo == nil then
		gi.name = basename
		gi.layer = 0
	else
		local info = gadget:GetInfo()
		gi.name = info.name or basename
		gi.layer = info.layer or 0
		gi.desc = info.desc or ""
		gi.author = info.author or ""
		gi.license = info.license or ""
		gi.enabled = info.enabled or false
	end

	--- @class info: GadgetInfo
	local gh_info = {} --  a proxy table
	local mt = {
		__index = gi,
		__newindex = function()
			error("ghInfo tables are read-only")
		end,
		__metatable = "protected",
	}
	setmetatable(gh_info, mt)
	gadget.ghInfo = gh_info
end

--- Validate a Gadget
--- @param gadget Gadget
--- @return string? error_message
function gadgetHandler:ValidateGadget(gadget)
	if gadget.GetTooltip and not gadget.IsAbove then
		return "Gadget has GetTooltip() but not IsAbove()"
	end
	if gadget.TweakGetTooltip and not gadget.TweakIsAbove then
		return "Gadget has TweakGetTooltip() but not TweakIsAbove()"
	end
	return nil
end

--- Add a Gadget
--- @param gadget Gadget
function gadgetHandler:InsertGadget(gadget)
	if gadget == nil then
		return
	end

	self.gadget_implemented_callins[gadget] = {}
	local implemented_list = self.gadget_implemented_callins[gadget]
	for listname, _ in pairs(CALLIN_LIST) do
		local func = gadget[listname]
		if func ~= nil and type(func) == "function" then
			table.insert(implemented_list, listname)
		end
	end

	for _, callin in ipairs(implemented_list) do
		local callin_map_list = self.gadget_callin_map[callin]
		if callin_map_list ~= nil then
			table.insert(callin_map_list, gadget)
		end
	end

	if gadget.Initialize then
		gadget:Initialize()
	end

	self:SortGadgets()
end

--- Remove a Gadget
--- @param gadget Gadget
function gadgetHandler:RemoveGadget(gadget)
	if gadget == nil then
		return
	end

	for index, value in ipairs(self.gadgets) do
		if value == gadget then
			table.remove(self.gadgets, index)
			break
		end
	end
	-- remove from gadget lists
	for _, callin in ipairs(self.gadget_implemented_callins[gadget]) do
		local callin_map = self.gadget_callin_map[callin]
		for i, g in ipairs(callin_map) do
			if g == gadget then
				table.remove(callin_map, i)
				break
			end
		end
	end

	if gadget.Shutdown then
		gadget:Shutdown()
	end

	self:RemoveGadgetGlobals(gadget)

	for id, g in pairs(self.CMDIDs) do
		if g == gadget then
			self.CMDIDs[id] = nil
		end
	end

	self:SortGadgets()
end

--- Enable a Gadget
--- @param name string
--- @return boolean success
function gadgetHandler:EnableGadget(name)
	local ki = self.knownGadgets[name]
	if not ki then
		Spring.Log(LOG_SECTION, LOG.ERROR, "EnableGadget(), could not find gadget: " .. tostring(name))
		return false
	end
	if not ki.active then
		Spring.Log(LOG_SECTION, LOG.INFO, "Loading:  " .. ki.filename)
		local order = gadgetHandler.orderList[name]
		if not order or (order <= 0) then
			self.orderList[name] = 1
		end
		local w = self:LoadGadget(ki.filename)
		if not w then
			return false
		end
		self:InsertGadget(w)
	end
	return true
end

--- Disable a Gadget
--- @param name string
--- @return boolean success
function gadgetHandler:DisableGadget(name)
	local ki = self.knownGadgets[name]
	if not ki then
		Spring.Log(LOG_SECTION, LOG.ERROR, "DisableGadget(), could not find gadget: " .. tostring(name))
		return false
	end
	if ki.active then
		local w = self:FindGadget(name)
		if not w then
			return false
		end
		Spring.Log(LOG_SECTION, LOG.INFO, "Removed:  " .. ki.filename)
		self:RemoveGadget(w) -- deactivate
		self.orderList[name] = 0 -- disable
	end
	return true
end

--- Toggle a Gadget's enabled state
--- @param name string
--- @return boolean success
function gadgetHandler:ToggleGadget(name)
	local ki = self.knownGadgets[name]
	if not ki then
		Spring.Log(LOG_SECTION, LOG.ERROR, "ToggleGadget(), could not find gadget: " .. tostring(name))
		return false
	end
	if ki.active then
		return self:DisableGadget(name)
	elseif self.orderList[name] <= 0 then
		return self:EnableGadget(name)
	else
		-- the gadget is not active, but enabled; disable it
		self.orderList[name] = 0
	end
	return true
end

--------------------------------------------------------------------------------

local function FindGadgetIndex(t, w)
	for k, v in ipairs(t) do
		if v == w then
			return k
		end
	end
	return nil
end

function gadgetHandler:RaiseGadget(gadget)
	if gadget == nil then
		return
	end

	local function FindLowestIndex(t, i, layer)
		local n = #t
		for x = (i + 1), n, 1 do
			if t[x].ghInfo.layer < layer then
				return (x - 1)
			end
		end
		return n
	end

	local function Raise(callinList, gadget)
		local gadgetIdx = FindGadgetIndex(callinList, gadget)
		if gadgetIdx == nil then
			return
		end

		-- starting from gIdx and counting up, find the index
		-- of the first gadget whose layer is lower** than g's
		-- and move g to right before (lowestIdx - 1) it
		-- ** lists are in reverse layer order, lowest at back
		local lowestIdx = FindLowestIndex(callinList, gadgetIdx, gadget.ghInfo.layer)

		if lowestIdx > gadgetIdx then
			-- insert first since lowestIdx is larger
			table.insert(callinList, lowestIdx, gadget)
			table.remove(callinList, gadgetIdx)
		end
	end

	Raise(self.gadgets, gadget)

	for _, listname in ipairs(CALLIN_LIST) do
		if gadget[listname] ~= nil then
			Raise(self[listname .. "List"], gadget)
		end
	end
end

function gadgetHandler:LowerGadget(gadget)
	if gadget == nil then
		return
	end

	local function FindHighestIndex(t, i, layer)
		for x = (i - 1), 1, -1 do
			if t[x].ghInfo.layer > layer then
				return (x + 1)
			end
		end
		return 1
	end

	local function Lower(callinList, gadget)
		local gadgetIdx = FindGadgetIndex(callinList, gadget)
		if gadgetIdx == nil then
			return
		end

		-- starting from gIdx and counting down, find the index
		-- of the first gadget whose layer is higher** than g's
		-- and move g to right after (highestIdx + 1) it
		-- ** lists are in reverse layer order, highest at front
		local highestIdx = FindHighestIndex(callinList, gadgetIdx, gadget.ghInfo.layer)

		if highestIdx < gadgetIdx then
			-- remove first since highestIdx is smaller
			table.remove(callinList, gadgetIdx)
			table.insert(callinList, highestIdx, gadget)
		end
	end

	Lower(self.gadgets, gadget)

	for _, listname in ipairs(CALLIN_LIST) do
		if gadget[listname] ~= nil then
			Lower(self[listname .. "List"], gadget)
		end
	end
end

function gadgetHandler:FindGadget(name)
	if type(name) ~= "string" then
		return nil
	end
	for k, v in ipairs(self.gadgets) do
		if name == v.ghInfo.name then
			return v, k
		end
	end
	return nil
end

--------------------------------------------------------------------------------
--  Global var/func management

function gadgetHandler:RegisterGlobal(owner, name, value)
	if name == nil then
		return false
	end
	if _G[name] ~= nil then
		return false
	end
	if self.globals[name] ~= nil then
		return false
	end
	if CALLIN_MAP[name] ~= nil then
		return false
	end

	_G[name] = value
	self.globals[name] = owner
	return true
end

function gadgetHandler:DeregisterGlobal(_, name)
	if name == nil then
		return false
	end
	_G[name] = nil
	self.globals[name] = nil
	return true
end

function gadgetHandler:SetGlobal(owner, name, value)
	if (name == nil) or (self.globals[name] ~= owner) then
		return false
	end
	_G[name] = value
	return true
end

function gadgetHandler:RemoveGadgetGlobals(owner)
	local count = 0
	for name, o in pairs(self.globals) do
		if o == owner then
			_G[name] = nil
			self.globals[name] = nil
			count = count + 1
		end
	end
	return count
end

--------------------------------------------------------------------------------
--  Helper facilities

local hourTimer = 0

function gadgetHandler:GetHourTimer()
	return hourTimer
end

function gadgetHandler:GetViewSizes()
	return self.xViewSize, self.yViewSize
end

function gadgetHandler:RegisterCMDID(gadget, id)
	if id <= 1000 then
		Spring.Log(
			LOG_SECTION,
			LOG.ERROR,
			"Gadget (" .. gadget.ghInfo.name .. ") " .. "tried to register a reserved CMD_ID"
		)
		Script.Kill("Reserved CMD_ID code: " .. id)
	end

	if self.CMDIDs[id] ~= nil then
		Spring.Log(
			LOG_SECTION,
			LOG.ERROR,
			"Gadget (" .. gadget.ghInfo.name .. ") " .. "tried to register a duplicated CMD_ID"
		)
		Script.Kill("Duplicate CMD_ID code: " .. id)
	end

	self.CMDIDs[id] = gadget
end

function gadgetHandler:SetViewSize(vsx, vsy)
	self.xViewSize = vsx
	self.yViewSize = vsy
	if (self.xViewSizeOld ~= vsx) or (self.yViewSizeOld ~= vsy) then
		_G["ViewResize"](vsx, vsy)
		self.xViewSizeOld = vsx
		self.yViewSizeOld = vsy
	end
end

--------------------------------------------------------------------------------

Spring.Echo("SCRIPT_DIRSCRIPT_DIRSCRIPT_DIRSCRIPT_DIRSCRIPT_DIR", Spring.Utilities.CMD)
gadgetHandler:Initialize()

Spring.Echo(
	"InitializeInitializeInitializeInitializeInitializeInitializeInitializeInitializeInitializeInitializeInitialize",
	Spring.Utilities.CMD
)

--------------------------------------------------------------------------------
-- Type Definitions

--- @class GadgetHandlerProxy
--- @field RaiseGadget fun(self: GadgetHandlerProxy) Raises the gadget.
--- @field LowerGadget fun(self: GadgetHandlerProxy) Lowers the gadget.
--- @field RemoveGadget fun(self: GadgetHandlerProxy) Removes the gadget.
--- @field GetViewSizes fun(self: GadgetHandlerProxy):number, number Returns the view sizes.
--- @field GetHourTimer fun(self: GadgetHandlerProxy):number Returns the hour timer.
--- @field IsSyncedCode fun(self: GadgetHandlerProxy):boolean Returns whether the code is synced.
--- @field RegisterCMDID fun(self: GadgetHandlerProxy, id: number) Registers a command ID for the gadget.
--- @field RegisterGlobal fun(self: GadgetHandlerProxy, name: string, value: any):any Registers a global variable for the gadget.
--- @field DeregisterGlobal fun(self: GadgetHandlerProxy, name: string):any Deregisters a global variable for the gadget.
--- @field SetGlobal fun(self: GadgetHandlerProxy, name: string, value: any):any Sets a global variable for the gadget.
--- @field AddChatAction fun(self: GadgetHandlerProxy, cmd: string, func: function, help: string):any Adds a chat action for the gadget.
--- @field RemoveChatAction fun(self: GadgetHandlerProxy, cmd: string):any Removes a chat action for the gadget.
--- @field IsMouseOwner fun(self: GadgetHandlerProxy):boolean Returns whether the gadget is the mouse owner.
--- @field DisownMouse fun(self: GadgetHandlerProxy) Disowns the mouse if the gadget is the owner.
--- @field AddSyncAction fun(self: GadgetHandlerProxy, cmd: string, func: function, help: string):any Adds a sync action for the gadget.
--- @field RemoveSyncAction fun(self: GadgetHandlerProxy, cmd: string):any Removes a sync action for the gadget.

--- @class GadgetInfo
--- @field name string
--- @field desc string Short description of the gadget.
--- @field author string Author of the gadget.
--- @field date string Date of creation or last update.
--- @field license string License information.
--- @field layer integer Determines the order in which gadgets are called.
--- @field enabled boolean Whether the gadget is enabled by default.
--- @field handler boolean If true, gadget has access to the handler.
--- @field basename string Autogenerated.
--- @field filename string Autogenerated.

--- @class GadgetInfoPacket
--- @field name string
--- @field desc string? Short description of the gadget.
--- @field author string Author of the gadget.
--- @field date string? Date of creation or last update.
--- @field license string? License information.
--- @field layer integer Determines the order in which gadgets are called.
--- @field enabled boolean Whether the gadget is enabled by default.
--- @field handler boolean? If true, gadget has access to the handler.

--- @class Gadget
--- @field ghInfo GadgetInfo
--- @field GetInfo (fun(self: Gadget): GadgetInfoPacket)?
--- @field Initialize fun(self: Gadget)?
--- @field Shutdown fun(self: Gadget)?
--- @field Save fun(self: Gadget, zip: table)? Called when the game is saved.
--- @field Load fun(self: Gadget, zip: table)? Called after GamePreload and before GameStart.
--- @field Pong fun(self: Gadget, pingTag: integer, pktSendTime: number, pktRecvTime: number)? Called when a pong response is received.
--- @field GameSetup (fun(self: Gadget, state: string, ready: boolean, playerStates: table): boolean, boolean)? Called to set up the game before it starts.
--- @field GamePreload fun(self: Gadget)? Called before the 0 gameframe.
--- @field GameStart fun(self: Gadget)? Called upon the start of the game.
--- @field GameOver fun(self: Gadget, winningAllyTeams: integer[])? Called when the game ends.
--- @field GameFrame fun(self: Gadget, frameNum: integer)? Called for every game simulation frame (30 per second).
--- @field GameFramePost fun(self: Gadget, frameNum: integer)? Called at the end of every game simulation frame.
--- @field GamePaused fun(self: Gadget, playerID: integer, paused: boolean)? Called when the game is paused.
--- @field GameProgress fun(self: Gadget, serverFrameNum: integer)? Called every 60 frames, calculating delta between GameFrame and GameProgress.
--- @field GameID fun(self: Gadget, gameID: string)? Called once to deliver the gameID.
--- @field PlayerChanged fun(self: Gadget, playerID: integer)? Called whenever a player's status changes.
--- @field PlayerAdded fun(self: Gadget, playerID: integer)? Called whenever a new player joins the game.
--- @field PlayerRemoved fun(self: Gadget, playerID: integer, reason: string)? Called whenever a player is removed from the game.
--- @field TeamDied fun(self: Gadget, teamID: integer)? Called when a team dies.
--- @field TeamChanged fun(self: Gadget, teamID: integer)? Called when a team changes.
--- @field UnitCreated fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, builderID: integer?)? Called at the moment the unit is created.
--- @field UnitFinished fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called at the moment the unit is completed.
--- @field UnitFromFactory fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, factID: integer, factDefID: integer, userOrders: boolean)? Called when a factory finishes construction of a unit.
--- @field UnitReverseBuilt fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a living unit becomes a nanoframe again.
--- @field UnitConstructionDecayed fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, timeSinceLastBuild: number, iterationPeriod: number, part: number)? Called when a unit being built starts decaying.
--- @field UnitDestroyed fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, attackerID: integer, attackerDefID: integer, attackerTeam: integer, weaponDefID: integer)? Called when a unit is destroyed.
--- @field RenderUnitDestroyed fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called just before a unit is invalid, after it finishes its death animation.
--- @field UnitExperience fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, experience: number, oldExperience: number)? Called when a unit gains experience.
--- @field UnitIdle fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit is idle (empty command queue).
--- @field UnitCmdDone fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, options: table, cmdTag: integer)? Called when a unit completes a command.
--- @field UnitPreDamaged (fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, damage: number, paralyzer: number, weaponDefID: integer, projectileID: integer, attackerID: integer, attackerDefID: integer, attackerTeam: integer): number, number)? Called before a unit is damaged.
--- @field UnitDamaged fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, damage: number, paralyzer: number, weaponDefID: integer, projectileID: integer, attackerID: integer, attackerDefID: integer, attackerTeam: integer)? Called when a unit is damaged (after UnitPreDamaged).
--- @field UnitStunned fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, stunned: boolean)? Called when a unit changes its stun status.
--- @field UnitTaken fun(self: Gadget, unitID: integer, unitDefID: integer, oldTeam: integer, newTeam: integer)? Called when a unit is transferred between teams (before UnitGiven).
--- @field UnitGiven fun(self: Gadget, unitID: integer, unitDefID: integer, newTeam: integer, oldTeam: integer)? Called when a unit is transferred between teams (after UnitTaken).
--- @field UnitEnteredRadar fun(self: Gadget, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer)? Called when a unit enters radar of an allyteam.
--- @field UnitEnteredLos fun(self: Gadget, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer)? Called when a unit enters LOS of an allyteam.
--- @field UnitLeftRadar fun(self: Gadget, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer)? Called when a unit leaves radar of an allyteam.
--- @field UnitLeftLos fun(self: Gadget, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer)? Called when a unit leaves LOS of an allyteam.
--- @field UnitSeismicPing fun(self: Gadget, x: number, y: number, z: number, strength: number, allyTeam: integer, unitID: integer, unitDefID: integer)? Called when a unit emits a seismic ping.
--- @field UnitLoaded fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, transportID: integer, transportTeam: integer)? Called when a unit is loaded by a transport.
--- @field UnitUnloaded fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, transportID: integer, transportTeam: integer)? Called when a unit is unloaded by a transport.
--- @field UnitCloaked fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit cloaks.
--- @field UnitDecloaked fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit decloaks.
--- @field UnitUnitCollision fun(self: Gadget, colliderID: integer, collideeID: integer): boolean?? Called when two units collide.
--- @field UnitFeatureCollision fun(self: Gadget, colliderID: integer, collideeID: integer): boolean?? Called when a unit collides with a feature.
--- @field UnitMoveFailed fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit move fails.
--- @field UnitMoved fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit moves.
--- @field UnitEnteredAir fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit enters air.
--- @field UnitLeftAir fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit leaves air.
--- @field UnitEnteredWater fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit enters water.
--- @field UnitLeftWater fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit leaves water.
--- @field UnitEnteredUnderwater fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit enters underwater.
--- @field UnitLeftUnderwater fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit leaves underwater.
--- @field UnitCommand fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, options: table, cmdTag: integer)? Called after a unit accepts a command.
--- @field UnitHarvestStorageFull fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer)? Called when a unit's harvestStorage is full.
--- @field StockpileChanged fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, weaponNum: integer, oldCount: integer, newCount: integer)? Called when a unit's stockpile of weapons changes.
--- @field FeatureCreated fun(self: Gadget, featureID: integer, allyTeamID: integer)? Called when a feature is created.
--- @field FeatureDestroyed fun(self: Gadget, featureID: integer, allyTeamID: integer)? Called when a feature is destroyed.
--- @field FeatureDamaged fun(self: Gadget, featureID: integer, featureDefID: integer, featureTeam: integer, damage: number, weaponDefID: integer, projectileID: integer, attackerID: integer, attackerDefID: integer, attackerTeam: integer)? Called when a feature is damaged.
--- @field FeatureMoved fun(self: Gadget, featureID: integer, featureDefID: integer, featureTeam: integer)? Called when a feature moves.
--- @field FeaturePreDamaged (fun(self: Gadget, featureID: integer, featureDefID: integer, featureTeam: integer, damage: number, weaponDefID: integer, projectileID: integer, attackerID: integer, attackerDefID: integer, attackerTeam: integer): number, number)? Called before a feature is damaged.
--- @field ProjectileCreated fun(self: Gadget, proID: integer, proOwnerID: integer, weaponDefID: integer)? Called when a projectile is created.
--- @field ProjectileDestroyed fun(self: Gadget, proID: integer, ownerID: integer, proWeaponDefID: integer)? Called when a projectile is destroyed.
--- @field ShieldPreDamaged (fun(self: Gadget, proID: integer, proOwnerID: integer, shieldEmitterWeapNum: integer, shieldCarrierUnitID: integer, bounceProj: boolean, beamEmitterWeapNum: integer, beamEmitterUnitID: integer, spx: number, spy: number, spz: number, hpx: number, hpy: number, hpz: number): boolean?)? Called before a shield is damaged.
--- @field AllowCommand fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, options: table, cmdTag: integer, playerID: integer, fromSynced: boolean, fromLua: boolean): boolean? Called to determine if a command is allowed.
--- @field AllowStartPosition fun(self: Gadget, playerID: integer, teamID: integer, readyState: integer, cx: number, cy: number, cz: number, rx: number, ry: number, rz: number): boolean? Called to determine if a start position is allowed.
--- @field AllowUnitCreation fun(self: Gadget, unitDefID: integer, builderID: integer, builderTeam: integer, x: number, y: number, z: number, facing: integer): boolean, boolean? Called to determine if a unit creation is allowed.
--- @field AllowUnitTransfer fun(self: Gadget, unitID: integer, unitDefID: integer, oldTeam: integer, newTeam: integer, capture: boolean): boolean? Called to determine if a unit transfer is allowed.
--- @field AllowUnitBuildStep fun(self: Gadget, builderID: integer, builderTeam: integer, unitID: integer, unitDefID: integer, part: number): boolean? Called to determine if a unit build step is allowed.
--- @field AllowUnitCaptureStep fun(self: Gadget, builderID: integer, builderTeam: integer, unitID: integer, unitDefID: integer, part: number): boolean? Called to determine if a unit capture step is allowed.
--- @field AllowUnitTransport fun(self: Gadget, transporterID: integer, transporterUnitDefID: integer, transporterTeam: integer, transporteeID: integer, transporteeUnitDefID: integer, transporteeTeam: integer): boolean? Called to determine if a unit transport is allowed.
--- @field AllowUnitTransportLoad (fun(self: Gadget, transporterID: integer, transporterUnitDefID: integer, transporterTeam: integer, transporteeID: integer, transporteeUnitDefID: integer, transporteeTeam: integer, loadPosX: number, loadPosY: number, loadPosZ: number): boolean)? Called to determine if a unit transport load is allowed.
--- @field AllowUnitTransportUnload (fun(self: Gadget, transporterID: integer, transporterUnitDefID: integer, transporterTeam: integer, transporteeID: integer, transporteeUnitDefID: integer, transporteeTeam: integer, unloadPosX: number, unloadPosY: number, unloadPosZ: number): boolean)? Called to determine if a unit transport unload is allowed.
--- @field AllowUnitCloak fun(self: Gadget, unitID: integer, enemyID: integer): boolean? Called to determine if a unit can cloak.
--- @field AllowUnitDecloak (fun(self: Gadget, unitID: integer, objectID: integer, weaponID: integer): boolean)? Called to determine if a unit can decloak.
--- @field AllowUnitKamikaze (fun(self: Gadget, unitID: integer, targetID: integer): boolean)? Called to determine if a unit can kamikaze.
--- @field AllowFeatureBuildStep (fun(self: Gadget, builderID: integer, builderTeam: integer, featureID: integer, featureDefID: integer, part: number): boolean)? Called to determine if a feature build step is allowed.
--- @field AllowFeatureCreation (fun(self: Gadget, featureDefID: integer, teamID: integer, x: number, y: number, z: number): boolean)? Called to determine if a feature creation is allowed.
--- @field AllowResourceLevel (fun(self: Gadget, teamID: integer, res: string, level: number): boolean)? Called to determine if a resource level is allowed.
--- @field AllowResourceTransfer (fun(self: Gadget, oldTeamID: integer, newTeamID: integer, res: string, amount: number): boolean)? Called to determine if a resource transfer is allowed.
--- @field AllowDirectUnitControl (fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, playerID: integer): boolean)? Called to determine if direct unit control is allowed.
--- @field AllowBuilderHoldFire (fun(self: Gadget, unitID: integer, unitDefID: integer, action: string): boolean)? Called to determine if builder hold fire is allowed.
--- @field AllowWeaponTargetCheck (fun(self: Gadget, attackerID: integer, attackerWeaponNum: integer, attackerWeaponDefID: integer): boolean, boolean)? Called to determine if a weapon target check is allowed.
--- @field AllowWeaponTarget (fun(self: Gadget, attackerID: integer, targetID: integer, attackerWeaponNum: integer, attackerWeaponDefID: integer, defPriority: number): boolean, number)? Called to determine if a weapon target is allowed.
--- @field AllowWeaponInterceptTarget (fun(self: Gadget, interceptorUnitID: integer, interceptorWeaponNum: integer, interceptorTargetID: integer): boolean)? Called to determine if a weapon intercept target is allowed.
--- @field Explosion (fun(self: Gadget, weaponDefID: integer, px: number, py: number, pz: number, attackerID: integer, projectileID: integer): boolean?)? Called when an explosion occurs.
--- @field CommandFallback (fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, cmdOptions: table, cmdTag: integer): boolean, boolean)? Called when a command fallback is needed.
--- @field MoveCtrlNotify (fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, data: any): boolean)? Called when a move control notification is received.
--- @field TerraformComplete (fun(self: Gadget, unitID: integer, unitDefID: integer, unitTeam: integer, buildUnitID: integer, buildUnitDefID: integer, buildUnitTeam: integer): boolean)? Called when terraforming is complete.
--- @field GotChatMsg (fun(self: Gadget, msg: string, playerID: integer): boolean)? Called when a player issues a UI command.
--- @field RecvLuaMsg (fun(self: Gadget, msg: string, playerID: integer): boolean)? Receives messages from unsynced sent via Spring.SendLuaRulesMsg or Spring.SendLuaUIMsg.
--- @field Update fun(self: Gadget, dt: number)? Called for every draw frame and at least once per sim frame except when catching up.
--- @field UnsyncedHeightMapUpdate (fun(self: Gadget): number, number, number, number)? Called when the unsynced copy of the height-map is altered.
--- @field DrawGenesis fun(self: Gadget)? Use this callin to update textures, shaders, etc.
--- @field DrawWorld fun(self: Gadget)? Spring draws command queues, 'map stuff', and map marks.
--- @field DrawWorldPreUnit fun(self: Gadget)? Spring draws units, features, some water types, cloaked units, and the sun.
--- @field DrawOpaqueUnitsLua fun(self: Gadget, deferredPass: boolean, drawReflection: boolean, drawRefraction: boolean)? Called for opaque unit drawing.
--- @field DrawOpaqueFeaturesLua fun(self: Gadget, deferredPass: boolean, drawReflection: boolean, drawRefraction: boolean)? Called for opaque feature drawing.
--- @field DrawAlphaUnitsLua fun(self: Gadget, drawReflection: boolean, drawRefraction: boolean)? Called for alpha unit drawing.
--- @field DrawAlphaFeaturesLua fun(self: Gadget, drawReflection: boolean, drawRefraction: boolean)? Called for alpha feature drawing.
--- @field DrawShadowUnitsLua fun(self: Gadget)? Called for shadow unit drawing.
--- @field DrawShadowFeaturesLua fun(self: Gadget)? Called for shadow feature drawing.
--- @field DrawPreDecals fun(self: Gadget)? Called before decals are drawn.
--- @field DrawWorldPreParticles fun(self: Gadget, drawAboveWater: boolean, drawBelowWater: boolean, drawReflection: boolean, drawRefraction: boolean)? Called multiple times per draw frame for different permutations.
--- @field DrawWorldShadow fun(self: Gadget)? Called for world shadow drawing.
--- @field DrawWorldReflection fun(self: Gadget)? Called for world reflection drawing.
--- @field DrawWorldRefraction fun(self: Gadget)? Called for world refraction drawing.
--- @field DrawGroundPreForward fun(self: Gadget)? Runs at the start of the forward pass.
--- @field DrawGroundPostForward fun(self: Gadget)? Runs at the end of the forward pass.
--- @field DrawGroundPreDeferred fun(self: Gadget)? Runs at the start of the deferred pass.
--- @field DrawGroundDeferred fun(self: Gadget)? Runs during the deferred pass.
--- @field DrawGroundPostDeferred fun(self: Gadget)? Runs at the end of the deferred pass.
--- @field DrawUnitsPostDeferred fun(self: Gadget)? Runs at the end of the unit deferred pass.
--- @field DrawFeaturesPostDeferred fun(self: Gadget)? Runs at the end of the feature deferred pass.
--- @field DrawScreenEffects fun(self: Gadget, viewSizeX: number, viewSizeY: number)? Called for screen effects.
--- @field DrawScreenPost fun(self: Gadget, viewSizeX: number, viewSizeY: number)? Called after the frame is completely rendered.
--- @field DrawScreen fun(self: Gadget, viewSizeX: number, viewSizeY: number)? Called for screen drawing.
--- @field DrawInMiniMap fun(self: Gadget, sx: number, sy: number)? Called for minimap drawing.
--- @field FontsChanged fun(self: Gadget)? Called whenever fonts are updated.
--- @field SunChanged fun(self: Gadget)? Called when the sun changes.
--- @field RecvFromSynced fun(self: Gadget, ...)? Receives messages from synced code.
--- @field RecvSkirmishAIMessage fun(self: Gadget, aiTeam: integer, dataStr: string): any? Called when a message is received from a Skirmish AI.
--- @field DefaultCommand fun(self: Gadget, type: string, id: integer): any? Used to set the default command when a unit is selected.
--- @field ActiveCommandChanged fun(self: Gadget, cmdId: integer, cmdType: integer)? Called when a command is issued.
--- @field CameraRotationChanged fun(self: Gadget, rotX: number, rotY: number, rotZ: number)? Called whenever the camera rotation changes.
--- @field CameraPositionChanged fun(self: Gadget, posX: number, posY: number, posZ: number)? Called whenever the camera position changes.
--- @field CommandNotify fun(self: Gadget, cmdID: integer, cmdParams: table, options: table): boolean? Called when a command is issued.
--- @field ViewResize fun(self: Gadget, viewSizeX: number, viewSizeY: number)? Called whenever the window is resized.
--- @field LayoutButtons fun(self: Gadget, ...)? Called to layout buttons.
--- @field ConfigureLayout fun(self: Gadget, ...)? Called to configure layout.
--- @field AddConsoleLine fun(self: Gadget, msg: string, priority: integer)? Called when text is entered into the console.
--- @field GroupChanged fun(self: Gadget, groupID: integer)? Called when a unit is added to or removed from a control group.
--- @field KeyPress (fun(self: Gadget, keyCode: number, mods: table, isRepeat: boolean, label: boolean, utf32char: number, scanCode: number, actionList: table): boolean)? Called repeatedly when a key is pressed down.
--- @field KeyRelease (fun(self: Gadget, keyCode: number, mods: table, label: boolean, utf32char: number, scanCode: number, actionList: table): boolean)? Called when the key is released.
--- @field TextInput (fun(self: Gadget, utf8char: string): boolean)? Called whenever a key press results in text input.
--- @field TextEditing (fun(self: Gadget, utf8: string, start: number, length: number))? Called when text is being edited.
--- @field MousePress (fun(self: Gadget, x: number, y: number, button: number): boolean)? Called when a mouse button is pressed.
--- @field MouseRelease (fun(self: Gadget, x: number, y: number, button: number): boolean)? Called when a mouse button is released.
--- @field MouseMove fun(self: Gadget, x: number, y: number, dx: number, dy: number, button: number)? Called when the mouse is moved.
--- @field MouseWheel fun(self: Gadget, up: boolean, value: number)? Called when the mouse wheel is moved.
--- @field IsAbove (fun(self: Gadget, x: number, y: number): boolean)? Called every Update. Must return true for Mouse* events and Spring.GetToolTip to be called.
--- @field GetTooltip (fun(self: Gadget, x: number, y: number): string)? Called when Spring.IsAbove returns true.
--- @field WorldTooltip fun(self: Gadget, ...)? Called to provide a world tooltip.
--- @field MapDrawCmd (fun(self: Gadget, playerID: integer, type: string, posX: number, posY: number, posZ: number, label: string): boolean)? Called when a map draw command is issued.
--- @field ShockFront fun(self: Gadget, ...)? Called for shock front events.
--- @field DownloadQueued fun(self: Gadget, id: integer, name: string, type: string)? Called when a download is queued.
--- @field DownloadStarted fun(self: Gadget, id: integer)? Called when a download is started.
--- @field DownloadFinished fun(self: Gadget, id: integer)? Called when a download finishes successfully.
--- @field DownloadFailed fun(self: Gadget, id: integer, errorID: integer)? Called when a download fails to complete.
--- @field DownloadProgress fun(self: Gadget, id: integer, downloaded: integer, total: integer)? Called incrementally during a download.
