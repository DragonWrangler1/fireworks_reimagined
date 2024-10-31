local creeper_face = {
	{"#775e52","#775e52","#466837","#466837","#513e35","#513e35","#557c40","#557c40","#669951","#669951","#513e35","#513e35","#466837","#466837","#466837","#466837"},
	{"#775e52","#775e52","#466837","#466837","#513e35","#513e35","#557c40","#557c40","#669951","#669951","#513e35","#513e35","#466837","#466837","#466837","#466837"},
	{"#685247","#685247","#557c40","#557c40","#513e35","#513e35","#513e35","#513e35","#513e35","#513e35","#513e35","#513e35","#466837","#466837","#466837","#466837"},
	{"#685247","#685247","#557c40","#557c40","#513e35","#513e35","#513e35","#513e35","#513e35","#513e35","#513e35","#513e35","#466837","#466837","#466837","#466837"},
	{"#466837","#466837","#669951","#669951","#466837","#466837","#513e35","#513e35","#513e35","#513e35","#557c40","#557c40","#466837","#466837","#685247","#685247"},
	{"#466837","#466837","#669951","#669951","#466837","#466837","#513e35","#513e35","#513e35","#513e35","#557c40","#557c40","#466837","#466837","#685247","#685247"},
	{"#557c40","#557c40","#685247","#685247","#557c40","#557c40","#557c40","#557c40","#557c40","#557c40","#557c40","#557c40","#669951","#669951","#466837","#466837"},
	{"#557c40","#557c40","#685247","#685247","#557c40","#557c40","#557c40","#557c40","#557c40","#557c40","#557c40","#557c40","#669951","#669951","#466837","#466837"},
	{"#557c40","#557c40","#513e35","#513e35","#513e35","#513e35","#557c40","#557c40","#84ba68","#84ba68","#513e35","#513e35","#513e35","#513e35","#466837","#466837"},
	{"#557c40","#557c40","#513e35","#513e35","#513e35","#513e35","#557c40","#557c40","#84ba68","#84ba68","#513e35","#513e35","#513e35","#513e35","#466837","#466837"},
	{"#466837","#466837","#513e35","#513e35","#513e35","#513e35","#84ba68","#84ba68","#84ba68","#84ba68","#513e35","#513e35","#513e35","#513e35","#557c40","#557c40"},
	{"#466837","#466837","#513e35","#513e35","#513e35","#513e35","#84ba68","#84ba68","#84ba68","#84ba68","#513e35","#513e35","#513e35","#513e35","#557c40","#557c40"},
	{"#557c40","#557c40","#669951","#669951","#557c40","#557c40","#669951","#669951","#669951","#669951","#557c40","#557c40","#685247","#685247","#669951","#669951"},
	{"#557c40","#557c40","#669951","#669951","#557c40","#557c40","#669951","#669951","#669951","#669951","#557c40","#557c40","#685247","#685247","#669951","#669951"},
	{"#669951","#669951","#669951","#669951","#466837","#466837","#669951","#669951","#557c40","#557c40","#669951","#669951","#557c40","#557c40","#669951","#669951"},
	{"#669951","#669951","#669951","#669951","#466837","#466837","#669951","#669951","#557c40","#557c40","#669951","#669951","#557c40","#557c40","#669951","#669951"},
}

if minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core") then
	fireworks_reimagined.register_firework_entity("fireworks_reimagined:creeper_firework_entity", {
		time_remaining = 3,
		firework_explosion = function(pos, shape)
			fireworks_reimagined.register_firework_explosion(pos, 0.5, creeper_face, 2, nil)
		end
	})
	fireworks_reimagined.register_firework_node(nil, "creeper", "fireworks_reimagined:creeper_firework_entity", 0)
end
