local gadget = gadget --- @type Gadget

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

--- @type {[UnitDefID]: string}
local can_sit_down = {}
--- @type {[UnitDefID]: string}
local can_stand_up = {}

-- Initialize tables
for unit_def_id, unit_def in pairs(UnitDefs) do
	if unit_def.customParams.can_sit_down then
		can_sit_down[unit_def_id] = unit_def.customParams.stationary_form
	end

	if unit_def.customParams.can_stand_up then
		can_stand_up[unit_def_id] = unit_def.customParams.mobile_form
	end
end

if gadgetHandler:IsSyncedCode() then
	---@param unit_id UnitID
	---@param unit_def_id UnitDefID
	---@return boolean
	---@return boolean
	local function sit_down(unit_id, unit_def_id)
		-- TODO: Replace unit with stationary building
		return true, true
	end

	---@param unit_id UnitID
	---@param unit_def_id UnitDefID
	---@return boolean
	---@return boolean
	local function stand_up(unit_id, unit_def_id)
		-- TODO: Replace buildings with mobile unit
		return true, true
	end

	function gadget:CommandFallback(unit_id, unit_def_id, _unit_team, cmd_id, _cmd_params, _cmd_options)
		if cmd_id == CMD_SIT_DOWN then
			return sit_down(unit_id, unit_def_id)
		elseif cmd_id == CMD_STAND_UP then
			return stand_up(unit_id, unit_def_id)
		end
	end

	function gadget:AllowCommand(_unitID, unit_def_id, _unitTeam, cmd_id, _cmdParams, _cmdOptions, _cmdTag, _synced)
		if cmd_id == CMD_SIT_DOWN then
			return can_sit_down[unit_def_id] ~= nil
		elseif cmd_id == CMD_STAND_UP then
			return can_stand_up[unit_def_id] ~= nil
		else
			return true
		end
	end

	function gadget:Initialize()
		gadgetHandler:RegisterCMDID(CMD_SIT_DOWN)
		gadgetHandler:RegisterCMDID(CMD_STAND_UP)
	end

	function dadget:UnitCreated(unit_id)
		Spring.InsertUnitCmdDesc(unit_id, sit_down_command_desc)
		Spring.InsertUnitCmdDesc(unit_id, stand_up_command_desc)
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
