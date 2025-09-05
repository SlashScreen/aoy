-- included in globals
local inspect = VFS.Include("utils/inspect.lua")

--- @param tbl table
--- @return string
function Serialize(tbl)
	return inspect(tbl)
end

--- @param str string
--- @return table
function Deserialize(str)
	return loadstring("return" .. str)()
end
