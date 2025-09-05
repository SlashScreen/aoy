return ComposedUnit.New(
	"Andros",
	"These creepy automatons make up the bulk of the Human invasion force.",
	GetFilenameTrimmed(),
	{
		category = "LAND MACHINE",
		acceleration = 1.5,
		brakeRate = 2.4,

		footprintX = 2,
		footprintZ = 2,
		health = 230,
		movementClass = [[KBOT2]],
		noAutoFire = false,
		-- allowNonBlockingAim = true,
		objectName = [[spherebot.s3o]],
		script = [[scripts/basic_unit.lua]],

		sightDistance = 560,
		speed = 115.5,
		turnRate = 3000,

		collisionVolumeOffsets = [[0 -2 0]],
		collisionVolumeScales = [[18 28 18]],
		collisionVolumeType = [[cylY]],

		corpse = "",
		explodeAs = "",
		selfDestructAs = "",
	}
)
	:Is(
		"Builder",
		VFS.Include("unit_components/component_factories/harvests.lua")(20, 50),
		VFS.Include("unit_components/component_factories/morph.lua")({
			morph_to = "cloakraid",
			command_name = "Test Morph",
			desc = "test tooltip",
			money = 0,
			wood = 0,
		}),
		VFS.Include("unit_components/component_factories/buildable.lua")("demon/engineer_placeholder.dds", 10, 65)
	)
	:AddWeapon("Slice", { "LAND", "BUILDING" })
	:Wrap()
