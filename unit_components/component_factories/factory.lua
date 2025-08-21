return function(...)
	local custom_params = {
		is_factory = true,
	}
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		custom_params["build_" .. i] = name
	end

	return {
		name = "Factory",
		component = {
			customParams = custom_params,
		},
	}
end
