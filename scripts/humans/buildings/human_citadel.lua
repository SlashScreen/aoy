--- @enum leg_dirs
local leg_dirs = {
	NE = 1,
	SE = 2,
	SW = 3,
	NW = 4,
}

--- @type {Idle: integer, Walk: integer}
local signals = {
	Idle = 1,
	Walk = 2,
}

--- @alias Piece table
--- @type table<leg_dirs, Piece>
local legs = {
	piece("LegNE"),
	piece("LegSE"),
	piece("LegSW"),
	piece("LegNW"),
}

--- @type table<leg_dirs, Piece>
local arms = {
	piece("ArmNE"),
	piece("ArmSE"),
	piece("ArmSW"),
	piece("ArmNW"),
}

local citadel_body = piece("CitadelBody") --- @type Piece

local runspeed = UnitDefs[unitDefID].speed

local arm_start_rot = math.rad(42)
local arm_end_rot = math.rad(65)
local leg_start_rot = math.rad(80)
local leg_end_rot = math.rad(68)
--- @type table<leg_dirs, {axis: any, arm_start: number, arm_end: number, leg_start: number, leg_end: number}>
--- The axes and signs of everything changes based on the leg so I hardcoded it into this table
local directional_info = {
	{
		axis = x_axis,
		arm_start = -arm_start_rot,
		arm_end = -arm_end_rot,
		leg_start = leg_start_rot,
		leg_end = leg_end_rot,
	},
	{
		axis = z_axis,
		arm_start = -arm_start_rot,
		arm_end = -arm_end_rot,
		leg_start = leg_start_rot,
		leg_end = leg_end_rot,
	},
	{
		axis = x_axis,
		arm_start = arm_start_rot,
		arm_end = arm_end_rot,
		leg_start = -leg_start_rot,
		leg_end = -leg_end_rot,
	},
	{
		axis = z_axis,
		arm_start = arm_start_rot,
		arm_end = arm_end_rot,
		leg_start = -leg_start_rot,
		leg_end = -leg_end_rot,
	},
}

local hangtime = 30 --- frames held in air

local function GetSpeedMod()
	-- disallow zero (instant turn instead -> infinite loop)
	-- return math.max(0.05, GG.att_MoveChange[unitID] or 1)
	return 1.0
end

---@param dir leg_dirs
local function leg_anim(dir)
	local speedmod = GetSpeedMod()
	local truespeed = runspeed * speedmod
	local move_speed = truespeed * 0.2

	local arm = arms[dir]
	local leg = legs[dir]
	local dir_info = directional_info[dir]
	local axis = dir_info.axis
	local arm_start = dir_info.arm_start
	local arm_end = dir_info.arm_end
	local leg_start = dir_info.leg_start
	local leg_end = dir_info.leg_end

	-- Raise
	Turn(arm, axis, arm_end, move_speed)
	WaitForTurn(arm, axis)
	Turn(leg, axis, leg_end, move_speed)
	WaitForTurn(leg, axis)

	-- Hang
	Sleep(hangtime)

	-- Lower
	Turn(arm, axis, arm_start, move_speed)
	WaitForTurn(arm, axis)
	Turn(leg, axis, leg_start, move_speed)
	WaitForTurn(leg, axis)
end

local function Walk()
	Signal(signals.Walk)
	Signal(signals.Idle)
	SetSignalMask(signals.Walk)

	while true do
		for _, dir in pairs(leg_dirs) do
			leg_anim(dir)
		end
	end
end

local function Idle()
	Signal(signals.Idle)
	SetSignalMask(signals.Idle)
end

local function rest()
	local speedmod = GetSpeedMod()
	local truespeed = runspeed * speedmod
	local move_speed = truespeed * 0.2

	for _, dir in pairs(leg_dirs) do
		local arm = arms[dir]
		local leg = legs[dir]
		local dir_info = directional_info[dir]
		local axis = dir_info.axis
		local arm_start = dir_info.arm_start
		local leg_start = dir_info.leg_start

		Turn(arm, axis, arm_start, move_speed)
		WaitForTurn(arm, axis)
		Turn(leg, axis, leg_start, move_speed)
		WaitForTurn(leg, axis)
	end
end

local function StopWalk()
	Signal(signals.Walk)

	rest()

	StartThread(Idle)
end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(StopWalk)
end

function script.Activate()
	SetUnitValue(COB.INBUILDSTANCE, 1)
end

function script.Deactivate()
	Signal(SIG_BUILD)
	SetUnitValue(COB.INBUILDSTANCE, 0)
end

function script.Create()
	Turn(citadel_body, y_axis, math.rad(45), 0) -- Offset by 45
	for _, dir in pairs(leg_dirs) do
		local arm = arms[dir]
		local leg = legs[dir]
		local dir_info = directional_info[dir]
		local axis = dir_info.axis
		local arm_start = dir_info.arm_start
		local leg_start = dir_info.leg_start

		Turn(arm, axis, arm_start, 0)
		WaitForTurn(arm, axis)
		Turn(leg, axis, leg_start, 0)
		WaitForTurn(leg, axis)
	end
end

function script.QueryBuildInfo()
	return 0 -- TODO
end

function script.Killed(recentDamage, maxHealth) end
