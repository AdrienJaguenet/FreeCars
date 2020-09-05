player = {}
cars = {}
settings = {N_LANES = 4, MAX_CARS=10}

function filter_inplace(arr, func)
    local new_index = 1
    local size_orig = #arr
    for old_index, v in ipairs(arr) do
        if func(v, old_index) then
            arr[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do arr[i] = nil end
end

function newCar()
	return {
		lane = math.random(0,settings.N_LANES + 1),
		y = 0
	}
end

function love.load()
	settings.lane_width = love.graphics.getWidth() / 4
	settings.car_radius = settings.lane_width / 2 - settings.lane_width / 10
	player = {y = love.graphics.getHeight(), lane=2}
	cars = {
		newCar(),
	}
end

function love.update(dt)
	local n = #cars
	local missing_cars = 0

	-- update cars

	for i=1,n do
		local c = cars[i]
		c.y = c.y + 250 * dt
	end

	filter_inplace(cars, function(c) return c.y < love.graphics.getHeight() end)


	-- Spawn a new car if no collision would be created

	if #cars < settings.MAX_CARS then
		local c = newCar()
		local collision = false
		for k,c_ in pairs(cars) do
			if math.abs(c.y - c_.y) < 2 * settings.car_radius then
				collision = true
			end
		end
		if not collision then
			table.insert(cars, newCar())
		end
	end

	-- Check for a collision with the player
	local collision = false
	for k, c in pairs(cars) do
		if c.lane == player.lane and math.abs(c.y - player.y) then
			print('GAME OVER')
		end
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

function xFromLane(n)
	return n * settings.lane_width + settings.lane_width / 2
end

function love.keypressed(key)
	if key == 'left' then
		player.lane = math.max(player.lane - 1, 0)
	elseif key == 'right'  then
		player.lane = math.min(player.lane + 1, settings.N_LANES)
	end
end

function drawCar(c)
	love.graphics.circle('fill', xFromLane(c.lane), c.y, settings.car_radius)
end

