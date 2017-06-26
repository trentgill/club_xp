local enemies = require("scripts.enemies")

score = {}

local img_scale = 0.1
local gameSpeed = 1

local gameDims = {
	["x"] = 2560,
	["y"] = 1440
}

function love.load()
        local windowMode = {}
        _, _, windowMode = love.window.getMode()

        -- graphics setup
	love.graphics.setBackgroundColor(104, 136, 200)
        gameDims.x, gameDims.y = love.window.getDesktopDimensions( windowMode.display )
	love.window.setMode(gameDims.x, gameDims.y)
	checkJoysticks()

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
	objects.player.defaults = {}
	objects.player.defaults.x = w
	objects.player.defaults.y = gameDims.y - 50

	objects.player.body = lPh.newBody(world, objects.player.defaults.x, objects.player.defaults.y, "dynamic")
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
	score.x2 = w*2-100
	score.y = 40
	score.count = 10
	score.angle = 0
end

local lightbox = {
	["status"] = 0,
	["message"] = " ",
	["colour"] = {0,255,0}
}

gamestate = {
	['level'] = 1
}
function gamestate.reset()
	-- check if we're at an 'end state'
	if lightbox.status == 1 then
		enemies.destructor( world, objects.bouncer )

		-- reset player location
		objects.player.body:setLinearVelocity(0,0)
		objects.player.body:setX(objects.player.defaults.x)
		objects.player.body:setY(objects.player.defaults.y)

		-- generate new enemies
		for i=1,gamestate.level do
			enemies.constructor( world, objects.bouncer, (gameDims.x)/2+i, 50 )
		end
		world:setCallbacks(beginContact)

		-- global reset
		lightbox.status = 0
		gameSpeed = 1
	end
end

function score.gameover()
	world:setCallbacks(nil) -- disable collisions
	gameSpeed = 0.15
	score.count = 10
	lightbox.status = 1
	lightbox.message = "YOU'RE DEAD"
	lightbox.colour = {255,0,0}
	gamestate.level = 1 -- reset to level 1
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
	score.count = score.count + 10
	lightbox.status = 1
	lightbox.message = "YOU WIN"
	lightbox.colour = {0,150,220}
	gamestate.level = gamestate.level + 1
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
	start   = function () love.event.quit() end,

	["return"]	= function () gamestate.reset() end,
	b		= function () gamestate.reset() end,

	a 		= function () objects.player.body:applyForce(-400,   0) end,
	d 		= function () objects.player.body:applyForce( 400,   0) end,
	s 		= function () objects.player.body:applyForce(   0, 400) end,
	w 		= function () objects.player.body:applyForce(   0,-400) end,

	-- left,right,down,up = a,d,s,w,
	left	= function () objects.player.body:applyForce(-400,   0) end,
	dpleft  = function () objects.player.body:applyForce(-400,   0) end,
	right	= function () objects.player.body:applyForce( 400,   0) end,
	dpright = function () objects.player.body:applyForce( 400,   0) end,
	down	= function () objects.player.body:applyForce(   0, 400) end,
	dpdown  = function () objects.player.body:applyForce(   0, 400) end,
	up 	= function () objects.player.body:applyForce(   0,-400) end,
	dpup    = function () objects.player.body:applyForce(   0,-400) end,

	space 	= function ()
			local x,y = objects.player.body:getLinearVelocity()
				    objects.player.body:applyForce(
								-(x*5),
								-(y*5)) end
	
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


theJoy = {}
jsID = {}
function checkJoysticks()
	local joysticks = love.joystick.getJoysticks()
	for i,js in ipairs(joysticks) do
		print(js:getName())
		theJoy = js:getName()
                jsID = js
                if js:isVibrationSupported() then
                    js:setVibration(1,1,0.2)
                end
            local axis1, axis2 = js:getAxes()
            print("axis1", axis1)
            print("axis2", axis2)
	end
    print(state)
end

function love.joystickaxis( gp, axis, val )
    if gp == theJoy then
        print(axis, val)
    end
end

function love.joystickadded( js )
    print(js)
end

function love.gamepadpressed( theJoy, k )
	local action = bindings[k]
	heldKeys[k] = action
end

function love.gamepadreleased( theJoy, k )
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
        local joysticks = love.joystick.getJoysticks()
        for i,js in ipairs(joysticks) do
            local axis1, axis2 = js:getAxes()
            objects.player.body:applyForce(axis1*400, axis2*400)
        end
        -- local axis1, axis2 = js:getAxes()
	-- gravity
	local pX, pY = objects.player.body:getX(), objects.player.body:getY()
	local w, h = love.graphics.getDimensions()
	pX, pY = pX - (w/2), pY - (h/2)
	world:setGravity(pX/2, pY/2) -- decrease gravitational pull

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
	lg.print("level: "..gamestate.level,score.x2,score.y, score.angle,1,1,30,30)

	if lightbox.status == 1 then
		-- draw the message window
		local w, h = love.graphics.getDimensions()
		lg.setColor(255,255,255,127)
		lg.polygon("fill", w,h,-w,h,-w,-h,w,-h)
		lg.setColor(lightbox.colour[1],lightbox.colour[2],lightbox.colour[3])
		lg.print(lightbox.message,w/2,h/2,0,1,1,30,30)
	end
end
