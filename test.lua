fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_firework_entity", {

	time_remaining = 3,
	firework_explosion = function(pos, shape)
		minetest.chat_send_all("Custom explosion at " .. minetest.pos_to_string(pos) .. " with shape " .. shape)
	end
})

fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_firework_entity_2", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFFFF", "#FF0000", "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_3_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", nil, "255", nil, nil)
	end
})

fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_4_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFF00", nil, "255", "fireworks_redo_particle2.png", math.random(3,4))
	end
})

fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_5_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#00FFFF", nil, "255", "fireworks_spark_white.png", math.random(5,6))
	end
})

fireworks_reimagined.register_firework_node(nil, "test", "fireworks_reimagined:test_firework_entity", 0, nil, nil)
fireworks_reimagined.register_firework_node(nil, "test_2", "fireworks_reimagined:test_firework_entity_2", 0, nil, nil)
fireworks_reimagined.register_firework_node(nil, "test_3", "fireworks_reimagined:test_3_firework_entity", 0, nil, nil)
fireworks_reimagined.register_firework_node(nil, "test_4", "fireworks_reimagined:test_4_firework_entity", 0, nil, nil)
fireworks_reimagined.register_firework_node(nil, "test_5", "fireworks_reimagined:test_5_firework_entity", 0, nil, nil)
