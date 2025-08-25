return {
	name = "Building",
	component = {
		canMove = false,
		canattack = false,
	},
	mutators = {
		function(self)
			if self.category:sub(-1) == " " then
				self.category = self.category .. "BUILDING"
			else
				self.category = self.category .. " BUILDING"
			end
		end,
	},
}
