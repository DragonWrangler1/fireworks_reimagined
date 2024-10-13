-- Only 0 delay can be crafted.
minetest.register_craft({
	output = "fireworks_reimagined:firework_ring_0",
	recipe = {
		{"default:stick", "dye:red", "default:stick"},
		{"dye:red", "tnt:tnt", "dye:red"},
		{"default:stick", "dye:red", "default:stick"}
	},
})
minetest.register_craft({
	output = "fireworks_reimagined:firework_sphere_0",
	recipe = {
		{"default:stick", "dye:orange", "default:stick"},
		{"dye:red", "tnt:tnt", "dye:red"},
		{"default:stick", "dye:orange", "default:stick"}
	},
})
minetest.register_craft({
	output = "fireworks_reimagined:firework_2025_0",
	recipe = {
		{"default:stick", "dye:yellow", "default:stick"},
		{"dye:yellow", "tnt:tnt", "dye:yellow"},
		{"default:stick", "dye:yellow", "default:stick"}
	},
})
