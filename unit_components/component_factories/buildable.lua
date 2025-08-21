return function(icon, time, cost)
	return {
		name = "Buildable",
		buildTime = time,
		component = {
			metalCost = cost,
			buildPic = icon,
			customParams = {
				build_time = time,
			},
		},
	}
end
