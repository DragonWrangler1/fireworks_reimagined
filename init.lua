local is_mcl_or_vlf = minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core")
local modpath = minetest.get_modpath("fireworks_reimagined")
fireworks_reimagined = {}
local firework_shapes = {
	{shape = "sphere", description = "Sphere"},
	{shape = "star", description = "Star"},
	{shape = "ring", description = "Ring"},
	{shape = "burst", description = "Burst"},
	{shape = "cube", description = "Cube"},
	{shape = "spiral", description = "Spiral"},
	{shape = "chaotic", description = "Chaotic"},
	{shape = "flame", description = "Flame"},
	{shape = "snowflake", description = "Snowflake"},
	{shape = "present", description = "Present"},
	{shape = "christmas_tree", description = "Christmas Tree"},
	{shape = "hour_glass", description = "Hour Glass"},
}

function fireworks_reimagined.register_firework_shape(shape_name, description)
    table.insert(firework_shapes, {shape = shape_name, description = description})
end

local function random_color()
	local r = math.random(0, 255)
	local g = math.random(0, 255)
	local b = math.random(0, 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

local function random_explosion_colors()
	local color1 = random_color()
	local color2 = random_color()
	if math.random(2) == 1 then
		return {color1}
	else
		return {color1, color2}
	end
end

function fireworks_reimagined.spawn_firework_explosion(pos, shape, double, color_def, color_def_2, alpha)
	local explosion_colors = random_explosion_colors()
	local radius = math.random(4, 7)
	local size = math.random(1.5, 3)
	local glow = math.random(5, 15)
	local function spawn_colored_particle(velocity)
		if not color_def then
			color = explosion_colors[math.random(#explosion_colors)]
		elseif color_def and color_def_2 then
			if math.random(2) == 1 then
				color = color_def
			else
				color = color_def_2
			end
		else
			color = color_def
		end
		if not alpha then
			alpha = 128
		end
		local colored_texture = "black.png^[colorize:" .. color .. ":" .. alpha
		local random_speed = math.random() + 0.5
		local particle_properties = {
			pos = pos,
			velocity = velocity,
			acceleration = {x = 0, y = 0, z = 0},  -- No movement initially
			expirationtime = 2.5,
			size = size,
			texture = colored_texture,
			glow = glow,
		}
		minetest.add_particle(particle_properties)
		minetest.after(0.3, function()
			local breaking_velocity = {
				x = velocity.x + math.random(-2, 2),
				y = velocity.y - 4,
				z = velocity.z + math.random(-2, 2)
			}
			local breaking_particle_properties = {
				pos = pos,
				velocity = breaking_velocity,
				acceleration = {x = 0, y = -1, z = 0},
				expirationtime = 2.2,
				size = size,
				texture = colored_texture,
				glow = glow,
			}
			minetest.add_particle(breaking_particle_properties)
			if double == true then
				minetest.add_particle(breaking_particle_properties)
			end
		end)
	end
	if shape == "sphere" then
		for i = 1, 360, 15 do
  			for j = -90, 90, 15 do
				local theta = math.rad(i)
				local phi = math.rad(j)
				local x = math.cos(phi) * math.cos(theta) * radius
				local y = math.sin(phi) * radius
				local z = math.cos(phi) * math.sin(theta) * radius
				spawn_colored_particle({x = x, y = y, z = z})
			end
		end
	elseif shape == "star" then
		local star_points = {
			{x = radius, y = 0, z = 0},
			{x = -radius, y = 0, z = 0},
			{x = 0, y = radius, z = 0},
			{x = 0, y = -radius, z = 0},
			{x = 0, y = 0, z = radius},
			{x = 0, y = 0, z = -radius},
		}
		for _, point in ipairs(star_points) do
			spawn_colored_particle(point)
  		end
	elseif shape == "ring" then
		for i = 1, 360, 15 do
			local theta = math.rad(i)
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			local y = 0
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "christmas_tree" then
		local height = 10
		local base_radius = 4
		for i = 1, height do
			local current_radius = base_radius * (1 - i / height)
			for j = 1, 360, 30 do
				local theta = math.rad(j)
				local x = math.cos(theta) * current_radius
				local z = math.sin(theta) * current_radius
				spawn_colored_particle({x = x, y = i, z = z})
			end
		end
	elseif shape == "present" then
		for x = -radius, radius, radius do
			for y = -radius, radius, radius do
 				for z = -radius, radius, radius do
					spawn_colored_particle({x = x, y = y, z = z})
				end
			end
		end
		for i = 1, 360, 30 do
			local theta = math.rad(i)
			local x = math.cos(theta) * (radius / 2)
			local z = math.sin(theta) * (radius / 2)
 			local y = radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "snowflake" then
		local arms = 6
		for i = 1, arms do
			local angle = (2 * math.pi / arms) * i
			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			for j = 1, radius do
				spawn_colored_particle({x = x * (j / radius), y = 0, z = z * (j / radius)})
			end
		end
	elseif shape == "spiral" then
		local spiral_height = 10
		local spiral_turns = 5
		for i = 1, 360 * spiral_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * spiral_height
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "hour_glass" then
		local num_turns = 10
		for i = 1, 360 * num_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * num_turns
			local radius = 10 - (y / 2) -- Vary radius over time
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "chaotic" then
		local num_particles = 150
		for i = 1, num_particles do
			local x = (math.random() - 0.5) * 2 * radius
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius
			local rs = math.random() + 0.5
			local random_velocity = {x = x + math.random(-3, 3) * rs, y = y + math.random(-3, 3) * rs, z = z + math.random(-3, 3) * rs}
			spawn_colored_particle(random_velocity)
		end
	elseif shape == "cube" then
		for x = -radius, radius, radius do
			for y = -radius, radius, radius do
				for z = -radius, radius, radius do
 					spawn_colored_particle({x = x, y = y, z = z})
 				end
			end
		end
	elseif shape == "flame" then
		local flame_height = 10
		local base_radius = 3
		for i = 1, 100 do
			local theta = math.rad(math.random(360))
			local r = math.random() * base_radius
			local x = math.cos(theta) * r
			local z = math.sin(theta) * r
			local y = math.random() * flame_height
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "burst" then
		for i = 1, 100 do
			local x = (math.random() - 0.5) * 2 * radius
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	end
end

function fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers)
	local radius = 1.5
	local function spawn_colored_particle(offset, color)
		local x = (math.random() - 0.5) * 2 * radius
		local y = (math.random() - 0.5) * 2 * radius
		local z = (math.random() - 0.5) * 2 * radius
		local random_velocity = {x = x + math.random(-3, 3), y = y + math.random(-3, 3), z = z + math.random(-3, 3)}
		local particle_properties = {
			pos = vector.add(pos, offset),
			velocity = {x=0, y=0, z=0},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = delay,
			collisiondetection = false,
			vertical = false,
			size = 1.5,
			texture = "black.png^[colorize:" .. color,
			glow = 10,
		}
		minetest.add_particle(particle_properties)
		minetest.after(delay, function()
			particle_properties.velocity = random_velocity
			particle_properties.expirationtime = 2.5 - delay
			minetest.add_particle(particle_properties)
		end)
	end

	-- Variables for scaling and size
	local pixel_scale = 0.5 / 2
	local size_multiplier = 1.5

	-- Create fireworks based on the color grid and depth layers
	for z = 0, depth_layers do
		for y = 1, #color_grid do
			for x = 1, #color_grid[y] do
				local color = color_grid[y][x]
				for dx = 0, 1 do
					for dy = 0, 1 do
						spawn_colored_particle({
							x = (x * size_multiplier) + (dx * pixel_scale * size_multiplier),
							y = (y * size_multiplier) + (dy * pixel_scale * size_multiplier),
							z = z * size_multiplier
						}, color)
					end
				end
			end
		end
	end
end

minetest.register_entity("fireworks_reimagined:firework_entity", {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		visual = "sprite",
		textures = {"fireworks_rocket_white.png"},
		velocity = 0.5,
		glow = 5,
	},
	firework_shape = "sphere",
	time_remaining = 2,
	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end
		pos.y = pos.y + (self.initial_properties.velocity * dtime)
		self.object:set_velocity({x = 0, y = 20, z = 0})
		self.time_remaining = self.time_remaining - dtime
		if self.time_remaining <= 0 then
			fireworks_reimagined.spawn_firework_explosion(pos, self.firework_shape or "sphere", false)
			self.object:remove()
			minetest.sound_play("fireworks_explosion", {
				pos = pos,
				max_hear_distance = 60,
				gain = 20.0
			})
		end
	end,
})

local function spawn_firework_entity(pos, firework_shape)
	local obj = minetest.add_entity(pos, "fireworks_reimagined:firework_entity")
	if obj then
		obj:get_luaentity().firework_shape = firework_shape
	end
end

local last_rightclick_time = {}
local last_mesecons_time = {}

function fireworks_reimagined.register_firework_node(tiles, shape, entity, delay)
	minetest.register_node(":fireworks_reimagined:firework_" .. shape .. "_" .. delay, {
		description = "Firework (" .. shape .. ") Delay: ( " .. delay .. " )",
		tiles = { tiles or "fireworks_" .. shape .. ".png" },
		groups = { cracky = 1, oddly_breakable_by_hand = 1 },
		paramtype = "light",
		light_source = 5,
		on_rightclick = function(pos, node, clicker)
			local pos_hash = minetest.hash_node_position(pos)
			local current_time = minetest.get_gametime()
			if not last_rightclick_time[pos_hash] or current_time - last_rightclick_time[pos_hash] >= 3 then
				last_rightclick_time[pos_hash] = current_time
				minetest.after(delay, function()
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						firework_entity:get_luaentity().firework_shape = shape
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end)
			else
				minetest.chat_send_player(clicker:get_player_name(), "Please wait before launching another firework!")
			end
		end,
		mesecons = { effector = {
			rules = rules,
			action_on = function(pos, node)
				local pos_hash = minetest.hash_node_position(pos)
				local current_time = minetest.get_gametime()
				if not last_mesecons_time[pos_hash] or current_time - last_mesecons_time[pos_hash] >= 4 then
					last_mesecons_time[pos_hash] = current_time
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						firework_entity:get_luaentity().firework_shape = shape
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end
			end,
		}},
	})
end

local register_firework_node = fireworks_reimagined.register_firework_node
register_firework_node(nil, "sphere", nil, 0)
register_firework_node(nil, "star", nil, 0)
register_firework_node(nil, "ring", nil, 0)
register_firework_node(nil, "burst", nil, 0)
register_firework_node(nil, "cube", nil, 0)
register_firework_node(nil, "spiral", nil, 0)
register_firework_node(nil, "chaotic", nil, 0)
register_firework_node(nil, "flame", nil, 0)
register_firework_node(nil, "snowflake", nil, 0)
register_firework_node(nil, "christmas_tree", nil, 0)
register_firework_node(nil, "present", nil, 0)
register_firework_node(nil, "hour_glass", nil, 0)
if minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core") then
	register_firework_node(nil, "creeper", nil, 0)
end

if minetest.settings:get_bool("long_delay", true) then
	register_firework_node(nil, "sphere", nil, 10)
	register_firework_node(nil, "star", nil, 10)
	register_firework_node(nil, "ring", nil, 10)
	register_firework_node(nil, "burst", nil, 10)
	register_firework_node(nil, "cube", nil, 10)
	register_firework_node(nil, "spiral", nil, 10)
	register_firework_node(nil, "chaotic", nil, 10)
	register_firework_node(nil, "flame", nil, 10)
	register_firework_node(nil, "snowflake", nil, 10)
	register_firework_node(nil, "christmas_tree", nil, 10)
	register_firework_node(nil, "present", nil, 10)
	register_firework_node(nil, "hour_glass", nil, 10)
	if minetest.get_modpath("mcl_core") or minetest.get_modpath("vlf_core") then
		register_firework_node(nil, "creeper", nil, 10)
	end
end

local function spawn_random_firework(pos)
	local shapes = {"sphere", "star", "ring", "burst", "cube", "spiral", "chaotic", "flame", "snowflake", "present", "christmas_tree"}
	local random_shape = shapes[math.random(#shapes)]
	spawn_firework_entity(pos, random_shape)
end

local usage_limit = 3
local cooldown_time = 4
local user_usage = {}

minetest.register_craftitem("fireworks_reimagined:firework_item", {
	description = "Firework (Random)",
	inventory_image = "fireworks_item.png",
	on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()
		local current_time = minetest.get_gametime()
		
		-- Initialize user usage data if not set
		if not user_usage[player_name] then
			user_usage[player_name] = {
				uses = 0,
				last_used = 0,
			}
		end

		local usage_data = user_usage[player_name]

		-- Check if the cooldown period has passed, and reset usage if it has
		if current_time - usage_data.last_used >= cooldown_time then
			usage_data.uses = 0
			usage_data.last_used = current_time
		end

		-- Allow usage if it's below the limit
		if usage_data.uses < usage_limit then
			local pos = user:get_pos()
			pos.y = pos.y + 1.5
			spawn_random_firework(pos)
			itemstack:take_item()
			usage_data.uses = usage_data.uses + 1
			return itemstack
		else
			minetest.chat_send_player(player_name, "You can only use this item 3 times every 4 seconds.")
			return itemstack
		end
	end,
})

-- Clean up usage data when player leaves the game
minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	user_usage[player_name] = nil
end)


--===========--
--=== API ===--
--===========--

local registered_fireworks = {}
function fireworks_reimagined.register_firework_entity(name, def)
	local entity_def = {
		initial_properties = {
			physical = false,
			collide_with_objects = false,
			visual = "sprite",
			textures = {"fireworks_rocket_white.png"},
			velocity = 0.5,
			glow = 5,
		},
		firework_shape = def.firework_shape or "sphere",
		time_remaining = def.time_remaining or 2,
		spiral = def.spiral or false,
		spiral_angle = def.spiral_angle or 100,
		spiral_radius = def.spiral_radius or 80,
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			if not pos then return end
			pos.y = pos.y + (self.initial_properties.velocity * dtime)
			if self.spiral then
				self.spiral_angle = self.spiral_angle + (math.pi / 8)
				local offset_x = math.cos(self.spiral_angle) * self.spiral_radius
				local offset_z = math.sin(self.spiral_angle) * self.spiral_radius
				self.object:set_velocity({x = offset_x, y = 18, z = offset_z})
				self.spiral_radius = self.spiral_radius + (0.01 * dtime)
			else
				self.object:set_velocity({x = 0, y = 20, z = 0})
			end
			self.time_remaining = self.time_remaining - dtime
			if self.time_remaining <= 0 then
				local explosion_fn = def.firework_explosion
				explosion_fn(pos)
				self.object:remove()
				minetest.sound_play("fireworks_explosion", {
					pos = pos,
					max_hear_distance = 60,
					gain = 20.0
				})
			end
		end,
	}
	minetest.register_entity(":"..name, entity_def)
	registered_fireworks[name] = entity_def
end

fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_firework_entity", {
	time_remaining = 3,
	firework_explosion = function(pos, shape)
		minetest.chat_send_all("Custom explosion at " .. minetest.pos_to_string(pos) .. " with shape " .. shape)
	end
})

fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_firework_entity_2", {
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FFFFFF", "#FF0000", "255")
	end
})

fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_3_firework_entity", {
	spiral = true,
	firework_explosion = function(pos, shape)
		fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", nil, "255")
	end
})

fireworks_reimagined.register_firework_node(nil, "test", "fireworks_reimagined:test_firework_entity", 0)
fireworks_reimagined.register_firework_node(nil, "test_2", "fireworks_reimagined:test_firework_entity_2", 0)
fireworks_reimagined.register_firework_node(nil, "test_3", "fireworks_reimagined:test_3_firework_entity", 0)

if minetest.get_modpath("mesecons") then
	local rules = mesecon.rules.pplate
end

dofile(modpath.."/creeper.lua")
dofile(modpath.."/crafting.lua")
dofile(modpath.."/colored.lua")
dofile(modpath.."/2025.lua")
