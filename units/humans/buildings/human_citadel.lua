return lowerkeys({
	human_citadel = {
		name = [[Citadel]],
		description = [[The heart of any human invasion force.]],
		category = [[LAND BUILDING]],
		footprintX = 4,
		footprintZ = 4,

		objectName = "humans/buildings/human_citadel.s3o",
		script = "scripts/humans/buildings/human_citadel.lua",

		health = 1000,
		metalCost = 150,
		buildPic = [[demon/engineer_placeholder.dds]],

		canMove = 1,
		canattack = 0,

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

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",

		builder = true,
		workerTime = 1,

		customParams = {
			is_factory = true,
			build_1 = [[human_andros]],

			movable_building = true,
		},
	},
})
