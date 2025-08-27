return ComposedUnit.New(
	"Base Tent",
	"The base of operations for the demons. Can make engineers.",
	GetFilenameTrimmed(),
	{
		category = "LAND",
		footprintX = 4,
		footprintZ = 4,

		objectName = "demons/buildings/demon_base_tent.s3o",
		script = "scripts/demons/buildings/demon_base_tent.lua",
		health = 1000,

		sightDistance = 560,

		collisionVolumeOffsets = [[0 -8 -25]],
		collisionVolumeScales = [[110 46 0]],
		collisionVolumeType = [[cylY]],
		yardmap = "yyyy yyyy yyyy yyyy",
	}
)
	:Is(
		"Building",
		"Builder",
		VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 150),
		VFS.Include("unit_components/component_factories/factory.lua")("demon_engineer")
	)
	:Wrap()
