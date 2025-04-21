--//=============================================================================
--//  SHORT INFO WHY WE DO THIS:
--// Cause of the reference based system in lua we can't
--// destroy objects yourself, instead we have to tell
--// the GarbageCollector somehow that an object isn't
--// in use anymore.
--//  Now we have a quite complex class system in Chili
--// with parent and children links between objects. Those
--// circles make it normally impossible for the GC to
--// detect if an object (and all its children) can be
--// destructed.
--//  This is the point where so called WeakLinks come
--// into play. Instead of saving direct references to the
--// objects in the parent field, we created a weaktable
--// (use google, if you aren't familiar with this name)
--// which directs to the parent-object. So now the link
--// between children and its parent is 'weak' (the GC can
--// catch the parent), and the link between the parent
--// and its children is 'hard', so the GC won't catch the
--// children as long as there is a parent object.
--//=============================================================================

local wmeta = { __mode = "v" }
local newproxy = newproxy or getfenv(0).newproxy

--- Creates a weak link to an object.
--- This allows the garbage collector to collect the object if there are no other strong references to it.
--- @param obj any The object to create a weak link to.
--- @param wlink userdata? Optional weak link to reuse.
--- @return userdata link The weak link.
function MakeWeakLink(obj, wlink)
	--// 2nd argument is optional, if it's given it will reuse the given link (-> less garbage)

	obj = UnlinkSafe(obj) --// unlink hard-/weak-links -> faster (else it would have to go through multiple metatables)

	if not isindexable(obj) then
		return obj
	end

	local mtab
	if type(wlink) == "userdata" then
		mtab = getmetatable(wlink)
	end
	if not mtab then
		wlink = newproxy(true)
		mtab = getmetatable(wlink)
		setmetatable(mtab, wmeta)
	end
	local getRealObject = function()
		return mtab._obj
	end --// note: we are using mtab._obj here, so it is a weaklink -> it can return nil!
	mtab._islink = true
	mtab._isweak = true
	mtab._obj = obj
	mtab.__index = obj
	mtab.__newindex = obj
	mtab.__call = getRealObject --// values are weak, so we need to make it gc-safe
	mtab[getRealObject] = true --// and buffer it in a key, too

	if not obj._wlinks then
		local t = {}
		setmetatable(t, { __mode = "v" })
		obj._wlinks = t
	end
	obj._wlinks[#obj._wlinks + 1] = wlink

	return wlink
end

--- Creates a hard link to an object.
--- This prevents the garbage collector from collecting the object until the hard link is garbage collected.
--- @param obj any The object to create a hard link to.
--- @param gc function? Optional garbage collection function.
--- @return userdata  hlinkThe hard link.
function MakeHardLink(obj, gc)
	obj = UnlinkSafe(obj) --// unlink hard-/weak-links -> faster (else it would have to go through multiple metatables)

	if not isindexable(obj) then
		return obj
	end

	local hlink = newproxy(true)
	local mtab = getmetatable(hlink)
	mtab._islink = true
	mtab._ishard = true
	mtab._obj = obj
	mtab.__gc = gc or function()
		if not obj._hlinks or not next(obj._hlinks) then
			obj:AutoDispose()
		end
	end
	mtab.__index = obj
	mtab.__newindex = obj
	mtab.__call = function()
		return mtab._obj
	end

	if not obj._hlinks then
		local t = {}
		setmetatable(t, { __mode = "v" })
		obj._hlinks = t
	end
	obj._hlinks[#obj._hlinks + 1] = hlink

	return hlink
end

--- Unlinks a safe link.
-- If the link is a userdata, it returns the underlying object. Otherwise, it returns the link itself.
-- @param link any The link to unlink.
-- @return any The unlinked object.
function UnlinkSafe(link)
	local link = link
	while type(link) == "userdata" do
		link = link()
	end
	return link
end

--- Compares two links for equality.
-- If the links are userdatas, it compares the underlying objects. Otherwise, it compares the links themselves.
-- @param link1 any The first link to compare.
-- @param link2 any The second link to compare.
-- @return boolean True if the links are equal, false otherwise.
function CompareLinks(link1, link2)
	return UnlinkSafe(link1) == UnlinkSafe(link2)
end

--- Checks if a link is a weak link and returns the underlying object if it is still valid.
-- @param link any The link to check.
-- @return any The underlying object if the link is a valid weak link, nil otherwise.
function CheckWeakLink(link)
	return (type(link) == "userdata") and link()
end

--//=============================================================================
