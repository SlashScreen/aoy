return ComposedUnit.New(
	"Base Tent",
	"The base of operations for the demons. Can make engineers.",
	GetFilenameTrimmed(),
	{
		category = "LAND",
		footprintX = 4,
		footprintZ = 4,

		objectName = "humans/buildings/human_citadel.s3o",
		script = "scripts/humans/buildings/human_citadel.lua",
		health = 1000,

		speed = 20,
		turnRate = 300,
		sightDistance = 560,
		acceleration = 1.5,
		brakeRate = 2.4,
		movementClass = [[KBOT2]],

		collisionVolumeOffsets = [[0 -8 -25]],
		collisionVolumeScales = [[110 46 0]],
		collisionVolumeType = [[cylY]],
		yardmap = "yyyy yyyy yyyy yyyy",
	}
)
	:Is(
		"MovableBuilding",
		"Builder",
		VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 150),
		VFS.Include("unit_components/component_factories/factory.lua")("human_andros")
	)
	:Wrap()
