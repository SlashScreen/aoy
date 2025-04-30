return lowerkeys({
	human_citadel_mobile = {
		name = [[Citadel]],
		description = [[The heart of any human invasion force.]],
		category = [[LAND LARGE]],
		acceleration = 1.5,
		brakeRate = 2.4,

		footprintX = 4,
		footprintZ = 4,
		health = 230,
		metalCost = 65,
		movementClass = [[KBOT2]],
		noAutoFire = false,
		-- allowNonBlockingAim = true,
		objectName = [["humans/buildings/human_citadel.s3o"]],
		script = [[scripts/humans/buildings/human_citadel_mobile.lua]],

		canmove = 1,
		canattack = 1,

		sightDistance = 560,
		speed = 25,
		turnRate = 300,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales = [[18 28 18]],
		collisionVolumeType = [[cylY]],

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",

		weapons = {},

		weaponDefs = {},

		customParams = {
			can_sit_down = true,
			stationary_form = "human_citadel_stationary",
		},
	},
})
