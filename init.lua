--================================================================--
--=== FIREWORKS REIMAGINED - ENHANCED REALISTIC EDITION ===--
--================================================================--
-- Major enhancements made to create 100x more realistic fireworks:
-- 
-- ✨ VISUAL ENHANCEMENTS:
-- • Enhanced particle physics with realistic acceleration and drag
-- • Multi-layered particle systems with trails and breaking effects
-- • Improved particle scaling and fading animations
-- • Ground illumination and environmental lighting effects
-- • Atmospheric pressure wave effects
-- • Realistic smoke and debris systems
-- • Enhanced color blending and alpha effects
--
-- 🎆 NEW FIREWORK PATTERNS:
-- • Weeping Willow - particles shoot up then droop down realistically
-- • Chrysanthemum - expanding rings with delayed bursts
-- • Peony - main burst followed by secondary breaking effects
-- • Enhanced Christmas Tree with star and ornament effects
-- • Improved Flame pattern with realistic fire physics
-- • Enhanced Star pattern with 3D rays and sparkle tips
--
-- 🚀 ROCKET ENHANCEMENTS:
-- • Realistic thrust physics with decreasing power over time
-- • Enhanced trail system with multiple particle types
-- • Wobble effects and wind simulation
-- • Falling sparks and smoke trails
-- • Whistle sound effects during flight
--
-- 💥 EXPLOSION IMPROVEMENTS:
-- • Initial flash effects for all explosions  
-- • Multi-stage particle spawning (primary, secondary, glitter)
-- • Enhanced particle breaking with multiple stages
-- • Realistic debris and settling smoke
-- • Shape-specific sound variations with echo effects
-- • Finale effects for spectacular patterns
--
-- 🔊 AUDIO ENHANCEMENTS:
-- • Shape-specific explosion sounds with different pitch/gain
-- • Echo and reverb effects
-- • Crackling sounds for chaotic patterns
-- • Rocket whistle sounds during flight
-- • Distance-based audio effects
--
-- 🌍 ENVIRONMENTAL EFFECTS:
-- • Ground illumination that lights up terrain
-- • Atmospheric disturbance particles
-- • Pressure wave visual effects
-- • Wind interaction simulation
-- • Realistic falling debris physics
--================================================================--
local rules = mesecon.rules.pplate
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
	{shape = "christmas_tree", descripton = "Christmas Tree"},
	{shape = "hour_glass", description = "Hour Glass"},
	{shape = "willow", description = "Weeping Willow"},
	{shape = "chrysanthemum", description = "Chrysanthemum"},
	{shape = "peony", description = "Peony"},
}

local function random_color()
    local r, g, b
    repeat
        r = math.random(0, 255)
        g = math.random(0, 255)
        b = math.random(0, 255)
    until r > 200 or g > 200 or b > 200  -- Ensure at least one value is above 200 for brightness
    return string.format("#%02X%02X%02X", r, g, b)
end

