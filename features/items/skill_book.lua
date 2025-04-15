local skbook = VFS.Include("features/items/item.lua")
skbook.object = "book.s3o"
skbook.description = "A skill book"

return lowerkeys({
	skill_book = skbook,
})
