local sound_variations = {
	sphere = {pitch = 0.9, gain = 10},
	star = {pitch = 1.1, gain = 9},
	burst = {pitch = 0.7, gain = 10},
	chaotic = {pitch = 1.4, gain = 6},
	flame = {pitch = 0.8, gain = 9},
	snowflake = {pitch = 1.0, gain = 9},
	spiral = {pitch = 0.95, gain = 10},
	ring = {pitch = 1.05, gain = 9},
	hour_glass = {pitch = 0.85, gain = 9},
}

local function create_explosion_sound_effects(pos, firework_shape)
	local sound_config = sound_variations[firework_shape] or sound_variations.sphere

	core.sound_play("fireworks_explosion", {
		pos = pos,
		max_hear_distance = 160,
		gain = sound_config.gain,
		pitch = sound_config.pitch + math.random() * 0.8,
	})
end

fireworks_reimagined.create_explosion_sound_effects = create_explosion_sound_effects