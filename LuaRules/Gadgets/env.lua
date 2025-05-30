--- @meta

-- Dumb hack to prevent this script from being executed as a gadget.
-- This is needed because the gadget handler will try to load this file as a gadget and possibly screw up the tables.
if true then
	return false
end

-- The environment for gadgets.
-- Also includes system.lua.

--- @alias UnitID integer
--- @alias UnitDefID integer
--- @alias FeatureID integer
--- @alias FeatureDefID integer
--- @alias TeamID integer

handler = handler or {} --- @type GadgetHandlerProxy
raw_handler = raw_handler or {} --- @type GadgetHandler
include = VFS.Include
SG = SG or {} --- @type table
UnitDefs = UnitDefs or {} --- @type table<UnitDefID, table>
UnitDefNames = UnitDefNames or {} --- @type table<string, UnitDefID>
FeatureDefs = FeatureDefs or {} --- @type table<FeatureDefID, table>

unitShare = unitShare or false --- @type boolean
resShare = resShare or false --- @type boolean
unitShareEnemy = unitShareEnemy or false --- @type boolean
resShareEnemy = resShareEnemy or false --- @type boolean
