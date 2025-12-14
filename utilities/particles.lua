local function get_enhanced_particle_texture(color, alpha, particle_type)
	particle_type = particle_type or "default"
	
	local texture_variants = {
		default = {
			"fireworks_spark_white.png",
			"fireworks_enhanced_spark.png",
			"black.png^[colorize:#FFF",
			"black.png"
		},
		sparkle = {
			"fireworks_sparkle_enhanced.png",
			"fireworks_spark_white.png",
			"fireworks_star.png"
		},
		smoke = {
			"black.png^[colorize:#FFF",
			"black.png"
		},
		flame = {
			"fireworks_flame.png",
			"black.png^[colorize:#FFF",
			"fireworks_enhanced_spark.png"
		},
		trail = {
			"fireworks_enhanced_spark.png",
			"black.png^[colorize:#FFF"
		}
	}
	
	local textures = texture_variants[particle_type] or texture_variants.default
	local selected_texture = textures[math.random(#textures)]
	
	local enhanced_texture = selected_texture .. "^[colorize:" .. color .. ":" .. alpha
	
	if particle_type == "sparkle" then
		enhanced_texture = enhanced_texture .. "^[brighten"
		if math.random() < 0.3 then
			enhanced_texture = enhanced_texture
		end
	elseif particle_type == "smoke" then
		enhanced_texture = enhanced_texture .. "^[opacity:" .. math.max(30, alpha - 50)
	elseif particle_type == "flame" then
		enhanced_texture = enhanced_texture .. "^[brighten"
		if math.random() < 0.4 then
			enhanced_texture = enhanced_texture .. "^[opacity:" .. (alpha + math.random(-30, 30))
		end
	elseif particle_type == "trail" then
		enhanced_texture = enhanced_texture .. "^[opacity:" .. math.max(20, alpha - 40)
	end
	
	return enhanced_texture
end

local function scale_particle_count(base_count)
	return math.max(1, base_count)
end

fireworks_reimagined.get_enhanced_particle_texture = get_enhanced_particle_texture
fireworks_reimagined.scale_particle_count = scale_particle_count
