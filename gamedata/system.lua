--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    system.lua
--  brief:   system calls table
--  author:  Dave Rodgers
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- no metatable protection
local function reftable(ref, tbl)
	tbl = tbl or {}
	setmetatable(tbl, { __index = ref })
	return tbl
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local system = {

	--  Custom packages
	VFS = VFS,
	Spring = Spring,

	--  Custom functions
	reftable = reftable,

	--  Custom tables
	DEFS = DEFS,

	--  Standard packages
	math = math,
	table = table,
	string = string,
	coroutine = coroutine,

	--
	--  Standard functions and variables
	--
	assert = assert,
	error = error,

	print = print,

	next = next,
	pairs = pairs,
	ipairs = ipairs,

	tonumber = tonumber,
	tostring = tostring,
	type = type,

	--collectgarbage = collectgarbage,
	--gcinfo         = gcinfo,

	unpack = unpack,
	select = select,

	--dofile         = dofile,
	--loadfile       = loadfile,
	--loadlib        = loadlib,
	loadstring = loadstring,
	--require        = require,

	getmetatable = getmetatable,
	setmetatable = setmetatable,

	rawequal = rawequal,
	rawget = rawget,
	rawset = rawset,

	getfenv = getfenv,
	setfenv = setfenv,

	pcall = pcall,
	xpcall = xpcall,

	_VERSION = _VERSION,
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

setmetatable(system, {
	__newindex = function()
		error("Attempt to write to system")
	end,
	__metatable = function()
		error("Attempt to access system metatable")
	end,
})

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return system

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
