return ComposedUnit.New(
	"Sphinx",
	"These huge demons are a bit slow, but can easily smash structures. Believe it or not, they are the same species as the Harpy, just in a different form.",
	GetFilenameTrimmed(),
	{
		category = "LAND FLESHY DEMON SIEGE",
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
		speed = 30,
		turnRate = 3000,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales = [[18 28 18]],
		collisionVolumeType = [[cylY]],

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",
	}
)
	:AddWeapon("Crush", { "LAND", "BUILDING" })
	:Wrap()
