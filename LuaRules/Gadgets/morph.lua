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

--- @type table<integer, string[]>
local def_morph_list = {}
--- @type table<integer, CommandDescription>
local commands = {}
--- @type table<string, integer>
local morph_to_id = {}

--- @param md MorphDef
local function morph_def_to_command(md) end

if handler:IsSyncedCode() then
	local function begin_morph(unit_id, unit_def_id, team_id, to_unit)
		Spring.Echo("Morphing")
		return true
	end

	function gadget:AllowCommand(unit_id, unit_def_id, unit_team, cmd_id, _cmdParams, _cmdOptions, _cmdTag, _synced)
		-- TODO
		if commands[cmd_id] ~= nil then
		end
		return true
	end

	function gadget:Initialize()
		for i, _ in pairs(commands) do
			handler:RegisterCMDID(i)
			i = i + 1
		end
	end

	function gadget:UnitCreated(unit_id)
		local ml = def_morph_list[
			Spring.GetUnitDefID(unit_id) --[[@as integer]]
		]
		if ml then
			for _, morph in ipairs(ml) do
				Spring.InsertUnitCmdDesc(unit_id, commands[morph_to_id[morph]])
			end
		end
	end
else
	function gadget:Initialize()
		for i, _ in pairs(commands) do
			handler:RegisterCMDID(i)
			Spring.SetCustomCommandDrawData(i, CMD.MOVE)
			Spring.AssignMouseCursor("Sit Down", "cursorfight", true, true)
		end
	end
end
