return lowerkeys({
	human_andros = {
		name = [[Andros]],
		description = [[These creepy automatons make up the bulk of the Human invasion force.]],
		category = [[LAND SMALL TOOFAST]],
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

		customParams = {
			build_time = 10,
		},

		customdefs = {
			can_chop = true,
			wood_cap = 20,
			gold_cap = 50,
		},

		weapons = {

			{
				def = [[Slice]],
				badTargetCategory = [[FIXEDWING]],
				onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
			},
		},

		weaponDefs = {

			Spike = {
				name = [[Slice]],
				areaOfEffect = 8,
				beamTime = 4 / 30,
				canattackground = true,
				cegTag = [[orangelaser]],
				coreThickness = 0.5,
				craterBoost = 0,
				craterMult = 0,

				customParams = {
					light_camera_height = 1000,
					light_color = [[1 1 0.7]],
					light_radius = 150,
					light_beam_start = 0.25,

					combatrange = 60,
				},

				damage = {
					default = 300.1,
				},

				explosionGenerator = [[custom:BEAMWEAPON_HIT_ORANGE]],
				fireStarter = 90,
				impactOnly = true,
				impulseBoost = 0,
				impulseFactor = 0.4,
				interceptedByShieldType = 0,
				lodDistance = 10000,
				minIntensity = 1,
				noSelfDamage = true,
				range = 34,
				reloadtime = 1,
				rgbColor = [[1 0.25 0]],
				soundStart = [[explosion/ex_large7]],
				targetborder = 0.9,
				thickness = 0,
				tolerance = 10000,
				turret = true,
				waterweapon = true,
				weaponType = [[BeamLaser]],
				weaponVelocity = 2000,
			},
		},
	},
})
