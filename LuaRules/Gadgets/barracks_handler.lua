local gadget = NewGadget()

function gadget:GetInfo()
	return {
		name = "Barracks Handler",
		desc = "Handles units being built in buildings",
		author = "GoogleFrog",
		date = "19, April, 2025",
		license = "GPL v3",
		layer = 0,
		enabled = true,
	}
end

if not gadgetHandler:IsSyncedCode() then
	return gadget
end

local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local barrackUnits = IterableMap.New()

local FRAMES_PER_SECOND = 30 -- Look up whether this is a const that the engine supplies

local CMD_BUILD_UNIT_RANGE = Spring.Utilities.CMD.BUILD_UNIT_RANGE
local CMD_BUILD_UNIT_RANGE_UPPER = Spring.Utilities.CMD.BUILD_UNIT_RANGE_UPPER

local MAX_JOBS = 5

local function SetupConstruction(unitID, ud, bud)
	--- @type CommandDescription
	local buildCmd = {
		id = CMD_BUILD_UNIT_RANGE + bud.id,
		type = CMDTYPE.ICON,
		name = "Build " .. bud.humanName,
		action = "build_" .. bud.name,
		tooltip = "Build "
			.. bud.humanName
			.. " for "
			.. bud.metalCost
			.. " metal in "
			.. bud.customParams.build_time
			.. " seconds",
		texture = bud.buildPic or "",
	}
	Spring.InsertUnitCmdDesc(unitID, buildCmd)
end

local function SetupConstructionOptions(unitID, ud)
	local index = 1
	local option = ud.customParams["build_" .. index]
	local canBuild = {}

	while option do
		local bud = UnitDefNames[option]
		assert(bud ~= nil, "No unit named " .. option .. " in build menu for " .. ud.humanName)
		SetupConstruction(unitID, ud, bud)
		canBuild[bud.id] = true
		index = index + 1
		option = ud.customParams["build_" .. index]
	end

	local barracks = {
		queue = {},
		nextFinishFrame = false,
		canBuild = canBuild,
	}

	IterableMap.Add(barrackUnits, unitID, barracks)
end

function gadget:UnitCreated(unitID, unitDefID, ...)
	Spring.Echo("on unit created", unitID, unitDefID, ...)
	local ud = UnitDefs[unitDefID]
	if ud.customParams.build_1 then
		SetupConstructionOptions(unitID, ud)
	end
end

local function CreateUnitNear(ox, oy, oz, unitDefID, teamID)
	local range = 20
	local x, z = ox + range * (math.random() - 0.5), oz + range * (math.random() - 0.5)
	local tries = 0

	while not Spring.TestMoveOrder(unitDefID, x, 0, z) and tries < 100 do
		x, z = ox + range * (math.random() - 0.5), oz + range * (math.random() - 0.5)
		range = range + 5
		tries = tries + 1
	end

	local y = Spring.GetGroundHeight(x, z)
	Spring.CreateUnit(unitDefID, x, y, z, 0, teamID)
end

local function UpdateBarracksQueue(unitID, barracks, index, frame)
	frame = frame or Spring.GetGameFrame()

	if barracks.nextFinishFrame and frame >= barracks.nextFinishFrame then
		local buildUnitDefID = barracks.queue[1]
		local ux, uy, uz = Spring.GetUnitPosition(unitID)
		CreateUnitNear(ux, uy, uz, buildUnitDefID, Spring.GetUnitTeam(unitID))
		barracks.nextFinishFrame = false
		table.remove(barracks.queue, 1) -- Shifts down the queue, I hope
		for i = 1, MAX_JOBS do
			local value = barracks.queue[i] or 0
			Spring.SetUnitRulesParam(unitID, "build_queue_" .. i, value)
		end
		--Script.LuaUI.UpdateBuildQueueUI(unitID)
	end

	if barracks.queue[1] and not barracks.nextFinishFrame then
		local buildUnitDefID = barracks.queue[1]
		local bud = UnitDefs[buildUnitDefID]
		barracks.nextFinishFrame = frame + bud.customParams.build_time * FRAMES_PER_SECOND
	end

	if frame % 30 == 0 then
		local ux, uy, uz = Spring.GetUnitPosition(unitID)
		Spring.MarkerErasePosition(ux, uy, uz)
	end

	if frame % 30 == 1 then
		local ux, uy, uz = Spring.GetUnitPosition(unitID)
		local progress = "-"

		if barracks.nextFinishFrame then
			local buildUnitDefID = barracks.queue[1]
			local bud = UnitDefs[buildUnitDefID]
			local totalTime = bud.customParams.build_time * FRAMES_PER_SECOND
			progress = string.format("%d%%", 100 * (1 - (barracks.nextFinishFrame - frame) / totalTime))
		end
		Spring.MarkerAddPoint(ux, uy, uz, "Queue: " .. #barracks.queue .. " progress: " .. progress)
	end
end

local function HandleConstruction(unitID, unitDefID, teamID, cmdID, cmdOptions)
	local buildUnitDefID = cmdID - CMD_BUILD_UNIT_RANGE
	local barracks = IterableMap.Get(barrackUnits, unitID)
	if not barracks.canBuild[buildUnitDefID] then
		return
	end

	local bud = UnitDefs[buildUnitDefID]
	local cost = bud.metalCost
	if cmdOptions.right then
		for i = #barracks.queue, 1, -1 do
			if barracks.queue[i] == buildUnitDefID then -- remove most recent queued building
				table.remove(barracks.queue, i)
				Spring.AddTeamResource(teamID, "metal", cost)
				if i == 1 then
					barracks.nextFinishFrame = false
					UpdateBarracksQueue(unitID, barracks)
				end
				local ux, uy, uz = Spring.GetUnitPosition(unitID)
				Spring.MarkerAddPoint(ux, uy, uz, "  \nUnit Cancelled")
				break
			end
		end
	elseif Spring.UseTeamResource(teamID, "metal", cost) or Spring.IsNoCostEnabled() then
		barracks.queue[#barracks.queue + 1] = buildUnitDefID
		UpdateBarracksQueue(unitID, barracks)
		local ux, uy, uz = Spring.GetUnitPosition(unitID)
		Spring.MarkerAddPoint(ux, uy, uz, "  \nUnit Queued")
	else
		local ux, uy, uz = Spring.GetUnitPosition(unitID)
		Spring.MarkerAddPoint(ux, uy, uz, "  \nNot enough metal!! (type /atm)")
	end
end

function gadget:GameFrame(frame)
	IterableMap.Apply(barrackUnits, UpdateBarracksQueue, frame)
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if
		IterableMap.Get(barrackUnits, unitID)
		and cmdID >= CMD_BUILD_UNIT_RANGE
		and cmdID <= CMD_BUILD_UNIT_RANGE_UPPER
	then
		HandleConstruction(unitID, unitDefID, teamID, cmdID, cmdOptions)
		return false
	end
	return true
end

return gadget
