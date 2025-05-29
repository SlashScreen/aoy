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
local possession_tasks = {} --- @type PossessionTask[]
local tasks_to_remove = {} --- @type PossessionTask[]

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
function PossessionTask:update(delta)
	if self:should_cancel() then -- auto-cancel
		self:cancel()
		return
	end

	if self.valid then -- if valid, count up timer, else set to 0
		self.timer = self.timer + delta
	else
		self.timer = 0.0
	end

	local x, y, z = Spring.GetUnitPosition(self.victim)
	if x == nil then
		return
	end

	if self.timer >= self.max_timer then
		self:finish(x, y, z)
		return
	end

	local ux, _, uz = Spring.GetUnitPosition(self.attacker)
	local tx, ty, tz = Spring.GetUnitPosition(self.victim)
	if tx == nil then
		return
	end

	local distSq = (ux - tx) * (ux - tx) + (uz - tz) * (uz - tz)
	if distSq > POSSESS_DIST * POSSESS_DIST then -- if too far away, make the attacker move to the victim
		self.valid = false
		-- TODO: don't do this every frame
		Spring.SetUnitMoveGoal(self.attacker, tx, ty, tz, POSSESS_DIST)
	else
		self.valid = true
	end
end

--- Cancel this task. Does not actually do the unit remobilization.
function PossessionTask:cancel()
	table.insert(tasks_to_remove, self)
end

function PossessionTask:stop()
	self.valid = false
	if not Spring.GetUnitIsDead(self.victim) then -- victim alive?
		Spring.MoveCtrl.Disable(self.victim)
	end
end

--- Start the task by immobilizing the victim
function PossessionTask:start()
	Spring.MoveCtrl.Enable(self.victim)
end

--- Finish posession
--- @param x integer
--- @param y integer
--- @param z integer
function PossessionTask:finish(x, y, z)
	local target_alt = possessed_alternates[self.victim_def]
	Spring.DestroyUnit(self.victim, false, false, self.attacker)
	Spring.CreateUnit(target_alt, x, y, z, "s", self.attacker_team)
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
--- @param victim UnitID
--- @param max_timer number
--- @return PossessionTask
function PossessionTask.new(attacker, victim, max_timer)
	--- @diagnostic disable-next-line: missing-fields
	local pt = {} --- @type PossessionTask
	setmetatable(pt, { __index = PossessionTask })

	pt.attacker = attacker
	pt.victim = victim
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

	function gadget:Update(delta)
		-- Run update code
		for _, task in ipairs(possession_tasks) do
			task:update(delta)
		end

		-- Remove tasks set to be finished
		for _, task in ipairs(tasks_to_remove) do
			for index, t in ipairs(possession_tasks) do
				if task == t then
					table.remove(possession_tasks, index)
					task:stop() -- Tell it to stop
					--task = nil -- would this erase for gc, or get rid of this specific reference?... Where does this thing live? Ugh, dynamic languages...
					break
				end
			end
		end
	end
else
end

--#endregion

return gadget
