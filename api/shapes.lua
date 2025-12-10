local function spawn_sphere_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local golden_angle = math.pi * (3 - math.sqrt(5))
	
	local function emit_perfect_sphere(delay, num_particles, wave_intensity, size_mult, glow_mult)
		core.after(delay, function()
			for i = 0, num_particles - 1 do
				local y = 1 - (i / (num_particles - 1)) * 2
				local radius_at_y = math.sqrt(1 - y * y)
				local theta = golden_angle * i
				local r = radius * size_mult * (0.9 + math.random() * 0.2)
				local speed_mult = (0.95 + math.random() * 0.1) * wave_intensity

				local x = math.cos(theta) * radius_at_y * r * speed_mult
				local z = math.sin(theta) * radius_at_y * r * speed_mult
				local y_pos = y * r * speed_mult
				
				local dist_factor = math.sqrt(x*x + y_pos*y_pos + z*z) / (radius * size_mult * 1.2)
				dist_factor = math.min(1.0, dist_factor)

				spawn_colored_particle_func({x = x, y = y_pos, z = z}, {
					no_wind = true,
					size_mult = 0.7 + dist_factor * 0.6,
					glow_mult = glow_mult
				})
			end
		end)
	end
	
	emit_perfect_sphere(0, 130, 1.0, 1.4, 1.2)
	emit_perfect_sphere(0.1, 110, 0.8, 1.2, 1.1)
	
	core.after(0.02, function()
		for ring = 1, 2 do
			core.after(ring * 0.09, function()
				local ring_radius = radius * (1.8 + ring * 0.6)
				local ring_count = 24
				
				for i = 1, ring_count do
					local theta = (i / ring_count) * math.pi * 2
					local tilt_angle = math.rad(math.random(15, 175))
					local r = ring_radius * (0.95 + math.random() * 0.1)
					local speed_mult = 1.3 + ring * 0.4
					
					local x = math.cos(theta) * math.sin(tilt_angle) * r * speed_mult
					local y = math.cos(tilt_angle) * r * speed_mult
					local z = math.sin(theta) * math.sin(tilt_angle) * r * speed_mult
					
					spawn_colored_particle_func({x = x, y = y, z = z}, {
						no_wind = true,
						size_mult = 0.5 + ring * 0.3,
						glow_mult = 1.3,
						lifetime_mult = 0.7
					})
				end
			end)
		end
	end)
end

