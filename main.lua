player = {}
score = {}

local img_scale = 0.1

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
	objects.player.fixture:setUserData(objects.player)

	objects.bouncer = {}
	objects.bouncer.body = love.physics.newBody(world, 400, 200, "dynamic")
	objects.bouncer.shape = love.physics.newRectangleShape(0, 0, 50, 100)
	objects.bouncer.fixture = love.physics.newFixture(objects.bouncer.body, objects.bouncer.shape, 5)
	objects.bouncer.fixture:setRestitution(1)
	objects.bouncer.fixture:setUserData(objects.bouncer)
	-- player.img = love.graphics.newImage('perfect.png')

	-- physics callbacks
	world:setCallbacks(beginContact)
	
	-- score board
	mainFont = love.graphics.newFont("lekton.ttf", 30)
	love.graphics.setFont(mainFont)
	score.x = 40
	score.y = 40
	score.count = 0
	score.rotation = 0
end

function beginContact(objA, objB, coll)
	-- print(objA)
	if objA:getUserData() == objects.player or objB:getUserData() == objects.player then
		print("you're dead")
	end
end

function score.update( plus )
	score.count = score.count + plus
	score.rotation = score.rotation + plus*5
	if score.rotation > (2 * math.pi) then
		score.rotation = score.rotation - (2 * math.pi)
	end
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

	world:update(dt)
end

function love.draw()
	-- love.graphics.draw(player.img, player.x, player.y, player.rotation, img_scale, img_scale, 0, 32)
	love.graphics.print(score.count,score.x,score.y, score.rotation,1,1,30,30)

	love.graphics.setColor(193, 47, 14) --set the drawing color to red for the player
	love.graphics.circle("fill", objects.player.body:getX(), objects.player.body:getY(), objects.player.shape:getRadius())

	love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the bouncers
	love.graphics.polygon("fill", objects.bouncer.body:getWorldPoints(objects.bouncer.shape:getPoints()))
end





