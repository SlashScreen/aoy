return ComposedUnit.New("Glaive Melee", "Test melee", GetFilenameTrimmed(), {
	category = "LAND MACHINE",

	acceleration = 1.5,
	brakeRate = 2.4,

	footprintX = 2,
	footprintZ = 2,
	health = 230,
	movementclass = [[KBOT2]],
	noAutoFire = false,
	-- allowNonBlockingAim = true,
	objectName = [[spherebot.s3o]],
	script = [[cloakraid.lua]],

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
			name = [[Spike]],
			badTargetCategory = "IMMUNE_PHYSICAL",
			onlyTargetCategory = "LAND AIR WATER BUILDING",
		},
	},
})
	:Is(VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 65))
	:Wrap()
