--============--
--=== INIT ===--
--============--
local is_mcl_or_vlf = minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core")
local modpath = minetest.get_modpath("fireworks_reimagined")
fireworks_reimagined = {}
local firework_shapes = {
	{shape = "sphere", description = "Sphere"},
	{shape = "star", description = "Star"},
	{shape = "ring", description = "Ring"},
	{shape = "burst", description = "Burst"},
	{shape = "cube", description = "Cube"},
	{shape = "spiral", description = "Spiral"},
	{shape = "chaotic", description = "Chaotic"},
	{shape = "flame", description = "Flame"},
	{shape = "snowflake", description = "Snowflake"},
	{shape = "present", description = "Present"},
	{shape = "christmas_tree", description = "Christmas Tree"},
	{shape = "hour_glass", description = "Hour Glass"},
}

function fireworks_reimagined.register_firework_shape(shape_name, description)
    table.insert(firework_shapes, {shape = shape_name, description = description})
end

local function random_color()
	local r = math.random(0, 255)
	local g = math.random(0, 255)
	local b = math.random(0, 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

local function random_explosion_colors()
	local color1 = random_color()
	local color2 = random_color()
	if math.random(2) == 1 then
		return {color1}
	else
		return {color1, color2}
	end
end
--==============--
--=== LEGACY ===--
--==============--

-- FIREWORK SHAPES.
function fireworks_reimagined.spawn_firework_explosion_legacy(pos, shape, double, color_def, color_def_2, alpha, texture, psize)
	local explosion_colors = random_explosion_colors()
	local radius = math.random(4, 7)
	if psize then
		size = psize
	else
		size = math.random(1.5, 3)
	end
	local glow = math.random(5, 15)
	local function spawn_colored_particle(velocity)
		if not color_def then
			color = explosion_colors[math.random(#explosion_colors)]
		elseif color_def and color_def_2 then
			if math.random(2) == 1 then
				color = color_def
			else
				color = color_def_2
			end
		else
			color = color_def
		end
		if not alpha then
			alpha = 128
		end
		if texture then
			colored_texture = texture.."^[colorize:" .. color .. ":" .. alpha
		else
			colored_texture = "black.png^[colorize:" .. color .. ":" .. alpha
		end
		local random_speed = math.random() + 0.5
		local particle_properties = {
			pos = pos,
			velocity = velocity,
			acceleration = {x = 0, y = 0, z = 0},  -- No movement initially
			expirationtime = 2.5,
			size = size,
			texture = colored_texture,
			glow = glow,
			collisiondetection = true,
			collision_removal = true,
		}
		minetest.add_particle(particle_properties)
		minetest.after(0.3, function()
			local breaking_velocity = {
				x = velocity.x + math.random(-2, 2),
				y = velocity.y - 4,
				z = velocity.z + math.random(-2, 2)
			}
			local breaking_particle_properties = {
				pos = pos,
				velocity = breaking_velocity,
				acceleration = {x = 0, y = -1, z = 0},
				expirationtime = 2.2,
				size = size,
				texture = colored_texture,
				glow = glow,
				collisiondetection = true,
				collision_removal = true,
			}
			minetest.add_particle(breaking_particle_properties)
			if double == true then
				minetest.add_particle(breaking_particle_properties)
			end
		end)
	end
	if shape == "sphere" then
		for i = 1, 360, 15 do
  			for j = -90, 90, 15 do
				local theta = math.rad(i)
				local phi = math.rad(j)
				local x = math.cos(phi) * math.cos(theta) * radius
				local y = math.sin(phi) * radius
				local z = math.cos(phi) * math.sin(theta) * radius
				spawn_colored_particle({x = x, y = y, z = z})
			end
		end
	elseif shape == "star" then
		local star_points = {
			{x = radius, y = 0, z = 0},
			{x = -radius, y = 0, z = 0},
			{x = 0, y = radius, z = 0},
			{x = 0, y = -radius, z = 0},
			{x = 0, y = 0, z = radius},
			{x = 0, y = 0, z = -radius},
		}
		for _, point in ipairs(star_points) do
			spawn_colored_particle(point)
  		end
	elseif shape == "ring" then
		for i = 1, 360, 15 do
			local theta = math.rad(i)
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			local y = 0
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "christmas_tree" then
		local height = 10
		local base_radius = 4
		for i = 1, height do
			local current_radius = base_radius * (1 - i / height)
			for j = 1, 360, 30 do
				local theta = math.rad(j)
				local x = math.cos(theta) * current_radius
				local z = math.sin(theta) * current_radius
				spawn_colored_particle({x = x, y = i, z = z})
			end
		end
	elseif shape == "present" then
		for x = -radius, radius, radius do
			for y = -radius, radius, radius do
 				for z = -radius, radius, radius do
					spawn_colored_particle({x = x, y = y, z = z})
				end
			end
		end
		for i = 1, 360, 30 do
			local theta = math.rad(i)
			local x = math.cos(theta) * (radius / 2)
			local z = math.sin(theta) * (radius / 2)
 			local y = radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "snowflake" then
		local arms = 6
		for i = 1, arms do
			local angle = (2 * math.pi / arms) * i
			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			for j = 1, radius do
				spawn_colored_particle({x = x * (j / radius), y = 0, z = z * (j / radius)})
			end
		end
	elseif shape == "spiral" then
		local spiral_height = 10
		local spiral_turns = 5
		for i = 1, 360 * spiral_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * spiral_height
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "hour_glass" then
		local num_turns = 10
		for i = 1, 360 * num_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * num_turns
			local radius = 10 - (y / 2) -- Vary radius over time
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "chaotic" then
		local num_particles = 150
		for i = 1, num_particles do
			local x = (math.random() - 0.5) * 2 * radius
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius
			local rs = math.random() + 0.5
			local random_velocity = {x = x + math.random(-3, 3) * rs, y = y + math.random(-3, 3) * rs, z = z + math.random(-3, 3) * rs}
			spawn_colored_particle(random_velocity)
		end
	elseif shape == "cube" then
		for x = -radius, radius, radius do
			for y = -radius, radius, radius do
				for z = -radius, radius, radius do
 					spawn_colored_particle({x = x, y = y, z = z})
 				end
			end
		end
	elseif shape == "flame" then
		local flame_height = 10
		local base_radius = 3
		for i = 1, 100 do
			local theta = math.rad(math.random(360))
			local r = math.random() * base_radius
			local x = math.cos(theta) * r
			local z = math.sin(theta) * r
			local y = math.random() * flame_height
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "burst" then
		for i = 1, 100 do
			local x = (math.random() - 0.5) * 2 * radius
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	end
end
-- LIMITED FIREWORK PICTURES
function fireworks_reimagined.register_limited_firework_explosion_legacy(pos, delay, color_grid, depth_layers, texture)
	local radius = 1.5
	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	local max_size = math.max(grid_width, grid_height)
	local particle_density = max_size <= 64 and 1 or math.ceil(max_size / 64)
	local pixel_scale = (0.5 / particle_density)
	local size_multiplier = 1.5
	local function spawn_colored_particle(offset, color)
		if texture then
			colored_texture = texture.."^[colorize:" .. color
		else
			colored_texture = "black.png^[colorize:" .. color
		end
		local x = (math.random() - 0.5) * 2 * radius
		local y = (math.random() - 0.5) * 2 * radius
		local z = (math.random() - 0.5) * 2 * radius
		local random_velocity = {x = x + math.random(-3, 3), y = y + math.random(-3, 3), z = z + math.random(-3, 3)}
		local particle_properties = {
			pos = vector.add(pos, offset),
			velocity = {x=0, y=0, z=0},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = delay,
			collisiondetection = true,
			collision_removal = true,
			vertical = false,
			size = 1.5,
			texture = colored_texture,
			glow = 10,
		}
		minetest.add_particle(particle_properties)
		minetest.after(delay, function()
			particle_properties.velocity = random_velocity
			particle_properties.expirationtime = 2.5 - delay
			minetest.add_particle(particle_properties)
		end)
	end
	for z = 0, depth_layers do
		for y = 1, grid_height do
			for x = 1, grid_width do
				local color = color_grid[y][x]
				for dx = 0, particle_density - 1 do
					for dy = 0, particle_density - 1 do
						spawn_colored_particle({
							x = (x * size_multiplier) + (dx * pixel_scale * size_multiplier),
							y = (y * size_multiplier) + (dy * pixel_scale * size_multiplier),
							z = z * size_multiplier
						}, color)
					end
				end
			end
		end
	end
end
-- FULL FIREWORK PICTURES
function fireworks_reimagined.register_firework_explosion_legacy(pos, delay, color_grid, depth_layers, texture)
	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	if grid_width > 32 or grid_height > 32 then
		fireworks_reimagined.register_limited_firework_explosion(pos, delay, color_grid, depth_layers)
		return
	end

	local radius = 1.5
	

	local function spawn_colored_particle(offset, color)
		if texture then
			colored_texture = texture.."^[colorize:" .. color
		else
			colored_texture = "black.png^[colorize:" .. color
		end
		local x = (math.random() - 0.5) * 2 * radius
		local y = (math.random() - 0.5) * 2 * radius
		local z = (math.random() - 0.5) * 2 * radius
		local random_velocity = {x = x + math.random(-3, 3), y = y + math.random(-3, 3), z = z + math.random(-3, 3)}
		local particle_properties = {
			pos = vector.add(pos, offset),
			velocity = {x=0, y=0, z=0},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = delay,
			collisiondetection = true,
			collision_removal = true,
			vertical = false,
			size = 1.5,
			texture = colored_texture,
			glow = 10,
		}
		minetest.add_particle(particle_properties)
		minetest.after(delay, function()
			particle_properties.velocity = random_velocity
			particle_properties.expirationtime = 2.5 - delay
			minetest.add_particle(particle_properties)
		end)
	end
	local pixel_scale = 0.5 / 2
	local size_multiplier = 1.5
	for z = 0, depth_layers do
		for y = 1, #color_grid do
			for x = 1, #color_grid[y] do
				local color = color_grid[y][x]
				for dx = 0, 1 do
					for dy = 0, 1 do
						spawn_colored_particle({
							x = (x * size_multiplier) + (dx * pixel_scale * size_multiplier),
							y = (y * size_multiplier) + (dy * pixel_scale * size_multiplier),
							z = z * size_multiplier
						}, color)
					end
				end
			end
		end
	end
end
--===========--
--=== API ===--
--===========--
-- FIREWORKS SHAPES.
function fireworks_reimagined.spawn_firework_explosion(pos, shape, double, color_def, color_def_2, alpha, texture, psize)
	local explosion_colors = random_explosion_colors()
	local radius = math.random(4, 7)
	local size = psize or math.random(1.5, 3)
	local glow = math.random(10, 15)
	local color = color_def or explosion_colors[math.random(#explosion_colors)]
	local color_def_2 = color_def_2 or explosion_colors[math.random(#explosion_colors)]
	alpha = alpha or 128
	local function get_colored_texture(index, total)
		local chosen_color
		--if index <= total / 2 then
		if math.random(1,2) == 1 then
			chosen_color = color_def or color
		else
			chosen_color = color_def_2
		end
		return texture and texture .. "^[colorize:" .. chosen_color .. ":" .. alpha or "black.png^[colorize:" .. chosen_color .. ":" .. alpha
	end

	local particle_params = {
		amount = 1,
		time = 2.5,
		minpos = pos,
		maxpos = pos,
		acceleration = {x = 0, y = -1, z = 0},
		minexptime = 1.5,
		maxexptime = 2.5,
		minsize = size,
 		maxsize = size,
 		glow = glow,
		collisiondetection = true,
		collision_removal = true,
	}
	if shape == "spiral" then
		local spiral_height = 10
		local spiral_turns = 5
		local total_particles = 360 * spiral_turns / 15
		for i = 1, 360 * spiral_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * spiral_height
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			particle_params.minvel = {x = x, y = y, z = z}
			particle_params.maxvel = {x = x, y = y, z = z}
			particle_params.texture = get_colored_texture(i, total_particles)
			minetest.add_particlespawner(particle_params)
	    	end
	elseif shape == "sphere" then
		local total_particles = 360 / 15
		for i = 1, 360, 15 do
			for j = -90, 90, 15 do
				local theta = math.rad(i)
				local phi = math.rad(j)
				local x = math.cos(phi) * math.cos(theta) * radius
				local y = math.sin(phi) * radius
				local z = math.cos(phi) * math.sin(theta) * radius
				particle_params.minvel = {x = x, y = y, z = z}
				particle_params.maxvel = {x = x, y = y, z = z}
				particle_params.texture = get_colored_texture(i, total_particles)
				minetest.add_particlespawner(particle_params)
			end
		end
	elseif shape == "star" then
		local star_points = {
			{x = radius, y = 0, z = 0},
			{x = -radius, y = 0, z = 0},
			{x = 0, y = radius, z = 0},
			{x = 0, y = -radius, z = 0},
			{x = 0, y = 0, z = radius},
			{x = 0, y = 0, z = -radius},
		}
		for _, point in ipairs(star_points) do
			particle_params.minvel = point
			total_particles = 6
			particle_params.maxvel = point
			for i = 1,8 do
				particle_params.texture = get_colored_texture(i, total_particles)
			end
			minetest.add_particlespawner(particle_params)
		end

	elseif shape == "ring" then
		local total_particles = 360 / 15
		for i = 1, 360, 15 do
			local theta = math.rad(i)
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			local y = 0
			particle_params.minvel = {x = x, y = y, z = z}
			particle_params.maxvel = {x = x, y = y, z = z}
			particle_params.texture = get_colored_texture(i, total_particles)
			minetest.add_particlespawner(particle_params)
		end
	elseif shape == "christmas_tree" then
		local height = 10
		local base_radius = 5

		for i = 1, height do
			local current_radius = base_radius * (1 - i / height)
			local total_particles = 360 / 30
			for j = 1, 360, 30 do
				local theta = math.rad(j)

				local x = math.cos(theta) * current_radius
				local z = math.sin(theta) * current_radius
				particle_params.minvel = {x = x, y = i, z = z}
				particle_params.maxvel = {x = x, y = i, z = z}
				particle_params.texture = get_colored_texture(j, total_particles)
				minetest.add_particlespawner(particle_params)
			end

		end

	elseif shape == "present" then
		local present_positions = {
			{x = 0, y = 0, z = 0},
			{x = 1, y = 0, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 1, y = 1, z = 0},
			{x = 0, y = 0, z = 1},
			{x = 1, y = 0, z = 1},
			{x = 0, y = 1, z = 1},
			{x = 1, y = 1, z = 1},
		}

		for _, pos in ipairs(present_positions) do
			particle_params.minvel = pos
			particle_params.maxvel = pos
			total_particles = 8
			for i = 1, 8 do
				particle_params.texture = get_colored_texture(i, total_particles)
			end
			minetest.add_particlespawner(particle_params)
		end

	elseif shape == "snowflake" then
		local snowflake_points = {
			{x = 0, y = 1, z = 0},
			{x = 1, y = 0, z = 0},
			{x = 0, y = 0, z = 1},
			{x = -1, y = 0, z = 0},
			{x = 0, y = 0, z = -1},
			{x = 1, y = 1, z = 1},
			{x = -1, y = 1, z = -1},
		}

		for _, point in ipairs(snowflake_points) do
			particle_params.minvel = point
			particle_params.maxvel = point
			total_particles = 7
			for i = 1, 7 do
				particle_params.texture = get_colored_texture(i, total_particles)
			end
			minetest.add_particlespawner(particle_params)
		end
	elseif shape == "hour_glass" then
		local num_turns = 10
		local total_particles = 240 * num_turns / 15
		for i = 1, 240 * num_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * num_turns

			local radius = 10 - (y / 2)
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			particle_params.minvel = {x = x, y = y, z = z}
			particle_params.maxvel = {x = x, y = y, z = z}
			particle_params.texture = get_colored_texture(i, total_particles)
			minetest.add_particlespawner(particle_params)
			particle_params.minvel = {x = -x/5, y = -y/5, z = -z/5}
			particle_params.maxvel = {x = -x/5, y = -y/5, z = -z/5}
			minetest.add_particlespawner(particle_params)
		end

	elseif shape == "chaotic" then
		local total_particles = 0
		for _ = 1, 150 do
			total_particles = total_particles + 1
			local x = (math.random() - 0.5) * 2 * radius
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius

			local rs = math.random() + 0.5
			local random_velocity = {x = x + math.random(-3, 3) * rs, y = y + math.random(-3, 3) * rs, z = z + math.random(-3, 3) * rs}
			particle_params.texture = get_colored_texture(i, total_particles)
			particle_params.minvel = {x = random_velocity.x, y = random_velocity.y, z = random_velocity.z}
			particle_params.maxvel = {x = random_velocity.x, y = random_velocity.y, z = random_velocity.z}
			minetest.add_particlespawner(particle_params)
		end
	elseif shape == "cube" then
		local size = radius
		local half_size = size / 2
		local cube_positions = {
			{x = -half_size, y = -half_size, z = -half_size},
			{x = half_size, y = -half_size, z = -half_size},
			{x = -half_size, y = half_size, z = -half_size},
			{x = half_size, y = half_size, z = -half_size},
			{x = -half_size, y = -half_size, z = half_size},
			{x = half_size, y = -half_size, z = half_size},
			{x = -half_size, y = half_size, z = half_size},
			{x = half_size, y = half_size, z = half_size},
		}
		for index, pos in ipairs(cube_positions) do
			particle_params.texture = get_colored_texture(index, #cube_positions)
			particle_params.minvel = pos
			particle_params.maxvel = pos
			minetest.add_particlespawner(particle_params)
		end
	elseif shape == "flame" then
		local flame_height = 10
		local base_radius = 3
		local total_particles = 0
		for i = 1, 100 do
			local theta = math.rad(math.random(360))
			total_particles = total_particles + 1
			local r = math.random() * base_radius
			local x = math.cos(theta) * r

			local z = math.sin(theta) * r
			local y = math.random() * flame_height
			particle_params.minvel = {x = x, y = y, z = z}
			particle_params.maxvel = {x = x, y = y, z = z}
			particle_params.texture = get_colored_texture(i, total_particles)
			minetest.add_particlespawner(particle_params)
		end
	elseif shape == "burst" then
		local total_particles = 0
		for i = 1, 100 do
			local x = (math.random() - 0.5) * 2 * radius
			total_particles = total_particles + 1
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius
			particle_params.minvel = {x = x, y = y, z = z,}
			particle_params.maxvel = {x = x, y = y, z = z,}
			particle_params.texture = get_colored_texture(i, total_particles)
			minetest.add_particlespawner(particle_params)
		end
	end
end
-- LIMITED FIREWORKS IMAGE EXPLOSION
function fireworks_reimagined.register_limited_firework_explosion(pos, delay, color_grid, depth_layers, texture)
	local radius = 1.5
	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	local max_size = math.max(grid_width, grid_height)
	local particle_density = max_size <= 64 and 1 or math.ceil(max_size / 64)
	local pixel_scale = (0.5 / particle_density)
	local size_multiplier = 1.5
	local spawner_id = minetest.add_particlespawner({
		amount = max_size * max_size * particle_density,
		time = 2.5,
		minpos = vector.subtract(pos, radius),
		maxpos = vector.add(pos, radius),
		minvel = {x = -2, y = -2, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = {x = 0, y = 0, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = delay,
		maxexptime = 2.5,
		minsize = 1.5,
		maxsize = 1.5,
		collisiondetection = true,
		collision_removal = true,
		glow = 10
	})
	for z = 0, depth_layers do
		for y = 1, grid_height do
			for x = 1, grid_width do
				local color = color_grid[y][x]
				local colored_texture = texture and texture .. "^[colorize:" .. color or "black.png^[colorize:" .. color
				minetest.add_particlespawner({
					amount = particle_density,
					time = 2.5 - delay,
					minpos = vector.add(pos, {
						x = (x * size_multiplier),
						y = (y * size_multiplier),
						z = z * size_multiplier
					}),
					maxpos = vector.add(pos, {
						x = (x * size_multiplier + pixel_scale),
						y = (y * size_multiplier + pixel_scale),
						z = z * size_multiplier
					}),
					minvel = {x = -3, y = -3, z = -3},
					maxvel = {x = 3, y = 3, z = 3},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = delay,
					maxexptime = 2.5 - delay,
					minsize = 1.5,
					maxsize = 1.5,
					collisiondetection = true,
					collision_removal = true,
					glow = 10,
					texture = colored_texture,
				})
			end
		end
	end
end

function fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers, texture)
	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	if grid_width > 32 or grid_height > 32 then
		fireworks_reimagined.register_limited_firework_explosion(pos, delay, color_grid, depth_layers)
		return
	end
	local radius = 1.5
	local pixel_scale = 0.5 / 2
	local size_multiplier = 1.5
	local particle_lifetime = 2.5 - delay
	for z = 0, depth_layers do
		for y = 1, #color_grid do
			for x = 1, #color_grid[y] do
				local color = color_grid[y][x]
				local colored_texture = texture and (texture .. "^[colorize:" .. color) or ("black.png^[colorize:" .. color)
  				local base_offset = {
					x = x * size_multiplier,
					y = y * size_multiplier,
					z = z * size_multiplier,
				}
				minetest.add_particlespawner({
					amount = 4,
					time = delay,
					minpos = vector.add(pos, base_offset),
					maxpos = vector.add(pos, base_offset),
					minvel = {x = -radius, y = -radius, z = -radius},
					maxvel = {x = radius, y = radius, z = radius},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = delay,
					maxexptime = particle_lifetime,
					minsize = 1.5,
					maxsize = 1.5,
					collisiondetection = true,
					collision_removal = true,
					vertical = false,
					texture = colored_texture,
					glow = 10,
				})
			end
		end
	end
end

local last_rightclick_time = {}
local last_mesecons_time = {}

function fireworks_reimagined.register_firework_node(tiles, shape, entity, delay, cooldown, mese_cooldown)
	minetest.register_node(":fireworks_reimagined:firework_" .. shape .. "_" .. delay, {
		description = "Firework (" .. shape .. ") Delay: ( " .. delay .. " )",
		tiles = { tiles or "fireworks_" .. shape .. ".png" },
		groups = { cracky = 1, oddly_breakable_by_hand = 1 },
		paramtype = "light",
		light_source = 5,
		on_rightclick = function(pos, node, clicker)
			local pos_hash = minetest.hash_node_position(pos)
			local player_name = clicker:get_player_name()
			local current_time = minetest.get_gametime()
			local cd = cooldown or 3
			local privs = minetest.get_player_privs(player_name)
			if not last_rightclick_time[pos_hash] or current_time - last_rightclick_time[pos_hash] >= cd and not privs.fireworks_master then
				last_rightclick_time[pos_hash] = current_time
				minetest.after(delay, function()
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						firework_entity:get_luaentity().firework_shape = shape
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end)
			elseif privs.fireworks_master then
				minetest.after(delay, function()
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						firework_entity:get_luaentity().firework_shape = shape
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end)
			else
				minetest.chat_send_player(clicker:get_player_name(), "Please wait before launching another firework!")
			end
		end,
		mesecons = { effector = {
			rules = rules,
			action_on = function(pos, node)
				local pos_hash = minetest.hash_node_position(pos)
				local current_time = minetest.get_gametime()
				local mcd = mese_cooldown or 4
				if not last_mesecons_time[pos_hash] or current_time - last_mesecons_time[pos_hash] >= mcd then
					last_mesecons_time[pos_hash] = current_time
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						firework_entity:get_luaentity().firework_shape = shape
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end
			end,
		}},
	})
end

local registered_fireworks = {}
function fireworks_reimagined.register_firework_entity(name, def)
	local entity_def = {
		initial_properties = {
			physical = true,
			collide_with_objects = false,
			visual = "sprite",
			textures = {"fireworks_rocket_white.png"},
			velocity = 0.5,
			glow = 5,
		},
		firework_shape = def.firework_shape or "sphere",
		time_remaining = def.time_remaining or 2,
		spiral = def.spiral or false,
		spiral_angle = def.spiral_angle or 100,
		spiral_radius = def.spiral_radius or 80,
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			if not pos then return end
			pos.y = pos.y + (self.initial_properties.velocity * dtime)
			if self.spiral then
				self.spiral_angle = self.spiral_angle + (math.pi / 8)
				local offset_x = math.cos(self.spiral_angle) * self.spiral_radius
				local offset_z = math.sin(self.spiral_angle) * self.spiral_radius
				self.object:set_velocity({x = offset_x, y = 18, z = offset_z})
				self.spiral_radius = self.spiral_radius + (0.01 * dtime)
			else
				self.object:set_velocity({x = 0, y = 20, z = 0})
			end
			self.time_remaining = self.time_remaining - dtime
			if self.time_remaining <= 0 then
				local explosion_fn = def.firework_explosion
				explosion_fn(pos)
				self.object:remove()
				minetest.sound_play("fireworks_explosion", {
					pos = pos,
					max_hear_distance = 60,
					gain = 20.0
				})
			end
		end,
	}
	minetest.register_entity(":"..name, entity_def)
	registered_fireworks[name] = entity_def
end

--==================--
--=== LOCAL FUNC ===--
--==================--

local function spawn_firework_entity(pos, firework_shape)
	local obj = minetest.add_entity(pos, "fireworks_reimagined:firework_entity")
	if obj then
		obj:get_luaentity().firework_shape = firework_shape
	end
end

local function spawn_random_firework(pos)
	local shapes = {"sphere", "star", "ring", "burst", "cube", "spiral", "chaotic", "flame", "snowflake", "present", "christmas_tree"}
	local random_shape = shapes[math.random(#shapes)]
	spawn_firework_entity(pos, random_shape)
end

--==================--
--=== REGISTRIES ===--
--==================--

minetest.register_entity("fireworks_reimagined:firework_entity", {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		visual = "sprite",
		textures = {"fireworks_rocket_white.png"},
		velocity = 0.5,
		glow = 5,
	},
	firework_shape = "sphere",
	time_remaining = 2,
	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end
		pos.y = pos.y + (self.initial_properties.velocity * dtime)
		self.object:set_velocity({x = 0, y = 20, z = 0})
		self.time_remaining = self.time_remaining - dtime
		if self.time_remaining <= 0 then
			fireworks_reimagined.spawn_firework_explosion(pos, self.firework_shape or "sphere", false, nil, nil, nil, nil, nil)
			self.object:remove()
			minetest.sound_play("fireworks_explosion", {
				pos = pos,
				max_hear_distance = 60,
				gain = 20.0
			})
		end
	end,
})

local usage_limit = 3
local cooldown_time = 4
local user_usage = {}

minetest.register_craftitem("fireworks_reimagined:firework_item", {
	description = "Firework (Random)",
	inventory_image = "fireworks_item.png",
	on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()
		local current_time = minetest.get_gametime()
		
		local privs = minetest.get_player_privs(player_name)
		if privs.fireworks_master then
			local pos = user:get_pos()
			pos.y = pos.y + 1.5
			spawn_random_firework(pos)
			itemstack:take_item()
			return itemstack
		end
		if not user_usage[player_name] then
			user_usage[player_name] = {
				uses = 0,
				last_used = 0,
			}
		end

		local usage_data = user_usage[player_name]
		if current_time - usage_data.last_used >= cooldown_time then
			usage_data.uses = 0
			usage_data.last_used = current_time
		end
		if usage_data.uses < usage_limit then
			local pos = user:get_pos()
			pos.y = pos.y + 1.5
			spawn_random_firework(pos)
			itemstack:take_item()
			usage_data.uses = usage_data.uses + 1
			return itemstack
		else
			minetest.chat_send_player(player_name, "You can only use this item 3 times every 4 seconds.")
			return itemstack
		end
	end,
})

minetest.register_privilege("fireworks_master", {
	description = ("Allows the player with this priv to not be affected by the user cooldown on fireworks."),
	give_to_singleplayer = false,
})

-- Clean up usage data when player leaves the game
minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	user_usage[player_name] = nil
end)

if minetest.get_modpath("mesecons") then
	local rules = mesecon.rules.pplate
end

dofile(modpath.."/creeper.lua")
dofile(modpath.."/crafting.lua")
dofile(modpath.."/colored.lua")
dofile(modpath.."/2025.lua")
dofile(modpath.."/default.lua")
dofile(modpath.."/test.lua")
