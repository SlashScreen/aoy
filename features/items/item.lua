return lowerkeys({
	item = {
		description = [[A pick uppable item]],
		--object = "book.s3o",
		object = "chickenegg.s3o", -- for testing
		blocking = false,
		damage = 10000,
		reclaimable = true,
		energy = 0,
		footprintx = 1,
		footprintz = 1,

		customParams = {
			is_item = true,
		},
	},
})
