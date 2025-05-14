--- @meta

--- @alias CommandID integer

--- @class RmlDatamodelHandle<T> : {__GetTable:fun():T}
--- @field __SetDirty fun(self, name: string)

---@class Addon
---@field Initialize fun(self: Addon)
---@field Shutdown fun(self: Addon)
---@field Update fun(self: Addon)
---@field Initialize fun(self: Addon) --Called when the addon is (re)loaded.
---@field Shutdown fun(self: Addon) --Called when the addon or the game is shutdown.
---@field DefaultCommand fun(self: Addon, type: string, id: integer): integer? --Used to set the default command when a unit is selected.
---@field CommandNotify fun(self: Addon, cmdID: integer, cmdParams: table, cmdOptions: table): boolean? --Called when a command is issued. Returning true deletes the command and does not send it through the network.
---@field CommandsChanged fun(self: Addon) --Called when the command descriptions changed, e.g. when selecting or deselecting a unit.
---@field WorldTooltip fun(self: Addon, ttType: string, data1: any, data2: any, data3: any): string? --The parameters can be "unit", unitID; "feature", featureID; "ground", posX, posY, posZ or "selection".
---@field UnsyncedHeightMapUpdate fun(self: Addon, ...) --Called when the unsynced copy of the height-map is altered.
---@field GameProgress fun(self: Addon, serverFrameNum: integer) --Called every 60 frames, calculating delta between GameFrame and GameProgress.
---@field GameSetup fun(self: Addon, state: any, ready: any, playerStates: any): boolean?, boolean? --???
---@field SunChanged fun(self: Addon, ...) --???
---@field AddConsoleLine fun(self: Addon, msg: string, priority: integer) --Called when text is entered into the console (e.g. Spring.Echo).
---@field RecvSkirmishAIMessage fun(self: Addon, aiTeam: integer, dataStr: string): any --???
---@field RecvFromSynced fun(self: Addon, ...) --Receives data sent via SendToUnsynced callout.
---@field Save fun(self: Addon, zip: any) --Called when a chat command '/save' or '/savegame' is received. The single argument is a userdatum representing the savegame zip file.
---@field LoadProgress fun(self: Addon, message: string, replaceLastLine: boolean) --Only available to LuaIntro.
---@field GroupChanged fun(self: Addon, groupID: integer) --Called when a unit is added to or removed from a control group. Currently implemented for widgets only.
---@field ConfigureLayout fun(self: Addon, ...): any --???
---@field IsAbove fun(self: Addon, x: number, y: number): boolean? --Called every Update. Must return true for Mouse* events and GetToolTip to be called.
---@field GetTooltip fun(self: Addon, x: number, y: number): string? --Called when IsAbove returns true.
---@field KeyPress fun(self: Addon, key: integer, mods: table, isRepeat: boolean): boolean? --Called repeatedly when a key is pressed down. Return true if you don't want other callins or the engine to also receive this keypress.
---@field KeyRelease fun(self: Addon, key: integer): boolean? --Called when the key is released.
---@field TextInput fun(self: Addon, utf8char: string) --Called whenever a key press results in text input.
---@field JoystickEvent fun(self: Addon, ...) --???
---@field MousePress fun(self: Addon, x: number, y: number, button: integer): boolean? --Called when a mouse button is pressed. Must return true for MouseRelease and other functions to be called.
---@field MouseRelease fun(self: Addon, x: number, y: number, button: integer): boolean? --Called when a mouse button is released. Only called if MousePress returns true.
---@field MouseWheel fun(self: Addon, up: boolean, value: number) --Called when the mouse wheel is moved. The parameters indicate the direction and amount of travel.
---@field MouseMove fun(self: Addon, x: number, y: number, dx: number, dy: number, button: integer) --Called when the mouse is moved. dx and dy are the distance travelled, x and y are the final position.
---@field PlayerChanged fun(self: Addon, playerID: integer) --Called whenever a player's status changes e.g. becoming a spectator.
---@field PlayerAdded fun(self: Addon, playerID: integer) --Called whenever a new player joins the game.
---@field PlayerRemoved fun(self: Addon, playerID: integer, reason: string) --Called whenever a player is removed from the game.
---@field DownloadStarted fun(self: Addon, id: string) --Called when a download is started via VFS.DownloadArchive.
---@field DownloadFinished fun(self: Addon, id: string) --Called when a download finishes successfully.
---@field DownloadFailed fun(self: Addon, id: string, errorID: integer) --Called when a download fails to complete.
---@field DownloadProgress fun(self: Addon, id: string, downloaded: number, total: number) --Called incrementally during a download.
---@field ViewResize fun(self: Addon, viewSizeX: integer, viewSizeY: integer) --Called whenever the window is resized.
---@field Update fun(self: Addon, dt: number) --Called for every draw frame (including when the game is paused) and at least once per sim frame except when catching up. The parameter is the time since the last update.
---@field DrawGenesis fun(self: Addon) --Doesn't render to screen! Use this callin to update textures, shaders, etc.
---@field DrawWorldPreParticles fun(self: Addon) --???
---@field DrawWorldPreUnit fun(self: Addon) --Spring draws units, features, some water types, cloaked units, and the sun.
---@field DrawWorld fun(self: Addon) --Spring draws command queues, 'map stuff', and map marks.
---@field DrawWorldShadow fun(self: Addon) --???
---@field DrawWorldReflection fun(self: Addon) --???
---@field DrawWorldRefraction fun(self: Addon) --???
---@field DrawGroundPreForward fun(self: Addon) --Runs at the start of the forward pass when a custom map shader has been assigned.
---@field DrawGroundPreDeferred fun(self: Addon) --Runs at the start of the deferred pass when a custom map shader has been assigned.
---@field DrawGroundPostDeferred fun(self: Addon) --Runs at the end of its respective deferred pass and allows proper frame compositing.
---@field DrawUnitsPostDeferred fun(self: Addon) --Runs at the end of the unit deferred pass to inform Lua code it should make use of the $model_gbuffer_* textures before another pass overwrites them.
---@field DrawFeaturesPostDeferred fun(self: Addon) --Runs at the end of the feature deferred pass to inform Lua code it should make use of the $model_gbuffer_* textures before another pass overwrites them.
---@field DrawScreen fun(self: Addon, vsx: integer, vsy: integer) --??? Also available to LuaMenu.
---@field DrawScreenEffects fun(self: Addon, vsx: integer, vsy: integer) --Where vsx, vsy are screen coordinates.
---@field DrawScreenPost fun(self: Addon, vsx: integer, vsy: integer) --Similar to DrawScreenEffects, this can be used to alter the contents of a frame after it has been completely rendered.
---@field DrawLoadScreen fun(self: Addon) --Only available to LuaIntro, draws custom load screens.
---@field DrawInMinimap fun(self: Addon, sx: number, sy: number) --Where sx, sy are values relative to the minimap's position and scale.
---@field DrawInMinimapBackground fun(self: Addon, sx: number, sy: number) --Where sx, sy are values relative to the minimap's position and scale.
---@field DrawUnit fun(self: Addon, unitID: integer, drawMode: integer): boolean? --For custom rendering of units.
---@field DrawFeature fun(self: Addon, unitID: integer, drawMode: integer): boolean? --For custom rendering of features.
---@field DrawShield fun(self: Addon, unitID: integer, weaponID: integer, drawMode: integer): boolean? --For custom rendering of shields.
---@field DrawProjectile fun(self: Addon, projectileID: integer, drawMode: integer): boolean? --For custom rendering of weapon (& other) projectiles.
---@field AllowDraw fun(self: Addon): boolean? --Enables Draw{Genesis,Screen,ScreenPost} callins if true is returned, otherwise they are called once every 30 seconds. Only active when a game isn't running.
---@field ActivateMenu fun(self: Addon) --Called whenever LuaMenu is on with no game loaded.
---@field ActivateGame fun(self: Addon) --Called whenever LuaMenu is on with a game loaded.
---@field GetInfo fun(self: Addon): table
---@field UnitCreated fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, builderID: integer) --Called at the moment the unit is created.
---@field UnitFinished fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer) --Called at the moment the unit is completed.
---@field UnitFromFactory fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, factID: integer, factDefID: integer, userOrders: boolean) --Called when a factory finishes construction of a unit.
---@field UnitReverseBuilt fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer) --Called when a living unit becomes a nanoframe again.
---@field UnitGiven fun(self: Addon, unitID: integer, unitDefID: integer, newTeam: integer, oldTeam: integer) --Called when a unit is transferred between teams. This is called after UnitTaken and in that moment unit is assigned to the newTeam.
---@field UnitTaken fun(self: Addon, unitID: integer, unitDefID: integer, oldTeam: integer, newTeam: integer) --Called when a unit is transferred between teams. This is called before UnitGiven and in that moment unit is still assigned to the oldTeam.
---@field UnitDamaged fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, damage: number, paralyzer: boolean, weaponDefID: integer, projectileID: integer, attackerID: integer, attackerDefID: integer, attackerTeam: integer) --Called when a unit is damaged (after UnitPreDamaged).
---@field UnitDestroyed fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, attackerID: integer, attackerDefID: integer, attackerTeam: integer) --Called when a unit is destroyed.
---@field RenderUnitDestroyed fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer) --Called just before a unit is invalid, after it finishes its death animation.
---@field UnitStunned fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, stunned: boolean) --Called when a unit changes its stun status.
---@field UnitUnitCollision fun(self: Addon, colliderID: integer, collideeID: integer) --Called when two units collide. Both units must be registered with Script.SetWatchUnit.
---@field UnitFeatureCollision fun(self: Addon, colliderID: integer, collideeID: integer) --Called when a unit collides with a feature. The unit must be registered with Script.SetWatchUnit and the feature registered with Script.SetWatchFeature.
---@field UnitHarvestStorageFull fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer) --Called when a unit's harvestStorage is full (according to its unitDef's entry).
---@field UnitCommand fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, cmdOpts: table, cmdTag: integer) --Called after when a unit accepts a command, after AllowCommand returns true.
---@field UnitCmdDone fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, cmdOpts: table, cmdTag: integer) --Called when a unit completes a command.
---@field UnitLoaded fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, transportID: integer, transportTeam: integer) --Called when a unit is loaded by a transport.
---@field UnitUnloaded fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, transportID: integer, transportTeam: integer) --Called when a unit is unloaded by a transport.
---@field UnitExperience fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, experience: number, oldExperience: number) --Called when a unit gains experience greater or equal to the minimum limit set by calling Spring.SetExperienceGrade.
---@field UnitIdle fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer) --Called when a unit is idle (empty command queue).
---@field UnitCloaked fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer) --Called when a unit cloaks.
---@field UnitDecloaked fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer) --Called when a unit decloaks.
---@field UnitMoved fun(self: Addon, ...) --??? Not implemented in base handler
---@field UnitMoveFailed fun(self: Addon, ...) --??? Not implemented in base handler
---@field StockpileChanged fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, weaponNum: integer, oldCount: integer, newCount: integer) --Called when a units stockpile of weapons increases or decreases.
---@field UnitEnteredLos fun(self: Addon, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer) --Called when a unit enters LOS of an allyteam.
---@field UnitLeftLos fun(self: Addon, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer) --Called when a unit leaves LOS of an allyteam.
---@field UnitEnteredRadar fun(self: Addon, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer) --Called when a unit enters radar of an allyteam.
---@field UnitLeftRadar fun(self: Addon, unitID: integer, unitTeam: integer, allyTeam: integer, unitDefID: integer) --Called when a unit leaves radar of an allyteam.
---@field UnitEnteredAir fun(self: Addon, ...) --??? Not implemented by base handler
---@field UnitLeftAir fun(self: Addon, ...) --??? Not implemented by base handler
---@field UnitEnteredWater fun(self: Addon, ...) --??? Not implemented by base handler
---@field UnitLeftWater fun(self: Addon, ...) --??? Not implemented by base handler
---@field UnitSeismicPing fun(self: Addon, x: number, y: number, z: number, strength: number, allyTeam: integer, unitID: integer, unitDefID: integer) --Called when a unit emits a seismic ping.
---@field CommandFallback fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, cmdOptions: table, cmdTag: integer): boolean?, boolean? --Called when the unit reaches an unknown command in its queue (i.e. one not handled by the engine).
---@field AllowCommand fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, cmdID: integer, cmdParams: table, cmdOptions: table, cmdTag: integer, synced: boolean): boolean? --Called when the command is given, before the unit's queue is altered. The return value is whether it should be let into the queue.
---@field AllowUnitCreation fun(self: Addon, unitDefID: integer, builderID: integer, builderTeam: integer, x: number, y: number, z: number, facing: integer): boolean? --Called just before unit is created, the boolean return value determines whether or not the creation is permitted.
---@field AllowUnitTransfer fun(self: Addon, unitID: integer, unitDefID: integer, oldTeam: integer, newTeam: integer, capture: boolean): boolean? --Called just before a unit is transferred to a different team, the boolean return value determines whether or not the transfer is permitted.
---@field AllowUnitBuildStep fun(self: Addon, builderID: integer, builderTeam: integer, unitID: integer, unitDefID: integer, part: number): boolean? --Called just before a unit progresses its build percentage, the boolean return value determines whether or not the build makes progress.
---@field AllowFeatureCreation fun(self: Addon, featureDefID: integer, teamID: integer, x: number, y: number, z: number): boolean? --Called just before feature is created, the boolean return value determines whether or not the creation is permitted.
---@field AllowFeatureBuildStep fun(self: Addon, builderID: integer, builderTeam: integer, featureID: integer, featureDefID: integer, part: number): boolean? --Called just before a feature changes its build percentage, the boolean return value determines whether or not the change is permitted.
---@field AllowResourceLevel fun(self: Addon, teamID: integer, res: string, level: number): boolean? --Called when a team sets the sharing level of a resource, the boolean return value determines whether or not the sharing level is permitted.
---@field AllowResourceTransfer fun(self: Addon, oldTeamID: integer, newTeamID: integer, res: string, amount: number): boolean? --Called just before resources are transferred between players, the boolean return value determines whether or not the transfer is permitted.
---@field AllowStartPosition fun(self: Addon, playerID: integer, teamID: integer, readyState: integer, clampedX: number, clampedY: number, clampedZ: number, rawX: number, rawY: number, rawZ: number): boolean? --Called when a player sets their start position, the boolean return value determines whether or not the position is permitted.
---@field AllowDirectUnitControl fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, playerID: integer): boolean? --Determines if this unit can be controlled directly in FPS view.
---@field AllowWeaponTargetCheck fun(self: Addon, attackerID: integer, attackerWeaponNum: integer, attackerWeaponDefID: integer): boolean?, boolean? --Determines if this weapon can automatically generate targets itself.
---@field AllowWeaponTarget fun(self: Addon, attackerID: integer, targetID: integer, attackerWeaponNum: integer, attackerWeaponDefID: integer, defPriority: number): boolean?, number? --Controls blocking of a specific target from being considered during a weapon's periodic auto-targeting sweep.
---@field AllowWeaponInterceptTarget fun(self: Addon, interceptorUnitID: integer, interceptorWeaponID: integer, targetProjectileID: integer): boolean? --Controls blocking of a specific intercept target from being considered during an interceptor weapon's periodic auto-targeting sweep.
---@field AllowBuilderHoldFire fun(self: Addon, unitID: integer, unitDefID: integer, action: integer): boolean? --Called when a construction unit wants to "use his nano beams".
---@field Explosion fun(self: Addon, weaponDefID: integer, px: number, py: number, pz: number, AttackerID: integer, ProjectileID: integer): boolean? --Called when an explosion occurs. If it returns true then no graphical effects are drawn by the engine for this explosion.
---@field TerraformComplete fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, buildUnitID: integer, buildUnitDefID: integer, buildUnitTeam: integer): boolean? --Called when pre-building terrain levelling terraforms are completed. If the return value is true the current build order is terminated.
---@field MoveCtrlNotify fun(self: Addon, unitID: integer, unitDefID: integer, unitTeam: integer, data: any): boolean? --Enable both Spring.MoveCtrl.SetCollideStop and Spring.MoveCtrl.SetTrackGround to enable this call-in. The return value determines whether or not the unit should remain script-controlled (false) or return to engine controlled movement (true).
---@field RecvLuaMsg fun(self: Addon, msg: string, playerID: integer) --Receives messages from unsynced sent via Spring.SendLuaRulesMsg or Spring.SendLuaUIMsg.
---@field Load fun(self: Addon, zip: any) --Called after GamePreload and before GameStart.

