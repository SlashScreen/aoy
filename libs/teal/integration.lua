-- (C) 2025 Slashscreen, MIT license
-- Allows Recoil to load Teal files from VFS.

local tl = VFS.Include("libs/teal/tl.lua")
local vanilla_include = VFS.Include

TEAL_ENABLED = true

VFS.Include = function(path, environment, mode) --- @diagnostic disable-line
	if path:find(".tl") then
		local text = VFS.LoadFile(path)
		if not text then
			Spring.Log("VFS", LOG.ERROR, "Failed to load Teal file: " .. path)
			return nil
		end
		local ok, result = tl.load(text)
		if not ok then
			Spring.Log("VFS", LOG.ERROR, "Teal compilation error in " .. path .. ": " .. result)
			return nil
		end
		return ok
	end
	return vanilla_include(path, environment, mode)
end
