--- @module "Include/types"
local gadget = NewGadget()

function gadget:GetInfo()
	return {
		name = "Building Movement State",
		desc = "Handles transitioning from a mobile building to a stationary one and vice versa",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "LGPL-3.0-or-later",
		layer = 0,
		enabled = true,
	}
end

local CMD_STAND_UP = Spring.Utilities.CMD.BUILDING_STAND_UP
local CMD_SIT_DOWN = Spring.Utilities.CMD.BUILDING_SIT_DOWN

--- @type CommandDescription
local sit_down_command_desc = {
	id = CMD_SIT_DOWN,
	type = CMDTYPE.ICON, -- TODO: Maybe move to a specific position?
	name = "Sit Down",
	action = "sit_down",
	tooltip = "Sit the building on the ground",
}

--- @type CommandDescription
local stand_up_command_desc = {
	id = CMD_STAND_UP,
	type = CMDTYPE.ICON, -- TODO: Maybe move to a specific position?
	name = "Stand Up",
	action = "stand_up",
	tooltip = "Pick the building up off the ground",
}

local is_movable_building = {} --- @type {[UnitDefID]: true}

-- Initialize tables
for unit_def_id, unit_def in pairs(UnitDefs) do
	if unit_def.customParams.movable_building then
		is_movable_building[unit_def_id] = true
	end
end

---@param unit_def_id UnitDefID
---@return boolean?
local function is_movable(unit_def_id)
	if is_movable_building[unit_def_id] then
		return true
	else
		return nil
	end
end

if gadgetHandler:IsSyncedCode() then
	---@param unit_id UnitID
	---@param unit_def_id UnitDefID
	---@param team_id TeamID
	---@return boolean
	local function sit_down(unit_id, unit_def_id, team_id)
		Spring.Echo("Sitting down")
		Spring.MoveCtrl.Enable(unit_id) --SetGroundMoveTypeData(unit_id, "maxSpeed", 0.0)
		return true
	end

	---@param unit_id UnitID
	---@param unit_def_id UnitDefID
	---@param team_id TeamID
	---@return boolean
	local function stand_up(unit_id, unit_def_id, team_id)
		Spring.Echo("Standing up")
		Spring.MoveCtrl.Disable(unit_id) --SetGroundMoveTypeData(unit_id, "maxSpeed", def.speed)
		return true
	end

	function gadget:AllowCommand(unit_id, unit_def_id, unit_team, cmd_id, _cmdParams, _cmdOptions, _cmdTag, _synced)
		if cmd_id == CMD_SIT_DOWN then
			return (not is_movable(unit_def_id)) or sit_down(unit_id, unit_def_id, unit_team)
		elseif cmd_id == CMD_STAND_UP then
			return (not is_movable(unit_def_id)) or stand_up(unit_id, unit_def_id, unit_team)
		end

		return true
	end

	function gadget:Initialize()
		gadgetHandler:RegisterCMDID(CMD_SIT_DOWN)
		gadgetHandler:RegisterCMDID(CMD_STAND_UP)
	end

	function gadget:UnitCreated(unit_id)
		if is_movable_building[Spring.GetUnitDefID(unit_id)] ~= nil then
			Spring.InsertUnitCmdDesc(unit_id, sit_down_command_desc)
			Spring.InsertUnitCmdDesc(unit_id, stand_up_command_desc)
		end
	end
else
	function gadget:Initialize()
		gadgetHandler:RegisterCMDID(CMD_SIT_DOWN)
		Spring.SetCustomCommandDrawData(CMD_SIT_DOWN, CMD.MOVE)
		Spring.AssignMouseCursor("Sit Down", "cursorfight", true, true)

		gadgetHandler:RegisterCMDID(CMD_STAND_UP)
		Spring.SetCustomCommandDrawData(CMD_STAND_UP, CMD.MOVE)
		Spring.AssignMouseCursor("Stand Up", "cursorfight", true, true)
	end
end

return gadget
