-- RED
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "red", "fireworks_reimagined:red_firework_entity", 0)
-- YELLOW
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFF00", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "yellow", "fireworks_reimagined:yellow_firework_entity", 0)
-- BLUE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#0404B4", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "blue", "fireworks_reimagined:blue_firework_entity", 0)
-- WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFFFF", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "white", "fireworks_reimagined:white_firework_entity", 0)

minetest.register_alias("fireworks_redo:spawner_red", "fireworks_reimagined:firework_red_0")
minetest.register_alias("fireworks_redo:spawner_yellow", "fireworks_reimagined:firework_yellow_0")
minetest.register_alias("fireworks_redo:spawner_blue", "fireworks_reimagined:firework_blue_0")
minetest.register_alias("fireworks_redo:spawner_white", "fireworks_reimagined:firework_white_0")


-- RED WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "red_white", "fireworks_reimagined:red_white_firework_entity", 0)
-- YELLOW WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFF00", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "yellow_white", "fireworks_reimagined:yellow_white_firework_entity", 0)
-- BLUE WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_white_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#0404B4", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "blue_white", "fireworks_reimagined:blue_white_firework_entity", 0)



--==============--
--=== SPIRAL ===--
--==============--

-- RED
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_red.png", "red_spiral", "fireworks_reimagined:red_spiral_firework_entity", 0)
-- YELLOW
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFF00", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_yellow.png", "yellow_spiral", "fireworks_reimagined:yellow_spiral_firework_entity", 0)
-- BLUE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#0404B4", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_blue.png", "blue_spiral", "fireworks_reimagined:blue_spiral_firework_entity", 0)
-- WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFFFF", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_white.png", "white_spiral", "fireworks_reimagined:white_spiral_firework_entity", 0)

minetest.register_alias("fireworks_redo:spawner_red_spiral", "fireworks_reimagined:firework_red_spiral_0")
minetest.register_alias("fireworks_redo:spawner_yellow_spiral", "fireworks_reimagined:firework_yellow_spiral_0")
minetest.register_alias("fireworks_redo:spawner_blue_spiral", "fireworks_reimagined:firework_blue_spiral_0")
minetest.register_alias("fireworks_redo:spawner_white_spiral", "fireworks_reimagined:firework_white_spiral_0")


-- RED WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_red_white.png", "red_white_spiral", "fireworks_reimagined:red_white_spiral_firework_entity", 0)
-- YELLOW WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:yellow_white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFF00", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_yellow_white.png", "yellow_white_spiral", "fireworks_reimagined:yellow_white_spiral_firework_entity", 0)
-- BLUE WHITE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:blue_white_spiral_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#0404B4", "#FFFFFF", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node("fireworks_blue_white.png", "blue_white_spiral", "fireworks_reimagined:blue_white_spiral_firework_entity", 0)

-- FIREWORKS MOD COMPAT

-- RED
fireworks_reimagined.register_firework_entity("fireworks_reimagined:red_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "red", "fireworks_reimagined:red_firework_entity", 0)
-- ORANGE
fireworks_reimagined.register_firework_entity("fireworks_reimagined:orange_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#da8424", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "orange", "fireworks_reimagined:orange_firework_entity", 0)
-- GREEN
fireworks_reimagined.register_firework_entity("fireworks_reimagined:green_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#329644", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_node(nil, "green", "fireworks_reimagined:green_firework_entity", 0)
-- VIOLET
fireworks_reimagined.register_firework_entity("fireworks_reimagined:violet_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#783190", nil, "255", nil, nil)
	end
})
fireworks_reimagined.register_firework_node(nil, "violet", "fireworks_reimagined:violet_firework_entity", 0)

minetest.register_alias("fireworks:red", "fireworks_reimagined:firework_red_0")
minetest.register_alias("fireworks:orange", "fireworks_reimagined:firework_orange_0")
minetest.register_alias("fireworks:green", "fireworks_reimagined:firework_green_0")
minetest.register_alias("fireworks:violet", "fireworks_reimagined:firework_violet_0")
