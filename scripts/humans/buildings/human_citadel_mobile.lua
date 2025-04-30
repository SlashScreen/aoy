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
	piece("leg_ne"),
	piece("leg_se"),
	piece("leg_sw"),
	piece("leg_nw"),
}

local runspeed = 8.5 * (UnitDefs[unitDefID].speed / 115) -- run animation rate, future-proofed
local leg_top = 3.0
local leg_bottom = 0.0
local hangtime = 10 --- framed held in air

local function GetSpeedMod()
	-- disallow zero (instant turn instead -> infinite loop)
	-- return math.max(0.05, GG.att_MoveChange[unitID] or 1)
	return 1.0
end

---@param leg Piece
local function leg_anim(leg)
	local speedmod = GetSpeedMod()
	local truespeed = runspeed * speedmod

	-- Raise
	Move(leg, y_axis, leg_top, truespeed)
	WaitForMove(leg, y_axis)

	-- Hang
	Sleep(hangtime)

	-- Lower
	Move(leg, y_axis, leg_bottom, truespeed)
	WaitForMove(leg, y_axis)
end

local function Walk()
	Signal(signals.Walk)
	Signal(signals.Idle)

	while true do
		for _, leg in ipairs(legs) do
			leg_anim(leg)
		end
	end
end

local function StopWalk() end

function script.StartMoving()
	StartThread(Walk)
end

function script.StopMoving()
	StartThread(StopWalk)
end
