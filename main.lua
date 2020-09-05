settings = {N_LANES = 5, MAX_CARS=10, BORDER=60}
gfx = {}
carsound = love.audio.newSource("resources/car-loop.wav", "static")
music = love.audio.newSource("resources/music.wav", "stream")

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
		y = -109,
		gfx = math.random(1,4)
	}
end

function love.load()
	love.window.setMode(640,480)
	settings.lane_width = (love.graphics.getWidth() - settings.BORDER * 2) / settings.N_LANES
	bg_y = 0
	cars = {
		newCar(),
	}
	gfx = {
		background = love.graphics.newImage('resources/background-1.png'),
		cars = {
		}
	}
	gfx.background:setWrap('repeat', 'repeat')
	for i=1,5 do
		table.insert(gfx.cars, love.graphics.newImage('resources/car-'..i..'.png'))
	end
	settings.car_radius = gfx.cars[1]:getHeight()/2

	carsound:setLooping(true)
	carsound:play()
	music:setLooping(true)
	music:play()

	resetPlayer()
end

function love.update(dt)
	if settings.game_over == true then
		return
	end

	local n = #cars
	local missing_cars = 0

	-- update cars

	for k, c in pairs(cars) do
		c.y = c.y + 250 * dt
	end
	bg_y = bg_y + 250 * dt

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
		if c.lane == player.lane and math.abs(c.y - player.y) < settings.car_radius * 2 then
	--		collision = true
			print('GAME OVER')
		end
	end
	if collision == true then
		settings.game_over = true
		cars = {}
		resetPlayer()
	end

	-- Add a score to the player
	player.score = player.score + dt
end

function love.draw()
	local actual_bg_y = bg_y % gfx.background:getHeight()
	love.graphics.draw(gfx.background, 0, 0, 0, 1, 1, 0, -actual_bg_y) 
	love.graphics.draw(gfx.background, 0, 0, 0, 1, 1, 0, gfx.background:getHeight() - actual_bg_y)
	if not settings.game_over then
		love.graphics.setColor(1, 0, 0)
		love.graphics.print("Score: "..player.score, 0, 0)
		love.graphics.reset()
		for k,c in pairs(cars) do
			drawCar(c)
		end
		drawCar(player)
	else
		love.graphics.setColor(0, 0, 1)
		love.graphics.print("GAME OVER!\nScore: "..player.score, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
		love.graphics.reset()
	end
end

function xFromLane(n)
	return n * settings.lane_width + settings.lane_width / 2 + settings.BORDER - gfx.cars[1]:getWidth()/2
end

function love.keypressed(key)
	if key == 'left' then
		player.lane = math.max(player.lane - 1, 0)
	elseif key == 'right'  then
		player.lane = math.min(player.lane + 1, settings.N_LANES - 1)
	elseif key == 'space' then
		settings.game_over = false
	end
end

function resetPlayer()
	player = {y = love.graphics.getHeight() - settings.car_radius, lane=2,score=0, gfx=4}
end

function drawCar(c)
	love.graphics.draw(gfx.cars[c.gfx], xFromLane(c.lane), c.y)
end

