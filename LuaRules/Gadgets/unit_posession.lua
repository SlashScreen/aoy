function gadget:GetInfo()
	return {
		name = "Unit Posession",
		desc = "Handles units being posessed",
		author = "Slashscreen",
		date = "Present Day, Present TIme",
		license = "GPL v3",
		layer = 0,
		enabled = true,
	}
end

local CMD_POSSESS_UNIT = Spring.Utilities.CMD.POSSESS_UNIT
local POSSESS_DIST = 25

local command_desc = {
	is = CMD_POSSESS_UNIT,
	type = CMDTYPE.ICON_UNIT,
	name = "Possess Unit",
	action = "possess_unit",
	tooltip = "Possess a unit",
}

local possessed_alternates = {} --- @type table<UnitDefID, UnitDefID>
local possession_time = {} --- @type table<UnitDefID, number>
local can_possess = {} --- @type table<UnitDefID, boolean>

for unit_def_id, unit_def in pairs(UnitDefs) do
	local possessed_def = unit_def.customParams.possessed_alternate
	if possessed_def then
		possessed_alternates[unit_def_id] = UnitDefNames[possessed_def]
		possession_time[unit_def_id] = unit_def.customParams.possession_time or 5.0
	end

	if unit_def.customParams.can_possess then
		can_possess[unit_def_id] = true
	end
end

function gadget:Initialize()
	gadgetHandler:RegisterCMDID(CMD_POSSESS_UNIT)
end

if gadgetHandler:IsSyncedCode() then
	--- @param unit_id UnitID
	--- @param target_id UnitID
	--- @param target_def_id UnitDefID
	--- @param team_id integer
	local function possess_unit(unit_id, target_id, target_def_id, team_id)
		--local delay_time = possession_time[target_def_id]
		local target_alt = possessed_alternates[target_def_id]

		local x, y, z = Spring.GetUnitPosition(target_id)
		if x == nil then
			return false, false
		end

		local ux, _, uz = Spring.GetUnitPosition(unit_id)
		local tx, ty, tz = Spring.GetUnitPosition(target_id)
		if tx == nil then
			return false, false
		end

		local distSq = (ux - tx) * (ux - tx) + (uz - tz) * (uz - tz)
		if distSq > POSSESS_DIST * POSSESS_DIST then
			Spring.SetUnitMoveGoal(unit_id, tx, ty, tz, POSSESS_DIST)
		else
			Spring.DestroyUnit(target_id, false, false, unit_id)
			Spring.CreateUnit(target_alt, x, y, z, "s", team_id)
			return true, true
		end

		return true, false
	end

	function gadget:UnitCreated(unit_id)
		if possessed_alternates[Spring.GetUnitDefID(unit_id)] ~= nil then
			Spring.InsertUnitCmdDesc(unit_id, command_desc)
		end
	end

	function gadget:CommandFallback(unit_id, unit_def_id, unit_team, cmd_id, cmd_params, _cmd_options)
		if cmd_id == CMD_POSSESS_UNIT then
			local target = cmd_params[1] --- @type UnitID
			if target == nil then
				return false, false
			end

			local target_def_id = Spring.GetUnitDefID(target)
			if target_def_id == nil then
				return false, false
			end

			if Spring.GetUnitTeam(target) == unit_team then
				return false, false
			end

			return possess_unit(unit_id, target, target_def_id, unit_team)
		end
	end

	function gadget:AllowCommand(_unitID, unit_def_id, _unitTeam, cmdID, _cmdParams, _cmdOptions, _cmdTag, _synced)
		if cmdID == CMD_POSSESS_UNIT then
			return can_possess[unit_def_id]
		else
			return true
		end
	end
else
end
