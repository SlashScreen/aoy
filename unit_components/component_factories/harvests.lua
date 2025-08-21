return function(wood_cap, gold_cap)
	return {
		name = "Harvests",
		component = {
			customdefs = {
				can_chop = true,
				wood_cap = wood_cap or 20,
				gold_cap = gold_cap or 50,
			},
		},
	}
end
