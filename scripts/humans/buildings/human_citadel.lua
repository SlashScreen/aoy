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

local runspeed = UnitDefs[unitDefID].speed
local arm_start = math.rad(0)
local arm_end = math.rad(45)
local arm_axis = x_axis
local leg_start = math.rad(0)
local leg_end = math.rad(-45)
local leg_axis = z_axis
local hangtime = 0.5 --- frames held in air

local function GetSpeedMod()
	-- disallow zero (instant turn instead -> infinite loop)
	-- return math.max(0.05, GG.att_MoveChange[unitID] or 1)
	return 1.0
end

---@param leg Piece
local function leg_anim(arm, leg)
	local speedmod = GetSpeedMod()
	local truespeed = runspeed * speedmod

	-- Raise
	Turn(arm, arm_axis, arm_start, truespeed)
	WaitForTurn(arm, arm_axis)
	Turn(leg, leg_axis, leg_start, truespeed)
	WaitForTurn(leg, leg_axis)

	-- Hang
	Sleep(hangtime)

	-- Lower
	Turn(arm, arm_axis, arm_end, truespeed)
	WaitForTurn(arm, arm_axis)
	Turn(leg, leg_axis, leg_end, truespeed)
	WaitForTurn(leg, leg_axis)
end

local function Walk()
	Signal(signals.Walk)
	Signal(signals.Idle)
	SetSignalMask(signals.Walk)

	while true do
		for _, dir in pairs(leg_dirs) do
			leg_anim(arms[dir], legs[dir])
		end
	end
end

local function Idle()
	Signal(signals.Idle)
	SetSignalMask(signals.Idle)
end

local function StopWalk()
	local speedmod = GetSpeedMod()
	local truespeed = runspeed * speedmod

	Signal(signals.Walk)

	for _, dir in pairs(leg_dirs) do
		local arm = arms[dir]
		local leg = legs[dir]

		Turn(arm, arm_axis, arm_start, truespeed)
		WaitForTurn(arm, arm_axis)

		Turn(leg, leg_axis, leg_start, truespeed)
		WaitForTurn(leg, leg_axis)
	end

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

function script.Create() end

function script.QueryBuildInfo()
	return 0 -- TODO
end

function script.Killed(recentDamage, maxHealth) end