--- @class Widget : Addon
--- @field [any] any

--- @class Gadget : Addon

-- *rml types

--- @class RmlUi
RmlUi = {}

--- Create a new context
--- @param name string
--- @return RmlContext?
function RmlUi.CreateContext(name) end

--- Set which context the debug inspector is meant to inspect
--- @param context string | RmlContext
function RmlUi.SetDebugContext(context) end

--- Remove a context
--- @param name string
function RmlUi.RemoveContext(name) end

--- Load a font face into the Rml system.
---@param path string
---@return boolean success
function RmlUi.LoadFontFace(path) end

--- @param tag string
function RmlUi.RegisterTag(tag) end

--- Get a context by name.
--- @param name string
--- @return RmlContext?
function RmlUi.GetContext(name) end

--- Set a translation for a particular key.
---@param key string
---@param translation string
function RmlUi.AddTranslationString(key, translation) end

function RmlUi.ClearTranslation() end

--- it converts the css names for cursors to the Recoil Engine names for cursorsm like `RmlUi.SetMouseCursorAlias("pointer", 'Move')`
--- @param rml_name string name used in rml script
--- @param recoil_name string name used in recoil
function RmlUi.SetMouseCursorAlias(rml_name, recoil_name) end

--- @class Colourb
--- Constructs a colour with four channels, each from 0 to 255.
--- @field alpha integer
--- @field blue integer
--- @field green integer
--- @field red integer
--- @field rgba [integer, integer, integer, integer]
--- @field new fun():Colourb
--- @operator add:Colourb
--- @operator mul:Colourb

