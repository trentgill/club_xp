-- enemy generation class
local M = {}


-- declarations (all are 'local')
local function constructor( world, parent, x, y )
	-- add a new entry in the enemy table
	local n = #parent + 1
	parent[n] = {}
	parent[n].body = lPh.newBody(world, x, y, "dynamic")
	parent[n].shape = lPh.newRectangleShape(0, 0, 50, 100)
	parent[n].fixture = lPh.newFixture(parent[n].body, parent[n].shape, 5)
	parent[n].fixture:setRestitution(1)
	parent[n].fixture:setUserData("enemy")
end

local loc = {
	["x"] = 0,
	["y"] = 40
}
local function process( world, parent, new )
	local retval = 0
	if new >= 1 then
		retval = new - 1
		constructor( world, parent, loc.x, loc.y )
		loc.x = loc.x + 60
	end
	return retval
end

-- global namespace (like .h public declaration, to give global access)
M.constructor = constructor
M.process = process


return M