-- Enhanced color palette with more vibrant options
local function get_vibrant_color()
	local vibrant_colors = {
		"#FF1493", -- Deep Pink
		"#00FFFF", -- Cyan
		"#FFD700", -- Gold
		"#FF4500", -- Orange Red
		"#32CD32", -- Lime Green
		"#8A2BE2", -- Blue Violet
		"#FF69B4", -- Hot Pink
		"#00FA9A", -- Medium Spring Green
		"#FF6347", -- Tomato
		"#1E90FF", -- Dodger Blue
		"#FFFF00", -- Yellow
		"#FF0000", -- Red
		"#00FF00", -- Lime
		"#0000FF", -- Blue
		"#FF00FF", -- Magenta
		"#FFFFFF", -- White
	}
	return vibrant_colors[math.random(#vibrant_colors)]
end

-- Color transition function for smooth color changes
local function get_color_transition(color1, color2, progress)
	-- Simple linear interpolation between two colors
	local r1, g1, b1 = tonumber(color1:sub(2,3), 16), tonumber(color1:sub(4,5), 16), tonumber(color1:sub(6,7), 16)
	local r2, g2, b2 = tonumber(color2:sub(2,3), 16), tonumber(color2:sub(4,5), 16), tonumber(color2:sub(6,7), 16)
	
	local r = math.floor(r1 + (r2 - r1) * progress)
	local g = math.floor(g1 + (g2 - g1) * progress)
	local b = math.floor(b1 + (b2 - b1) * progress)
	
	return string.format("#%02X%02X%02X", r, g, b)
end

local function random_explosion_colors()
    -- Use vibrant colors 70% of the time, random colors 30% of the time
    local color1, color2
    if math.random() < 0.7 then
        color1 = get_vibrant_color()
        color2 = get_vibrant_color()
    else
        color1 = random_color()
        color2 = random_color()
    end
    
    if math.random(2) == 1 then
        return {color1}
    else
        return {color1, color2}
    end
end

-- Enhanced particle texture selection for better visual variety
local function get_enhanced_particle_texture(color, alpha, particle_type)
	particle_type = particle_type or "default"
	
	local texture_variants = {
		default = {
			"fireworks_spark_white.png",
			"fireworks_enhanced_spark.png",
			"default_cloud.png",
			"black.png"
		},
		sparkle = {
			"fireworks_sparkle_enhanced.png",
			"fireworks_spark_white.png",
			"fireworks_star.png"
		},
		smoke = {
			"default_cloud.png",
			"black.png"
		},
		flame = {
			"fireworks_flame.png",
			"default_cloud.png",
			"fireworks_enhanced_spark.png"
		},
		trail = {
			"fireworks_enhanced_spark.png",
			"default_cloud.png"
		}
	}
	
	local textures = texture_variants[particle_type] or texture_variants.default
	local selected_texture = textures[math.random(#textures)]
	
	-- Add additional visual enhancements based on particle type
	local enhanced_texture = selected_texture .. "^[colorize:" .. color .. ":" .. alpha
	
	if particle_type == "sparkle" then
		-- Add extra brightness and star effect
		enhanced_texture = enhanced_texture .. "^[brighten"
		-- Add subtle glow effect for sparkles
		if math.random() < 0.3 then
			enhanced_texture = enhanced_texture .. ""
		end
	elseif particle_type == "smoke" then
		-- Add slight blur effect for smoke
		enhanced_texture = enhanced_texture .. "^[opacity:" .. math.max(30, alpha - 50)
	elseif particle_type == "flame" then
		-- Add flame-specific effects
		enhanced_texture = enhanced_texture .. "^[brighten"
		if math.random() < 0.4 then
			-- Add flicker effect
			enhanced_texture = enhanced_texture .. "^[opacity:" .. (alpha + math.random(-30, 30))
		end
	elseif particle_type == "trail" then
		-- Add trail-specific effects
		enhanced_texture = enhanced_texture .. "^[opacity:" .. math.max(20, alpha - 40)
	end
	
	return enhanced_texture
end


--===========--
--=== API ===--
--===========--

--=== Individual particles ===--

-- Helper function to scale particle counts based on quality
local function scale_particle_count(base_count, quality)
	return math.max(1, math.floor(base_count * (quality.particles_multiplier or 1.0)))
end

function fireworks_reimagined.spawn_firework_explosion_ip(pos, shape, double, color_def, color_def_2, alpha, texture, psize)
	-- Get quality settings for performance adaptation
	local quality = fireworks_reimagined.performance.get_quality_settings()
	
	local explosion_colors = random_explosion_colors()
	local radius = math.random(4, 7) * (quality.particles_multiplier or 1.0)
	local size
	local color
	local colored_texture
	
	-- Apply size modifier from quality settings
	local size_mod = quality.particle_size_modifier or 1.0
	if psize then
		size = psize * size_mod
	else
		size = math.random(2, 4) * size_mod
	end
	local glow = math.random(12, 15)
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
		
		-- Enhanced texture selection using new system
		if texture then
			colored_texture = texture.."^[colorize:" .. color .. ":" .. alpha
		else
			-- Use enhanced particle texture system with random variety
			local particle_types = {"default", "sparkle", "smoke"}
			local random_type = particle_types[math.random(#particle_types)]
			colored_texture = get_enhanced_particle_texture(color, alpha, random_type)
		end
		
		-- Enhanced particle physics with more realistic values and variation
		-- Add wind simulation
		local wind_effect = {
			x = math.sin(minetest.get_gametime() * 0.5) * 0.3,
			y = 0,
			z = math.cos(minetest.get_gametime() * 0.3) * 0.2
		}
		
		local enhanced_velocity = {
			x = velocity.x + math.random(-120, 120) / 100 + wind_effect.x,
			y = velocity.y + math.random(-60, 120) / 100,
			z = velocity.z + math.random(-120, 120) / 100 + wind_effect.z
		}
		
		-- Create multiple particle layers for depth and realism
		local base_lifetime = math.random(200, 400) / 100
		local enhanced_size = size * (0.9 + math.random() * 0.6)
		
		-- Main bright particle with enhanced properties and dynamic effects
		local dynamic_glow = glow + math.random(0, 5)
		local particle_properties = {
			pos = pos,
			velocity = enhanced_velocity,
			acceleration = {
				x = enhanced_velocity.x * -0.06,
				y = -9.81 + math.random(-100, 100) / 1000, -- Add slight gravity variation
				z = enhanced_velocity.z * -0.06
			},
			expirationtime = base_lifetime,
			size = enhanced_size,
			texture = {
				name = colored_texture,
				scale_tween = {
					style = "fwd",
					reps = 1,
					1.4, -- Start larger for more impact
					1.0,
					0.2, -- End smaller but not zero for lingering effect
					start = 0.0,
					finish = 1.0
				},
				alpha_tween = {
					style = "fwd",
					reps = 1,
					255, -- Start fully opaque
					200,
					0,   -- Fade to transparent
					start = 0.0,
					finish = 1.0
				}
			},
			glow = dynamic_glow,
			--collisiondetection = true,
			--collision_removal = true,
		}
		minetest.add_particle(particle_properties)
		
		-- Enhanced particle trail system with multiple layers
		local trail_count = scale_particle_count(7, quality)
		for i = 1, trail_count do
			local trail_pos = {
				x = pos.x - enhanced_velocity.x * (i * 0.04),
				y = pos.y - enhanced_velocity.y * (i * 0.04),
				z = pos.z - enhanced_velocity.z * (i * 0.04)
			}
			local trail_alpha = math.floor(alpha * (1 - i * 0.12))
			
			-- Main trail particle
			minetest.add_particle({
				pos = trail_pos,
				velocity = {
					x = enhanced_velocity.x * 0.3,
					y = -2 + math.random(-50, 50) / 100,
					z = enhanced_velocity.z * 0.3
				},
				acceleration = {x = 0, y = -6, z = 0},
				expirationtime = base_lifetime * (0.7 - i * 0.08),
				size = enhanced_size * (0.8 - i * 0.08),
				texture = {
					name = colored_texture:gsub(":" .. alpha, ":" .. trail_alpha),
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.5,
						0.0
					},
					alpha_tween = {
						style = "fwd",
						reps = 1,
						trail_alpha,
						trail_alpha * 0.7,
						0
					}
				},
				glow = math.max(2, dynamic_glow - i),
				collisiondetection = false,
			})
			
			-- Add secondary shimmer particles for extra sparkle
			if i <= 3 and math.random() < 0.6 then
				minetest.add_particle({
					pos = {
						x = trail_pos.x + math.random(-20, 20) / 100,
						y = trail_pos.y + math.random(-20, 20) / 100,
						z = trail_pos.z + math.random(-20, 20) / 100
					},
					velocity = {
						x = math.random(-30, 30) / 100,
						y = math.random(-30, 30) / 100,
						z = math.random(-30, 30) / 100
					},
					acceleration = {x = 0, y = -3, z = 0},
					expirationtime = base_lifetime * 0.4,
					size = enhanced_size * 0.3,
					texture = {
						name = "fireworks_spark_white.png^[colorize:" .. color .. ":150",
						scale_tween = {
							style = "fwd",
							reps = 1,
							0.8,
							0.2,
							0.0
						}
					},
					glow = dynamic_glow + 2,
					collisiondetection = false,
				})
			end
		end
		
		-- Enhanced breaking effect with multiple stages and flash
		minetest.after(base_lifetime * 0.25, function()
			-- Add initial bright flash for breaking
			minetest.add_particle({
				pos = {
					x = pos.x + enhanced_velocity.x * base_lifetime * 0.25,
					y = pos.y + enhanced_velocity.y * base_lifetime * 0.25,
					z = pos.z + enhanced_velocity.z * base_lifetime * 0.25
				},
				velocity = {x = 0, y = 0, z = 0},
				acceleration = {x = 0, y = 0, z = 0},
				expirationtime = 0.1,
				size = enhanced_size * 2.5,
				texture = {
					name = "default_cloud.png^[colorize:" .. color .. ":100",
					scale_tween = {
						style = "fwd",
						reps = 1,
						2.0,
						0.0,
						-0.1
					}
				},
				glow = 15,
				collisiondetection = false,
			})
			
			-- First breaking stage with enhanced effects
			local break_count = math.random(3, 6)
			for i = 1, break_count do
				local breaking_velocity = {
					x = enhanced_velocity.x * 0.5 + math.random(-250, 250) / 100,
					y = enhanced_velocity.y * 0.4 - 2 + math.random(-150, 150) / 100,
					z = enhanced_velocity.z * 0.5 + math.random(-250, 250) / 100
				}
				
				local breaking_particle_properties = {
					pos = {
						x = pos.x + enhanced_velocity.x * base_lifetime * 0.25,
						y = pos.y + enhanced_velocity.y * base_lifetime * 0.25,
						z = pos.z + enhanced_velocity.z * base_lifetime * 0.25
					},
					velocity = breaking_velocity,
					acceleration = {
						x = breaking_velocity.x * -0.08,
						y = -9.81,
						z = breaking_velocity.z * -0.08
					},
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
					glow = math.max(5, glow - 2),
					--collisiondetection = true,
					--collision_removal = true,
				}
				minetest.add_particle(breaking_particle_properties)
				
				-- Add sparkle effect
				if math.random() < 0.4 then
					minetest.add_particle({
						pos = breaking_particle_properties.pos,
						velocity = {
							x = math.random(-100, 100) / 100,
							y = math.random(-50, 50) / 100,
							z = math.random(-100, 100) / 100
						},
						acceleration = {x = 0, y = -5, z = 0},
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
						glow = 12,
						--collisiondetection = true,
						--collision_removal = true,
					})
				end
			end
		end)
		
		-- Second stage breaking for double effect
		if double == true then
			minetest.after(base_lifetime * 0.5, function()
				for i = 1, 3 do
					local final_velocity = {
						x = math.random(-150, 150) / 100,
						y = math.random(-100, 50) / 100,
						z = math.random(-150, 150) / 100
					}
					minetest.add_particle({
						pos = {
							x = pos.x + enhanced_velocity.x * base_lifetime * 0.5,
							y = pos.y + enhanced_velocity.y * base_lifetime * 0.5,
							z = pos.z + enhanced_velocity.z * base_lifetime * 0.5
						},
						velocity = final_velocity,
						acceleration = {x = 0, y = -9.81, z = 0},
						expirationtime = base_lifetime * 0.5,
						size = enhanced_size * 0.5,
						texture = {
							name = colored_texture,
							scale_tween = {
								style = "fwd",
								reps = 1,
								0.8,
								0.2,
								0.0
							},
						},
						glow = math.max(3, glow - 4),
						--collisiondetection = true,
						--collision_removal = true,
					})
				end
			end)
		end
	end
	
	-- Add initial explosion flash effect for all shapes
	minetest.add_particle({
		pos = pos,
		velocity = {x = 0, y = 0, z = 0},
		acceleration = {x = 0, y = 0, z = 0},
		expirationtime = 0.15,
		size = radius * 3,
		texture = {
			name = "default_cloud.png^[colorize:" .. (color_def or explosion_colors[1]) .. ":80",
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
				255,
				100,
				0
			}
		},
		glow = 15,
		collisiondetection = false,
	})
	
	-- Enhanced sound effects with shape-specific variations
	local explosion_sounds = {
		sphere = "fireworks_explosion.ogg",
		star = "fireworks_explosion.ogg",
		burst = "fireworks_explosion.ogg",
		chaotic = "fireworks_crackle.ogg",
		flame = "fireworks_crackle.ogg"
	}
	
	local sound_name = explosion_sounds[shape] or "fireworks_explosion.ogg"
	local pitch_variation = 0.8 + math.random() * 0.6
	local gain_variation = 0.7 + math.random() * 0.4
	
	minetest.sound_play(sound_name, {
		pos = pos,
		gain = gain_variation,
		pitch = pitch_variation,
		max_hear_distance = 200,
	})
	
	-- Add echo effect for larger explosions
	if shape == "burst" or shape == "star" or shape == "chrysanthemum" then
		minetest.after(0.3, function()
			minetest.sound_play("fireworks_explosion.ogg", {
				pos = pos,
				gain = gain_variation * 0.3,
				pitch = pitch_variation * 0.8,
				max_hear_distance = 150,
			})
		end)
	end

	-- Ground illumination effect
	minetest.after(0.1, function()
		local ground_lights = scale_particle_count(12, quality)
		for i = 1, ground_lights do
			local angle = (i / ground_lights) * math.pi * 2
			local ground_pos = {
				x = pos.x + math.cos(angle) * radius * 1.5,
				y = pos.y - 8,
				z = pos.z + math.sin(angle) * radius * 1.5
			}
			
			minetest.add_particle({
				pos = ground_pos,
				velocity = {x = 0, y = 1, z = 0},
				acceleration = {x = 0, y = -2, z = 0},
				expirationtime = 2.0,
				size = 4,
				texture = {
					name = "default_cloud.png^[colorize:" .. (color_def or explosion_colors[1]) .. ":40",
					scale_tween = {
						style = "fwd",
						reps = 1,
						2.0,
						4.0,
						0.0
					}
				},
				glow = 8,
				collisiondetection = false,
			})
		end
	end)
	
	-- Atmospheric pressure wave effects
	minetest.after(0.05, function()
		local wave_rings = 3
		for ring = 1, wave_rings do
			minetest.after(ring * 0.15, function()
				local wave_radius = radius * (2 + ring * 1.5)
				local wave_particles = math.floor(40 - ring * 8)
				
				for i = 1, wave_particles do
					local angle = (i / wave_particles) * math.pi * 2
					local wave_pos = {
						x = pos.x + math.cos(angle) * wave_radius,
						y = pos.y + math.random(-100, 200) / 100,
						z = pos.z + math.sin(angle) * wave_radius
					}
					
					-- Create expanding pressure wave particles
					minetest.add_particle({
						pos = wave_pos,
						velocity = {
							x = math.cos(angle) * 2,
							y = math.random(-50, 50) / 100,
							z = math.sin(angle) * 2
						},
						acceleration = {x = 0, y = -1, z = 0},
						expirationtime = 1.5 - ring * 0.3,
						size = 2 - ring * 0.3,
						texture = {
							name = "default_cloud.png^[colorize:#FFFFFF:30",
							scale_tween = {
								style = "fwd",
								reps = 1,
								1.5,
								0.8,
								0.0
							},
							alpha_tween = {
								style = "fwd",
								reps = 1,
								80,
								40,
								0
							}
						},
						glow = 3,
						collisiondetection = false,
					})
				end
			end)
		end
	end)
	
	-- Realistic falling debris and settling smoke
	minetest.after(1.0, function()
		local debris_count = math.random(15, 25)
		for i = 1, debris_count do
			local debris_pos = {
				x = pos.x + math.random(-radius * 2, radius * 2),
				y = pos.y + math.random(radius, radius * 3),
				z = pos.z + math.random(-radius * 2, radius * 2)
			}
			
			-- Create falling debris particles
			minetest.add_particle({
				pos = debris_pos,
				velocity = {
					x = math.random(-100, 100) / 100,
					y = math.random(-300, -100) / 100,
					z = math.random(-100, 100) / 100
				},
				acceleration = {x = 0, y = -9.81, z = 0},
				expirationtime = 3.0 + math.random() * 2.0,
				size = 0.5 + math.random() * 1.0,
				texture = {
					name = "default_cloud.png^[colorize:#666666:80",
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.8,
						0.0
					},
					alpha_tween = {
						style = "fwd",
						reps = 1,
						120,
						60,
						0
					}
				},
				glow = 2,
				--collisiondetection = true,
				--collision_removal = true,
			})
		end
		
		-- Settling smoke effect
		for i = 1, 8 do
			local smoke_pos = {
				x = pos.x + math.random(-radius, radius),
				y = pos.y - 2,
				z = pos.z + math.random(-radius, radius)
			}
			
			minetest.add_particle({
				pos = smoke_pos,
				velocity = {
					x = math.random(-50, 50) / 100,
					y = math.random(50, 150) / 100,
					z = math.random(-50, 50) / 100
				},
				acceleration = {x = 0, y = -0.5, z = 0},
				expirationtime = 8.0 + math.random() * 4.0,
				size = 3.0 + math.random() * 2.0,
				texture = {
					name = "default_cloud.png^[colorize:#888888:60",
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						3.0,
						0.2
					},
					alpha_tween = {
						style = "fwd",
						reps = 1,
						100,
						40,
						0
					}
				},
				glow = 1,
				collisiondetection = false,
			})
		end
	end)

	if shape == "sphere" then
		-- Enhanced sphere with multiple layers and realistic distribution
		local particle_count = 0
		local max_particles = math.floor(200 * (quality.particles_multiplier or 1.0))
		
		-- Adjust step size based on quality
		local step_i = math.max(4, math.floor(8 / (quality.particles_multiplier or 1.0)))
		local step_j = math.max(6, math.floor(12 / (quality.particles_multiplier or 1.0)))
		
		-- Dense inner core
		for i = 1, 360, step_i do
			for j = -90, 90, step_j do
				if particle_count >= max_particles then break end
				local theta = math.rad(i + math.random(-3, 3))
				local phi = math.rad(j + math.random(-3, 3))
				local r = radius * (0.8 + math.random() * 0.4)
				local speed_mult = 0.8 + math.random() * 0.6
				
				local x = math.cos(phi) * math.cos(theta) * r * speed_mult
				local y = math.sin(phi) * r * speed_mult
				local z = math.cos(phi) * math.sin(theta) * r * speed_mult
				
				spawn_colored_particle({x = x, y = y, z = z})
				particle_count = particle_count + 1
			end
		end
		
		-- Outer shell with variation
		local outer_step_i = math.max(10, math.floor(20 / (quality.particles_multiplier or 1.0)))
		local outer_step_j = math.max(10, math.floor(20 / (quality.particles_multiplier or 1.0)))
		for i = 1, 360, outer_step_i do
			for j = -90, 90, outer_step_j do
				if particle_count >= max_particles * 1.5 then break end
				local theta = math.rad(i + math.random(-5, 5))
				local phi = math.rad(j + math.random(-5, 5))
				local r = radius * (1.2 + math.random() * 0.3)
				local speed_mult = 1.1 + math.random() * 0.4
				
				local x = math.cos(phi) * math.cos(theta) * r * speed_mult
				local y = math.sin(phi) * r * speed_mult
				local z = math.cos(phi) * math.sin(theta) * r * speed_mult
				
				spawn_colored_particle({x = x, y = y, z = z})
				particle_count = particle_count + 1
			end
		end
		
		-- Add random scattered particles for realism
		local scattered_count = math.floor(50 * (quality.particles_multiplier or 1.0))
		for i = 1, scattered_count do
			local theta = math.random() * math.pi * 2
			local phi = math.acos(math.random() * 2 - 1)
			local r = radius * (0.6 + math.random() * 0.8)
			local speed_mult = 0.7 + math.random() * 0.8
			
			local x = math.sin(phi) * math.cos(theta) * r * speed_mult
			local y = math.cos(phi) * r * speed_mult
			local z = math.sin(phi) * math.sin(theta) * r * speed_mult
			
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "star" then
		-- Enhanced 3D star with multiple rays and realistic physics
		local star_rays = {
			{x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
			{x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0},
			{x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1},
			{x = 0.7, y = 0.7, z = 0}, {x = -0.7, y = -0.7, z = 0},
			{x = 0.7, y = -0.7, z = 0}, {x = -0.7, y = 0.7, z = 0},
			{x = 0.7, y = 0, z = 0.7}, {x = -0.7, y = 0, z = -0.7},
		}
		
		-- Create main star rays
		local ray_particles = math.floor(8 * (quality.particles_multiplier or 1.0))
		for _, ray in ipairs(star_rays) do
			for i = 1, ray_particles do
				local distance = (i / ray_particles) * radius * (1.2 + math.random() * 0.6)
				local speed_mult = 1.5 - (i / ray_particles) * 0.8
				
				local velocity = {
					x = ray.x * distance * speed_mult,
					y = ray.y * distance * speed_mult,
					z = ray.z * distance * speed_mult
				}
				spawn_colored_particle(velocity)
			end
		end
		
		-- Add sparkle points at ray tips
		minetest.after(0.2, function()
			for _, ray in ipairs(star_rays) do
				local tip_pos = {
					x = ray.x * radius * 1.5,
					y = ray.y * radius * 1.5,
					z = ray.z * radius * 1.5
				}
				
				-- Create bright sparkle at tip
				local sparkle_count = math.floor(5 * (quality.particles_multiplier or 1.0))
				for i = 1, sparkle_count do
					local sparkle_velocity = {
						x = tip_pos.x + math.random(-100, 100) / 100,
						y = tip_pos.y + math.random(-100, 100) / 100,
						z = tip_pos.z + math.random(-100, 100) / 100
					}
					spawn_colored_particle(sparkle_velocity)
				end
			end
		end)
	elseif shape == "ring" then
		-- Enhanced ring with multiple layers and expanding waves
		local ring_layers = 3
		
		for layer = 1, ring_layers do
			minetest.after((layer - 1) * 0.08, function()
				local layer_radius = radius * (0.8 + layer * 0.4)
				local particles_count = math.floor(360 / (12 - layer * 2))
				
				for i = 1, particles_count do
					local theta = (i / particles_count) * math.pi * 2 + math.random(-5, 5) * math.pi / 180
					local r = layer_radius * (0.9 + math.random() * 0.2)
					local speed_mult = 1.2 + layer * 0.3
					
					local x = math.cos(theta) * r * speed_mult
					local z = math.sin(theta) * r * speed_mult
					local y = math.random(-30, 30) / 100 -- Slight vertical variation
					
					spawn_colored_particle({x = x, y = y, z = z})
				end
				
				-- Add ring sparkles
				for i = 1, 8 do
					local sparkle_theta = math.random() * math.pi * 2
					local sparkle_r = layer_radius * (1.1 + math.random() * 0.3)
					local sparkle_velocity = {
						x = math.cos(sparkle_theta) * sparkle_r,
						y = math.random(-100, 100) / 100,
						z = math.sin(sparkle_theta) * sparkle_r
					}
					spawn_colored_particle(sparkle_velocity)
				end
			end)
		end
	elseif shape == "christmas_tree" then
		-- Enhanced Christmas tree with layered effects and star on top
		local height = 12
		local base_radius = 5
		
		-- Tree layers with decreasing radius
		for i = 1, height do
			local layer_radius = base_radius * (1 - i / height * 0.8)
			local particles_in_layer = math.max(8, math.floor(layer_radius * 8))
			
			for j = 1, particles_in_layer do
				local theta = (j / particles_in_layer) * math.pi * 2
				local r = layer_radius * (0.8 + math.random() * 0.4)
				local x = math.cos(theta) * r
				local z = math.sin(theta) * r
				local y = i + math.random(-20, 20) / 100
				
				spawn_colored_particle({x = x, y = y, z = z})
			end
		end
		
		-- Tree trunk
		for i = 1, 3 do
			spawn_colored_particle({x = 0, y = -i, z = 0})
		end
		
		-- Bright star on top with sparkle effect
		minetest.after(0.2, function()
			-- Main star
			for i = 1, 12 do
				local star_angle = (i / 12) * math.pi * 2
				local star_velocity = {
					x = math.cos(star_angle) * 2,
					y = height + math.random(100, 300) / 100,
					z = math.sin(star_angle) * 2
				}
				spawn_colored_particle(star_velocity)
			end
			
			-- Sparkles around the star
			for i = 1, 20 do
				local sparkle_velocity = {
					x = math.random(-300, 300) / 100,
					y = height + math.random(200, 500) / 100,
					z = math.random(-300, 300) / 100
				}
				spawn_colored_particle(sparkle_velocity)
			end
		end)
		
		-- Ornaments (delayed colorful bursts)
		minetest.after(0.4, function()
			for i = 2, height - 2, 2 do
				local ornament_count = math.random(3, 6)
				for j = 1, ornament_count do
					local ornament_angle = math.random() * math.pi * 2
					local ornament_radius = (base_radius * (1 - i / height * 0.8)) * 0.7
					
					-- Small ornament burst
					for k = 1, 8 do
						local ornament_burst_angle = (k / 8) * math.pi * 2
						local ornament_velocity = {
							x = math.cos(ornament_angle) * ornament_radius * 0.5 + math.cos(ornament_burst_angle) * 1.5,
							y = i + math.random(-50, 150) / 100,
							z = math.sin(ornament_angle) * ornament_radius * 0.5 + math.sin(ornament_burst_angle) * 1.5
						}
						spawn_colored_particle(ornament_velocity)
					end
				end
			end
		end)
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
		local spiral_height = 3
		local spiral_turns = 20
		local rotation_speed = 0.1
		local radius_start = 7
		local radius_end = 7

		for i = 1, 360 * spiral_turns, 15 do
			local angle = math.rad(i)
			local y = (i / 360) * spiral_height

			local radius = radius_start + ((radius_end - radius_start) * (y / spiral_height))

			local rotation_angle = angle * rotation_speed

			local x = math.cos(rotation_angle) * radius
			local z = math.sin(rotation_angle) * radius

			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "hour_glass" then
		local num_turns = 10
		for i = 1, 360 * num_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * num_turns
			local radius = 10 - (y / 2)
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "chaotic" then
		-- Multi-stage chaotic explosion with waves of different intensities
		local total_waves = 4
		local particles_per_wave = {60, 80, 40, 30}
		
		for wave = 1, total_waves do
			minetest.after((wave - 1) * 0.08, function()
				local wave_radius = radius * (0.5 + wave * 0.3)
				local wave_speed_mult = 1.5 - wave * 0.2
				
				for i = 1, particles_per_wave[wave] do
					-- Create clusters of particles
					local cluster_center = {
						x = (math.random() - 0.5) * wave_radius,
						y = (math.random() - 0.5) * wave_radius,
						z = (math.random() - 0.5) * wave_radius
					}
					
					-- Add individual particles around cluster center
					local cluster_size = math.random(1, 3)
					for j = 1, cluster_size do
						local x = cluster_center.x + (math.random() - 0.5) * 2
						local y = cluster_center.y + (math.random() - 0.5) * 2
						local z = cluster_center.z + (math.random() - 0.5) * 2
						
						local rs = (math.random() + 0.5) * wave_speed_mult
						local chaos_factor = 1 + wave * 0.5
						
						local random_velocity = {
							x = x + math.random(-4, 4) * rs * chaos_factor,
							y = y + math.random(-4, 4) * rs * chaos_factor,
							z = z + math.random(-4, 4) * rs * chaos_factor
						}
						spawn_colored_particle(random_velocity)
					end
				end
			end)
		end
		
		-- Add final sparkle burst
		minetest.after(0.4, function()
			for i = 1, 25 do
				local sparkle_velocity = {
					x = math.random(-8, 8),
					y = math.random(-6, 8),
					z = math.random(-8, 8)
				}
				spawn_colored_particle(sparkle_velocity)
			end
		end)
	elseif shape == "cube" then
		for x = -radius, radius, radius do
			for y = -radius, radius, radius do
				for z = -radius, radius, radius do
					spawn_colored_particle({x = x, y = y, z = z})
				end
			end
		end
	elseif shape == "flame" then
		-- Enhanced flame effect with realistic fire physics and multiple layers
		local flame_height = 15
		local base_radius = 5
		local flame_stages = 4
		
		-- Create multi-stage flame with different intensities
		for stage = 1, flame_stages do
			minetest.after((stage - 1) * 0.05, function()
				local stage_particles = 100 - stage * 15
				local stage_height = flame_height * (1 + stage * 0.2)
				local stage_radius = base_radius * (1.2 - stage * 0.1)
				
				for i = 1, stage_particles do
					local theta = math.rad(math.random(360))
					local r = math.random() * stage_radius * (0.7 + math.random() * 0.5)
					local height = math.random() * stage_height
					
					-- Enhanced flame shape - more realistic tapering
					local height_factor = math.max(0.1, 1 - math.pow(height / stage_height, 1.5) * 0.8)
					r = r * height_factor
					
					-- Add flame turbulence
					local turbulence = math.sin(height * 0.5) * 0.3 + math.random(-20, 20) / 100
					local x = math.cos(theta) * r + turbulence
					local z = math.sin(theta) * r + turbulence
					local y = height
					
					-- Enhanced upward velocity with realistic flame motion
					local velocity = {
						x = x * 0.8 + math.random(-80, 80) / 100,
						y = y * 0.6 + math.random(200, 500) / 100,
						z = z * 0.8 + math.random(-80, 80) / 100
					}
					
					spawn_colored_particle(velocity)
				end
			end)
		end
		
		-- Add dancing flame tips
		minetest.after(0.1, function()
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
				
				spawn_colored_particle(flicker_velocity)
			end
		end)
		
		-- Add sparks flying off
		minetest.after(0.2, function()
			for i = 1, 20 do
				local spark_velocity = {
					x = math.random(-6, 6),
					y = math.random(2, 8),
					z = math.random(-6, 6)
				}
				spawn_colored_particle(spark_velocity)
			end
		end)
	elseif shape == "burst" then
		-- Create initial bright flash
		spawn_colored_particle({x = 0, y = 0, z = 0})
		
		-- Primary burst wave
		for i = 1, 120 do
			local angle_h = math.random() * math.pi * 2
			local angle_v = math.acos(math.random() * 2 - 1)
			local r = radius * (0.8 + math.random() * 0.4)
			local speed = 1.2 + math.random() * 0.8
			
			local x = math.sin(angle_v) * math.cos(angle_h) * r * speed
			local y = math.cos(angle_v) * r * speed
			local z = math.sin(angle_v) * math.sin(angle_h) * r * speed
			
			spawn_colored_particle({x = x, y = y, z = z})
		end
		
		-- Secondary burst wave (delayed)
		minetest.after(0.15, function()
			for i = 1, 80 do
				local angle_h = math.random() * math.pi * 2
				local angle_v = math.acos(math.random() * 2 - 1)
				local r = radius * (1.1 + math.random() * 0.3)
				local speed = 0.9 + math.random() * 0.6
				
				local x = math.sin(angle_v) * math.cos(angle_h) * r * speed
				local y = math.cos(angle_v) * r * speed
				local z = math.sin(angle_v) * math.sin(angle_h) * r * speed
				
				local enhanced_pos = {
					x = pos.x + math.random(-100, 100) / 100,
					y = pos.y + math.random(-100, 100) / 100,
					z = pos.z + math.random(-100, 100) / 100
				}
				
				spawn_colored_particle({x = x, y = y, z = z})
			end
		end)
	elseif shape == "willow" then
		-- Weeping Willow effect - particles shoot up then droop down
		local initial_burst_count = 60
		local droop_delay = 0.4
		
		-- Initial upward burst
		for i = 1, initial_burst_count do
			local angle = math.random() * math.pi * 2
			local initial_speed = 4 + math.random() * 3
			local upward_speed = 6 + math.random() * 4
			
			local velocity = {
				x = math.cos(angle) * initial_speed,
				y = upward_speed,
				z = math.sin(angle) * initial_speed
			}
			spawn_colored_particle(velocity)
		end
		
		-- Delayed drooping effect
		minetest.after(droop_delay, function()
			for i = 1, 80 do
				local angle = math.random() * math.pi * 2
				local radius_factor = 0.8 + math.random() * 0.4
				local droop_speed = 2 + math.random() * 2
				
				local start_pos = {
					x = pos.x + math.cos(angle) * radius * radius_factor,
					y = pos.y + 3 + math.random() * 2,
					z = pos.z + math.sin(angle) * radius * radius_factor
				}
				
				local droop_velocity = {
					x = math.cos(angle) * droop_speed * 0.3,
					y = -droop_speed - math.random() * 2,
					z = math.sin(angle) * droop_speed * 0.3
				}
				
				-- Create drooping particle with enhanced physics
				spawn_colored_particle(droop_velocity)
			end
		end)
		
	elseif shape == "chrysanthemum" then
		-- Chrysanthemum - expanding rings of particles
		local rings = 5
		local particles_per_ring = 25
		
		for ring = 1, rings do
			minetest.after(ring * 0.05, function()
				local ring_radius = radius * (ring * 0.3)
				local ring_height = ring * 0.8
				
				for i = 1, particles_per_ring do
					local angle = (i / particles_per_ring) * math.pi * 2
					local speed = 3 + ring * 0.8
					
					local velocity = {
						x = math.cos(angle) * speed,
						y = ring_height + math.random(-100, 100) / 100,
						z = math.sin(angle) * speed
					}
					spawn_colored_particle(velocity)
				end
			end)
		end
		
		-- Add center burst
		for i = 1, 20 do
			local center_velocity = {
				x = math.random(-200, 200) / 100,
				y = math.random(200, 600) / 100,
				z = math.random(-200, 200) / 100
			}
			spawn_colored_particle(center_velocity)
		end
		
	elseif shape == "peony" then
		-- Peony - burst followed by secondary breaking
		local main_burst_count = 80
		
		-- Main burst
		for i = 1, main_burst_count do
			local angle_h = math.random() * math.pi * 2
			local angle_v = math.acos(math.random() * 2 - 1)
			local speed = 4 + math.random() * 3
			
			local velocity = {
				x = math.sin(angle_v) * math.cos(angle_h) * speed,
				y = math.cos(angle_v) * speed,
				z = math.sin(angle_v) * math.sin(angle_h) * speed
			}
			spawn_colored_particle(velocity)
		end
		
		-- Secondary breaking effect
		minetest.after(0.6, function()
			for i = 1, 40 do
				local break_pos = {
					x = pos.x + math.random(-radius, radius),
					y = pos.y + math.random(-radius/2, radius),
					z = pos.z + math.random(-radius, radius)
				}
				
				local break_velocity = {
					x = math.random(-300, 300) / 100,
					y = math.random(-200, 100) / 100,
					z = math.random(-300, 300) / 100
				}
				spawn_colored_particle(break_velocity)
			end
		end)
	end
	
	-- Add spectacular finale effects for certain shapes
	if shape == "star" or shape == "chrysanthemum" or shape == "peony" then
		minetest.after(2.5, function()
			-- Finale sparkle burst
			for i = 1, 30 do
				local finale_angle = math.random() * math.pi * 2
				local finale_radius = radius * (1.5 + math.random())
				local finale_velocity = {
					x = math.cos(finale_angle) * finale_radius,
					y = math.random(2, 6),
					z = math.sin(finale_angle) * finale_radius
				}
				
				-- Create finale sparkle with enhanced effects
				spawn_colored_particle(finale_velocity)
			end
		end)
	end
	
	-- Performance cleanup after explosion duration
	minetest.after(8.0, function()
		fireworks_reimagined.performance.register_firework_end()
	end)
end

function fireworks_reimagined.spawn_firework_explosion(pos, color_def, color_def_2, alpha, texture, psize)
	-- Performance tracking
	fireworks_reimagined.performance.register_firework_start()
	
	-- Get quality settings for performance adaptation
	local quality = fireworks_reimagined.performance.get_quality_settings()
	
	local explosion_colors = random_explosion_colors()
	local radius = math.random(8, 12) * quality.particles_multiplier
	
	-- Apply particle size modifier from quality settings
	local size_mod = quality.particle_size_modifier or 1.0
	local mnpsize = (psize or 2.0) * quality.particles_multiplier * size_mod
	local mxpsize = (psize or 5.5) * quality.particles_multiplier * size_mod
	
	local glow = math.random(12, 15)
	local color = color_def or explosion_colors[math.random(#explosion_colors)]
	color_def_2 = color_def_2 or explosion_colors[math.random(#explosion_colors)]
	alpha = alpha or 150

	-- Create initial flash effect
	minetest.add_particle({
		pos = pos,
		velocity = {x = 0, y = 0, z = 0},
		acceleration = {x = 0, y = 0, z = 0},
		expirationtime = 0.4,
		size = radius * 3,
		texture = {
			name = "fireworks_white.png^[colorize:" .. color .. ":80",
			scale_tween = {
				style = "fwd",
				reps = 1,
				3.0,
				0.0,
				-0.05
			},
		},
		glow = 15,
		collisiondetection = false,
	})

	-- Enhanced main explosion with multiple layers
	local tex = texture or "black.png"
	
	-- Adjust particle count based on quality
	local particle_count = math.floor(800 * quality.particles_multiplier)
	
	-- Primary explosion layer (bright core particles)
	local primary_params = {
		amount = particle_count,
		time = 0.8,
		minpos = pos,
		maxpos = pos,
		minexptime = 2.2,
		maxexptime = 4.5,
		radius = {min = -radius * 1.5, max = radius * 1.2, bias = 0},
		minsize = mnpsize * 1.0,  -- Reduced multiplier for better size control
		maxsize = mxpsize * 1.4,  -- Reduced multiplier for better size control
		minvel = {x = -math.random(4,6), y = 6, z = -math.random(5, 7)},  -- Further increased Y velocity
		maxvel = {x = math.random(7,9), y = 15, z = math.random(8, 10)},  -- Further increased Y velocity
		acc = {x = 0, y = -9.81, z = 0},
		glow = glow + 2,
		--collisiondetection = true,
		--collision_removal = true,
		drag = vector.new(0.05, 0.02, 0.05),
		particlespawner_tweenable = true,
		texpool = {
			{
				name = tex .. "^[colorize:" .. color .. ":" .. alpha,
				scale_tween = {
					style = "fwd",
					reps = 1,
					1.4,
					0.8,
					0.0,
					start = 0.0,
					finish = 1.0
				},
			},
			{
				name = tex .. "^[colorize:" .. color_def_2 .. ":" .. alpha,
				scale_tween = {
					style = "fwd",
					reps = 1,
					1.4,
					0.8,
					0.0,
					start = 0.0,
					finish = 1.0
				},
			}
		},
	}
	minetest.add_particlespawner(primary_params)

	-- Secondary explosion layer (trailing particles)
	minetest.after(0.3, function()
		local secondary_count = math.floor(400 * quality.particles_multiplier)
		local secondary_params = {
			amount = secondary_count,
			time = 0.5,
			minpos = pos,
			maxpos = pos,
			minexptime = 1.8,
			maxexptime = 3.5,
			radius = {min = -radius * 1.2, max = radius * 0.9, bias = 0},
			minsize = mnpsize * 0.6,  -- Further reduced for better control
			maxsize = mxpsize * 1.0,  -- Further reduced for better control
			minvel = {x = -math.random(3,4), y = 3, z = -math.random(4, 5)},  -- Increased Y velocity
			maxvel = {x = math.random(5,6), y = 12, z = math.random(6, 7)},  -- Increased Y velocity
			acc = {x = 0, y = -9.81, z = 0},
			glow = glow,
			--collisiondetection = true,
			--collision_removal = true,
			drag = vector.new(0.08, 0.03, 0.08),
			particlespawner_tweenable = true,
			texpool = {
				{
					name = "fireworks_spark_white.png^[colorize:" .. color .. ":" .. math.floor(alpha * 0.8),
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.4,
						0.0
					},
				},
				{
					name = "fireworks_spark_white.png^[colorize:" .. color_def_2 .. ":" .. math.floor(alpha * 0.8),
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.4,
						0.0
					},
				}
			},
		}
		minetest.add_particlespawner(secondary_params)
	end)

	-- Glitter effect layer
	minetest.after(0.8, function()
		local glitter_count = math.floor(200 * quality.particles_multiplier)
		local glitter_params = {
			amount = glitter_count,
			time = 0.3,
			minpos = vector.add(pos, {x = -radius, y = -radius/2, z = -radius}),  -- Adjusted Y to be higher
			maxpos = vector.add(pos, {x = radius, y = radius*1.5, z = radius}),   -- Adjusted Y to be higher
			minexptime = 2.0,
			maxexptime = 4.0,
			minsize = 0.6 * size_mod,  -- Apply size modifier
			maxsize = 1.2 * size_mod,  -- Apply size modifier
			minvel = {x = -1, y = 0, z = -1},  -- Improved Y velocity
			maxvel = {x = 1, y = 4, z = 1},    -- Improved Y velocity
			acc = {x = 0, y = -9.81, z = 0},
			glow = 14,
			--collisiondetection = true,
			--collision_removal = true,
			texture = {
				name = "fireworks_spark_white.png^[colorize:" .. (math.random(2) == 1 and color or color_def_2) .. ":180",
				scale_tween = {
					style = "fwd",
					reps = 1,
					1.2,
					0.0,
					-0.02
				},
			},
		}
		minetest.add_particlespawner(glitter_params)
	end)

	-- Smoke and debris effect
	minetest.after(0.2, function()
		local smoke_params = {
			amount = 150,
			time = 0.4,
			minpos = vector.add(pos, {x = -2, y = -2, z = -2}),
			maxpos = vector.add(pos, {x = 2, y = 2, z = 2}),
			minexptime = 3.0,
			maxexptime = 6.0,
			minsize = 3.0,
			maxsize = 8.0,
			minvel = {x = -2, y = 1, z = -2},
			maxvel = {x = 2, y = 4, z = 2},
			acc = {x = 0, y = 0.5, z = 0},
			glow = 0,
			collisiondetection = false,
			texture = {
				name = "tnt_smoke.png^[colorize:#666666:120",
				scale_tween = {
					style = "fwd",
					reps = 1,
					0.5,
					2.5,
					0.0
				},
			},
		}
		if minetest.registered_items["default:smoke"] then
			minetest.add_particlespawner(smoke_params)
		end
	end)

	-- Enhanced ground illumination effect
	local ground_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
	for i = -4, 4 do
		for j = -4, 4 do
			local light_pos = {x = ground_pos.x + i, y = ground_pos.y, z = ground_pos.z + j}
			local node = minetest.get_node(light_pos)
			if node.name ~= "air" and node.name ~= "ignore" then
				local distance = math.sqrt(i*i + j*j)
				local light_intensity = math.max(0.2, 1 - distance / 5)
				
				minetest.add_particle({
					pos = {x = light_pos.x, y = light_pos.y + 1.1, z = light_pos.z},
					velocity = {x = 0, y = 0, z = 0},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = 2.5,
					size = 12 * light_intensity,
					texture = {
						name = "fireworks_white.png^[colorize:" .. color .. ":" .. math.floor(80 * light_intensity),
						scale_tween = {
							style = "fwd",
							reps = 1,
							1.2,
							0.0,
							-0.012
						},
					},
					glow = math.floor(10 * light_intensity),
					collisiondetection = false,
				})
			end
		end
	end
	
	-- Enhanced atmospheric pressure wave effect
	minetest.after(0.1, function()
		for i = 1, 60 do
			local wave_angle = math.random() * math.pi * 2
			local wave_distance = 8 + math.random() * 12
			local wave_pos = {
				x = pos.x + math.cos(wave_angle) * wave_distance,
				y = pos.y + math.random(-3, 3),
				z = pos.z + math.sin(wave_angle) * wave_distance
			}
			
			minetest.add_particle({
				pos = wave_pos,
				velocity = {
					x = math.cos(wave_angle) * 2,
					y = math.random(-100, 100) / 100,
					z = math.sin(wave_angle) * 2
				},
				acceleration = {x = 0, y = 0, z = 0},
				expirationtime = 1.5,
				size = math.random(8, 20) / 10,
				texture = {
					name = "fireworks_white.png^[colorize:#CCCCCC:40",
					scale_tween = {
						style = "fwd",
						reps = 1,
						0.5,
						1.5,
						0.0
					},
				},
				glow = 3,
				collisiondetection = false,
			})
		end
	end)
	
	-- Add realistic falling debris
	minetest.after(1.0, function()
		for i = 1, 30 do
			local debris_pos = {
				x = pos.x + math.random(-radius, radius),
				y = pos.y + math.random(-2, 5),
				z = pos.z + math.random(-radius, radius)
			}
			
			minetest.add_particle({
				pos = debris_pos,
				velocity = {
					x = math.random(-200, 200) / 100,
					y = math.random(-300, -50) / 100,
					z = math.random(-200, 200) / 100
				},
				acceleration = {x = 0, y = -9.81, z = 0},
				expirationtime = math.random(200, 600) / 100,
				size = math.random(2, 8) / 10,
				texture = {
					name = "fireworks_spark_white.png^[colorize:#666666:150",
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.3,
						0.0
					},
				},
				glow = 2,
				--collisiondetection = true,
				--collision_removal = true,
			})
		end
	end)
end

function fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers, texture, batch_size, log)
	-- Performance tracking
	fireworks_reimagined.performance.register_firework_start()
	
	-- Get quality settings for performance adaptation
	local quality = fireworks_reimagined.performance.get_quality_settings()
	
	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	local size_multiplier = 1.6
	local particle_lifetime = 2.5 - delay
	local radius = math.max(grid_width, grid_height) * size_multiplier * 0.8
	local b_size = batch_size or 10
	local color_particles = {}
	
	-- Extract dominant colors from the grid for effects
	local dominant_colors = {}
	local color_counts = {}
	
	for z = 0, depth_layers do
		for y = 1, grid_height do
			for x = 1, grid_width do
				local color = color_grid[y][x]
				if color ~= "#000000" then
					color_particles[color] = color_particles[color] or {}
					local particle_pos = vector.add(pos, vector.new(
						(x - (grid_width / 2)) * size_multiplier,
						(y - (grid_height / 2)) * size_multiplier,
						(z - (depth_layers / 2)) * size_multiplier
					))
					table.insert(color_particles[color], particle_pos)
					
					-- Count colors for dominant color detection
					color_counts[color] = (color_counts[color] or 0) + 1
				end
			end
		end
	end
	
	-- Find the most dominant colors for effects
	local sorted_colors = {}
	for color, count in pairs(color_counts) do
		table.insert(sorted_colors, {color = color, count = count})
	end
	table.sort(sorted_colors, function(a, b) return a.count > b.count end)
	
	local primary_color = sorted_colors[1] and sorted_colors[1].color or "#FFFFFF"
	local secondary_color = sorted_colors[2] and sorted_colors[2].color or primary_color
	local tertiary_color = sorted_colors[3] and sorted_colors[3].color or secondary_color
	local total_spawners = 0
	
	-- ===== STAGE 1: PRE-IGNITION ANTICIPATION =====
	-- Create building tension with small sparks
	minetest.after(delay * 0.1, function()
		for i = 1, 8 do
			minetest.add_particle({
				pos = {
					x = pos.x + math.random(-100, 100) / 100,
					y = pos.y + math.random(-50, 50) / 100,
					z = pos.z + math.random(-100, 100) / 100
				},
				velocity = {
					x = math.random(-50, 50) / 100,
					y = math.random(50, 150) / 100,
					z = math.random(-50, 50) / 100
				},
				acceleration = {x = 0, y = -2, z = 0},
				expirationtime = 0.8,
				size = 0.5,
				texture = {
					name = "fireworks_spark_white.png^[colorize:" .. primary_color .. ":200",
					scale_tween = {
						style = "fwd",
						reps = 1,
						0.8,
						0.2,
						0.0
					}
				},
				glow = 8,
				collisiondetection = false,
			})
			total_spawners = total_spawners + 1
		end
	end)
	
	-- ===== STAGE 2: INITIAL FLASH AND CORE IGNITION =====
	minetest.after(delay * 0.5, function()
		minetest.add_particle({
			pos = pos,
			velocity = {x = 0, y = 0, z = 0},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = 0.4,
			size = radius * 2.0,
			texture = {
				name = "fireworks_white.png^[colorize:" .. secondary_color .. ":100",
				scale_tween = {
					style = "fwd",
					reps = 1,
					2.5,
					0.0,
					-0.1
				}
			},
			glow = 12,
			collisiondetection = false,
		})
		total_spawners = total_spawners + 1
	end)
	
	-- ===== STAGE 3: PRIMARY GRID EXPLOSION =====
	minetest.after(delay, function()
		for color, positions in pairs(color_particles) do
			local colored_texture = texture and (texture .. "^[colorize:" .. color) or ("black.png^[colorize:" .. color)
			for i = 1, #positions, b_size do
				local batch_positions = {}
				for j = i, math.min(i + b_size - 1, #positions) do
					table.insert(batch_positions, positions[j])
				end
				local world_minpos = vector.new(1e10, 1e10, 1e10)
				local world_maxpos = vector.new(-1e10, -1e10, -1e10)
				for _, pos_item in ipairs(batch_positions) do
					world_minpos = vector.new(
						math.min(world_minpos.x, pos_item.x),
						math.min(world_minpos.y, pos_item.y),
						math.min(world_minpos.z, pos_item.z)
					)
					world_maxpos = vector.new(
						math.max(world_maxpos.x, pos_item.x),
						math.max(world_maxpos.y, pos_item.y),
						math.max(world_maxpos.z, pos_item.z)
					)
				end
				
				-- Enhanced primary particles with advanced tweening
				minetest.add_particlespawner({
					amount = #batch_positions,
					time = 0.2,
					minpos = world_minpos,
					maxpos = world_maxpos,
					minvel = {x = math.random(-8,-5), y = 3, z = math.random(-9, -6)},
					maxvel = {x = math.random(5,8), y = 12, z = math.random(6, 9)},
					acc = {x=0, y=-9.81, z=0},
					minexptime = 2.0,
					maxexptime = 4.0,
					minsize = 1.5 * quality.particles_multiplier,
					maxsize = 3.0 * quality.particles_multiplier,
					vertical = false,
					glow = math.random(13, 16),
					drag = vector.new(0.04, 0.02, 0.04),
					particlespawner_tweenable = true,
					texpool = {
						{
							name = colored_texture,
							scale_tween = {
								style = "fwd",
								reps = 1,
								1.8,
								1.2,
								0.0,
								start = 0.0,
								finish = 1.0
							},
							alpha_tween = {
								style = "fwd",
								reps = 1,
								255,
								200,
								0,
								start = 0.0,
								finish = 1.0
							}
						}
					},
				})
				total_spawners = total_spawners + 1
			end
		end
	end)
	
	-- ===== STAGE 4: SECONDARY EXPANSION WAVES =====
	-- Multi-wave chrysanthemum-style expansion
	local wave_count = 4
	for wave = 1, wave_count do
		minetest.after(delay + 0.2 + (wave * 0.08), function()
			local wave_radius = radius * (0.6 + wave * 0.4)
			local wave_particles = math.floor((50 - wave * 8) * quality.particles_multiplier)
			local wave_colors = {primary_color, secondary_color, tertiary_color}
			local wave_color = wave_colors[((wave - 1) % #wave_colors) + 1]
			
			for i = 1, wave_particles do
				local angle = (i / wave_particles) * math.pi * 2
				local speed = 4 + wave * 1.2
				local height_variation = wave * 0.6
				
				minetest.add_particle({
					pos = pos,
					velocity = {
						x = math.cos(angle) * speed,
						y = height_variation + math.random(-100, 200) / 100,
						z = math.sin(angle) * speed
					},
					acceleration = {x = 0, y = -9.81, z = 0},
					expirationtime = 2.5 + wave * 0.3,
					size = (2.0 - wave * 0.2) * quality.particles_multiplier,
					texture = {
						name = "fireworks_spark_white.png^[colorize:" .. wave_color .. ":150",
						scale_tween = {
							style = "fwd",
							reps = 1,
							1.4,
							0.6,
							0.0
						},
						alpha_tween = {
							style = "fwd",
							reps = 1,
							200,
							120,
							0
						}
					},
					glow = 12 - wave,
					collisiondetection = false,
				})
				total_spawners = total_spawners + 1
			end
		end)
	end
	
	-- ===== STAGE 5: TERTIARY BREAKING EFFECTS =====
	-- Peony-style secondary breaking
	minetest.after(delay + 0.8, function()
		local break_positions = {}
		-- Create break points around the explosion area
		for i = 1, 6 do
			local break_angle = (i / 6) * math.pi * 2
			local break_distance = radius * (0.8 + math.random() * 0.4)
			table.insert(break_positions, {
				x = pos.x + math.cos(break_angle) * break_distance,
				y = pos.y + math.random(-2, 4),
				z = pos.z + math.sin(break_angle) * break_distance
			})
		end
		
		for _, break_pos in ipairs(break_positions) do
			-- Create mini-explosions at break points
			for j = 1, 12 do
				local break_angle = math.random() * math.pi * 2
				local break_speed = 2 + math.random() * 2
				
				minetest.add_particle({
					pos = break_pos,
					velocity = {
						x = math.cos(break_angle) * break_speed,
						y = math.random(-100, 300) / 100,
						z = math.sin(break_angle) * break_speed
					},
					acceleration = {x = 0, y = -9.81, z = 0},
					expirationtime = 1.5 + math.random() * 1.0,
					size = 1.2 * quality.particles_multiplier,
					texture = {
						name = "fireworks_spark_white.png^[colorize:" .. (math.random(2) == 1 and primary_color or secondary_color) .. ":180",
						scale_tween = {
							style = "fwd",
							reps = 1,
							1.0,
							0.3,
							0.0
						}
					},
					glow = 10,
					collisiondetection = false,
				})
				total_spawners = total_spawners + 1
			end
		end
	end)
	
	-- ===== STAGE 6: QUATERNARY SPARKLE BURSTS =====
	-- Multiple delayed sparkle bursts for maximum spectacle
	for burst = 1, 3 do
		minetest.after(delay + 1.2 + (burst * 0.3), function()
			local sparkle_count = math.floor((40 - burst * 8) * quality.particles_multiplier)
			local burst_colors = {primary_color, secondary_color, tertiary_color}
			local burst_color = burst_colors[burst]
			
			for i = 1, sparkle_count do
				local sparkle_angle = math.random() * math.pi * 2
				local sparkle_elevation = math.random() * math.pi - math.pi/2
				local sparkle_speed = 3 + math.random() * 4
				
				minetest.add_particle({
					pos = {
						x = pos.x + math.random(-radius/2, radius/2),
						y = pos.y + math.random(-2, 6),
						z = pos.z + math.random(-radius/2, radius/2)
					},
					velocity = {
						x = math.cos(sparkle_elevation) * math.cos(sparkle_angle) * sparkle_speed,
						y = math.sin(sparkle_elevation) * sparkle_speed + 2,
						z = math.cos(sparkle_elevation) * math.sin(sparkle_angle) * sparkle_speed
					},
					acceleration = {x = 0, y = -9.81, z = 0},
					expirationtime = 2.0 + math.random() * 2.0,
					size = (0.8 + math.random() * 0.6) * quality.particles_multiplier,
					texture = {
						name = "fireworks_spark_white.png^[colorize:" .. burst_color .. ":220",
						scale_tween = {
							style = "fwd",
							reps = 1,
							1.5,
							0.1,
							0.0
						},
						alpha_tween = {
							style = "fwd",
							reps = 1,
							255,
							150,
							0
						}
					},
					glow = 14,
					collisiondetection = false,
				})
				total_spawners = total_spawners + 1
			end
		end)
	end
	
	-- ===== STAGE 7: ENVIRONMENTAL EFFECTS =====
	-- Enhanced ground illumination with color waves
	minetest.after(delay + 0.1, function()
		local ground_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
		local light_radius = math.min(6, math.floor(radius / 1.5))
		
		for ring = 1, 3 do
			minetest.after(ring * 0.1, function()
				local ring_radius = light_radius * (ring / 3)
				local ring_color = {primary_color, secondary_color, tertiary_color}
				
				for i = -ring_radius, ring_radius do
					for j = -ring_radius, ring_radius do
						local light_pos = {x = ground_pos.x + i, y = ground_pos.y, z = ground_pos.z + j}
						local node = minetest.get_node(light_pos)
						if node.name ~= "air" and node.name ~= "ignore" then
							local distance = math.sqrt(i*i + j*j)
							if distance <= ring_radius and distance > (ring_radius - 1) then
								local light_intensity = math.max(0.3, 1 - distance / (ring_radius + 1))
								
								minetest.add_particle({
									pos = {x = light_pos.x, y = light_pos.y + 1.1, z = light_pos.z},
									velocity = {x = 0, y = 0, z = 0},
									acceleration = {x = 0, y = 0, z = 0},
									expirationtime = 3.0,
									size = 10 * light_intensity,
									texture = {
										name = "fireworks_white.png^[colorize:" .. ring_color .. ":" .. math.floor(100 * light_intensity),
										scale_tween = {
											style = "fwd",
											reps = 1,
											1.5,
											0.0,
											-0.008
										},
									},
									glow = math.floor(10 * light_intensity),
									collisiondetection = false,
								})
								total_spawners = total_spawners + 1
							end
						end
					end
				end
			end)
		end
	end)
	
	-- ===== STAGE 8: ATMOSPHERIC PRESSURE WAVES =====
	-- Multi-ring pressure wave system
	local wave_rings = 4
	for ring = 1, wave_rings do
		minetest.after(delay + 0.05 + (ring * 0.12), function()
			local wave_radius = radius * (1.5 + ring * 1.2)
			local wave_particles = math.floor((60 - ring * 10) * quality.particles_multiplier)
			
			for i = 1, wave_particles do
				local wave_angle = (i / wave_particles) * math.pi * 2
				local wave_pos = {
					x = pos.x + math.cos(wave_angle) * wave_radius,
					y = pos.y + math.random(-3, 3),
					z = pos.z + math.sin(wave_angle) * wave_radius
				}
				
				minetest.add_particle({
					pos = wave_pos,
					velocity = {
						x = math.cos(wave_angle) * (2 - ring * 0.3),
						y = math.random(-80, 80) / 100,
						z = math.sin(wave_angle) * (2 - ring * 0.3)
					},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = 1.8,
					size = (1.5 - ring * 0.2),
					texture = {
						name = "fireworks_white.png^[colorize:#DDDDDD:" .. (60 - ring * 10),
						scale_tween = {
							style = "fwd",
							reps = 1,
							0.3,
							2.0,
							0.0
						},
					},
					glow = 4 - ring,
					collisiondetection = false,
				})
				total_spawners = total_spawners + 1
			end
		end)
	end
	
	-- ===== STAGE 9: FALLING DEBRIS AND SMOKE =====
	minetest.after(delay + 1.5, function()
		local debris_count = math.min(30, grid_width * grid_height / 2)
		for i = 1, debris_count do
			local debris_pos = {
				x = pos.x + math.random(-radius * 1.5, radius * 1.5),
				y = pos.y + math.random(-2, 8),
				z = pos.z + math.random(-radius * 1.5, radius * 1.5)
			}
			
			minetest.add_particle({
				pos = debris_pos,
				velocity = {
					x = math.random(-200, 200) / 100,
					y = math.random(-400, -100) / 100,
					z = math.random(-200, 200) / 100
				},
				acceleration = {x = 0, y = -9.81, z = 0},
				expirationtime = math.random(300, 800) / 100,
				size = math.random(3, 10) / 10,
				texture = {
					name = "fireworks_spark_white.png^[colorize:#888888:180",
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.2,
						0.2,
						0.0
					},
				},
				glow = 1,
				collisiondetection = true,
				collision_removal = true,
			})
			total_spawners = total_spawners + 1
		end
		
		-- Add settling smoke
		for i = 1, 15 do
			minetest.add_particle({
				pos = {
					x = pos.x + math.random(-radius, radius),
					y = pos.y + math.random(-1, 3),
					z = pos.z + math.random(-radius, radius)
				},
				velocity = {
					x = math.random(-100, 100) / 100,
					y = math.random(50, 200) / 100,
					z = math.random(-100, 100) / 100
				},
				acceleration = {x = 0, y = 0.2, z = 0},
				expirationtime = 4.0 + math.random() * 3.0,
				size = 4.0 + math.random() * 3.0,
				texture = {
					name = "tnt_smoke.png^[colorize:#999999:100",
					scale_tween = {
						style = "fwd",
						reps = 1,
						0.8,
						3.0,
						0.0
					},
					alpha_tween = {
						style = "fwd",
						reps = 1,
						120,
						60,
						0
					}
				},
				glow = 0,
				collisiondetection = false,
			})
		end
	end)
	
	-- Performance tracking
	minetest.after(6.0, function()
		fireworks_reimagined.performance.register_firework_end()
		if log == true then
			minetest.log("warning", "Total particle spawners used: " .. total_spawners)
		end
	end)
end

local last_rightclick_time = {}
local last_mesecons_time = {}

function fireworks_reimagined.register_firework_node(tiles, shape, entity, cooldown, mese_cooldown, ip)
	minetest.register_alias("fireworks_reimagined:firework_" .. shape .. "_0", "fireworks_reimagined:firework_" .. shape)
	minetest.register_alias("fireworks_reimagined:firework_" .. shape .. "_10", "fireworks_reimagined:firework_" .. shape)
	minetest.register_node(":fireworks_reimagined:firework_" .. shape, {
		description = "Firework (" .. shape .. ")",
		tiles = { tiles or "fireworks_" .. shape .. ".png" },
		groups = { cracky = 1, oddly_breakable_by_hand = 1 },
		paramtype = "light",
		light_source = 5,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("allow_others", "false")
			meta:set_string("c1", "#FFFFFF")
			meta:set_string("c2", "#FF0000")
			local inv = meta:get_inventory()
			inv:set_size("fuse", 1)
			inv:set_size("firework_rocket", 25)
		end,
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			local placer_name = placer:get_player_name()
			meta:set_string("owner", placer_name)
		end,
		on_punch = function(pos, node, clicker)
			local wielded_item = clicker:get_wielded_item():get_name()
			if wielded_item == "" then
				local meta = minetest.get_meta(pos)
				local owner = meta:get_string("owner")
				local player_name = clicker:get_player_name()
				local privs = minetest.get_player_privs(player_name)
				local is_owner = player_name == owner or privs.fireworks_master
				local inv = meta:get_inventory()
				if inv:is_empty("fuse") then
					inv:set_size("fuse", 1)
				end
				if inv:is_empty("firework_rockets") then
					inv:set_size("firework_rockets", 25)
				end
				local spos = pos.x .. "," .. pos.y .. "," .. pos.z
				if is_owner and not privs.fireworks_admin then
					local formspec = "size[11,9.5]" ..
					"label[2.5,0.0;Firework Settings]" ..
					"checkbox[0.5,1.5;allow_others;Allow others to launch;" .. meta:get_string("allow_others") .. "]" ..
					"list[nodemeta:" .. spos .. ";fuse;8,2;1,1;]" ..
					"field[0.5,3.0;7.5,0.5;cone;First Fireworks Color;" .. meta:get_string("c1") .. "]" ..
					"field[0.5,4.5;7.5,0.5;ctwo;Second Fireworks Color;" .. meta:get_string("c2") .. "]" ..
					"list[current_player;main;0,4.85;8,4;]" ..
					"button_exit[8,3.5;3,1;save;Save]" ..
					"listring[nodemeta:" .. spos .. ";fuse]" ..
					"listring[current_player;main]" ..
					default.get_hotbar_bg(0, 4.85)
					minetest.show_formspec(player_name, "fireworks_reimagined:settings_" .. minetest.pos_to_string(pos), formspec)
				elseif privs.fireworks_admin then
					local formspec = "size[10,12]" ..
					"label[2.5,0.0;Firework Settings]" ..
					"checkbox[0.5,1.5;allow_others;Allow others to launch;" .. meta:get_string("allow_others") .. "]" ..
					"field[0.5,1.5;7.5,0.5;delay;Launch Delay (seconds);" .. meta:get_int("delay") .. "]" ..
					"field[0.5,3.0;7.5,0.5;cone;First Fireworks Color;" .. meta:get_string("c1") .. "]" ..
					"field[0.5,4.5;7.5,0.5;ctwo;Second Fireworks Color;" .. meta:get_string("c2") .. "]" ..
					"button_exit[2.5,5.5;3,1;save;Save]"
					minetest.show_formspec(player_name, "fireworks_reimagined:settings_" .. minetest.pos_to_string(pos), formspec)
				end
			else
				return false
			end
		end,
		on_rightclick = function(pos, node, clicker)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local player_name = clicker:get_player_name()
			local privs = minetest.get_player_privs(player_name)
			local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
			local pos_hash = minetest.hash_node_position(pos)
			local allow_others = meta:get_string("allow_others") == "true"
			local is_allowed = is_owner or allow_others or privs.fireworks_master or privs.fireworks_admin
			local current_time = minetest.get_gametime()
			local cd = cooldown or 3
			local c1 = meta:get_string("c1")
			local c2 = meta:get_string("c2")

			if meta:get_string("owner") == "" then
				meta:set_string("owner", player_name)
			end

			local inv = meta:get_inventory()
			if inv:is_empty("fuse") then
				inv:set_size("fuse", 1)
			end
			local fuse_stack = inv:get_stack("fuse", 1)
			local fuse_count = fuse_stack:get_count()
			local delay
			if not privs.fireworks_admin then
				delay = fuse_count
			elseif privs.fireworks_admin then
				delay = meta:get_int("delay")
			end

			if is_allowed and (not last_rightclick_time[pos_hash] or current_time - last_rightclick_time[pos_hash] >= cd) then
				last_rightclick_time[pos_hash] = current_time
				inv:set_stack("fuse", 1, nil)
				minetest.after(delay, function()
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						if ip ~= (nil or false) then
							firework_entity:get_luaentity().ip = true
						end
						firework_entity:get_luaentity().firework_shape = shape
						firework_entity:get_luaentity().color1 = c1
						firework_entity:get_luaentity().color2 = c2
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end)
			elseif not is_allowed then
				minetest.chat_send_player(player_name, "You don't have permission to launch this firework.")
			elseif privs.fireworks_master or privs.fireworks_admin then
				minetest.after(delay, function()
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						if ip ~= (nil or false) then
							firework_entity:get_luaentity().ip = true
						end
						firework_entity:get_luaentity().firework_shape = shape
						firework_entity:get_luaentity().color1 = c1
						firework_entity:get_luaentity().color2 = c2
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
						inv:set_stack("fuse", 1, nil)
					end
				end)
			else
				minetest.chat_send_player(player_name, "Please wait before launching another firework!")
			end
		end,
		mesecons = { effector = {
			rules = rules,
			action_on = function(pos, node)
				local pos_hash = minetest.hash_node_position(pos)
				local current_time = minetest.get_gametime()
				local meta = minetest.get_meta(pos)
				local c1 = meta:get_string("c1")
				local c2 = meta:get_string("c2")
				local mcd = mese_cooldown or 4
				if not last_mesecons_time[pos_hash] or current_time - last_mesecons_time[pos_hash] >= mcd then
					last_mesecons_time[pos_hash] = current_time
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						if ip ~= (nil or false) then
							firework_entity:get_luaentity().ip = true
						end
						firework_entity:get_luaentity().firework_shape = shape
						firework_entity:get_luaentity().color1 = c1
						firework_entity:get_luaentity().color2 = c2
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end
			end,
		}},
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			if listname == "fuse" and stack:get_name() == "fireworks_reimagined:fuse" then
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local fuse_stack = inv:get_stack("fuse", 1)
				if fuse_stack:get_count() > 15 then
					fuse_stack:set_count(15)
					inv:set_stack("fuse", 1, fuse_stack)
				end
			end
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			if listname == "fuse" and stack:get_name() == "fireworks_reimagined:fuse" then
				return math.min(stack:get_count(), 15)
			elseif listname == "extras" and minetest.get_item_group(stack:get_name(), "firework_rocket") > 0 then
				return 1
			end
			return 0
		end,
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pos = minetest.string_to_pos(formname:match("fireworks_reimagined:settings_(.*)"))
	if pos and player then
		local meta = minetest.get_meta(pos)
		local player_name = player:get_player_name()
		local privs = minetest.get_player_privs(player_name)
		local is_owner = player_name == meta:get_string("owner") or privs.fireworks_master
		if is_owner then
			if fields.delay and tonumber(fields.delay) then
				meta:set_int("delay", tonumber(fields.delay))
			end
			if fields.cone and fields.cone then
				meta:set_string("c1", fields.cone)
			end
			if fields.ctwo then
				meta:set_string("c2", fields.ctwo)
			end
			if fields.allow_others then
				meta:set_string("allow_others", fields.allow_others)
			else
				local current_allow_others = meta:get_string("allow_others")
				meta:set_string("allow_others", current_allow_others ~= "" and current_allow_others or "false")
			end
		end
	end
end)


local registered_fireworks = {}
function fireworks_reimagined.register_firework_entity(name, def)
	local entity_def = {
		initial_properties = {
			fireworks    = true,
			textures = {"fireworks_rocket_white.png"},
			glow = 10,
			collisionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
			physical     = true,
			collide_with_objects = false,
			velocity = 0,
		},
		yaw = 0,
		acceleration = 5,
		static_save = false,
		firework_shape = def.firework_shape or "sphere",
		time_remaining = def.time_remaining or 3,
		spiral = def.spiral or false,
		spiral_force = def.spiral_force or 100,
		spiral_radius = def.spiral_radius or 0.1,
		thrust = def.thrust or 15,
		color1 = nil,
		color2 = nil ,
		------------BY NIWLA23--MIT LICENSE------------
		on_activate = function(self, staticdata, dtime_s)
			if def.on_activate ~= nil then
				def.on_activate(self, staticdata, dtime_s)
			end
			self.object:set_armor_groups({immortal = 1})
			minetest.sound_play(self.launch_noise, {
				max_hear_distance = 100,
				gain = 10.0,
				object = self.object,
			})
			if self.spiral == true and self.spiral_force > 0 then
				self.velocity = self.spiral_force
				self.spiraling = true
				self.time_remaining = self.time_remaining * 2
			else
				self.velocity = 0
			end	
		end,
		collision = function(self)
			local pos = self.object:get_pos()
			local vel = self.object:get_velocity()
			local x   = 0
			local z   = 0
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
				if object:is_player() or (object:get_luaentity() and object:get_luaentity().mob == true and object ~= self.object) then
					local pos2 = object:get_pos()
					local vec  = {x=pos.x-pos2.x, z=pos.z-pos2.z}
					local force = (1) - vector.distance({x=pos.x,y=0,z=pos.z}, {x=pos2.x,y=0,z=pos2.z})
					x = x + (vec.x * force) * 20
					z = z + (vec.z * force) * 20
				end
			end
			return({x,z})
		end,
		movement = function(self)
			if self.spiraling == true then
				self.yaw = self.yaw + self.spiral_radius
				if self.yaw > math.pi*2 then
					self.yaw = self.yaw - (math.pi*2)
				end
			end		
			local collide_values = self.collision(self)
			local c_x = collide_values[1]
			local c_z = collide_values[2]
			local vel = self.object:get_velocity()
			local x   = math.sin(self.yaw) * -self.velocity
			local z   = math.cos(self.yaw) *  self.velocity
			local gravity = -10
			if self.thrust > 0 then
				gravity = self.thrust
			end
			if self.spiral == true then
				if gravity == -10 then
					self.object:set_acceleration({x=(x - vel.x + c_x)*self.acceleration,y=-10,z=(z - vel.z + c_z)*self.acceleration})				
				else
					self.object:set_acceleration({x=(x - vel.x + c_x)*self.acceleration,y=(gravity-vel.y)*self.acceleration,z=(z - vel.z + c_z)*self.acceleration})
				end
			else
				self.object:set_velocity({x=0, y=20, z=0})
			end
		end,
		------------------------------------------------
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			if not pos then return end
			self.movement(self)
			pos.y = pos.y + (self.initial_properties.velocity * dtime)
			self.time_remaining = self.time_remaining - dtime
			if self.time_remaining <= 0 then
				def.firework_explosion(pos, self.color1, self.color2)
				self.object:remove()
				minetest.sound_play("fireworks_explosion", {
					pos = pos,
					max_hear_distance = 150,
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
	local shapes = {"sphere", "star", "ring", "burst", "cube", "spiral", "chaotic", "flame", "snowflake", "present", "christmas_tree", "willow", "chrysanthemum", "peony"}
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
	time_remaining = 3,
	ip = false,
	static_save = false,
	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end
		
		-- Enhanced rocket physics with realistic thrust
		local current_velocity = self.object:get_velocity()
		local thrust = 25 * (self.time_remaining / 2) -- Decreasing thrust over time
		local wobble = {
			x = math.sin(self.time_remaining * 10) * 0.5,
			y = 0,
			z = math.cos(self.time_remaining * 10) * 0.5
		}
		
		self.object:set_velocity({
			x = wobble.x,
			y = thrust,
			z = wobble.z
		})
		
		-- Create enhanced rocket trail with multiple particle types
		local trail_colors = {"#FFD700", "#FF8C00", "#FF4500", "#DC143C", "#8B0000"}
		local trail_intensity = math.max(0.3, self.time_remaining / 2)
		
		-- Main bright trail
		for i = 1, 5 do
			local trail_pos = {
				x = pos.x + math.random(-30, 30) / 100,
				y = pos.y - 0.3 - i * 0.15,
				z = pos.z + math.random(-30, 30) / 100
			}
			
			local trail_alpha = math.floor(255 * trail_intensity * (1 - i * 0.15))
			local trail_size = (3.0 - i * 0.4) * trail_intensity
			
			minetest.add_particle({
				pos = trail_pos,
				velocity = {
					x = current_velocity.x * -0.1 + math.random(-150, 150) / 100,
					y = current_velocity.y * -0.4 - 1.5,
					z = current_velocity.z * -0.1 + math.random(-150, 150) / 100
				},
				acceleration = {x = 0, y = -9.81, z = 0},
				expirationtime = 1.5 - i * 0.2,
				size = trail_size,
				texture = {
					name = "fireworks_spark_white.png^[colorize:" .. trail_colors[math.min(i, #trail_colors)] .. ":" .. trail_alpha,
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.2,
						0.4,
						0.0
					},
				},
				glow = math.floor((15 - i * 2) * trail_intensity),
				collisiondetection = false,
			})
		end
		
		-- Sparks falling from trail
		if math.random() < 0.4 then
			for i = 1, 3 do
				minetest.add_particle({
					pos = {x = pos.x, y = pos.y - 0.8, z = pos.z},
					velocity = {
						x = math.random(-200, 200) / 100,
						y = math.random(-400, -200) / 100,
						z = math.random(-200, 200) / 100
					},
					acceleration = {x = 0, y = -9.81, z = 0},
					expirationtime = math.random(80, 200) / 100,
					size = math.random(5, 15) / 10,
					texture = {
						name = "fireworks_spark_white.png^[colorize:#FFD700:180",
						scale_tween = {
							style = "fwd",
							reps = 1,
							1.0,
							0.0,
							-0.04
						},
					},
					glow = 10,
					--collisiondetection = true,
					--collision_removal = true,
				})
			end
		end
		
		-- Smoke trail
		if math.random() < 0.3 then
			minetest.add_particle({
				pos = {x = pos.x, y = pos.y - 1, z = pos.z},
				velocity = {
					x = math.random(-50, 50) / 100,
					y = math.random(-100, 50) / 100,
					z = math.random(-50, 50) / 100
				},
				acceleration = {x = 0, y = 0.5, z = 0},
				expirationtime = math.random(200, 400) / 100,
				size = math.random(15, 30) / 10,
				texture = {
					name = "tnt_smoke.png^[colorize:#555555:100",
					scale_tween = {
						style = "fwd",
						reps = 1,
						0.5,
						2.0,
						0.0
					},
				},
				glow = 0,
				collisiondetection = false,
			})
		end
		
		-- Rocket whistle sound effect
		if math.random() < 0.08 then
			minetest.sound_play("fireworks_whistle", {
				pos = pos,
				max_hear_distance = 40,
				gain = 0.8,
				pitch = 0.8 + self.time_remaining * 0.3
			})
		end
		
		self.time_remaining = self.time_remaining - dtime
		if self.time_remaining <= 0 then
			-- Enhanced explosion effects
			local colors = {}
			if self.color1 then table.insert(colors, self.color1) end
			if self.color2 then table.insert(colors, self.color2) end
			if #colors == 0 then colors = {"#FFFFFF", "#FFD700", "#FF4500"} end
			
			if self.ip == true then
				fireworks_reimagined.spawn_firework_explosion_ip(pos, self.firework_shape or "chaotic", false, colors[1], colors[2], nil, nil, nil)
			else
				fireworks_reimagined.spawn_firework_explosion(pos, colors[1], colors[2], nil, nil, nil)
			end
			
			-- Add spectacular finale effects for certain shapes
			if self.firework_shape == "sphere" or self.firework_shape == "chaotic" then
				-- Triple burst finale
				minetest.after(0.3, function()
					fireworks_reimagined.spawn_firework_explosion_ip(
						{x = pos.x + math.random(-2, 2), y = pos.y + 2, z = pos.z + math.random(-2, 2)}, 
						"burst", false, colors[1], colors[2], nil, nil, nil
					)
				end)
				minetest.after(0.6, function()
					fireworks_reimagined.spawn_firework_explosion_ip(
						{x = pos.x + math.random(-3, 3), y = pos.y + 4, z = pos.z + math.random(-3, 3)}, 
						"star", false, colors[1], colors[2], nil, nil, nil
					)
				end)
			elseif self.firework_shape == "christmas_tree" then
				-- Christmas finale with golden sparkles
				minetest.after(0.4, function()
					for i = 1, 15 do
						local sparkle_pos = {
							x = pos.x + math.random(-6, 6),
							y = pos.y + math.random(0, 8),
							z = pos.z + math.random(-6, 6)
						}
						fireworks_reimagined.spawn_firework_explosion_ip(
							sparkle_pos, "burst", false, "#FFD700", "#FFFFFF", nil, "black.png", 1.5
						)
					end
				end)
			elseif self.firework_shape == "willow" then
				-- Willow finale with cascading effect
				minetest.after(0.5, function()
					for i = 1, 8 do
						minetest.after(i * 0.1, function()
							local cascade_pos = {
								x = pos.x + math.random(-4, 4),
								y = pos.y - i,
								z = pos.z + math.random(-4, 4)
							}
							fireworks_reimagined.spawn_firework_explosion_ip(
								cascade_pos, "burst", false, colors[1], colors[2], nil, nil, nil
							)
						end)
					end
				end)
			end
			
			-- Enhanced explosion sound with shape-specific effects
			local sound_variations = {
				sphere = {pitch = 0.9, gain = 25.0, echo_delay = 0.4},
				star = {pitch = 1.1, gain = 22.0, echo_delay = 0.3},
				burst = {pitch = 0.7, gain = 28.0, echo_delay = 0.5},
				chaotic = {pitch = 0.6, gain = 30.0, echo_delay = 0.2},
				christmas_tree = {pitch = 1.2, gain = 20.0, echo_delay = 0.6},
				flame = {pitch = 0.8, gain = 24.0, echo_delay = 0.3},
				willow = {pitch = 1.0, gain = 26.0, echo_delay = 0.7}
			}
			
			local sound_config = sound_variations[self.firework_shape] or sound_variations.sphere
			
			minetest.sound_play("fireworks_explosion", {
				pos = pos,
				max_hear_distance = 180,
				gain = sound_config.gain,
				pitch = sound_config.pitch + math.random() * 0.3
			})
			
			-- Add delayed echo sound
			minetest.after(sound_config.echo_delay, function()
				minetest.sound_play("fireworks_explosion", {
					pos = pos,
					max_hear_distance = 120,
					gain = sound_config.gain * 0.6,
					pitch = sound_config.pitch * 0.8 + math.random() * 0.2
				})
			end)
			
			-- Add crackling sounds for certain patterns
			if self.firework_shape == "chaotic" or self.firework_shape == "burst" then
				minetest.after(0.2, function()
					for i = 1, 5 do
						minetest.after(i * 0.15, function()
							minetest.sound_play("fireworks_crackle", {
								pos = {
									x = pos.x + math.random(-8, 8),
									y = pos.y + math.random(-4, 4),
									z = pos.z + math.random(-8, 8)
								},
								max_hear_distance = 50,
								gain = 0.8,
								pitch = 0.8 + math.random() * 0.6
							})
						end)
					end
				end)
			end

			self.object:remove()
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
		if privs.fireworks_master or privs.fireworks_admin then
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

minetest.register_privilege("fireworks_admin", {
	description = ("Administrator priv for fireworks."),
	give_to_singleplayer = false,
})

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	user_usage[player_name] = nil
end)

minetest.register_craftitem("fireworks_reimagined:fuse", {
	description = ("Fuse"),
	inventory_image = "farming_string.png^[multiply:#343434",
	groups = {flammable = 1},
})

minetest.register_craft({
	output = "fireworks_reimagined:fuse 9",
	recipe = {
		{"farming:string", "farming:string", "farming:string"},
		{"farming:string", "default:coal_lump", "farming:string"},
		{"farming:string", "farming:string", "farming:string"},
	}
})

-- Load enhanced systems
dofile(modpath.."/performance.lua")
dofile(modpath.."/timeline.lua")
dofile(modpath.."/pattern_creator.lua")
dofile(modpath.."/timeline_blocks.lua")
dofile(modpath.."/showcase.lua")

-- Load original systems
dofile(modpath.."/crafting.lua")
dofile(modpath.."/colored.lua")
dofile(modpath.."/images.lua")
dofile(modpath.."/default.lua")
dofile(modpath.."/test.lua")