--- @class Colourf
---
--- @see rgba
--- @field alpha number
--- @field blue number
--- @field green number
--- @field red number
--- @field rgba [number, number, number, number]
--- @field new fun():Colourf

--- @class RmlContext
--- The Context class has no constructor; it must be instantiated through the CreateContext() function. It has the following functions and properties:
--- @field dimensions Vector2i
--- @field documents RmlContextDocumentsProxy
--- @field focus_element RmlElement
--- @field hover_element RmlElement
--- @field name string
--- @field root_element RmlElement
--- @field AddEventListener fun(self: RmlContext, event: string, script: RmlElement, element_context: boolean, in_capture_phase: boolean) Adds the inline Lua script, script, as an event listener to the context. element_context is an optional Element; if it is not None, then the script will be executed as if it was bound to that element.
--- @field CreateDocument fun(self: RmlContext, tag: string):RmlDocument Creates a new document with the tag name of tag.
--- @field LoadDocument fun(self: RmlContext, document_path: string):RmlDocument Attempts to load a document from the RML file found at document_path. If successful, the document will be returned with a reference count of one.
--- @field Render fun(self: RmlContext):boolean Renders the context.
--- @field UnloadAllDocuments fun(self: RmlContext) Closes all documents currently loaded with the context.
--- @field UnloadDocument fun(self: RmlContext, document: RmlDocument) Unloads a specific document within the context.
--- @field Update fun(self: RmlContext):boolean Updates the context.
--- @field OpenDataModel fun(self: RmlContext, name: string, model: table, widget: table): RmlDatamodelHandle Loads a data model. The handle's generic type matches that of `model`, but LuaCATS solver can't do that yet. Note that `widget` does not actually have to be a widget; it can be any table. This table can be accessed in widgets like `<button class="mode-button" onclick="widget:SetCamMode()">Set Dolly Mode</button>`. Note that your data model is inaccessible in `onx` properties.

