player = {}
score = {}

local img_scale = 0.1

function love.load()
	-- player emoji
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.img = love.graphics.newImage('perfect.png')
	player.momentum = 1
	player.friction = 0.97
	player.velo = { x = 0, y = 0 }
		-- player.velo.x = 0
		-- player.velo.y = 0
	player.rotation = 0

	-- score board
	mainFont = love.graphics.newFont("lekton.ttf", 30)
	love.graphics.setFont(mainFont)
	score.x = 40
	score.y = 40
	score.count = 0
	score.rotation = 0
end

function score.update( plus )
	score.count = score.count + plus
	score.rotation = score.rotation + plus*5
	if score.rotation > (2 * math.pi) then
		score.rotation = score.rotation - (2 * math.pi)
	end
end

function player.impact( dim )
	score.update( 1 )
	player.velo[dim] = -(player.velo[dim])
	player.rotation = player.rotation + 1
end

function player.move( dim, value )
	player.velo[dim] = player.velo[dim] + value * player.momentum
	-- score.count = go
end

-- user actions: function w/ optional table of arguments
local bindings = {
	escape 	= function () loop.event.quit() end,
	up 		= function () player.move("y", -1) end,
	down 	= function () player.move("y",  1) end,
	left	= function () player.move("x", -1) end,
	right 	= function () player.move("x",  1) end,
	stick 	= function (value) player.move("x", value) end
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

-- function love.mousemoved( x, y, dx, dy )
-- 	player.move("x", dx / 10)
-- 	player.move("y", dy / 10)
-- end

function love.update( dt )
	-- input handler
	inputHandler()

	-- apply momentum to player position with limits
	if player.velo.y ~= 0 then
		player.y = player.y + player.velo.y
		player.velo.y = player.velo.y * player.friction
		if player.y < 0 then
			player.y = -(player.y)
			player.impact("y")
		elseif player.y > (love.graphics.getHeight() - player.img:getHeight()*img_scale) then
			player.y = 2*(love.graphics.getHeight() - player.img:getHeight()*img_scale) - player.y
			player.impact("y")
		end
	end

	if player.velo.x ~= 0 then
		player.x = player.x + player.velo.x
		player.velo.x = player.velo.x * player.friction
		if player.x < 0 then
			player.x = -(player.x)
			player.impact("x")
		elseif player.x > (love.graphics.getWidth() - player.img:getWidth()*img_scale) then
			player.x = 2*(love.graphics.getWidth() - player.img:getWidth()*img_scale) - player.x
			player.impact("x")
		end
	end

end

function love.draw(  )
	love.graphics.draw(player.img, player.x, player.y, player.rotation, img_scale, img_scale, 0, 32)
	love.graphics.print(score.count,score.x,score.y, score.rotation,1,1,30,30)
end





