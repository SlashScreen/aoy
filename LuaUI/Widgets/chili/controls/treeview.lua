--//=============================================================================
--- TreeView module
--- A control that displays hierarchical data in a collapsible tree structure.
--- This control allows users to view and interact with tree-structured data,
--- with features like node expansion/collapse, selection, and custom node handling.
---
--- @class TreeView
--- @field nodes table[] Array of root level tree nodes
--- @field selectedNode Node Currently selected tree node
--- @field clickableNodes boolean Whether nodes can be clicked (default: true)
--- @field expandOnClick boolean Whether clicking a node expands/collapses it (default: true)
--- @field indentation number Pixels to indent each level of nodes (default: 16)
--- @field selectedColor table Color for selected node {r,g,b,a} (default: {0.5,0.5,1,0.3})
--- @field OnSelectNode function[] Callbacks when a node is selected
--- @field OnExpandNode function[] Callbacks when a node is expanded
--- @field OnCollapseNode function[] Callbacks when a node is collapsed

TreeView = Control:Inherit({
	classname = "treeview",
	nodes = {},
	selectedNode = nil,

	clickableNodes = true,
	expandOnClick = true,
	indentation = 16,

	selectedColor = { 0.5, 0.5, 1, 0.3 },

	OnSelectNode = {},
	OnExpandNode = {},
	OnCollapseNode = {},
})

local this = TreeView
local inherited = this.inherited

--- Creates a new TreeView instance with the given properties
--- @param obj table Configuration table for the new TreeView
--- @return TreeView The newly created TreeView instance
function TreeView:New(obj)
	obj = inherited.New(self, obj)

	-- Initialize nodes
	if obj.nodes then
		for i = 1, #obj.nodes do
			self:AddNode(obj.nodes[i])
		end
	end

	return obj
end

--- Creates a new tree node with the specified data
--- @param data table Node configuration data
--- @param data.caption string Text to display for the node
--- @param data.expanded boolean Whether node starts expanded
--- @param data.children table[] Optional child nodes
--- @return table The created node object
function TreeView:CreateNode(data)
	local node = {
		caption = data.caption or "",
		expanded = data.expanded or false,
		children = {},
		parent = nil,
		level = 0,
		data = data,
	}

	-- Add child nodes if any
	if data.children then
		for i = 1, #data.children do
			local child = self:CreateNode(data.children[i])
			child.parent = node
			child.level = node.level + 1
			table.insert(node.children, child)
		end
	end

	return node
end

--- Adds a new node to the tree
--- @param data table Node configuration data
--- @return table The newly added node
function TreeView:AddNode(data)
	local node = self:CreateNode(data)
	table.insert(self.nodes, node)
	self:Invalidate()
	return node
end

--- Removes a node from the tree
--- @param node table The node to remove
function TreeView:RemoveNode(node)
	-- Remove from parent's children
	if node.parent then
		local siblings = node.parent.children
		for i = 1, #siblings do
			if siblings[i] == node then
				table.remove(siblings, i)
				break
			end
		end
	-- Remove from root nodes
	else
		for i = 1, #self.nodes do
			if self.nodes[i] == node then
				table.remove(self.nodes, i)
				break
			end
		end
	end

	self:Invalidate()
end

--- Expands a collapsed node to show its children
--- @param node table The node to expand
function TreeView:ExpandNode(node)
	if not node.expanded then
		node.expanded = true
		self:CallListeners(self.OnExpandNode, node)
		self:Invalidate()
	end
end

--- Collapses an expanded node to hide its children
--- @param node table The node to collapse
function TreeView:CollapseNode(node)
	if node.expanded then
		node.expanded = false
		self:CallListeners(self.OnCollapseNode, node)
		self:Invalidate()
	end
end

--- Selects a node in the tree
--- @param node table The node to select
function TreeView:SelectNode(node)
	if self.selectedNode ~= node then
		self.selectedNode = node
		self:CallListeners(self.OnSelectNode, node)
		self:Invalidate()
	end
end

--- Draws a single node in the tree
--- @param node table The node to draw
--- @param x number X coordinate to start drawing
--- @param y number Y coordinate to start drawing
--- @return number Height of the drawn node including children if expanded
function TreeView:DrawNode(node, x, y)
	local height = 20 -- Node height

	-- Draw selection
	if node == self.selectedNode then
		gl.Color(self.selectedColor)
		gl.Rect(0, y, self.width, y + height)
	end

	-- Draw expand/collapse icon
	if #node.children > 0 then
		-- TODO: Draw +/- icon
	end

	-- Draw caption
	local indent = node.level * self.indentation
	self.font:Print(node.caption, x + indent, y + 2, 14)

	-- Draw children if expanded
	if node.expanded then
		y = y + height
		for i = 1, #node.children do
			local childHeight = self:DrawNode(node.children[i], x, y)
			y = y + childHeight
		end
	end

	return height
