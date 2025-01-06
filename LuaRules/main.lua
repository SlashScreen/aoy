local VFSMODE = VFS.ZIP_ONLY
---@type LuaScript
local LuaScript = VFS.Include("LuaRules/synced/lua_unit_scripts.lua", nil, VFSMODE)

LuaScript.Initialize()

function GameFrame(gameFrame)
	LuaScript.GameFrame(gameFrame)
end

function UnitCreated(unitID, unitDefID)
	LuaScript.UnitCreated(unitID, unitDefID)
end
