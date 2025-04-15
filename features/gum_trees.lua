local TREE_PATH = "trees/gum/"
local deep_clone = table.deep_clone or VFS.Include("utils/table_utils.lua").deep_clone
---@type string[]
local model_names = {
	"gum_tree_1",
}

local tree_prototype = {
	description = [[A tree common on Anvilhead.]],
	footprintX = 1,
	footprintZ = 1,

	reclaimable = true,
	blocking = true,
	energy = 100,

	customParams = {
		is_tree = true,
	},
}

---@type table<string, table>
local trees = {}
for i = 1, #model_names do
	local name = model_names[i]
	local path = TREE_PATH .. name .. ".s3o"
	local new_tree = deep_clone(tree_prototype)
	new_tree.object = path
	trees[name] = new_tree
end

return lowerkeys(trees)