--- @alias RmlContextDocumentsProxy { [string | integer]: RmlDocument }
--- Table of documents with the ability to be iterated over or indexed by an integer or a string.

--- @enum RmlDocumentFocus
RmlDocumentFocus = {
	None = 0,
	Document = 1,
	Keep = 2,
	Auto = 3,
}

--- @enum RmlDocumentModal
RmlDocumentModal = {
	None = 0,
	Modal = 1,
	Keep = 2,
}

--- @class RmlDocument:RmlElement
--- Document derives from Element. Document has no constructor; it must be instantiated through a Context object instead, either by loading an external RML file or creating an empty document. It has the following functions and properties:
--- @field context RmlContext
--- @field title string
--- @field Close fun(self: RmlDocument) Hides and closes the document, destroying its contents.
--- @field CreateElement fun(self: RmlDocument, tag_name: string):RmlElementPtr Instances an element with a tag of tag_name.
--- @field CreateTextNode fun(self: RmlDocument, text: string):RmlElementPtr Instances a text element containing the string text.
--- @field Hide fun(self: RmlDocument) Hides the document.
--- @field PullToFront fun(self: RmlDocument) Pulls the document in front of other documents within its context with a similar z-index.
--- @field PushToBack fun(self: RmlDocument) Pushes the document behind other documents within its context with a similar z-index.
--- @field Show fun(self: RmlDocument, modal: RmlDocumentModal?, focus: RmlDocumentFocus?) Shows the document. flags is either NONE, FOCUS or MODAL. flags defaults to FOCUS.

