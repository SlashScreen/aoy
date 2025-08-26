return ComposedUnit.New("Glaive", "Light Raider Bot", "cloakraid", {
	category = [[LAND SMALL TOOFAST]],

	objectName = [[spherebot.s3o]],
	script = [[cloakraid.lua]],

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
