return lowerkeys({
	demon_base_tent = {
		name = [[Base Tent]],
		description = [[The base of operations for the demons. Can make engineers.]],
		category = [[LAND BUILDING]],
		footprintX = 4,
		footprintZ = 4,

		objectName = "buildings/demon/demon_base_tent.s3o",
		health = 1000,

		canMove = 0,
		speed = 0,
		sightDistance = 560,

		buolder = true,

		collisionVolumeOffsets = [[0 -8 -25]],
		collisionVolumeScales = [[110 46 0]],
		collisionVolumeType = [[cylY]],
		yardmap = "oooo oooo oooo oooo",

		buildOptions = {
			[[demon_engineer]],
		},
	},
})
