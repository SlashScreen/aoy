local hips = piece("hips")

function script.Create()
	Spring.Echo("basic unit script")
end

function script.StartMoving() end

function script.StopMoving() end

function script.QueryWeapon()
	return hips
end

function script.AimFromWeapon()
	return hips
end

function script.AimWeapon(_, heading, pitch)
	return true
end

function script.Killed(recentDamage, maxHealth)
	return 1
end
