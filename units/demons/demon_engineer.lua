return lowerkeys({
	demon_engineer = {
		name                   = [[Engineer]],
		description            = [[These engineers may be in a little above their pay grade, but they are invaluable for building structures. They can't, however, fight for anything.]],
		category               = [[LAND SMALL TOOFAST]],
		acceleration           = 1.5,
		brakeRate              = 2.4,

		footprintX             = 2,
		footprintZ             = 2,
		health                 = 230,
		metalCost              = 65,
		movementClass          = [[KBOT2]],
		noAutoFire             = false,
		-- allowNonBlockingAim = true,
		objectName             = [[spherebot.s3o]],
		script                 = [[cloakraid.lua]],

		canmove                = 1,
		canattack              = 1,

		sightDistance          = 560,
		speed                  = 115.5,
		turnRate               = 3000,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales  = [[18 28 18]],
		collisionVolumeType    = [[cylY]],

		corpse                 = "",
		explodeAs              = "",
		selfDestructAs         = "",

		weapons                = {},
	},
})
