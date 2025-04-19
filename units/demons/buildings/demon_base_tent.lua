return lowerkeys({
	demon_base_tent = {
		name = [[Base Tent]],
		description = [[The base of operations for the demons. Can make engineers.]],
		category = [[LAND BUILDING]],
		footprintX = 4,
		footprintZ = 4,

		objectName = "buildings/demon/demon_base_tent.s3o",
		script = "scripts/demons/buildings/demon_base_tent.lua",
		health = 1000,
		metalCost = 150,

		canMove = 0,
		speed = 0,
		sightDistance = 560,

		builder = true,
		workerTime = 5.0,

		collisionVolumeOffsets = [[0 -8 -25]],
		collisionVolumeScales = [[110 46 0]],
		collisionVolumeType = [[cylY]],
		yardmap = "yyyy yyyy yyyy yyyy",

		buildOptions = {
			[[demon_engineer]],
		},
	},
})
