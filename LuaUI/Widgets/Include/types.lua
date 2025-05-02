--- @meta

--- @alias CommandID integer

--- @class DatamodelHandle<T> : {__GetTable:fun():T}
--- @field __SetDirty fun(self, name: string)

--- @class UnitOrder
--- @field type integer
--- @field action string
--- @field id integer
--- @field tooltip string
--- @field cursor string
--- @field showUnique boolean
--- @field params table
--- @field name string
--- @field onlyTexture boolean
--- @field disabled boolean
--- @field hidden boolean
--- @field queueing boolean
--- @field texture string

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
