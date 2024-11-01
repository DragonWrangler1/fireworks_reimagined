local register_firework_node = fireworks_reimagined.register_firework_node
register_firework_node(nil, "sphere", nil, 0, nil, nil)
register_firework_node(nil, "star", nil, 0, nil, nil)
register_firework_node(nil, "ring", nil, 0, nil, nil)
register_firework_node(nil, "burst", nil, 0, nil, nil)
register_firework_node(nil, "cube", nil, 0, nil, nil)
register_firework_node(nil, "spiral", nil, 0, nil, nil)
register_firework_node(nil, "chaotic", nil, 0, nil, nil)
register_firework_node(nil, "flame", nil, 0, nil, nil)
register_firework_node(nil, "snowflake", nil, 0, nil, nil)
register_firework_node(nil, "christmas_tree", nil, 0, nil, nil)
register_firework_node(nil, "present", nil, 0, nil, nil)
register_firework_node(nil, "hour_glass", nil, 0, nil, nil)
if minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core") then
	register_firework_node(nil, "creeper", nil, 0, nil, nil)
end

if minetest.settings:get_bool("long_delay", true) then
	register_firework_node(nil, "sphere", nil, 10, nil, nil)
	register_firework_node(nil, "star", nil, 10, nil, nil)
	register_firework_node(nil, "ring", nil, 10, nil, nil)
	register_firework_node(nil, "burst", nil, 10, nil, nil)
	register_firework_node(nil, "cube", nil, 10, nil, nil)
	register_firework_node(nil, "spiral", nil, 10, nil, nil)
	register_firework_node(nil, "chaotic", nil, 10, nil, nil)
	register_firework_node(nil, "flame", nil, 10, nil, nil)
	register_firework_node(nil, "snowflake", nil, 10, nil, nil)
	register_firework_node(nil, "christmas_tree", nil, 10, nil, nil)
	register_firework_node(nil, "present", nil, 10, nil, nil)
	register_firework_node(nil, "hour_glass", nil, 10, nil, nil)
	if minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core") then
		register_firework_node(nil, "creeper", nil, 10, nil, nil)
	end
end
