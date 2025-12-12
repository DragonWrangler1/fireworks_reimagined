local create_explosion_sound_effects = fireworks_reimagined.create_explosion_sound_effects
local create_explosion_finale_effects = fireworks_reimagined.create_explosion_finale_effects

local shapes = {"sphere", "star", "ring", "burst", "spiral", "chaotic", "flame", "snowflake", "hour_glass"}
local palette = fireworks_reimagined.color_palette

local dye_map = {
	Red = "dye:red",
	Yellow = "dye:yellow",
	Blue = "dye:blue",
	White = "dye:white",
	Orange = "dye:orange",
	Green = "dye:green",
	Violet = "dye:violet",
	Cyan = "dye:cyan",
}

local function get_colored_tiles(primary_hex)
	local overlay2_with_color = "darkage_box.png^(fireworks_overlay_2.png^[colorize:" .. primary_hex .. ":100)"
	return {
		{name = "fireworks_box_top.png", color = "white"},
		{name = "darkage_box_top.png", color = "white"},
		{name = overlay2_with_color, color = "white"},
		{name = overlay2_with_color, color = "white"},
		{name = overlay2_with_color, color = "white"},
		{name = overlay2_with_color, color = "white"},
	}
end

local function get_overlay_tiles()
	return {
		"",
		"",
		"fireworks_overlay_1.png",
		"fireworks_overlay_1.png",
		"fireworks_overlay_1.png",
		"fireworks_overlay_1.png",
	}
end

for color_idx, color_def in ipairs(palette) do
	local color_name = color_def.name:lower()
	
	for _, shape_name in ipairs(shapes) do
		local entity_name = "fireworks_reimagined:" .. color_name .. "_" .. shape_name .. "_firework_entity"
		
		fireworks_reimagined.register_firework_entity(entity_name, {
			firework_explosion = function(pos, color1, color2)
				fireworks_reimagined.spawn_firework_explosion(pos, shape_name, nil, color1, color2, "255", nil, nil)
				local colors = {color1, color2}
				create_explosion_finale_effects(pos, shape_name, colors)
				create_explosion_sound_effects(pos, shape_name)
			end
		})
	end
	
	for _, shape_name in ipairs(shapes) do
		local node_name = color_name .. "_" .. shape_name
		
		local reg_options = {
			primary_color = color_idx,
			description = "Firework (" .. color_name .. " " .. shape_name .. ")",
			tiles = get_colored_tiles(color_def.hex),
			overlay_tiles = get_overlay_tiles(),
		}
		
		fireworks_reimagined.register_firework_node(nil, node_name, "fireworks_reimagined:" .. color_name .. "_" .. shape_name .. "_firework_entity", nil, nil, true, reg_options)
		
		core.register_craft({
			output = "fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name,
			recipe = {
				{"default:stick", "dye:white", "default:stick"},
				{"dye:white", "tnt:tnt", "dye:white"},
				{"default:stick", "dye:white", "default:stick"}
			},
		})
		
		for secondary_idx, secondary_def in ipairs(palette) do
			local dye = dye_map[secondary_def.name]
			
			core.register_craft({
				type = "shapeless",
				output = core.itemstring_with_palette("fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name, secondary_idx - 1),
				recipe = {"fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name, dye},
			})
		end
	end
end

core.register_alias("fireworks_redo:spawner_red", "fireworks_reimagined:firework_red_burst")
core.register_alias("fireworks_redo:spawner_yellow", "fireworks_reimagined:firework_yellow_burst")
core.register_alias("fireworks_redo:spawner_blue", "fireworks_reimagined:firework_blue_burst")
core.register_alias("fireworks_redo:spawner_white", "fireworks_reimagined:firework_white_burst")
core.register_alias("fireworks_redo:spawner_orange", "fireworks_reimagined:firework_orange_burst")
core.register_alias("fireworks_redo:spawner_green", "fireworks_reimagined:firework_green_burst")
core.register_alias("fireworks_redo:spawner_purple", "fireworks_reimagined:firework_violet_burst")
core.register_alias("fireworks_redo:spawner_cyan", "fireworks_reimagined:firework_cyan_burst")

core.register_alias("fireworks:red", "fireworks_reimagined:firework_red_burst")
core.register_alias("fireworks:orange", "fireworks_reimagined:firework_orange_burst")
core.register_alias("fireworks:green", "fireworks_reimagined:firework_green_burst")
core.register_alias("fireworks:violet", "fireworks_reimagined:firework_violet_burst")

for _, shape_name in ipairs(shapes) do
	core.register_alias("fireworks_reimagined:firework_" .. shape_name, "fireworks_reimagined:firework_white_" .. shape_name)
end

local non_existent_shapes = {"cube", "present", "christmas_tree"}
for _, shape_name in ipairs(non_existent_shapes) do
	core.register_alias("fireworks_reimagined:firework_" .. shape_name, "fireworks_reimagined:firework_white_burst")
	
	for _, color_def in ipairs(palette) do
		local color_name = color_def.name:lower()
		core.register_alias("fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name, "fireworks_reimagined:firework_white_burst")
	end
end

for _, color_def in ipairs(palette) do
	local color_name = color_def.name:lower()
	core.register_alias("fireworks_reimagined:firework_" .. color_name, "fireworks_reimagined:firework_" .. color_name .. "_burst")
end
