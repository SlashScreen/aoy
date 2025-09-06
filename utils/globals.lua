if not Spring.Utilities then
	Spring.Utilities = {}
end

Spring.Utilities.CMD = {
	PICK_UP_ITEM = 45000, --- When a hero picks up an item
	BUILDING_STAND_UP = 45100, --- When a building goes from stationary to mobile
	BUILDING_SIT_DOWN = 45101, --- When a building goes from mobile to stationary
	POSSESS_UNIT = 45110, --- When a unit is set to be posessed
	MORPH = 45100, --- When a morph command is issued. 100 block
	BUILD_UNIT_RANGE = 60000,
	BUILD_UNIT_RANGE_UPPER = 70000,
}

Spring.Utilities.SIM_TPS = 30 -- if there's an API thing in the future we will use it then

--local cbor = VFS.Include("utils/cbor.lua")
local serde = VFS.Include("utils/binser.lua")

Spring.Echo("Loading serde")

--- @param tbl table
--- @return string
function Script.Serialize(tbl)
	--return cbor.encode(tbl)
	return serde.serialize(tbl)
end

--- @param str string
--- @return table
function Script.Deserialize(str)
	--return cbor.decode(str) --loadstring("return" .. str)() or {}
	local res, _ = serde.deserialize(str)
	return res[1] or {}
end
