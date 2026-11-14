local shapes = fireworks_reimagined.get_enabled_shapes()
local all_shapes = fireworks_reimagined.known_shapes
local default_shape = shapes[1] or "burst"
-- Legacy item aliases historically pointed at burst. If burst is disabled,
-- point them at the first enabled shape instead of an unregistered node.
local legacy_shape = fireworks_reimagined.is_shape_enabled("burst") and "burst" or default_shape
local alias_disabled_shapes = core.settings:get_bool("fireworks_alias_disabled_shapes", false)
local palette = fireworks_reimagined.color_palette

local has_mcl = core.get_modpath("mcl_core") ~= nil
local has_mcl_dyes = core.get_modpath("mcl_dye") ~= nil

local stick_item = has_mcl and "mcl_core:stick" or "default:stick"
local tnt_item = has_mcl and "mcl_tnt:tnt" or "tnt:tnt"

local dye_map
if has_mcl_dyes then
	dye_map = {
		Red = "mcl_dye:red",
		Yellow = "mcl_dye:yellow",
		Blue = "mcl_dye:blue",
		White = "mcl_dye:white",
		Orange = "mcl_dye:orange",
		Green = "mcl_dye:green",
		Violet = "mcl_dye:violet",
		Cyan = "mcl_dye:cyan",
		Magenta = "mcl_dye:magenta",
		Pink = "mcl_dye:pink",
		DarkGreen = "mcl_dye:dark_green",
	}
else
	dye_map = {
		Red = "dye:red",
		Yellow = "dye:yellow",
		Blue = "dye:blue",
		White = "dye:white",
		Orange = "dye:orange",
		Green = "dye:green",
		Violet = "dye:violet",
		Cyan = "dye:cyan",
		Magenta = "dye:magenta",
		Pink = "dye:pink",
		DarkGreen = "dye:dark_green",
	}
end

local shape_recipes = {
	sphere = {
		{stick_item, "COLOR_DYE", stick_item},
		{"COLOR_DYE", tnt_item, "COLOR_DYE"},
		{stick_item, "COLOR_DYE", stick_item},
	},
	star = {
		{"COLOR_DYE", stick_item, "COLOR_DYE"},
		{stick_item, tnt_item, stick_item},
		{"COLOR_DYE", stick_item, "COLOR_DYE"},
	},
	ring = {
		{stick_item, tnt_item, stick_item},
		{tnt_item, "COLOR_DYE", tnt_item},
		{stick_item, tnt_item, stick_item},
	},
	burst = {
		{"COLOR_DYE", "COLOR_DYE", "COLOR_DYE"},
		{"COLOR_DYE", tnt_item, "COLOR_DYE"},
		{"COLOR_DYE", "COLOR_DYE", "COLOR_DYE"},
	},
	spiral = {
		{stick_item, stick_item, "COLOR_DYE"},
		{stick_item, tnt_item, stick_item},
		{"COLOR_DYE", stick_item, stick_item},
	},
	chaotic = {
		{stick_item, "COLOR_DYE", stick_item},
		{"COLOR_DYE", tnt_item, stick_item},
		{stick_item, stick_item, "COLOR_DYE"},
	},
	flame = {
		{"", stick_item, ""},
		{stick_item, tnt_item, stick_item},
		{"COLOR_DYE", "COLOR_DYE", "COLOR_DYE"},
	},
	snowflake = {
		{stick_item, "COLOR_DYE", stick_item},
		{"COLOR_DYE", "COLOR_DYE", "COLOR_DYE"},
		{stick_item, "COLOR_DYE", stick_item},
	},
	hour_glass = {
		{stick_item, stick_item, stick_item},
		{"COLOR_DYE", tnt_item, "COLOR_DYE"},
		{stick_item, stick_item, stick_item},
	},
}

local function substitute_dye_in_recipe(recipe, color_dye)
	local substituted = {}
	for row_idx, row in ipairs(recipe) do
		substituted[row_idx] = {}
		for col_idx, item in ipairs(row) do
			if item == "COLOR_DYE" then
				substituted[row_idx][col_idx] = color_dye
			else
				substituted[row_idx][col_idx] = item
			end
		end
	end
	return substituted
end