local function spawn_star_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local star_rays = {
		{x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
		{x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0},
		{x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1},
		{x = 0.7, y = 0.7, z = 0}, {x = -0.7, y = -0.7, z = 0},
		{x = 0.7, y = -0.7, z = 0}, {x = -0.7, y = 0.7, z = 0},
		{x = 0.7, y = 0, z = 0.7}, {x = -0.7, y = 0, z = -0.7},
	}
	
	local ray_particles = 8
	for _, ray in ipairs(star_rays) do
		for i = 1, ray_particles do
			local distance = (i / ray_particles) * radius * (1.2 + math.random() * 0.6)
			local speed_mult = 1.5 - (i / ray_particles) * 0.8
			
			local velocity = {
				x = ray.x * distance * speed_mult,
				y = ray.y * distance * speed_mult,
				z = ray.z * distance * speed_mult
			}
			spawn_colored_particle_func(velocity)
		end
	end
	
	core.after(0.2, function()
		for _, ray in ipairs(star_rays) do
			local tip_pos = {
				x = ray.x * radius * 1.5,
				y = ray.y * radius * 1.5,
				z = ray.z * radius * 1.5
			}
			
			local sparkle_count = 5
			for i = 1, sparkle_count do
				local sparkle_velocity = {
					x = tip_pos.x + math.random(-100, 100) / 100,
					y = tip_pos.y + math.random(-100, 100) / 100,
					z = tip_pos.z + math.random(-100, 100) / 100
				}
				spawn_colored_particle_func(sparkle_velocity)
			end
		end
	end)
	
	core.after(2.5, function()
		for i = 1, 30 do
			local finale_angle = math.random() * math.pi * 2
			local finale_radius = radius * (1.5 + math.random())
			local finale_velocity = {
				x = math.cos(finale_angle) * finale_radius,
				y = math.random(2, 6),
				z = math.sin(finale_angle) * finale_radius
			}
			
			spawn_colored_particle_func(finale_velocity)
		end
	end)
end

local function spawn_ring_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local ring_layers = 3
	
	for layer = 1, ring_layers do
		core.after((layer - 1) * 0.08, function()
			local layer_radius = radius * (0.8 + layer * 0.4)
			local particles_count = 45
			
			for i = 1, particles_count do
				local theta = (i / particles_count) * math.pi * 2 + math.random(-5, 5) * math.pi / 180
				local r = layer_radius * (0.9 + math.random() * 0.2)
				local speed_mult = 1.2 + layer * 0.3
				
				local x = math.cos(theta) * r * speed_mult
				local z = math.sin(theta) * r * speed_mult
				local y = math.random(-30, 30) / 100
				
				spawn_colored_particle_func({x = x, y = y, z = z})
			end
			
			for i = 1, 8 do
				local sparkle_theta = math.random() * math.pi * 2
				local sparkle_r = layer_radius * (1.1 + math.random() * 0.3)
				local sparkle_velocity = {
					x = math.cos(sparkle_theta) * sparkle_r,
					y = math.random(-100, 100) / 100,
					z = math.sin(sparkle_theta) * sparkle_r
				}
				spawn_colored_particle_func(sparkle_velocity)
			end
		end)
	end
end

local function spawn_snowflake_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local arms = 6
	for i = 1, arms do
		local angle = (2 * math.pi / arms) * i
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		for j = 1, radius do
			spawn_colored_particle_func({x = x * (j / radius), y = 0, z = z * (j / radius)})
		end
	end
end

local function spawn_spiral_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local spiral_turns = math.random(3, 7)
	local particles_per_turn = math.random(55, 95)
	local total_spiral_particles = spiral_turns * particles_per_turn

	local upward_speed = 8 + math.random() * 6
	local tangential_speed = 16 + math.random() * 10

	local height = 45 + math.random() * 50
	local radius_growth = 0.15 + math.random() * 0.35
	local wobble_strength = math.random() * 1.2

	local bias = math.random() ^ 2
	local tilt_x = (bias * (math.random() - 0.5)) * (math.pi / 3)
	local tilt_z = (bias * (math.random() - 0.5)) * (math.pi / 3)

	local spin_dir = (math.random(2) == 1) and 1 or -1

	local cos_x = math.cos(tilt_x)
	local sin_x = math.sin(tilt_x)
	local cos_z = math.cos(tilt_z)
	local sin_z = math.sin(tilt_z)

	local function rotate_vector(v)
		local y = v.y * cos_x - v.z * sin_x
		local z = v.y * sin_x + v.z * cos_x
		v.y, v.z = y, z

		local x = v.x * cos_z - v.y * sin_z
		y = v.x * sin_z + v.y * cos_z
		v.x, v.y = x, y

		return v
	end

	for i = 1, total_spiral_particles do
		local progress = (i - 1) / (total_spiral_particles - 1)
		local angle = progress * spiral_turns * math.pi * 2 * spin_dir

		local current_radius = radius * (1 + progress * radius_growth)

		local wobble = math.sin(progress * math.pi * 4) * wobble_strength

		local pos_offset = {
			x = math.cos(angle) * (current_radius + wobble),
			y = (progress * height) - (height / 2),
			z = math.sin(angle) * (current_radius + wobble)
		}

		local tangent = {
			x = -math.sin(angle) * spin_dir,
			y = 0,
			z =  math.cos(angle) * spin_dir
		}

		pos_offset = rotate_vector(pos_offset)
		tangent = rotate_vector(tangent)

		local velocity = {
			x = tangent.x * tangential_speed + math.random(-60, 60) / 100,
			y = upward_speed + math.random(-40, 70) / 100,
			z = tangent.z * tangential_speed + math.random(-60, 60) / 100
		}

		local centripetal_strength = 4 + math.random() * 3
		local accel = {
			x = -math.cos(angle) * centripetal_strength,
			y = -4.5,
			z = -math.sin(angle) * centripetal_strength
		}

		accel = rotate_vector(accel)

		spawn_colored_particle_func(velocity, {
			no_wind = true,
			custom_accel = accel,
			pos_offset = pos_offset,
			size_mult = 0.6 + progress * 1.0,
			glow_mult = 1.0 + progress * 0.3
		})
	end

	core.after(0.35 + math.random() * 0.4, function()
		for i = 1, math.random(45, 85) do
			local burst_angle = math.random() * math.pi * 2
			local burst_radius = radius * (1.3 + math.random() * 1.1)
			local burst_height = math.random(-8, 8)

			local pos_off = {
				x = math.cos(burst_angle) * burst_radius,
				y = burst_height,
				z = math.sin(burst_angle) * burst_radius
			}
			pos_off = rotate_vector(pos_off)

			local vel = {
				x = pos_off.x * 0.08,
				y = burst_height + math.random(1, 5),
				z = pos_off.z * 0.08
			}

			local accel = {
				x = -pos_off.x * 0.03,
				y = -5.5,
				z = -pos_off.z * 0.03
			}

			spawn_colored_particle_func(vel, {
				no_wind = true,
				custom_accel = accel,
				pos_offset = pos_off,
				lifetime_mult = 0.75 + math.random() * 0.3,
				size_mult = 0.6 + math.random() * 0.5,
				glow_mult = 1.2
			})
		end
	end)
end

local function spawn_hour_glass_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local num_turns = 10
	for i = 1, 360 * num_turns, 15 do
		local theta = math.rad(i)
		local y = (i / 360) * num_turns
		local radius = 10 - (y / 2)
		local x = math.cos(theta) * radius
		local z = math.sin(theta) * radius
		spawn_colored_particle_func({x = x, y = y, z = z})
	end
end

local function spawn_burst_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local base_props = {
		amount = 600,
		time = 0.01,
		pos = pos,
		radius = { min = 2, max = 3, bias = -10000 },
		drag_tween = {
			{x=1.0, y=1.0, z=1.0},
			{x=3.0, y=1.0, z=3.0},
		},
		minvel = { x= -4 , y=5, z= -4},
		maxvel = { x=4, y=5, z=4},
		attract = {
			kind = 'point',
			strength = { min = -11.0, max = -14.5 },
			origin = pos,
			direction = vector.new(0,-1,0),
		},
		acc = { x = 0, y = -19.81, z = 0 },
		collisiondetection = false,
		collision_removal = false,
		glow = 14,
	}

	local variations = fireworks_reimagined.get_particle_variations(color_def, color_def_2, alpha)

	for _, key in ipairs({"spark_props", "break_props1", "break_props"}) do
		local props = table.copy(base_props)
		for k,v in pairs(variations[key]) do
			props[k] = v
		end

		if key == "spark_props" then
			for _, player_name in ipairs(eligible_players) do
				props.playername = player_name
				core.add_particlespawner(props)
			end
		else
			core.after(0.75, function()
				for _, player_name in ipairs(eligible_players) do
					props.playername = player_name
					core.add_particlespawner(props)
				end
			end)
		end
	end
end

local function spawn_chaotic_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local total_particles = math.random(250, 350)
	local chaos_type = math.random(1, 5)
	
	if chaos_type == 1 then
		for i = 1, total_particles do
			local angle = math.random() * math.pi * 2
			local tilt = math.random() * math.pi
			local speed = math.random(2, 10)
			local vx = math.cos(angle) * math.sin(tilt) * speed
			local vy = math.cos(tilt) * speed + math.random(-4, 4)
			local vz = math.sin(angle) * math.sin(tilt) * speed
			spawn_colored_particle_func({x = vx, y = vy, z = vz})
		end
	elseif chaos_type == 2 then
		for i = 1, total_particles do
			local r = math.random() * radius * 2
			local angle = math.random() * math.pi * 2
			local vx = math.cos(angle) * r + math.random(-8, 8)
			local vy = math.random(-10, 10)
			local vz = math.sin(angle) * r + math.random(-8, 8)
			spawn_colored_particle_func({x = vx, y = vy, z = vz})
		end
	elseif chaos_type == 3 then
		local waves = math.random(8, 15)
		for wave = 1, waves do
			core.after(math.random(0, 300) / 1000, function()
				local particles_this_wave = math.floor(total_particles / waves)
				for i = 1, particles_this_wave do
					local vx = (math.random() - 0.5) * math.random(4, 12)
					local vy = (math.random() - 0.5) * math.random(4, 12)
					local vz = (math.random() - 0.5) * math.random(4, 12)
					spawn_colored_particle_func({x = vx, y = vy, z = vz})
				end
			end)
		end
	elseif chaos_type == 4 then
		for i = 1, total_particles do
			local fx = math.sin(i * 0.01) * 10
			local fy = math.cos(i * 0.02) * 10 + math.random(-5, 10)
			local fz = math.sin(i * 0.015) * 10
			spawn_colored_particle_func({x = fx, y = fy, z = fz})
		end
	else
		for i = 1, total_particles do
			local vx = (math.random() * 2 - 1) * math.random(1, 12)
			local vy = (math.random() * 2 - 1) * math.random(1, 12)
			local vz = (math.random() * 2 - 1) * math.random(1, 12)
			spawn_colored_particle_func({x = vx, y = vy, z = vz})
		end
	end
end

local function spawn_flame_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local flame_height = 15
	local base_radius = 5
	local flame_stages = 4
	
	for stage = 1, flame_stages do
		core.after((stage - 1) * 0.05, function()
			local stage_particles = 100 - stage * 15
			local stage_height = flame_height * (1 + stage * 0.2)
			local stage_radius = base_radius * (1.2 - stage * 0.1)
			
			for i = 1, stage_particles do
				local theta = math.rad(math.random(360))
				local r = math.random() * stage_radius * (0.7 + math.random() * 0.5)
				local height = math.random() * stage_height
				
				local height_factor = math.max(0.1, 1 - math.pow(height / stage_height, 1.5) * 0.8)
				r = r * height_factor
				
				local turbulence = math.sin(height * 0.5) * 0.3 + math.random(-20, 20) / 100
				local x = math.cos(theta) * r + turbulence
				local z = math.sin(theta) * r + turbulence
				local y = height
				
				local velocity = {
					x = x * 0.8 + math.random(-80, 80) / 100,
					y = y * 0.6 + math.random(200, 500) / 100,
					z = z * 0.8 + math.random(-80, 80) / 100
				}
				
				spawn_colored_particle_func(velocity)
			end
		end)
	end
	
	core.after(0.1, function()
		for i = 1, 30 do
			local theta = math.rad(math.random(360))
			local r = math.random() * base_radius * 0.5
			local x = math.cos(theta) * r
			local z = math.sin(theta) * r
			local y = flame_height + math.random(0, 3)
			
			local flicker_velocity = {
				x = x + math.random(-200, 200) / 100,
				y = y + math.random(200, 500) / 100,
				z = z + math.random(-200, 200) / 100
			}
			
			spawn_colored_particle_func(flicker_velocity)
		end
	end)
	
	core.after(0.2, function()
		for i = 1, 20 do
			local spark_velocity = {
				x = math.random(-6, 6),
				y = math.random(2, 8),
				z = math.random(-6, 6)
			}
			spawn_colored_particle_func(spark_velocity)
		end
	end)
end

fireworks_reimagined.register_shape_function = function(name, func)
	fireworks_reimagined.shape_functions[name] = func
end

fireworks_reimagined.register_shape_function("sphere", spawn_sphere_shape)
fireworks_reimagined.register_shape_function("star", spawn_star_shape)
fireworks_reimagined.register_shape_function("ring", spawn_ring_shape)
fireworks_reimagined.register_shape_function("snowflake", spawn_snowflake_shape)
fireworks_reimagined.register_shape_function("spiral", spawn_spiral_shape)
fireworks_reimagined.register_shape_function("hour_glass", spawn_hour_glass_shape)
fireworks_reimagined.register_shape_function("burst", spawn_burst_shape)
fireworks_reimagined.register_shape_function("chaotic", spawn_chaotic_shape)
fireworks_reimagined.register_shape_function("flame", spawn_flame_shape)
