core.register_privilege("fireworks_master", {
	description = ("Allows the player with this priv to not be affected by the user cooldown on fireworks."),
	give_to_singleplayer = false,
})

core.register_privilege("fireworks_admin", {
	description = ("Administrator priv for fireworks."),
	give_to_singleplayer = false,
})

core.register_craftitem("fireworks_reimagined:fuse", {
	description = ("Fuse"),
	inventory_image = "farming_string.png^[multiply:#343434",
	groups = {flammable = 1},
})

local has_farming = core.get_modpath("farming") ~= nil
local has_mcl = core.get_modpath("mcl_core") ~= nil
local string_item = has_farming and "farming:string" or (has_mcl and "mcl_core:string" or "default:stick")
local coal_item = has_mcl and "mcl_core:coal" or "default:coal_lump"

core.register_craft({
	output = "fireworks_reimagined:fuse 9",
	recipe = {
		{string_item, string_item, string_item},
		{string_item, coal_item, string_item},
		{string_item, string_item, string_item},
	}
})
