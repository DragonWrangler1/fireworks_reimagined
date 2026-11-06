local function parse_version(str)
	str = tostring(str or "0.0"):match("(%d+%.%d+)") or "0.0"
	local major, minor = str:match("^(%d+)%.(%d+)")
	return tonumber(major) or 0, tonumber(minor) or 0
end

local function validate_version(major, minor)
	return (major > 5) or (major == 5 and minor >= 14)
end

-- Server grabs its own version as well as every client's version
local function get_eligible_players()
	local eligible_players = {}
	local old_client = {}

	-- Server version check.
	local server_major, server_minor = parse_version(
		(core.get_version() or {}).string
	)
	local valid_server = validate_version(server_major, server_minor)

	for _, player in ipairs(core.get_connected_players()) do
		--core.get_version() grabs only the server version, hence the reason I have looped through the players, that way I can get their metadata and extract the client version... Hopefully this can filter properly.
		local name = player:get_player_name()

		if not valid_server then
			old_client[#old_client + 1] = name
		else
			local info = core.get_player_information(name) or {}
			local major, minor = parse_version(info.version_string)

			if validate_version(major, minor) then
				eligible_players[#eligible_players + 1] = name
			else
				old_client[#old_client + 1] = name
			end
		end
	end

	return eligible_players, old_client
end

-- This is here as to not duplicate the Burst firework defs with the pre 5.14 user defs.
local function get_particle_variations(color_def, color_def_2, alpha)
	color_def_2 = color_def_2 or color_def

	local function spark_tween()
		return { style = "fwd", reps = 1, 1.4, 1.0, 0.2, start = 0.0, finish = 1.0 }
	end

	return {
		spark_props = {
			texpool = {
				{
					name = "fireworks_spark_white.png^[colorize:" .. color_def .. ":" .. alpha,
					scale_tween = spark_tween(),
				},
				{
					name = "fireworks_spark_white.png^[colorize:" .. color_def_2 .. ":" .. alpha,
					scale_tween = spark_tween(),
				},
				{
					name = "fireworks_enhanced_spark.png^[colorize:" .. color_def .. ":" .. alpha,
					scale_tween = spark_tween(),
				},
				{
					name = "fireworks_enhanced_spark.png^[colorize:" .. color_def_2 .. ":" .. alpha,
					scale_tween = spark_tween(),
				},
				{
					name = "fireworks_sparkle_enhanced.png^[colorize:" .. color_def .. ":" .. alpha,
					scale_tween = spark_tween(),
				},
				{
					name = "fireworks_sparkle_enhanced.png^[colorize:" .. color_def_2 .. ":" .. alpha,
					scale_tween = spark_tween(),
				},
			},
			size = math.random(2,4) * (0.9 + math.random() * 0.6),
			exptime = 3
		},
		break_props = {
			texpool = {
				{
					name = "fireworks_spark_white.png^[colorize:" .. color_def .. ":200",
					scale_tween = { style="fwd", reps=1, 1.0, 0.5, 0.0, start=0.0, finish=1.0 }
				},
				{
					name = "fireworks_spark_white.png^[colorize:" .. color_def_2 .. ":200",
					scale_tween = { style="fwd", reps=1, 1.0, 0.5, 0.0, start=0.0, finish=1.0 }
				}
			},
			size = math.random(2,4) * (0.9 + math.random() * 0.6) * 0.7,
			exptime = 2.25
		},
		break_props1 = {
			texpool = {
				{
					name = "fireworks_sparkle_enhanced.png^[colorize:" .. color_def .. ":100",
					scale_tween = { style="fwd", reps=1, 2.0, 0.5, 0.0, start=0.0, finish=1.0 }
				},
				{
					name = "fireworks_sparkle_enhanced.png^[colorize:" .. color_def_2 .. ":100",
					scale_tween = { style="fwd", reps=1, 2.0, 0.5, 0.0, start=0.0, finish=1.0 }
				}
			},
			size = math.random(2,4) * (0.9 + math.random() * 0.6) * 2.5,
			exptime = 1
		},
	}
end

local function spawn_colored_particle(pos, color_def, color_def_2, explosion_colors, alpha, texture, size, glow, eligible_players, velocity, opts)
	opts = opts or {}
	
	local color
	local colored_texture
	local wind_effect = {x = 0, y = 0, z = 0}
	
	if math.random(2) == 1 then
		color = color_def
	else
		color = color_def_2
	end

	if texture then
		colored_texture = texture.."^[colorize:" .. color .. ":" .. alpha
	else
		local particle_types = {"default", "sparkle", "smoke"}
		local random_type = particle_types[math.random(#particle_types)]
		colored_texture = fireworks_reimagined.get_enhanced_particle_texture(color, alpha, random_type)
	end
	
	if not opts.no_wind then
		wind_effect = {
			x = math.sin(core.get_gametime() * 0.5) * 0.3,
			y = 0,
			z = math.cos(core.get_gametime() * 0.3) * 0.2
		}
	end
	
	local particle_velocity = {
		x = velocity.x + (opts.no_wind and 0 or math.random(-120, 120) / 100) + wind_effect.x,
		y = velocity.y + (opts.no_wind and 0 or math.random(-60, 120) / 100),
		z = velocity.z + (opts.no_wind and 0 or math.random(-120, 120) / 100) + wind_effect.z
	}
	
	local lifetime_mult = opts.lifetime_mult or 1.0
	local base_lifetime = math.random(2, 4) * lifetime_mult
	
	local size_mult = opts.size_mult or 1.0
	local enhanced_size = size * size_mult * (0.9 + math.random() * 0.6)
	
	local glow_mult = opts.glow_mult or 1.0
	local base_glow = math.floor(glow * glow_mult)
	
	local acceleration
	if opts.custom_accel then
		acceleration = opts.custom_accel
	else
		local accel_mult = opts.accel_mult or 1.0
		acceleration = {
			x = particle_velocity.x * -0.06 * accel_mult,
			y = (-9.81 + math.random(-100, 100) / 1000) * accel_mult,
			z = particle_velocity.z * -0.06 * accel_mult
		}
	end
	
	local spawn_pos = pos
	if opts.pos_offset then
		spawn_pos = {
			x = pos.x + opts.pos_offset.x,
			y = pos.y + opts.pos_offset.y,
			z = pos.z + opts.pos_offset.z
		}
	end

	local effect_time = base_lifetime * 0.25
	local effect_pos = {
		x = spawn_pos.x + particle_velocity.x * effect_time + 0.5 * acceleration.x * effect_time * effect_time,
		y = spawn_pos.y + particle_velocity.y * effect_time + 0.5 * acceleration.y * effect_time * effect_time,
		z = spawn_pos.z + particle_velocity.z * effect_time + 0.5 * acceleration.z * effect_time * effect_time,
	}

	local particle_properties = {
		pos = spawn_pos,
		velocity = particle_velocity,
		acceleration = acceleration,
		expirationtime = base_lifetime,
		size = enhanced_size,
		texture = {
			name = colored_texture,
			scale_tween = {
				style = "fwd",
				reps = 1,
				1.4,
				1.0,
				0.2,
				start = 0.0,
				finish = 1.0
			},
			alpha_tween = {
				style = "fwd",
				reps = 1,
				1.0,
				0.8,
				0,
				start = 0.0,
				finish = 1.0
			}
		},
		glow = math.min(14, math.max(0, base_glow)),
		blend = "add",
	}
	for _, player_name in ipairs(eligible_players) do
		particle_properties.playername = player_name
		core.add_particle(particle_properties)
	end
	
	core.after(effect_time, function()
		local cloud_props = {
			pos = effect_pos,
			velocity = {x = 0, y = 0, z = 0},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = 0.1,
			size = enhanced_size * 2.5,
			texture = {
				name = "fireworks_sparkle_enhanced.png^[colorize:" .. color .. ":100",
				scale_tween = {
					style = "fwd",
					reps = 1,
					2.0,
					0.0,
					-0.1
				}
			},
			glow = 14,
			blend = "add",
			collisiondetection = false,
		}
		for _, player_name in ipairs(eligible_players) do
			cloud_props.playername = player_name
			core.add_particle(cloud_props)
		end
		
		local break_count = math.random(2, 3)
		for i = 1, break_count do
			local breaking_velocity = {
				x = particle_velocity.x * 0.5 + math.random(-250, 250) / 100,
				y = particle_velocity.y * 0.4 - 2 + math.random(-150, 150) / 100,
				z = particle_velocity.z * 0.5 + math.random(-250, 250) / 100
			}
			
			local breaking_particle_properties = {
				pos = effect_pos,
				velocity = breaking_velocity,
				acceleration = acceleration,
				expirationtime = base_lifetime * 0.75,
				size = enhanced_size * 0.7,
				texture = {
					name = colored_texture,
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.5,
						0.0
					},
				},
				glow = math.min(14, math.max(0, glow - 2)),
				blend = "add",
			}
			for _, player_name in ipairs(eligible_players) do
				breaking_particle_properties.playername = player_name
				core.add_particle(breaking_particle_properties)
			end
			
			local spark_props = {
				pos = effect_pos,
				velocity = {
					x = math.random(-100, 100) / 100,
					y = math.random(-50, 50) / 100,
					z = math.random(-100, 100) / 100
				},
				acceleration = acceleration,
				expirationtime = math.random(80, 160) / 100,
				size = enhanced_size * 0.3,
				texture = {
					name = "fireworks_spark_white.png^[colorize:" .. color .. ":200",
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.0,
						-0.05
					},
				},
				glow = 14,
				blend = "add",
			}
			for _, player_name in ipairs(eligible_players) do
				spark_props.playername = player_name
				core.add_particle(spark_props)
			end
		end
	end)
end

fireworks_reimagined.shape_functions = {}

function fireworks_reimagined.spawn_firework_explosion(pos, shape, double, color_def, color_def_2, alpha, texture, psize)
	-- `double` is kept for backwards compatibility but no longer has any effect.
	local fallback_color = "#FFFFFF"
	color_def = color_def or fallback_color
	color_def_2 = color_def_2 or color_def
	shape = shape or "sphere"
	alpha = tonumber(alpha) or 128

	local radius = math.random(4, 7)
	local size = psize or math.random(2, 4)
	local glow = math.min(14, math.random(12, 15))

	local eligible_players, old_client = get_eligible_players()

	-- Burst and chaotic already spawn through core.add_particlespawner, which
	-- older clients can render, so treat every player as eligible for those
	-- two shapes instead of leaving them out of the shape spawner.
	local shape_players = eligible_players
	if shape == "burst" or shape == "chaotic" then
		shape_players = {}
		for _, player_name in ipairs(eligible_players) do
			shape_players[#shape_players + 1] = player_name
		end
		for _, player_name in ipairs(old_client) do
			shape_players[#shape_players + 1] = player_name
		end
	end

	local spawn_colored_particle_wrapper = function(velocity, opts)
		return spawn_colored_particle(pos, color_def, color_def_2, nil, alpha, texture, size, glow, eligible_players, velocity, opts)
	end

	local initial_cloud = {
		pos = pos,
		velocity = {x = 0, y = 0, z = 0},
		acceleration = {x = 0, y = 0, z = 0},
		expirationtime = 0.15,
		size = radius * 3,
		texture = {
			name = "fireworks_sparkle_enhanced.png^[colorize:" .. color_def .. ":80",
			scale_tween = {
				style = "fwd",
				reps = 1,
				3.0,
				1.0,
				0.0
			},
			alpha_tween = {
				style = "fwd",
				reps = 1,
				1.0,
				0.4,
				0.0
			}
		},
		glow = 14,
		blend = "add",
		collisiondetection = false,
	}
	for _, player_name in ipairs(eligible_players) do
		initial_cloud.playername = player_name
		core.add_particle(initial_cloud)
	end

	local shape_spawner = fireworks_reimagined.shape_functions[shape]
	if not shape_spawner then
		core.log("warning", "[fireworks_reimagined] Unknown firework shape '" .. tostring(shape) .. "'; using sphere.")
		shape_spawner = fireworks_reimagined.shape_functions.sphere
	end
	if shape_spawner then
		shape_spawner(pos, radius, size, glow, shape_players, color_def, color_def_2, nil, alpha, texture, spawn_colored_particle_wrapper)
	end

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
		blend = "add",
	}


	if shape ~= "burst" and shape ~= "chaotic" then
		local variations = get_particle_variations(color_def, color_def_2, alpha)
		for _, player_name in ipairs(old_client) do
			for _, key in ipairs({"spark_props", "break_props1", "break_props"}) do
				local props = table.copy(base_props)
				for k,v in pairs(variations[key]) do
					props[k] = v
				end
				props.playername = player_name

				if key == "spark_props" then
					core.add_particlespawner(props)
				else
					core.after(0.25, function()
						core.add_particlespawner(props)
					end)
				end
			end
		end
	end
end

fireworks_reimagined.get_particle_variations = get_particle_variations

return {
	spawn_firework_explosion = fireworks_reimagined.spawn_firework_explosion,
}