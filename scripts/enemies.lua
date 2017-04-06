-- enemy generation class
local M = {}

local loc = {
	["x"] = 325,
	["y"] = 50
}

-- declarations (all are 'local')
local function constructor( world, parent, x, y )
	loc[x] = x or loc[x]
	loc[y] = y or loc[y]

	-- add a new entry in the enemy table
	local n = #parent + 1
	parent[n] = {}
	parent[n].body = lPh.newBody(world, x, y, "dynamic")
	parent[n].shape = lPh.newRectangleShape(0, 0, 40, 90)
	parent[n].fixture = lPh.newFixture(parent[n].body, parent[n].shape, 5)
	parent[n].fixture:setRestitution(1)
	parent[n].fixture:setUserData("enemy")
	parent[n].body:setLinearVelocity( math.random(-30,30), math.random(-30,30))
	parent[n].body:setAngularVelocity( math.random(10) )
end

local function destructor( world, parent )
	-- add a new entry in the enemy table
	for ix,val in pairs(parent) do
		parent[ix].fixture:destroy()
		parent[ix].body:destroy()
		parent[ix] = nil
	end
end

local function process( world, parent, new )
	local retval = 0
	if new >= 1 then
		retval = new - 1
		constructor( world, parent, loc.x, loc.y )
		-- loc.x = loc.x + 60
	end
	return retval
end

-- global namespace (like .h public declaration, to give global access)
M.constructor = constructor
M.destructor = destructor
M.process = process


return M