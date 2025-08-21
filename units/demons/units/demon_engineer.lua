return ComposedUnit.New(
	"Engineer",
	"These engineers may be in a little above their pay grade, but they are invaluable for building structures. They can't, however, fight for anything.",
	"demon_engineer",
	{
		category = [[LAND SMALL TOOFAST]],
		acceleration = 1.5,
		brakeRate = 2.4,

		footprintX = 2,
		footprintZ = 2,
		health = 230,
		movementClass = [[KBOT2]],
		noAutoFire = false,
		-- allowNonBlockingAim = true,
		objectName = [[mbot.s3o]],
		script = [[shieldraid.lua]],

		sightDistance = 560,
		speed = 115.5,
		turnRate = 3000,

		harvestStorage = 50,
		harvestEnergyStorage = 20,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales = [[18 28 18]],
		collisionVolumeType = [[cylY]],

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",

		weapons = {},
	}
)
	:Is(
		"Builder",
		VFS.Include("unit_components/component_factories/harvests.lua")(20, 50),
		VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 65)
	)
	:Wrap()
