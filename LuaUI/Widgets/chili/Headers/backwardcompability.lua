--// =============================================================================
--//

local function CheckNoneNil(x, fallback)
	if (x ~= nil) then
		return x
	else
		return fallback
	end
end
