local function spawn_sphere_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local golden_angle = math.pi * (3 - math.sqrt(5))

	local petals = 10
	local petal_strength = 0.42
	local petal_sharpness = 1.25

	-- Generates a spherical layer with pronounced flower-shaped expansion.
	local function emit_bloom_shell(num_particles, size_mult, speed_mult, twist_strength, lifetime_mult, accel_mult, glow_mult)
		for i = 0, num_particles - 1 do
			local y = 1 - (i / (num_particles - 1)) * 2
			local horizontal = math.sqrt(1 - y * y)

			local base_theta = golden_angle * i

			-- Pronounced ten-petal geometry.
			local petal_wave = math.cos(base_theta * petals)
			local shaped_petal = (petal_wave < 0 and -1 or 1)
				* math.abs(petal_wave) ^ petal_sharpness

			local radial_mult = 1.0 + shaped_petal * petal_strength

			-- Subtle shell-specific rotation.
			local twist = math.sin(base_theta * 2 + y * math.pi)
				* twist_strength

			local theta = base_theta + twist

			-- Slight organic variation without destroying symmetry.
			local variation = 0.97 + math.random() * 0.06
			local r = radius * size_mult * radial_mult * variation

			-- Spherical direction.
			local dir_x = math.cos(theta) * horizontal
			local dir_z = math.sin(theta) * horizontal
			local dir_y = y

			-- Petal tips travel considerably faster than the valleys.
			local petal_speed = 1.0 + shaped_petal * 0.32

			-- Slight tangential velocity gives the petals rotational character.
			local tangential_speed = radius * size_mult * twist_strength * 0.12

			local velocity = {
				x = dir_x * r * speed_mult * petal_speed
					- math.sin(theta) * tangential_speed,

				y = dir_y * r * speed_mult * petal_speed
					+ radius * size_mult * 0.12,

				z = dir_z * r * speed_mult * petal_speed
					+ math.cos(theta) * tangential_speed
			}

			local dist_factor = math.sqrt(
				velocity.x * velocity.x
				+ velocity.y * velocity.y
				+ velocity.z * velocity.z
			) / (radius * size_mult * 1.8)

			dist_factor = math.min(1.0, dist_factor)

			spawn_colored_particle_func({
				x = velocity.x,
				y = velocity.y,
				z = velocity.z
			}, {
				no_wind = true,
				size_mult = 0.75 + dist_factor * 0.85,
				glow_mult = glow_mult,
				lifetime_mult = lifetime_mult * (0.95 + math.random() * 0.15),
				accel_mult = accel_mult
			})
		end
	end

	-- Main bloom: all three layers emitted together.
	core.after(0, function()
		-- Large outer petals.
		emit_bloom_shell(
			90,
			2.0,
			1.25,
			0.18,
			1.45,
			0.72,
			1.35
		)

		-- Interwoven middle layer.
		emit_bloom_shell(
			80,
			1.35,
			1.15,
			-0.14,
			1.2,
			0.9,
			1.2
		)

		-- Dense inner spherical core.
		emit_bloom_shell(
			70,
			0.8,
			1.05,
			0.10,
			0.95,
			1.0,
			1.1
		)
	end)

	-- Large intersecting geometric rings.
	core.after(0.12, function()
		for ring = 1, 2 do
			local ring_radius = radius * (1.9 + ring * 0.55)
			local ring_count = 24

			local tilt_angle = math.rad(35 + ring * 55)
			local cos_tilt = math.cos(tilt_angle)
			local sin_tilt = math.sin(tilt_angle)

			-- Offset the two rings to create an interlocking appearance.
			local ring_offset = ring * math.pi / 8

			for i = 1, ring_count do
				local theta = (i / ring_count) * math.pi * 2 + ring_offset

				local petal_wave = math.cos(theta * petals + ring * math.pi / 2)
				local radial_mult = 1.0 + petal_wave * 0.18

				local r = ring_radius * radial_mult
					* (0.97 + math.random() * 0.06)

				local speed_mult = 1.3 + ring * 0.15

				local velocity = {
					x = math.cos(theta) * r * speed_mult,
					y = math.sin(theta) * cos_tilt * r * speed_mult
						+ radius * 0.08,
					z = math.sin(theta) * sin_tilt * r * speed_mult
				}

				spawn_colored_particle_func({
					x = velocity.x,
					y = velocity.y,
					z = velocity.z
				}, {
					no_wind = true,
					size_mult = 0.65 + ring * 0.3,
					glow_mult = 1.4,
					lifetime_mult = 1.15,
					accel_mult = 0.8
				})
			end
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
					x = ray.x * 0.6 + math.random(-40, 40) / 100,
					y = ray.y * 0.6 + math.random(-40, 40) / 100,
					z = ray.z * 0.6 + math.random(-40, 40) / 100
				}
				spawn_colored_particle_func(sparkle_velocity, {
					no_wind = true,
					pos_offset = tip_pos,
					size_mult = 0.6,
					glow_mult = 1.2,
					lifetime_mult = 0.5,
				})
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
			local layer_radius = radius * (0.8 + layer * 0.8)
			local particles_count = 90
			
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
	local arm_particles = 10
	local branch_slope = 0.7

	for i = 1, arms do
		local angle = (2 * math.pi / arms) * (i - 1)
		local dir_x, dir_z = math.cos(angle), math.sin(angle)
		local perp_x, perp_z = -dir_z, dir_x

		for j = 1, arm_particles do
			local t = j / arm_particles
			local distance = radius * t
			local speed = 0.8 + (1 - t) * 0.6
			local size_mult = 0.5 + (1 - t) * 0.9

			spawn_colored_particle_func({
				x = dir_x * distance * speed,
				y = math.random(-20, 20) / 100,
				z = dir_z * distance * speed,
			}, {
				no_wind = true,
				size_mult = size_mult,
				lifetime_mult = 0.8 + t * 0.4,
			})

			-- Two pairs of side branches, like a real snow crystal.
			if j == math.floor(arm_particles / 3) or j == math.floor(2 * arm_particles / 3) then
				for sign = -1, 1, 2 do
					local branch_x = dir_x + perp_x * sign * branch_slope
					local branch_z = dir_z + perp_z * sign * branch_slope
					local norm = math.sqrt(branch_x * branch_x + branch_z * branch_z)
					branch_x, branch_z = branch_x / norm, branch_z / norm
					local branch_length = distance * 0.45

					for k = 1, 3 do
						local bt = k / 3
						spawn_colored_particle_func({
							x = (dir_x * distance + branch_x * branch_length * bt) * speed,
							y = math.random(-20, 20) / 100,
							z = (dir_z * distance + branch_z * branch_length * bt) * speed,
						}, {
							no_wind = true,
							size_mult = 0.3 + (1 - bt) * 0.3,
							lifetime_mult = 0.6,
						})
					end
				end
			end
		end
	end

	-- Central crystal core.
	for _ = 1, 20 do
		local theta = math.random() * math.pi * 2
		local phi = math.acos(2 * math.random() - 1)
		local r = math.random() * radius * 0.25
		spawn_colored_particle_func({
			x = math.sin(phi) * math.cos(theta) * r,
			y = math.cos(phi) * r,
			z = math.sin(phi) * math.sin(theta) * r,
		}, {
			no_wind = true,
			size_mult = 1.4,
			lifetime_mult = 0.5,
			glow_mult = 1.2,
		})
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
	local particles_per_turn = 12
	local total_particles = num_turns * particles_per_turn

	local upward_speed = 7 + math.random() * 4
	local tangential_speed = 11 + math.random() * 5
	local outward_speed = 3 + math.random() * 2
	local spin_dir = (math.random(2) == 1) and 1 or -1

	local max_height = 35 + math.random() * 15

	local end_radius = radius * 1.8
	local waist_radius = radius * 0.12

	for i = 1, total_particles do
		local progress = (i - 1) / (total_particles - 1)

		local angle = progress * num_turns * math.pi * 2

		local shape_progress = math.abs(progress * 2 - 1)

		local current_radius = waist_radius
			+ (end_radius - waist_radius) * (shape_progress ^ 1.5)

		local y = (progress - 0.5) * max_height * 2

		local cos_a = math.cos(angle)
		local sin_a = math.sin(angle)

		local radial_x = cos_a
		local radial_z = sin_a

		for side = 1, 2 do
			local direction = (side == 1) and 1 or -1
			local side_spin = spin_dir * direction

			local pos_offset = {
				x = radial_x * current_radius,
				y = y * direction,
				z = radial_z * current_radius
			}

			local tangent_x = -sin_a * side_spin
			local tangent_z = cos_a * side_spin

			local radius_factor = (current_radius - waist_radius)
				/ (end_radius - waist_radius)

			local velocity_factor = 0.25 + 0.75 * (radius_factor ^ 0.8)

			local local_tangential_speed =
				tangential_speed * velocity_factor

			local local_outward_speed =
				outward_speed * (radius_factor ^ 0.7)

			local velocity = {
				x = tangent_x * local_tangential_speed
					+ radial_x * local_outward_speed
					+ math.random(-30, 30) / 100,

				y = direction * (upward_speed * 0.65)
					+ math.random(-40, 40) / 100,

				z = tangent_z * local_tangential_speed
					+ radial_z * local_outward_speed
					+ math.random(-30, 30) / 100
			}

			local centripetal_strength =
				(local_tangential_speed * local_tangential_speed)
				/ math.max(current_radius, 0.1) * 0.012

			local accel = {
				x = -radial_x * centripetal_strength,
				y = -direction * 1.5,
				z = -radial_z * centripetal_strength
			}

			spawn_colored_particle_func(velocity, {
				no_wind = true,
				custom_accel = accel,
				pos_offset = pos_offset,
				size_mult = 0.7 + radius_factor * 0.6,
				glow_mult = 1.0 + radius_factor * 0.4
			})
		end
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
		minvel = { x= -8 , y=10, z= -8},
		maxvel = { x=8, y=10, z=8},
		attract = {
			kind = 'point',
			strength = { min = -11.0, max = math.random(-30.5, -10.5) },
			origin = pos,
			direction = vector.new(0,-1,0),
		},
		acc = { x = 0, y = -19.81, z = 0 },
		collisiondetection = false,
		collision_removal = false,
		glow = 14,
		blend = "add",
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
			core.after(0.05, function()
				for _, player_name in ipairs(eligible_players) do
					props.playername = player_name
					core.add_particlespawner(props)
				end
			end)
		end
	end
