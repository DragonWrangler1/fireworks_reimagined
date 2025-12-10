local usage_limit = 3
local cooldown_time = 4
local user_usage = {}

local function spawn_firework_entity(pos, firework_shape)
	local obj = core.add_entity(pos, "fireworks_reimagined:firework_entity")
	if obj then
		obj:get_luaentity().firework_shape = firework_shape
	end
end

local function spawn_random_firework(pos)
	local shapes = {"sphere", "star", "ring", "burst", "spiral", "chaotic", "flame", "snowflake", "hour_glass"}
	local random_shape = shapes[math.random(#shapes)]
	spawn_firework_entity(pos, random_shape)
end

core.register_craftitem("fireworks_reimagined:firework_item", {
	description = "Firework (Random)",
	inventory_image = "fireworks_item.png",
	on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()
		local current_time = core.get_gametime()
		
		local privs = core.get_player_privs(player_name)
		if privs.fireworks_master or privs.fireworks_admin then
			local pos = user:get_pos()
			pos.y = pos.y + 1.5
			spawn_random_firework(pos)
			itemstack:take_item()
			return itemstack
		end
		if not user_usage[player_name] then
			user_usage[player_name] = {
				uses = 0,
				last_used = 0,
			}
		end

		local usage_data = user_usage[player_name]
		if current_time - usage_data.last_used >= cooldown_time then
			usage_data.uses = 0
			usage_data.last_used = current_time
		end
		if usage_data.uses < usage_limit then
			local pos = user:get_pos()
			pos.y = pos.y + 1.5
			spawn_random_firework(pos)
			itemstack:take_item()
			usage_data.uses = usage_data.uses + 1
			return itemstack
		else
			core.chat_send_player(player_name, "You can only use this item " .. usage_limit .. " times every " .. cooldown_time .. " seconds.")
			return itemstack
		end
	end,
})

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
