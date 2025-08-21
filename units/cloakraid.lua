return ComposedUnit.New("Glaive", "Light Raider Bot", "cloakraid", {
	category = [[LAND SMALL TOOFAST]],
	acceleration = 1.5,
	brakeRate = 2.4,

	footprintX = 2,
	footprintZ = 2,
	health = 230,
	movementClass = [[KBOT2]],
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
			def = [[EMG]],
			badTargetCategory = [[FIXEDWING]],
			onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
		},
	},
})
	:Is(VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 65))
	:Wrap()
