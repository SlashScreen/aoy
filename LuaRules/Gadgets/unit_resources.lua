---@alias ResourceType "gold" | "lumber"

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

if gadgetHandler:IsSyncedCode() then
	-- Synced Code
else
	-- Unsynced Code
end
