--- @type UnitDef
local default = {
	category = [[LAND SMALL TOOFAST]],
	footprintX = 2,
	footprintZ = 2,

	acceleration = 1.5,
	brakeRate = 2.4,
	sightDistance = 560,
	speed = 115.5,
	turnRate = 3000,

	canAttack = true,
	canMove = true,

	health = 230,
	metalCost = 65,
	movementClass = [[KBOT2]],
	noAutoFire = false,
	objectName = [[spherebot.s3o]],
}
local inspect = VFS.Include("utils/inspect.lua")

--- @param t1 table
--- @param t2 table
local function merge_tables(t1, t2)
	for key, value in pairs(t2) do
		if type(value) == "table" then
			if type(t1[key]) == "table" then
				merge_tables(t1[key], value)
			else
				t1[key] = value
			end
		else
			t1[key] = value
		end
	end
end

--- @class UnitComponent
--- @field name string
--- @field component table
--- @field mutators fun(self: UnitDef)[]?

-- Load Unit Components

local components = {} --- @type {[string]: UnitComponent}

for _, filename in ipairs(VFS.DirList("unit_components/components", "*.lua", nil, true)) do
	local success, tbl = pcall(VFS.Include, filename, _G) --[[@as UnitComponent]]
	if not success then
		Spring.Log("unit.lua", LOG.ERROR, "Bad return table from: " .. filename)
	end

	if type(tbl) ~= "table" then
		Spring.Log("unit.lua", LOG.ERROR, "Bad return table from: " .. filename)
	end

	components[tbl.name] = tbl
end

-- * UNIT

--- @class ComposedUnit : UnitDef
--- @field unit_id string
local Unit = {}

--- @param name string
--- @param desc string
--- @param config UnitDef?
--- @return ComposedUnit
function Unit.New(name, desc, id, config)
	local output = (config or {}) --[[@as ComposedUnit]]
	merge_tables(output, default)

	output.name = name
	output.description = desc
	output.unit_id = id

	setmetatable(output, { __index = Unit })

	return output
end

--- Add a component to a unit
--- @param ... string | UnitComponent
--- @return ComposedUnit
function Unit:Is(...)
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		--Spring.Echo("Loading component: \n" .. inspect(name))

		if type(name) == "string" then
			local c = components[name]
			if c then
				merge_tables(self, c.component)
				for _, m in ipairs(c.mutators or {}) do
					m(self)
				end
			end
		else
			local c = name --[[@as UnitComponent]]
			merge_tables(self, c.component)
			for _, m in ipairs(c.mutators or {}) do
				m(self)
			end
		end
	end

	--Spring.Echo("Generated unit: " .. inspect(self))

	return self
end

--- Add a weapon
--- @param name string
--- @param target_categories string[]
function Unit:AddWeapon(name, target_categories)
	local weapon = {
		name = name,
		onlyTargetCategory = table.concat(target_categories, " "),
	}

	self.weapons = self.weapons or {} -- give it weapons if not already given

	table.insert(self.weapons, weapon)

	return self
end

function Unit:Wrap()
	local t = {}
	t[self.unit_id] = self
	return t
end

return Unit