local function get_colored_tiles(primary_hex)
	local has_darkage = core.get_modpath("darkage") ~= nil
	local has_mcl_barrels = core.get_modpath("mcl_barrels") ~= nil

	local top_texture, bottom_texture, side_texture

	if has_mcl then
		top_texture = "mcl_fireworks_box_top.png"
		bottom_texture = has_mcl_barrels and "mcl_barrels_barrel_bottom.png" or "black.png"
		side_texture = has_mcl_barrels and "mcl_barrels_barrel_side.png" or "black.png"
	elseif has_darkage then
		top_texture = "fireworks_box_top.png"
		bottom_texture = "darkage_box.png"
		side_texture = "darkage_box.png"
	else
		top_texture = "black.png"
		bottom_texture = "black.png"
		side_texture = "black.png"
	end

	local overlay2_with_color = side_texture .. "^(fireworks_overlay_2.png^[colorize:" .. primary_hex .. ":100)"

	return {
		{name = top_texture, color = "white"},
		{name = bottom_texture, color = "white"},
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

local enable_crafting = core.settings:get_bool("fireworks_enable_crafting", true)

for color_idx, color_def in ipairs(palette) do
	local color_name = color_def.name:lower()

	for _, shape_name in ipairs(shapes) do
		local entity_name = "fireworks_reimagined:" .. color_name .. "_" .. shape_name .. "_firework_entity"

		fireworks_reimagined.register_firework_entity(entity_name, {
			firework_shape = shape_name,
			firework_explosion = function(pos, color1, color2)
				fireworks_reimagined.spawn_firework_explosion(pos, shape_name, nil, color1, color2, "255", nil, nil)
			end
		})
	end

	for _, shape_name in ipairs(shapes) do
		local node_name = color_name .. "_" .. shape_name

		local reg_options = {
			primary_color = color_idx,
			description = shape_name:gsub("(%a)([%w]*)", function(a,b) return a:upper() .. b end):gsub("_", " ") .. " Fireworks (" .. color_name .. ")",
			overlay_tiles = get_overlay_tiles()
		}

		fireworks_reimagined.register_firework_node(get_colored_tiles(color_def.hex), node_name, shape_name, "fireworks_reimagined:" .. color_name .. "_" .. shape_name .. "_firework_entity", nil, nil, true, reg_options)

		if enable_crafting then
			local recipe = shape_recipes[shape_name]
			if recipe then
				local color_dye = dye_map[color_def.name]
				if color_dye then
					local substituted_recipe = substitute_dye_in_recipe(recipe, color_dye)
					core.register_craft({
						output = "fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name,
						recipe = substituted_recipe,
					})
				end
			end
		end

		for secondary_idx, secondary_def in ipairs(palette) do
			local dye = dye_map[secondary_def.name]

			if dye then
				core.register_craft({
					type = "shapeless",
					output = core.itemstring_with_palette("fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name, secondary_idx - 1),
					recipe = {"fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name, dye},
				})
			end
		end
	end
end

local function legacy_node_name(color_name)
	return "fireworks_reimagined:firework_" .. color_name .. "_" .. legacy_shape
end

local function register_firework_alias(alias_name, color_name, shape_name)
	local target_shape
	
	if shape_name then
		target_shape = shape_name
		if not fireworks_reimagined.is_shape_enabled(shape_name) then
			target_shape = legacy_shape
			if not target_shape then
				return
			end
		end
	else
		if alias_disabled_shapes then
			target_shape = legacy_shape
		elseif fireworks_reimagined.is_shape_enabled("burst") then
			target_shape = "burst"
		else
			return
		end
	end
	
	core.register_alias(alias_name, "fireworks_reimagined:firework_" .. color_name .. "_" .. target_shape)
end

register_firework_alias("fireworks_redo:spawner_red", "red")
register_firework_alias("fireworks_redo:spawner_yellow", "yellow")
register_firework_alias("fireworks_redo:spawner_blue", "blue")
register_firework_alias("fireworks_redo:spawner_white", "white")
register_firework_alias("fireworks_redo:spawner_orange", "orange")
register_firework_alias("fireworks_redo:spawner_green", "green")
register_firework_alias("fireworks_redo:spawner_purple", "violet")
register_firework_alias("fireworks_redo:spawner_cyan", "cyan")

register_firework_alias("fireworks:red", "red")
register_firework_alias("fireworks:orange", "orange")
register_firework_alias("fireworks:green", "green")
register_firework_alias("fireworks:violet", "violet")

register_firework_alias("fireworks_redo:spawner_red_spiral", "red", "spiral")
register_firework_alias("fireworks_redo:spawner_yellow_spiral", "yellow", "spiral")
register_firework_alias("fireworks_redo:spawner_blue_spiral", "blue", "spiral")
register_firework_alias("fireworks_redo:spawner_white_spiral", "white", "spiral")

for _, shape_name in ipairs(shapes) do
	core.register_alias("fireworks_reimagined:firework_" .. shape_name, "fireworks_reimagined:firework_white_" .. shape_name)
end

-- Optionally keep old item/node names working when their shape is disabled by
-- mapping them to the preferred legacy shape. This is opt-in: by default a
-- removed shape is simply unregistered and no alias is created.
if alias_disabled_shapes then
	for _, shape_name in ipairs(all_shapes) do
		if not fireworks_reimagined.is_shape_enabled(shape_name) then
			core.register_alias("fireworks_reimagined:firework_" .. shape_name, legacy_node_name("white"))

			for _, color_def in ipairs(palette) do
				local color_name = color_def.name:lower()
				local target = legacy_node_name(color_name)
				local prefix = "fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name
				core.register_alias(prefix, target)
				core.register_alias(prefix .. "_0", target)
				core.register_alias(prefix .. "_10", target)
			end
		end
	end
end

local non_existent_shapes = {"cube", "present", "christmas_tree"}
for _, shape_name in ipairs(non_existent_shapes) do
	register_firework_alias("fireworks_reimagined:firework_" .. shape_name, "white")

	for _, color_def in ipairs(palette) do
		local color_name = color_def.name:lower()
		register_firework_alias("fireworks_reimagined:firework_" .. color_name .. "_" .. shape_name, color_name)
	end
end

for _, color_def in ipairs(palette) do
	local color_name = color_def.name:lower()
	register_firework_alias("fireworks_reimagined:firework_" .. color_name, color_name)
end