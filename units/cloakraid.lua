return ComposedUnit.New("Glaive", "Light Raider Bot", GetFilenameTrimmed(), {
	category = "LAND MACHINE",

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
			name = [[EMG]],
			badTargetCategory = "IMMUNE_PHYSICAL",
			onlyTargetCategory = "LAND AIR WATER BUILDING",
		},
	},
})
	:Is(VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 65))
	:Wrap()