--- @class RmlElement
--- The Element class has no constructor; it must be instantiated through a Document object instead. It has the following functions and properties:
--- @field attributes RmlElementAttributesProxy
--- @field child_nodes RmlElementChildNodesProxy
--- @field class_name string
--- @field client_height number
--- @field client_left number
--- @field client_top number
--- @field client_width number
--- @field first_child RmlElement?
--- @field id string
--- @field inner_rml string
--- @field last_child RmlElement?
--- @field next_sibling RmlElement?
--- @field offset_height number
--- @field offset_left number
--- @field offset_parent RmlElement
--- @field offset_top number
--- @field offset_width number
--- @field owner_document RmlDocument
--- @field parent_node RmlElement?
--- @field previous_sibling RmlElement?
--- @field scroll_height number
--- @field scroll_left number
--- @field scroll_top number
--- @field scroll_width number
--- @field style RmlElementStyleProxy
--- @field tag_name string
--- @field AddEventListener fun(self: RmlElement, event: boolean, listener: function|string, in_capture_phase: boolean) NOTE: Events added from python cannot be removed.
--- @field AppendChild fun(self: RmlElement, element: RmlElementPtr) Appends element as a child to this element.
--- @field Blur fun(self: RmlElement) Removes input focus from this element.
--- @field Click fun(self: RmlElement) Fakes a click on this element.
--- @field DispatchEvent fun(self: RmlElement, event: string, parameters: table, interruptible: string) Dispatches an event to this element. The event is of type event. Parameters to the event are given in the dictionary parameters; the dictionary must only contain string keys and floating-point, integer or string values. interruptible determines if the event can be forced to stop propagation early.
--- @field Focus fun(self: RmlElement) Gives input focus to this element.
--- @field GetAttribute fun(self: RmlElement, name: string):any Returns the value of the attribute named name. If no such attribute exists, the empty string will be returned.
--- @field GetElementById fun(self: RmlElement, id: string):RmlElement Returns the descendant element with an id of id.
--- @field GetElementsByTagName fun(self: RmlElement, tag_name: string):RmlElementPtr[] Returns a list of all descendant elements with the tag of tag_name.
--- @field HasAttribute fun(self: RmlElement, name: string):boolean Returns True if the element has a value for the attribute named name, False if not.
--- @field HasChildNodes fun(self: RmlElement):boolean Returns True if the element has at least one child node, false if not.
--- @field InsertBefore fun(self: RmlElement, element: RmlElementPtr, adjacent_element: RmlElement) Inserts the element element as a child of this element, directly before adjacent_element in the list of children.
--- @field IsClassSet fun(self: RmlElement, name: string):boolean Returns true if the class name is set on the element, false if not.
--- @field RemoveAttribute fun(self: RmlElement, name: string) Removes the attribute named name from the element.
--- @field RemoveChild fun(self: RmlElement, element: RmlElement):boolean Removes the child element element from this element.
--- @field ReplaceChild fun(self: RmlElement, inserted_element: RmlElementPtr, replaced_element: RmlElement):boolean Replaces the child element replaced_element with inserted_element in this element's list of children. If replaced_element is not a child of this element, inserted_element will be appended onto the list instead.
--- @field ScrollIntoView fun(self: RmlElement, align_with_top: boolean) Scrolls this element into view if its ancestors have hidden overflow. If align_with_top is True, the element's top edge will be aligned with the top (or as close as possible to the top) of its ancestors' viewing windows. If False, its bottom edge will be aligned to the bottom.
--- @field SetAttribute fun(self: RmlElement, name: string, value: string) Sets the value of the attribute named name to value.
--- @field SetClass fun(self: RmlElement, name: string, value: boolean) Sets (if value is true) or clears (if value is false) the class name on the element.

