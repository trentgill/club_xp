player = {}
score = {}

local img_scale = 0.1
local gameSpeed = 1

function love.load()
	-- graphics setup
	love.graphics.setBackgroundColor(104, 136, 200)
	love.window.setMode(650, 650)

	-- physics environment
	lPh = love.physics
	lPh.setMeter(64)
	world = lPh.newWorld(0, 0, true)
	local w, h = love.graphics.getDimensions(); w, h = w/2, h/2

	objects = {}
	objects.bound = {}
	objects.bound.body = lPh.newBody(world, 650/2, 650/2)
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape(-w, h, w, h))
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape( w, h, w,-h))
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape( w,-h,-w,-h))
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape(-w,-h,-w, h))
	-- objects.bound.fixture:setUserData(objects.bound)

	objects.player = {}
	objects.player.body = lPh.newBody(world, 650/2, 650/2, "dynamic")
	objects.player.shape = lPh.newCircleShape(20)
	objects.player.fixture = lPh.newFixture(objects.player.body, objects.player.shape, 1)
	objects.player.fixture:setRestitution(0.9)
	objects.player.fixture:setUserData("you")

	
	objects.bouncer = {}
	local oB = objects.bouncer

	oB[1] = {}
	oB[1].body = lPh.newBody(world, 400, 200, "dynamic")
	oB[1].shape = lPh.newRectangleShape(0, 0, 50, 100)
	oB[1].fixture = lPh.newFixture(oB[1].body, oB[1].shape, 5)
	oB[1].fixture:setRestitution(1)
	oB[1].fixture:setUserData("enemy")
	-- player.img = love.graphics.newImage('perfect.png')

	oB[2] = {}
	oB[2].body = lPh.newBody(world, 200, 200, "dynamic")
	oB[2].shape = lPh.newRectangleShape(0, 0, 50, 100)
	oB[2].fixture = lPh.newFixture(oB[2].body, oB[2].shape, 5)
	oB[2].fixture:setRestitution(1)
	oB[2].fixture:setUserData("enemy")

	-- physics callbacks
	world:setCallbacks(beginContact)
	
	-- score board
	mainFont = love.graphics.newFont("lekton.ttf", 30)
	love.graphics.setFont(mainFont)
	score.x = 40
	score.y = 40
	score.count = 10
	score.angle = 0
end

-- enemy object class
enemy = {}
function enemy.generate( x, y )
	local oB = objects.bouncer
	
	-- add a new entry in the enemy table
	local n = (#oB) + 1
	oB[n] = {}
	oB[n].body = lPh.newBody(world, x, y, "dynamic")
	oB[n].shape = lPh.newRectangleShape(0, 0, 50, 100)
	oB[n].fixture = lPh.newFixture(oB[n].body, oB[n].shape, 5)
	oB[n].fixture:setRestitution(1)
	oB[n].fixture:setUserData("enemy")
end

local location = 0
function enemy.process()	
	if enemy.generateNew == 1 then
		enemy.generateNew = 0
		enemy.generate(location, 0)
		location = location + 60
	end
end

function score.update( plus )
	score.count = score.count + plus
	score.angle = score.angle + plus*5
	if score.angle > (2 * math.pi) then
		score.angle = score.angle - (2 * math.pi)
	end
	if score.count <= 0 then
		print("game over")
		gameSpeed = 0.15
		score.count = 0
	end
	enemy.generateNew = 1
end

function collidePlayerBounds(a, b, coll)
	print("you're dizzy")
end

function collidePlayerEnemy(a, b, coll)
	print("pe")
	score.update(-1)
end

function collideEnemyEnemy(a, b, coll)
	print("zork")
end

function collideEnemyBounds(a, b, coll)
	print("foo")
end

local collisions = {
	["you"] = {
		["bounds"] 	= function () collidePlayerBounds() end,
		["enemy"]	= function () collidePlayerEnemy() end
	},
	["enemy"] = {
		["bounds"]	= function () collideEnemyBounds() end,
		["enemy"]	= function () collideEnemyEnemy() end,
		["you"]		= nil
	},
	["bounds"] = {
		["you"] 	= nil,
		["enemy"]	= nil
	}
}

function beginContact(objA, objB, coll)
	-- UserData holds the 'class' of the colliding object
	local a, b = objA:getUserData(), objB:getUserData()
	-- sets 'nil' values to be "bounds" as they don't have fixtures
	a = a or "bounds"
	b = b or "bounds"

	local act = collisions[a][b]
	if act == nil then act = collisions[b][a] end

	-- pass data to appropriate function
	return act(objA, objB, coll)
end

-- user actions: function w/ optional table of arguments
local bindings = {
	escape 	= function () love.event.quit() end,

	a 		= function () objects.player.body:applyForce(-400,   0) end,
	d 		= function () objects.player.body:applyForce( 400,   0) end,
	s 		= function () objects.player.body:applyForce(   0, 400) end,
	w 		= function () objects.player.body:applyForce(   0,-400) end,
}

-- stores list of currently held keys
local heldKeys = {}

-- add/subtract keys from process-list
function love.keypressed( k )
	local action = bindings[k]
	heldKeys[k] = action
end

function love.keyreleased( k )
	heldKeys[k] = nil
end

function inputHandler()
	for i,fn in pairs(heldKeys) do
		return fn()
	end
end

function love.update( dt )
	-- input handler
	inputHandler()

	world:update(dt * gameSpeed)
	enemy.process()
end

function love.draw()
	local lg, op, ob = love.graphics, objects.player, objects.bouncer

	lg.print(score.count,score.x,score.y, score.angle,1,1,30,30)

	lg.setColor(193, 47, 14)
	lg.circle("fill", op.body:getX(), op.body:getY(), op.shape:getRadius())

	lg.setColor(50, 50, 50)
	for i,ix in pairs(ob) do
		lg.polygon("fill", ob[i].body:getWorldPoints(ob[i].shape:getPoints()))
	end
end





