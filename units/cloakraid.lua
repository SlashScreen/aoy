return lowerkeys({
	cloakraid = {
		name = [[Glaive]],
		description = [[Light Raider Bot]],
		category    = [[LAND SMALL TOOFAST]],
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

		canmove = 1,
		canattack = 1,

		sightDistance = 560,
		speed = 115.5,
		turnRate = 3000,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales = [[18 28 18]],
		collisionVolumeType = [[cylY]],

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",

		weapons = {

			{
				def = [[EMG]],
				badTargetCategory  = [[FIXEDWING]],
      			onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		},

		weaponDefs = {

			EMG = {
				name = [[Pulse MG]],
				alphaDecay = 0.1,
				areaOfEffect = 8,
				burst = 3,
				burstrate = 0.1,
				colormap = [[1 0.95 0.4 1   1 0.95 0.4 1    0 0 0 0.01    1 0.7 0.2 1]],
				craterBoost = 0,
				craterMult = 0,

				damage = {
					default = 10.5,
				},

				impactOnly = true,
				impulseBoost = 0,
				impulseFactor = 0.4,
				intensity = 0.7,
				interceptedByShieldType = 1,
				leadLimit = 0,
				noGap = false,
				noSelfDamage = true,
				range = 185,
				reloadtime = 0.3,
				rgbColor = [[1 0.95 0.4]],
				separation = 1.5,
				size = 1.75,
				sizeDecay = 0,
				soundStartVolume = 4,
				sprayAngle = 1180,
				stages = 10,
				tolerance = 5000,
				turret = true,
				weaponType = [[Cannon]],
				weaponVelocity = 500,
			},
		},
	},
})