--- @alias RmlElementAttributesProxy {[string]: string|number|boolean}
--- Contains all the attributes of an element: The stuff in the opening tag i.e. `<span class="my-class">`

--- @alias RmlElementChildNodesProxy RmlElement[]
--- Contains a list of all child elements.

--- @class RmlElementDataGrid:RmlElement
--- ElementDataGrid derives from Element. The data grid has the following functions and properties:
--- @field rows RmlElementDataGridRow
--- @field AddColumn fun(self: RmlElementDataGrid, fields: string, formatter: string, initial_width: number, header_rml: string) Adds a new column to the data grid. The column will read the columns fields (in CSV format) from the grid's data source, processing it through the data formatter named formatter. header_rml specifies the RML content of the column's header.
--- @field SetDataSource fun(self: RmlElementDataGrid, data_source_name: string) Sets the name and table of the new data source to be used by the data grid.

--- @class RmlElementDataGridRow:RmlElement
--- ElementDataGridRow derives from Element. The data grid row has the following properties:
--- @field parent_grid RmlElementDataGrid
--- @field parent_relative_index integer
--- @field parent_row RmlElementDataGridRow
--- @field row_expanded boolean
--- @field table_relative_index integer

--- @class RmlElementForm:RmlElement
--- ElementForm derives from Element. The form element has the following function:
--- @field Submit fun(self: RmlElementForm, submit_value: string?, submit_value: string?) Submits the form with a submit value of submit_value.

