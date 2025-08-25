--- @type UnitDef
local default = {
	name = "",
	description = "",
	buildPic = "",
	objectName = "",
	script = "",
	maxDamage = 0.0,
	autoHeal = 0.0,
	idleAutoHeal = 0.0,
	idleTime = 0,
	buildCostMetal = 0.0,
	buildCostEnergy = 0.0,
	buildTime = 1.0,
	mass = 0.0,
	reclaimable = true,
	capturable = true,
	repairable = true,
	maxRepairSpeed = 0.0,
	iconType = "",
	corpse = "",
	explodeAs = "",
	selfDestructAs = "",
	harvestStorage = 0.0,
	metalStorage = 0.0,
	energyStorage = 0.0,
	extractsMetal = 0.0,
	windGenerator = 0.0,
	tidalGenerator = 0.0,
	metalUse = 0.0,
	energyUse = 0.0,
	metalMake = 0.0,
	energyMake = 0.0,
	makesMetal = 0.0,
	canCloak = false,
	cloakCost = 0.0,
	cloakCostMoving = 0.0,
	initCloaked = false,
	minCloakDistance = 0.0,
	decloakSpherical = false,
	decloakOnFire = false,
	cloakTimeout = 0,
	onOffable = false,
	activateWhenBuilt = false,
	sightDistance = 0.0,
	airSightDistance = 0.0,
	losEmitHeight = 0.0,
	radarEmitHeight = 0.0,
	radarDistance = 0,
	sonarDistance = 0,
	radarDistanceJam = 0,
	sonarDistanceJam = 0,
	stealth = false,
	sonarStealth = false,
	seismicDistance = 0,
	seismicSignature = 0.0,
	canMove = true,
	canAttack = true,
	canFight = true,
	canPatrol = true,
	canGuard = true,
	canRepeat = true,
	canSelfDestruct = false,
	moveState = 0,
	fireState = 0,
	noAutoFire = false,
	canManualFire = false,
	builder = false,
	buildDistance = 0.0,
	buildRange3D = false,
	workerTime = 0.0,
	repairSpeed = 0.0,
	reclaimSpeed = 0.0,
	resurrectSpeed = 0.0,
	captureSpeed = 0.0,
	terraformSpeed = 0.0,
	canAssist = false,
	canBeAssisted = false,
	canSelfRepair = false,
	showNanoSpray = false,
	nanoColor = { 1, 1, 1 },
	fullHealthFactory = false,
	isAirbase = false,
	footprintX = 1,
	footprintZ = 1,
	yardmap = "",
	buildingMask = 0,
	levelGround = false,
	movementClass = "",
	floater = false,
	upright = false,
	maxSlope = 0.0,
	minWaterDepth = 0.0,
	maxWaterDepth = 0.0,
	waterline = 0.0,
	minCollisionSpeed = 0.0,
	pushResistant = false,
	maxVelocity = 0.0,
	maxReverseVelocity = 0.0,
	acceleration = 0.0,
	brakeRate = 0.0,
	myGravity = 0.0,
	turnRate = 0.0,
	turnInPlace = false,
	turnInPlaceSpeedLimit = 0.0,
	turnInPlaceAngleLimit = 0.0,
	blocking = true,
	crushResistance = 0.0,
	flankingBonusMode = 0,
	flankingBonusDir = { 0, 0, 0 },
	flankingBonusMax = 0.0,
	flankingBonusMin = 0.0,
	flankingBonusMobilityAdd = 0.0,
	canFly = false,
	canSubmerge = false,
	factoryHeadingTakeoff = false,
	collide = true,
	hoverAttack = false,
	airStrafe = false,
	cruiseAlt = 0.0,
	airHoverFactor = 0.0,
	bankingAllowed = false,
	useSmoothMesh = false,
	maxFuel = 0.0,
	refuelTime = 0.0,
	minAirbasePower = 1.0,
	canLoopbackAttack = false,
	wingDrag = 0.0,
	wingAngle = 0.0,
	frontToSpeed = 0.0,
	speedToFront = 0.0,
	crashDrag = 0.0,
	maxBank = 0.0,
	maxPitch = 0.0,
	turnRadius = 0.0,
	verticalSpeed = 0.0,
	maxAileron = 0.0,
	maxElevator = 0.0,
	maxRudder = 0.0,
	maxAcc = 0.0,
	attackSafetyDistance = 0.0,
	canDropFlare = false,
	flareReload = 0.0,
	flareDelay = 0.0,
	flareEfficiency = 0.0,
	flareDropVector = { 0, 0, 0 },
	flareTime = 0,
	flareSalvoSize = 0,
	flareSalvoDelay = 0,
	transportSize = 0,
	minTransportSize = 0,
	transportCapacity = 0,
	transportMass = 0.0,
	minTransportMass = 0.0,
	loadingRadius = 0.0,
	unloadSpread = 0.0,
	isFirePlatform = false,
	holdSteady = false,
	releaseHeld = false,
	cantBeTransported = false,
	transportByEnemy = false,
	transportUnloadMethod = 0,
	fallSpeed = 0.0,
	unitFallSpeed = 0.0,
	category = "",
	noChaseCategory = "",
	leaveTracks = false,
	trackType = "",
	trackWidth = 0.0,
	trackOffset = 0.0,
	trackStrength = 0.0,
	trackStretch = 0.0,
	useBuildingGroundDecal = false,
	buildingGroundDecalType = "",
	buildingGroundDecalSizeX = 0,
	buildingGroundDecalSizeY = 0,
	buildingGroundDecalDecaySpeed = 0.0,
	usePieceCollisionVolumes = false,
	useFootPrintCollisionVolume = false,
	collisionVolume = {
		type = "box",
		axis = "y",
		scales = { 0, 0, 0 },
		offsets = { 0, 0, 0 },
	},
	usePieceSelectionVolumes = false,
	useFootPrintSelectionVolume = false,
	selectionVolume = {
		type = "box",
		axis = "y",
		scales = { 0, 0, 0 },
		offsets = { 0, 0, 0 },
	},
	highTrajectory = 0,
	kamikaze = false,
	kamikazeDistance = 0.0,
	kamikazeUseLOS = false,
	strafeToAttack = false,
	decoyFor = "",
	selfDestructCountdown = 0,
	damageModifier = 1.0,
	isTargetingUpgrade = false,
	isFeature = false,
	hideDamage = false,
	showPlayerName = false,
	showNanoFrame = false,
	unitRestricted = 0,
	power = 1.0,
	weapons = {
		-- Example weapon entry
		-- {
		--     name = "",
		--     badTargetCategory = "",
		--     onlyTargetCategory = "",
		--     slaveTo = 0,
		--     mainDir = {0, 0, 0},
		--     maxAngleDif = 0.0,
		--     fuelUsage = 0.0,
		-- }
	},
	buildOptions = {},
	SFXTypes = {
		explosionGenerators = {},
		pieceExplosionGenerators = {},
	},
	sounds = {
		ok = {},
		select = {},
		arrived = {},
		build = {},
		activate = {},
		deactivate = {},
		cant = {},
		underattack = {},
	},
	customParams = {},
}

