player = {}
cars = {}

function love.load()
	player = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight()}
	cars = {
		{ x = 0,
		y = 0 }
	}
end

function love.update(dt)
	for k,c in pairs(cars) do
		c.y = c.y + 50 * dt
	end
end

function love.draw()
	love.graphics.setColor(1, 0, 0)
	for k,c in pairs(cars) do
		drawCar(c)
	end
	love.graphics.setColor(0, 1, 0)
	drawCar(player)
end

function drawCar(c)
	love.graphics.circle('fill', c.x, c.y, 20)
end

