---@alias ResourceType "gold" | "lumber"

local gadget = handler:NewGadget()

function gadget:GetInfo()
	return {
		name = "Unit Resources",
		desc = "Tracks unit resources",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "MIT",
		layer = 0,
		enabled = true,
	}
end

---@type table<UnitID, table<ResourceType, number>>
local unit_resources = {}

if handler:IsSyncedCode() then
	-- Synced Code
else
	-- Unsynced Code
end

return gadget
