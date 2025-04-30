return lowerkeys({
	human_citadel_stationary = {
		name = [[Citadel]],
		description = [[The heart of any human invasion force.]],
		category = [[LAND BUILDING]],
		footprintX = 4,
		footprintZ = 4,

		objectName = "humans/buildings/human_citadel.s3o",
		script = "scripts/humans/buildings/human_citadel_stationary.lua",
		health = 1000,
		metalCost = 150,

		canMove = 0,
		speed = 0,
		sightDistance = 560,

		collisionVolumeOffsets = [[0 -8 -25]],
		collisionVolumeScales = [[110 46 0]],
		collisionVolumeType = [[cylY]],
		yardmap = "yyyy yyyy yyyy yyyy",

		customParams = {
			is_factory = true,
			build_1 = [[human_andros]],

			can_stand_up = true,
			mobile_form = "human_citadel_mobile",
		},
	},
})
