local gadget = gadget --- @type Gadget

function gadget:GetInfo()
	return {
		name = "Hero Inventory",
		desc = "Tracks hero inventory",
		author = "Vileblood, GoogleFrog",
		date = "Present Day, Present Time",
		license = "MIT",
		layer = 0,
		enabled = true,
	}
end

local EVERY_FEATURE_IS_ITEM = false
local EVERY_UNIT_IS_HERO = true

local PICKUP_DIST = 25

local CMD_PICK_UP_ITEM = Spring.Utilities.CMD.PICK_UP_ITEM

local pick_up_item_command_desc = {
	id = CMD_PICK_UP_ITEM,
	type = CMDTYPE.ICON_UNIT_FEATURE_OR_AREA,
	name = "Pick Up Item",
	action = "pick_up_item",
	tooltip = "Pick up an item",
}

--- @type table<UnitDefID, boolean>
local is_hero = {}
--- @type table<FeatureID, boolean>
local is_item = {}
local max_inventory_size = 6

-- Initialize is hero table
for unit_def_id, unit_def in pairs(UnitDefs) do
	if unit_def.customParams.is_hero or EVERY_UNIT_IS_HERO then
		is_hero[unit_def_id] = true
	end
end
-- Initialize is item table
for feature_id, feature in pairs(FeatureDefs) do
	if feature.customParams.is_item or EVERY_FEATURE_IS_ITEM then
		is_item[feature_id] = true
	end
end

--[[ 
for key, _value in pairs(is_item) do
	Spring.Echo(key .. " is an item")
end
 ]]

---is this feature an item
---@param featureID FeatureID | nil
---@return boolean|nil
local function IsItem(featureID)
	--- @type FeatureDefID | nil
	local featureDefID = featureID and Spring.GetFeatureDefID(featureID)
	return featureDefID and is_item[featureDefID]
end

if gadgetHandler:IsSyncedCode() then
	--- @type table<UnitID, integer[]>
	local inventory = {}

	--- Pick up an item
	--- @param item string
	--- @param unit_id integer
	--- @return boolean, boolean
	local function pick_up_item(item, unit_id)
		inventory[unit_id] = inventory[unit_id] or {}
		Spring.Echo("ValidFeatureID", item, Spring.ValidFeatureID(item), unit_id)
		if #inventory[unit_id] >= max_inventory_size or not Spring.ValidFeatureID(item) then
			Spring.ClearUnitGoal(unit_id)
			return true, true
		end

		local fx, fy, fz = Spring.GetFeaturePosition(item)
		local ux, _, uz = Spring.GetUnitPosition(unit_id)
		local distSq = (ux - fx) * (ux - fx) + (uz - fz) * (uz - fz)
		if distSq > PICKUP_DIST * PICKUP_DIST then
			Spring.SetUnitMoveGoal(unit_id, fx, fy, fz, PICKUP_DIST)
		else
			table.insert(inventory[unit_id], item)
			Spring.DestroyFeature(item)
			return true, true
		end
		return true, false
	end

	function gadget:CommandFallback(unit_id, unit_def_id, unit_team, cmd_id, cmd_params, cmd_options)
		if cmd_id == CMD_PICK_UP_ITEM then
			local item = (cmd_params[1] or 0) - Game.maxUnits
			return pick_up_item(item, unit_id)
		end
	end

	function gadget:AllowCommand(_unitID, unit_def_id, _unitTeam, cmdID, _cmdParams, _cmdOptions, _cmdTag, _synced)
		if cmdID == CMD_PICK_UP_ITEM then
			return is_hero[unit_def_id]
		else
			return true
		end
	end

	function gadget:UnitCreated(unitID)
		if is_hero[Spring.GetUnitDefID(unitID)] then
			Spring.InsertUnitCmdDesc(unitID, pick_up_item_command_desc)
		end
	end

	function gadget:Initialize()
		gadgetHandler:RegisterCMDID(CMD_PICK_UP_ITEM)
	end
else
	function gadget:Initialize()
		gadgetHandler:RegisterCMDID(CMD_PICK_UP_ITEM)
		Spring.SetCustomCommandDrawData(CMD_PICK_UP_ITEM, CMD.FIGHT)
		Spring.AssignMouseCursor("Pick Up Item", "cursorfight", true, true)
	end

	---@param type "unit" | "feature"
	---@param id UnitID | FeatureID
	---@return number | nil
	function gadget:DefaultCommand(type, id)
		if type == "feature" then
			if IsItem(id) then
				local selected_units = Spring.GetSelectedUnits()
				for _, unit_id in ipairs(selected_units) do
					if is_hero[Spring.GetUnitDefID(unit_id)] then
						return CMD_PICK_UP_ITEM
					end
				end
			end
		end
	end
end

--[[
TODO:
- Add a function to drop an item
- Add a function to use an item
- Since Heroes do not drop iems when they die, do I just keep the items in the inventory until the game ends?
- Add item definitions and effects
]]
