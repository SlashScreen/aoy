return function(icon, time, cost)
	return {
		name = "Buildable",
		component = {
			buildTime = time,
			metalCost = cost,
			buildPic = icon,
			customParams = {
				build_time = time,
			},
		},
	}
end