--- @param t1 table
--- @param t2 table
local function merge_tables(t1, t2)
	for key, value in pairs(t2) do
		if type(value) == "table" then
			if type(t1[key]) == "table" then
				merge_tables(t1[key], value)
			else
				t1[key] = value
			end
		else
			t1[key] = value
		end
	end
end

--- @class UnitComponent
--- @field name string
--- @field component table
--- @field mutators fun(self: UnitDef)[]?

-- Load Unit Components

local components = {} --- @type {string: UnitComponent}

for _, filename in ipairs(VFS.DirList("unit_components/components", "*.lua", nil, true)) do
	local success, tbl = pcall(VFS.Include, filename, _G)
	if not success then
		Spring.Log("unit.lua", LOG.ERROR, "Bad return table from: " .. filename)
	end

	if type(tbl) ~= "table" then
		Spring.Log("unit.lua", LOG.ERROR, "Bad return table from: " .. filename)
	end

	components[tbl.name] = tbl
end

-- * UNIT

--- @class ComposedUnit : UnitDef
--- @field unit_id string
local Unit = {}

--- @param name string
--- @param desc string
--- @param config table?
--- @return ComposedUnit
function Unit.New(name, desc, id, config)
	local output = config or {}

	output.name = name
	output.description = desc
	output.unit_id = id

	setmetatable(output, { __index = Unit })

	return output
end

--- Add a component to a unit
--- @param ... string | UnitComponent
--- @return ComposedUnit
function Unit:Is(...)
	for i = 1, select("#", ...) do
		local name = select(i, ...)

		if type(name) == "string" then
			local c = components[name]
			if c then
				merge_tables(self, c.component)
				for _, m in ipairs(c.mutators or {}) do
					m(self)
				end
			end
		else
			merge_tables(self, name.component)
			for _, m in ipairs(name.mutators or {}) do
				m(self)
			end
		end

		return self
	end
end

function Unit:Wrap()
	local t = {}
	t[self.unit_id] = self
	return t
end

return Unit
