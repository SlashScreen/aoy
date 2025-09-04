--- @class MorphDef
--- @field morph_to string
--- @field desc string
--- @field money integer
--- @field wood integer
--- @field research string?

--- @param ... MorphDef
--- @return table
return function(...)
	-- just in case I need more processing

	--[[ local morphs = {}

	for i = 1, select("#", ...) do
		local name = select(i, ...)
		table.insert(morphs, name)
	end ]]

	return {
		name = "Morph",
		component = {
			morphs = { ... },
		},
	}
end
