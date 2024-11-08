local color_grid = {
--[[	{"#615200", "#f4ce00", "#c0a200", "#c0a200", "#b49800", "#000000", "#0f0d00", "#b09400", "#c4a500", "#b09400", "#0f0d00", "#000000", "#615200", "#f4ce00", "#c0a200", "#c0a200", "#b49800", "#000000", "#251f00", "#c4a500", "#c0a200", "#b89b00", "#231e00"},
	{"#010100", "#ad9200", "#594b00", "#000000", "#000000", "#000000", "#8a7400", "#726000", "#000000", "#736100", "#897400", "#000000", "#010100", "#ad9200", "#594b00", "#000000", "#000000", "#000000", "#a88e00", "#4f4300", "#000000", "#3a3100", "#bea000"},
	{"#000000", "#0c0a00", "#ccac00", "#372e00", "#000000", "#000000", "#d4b300", "#1a1600", "#000000", "#1b1700", "#d3b200", "#000000", "#000000", "#0c0a00", "#ccac00", "#372e00", "#000000", "#000000", "#201b00", "#030300", "#000000", "#030300", "#ebc600"},
	{"#000000", "#000000", "#231e00", "#d4b300", "#151200", "#000000", "#ebc600", "#020200", "#000000", "#020200", "#eac500", "#000000", "#000000", "#000000", "#231e00", "#d4b300", "#151200", "#000000", "#8e7800", "#6b5a00", "#000000", "#524500", "#bea000"},
	{"#000000", "#000000", "#000000", "#5f5000", "#9d8400", "#000000", "#ebc600", "#020200", "#000000", "#020200", "#eac500", "#000000", "#000000", "#000000", "#000000", "#5f5000", "#9d8400", "#000000", "#8f7900", "#9a8200", "#c4a500", "#b29600", "#231e00"},
	{"#282200", "#554800", "#000000", "#0b0900", "#eac500", "#000000", "#d4b300", "#1a1600", "#000000", "#1b1700", "#d3b200", "#000000", "#282200", "#554800", "#000000", "#0b0900", "#eac500", "#000000", "#766300", "#4f4300", "#000000", "#000000", "#000000"},
	{"#151200", "#c1a300", "#020200", "#282200", "#d7b500", "#000000", "#8a7400", "#726000", "#000000", "#736100", "#887300", "#000000", "#151200", "#c1a300", "#020200", "#282200", "#d7b500", "#000000", "#5d4e00", "#685800", "#000000", "#000000", "#000000"},
	{"#000000", "#625300", "#c3a400", "#d0af00", "#463b00", "#000000", "#0f0d00", "#b09400", "#c4a500", "#b09400", "#0f0d00", "#000000", "#000000", "#625300", "#c3a400", "#d0af00", "#463b00", "#000000", "#453a00", "#debb00", "#c0a200", "#c0a200", "#846f00"},]]
{"#000000","#bfa200","#bfa200","#bfa200","#bfa200","#bfa200","#000000","#000000","#bfa200","#bfa200","#bfa200","#000000","#000000","#bfa200","#bfa200","#bfa200","#bfa200","#bfa200","#000000","#000000","#bfa200","#bfa200","#bfa200","#000000","#000000"},
{"#000000","#000000","#bfa200","#bfa200","#000000","#000000","#000000","#bfa200","#bfa200","#000000","#bfa200","#bfa200","#000000","#000000","#bfa200","#bfa200","#000000","#000000","#000000","#bfa200","#000000","#000000","#000000","#bfa200","#000000"},
{"#000000","#000000","#000000","#bfa200","#000000","#000000","#000000","#bfa200","#000000","#000000","#000000","#bfa200","#000000","#000000","#000000","#bfa200","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#bfa200","#000000"},
{"#000000","#000000","#000000","#000000","#bfa200","#000000","#000000","#bfa200","#000000","#000000","#000000","#bfa200","#000000","#000000","#000000","#000000","#bfa200","#000000","#000000","#bfa200","#bfa200","#000000","#000000","#bfa200","#000000"},
{"#000000","#000000","#000000","#000000","#bfa200","#bfa200","#000000","#bfa200","#000000","#000000","#000000","#bfa200","#000000","#000000","#000000","#000000","#bfa200","#bfa200","#000000","#bfa200","#bfa200","#bfa200","#bfa200","#000000","#000000"},
{"#000000","#bfa200","#bfa200","#000000","#000000","#bfa200","#000000","#bfa200","#000000","#000000","#000000","#bfa200","#000000","#000000","#bfa200","#000000","#000000","#bfa200","#000000","#bfa200","#000000","#000000","#000000","#000000","#000000"},
{"#000000","#bfa200","#bfa200","#000000","#000000","#bfa200","#000000","#bfa200","#bfa200","#000000","#bfa200","#bfa200","#000000","#000000","#bfa200","#000000","#000000","#bfa200","#000000","#bfa200","#bfa200","#000000","#000000","#000000","#000000"},
{"#000000","#000000","#bfa200","#bfa200","#bfa200","#000000","#000000","#000000","#bfa200","#bfa200","#bfa200","#000000","#000000","#000000","#bfa200","#bfa200","#bfa200","#000000","#000000","#000000","#bfa200","#bfa200","#bfa200","#bfa200","#000000"},
	}

fireworks_reimagined.register_firework_entity("fireworks_reimagined:2025_firework_entity", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.register_firework_explosion(pos, 0.5, color_grid, 1, nil, 1)
	end
})

fireworks_reimagined.register_firework_node(nil, "2025", "fireworks_reimagined:2025_firework_entity", 10, 10)

--===============--
--=== CREEPER ===--
--===============--

local creeper = {
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
		firework_explosion = function(pos, shape)
			fireworks_reimagined.register_firework_explosion(pos, 0.5, creeper, 1, nil, 2)
		end
	})

	fireworks_reimagined.register_firework_node(nil, "creeper", "fireworks_reimagined:creeper_firework_entity", 10, 10)
end
