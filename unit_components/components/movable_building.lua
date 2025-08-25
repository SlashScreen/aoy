return {
	name = "MovableBuilding",
	component = {
		canMove = true,
		canattack = false,

		customParams = {
			movable_building = true,
		},
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
