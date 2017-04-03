player = {}
score = {}

img_scale = 0.1

function love.load(  )
	-- player emoji
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.img = love.graphics.newImage('perfect.png')
	player.momentum = 10
	player.friction = 0.97
	player.velo = {}
		player.velo.x = 0
		player.velo.y = 0
	player.rotation = 0

	-- score board
	mainFont = love.graphics.newFont("lekton.ttf", 30)
	love.graphics.setFont(mainFont)
	score.x = 40
	score.y = 40
	score.count = 0
	score.rotation = 0

	-- player input
	love.keyboard.setKeyRepeat(true)
end

function score.update( plus )
	score.count = score.count + plus
	score.rotation = score.rotation + plus*5
	if score.rotation > (2 * math.pi) then
		score.rotation = score.rotation - (2 * math.pi)
	end
end

function player.impact( dir )
	score.update( 1 )
	if dir ~= "y" then
		player.velo.x = -(player.velo.x)
	else
		player.velo.y = -(player.velo.y)
	end
	player.rotation = player.rotation + 1
end

local keys = {
	escape	= love.event.quit,
	up 		= {"y", -1},
	down 	= {"y",  1},
	left	= {"x", -1},
	right 	= {"x",  1}
}

function love.keypressed( k )
	local act = keys[k]
	if act then
		return act()
		-- player.velo[act[1]] = player.velo[act[1]] + act[2] * player.momentum
	end
end

function love.update( dt )
	-- input gives momentum to player
	-- if love.keyboard.isDown('up') then
	-- 	player.velo.y = player.velo.y - player.momentum * dt
	-- elseif love.keyboard.isDown('down') then
	-- 	player.velo.y = player.velo.y + player.momentum * dt
	-- end

	-- if love.keyboard.isDown('left') then
	-- 	player.velo.x = player.velo.x - player.momentum * dt
	-- elseif love.keyboard.isDown('right') then
	-- 	player.velo.x = player.velo.x + player.momentum * dt
	-- end

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





