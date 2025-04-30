function script.Activate()
	SetUnitValue(COB.INBUILDSTANCE, 1)
end

function script.Deactivate()
	Signal(SIG_BUILD)
	SetUnitValue(COB.INBUILDSTANCE, 0)
end

function script.Create() end

function script.QueryBuildInfo()
	return 0 -- TODO
end

function script.Killed(recentDamage, maxHealth) end
