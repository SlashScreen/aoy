local gadget = handler:NewGadget()

function gadget:GetInfo()
	return {
		name = "Unit morphing",
		desc = "Handles unit morphing",
		author = "Slashscreen",
		date = "Present Day, Present Time",
		license = "LGPL-3.0-or-later",
		layer = 0,
		enabled = true,
	}
end

local CMD_MORPH = Spring.Utilities.CMD.MORPH

-- probably isn't the ideal way to do this but I am very tired

--- @type table<integer, string[]>
local def_morph_list = {}
--- @type table<integer, CommandDescription>
local commands = {}
--- @type table<string, integer>
local morph_to_id = {}
--- @type table<integer, {
--- cost_money: integer,
--- cost_wood: integer,
--- research?: string,
--- target: string}>
local morph_metadata = {}

Spring.Echo("Loading morphs")

-- LOAD DEFS

-- loop through units, if there are morph defs, add them to the list of the unit def,
-- and add them to the command registry if need be

for unit_def_id, unit_def in pairs(UnitDefs) do
	local morphs = unit_def.customParams.morphs --[[@as string? ]]

	if morphs then
		Spring.Echo(unit_def.name .. " has morphs")

		local morph_table = Deserialize(morphs)
		local mlist = {}

		for _, mdef in ipairs(morph_table) do
			table.insert(mlist, mdef.morph_to)
			-- if we don't have this already
			if morph_to_id[mdef.morph_to] == nil then
				-- register new command ID
				local new_id = CMD_MORPH + #morph_to_id
				morph_to_id[mdef.morph_to] = new_id
				-- create command description
				commands[new_id] = {
					id = new_id,
					type = CMDTYPE.ICON,
					name = mdef.command_name,
					action = "morph_" .. mdef.morph_to,
					tooltip = mdef.desc,
				}

				morph_metadata[new_id] = {
					cost_money = mdef.money,
					cost_wood = mdef.wood,
					research = mdef.research,
					target = mdef.morph_to,
				}
			end
		end
		def_morph_list[unit_def_id] = mlist
	end
end

if handler:IsSyncedCode() then
	--- @param unit_id integer
	--- @param unit_def_id integer
	--- @param team_id integer
	--- @param to_unit string
	local function begin_morph(unit_id, unit_def_id, team_id, to_unit)
		Spring.Echo("Morphing")

		local x, y, z = Spring.GetUnitPosition(unit_id)
		if x == nil then
			return false
		end

		Spring.DestroyUnit(unit_id)
		-- TODO: Wait and construct
		Spring.CreateUnit(to_unit, x, y, z, "e", team_id)
		return true
	end

	function gadget:AllowCommand(unit_id, unit_def_id, unit_team, cmd_id, _cmdParams, _cmdOptions, _cmdTag, _synced)
		-- TODO
		-- Add Cost
		-- Add research
		if commands[cmd_id] ~= nil then
			return begin_morph(unit_id, unit_def_id, unit_team, morph_metadata[cmd_id].target)
		end
		return true
	end

	function gadget:Initialize()
		-- Register IDs
		for i, _ in pairs(commands) do
			handler:RegisterCMDID(i)
		end
	end

	function gadget:UnitCreated(unit_id)
		local ml = def_morph_list[
			Spring.GetUnitDefID(unit_id) --[[@as integer]]
		]
		-- For each morph in the list for this unit def, add the command
		if ml then
			for _, morph in ipairs(ml) do
				Spring.InsertUnitCmdDesc(unit_id, commands[morph_to_id[morph]])
			end
		end
	end
else
	function gadget:Initialize()
		-- Add UI stuff for each morph command
		for i, _ in pairs(commands) do
			handler:RegisterCMDID(i)
			Spring.SetCustomCommandDrawData(i, CMD.MOVE)
			Spring.AssignMouseCursor("Sit Down", "cursorfight", true, true)
		end
	end
end

return gadget
