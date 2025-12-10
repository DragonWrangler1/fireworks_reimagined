core.register_privilege("fireworks_master", {
	description = ("Allows the player with this priv to not be affected by the user cooldown on fireworks."),
	give_to_singleplayer = false,
})

core.register_privilege("fireworks_admin", {
	description = ("Administrator priv for fireworks."),
	give_to_singleplayer = false,
})

core.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	user_usage[player_name] = nil
end)

core.register_craftitem("fireworks_reimagined:fuse", {
	description = ("Fuse"),
	inventory_image = "farming_string.png^[multiply:#343434",
	groups = {flammable = 1},
})

core.register_craft({
	output = "fireworks_reimagined:fuse 9",
	recipe = {
		{"farming:string", "farming:string", "farming:string"},
		{"farming:string", "default:coal_lump", "farming:string"},
		{"farming:string", "farming:string", "farming:string"},
	}
})
