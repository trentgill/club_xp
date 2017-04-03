platform = {}
player = {}

function love.load(  )
	-- body
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2

	player.img = love.graphics.newImage('perfect.png')
end

function love.update( dt )
	-- body
end

function love.draw(  )
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 32)
end