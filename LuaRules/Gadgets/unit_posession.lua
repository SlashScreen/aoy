--- @diagnostic disable-next-line: undefined-global
local handler = handler --- @type GadgetHandlerProxy
local gadget = handler:NewGadget() --- @type Gadget

function gadget:GetInfo()
	return {
		name = "Unit Possession",
		desc = "Handles units being possessed",
		author = "Slashscreen",
		date = "Present Day, Present TIme",
		license = "GPL v3",
		layer = 0,
		enabled = true,
	}
end

local CMD_POSSESS_UNIT = Spring.Utilities.CMD.POSSESS_UNIT
local POSSESS_DIST = 25
local SIM_FRAMES_PER_SECOND = 30

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
local possession_tasks = {} --- @type table<UnitID, PossessionTask>

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

--#region Possession Task

--[[
	When a unit is commanded to possess another unit, it is given a posession task.
	Tasks are upated every slow update frame.
	Tasks are stopped when the unit is dead, the victim is dead, or the task is finished (the timer runs out).
	Tasks are also stopped when the unit is commanded to do something else.
	Tasks are created when the unit is commanded to possess a unit.
]]

--- @class PossessionTask
--- @field attacker UnitID
--- @field attacker_team TeamID
--- @field victim UnitID
--- @field victim_def UnitDefID
--- @field timer number
--- @field max_timer number
--- @field valid boolean
local PossessionTask = {
	attacker = 0,
	attacker_team = 0,
	victim = 0,
	victim_def = 0,
	timer = 0.0,
	max_timer = 1.0,
	valid = true,
}

--- Task update loop
--- @param delta number Delta time
--- @return boolean
--- @return boolean
function PossessionTask:update(delta)
	if self:should_cancel() then -- auto-cancel
		return self:stop()
	end

	if self.valid then -- if valid, count up timer, else set to 0
		self.timer = self.timer + delta
	else
		self.timer = 0.0
	end

	local x, y, z = Spring.GetUnitPosition(self.victim)
	if x == nil then
		return self:stop()
	end

	if self.timer >= self.max_timer then
		return self:finish(x, y, z)
	end

	local ux, _, uz = Spring.GetUnitPosition(self.attacker)
	local tx, ty, tz = Spring.GetUnitPosition(self.victim)
	if tx == nil then
		return self:stop()
	end

	local distSq = (ux - tx) * (ux - tx) + (uz - tz) * (uz - tz)
	if distSq > POSSESS_DIST * POSSESS_DIST then -- if too far away, make the attacker move to the victim
		self.valid = false
		-- TODO: don't do this every frame
		Spring.SetUnitMoveGoal(self.attacker, tx, ty, tz, POSSESS_DIST)
	else
		self.valid = true
	end

	return true, false -- in progress
end

--- @return false
--- @return false
function PossessionTask:stop()
	self.valid = false
	if not Spring.GetUnitIsDead(self.victim) then -- victim alive?
		Spring.MoveCtrl.Disable(self.victim)
	end
	possession_tasks[self.attacker] = nil
	return false, false
end

--- Start the task by immobilizing the victim
function PossessionTask:start()
	Spring.MoveCtrl.Enable(self.victim)
end

--- Finish posession
--- @param x integer
--- @param y integer
--- @param z integer
--- @return true
--- @return true
function PossessionTask:finish(x, y, z)
	local target_alt = possessed_alternates[self.victim_def]
	Spring.DestroyUnit(self.victim, false, false, self.attacker)
	Spring.CreateUnit(target_alt, x, y, z, "s", self.attacker_team)
	return true, true
end

--- Should this task be cancelled?
--- @return boolean
function PossessionTask:should_cancel()
	if Spring.GetUnitIsDead(self.attacker) then -- attacker dead?
		return true
	end
	if Spring.GetUnitIsDead(self.victim) then -- victim dead?
		return true
	end
	return false
end

--- Create a new task
--- @param attacker UnitID
--- @param attacker_team TeamID
--- @param victim UnitID
--- @param victim_def UnitDefID
--- @param max_timer number
--- @return PossessionTask
function PossessionTask.new(attacker, attacker_team, victim, victim_def, max_timer)
	--- @diagnostic disable-next-line: missing-fields
	local pt = {} --- @type PossessionTask
	setmetatable(pt, { __index = PossessionTask })

	pt.attacker = attacker
	pt.attacker_team = attacker_team
	pt.victim = victim
	pt.victim_def = victim_def
	pt.max_timer = max_timer

	return pt
end

--#endregion

-- * Gadget functions
--#region

function gadget:Initialize()
	handler:RegisterCMDID(CMD_POSSESS_UNIT)
end

if handler:IsSyncedCode() then
	function gadget:UnitCreated(unit_id)
		if possessed_alternates[Spring.GetUnitDefID(unit_id)] ~= nil then
			Spring.InsertUnitCmdDesc(unit_id, command_desc)
		end
	end

	function gadget:CommandFallback(unit_id, _unit_def_id, unit_team, cmd_id, cmd_params, _cmd_options)
		if cmd_id == CMD_POSSESS_UNIT then
			local task = possession_tasks[unit_id] -- if we have the task already, update it
			if task then
				local delta = 1.0 / SIM_FRAMES_PER_SECOND
				return task:update(delta)
			end

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

			local new_task =
				PossessionTask.new(unit_id, unit_team, target, target_def_id, possession_time[target_def_id])

			possession_tasks[unit_id] = new_task

			return true, false
		end
	end

	function gadget:AllowCommand(unit_id, unit_def_id, unit_team, cmdID, cmd_params, _cmdOptions, _cmdTag, _synced)
		if cmdID == CMD_POSSESS_UNIT then
			local target = cmd_params[1] --- @type UnitID
			if target == nil then
				return false
			end

			local target_def_id = Spring.GetUnitDefID(target)
			if target_def_id == nil then
				return false
			end

			if Spring.GetUnitTeam(target) == unit_team then
				return false
			end

			return can_possess[unit_def_id]
		else
			-- if we have a task, stop it
			local task = possession_tasks[unit_id]
			if task then
				task:stop()
			end
			return true
		end
	end
else
end

--#endregion

return gadget
