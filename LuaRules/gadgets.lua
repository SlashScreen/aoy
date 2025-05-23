-- (C) 2025 Slashscreen, 2007 Dave Rogers; Licensed under the terms of the GNU GPL, v3 or later.

local addon_handler = VFS.Include("utils/addon_handler.lua")
local callins = VFS.Include("LuaRules/callins.lua")

--- @class GadgetHandlerProxy: AddonHandlerProxy
--- @field RaiseGadget fun(handler: GadgetHandlerProxy) Raises the gadget.
--- @field LowerGadget fun(handler: GadgetHandlerProxy) Lowers the gadget.
--- @field RemoveGadget fun(handler: GadgetHandlerProxy) Removes the gadget.
--- @field IsSyncedCode fun(handler: GadgetHandlerProxy):boolean Returns whether the code is synced.
--- @field RegisterCMDID fun(handler: GadgetHandlerProxy, id: number) Registers a command ID for the gadget.
--- @field RegisterGlobal fun(handler: GadgetHandlerProxy, name: string, value: any):any Registers a global variable for the gadget.
--- @field DeregisterGlobal fun(handler: GadgetHandlerProxy, name: string):any Deregisters a global variable for the gadget.
--- @field SetGlobal fun(handler: GadgetHandlerProxy, name: string, value: any):any Sets a global variable for the gadget.
--- @field AddChatAction fun(handler: GadgetHandlerProxy, cmd: string, func: function, help: string):any Adds a chat action for the gadget.
--- @field RemoveChatAction fun(handler: GadgetHandlerProxy, cmd: string):any Removes a chat action for the gadget.
--- @field IsMouseOwner fun(handler: GadgetHandlerProxy):boolean Returns whether the gadget is the mouse owner.
--- @field DisownMouse fun(handler: GadgetHandlerProxy) Disowns the mouse if the gadget is the owner.
--- @field AddSyncAction fun(handler: GadgetHandlerProxy, cmd: string, func: function, help: string):any Adds a sync action for the gadget.
--- @field RemoveSyncAction fun(handler: GadgetHandlerProxy, cmd: string):any Removes a sync action for the gadget.

--- @class GadgetInfoPacket: AddonInfoPacket

--- @class Gadget: Addon

--- @param handler GadgetHandler
--- @param gadget Gadget
--- @return GadgetHandlerProxy
local function wrap_gadget_handler(handler, gadget)
	return {
		RaiseGadget = function(_)
			handler:RequestAddonRaise(gadget)
		end,
		LowerGadget = function(_)
			handler:RequestAddonLower(gadget)
		end,
		RemoveGadget = function(_)
			handler:RequestAddonRemoval(gadget)
		end,
		IsSyncedCode = function(_)
			return handler:IsSyncedCode()
		end,
		RegisterCMDID = function(_, id)
			handler:RegisterCMDID(gadget, id)
		end,
		RegisterGlobal = function(_, name, value)
			return handler:RegisterGlobal(gadget, name, value)
		end,
		DeregisterGlobal = function(_, name)
			return handler:DeregisterGlobal(gadget, name)
		end,
		SetGlobal = function(_, name, value)
			return handler:SetGlobal(gadget, name, value)
		end,
		AddChatAction = function(_, cmd, func, help)
			return actionHandler.AddChatAction(gadget, cmd, func, help)
		end,
		RemoveChatAction = function(_, cmd)
			return actionHandler.RemoveChatAction(gadget, cmd)
		end,
		IsMouseOwner = function(_)
			return (handler.mouse_owner == gadget)
		end,
		DisownMouse = function(_)
			if handler.mouse_owner == gadget then
				handler.mouse_owner = nil
			end
		end,
		--[[AddSyncAction = function(_, cmd, func, help)
			if handler:IsSyncedCode() then
				return nil
			end
			return actionHandler.AddSyncAction(gadget, cmd, func, help)
		end,
		RemoveSyncAction = function(_, cmd)
			if handler:IsSyncedCode() then
				return nil
			end
			return actionHandler.RemoveSyncAction(gadget, cmd)
		end,]]
	}
end

--- @class GadgetHandler: AddonHandler
local GadgetHandler = addon_handler.new(callins, {
	wrapper_func = wrap_gadget_handler,
	log_section = "Gadgets",
})
