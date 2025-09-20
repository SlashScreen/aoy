return ComposedUnit.New(
	"Pyry",
	"This timid gargoyle is in charge of forging a highway through the Tarsal Islands. She's pretty handy with a pair of boomerangs.",
	GetFilenameTrimmed(),
	{
		category = "LAND FLESHY DEMON",
		acceleration = 1.5,
		brakeRate = 2.4,

		footprintX = 2,
		footprintZ = 2,
		health = 500,
		metalCost = 65,
		movementClass = [[KBOT2]],
		noAutoFire = false,
		-- allowNonBlockingAim = true,
		objectName = [[se/units/pyry.glb]],
		script = [[scripts/basic_unit.lua]],

		sightDistance = 560,
		speed = 115.5,
		turnRate = 3000,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales = [[18 28 18]],
		collisionVolumeType = [[cylY]],

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",
	}
)
	:Is("Hero")
	:AddWeapon("Boomerangs", { "LAND", "AIR", "WATER", "BUILDING" })
	:Wrap()
