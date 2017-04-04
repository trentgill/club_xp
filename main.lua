player = {}
score = {}

local img_scale = 0.1
local gameSpeed = 1

function love.load()
	-- graphics setup
	love.graphics.setBackgroundColor(104, 136, 200)
	love.window.setMode(650, 650)

	-- physics environment
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)
	local w, h = love.graphics.getDimensions(); w, h = w/2, h/2

	objects = {}
	objects.bound = {}
	objects.bound.body = love.physics.newBody(world, 650/2, 650/2)
	love.physics.newFixture(objects.bound.body, love.physics.newEdgeShape(-w, h, w, h))
	love.physics.newFixture(objects.bound.body, love.physics.newEdgeShape( w, h, w,-h))
	love.physics.newFixture(objects.bound.body, love.physics.newEdgeShape( w,-h,-w,-h))
	love.physics.newFixture(objects.bound.body, love.physics.newEdgeShape(-w,-h,-w, h))
	-- objects.bound.fixture:setUserData(objects.bound)

	objects.player = {}
	objects.player.body = love.physics.newBody(world, 650/2, 650/2, "dynamic")
	objects.player.shape = love.physics.newCircleShape(20)
	objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape, 1)
	objects.player.fixture:setRestitution(0.9)
	objects.player.fixture:setUserData("you")

	objects.bouncer = {}
	objects.bouncer.body = love.physics.newBody(world, 400, 200, "dynamic")
	objects.bouncer.shape = love.physics.newRectangleShape(0, 0, 50, 100)
	objects.bouncer.fixture = love.physics.newFixture(objects.bouncer.body, objects.bouncer.shape, 5)
	objects.bouncer.fixture:setRestitution(1)
	objects.bouncer.fixture:setUserData("enemy")
	-- player.img = love.graphics.newImage('perfect.png')

	objects.bouncer2 = {}
	objects.bouncer2.body = love.physics.newBody(world, 200, 200, "dynamic")
	objects.bouncer2.shape = love.physics.newRectangleShape(0, 0, 50, 100)
	objects.bouncer2.fixture = love.physics.newFixture(objects.bouncer2.body, objects.bouncer2.shape, 5)
	objects.bouncer2.fixture:setRestitution(1)
	objects.bouncer2.fixture:setUserData("enemy")

	-- physics callbacks
	world:setCallbacks(beginContact)
	
	-- score board
	mainFont = love.graphics.newFont("lekton.ttf", 30)
	love.graphics.setFont(mainFont)
	score.x = 40
	score.y = 40
	score.count = 10
	score.rotation = 0
end

function score.update( plus )
	score.count = score.count + plus
	score.rotation = score.rotation + plus*5
	if score.rotation > (2 * math.pi) then
		score.rotation = score.rotation - (2 * math.pi)
	end
	if score.count <= 0 then
		print("game over")
		gameSpeed = 0.15
		score.count = 0
	end
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
end

function love.draw()
	-- love.graphics.draw(player.img, player.x, player.y, player.rotation, img_scale, img_scale, 0, 32)
	love.graphics.print(score.count,score.x,score.y, score.rotation,1,1,30,30)

	love.graphics.setColor(193, 47, 14) --set the drawing color to red for the player
	love.graphics.circle("fill", objects.player.body:getX(), objects.player.body:getY(), objects.player.shape:getRadius())

	love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the bouncers
	love.graphics.polygon("fill", objects.bouncer.body:getWorldPoints(objects.bouncer.shape:getPoints()))
	love.graphics.setColor(70, 30, 80) -- set the drawing color to grey for the bouncers
	love.graphics.polygon("fill", objects.bouncer2.body:getWorldPoints(objects.bouncer2.shape:getPoints()))
end





