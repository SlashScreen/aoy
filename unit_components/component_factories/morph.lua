--- @class MorphDef
--- @field morph_to string
--- @field command_name string
--- @field desc string
--- @field money integer
--- @field wood integer
--- @field research string?

local cbor = VFS.Include("utils/cbor.lua")

--- @param ... MorphDef
--- @return UnitComponent
return function(...)
	-- This is a stupid way to do this
	-- I am just directly serializing the table LOL
	local morph_string = cbor.encode({ ... })

	return {
		name = "Morph",
		component = {
			customParams = {
				morphs = morph_string,
			},
		},
	}
end
