return { shieldraid = {
  name                   = [[Bandit]],
  description            = [[Medium-Light Raider Bot]],

  footprintX             = 2,
  footprintZ             = 2,
  health                 = 340,

  metalCost              = 75,
  movementClass          = [[KBOT2]],
  objectName             = [[mbot.s3o]],
  script                 = [[shieldraid.lua]],

  sightDistance          = 560,

  speed                  = 90,
  acceleration           = 1.5,
  brakeRate              = 2.4,
  turnRate               = 3000,

  weapons                = {

    {
      def                = [[LASER]],
    },

  },

  weaponDefs             = {

    LASER = {
      name                    = [[Laser Blaster]],
      areaOfEffect            = 8,
      coreThickness           = 0.5,
      craterBoost             = 0,
      craterMult              = 0,

      customParams        = {
        light_camera_height = 1200,
        light_radius = 120,
      },
      
      damage                  = {
        default = 8.48,
      },

      duration                = 0.02,
      fireStarter             = 50,
      heightMod               = 1,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      leadLimit               = 0,
      noSelfDamage            = true,
      range                   = 232,
      reloadtime              = 0.1,
      rgbColor                = [[1 0 0]],
      soundTrigger            = true,
      thickness               = 2.55,
      tolerance               = 10000,
      turret                  = true,
      weaponType              = [[LaserCannon]],
      weaponVelocity          = 870,
    },

  },

} }
