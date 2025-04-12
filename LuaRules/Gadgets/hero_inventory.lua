local gadget = gadget --- @type Gadget
--- @alias UnitID integer
--- @alias UnitDefID integer
--- @alias FeatureID integer

CMD_PICKUP_ITEM = 0xDEADBEEF

function gadget:GetInfo()
	return {
		name = "Hero Inventory",
		desc = "Tracks hero inventory",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "MIT",
		layer = 0,
		enabled = true,
	}
end

if not gadgetHandler:IsSyncedCode() then
	return
end

local pick_up_item_command_desc = {
	id = CMD_PICKUP_ITEM,
	type = CMDTYPE.ICON_UNIT_FEATURE_OR_AREA,
	name = "Pick Up Item",
	action = "pick_up_item",
	tooltip = "Pick up an item",
	hidden = true,
}

--- @type table<UnitID, integer[]>
local inventory = {}
--- @type table<UnitDefID, boolean>
local is_hero = {}
local max_inventory_size = 6

-- Initialize is hero table
for unit_def_id, unit_def in pairs(UnitDefs) do
	if unit_def.customparams.is_hero then
		is_hero[unit_def_id] = true
	end
end

--- Pick up an item
--- @param item string
--- @param unit_id integer
--- @return boolean
local function pick_up_item(item, unit_id)
	local unit_def_id = Spring.GetUnitDefID(unit_id)
	if not is_hero[unit_def_id] then
		return false
	end

	if #inventory[unit_id] >= max_inventory_size then
		return false
	end

	if not inventory[unit_id] then
		inventory[unit_id] = {}
	end

	table.insert(inventory[unit_id], item)
	return true
end

function gadget:CommandFallback(unit_id, unit_def_id, cmd_id, cmd_params, cmd_options)
	if cmd_id == CMD_PICKUP_ITEM then
		local item = cmd_params[1]
		return pick_up_item(item, unit_id)
	end
end

function gadget:AllowCommand(_unitID, unit_def_id, _unitTeam, cmdID, _cmdParams, _cmdOptions, _cmdTag, _synced)
	if cmdID == CMD_PICKUP_ITEM then
		return UnitDefs[unit_def_id].customparams.is_hero ~= nil
	else
		return true
	end
end

---@param type "unit" | "feature"
---@param id UnitID | FeatureID
---@return table | nil
function gadget:DefaultCommand(type, id)
	if type == "feature" then
	else
	end
end

--[[
TODO:
- Add a function to drop an item
- Add a function to use an item
- Since Heroes do not drop iems when they die, do I just keep the items in the inventory until the game ends?
- Add item definitions and effects
]]
