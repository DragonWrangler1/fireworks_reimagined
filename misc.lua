core.register_privilege("fireworks_master", {
	description = ("Allows the player with this priv to launch fireworks without fuses, launch cooldowns, or nearby-rocket limits."),
	give_to_singleplayer = false,
})

core.register_privilege("fireworks_admin", {
	description = ("Administrator priv for fireworks (configuration, protected launches, and limit bypass)."),
	give_to_singleplayer = false,
})

local has_farming = core.get_modpath("farming") ~= nil
local has_mcl = core.get_modpath("mcl_core") ~= nil
local has_default = core.get_modpath("default") ~= nil

local string_texture = "fireworks_enhanced_spark.png^[multiply:#343434"
local string_item
local coal_item

if has_mcl then
	string_texture = "mcl_mobitems_string.png^[multiply:#343434"
	string_item = "mcl_mobitems:string"
	coal_item = "mcl_core:coal_lump"
elseif has_farming then
	string_texture = "farming_string.png^[multiply:#343434"
	string_item = "farming:string"
	coal_item = "default:coal_lump"
elseif has_default then
	string_item = "default:stick"
	coal_item = "default:coal_lump"
end

core.register_craftitem("fireworks_reimagined:fuse", {
	description = ("Fuse"),
	inventory_image = string_texture,
	groups = {flammable = 1},
})

-- Only register the recipe when both items are known to exist on this game.
if string_item and coal_item then
	core.register_craft({
		output = "fireworks_reimagined:fuse 9",
		recipe = {
			{string_item, string_item, string_item},
			{string_item, coal_item, string_item},
			{string_item, string_item, string_item},
		}
	})
end