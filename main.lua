settings = {N_LANES = 5, MAX_CARS=10, BORDER=60}
gfx = {}

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
		y = - (gfx.cars[1]:getHeight()),
		gfx = math.random(1,4),
		car=1
	}
end

function love.load()
	love.window.setMode(640,480)
	settings.lane_width = (love.graphics.getWidth() - settings.BORDER * 2) / settings.N_LANES
	bg_y = 0
	gfx = {
		background = love.graphics.newImage('resources/background-1.png'),
		cars = {
		},
		font = love.graphics.newFont('resources/fonts/LCDWinTT/LCD2B___.TTF', 32)
	}
	gfx.background:setWrap('repeat', 'repeat')
	for i=1,5 do
		table.insert(gfx.cars, love.graphics.newImage('resources/car-'..i..'.png'))
	end
	cars = {
	}
	settings.car_radius = gfx.cars[1]:getHeight()/2

	sfx = {
		engine = love.audio.newSource("resources/car-loop.wav", "static"),
		steer = love.audio.newSource("resources/steer.wav", "static"),
		crash = love.audio.newSource("resources/crash.wav", "static"),
		music = love.audio.newSource("resources/music.wav", "stream")
	}

	sfx.engine:setLooping(true)
	sfx.engine:play()
	sfx.music:setLooping(true)
	sfx.music:play()

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
			collision = true
			print('GAME OVER')
		end
	end
	if collision == true then
		settings.game_over = true
		sfx.engine:pause()
		sfx.crash:play()
		cars = {}
	end

	-- Add a score to the player
	player.score = player.score + dt
end

function love.draw()
	local actual_bg_y = bg_y % gfx.background:getHeight()
	love.graphics.draw(gfx.background, 0, 0, 0, 1, 1, 0, -actual_bg_y) 
	love.graphics.draw(gfx.background, 0, 0, 0, 1, 1, 0, gfx.background:getHeight() - actual_bg_y)
	love.graphics.setFont(gfx.font)
	if not settings.game_over then
		for k,c in pairs(cars) do
			drawCar(c)
		end
		drawCar(player)
		love.graphics.print("Score: "..string.format("%.2f", player.score), 0, 0)
	else
		love.graphics.printf("GAME OVER!\nScore: "..string.format("%.2f", player.score).."\nPress space to continue", 
			0, love.graphics.getHeight()/2, love.graphics.getWidth(), 'center')
	end
end

function xFromLane(n)
	return n * settings.lane_width + settings.lane_width / 2 + settings.BORDER - gfx.cars[1]:getWidth()/2
end

function love.keypressed(key)
	if key == 'left' then
		if player.lane > 0 then
			player.lane = player.lane - 1
			sfx.steer:play()
		end
	elseif key == 'right'  then
		if player.lane < settings.N_LANES - 1 then
			player.lane = player.lane + 1
			sfx.steer:play()
		end
	elseif key == 'space' then
		settings.game_over = false
		resetPlayer()
		sfx.engine:play()
	end
end

function resetPlayer()
	player = {y = love.graphics.getHeight() - settings.car_radius, lane=2,score=0, gfx=4}
end

function drawCar(c)
	local rot = 0
	if c.car then
		rot = math.pi
	end
	love.graphics.draw(gfx.cars[c.gfx], xFromLane(c.lane), c.y, rot)
end

