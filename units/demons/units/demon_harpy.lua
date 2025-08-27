return ComposedUnit.New(
	"Harpy",
	"These odd demons are a bit standoffish, but hey, they can fly, and that's invaluable in these circumstances. Believe it or not, they are the same species as the Sphinx, just in a different form.",
	"demon_harpy",
	{
		category = [[AIR SMALL TOOFAST]],
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
				name = [[Slice]],
				badTargetCategory = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		},
	}
):Wrap()