--- @class RmlElementFormControlInput:RmlElementFormControl
--- ElementFormControlInput derives from IElementFormControl. The control has the following properties, only appropriate on the relevant types:
--- @field checked boolean
--- @field max integer
--- @field maxlength integer
--- @field min integer
--- @field size integer
--- @field step integer
--- @field GetSelection fun(self: RmlElementFormControlInput): integer, integer, string
--- @field Select fun(self: RmlElementFormControlInput)
--- @field SetSelection fun(self: RmlElementFormControlInput, selection_start: integer, selection_end: integer)

--- @class RmlElementFormControl
--- @field disabled boolean
--- @field name string
--- @field value string

--- @alias RmlSelectOptionsProxy {element: RmlElement, value: string}[]
--- This one has no documentation.

--- @class RmlElementFormControlSelect:RmlElementFormControl
--- ElementFormControlSelect derives from ElementFormControl. The control has the following functions and properties:
--- @field options RmlSelectOptionsProxy
--- @field selection integer
--- @field Add fun(self: RmlElementFormControlSelect, rml: string, value: string, before: integer?):integer Adds a new option to the select box. The new option has the string value of value and is represented by the elements created by the RML string rml. The new option will be inserted by the index specified by before; if this is out of bounds (the default), then the new option will be appended onto the list. The index of the new option will be returned.
--- @field Remove fun(self: RmlElementFormControlSelect, index: integer) Removes an existing option from the selection box.
--- @field RemoveAll fun(self: RmlElementFormControlSelect)

--- @class RmlElementFormControlTextArea:RmlElementFormControl
--- ElementFormControlTextArea derives from ElementFormControl. The control has the following properties:
--- @field cols integer
--- @field maxlength integer
--- @field rows integer
--- @field wordwrap boolean
--- @field Add fun(self: RmlElementFormControlTextArea, rml: string, value: string, before: integer?):integer Adds a new option to the select box. The new option has the string value of value and is represented by the elements created by the RML string rml. The new option will be inserted by the index specified by before; if this is out of bounds (the default), then the new option will be appended onto the list. The index of the new option will be returned.
--- @field Remove fun(self: RmlElementFormControlTextArea, index: integer) Removes an existing option from the selection box.
--- @field RemoveAll fun(self: RmlElementFormControlTextArea)