end

--- Draws the entire tree control
function TreeView:DrawControl()
	local y = 0
	for i = 1, #self.nodes do
		local height = self:DrawNode(self.nodes[i], 0, y)
		y = y + height
	end
end

--- Finds and returns the node at the given coordinates
--- @param x number X coordinate
--- @param y number Y coordinate
--- @return table|nil The node at the position or nil if none found
function TreeView:GetNodeAt(x, y)
	local function findNode(nodes, level, yPos)
		for i = 1, #nodes do
			local node = nodes[i]
			local height = 20 -- Node height

			-- Check if coordinates are within node
			if y >= yPos and y < yPos + height then
				local indent = level * self.indentation
				if x >= indent then
					return node
				end
			end

			-- Check children if expanded
			if node.expanded then
				yPos = yPos + height
				local found = findNode(node.children, level + 1, yPos)
				if found then
					return found
				end
				yPos = yPos + height * #node.children
			else
				yPos = yPos + height
			end
		end
	end

	return findNode(self.nodes, 0, 0)
end

--- Handles mouse click events on the tree
--- @param x number X coordinate of click
--- @param y number Y coordinate of click
--- @param ... any Additional parameters
--- @return boolean True if the click was handled
function TreeView:MouseDown(x, y, ...)
	if not self.clickableNodes then
		return false
	end

	local node = self:GetNodeAt(x, y)
	if node then
		if self.expandOnClick then
			if node.expanded then
				self:CollapseNode(node)
			else
				self:ExpandNode(node)
			end
		end

		self:SelectNode(node)
		return true
	end

	return false
end

--//=============================================================================

--- Helper function to parse initialization data into the tree structure
--- @param node table Parent node to add children to
--- @param nodes table[] Array of node data to parse
local function ParseInitTable(node, nodes)
	local lastnode = node
	for i = 1, #nodes do
		local data = nodes[i]
		if type(data) == "table" then
			ParseInitTable(lastnode, data)
		else
			lastnode = node:Add(data)
		end
	end
end

--- Creates a new TreeView with initialization data
--- @param obj table Configuration data including initial nodes
--- @return TreeView The new TreeView instance
function TreeView:New(obj)
	local nodes = obj.nodes
	if nodes then
		obj.children = {}
	end

	obj = inherited.New(self, obj)

	obj.root =
		TreeViewNode:New({ treeview = obj, root = true, minHeight = obj.minItemHeight, expanded = obj.defaultExpanded })
	if nodes then
		ParseInitTable(obj.root, nodes)
	end
	obj:AddChild(obj.root)

	obj:UpdateLayout()

	local sel = obj.selected
	obj.selected = false
	if (sel or 0) > 0 then
		obj:Select(sel)
	end

	return obj
end

--- Finds a node by its caption text
--- @param caption string The caption text to search for
--- @return table|nil The matching node or nil if not found
function TreeView:GetNodeByCaption(caption)
	return self.root:GetNodeByCaption(caption)
end

--- Gets a node by its numeric index in the tree
--- @param index number The index to look up
--- @return table|nil The node at the index or nil if not found
function TreeView:GetNodeByIndex(index)
	local result = self.root:GetNodeByIndex(index, 0)
	return (not IsNumber(result)) and result
end

--- Selects a node either by reference or index
--- @param item table|number Node object or index to select
function TreeView:Select(item)
	local obj = UnlinkSafe(item)

	if type(item) == "number" then
		obj = self:GetNodeByIndex(item)
	end

	if obj and obj:InheritsFrom("treeviewnode") then
		local oldSelected = self.selected
		self.selected = MakeWeakLink(obj)
		self.selected:Invalidate()
		if oldSelected then
			oldSelected:Invalidate()
		end

		obj:CallListeners(obj.OnSelectChange, true)
		if oldSelected then
			oldSelected:CallListeners(oldSelected.OnSelectChange, false)
		end
		self:CallListeners(self.OnSelectNode, self.selected, oldSelected)
	end
end

--- Updates the layout of the tree control
--- @return boolean Always returns true
function TreeView:UpdateLayout()
	local c = self.root
	c:_UpdateConstraints(0, 0, self.clientWidth)
	c:Realign()

	if self.autosize then
		self:Resize(nil, c.height, true, true)
	end

	return true
end

--//=============================================================================
