local function create_explosion_finale_effects(pos, firework_shape, colors)
	if not colors or #colors == 0 then
		colors = {"#FFFFFF", "#FFD700", "#FF4500"}
	end
	
	if firework_shape == "chaotic" then
		core.after(0.6, function()
			fireworks_reimagined.spawn_firework_explosion(
				{x = pos.x + math.random(-3, 3), y = pos.y + 4, z = pos.z + math.random(-3, 3)}, 
				"ring", false, colors[1], colors[2], nil, nil, nil
			)
		end)
	end
end

local function create_explosion_sound_effects(pos, firework_shape)
	local sound_variations = {
		sphere = {pitch = 0.9, gain = 25.0, echo_delay = 0.4},
		star = {pitch = 1.1, gain = 22.0, echo_delay = 0.3},
		burst = {pitch = 0.7, gain = 28.0, echo_delay = 0.5},
		chaotic = {pitch = 0.6, gain = 30.0, echo_delay = 0.2},
		flame = {pitch = 0.8, gain = 24.0, echo_delay = 0.3},
		snowflake = {pitch = 1.0, gain = 23.0, echo_delay = 0.35},
		spiral = {pitch = 0.95, gain = 24.0, echo_delay = 0.3},
		ring = {pitch = 1.05, gain = 21.0, echo_delay = 0.4},
		hour_glass = {pitch = 0.85, gain = 22.0, echo_delay = 0.45}
	}
	
	local sound_config = sound_variations[firework_shape] or sound_variations.sphere
	
	core.sound_play("fireworks_explosion", {
		pos = pos,
		max_hear_distance = 180,
		gain = sound_config.gain,
		pitch = sound_config.pitch + math.random() * 0.3
	})
	
	core.after(sound_config.echo_delay, function()
		core.sound_play("fireworks_explosion", {
			pos = pos,
			max_hear_distance = 120,
			gain = sound_config.gain * 0.6,
			pitch = sound_config.pitch * 0.8 + math.random() * 0.2
		})
	end)
end

fireworks_reimagined.create_explosion_finale_effects = create_explosion_finale_effects
fireworks_reimagined.create_explosion_sound_effects = create_explosion_sound_effects
