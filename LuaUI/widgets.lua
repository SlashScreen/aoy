-- (C) 2025 Slashscreen, 2007 Dave Rogers; Licensed under the terms of the GNU GPL, v3 or later.

local AddonHandler = VFS.Include("utils/addon_handler.lua")
local ActionHandler = VFS.Include("utils/action_handler.lua")
local callins = VFS.Include("LuaRules/callins.lua")

local action_handler = ActionHandler.new()

local WIDGETS_PATH = "LuaUI/Widgets"

--- @class WidgetHandlerProxy: AddonHandlerProxy
--- @field RaiseWidget fun(handler: WidgetHandlerProxy) Raises the widget.
--- @field LowerWidget fun(handler: WidgetHandlerProxy) Lowers the widget.
--- @field RemoveWidget fun(handler: WidgetHandlerProxy) Removes the widget.
--- @field GetCommands fun(handler: WidgetHandlerProxy):string[] Returns the commands available for the widget.
--- @field InTweakMode fun(handler: WidgetHandlerProxy):boolean Returns whether the widget is in tweak mode.
--- @field IsMouseOwner fun(handler: WidgetHandlerProxy):boolean Returns whether the widget is the mouse owner.
--- @field DisownMouse fun(handler: WidgetHandlerProxy) Disowns the mouse if the widget is the owner.
--- @field AddAction fun(handler: WidgetHandlerProxy, cmd: string, func: function, data: any, types: string[]):any Adds an action for the widget.
--- @field RemoveAction fun(handler: WidgetHandlerProxy, cmd: string, types: string[]):any Removes an action for the widget.
--- @field AddSyncAction fun(handler: WidgetHandlerProxy, cmd: string, func: function, help: string):any Adds a sync action for the widget.
--- @field RemoveSyncAction fun(handler: WidgetHandlerProxy, cmd: string):any Removes a sync action for the widget.
--- @field RegisterGlobal fun(handler: WidgetHandlerProxy, name: string, value: any):any Registers a global variable for the widget.
--- @field DeregisterGlobal fun(handler: WidgetHandlerProxy, name: string):any Deregisters a global variable for the widget.
--- @field SetGlobal fun(handler: WidgetHandlerProxy, name: string, value: any):any Sets a global variable for the widget.

--- @class WidgetInfoPacket: AddonInfoPacket

--- @class Widget: Addon
--- @field TweakGetTooltip fun(self: Widget, x: number, y: number):string Returns the tooltip for the widget in tweak mode.
--- @field TweakIsAbove fun(self: Widget, x: number, y: number):boolean Returns whether the widget is above the specified coordinates in tweak mode.
--- @field TweakMousePress fun(self: Widget, x: number, y: number, button: string):boolean Handles mouse press events in tweak mode.
--- @field TweakMouseMove fun(self: Widget, x: number, y: number, dx: number, dy: number, button: string):boolean Handles mouse move events in tweak mode.

--- @param handler WidgetHandler
--- @param widget Widget
--- @return WidgetHandlerProxy
local function wrap_widget_handler(handler, widget)
	local wh = {
		RaiseWidget = function(_)
			handler:RequestAddonRaise(widget)
		end,
		LowerWidget = function(_)
			handler:RequestAddonLower(widget)
		end,
		RemoveWidget = function(_)
			handler:RequestAddonRemoval(widget)
		end,
		GetCommands = function(_)
			return handler.commands
		end,
		InTweakMode = function(_)
			return handler.tweak_mode
		end,
		IsMouseOwner = function(_)
			return (handler.mouse_owner == widget)
		end,
		DisownMouse = function(_)
			if handler.mouse_owner == widget then
				handler.mouse_owner = nil
			end
		end,

		--[[UpdateCallIn = function(_, name)
			handler:UpdateWidgetCallIn(name, widget)
		end,
		RemoveCallIn = function(_, name)
			handler:RemoveWidgetCallIn(name, widget)
		end,]]

		AddAction = function(_, cmd, func, data, types)
			return action_handler:AddAction(widget, cmd, func, data, types)
		end,
		RemoveAction = function(_, cmd, types)
			return action_handler:RemoveAction(widget, cmd, types)
		end,

		AddSyncAction = function(_, cmd, func, help)
			return action_handler:AddSyncAction(widget, cmd, func, help)
		end,
		RemoveSyncAction = function(_, cmd)
			return action_handler:RemoveSyncAction(widget, cmd)
		end,

		--[[AddLayoutCommand = function(_, cmd)
			if handler.inCommandsChanged then
				table.insert(handler.customCommands, cmd)
			else
				Spring.Log(handler.log_section, LOG.ERROR, "AddLayoutCommand() can only be used in CommandsChanged()")
			end
		end,]]

		RegisterGlobal = function(_, name, value)
			return handler:RegisterGlobal(widget, name, value)
		end,
		DeregisterGlobal = function(_, name)
			return handler:DeregisterGlobal(widget, name)
		end,
		SetGlobal = function(_, name, value)
			return handler:SetGlobal(widget, name, value)
		end,

		--[[ConfigLayoutHandler = function(_, d)
			handler:ConfigLayoutHandler(d) -- TODO
		end,]]
	}

	if handler:IsSyncedCode() then
		widget["SendToUnsynced"] = Spring.SendToUnsynced --- @diagnostic disable-line
	end

	return wh
end

--- @class WidgetHandler: AddonHandler
--- @field old_selection integer[]
--- @field tweak_mode boolean
--- @field commands table
local WidgetHandler = AddonHandler.new(callins, {
	wrapper_func = wrap_widget_handler,
	log_section = "LuaUI",
	system = VFS.Include("LuaUI/system.lua"), -- TODO
	--- @param _ WidgetHandler
	--- @param widget Widget
	--- @return string?
	validation_func = function(_, widget)
		if widget.GetTooltip and not widget.IsAbove then
			return "Widget has GetTooltip() but not IsAbove()"
		end
		if widget.TweakGetTooltip and not widget.TweakIsAbove then
			return "Widget has TweakGetTooltip() but not TweakIsAbove()"
		end
		return nil
	end,
})
WidgetHandler.old_selection = {}
WidgetHandler.tweak_mode = false
WidgetHandler.command = {}

--- Returns the widget at x, y on the screen, if any.
--- @param x integer
--- @param y integer
--- @return Widget?
function WidgetHandler:WidgetAt(x, y)
	if not self.tweak_mode then
		for _, w in
			ipairs(self.addon_callin_map["IsAbove"] --[[@as Widget[]])
		do
			if w:IsAbove(x, y) then
				return w
			end
		end
	else
		for _, w in
			ipairs(self.addon_callin_map["TweakIsAbove"] --[[@as Widget[]])
		do
			if w:TweakIsAbove(x, y) then
				return w
			end
		end
	end
	return nil
end

Spring.SendCommands({
	"unbindkeyset  Any+f11",
	"unbindkeyset Ctrl+f11",
	"bind    f11  luaui selector",
	"bind  C+f11  luaui tweakgui",
	"echo LuaUI: bound F11 to the widget selector",
	"echo LuaUI: bound CTRL+F11 to tweak mode",
})

WidgetHandler:LoadFromDirectory(WIDGETS_PATH)
