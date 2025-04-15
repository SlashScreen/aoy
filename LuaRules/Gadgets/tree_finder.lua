local INITIAL_FIND_RADIUS = 500
local SEARCH_RADIUS_INCREMENT = 300

--[[
We make the following assumptions: 
1. The unit is probably already pretty close to a tree
2. The closest tree is most likely able to be pathfound to

And the algorithm goes like this:
1. Get all trees in some cylinder of radius x around the unit
2. Filter ones that can currently be seen in the fog of war
3. Sort by distance
4. Starting from the closest distance, find one that a) is not claimed and b) can be pathfound to successfully
5. If a tree is found, break
6. If no tree is found, repeat from step 1 but increase the radius x by some amount until a tree is found or the map bounds are exceeded

With our assumptions, the vast majority of queries can be satisfied in the first loop with the closest tree and so not many calculations will need be done
]]

function gadget:GetInfo()
	return {
		name = "Tree Finder",
		desc = "Finds trees for units",
		author = "Vileblood",
		date = "Present Day, Present Time",
		license = "MIT",
		layer = 0,
		enabled = true,
	}
end

--- @type table<FeatureDefID, boolean>
local is_tree = {}
--- @type table<FeatureID, boolean>
local claimed_trees = {} -- TODO: Make sure this is cleared when a tree is removed or unit leaves

for feature_id, feature in pairs(FeatureDefs) do
	if feature.customParams.is_tree then
		is_tree[feature_id] = true
	end
end

---Is this feature visible in the fog of war
---@param id FeatureID
---@return boolean
local function is_feature_visible(id)
	--- @type number, number, number
	local x, y, z = Spring.GetFeaturePosition(id) --[[@as number, number, number]]
	return Spring.IsPosInLos(x, y, z) or Spring.IsPosInRadar(x, y, z)
end

---is this a tree we can use for search
---@param id FeatureID
---@return boolean
local function is_valid_tree(id)
	return (is_tree[Spring.GetFeatureDefID(id)] and not claimed_trees[id] and is_feature_visible(id)) -- TODO: Potential race condition with 2 units claiming a tree at the same time
end

---Find the closest tree to the position
---@param radius number
---@param x number
---@param y number
---@param z number
---@return FeatureID|nil id The ID of the tree found, or nil if no tree was found
local function search_for_nearest_tree(radius, x, y, z)
	local possible_trees = Spring.GetFeaturesInCylinder(x, z, radius)
	-- filter out any feature that is not a possible tree
	local valid_trees = {}
	local possible_trees_length = #possible_trees
	for i in possible_trees_length do
		local id = possible_trees[i]
		if is_valid_tree(id) then
			table.insert(valid_trees, id)
		end
	end

	-- sort the trees by distance to the unit
	table.sort(valid_trees, function(a, b)
		local ax, ay, az = Spring.GetFeaturePosition(a) --[[@as number, number, number]]
		local bx, by, bz = Spring.GetFeaturePosition(b) --[[@as number, number, number]]
		local dist_a = (ax - x) ^ 2 + (ay - y) ^ 2 + (az - z) ^ 2
		local dist_b = (bx - x) ^ 2 + (by - y) ^ 2 + (bz - z) ^ 2
		return dist_a < dist_b
	end)

	local valid_trees_length = #valid_trees
	for i = 1, valid_trees_length do
		local id = valid_trees[i]
		-- TODO
	end
end

---Find a tree for a unit
---@param unit_id UnitID The ID of the unit to find a tree for
---@return FeatureID | nil id The ID of the tree found, or nil if no tree was found
local function find_tree_for_unit(unit_id)
	local max_dimension = math.max(Game.mapSizeX, Game.mapSizeZ) / 2
	local x, y, z = Spring.GetUnitPosition(unit_id) --[[@as number, number, number]]
	local radius = INITIAL_FIND_RADIUS
	local tree_id = nil

	while not tree_id do
		tree_id = search_for_nearest_tree(radius, x, y, z)
		if tree_id then
			break
		end
		radius = radius + SEARCH_RADIUS_INCREMENT
		if radius > max_dimension then
			break
		end
	end

	return tree_id
end
