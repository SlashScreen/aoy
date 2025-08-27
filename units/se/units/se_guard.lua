return ComposedUnit.New(
	"Guard",
	"In case of danger, call a guard. These are necessary for pushing back the hostile fauna of Anvilhead.",
	GetFilenameTrimmed(),
	{
		category = "LAND FLESHY DEMON",
		acceleration = 1.5,
		brakeRate = 2.4,

		footprintX = 2,
		footprintZ = 2,
		health = 230,
		metalCost = 65,
		movementClass = [[KBOT2]],
		noAutoFire = false,
		-- allowNonBlockingAim = true,
		objectName = [[spherebot.s3o]],
		script = [[cloakraid.lua]],

		sightDistance = 560,
		speed = 115.5,
		turnRate = 3000,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales = [[18 28 18]],
		collisionVolumeType = [[cylY]],

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",

		weapons = {
			{
				name = [[Spike]],
				badTargetCategory = "IMMUNE_PHYSICAL",
				onlyTargetCategory = "LAND BUILDING",
			},
		},
	}
):Wrap()
