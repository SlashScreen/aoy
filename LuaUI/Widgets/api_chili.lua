function widget:GetInfo()
    return {
        name    = "Chili",
        desc    = "chili ui",
        author  = "Vileblood",
        license = "GNU GPL, v2 or later",
        layer   = 1,
        enabled = true,   --false,
        handler = true,
    }
end

function widget:Initialize()
    WG.Chili = VFS.Include(LUAUI_DIRNAME.."Widgets/chili/core.lua")
end
