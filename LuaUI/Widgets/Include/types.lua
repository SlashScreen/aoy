--- @meta

--- @alias CommandID integer

--- @class DatamodelHandle<T> : {__GetTable:fun():T}
--- @field __SetDirty fun(self, name: string)

--- @class RmlEvent
--- @field parameters RmlEventParameters

--- @alias RmlEventParameters {
--- button: 1 | 2 | 3,
--- mouse_x: integer,
--- mouse_y: integer,
--- scroll_lock_key: 0 | 1,
--- meta_key: 0 | 1,
--- ctrl_key: 0 | 1,
--- shift_key: 0 | 1,
--- caps_lock_key: 0 | 1,
--- alt_key: 0 | 1,
--- }

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

--- @class RmlContext
--- @field OpenDataModel fun(self: RmlContext, model: any): DatamodelHandle
--- @field LoadDocument fun(self: RmlContext, path: string, widget: Widget): RmlDocument
--- @field IsMouseInteracting fun(): boolean

--- @class RmlDocument

--- @class RmlUi
RmlUi = {}

--- Create a new context
--- @param name string
--- @return RmlContext
function RmlUi.CreateContext(name) end

--- Set which context the debug inspector is meant to inspect
--- @param name string
function RmlUi.SetDebugContext(name) end

--- Remove a context
--- @param name string
function RmlUi.RemoveContext(name) end
