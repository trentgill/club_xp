local enemies = require("scripts.enemies")

score = {}

local img_scale = 0.1
local gameSpeed = 1

local gameDims = {
	["x"] = 650,
	["y"] = 650
}

function love.load()
	-- graphics setup
	love.graphics.setBackgroundColor(104, 136, 200)
	love.window.setMode(gameDims.x, gameDims.y)

	-- physics environment
	lPh = love.physics
	lPh.setMeter(64)
	world = lPh.newWorld(0, 0, true)
	local w, h = gameDims.x/2, gameDims.y/2

	objects = {}

	objects.bound = {}
	objects.bound.body = lPh.newBody(world, w, h)
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape(-w, h, w, h))
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape( w, h, w,-h))
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape( w,-h,-w,-h))
	lPh.newFixture(objects.bound.body, lPh.newEdgeShape(-w,-h,-w, h))

	objects.goal = {}
	objects.goal.loc = {}
	local ogl = objects.goal.loc --alias
	ogl.x1 = w -50
	ogl.y1 =   10
	ogl.x2 = w +50
	ogl.y2 =   10
	objects.goal.body = lPh.newBody(world, 0, 0)
	objects.goal.shape = lPh.newEdgeShape( ogl.x1, ogl.y1, ogl.x2, ogl.y2 ) --1 px below edge
	objects.goal.fixture = lPh.newFixture(objects.goal.body, objects.goal.shape, 1)
	objects.goal.fixture:setUserData("goal")

	objects.player = {}
	objects.player.body = lPh.newBody(world, w, gameDims.y - 50, "dynamic")
	objects.player.shape = lPh.newCircleShape(20)
	objects.player.fixture = lPh.newFixture(objects.player.body, objects.player.shape, 1)
	objects.player.fixture:setRestitution(0.9)
	objects.player.fixture:setUserData("you")
	objects.player.fixture:setFriction(0.9)

	-- generate table to store enemies & make 2
	objects.bouncer = {}
	enemies.constructor( world, objects.bouncer, w, 50 )

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

local lightbox = {
	["status"] = 0,
	["message"] = " ",
	["colour"] = {0,255,0}
}

function score.gameover()
	gameSpeed = 0.15
	score.count = 0
	lightbox.status = 1
	lightbox.message = "YOU'RE DEAD"
	lightbox.colour = {255,0,0}
	world:setCallbacks(nil) -- disable collisions

end

function score.update( plus )
	score.count = score.count + plus
	score.angle = score.angle + plus*5
	if score.angle > (2 * math.pi) then
		score.angle = score.angle - (2 * math.pi)
	end
	if score.count <= 0 then
		score.gameover()
	end
end

function collidePlayerBounds(a, b, coll)
	print("you're dizzy")
end

local new_enemies = 0
function collidePlayerEnemy(a, b, coll)
	score.update(-1)
	new_enemies = new_enemies + 1
end

function collidePlayerGoal( a,b,coll )
	lightbox.status = 1
	lightbox.message = "YOU WIN"
	lightbox.colour = {0,150,220}
	gameSpeed = 0.15
	world:setCallbacks(nil) -- disable collisions
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
		["enemy"]	= function () collidePlayerEnemy() end,
		["goal"]	= function () collidePlayerGoal() end
	},
	["enemy"] = {
		["bounds"]	= function () collideEnemyBounds() end,
		["enemy"]	= function () collideEnemyEnemy() end,
		["you"]		= nil,
		["goal"] 	= nil
	},
	["bounds"] = {
		["you"] 	= nil,
		["enemy"]	= nil
	},
	["goal"] = {
		["you"]		= nil,
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
	if act == nil then
		act = collisions[b][a]
		if act == nil then
			return -- escape because no linked action
		else
			return act(objB, objA, coll) -- inverted action vars
		end
	else
		return act(objA, objB, coll) -- standard vars
	end

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

	-- gravity
	local pX, pY = objects.player.body:getX(), objects.player.body:getY()
	local w, h = love.graphics.getDimensions()
	pX, pY = pX - (w/2), pY - (h/2)
	world:setGravity(pX/4, pY/4) -- decrease gravitational pull

	-- update physics
	world:update(dt * gameSpeed)
	new_enemies = enemies.process(world, objects.bouncer, new_enemies)
end

function love.draw()
	local lg, op, ob = love.graphics, objects.player, objects.bouncer

	lg.setColor(193, 47, 14)
	lg.circle("fill", op.body:getX(), op.body:getY(), op.shape:getRadius())
	local ogl = objects.goal.loc
	lg.line(ogl.x1, ogl.y1, ogl.x2, ogl.y2)

	lg.setColor(50, 50, 50)
	for i,ix in pairs(ob) do
		lg.polygon("fill", ob[i].body:getWorldPoints(ob[i].shape:getPoints()))
	end
	lg.setColor(255,255,255)
	lg.print(score.count,score.x,score.y, score.angle,1,1,30,30)

	if lightbox.status == 1 then
		-- draw the message window
		local w, h = love.graphics.getDimensions()
		lg.setColor(255,255,255,127)
		lg.polygon("fill", w,h,-w,h,-w,-h,w,-h)
		lg.setColor(lightbox.colour[1],lightbox.colour[2],lightbox.colour[3])
		lg.print(lightbox.message,w/2,h/2,0,1,1,30,30)
	end
end