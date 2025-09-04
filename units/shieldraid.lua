return ComposedUnit.New("Bandit", "Medium-light raider bot", GetFilenameTrimmed(), {
	category = "LAND MACHINE",

	footprintX = 2,
	footprintZ = 2,
	health = 340,

	movementClass = [[KBOT2]],
	objectName = [[mbot.s3o]],
	script = [[shieldraid.lua]],

	sightDistance = 560,

	speed = 90,
	acceleration = 1.5,
	brakeRate = 2.4,
	turnRate = 3000,
})
	:Is(VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 75))
	:AddWeapon("LASER", { "LAND", "AIR", "WATER", "BUILDING" })
	:Wrap()