--- @class RmlElementInstancer
---
--- @field new fun():RmlElementInstancer
--- @field InstanceElement fun(self: RmlElementInstancer):any

--- @class RmlElementPtr
--- Represents an owned element. This type is mainly used to modify the DOM tree by passing the object into other elements. For example `RmlElement.AppendChild()`.
--- A current limitation in the Lua plugin is that Element member properties and functions cannot be used directly on this type.

--- @alias RmlElementStyleProxy { [string]: string }
--- Gets the rcss styles associated with an element. As far as I can tell, the values will always be a string.

--- @class RmlElementTabSet:RmlElement
--- ElementTabSet derives from Element. The control has the following functions and properties:
--- @field active_tab integer
--- @field num_tabs integer
--- @field SetPanel fun(self: RmlElementTabSet, index: integer, rml: string) Sets the contents of a panel to the RML content rml. If index is out-of-bounds, a new panel will be added at the end.
--- @field SetTab fun(self: RmlElementTabSet, index: integer, rml: string) Sets the contents of a tab to the RML content rml. If index is out-of-bounds, a new tab will be added at the end.

--- @class RmlElementText:RmlElement
---
--- @field text string

--- @class RmlEvent
--- The Event class has no constructor; it is generated internally. It has the following functions and properties:
--- @field current_element RmlElement
--- @field parameters RmlEventParametersProxy
--- @field target_element RmlElement
--- @field type string
--- @field StopPropagation fun(self: RmlEvent) Stops the propagation of the event through the event cycle, if allowed.

--- @alias RmlEventParametersProxy.MouseButton
--- | 0 # Left
--- | 1 # Right
--- | 2 # Middle

--- @alias RmlEventParametersProxy.TrueFalse
--- | 0 # False
--- | 1 # True

--- @alias RmlEventParametersProxy {
--- button: RmlEventParametersProxy.MouseButton,
--- mouse_x: integer,
--- mouse_y: integer,
--- scroll_lock_key: RmlEventParametersProxy.TrueFalse,
--- meta_key: RmlEventParametersProxy.TrueFalse,
--- ctrl_key: RmlEventParametersProxy.TrueFalse,
--- shift_key: RmlEventParametersProxy.TrueFalse,
--- caps_lock_key: RmlEventParametersProxy.TrueFalse,
--- alt_key: RmlEventParametersProxy.TrueFalse,
--- }

--- @class RmlGlobalLuaFunctions
--- Implemented in the RmlUi class.
--- @see RmlUi

--- @deprecated Use Recoil functions instead
--- @class RmlLog
---
--- @field logtype RmlLogType
--- @field LogMessage fun(self: RmlLog, type: RmlLogType, str: string)

--- @deprecated Use Recoil functions instead
--- @enum RmlLogType
--- Enum table for specifying the type of log.
RmlLogType = {
	always = 0,
	error = 1,
	warning = 2,
	info = 3,
	debug = 4,
}

--- @class RmlLuaDataSource
---
--- @field new fun():RmlLuaDataSource

--- @alias RmlUiContextsProxy {[string|integer]: RmlContext? }
--- A list of contexts.

--- @class Vector2f
--- @field magnitude number
--- @field x number
--- @field y number
--- @field DotProduct fun(self: Vector2f, other: Vector2f):number
--- @field Normalise fun(self: Vector2f):Vector2f
--- @field Rotate fun(self: Vector2f, angle: number):Vector2f
--- @field new fun():Vector2f
--- @operator add:Vector2f
--- @operator div:Vector2f
--- @operator mul:Vector2f
--- @operator sub:Vector2f

--- @class Vector2i
--- Constructs a two-dimensional integral vector.
--- @field magnitude number
--- @field x integer
--- @field y integer
--- @field new fun():Vector2i
--- @operator add:Vector2i
--- @operator div:Vector2i
--- @operator mul:Vector2i
--- @operator sub:Vector2i
