--- @type UnitComponent
return {
	name = "Hero",
	component = {
		customparams = {
			is_hero = true,
		},
	},
	mutators = {
		function(self)
			if self.category:sub(-1) == " " then
				self.category = self.category .. "HERO"
			else
				self.category = self.category .. " HERO"
			end
		end,
	},
}