end

local function spawn_chaotic_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local variations = fireworks_reimagined.get_particle_variations(color_def, color_def_2, alpha)
	local sub_explosions = math.random(13, 18)

	for i = 1, sub_explosions do
		local offset = {
			x = math.random(-radius * 4.0, radius * 4.0),
			y = math.random(-radius * 3.0, radius * 3.0),
			z = math.random(-radius * 4.0, radius * 4.0)
		}
		local sub_pos = vector.add(pos, offset)
		local delay = math.random() * 0.8
		
		core.after(delay, function()
			core.sound_play("fireworks_explosion", {
				pos = sub_pos,
				max_hear_distance = 140,
				gain = 6.0,
				pitch = 1.6 + math.random() * 0.4
			})

			local base_sub_props = {
				amount = 15,
				time = 0.01,
				pos = sub_pos,
				radius = { min = 2, max = 3, bias = -10000 },
				drag_tween = {
					{x=1.0, y=1.0, z=1.0},
					{x=3.0, y=1.0, z=3.0},
				},
				minvel = { x= -8 , y=10, z= -8},
				maxvel = { x=8, y=10, z=8},
				attract = {
					kind = 'point',
					strength = { min = -12.0, max = -18.5 },
					origin = sub_pos,
					direction = vector.new(0,-1,0),
				},
				acc = { x = 0, y = -19.81, z = 0 },
				collisiondetection = false,
				collision_removal = false,
				glow = 14,
				blend = "add",
			}


			for _, key in ipairs({"spark_props", "break_props1", "break_props"}) do
				local props = table.copy(base_sub_props)
				local var = variations[key]
				props.texpool = var.texpool
				props.minsize = var.size * 1.05
				props.maxsize = var.size * 1.8
				
				if key == "spark_props" then
					for _, player_name in ipairs(eligible_players) do
						props.playername = player_name
						core.add_particlespawner(props)
					end
				else
					core.after(0.05, function()
						for _, player_name in ipairs(eligible_players) do
							props.playername = player_name
							core.add_particlespawner(props)
						end
					end)
				end
			end
		end)
	end
end

local function spawn_flame_shape(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)
	local flame_height = math.max(3, radius * 2.2)
	local base_radius = math.max(1.2, radius * 0.7)
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