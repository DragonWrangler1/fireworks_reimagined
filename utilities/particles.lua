local function get_enhanced_particle_texture(color, alpha, particle_type)
	particle_type = particle_type or "default"

	local texture_variants = {
		default = {
			"fireworks_spark_white.png",
			"fireworks_sparkle_enhanced.png",
			"black.png"
		},
		sparkle = {
			"fireworks_sparkle_enhanced.png",
			"fireworks_spark_white.png",
			"black.png",
			"black.png"
		},
		smoke = {
			"black.png",
			"black.png"
		},
		flame = {
			"black.png",
			"fireworks_spark_white.png"
		},
		trail = {
			"fireworks_spark_white.png",
		},
	}

	local textures = texture_variants[particle_type] or texture_variants.default
	local selected_texture = textures[math.random(#textures)]

	local enhanced_texture = selected_texture .. "^[colorize:" .. color .. ":" .. alpha

	if particle_type == "sparkle" then
		enhanced_texture = enhanced_texture .. "^[brighten"
	elseif particle_type == "smoke" then
		enhanced_texture = enhanced_texture .. "^[opacity:" .. math.max(30, tonumber(alpha) - 50)
	elseif particle_type == "flame" then
		enhanced_texture = enhanced_texture .. "^[brighten"
		if math.random() < 0.4 then
			enhanced_texture = enhanced_texture .. "^[opacity:" .. (tonumber(alpha) + math.random(-30, 30))
		end
	elseif particle_type == "trail" then
		enhanced_texture = enhanced_texture .. "^[opacity:" .. math.max(20, tonumber(alpha) - 40)
	end

	return enhanced_texture
end

fireworks_reimagined.get_enhanced_particle_texture = get_enhanced_particle_texture