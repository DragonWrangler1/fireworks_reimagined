local registered_fireworks = {}
local default_max_fireworks = tonumber(core.settings:get("fireworks_max_rockets")) or 5
local default_scan_radius = tonumber(core.settings:get("fireworks_scan_radius")) or 8

local function can_activate(pos, radius, max_fireworks)
	radius = radius or default_scan_radius
	local pmin = vector.offset(pos, -radius, 0, -radius)
	local pmax = vector.offset(pos, radius, 80, radius)

	local count = 0
	-- luacheck: new read globals core.objects_in_area
	for ref in core.objects_in_area(pmin, pmax) do
		if ref:get_luaentity() and registered_fireworks[ref:get_luaentity().name] then
			count = count + 1
		end
	end

	return count < (max_fireworks or default_max_fireworks)
end

local function launch_firework(pos, entity, shape, ip, c1, c2)
	local firework_entity = core.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
	if firework_entity then
		if ip ~= (nil or false) then
			firework_entity:get_luaentity().ip = true
		end
		firework_entity:get_luaentity().firework_shape = shape
		firework_entity:get_luaentity().color1 = c1
		firework_entity:get_luaentity().color2 = c2
		core.sound_play("fireworks_launch", {
			pos = pos,
			max_hear_distance = 40,
			gain = 4.0
		})
		local entity_data = firework_entity:get_luaentity()
		local flight_time = entity_data.time_remaining or 3
		core.add_particlespawner({
			amount = 75 * flight_time,
			time = flight_time,
			minpos = {x=-0.2, y=-0.2, z=-0.2},
			maxpos = {x=0.2, y=0.2, z=0.2},
			minvel = {x=-0.1, y=3, z=-0.1},
			maxvel = {x=0.1, y=4, z=0.1},
			minacc = {x=0, y=-9.81, z=0},
			maxacc = {x=0, y=-9.81, z=0},
			glow = 12,
			minexptime = 1,
			maxexptime = 2,
			minsize = 1,
			maxsize = 3,
			collisiondetection = false,
			attached = firework_entity,
			texpool = {
				{name = "fireworks_spark_white.png^[colorize:#C59F15"},
				{name = "fireworks_spark_white.png^[colorize:#C54915"},
				{name = "fireworks_spark_white.png^[colorize:#84120A"},
			},
		})
	end
end

function fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers, texture, batch_size, log)
	
	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	local size_multiplier = 2.2
	local particle_lifetime = 2.5 - delay
	local radius = math.max(grid_width, grid_height) * size_multiplier * 0.8
	local b_size = batch_size or 1
	local color_particles = {}
	
	-- Extract dominant colors from the grid for effects
	local dominant_colors = {}
	local color_counts = {}
	
	for z = 0, depth_layers do
		for y = 1, grid_height do
			for x = 1, grid_width do
				local color = color_grid[y][x]
				if color ~= "#000000" then
					color_particles[color] = color_particles[color] or {}
					
					local pixel_offset = size_multiplier * 0.5
					local offsets = {
						{-pixel_offset * 0.5, -pixel_offset * 0.5, 0},
						{pixel_offset * 0.5, -pixel_offset * 0.5, 0},
						{-pixel_offset * 0.5, pixel_offset * 0.5, 0},
						{pixel_offset * 0.5, pixel_offset * 0.5, 0},
					}
					
					for _, offset in ipairs(offsets) do
						local particle_pos = vector.add(pos, vector.new(
							(x - (grid_width / 2)) * size_multiplier + offset[1],
							(y - (grid_height / 2)) * size_multiplier + offset[2],
							(z - (depth_layers / 2)) * size_multiplier + offset[3]
						))
						table.insert(color_particles[color], particle_pos)
						color_counts[color] = (color_counts[color] or 0) + 1
					end
				end
			end
		end
	end
	
	-- Find the most dominant colors for effects
	local sorted_colors = {}
	for color, count in pairs(color_counts) do
		table.insert(sorted_colors, {color = color, count = count})
	end
	table.sort(sorted_colors, function(a, b) return a.count > b.count end)
	
	local primary_color = sorted_colors[1] and sorted_colors[1].color or "#FFFFFF"
	local secondary_color = sorted_colors[2] and sorted_colors[2].color or primary_color
	local tertiary_color = sorted_colors[3] and sorted_colors[3].color or secondary_color
	local total_spawners = 0
	
	-- ===== STAGE 1: INITIAL FLASH AND CORE IGNITION =====
	core.after(delay * 0.5, function()
		core.add_particle({
			pos = pos,
			velocity = {x = 0, y = 0, z = 0},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = 0.4,
			size = radius * 2.0,
			texture = {
				name = "fireworks_white.png^[colorize:" .. secondary_color .. ":100",
				scale_tween = {
					style = "fwd",
					reps = 1,
					2.5,
					0.0,
					-0.1
				}
			},
			glow = 12,
			collisiondetection = false,
		})
		total_spawners = total_spawners + 1
	end)
	
	-- ===== STAGE 2: PRIMARY GRID EXPLOSION =====
	core.after(delay, function()
		for color, positions in pairs(color_particles) do
			local colored_texture = texture and (texture .. "^[colorize:" .. color) or ("black.png^[colorize:" .. color)
			for i = 1, #positions, b_size do
				local batch_positions = {}
				for j = i, math.min(i + b_size - 1, #positions) do
					table.insert(batch_positions, positions[j])
				end
				local world_minpos = vector.new(1e10, 1e10, 1e10)
				local world_maxpos = vector.new(-1e10, -1e10, -1e10)
				for _, pos_item in ipairs(batch_positions) do
					world_minpos = vector.new(
						math.min(world_minpos.x, pos_item.x),
						math.min(world_minpos.y, pos_item.y),
						math.min(world_minpos.z, pos_item.z)
					)
					world_maxpos = vector.new(
						math.max(world_maxpos.x, pos_item.x),
						math.max(world_maxpos.y, pos_item.y),
						math.max(world_maxpos.z, pos_item.z)
					)
				end
				
				local particle_properties = {
					pos = world_minpos,
					velocity = {x = math.random(-8,8), y = 3, z = math.random(-9, 9)},
					acceleration = {x=0, y=-9.81, z=0},
					expirationtime = math.random(2, 4),
					size = math.random(1.5, 3),
					texture = {
						name = colored_texture,
						scale_tween = {
							style = "fwd",
							reps = 1,
							1.4,
							1.0,
							0.2,
							start = 0.0,
							finish = 1.0
						},
						alpha_tween = {
							style = "fwd",
							reps = 1,
							255,
							200,
							0,
							start = 0.0,
							finish = 1.0
						}
					},
					glow = math.random(13, 16),
					drag = vector.new(0.04, 0.02, 0.04),
				}
				
				core.add_particle(particle_properties)
				total_spawners = total_spawners + 1
			end
		end
	end)
	
	-- ===== STAGE 3: ATMOSPHERIC PRESSURE WAVES =====
	-- Multi-ring pressure wave system
	local wave_rings = 4
	for ring = 1, wave_rings do
		core.after(delay + 0.05 + (ring * 0.12), function()
			local wave_radius = radius * (1.5 + ring * 1.2)
			local wave_particles = math.floor(60 - ring * 10)
			
			for i = 1, wave_particles do
				local wave_angle = (i / wave_particles) * math.pi * 2
				local wave_pos = {
					x = pos.x + math.cos(wave_angle) * wave_radius,
					y = pos.y + math.random(-3, 3),
					z = pos.z + math.sin(wave_angle) * wave_radius
				}
				
				core.add_particle({
					pos = wave_pos,
					velocity = {
						x = math.cos(wave_angle) * (2 - ring * 0.3),
						y = math.random(-80, 80) / 100,
						z = math.sin(wave_angle) * (2 - ring * 0.3)
					},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = 1.8,
					size = (1.5 - ring * 0.2),
					texture = {
						name = "fireworks_white.png^[colorize:#DDDDDD:" .. (60 - ring * 10),
						scale_tween = {
							style = "fwd",
							reps = 1,
							0.3,
							2.0,
							0.0
						},
					},
					glow = 4 - ring,
					collisiondetection = false,
				})
				total_spawners = total_spawners + 1
			end
		end)
	end
	
	-- Performance tracking
	if log == true then
		core.after(6.0, function()
			core.log("warning", "Total particle spawners used: " .. total_spawners)
		end)
	end
end

local color_palette = {
	{name = "White", hex = "#FFFFFF"},
	{name = "Yellow", hex = "#FFFF00"},
	{name = "Blue", hex = "#0404B4"},
	{name = "Red", hex = "#FF0000"},
	{name = "Orange", hex = "#FF903F"},
	{name = "Green", hex = "#008000"},
	{name = "Violet", hex = "#6600CC"},
	{name = "Cyan", hex = "#00C0C0"},
	{name = "Magenta", hex = "#FF00FF"},
	{name = "Pink", hex = "#FF69B4"},
	{name = "DarkGreen", hex = "#004D00"},
}

fireworks_reimagined.color_palette = color_palette

local function encode_colors(color1_idx, color2_idx)
	return (color1_idx - 1) * 8 + (color2_idx - 1)
end

local function decode_colors(param2)
	local c1_idx = math.floor(param2 / 16) + 1
	local c2_idx = (param2 % 16) + 1
	return c1_idx, c2_idx
end

local function get_color_by_index(idx)
	if idx < 1 or idx > #color_palette then
		return color_palette[1].hex
	end
	return color_palette[idx].hex
end

fireworks_reimagined.encode_colors = encode_colors
fireworks_reimagined.decode_colors = decode_colors
fireworks_reimagined.get_color_by_index = get_color_by_index

function fireworks_reimagined.register_firework_node(tiles, shape, entity, cooldown, mese_cooldown, ip, options)
	options = options or {}
	core.register_alias("fireworks_reimagined:firework_" .. shape .. "_0", "fireworks_reimagined:firework_" .. shape)
	core.register_alias("fireworks_reimagined:firework_" .. shape .. "_10", "fireworks_reimagined:firework_" .. shape)
	
	local primary_color_idx = options.primary_color or 1
	local primary_color_hex = get_color_by_index(primary_color_idx)
	
	local node_tiles
	if options.tiles then
		node_tiles = options.tiles
	elseif tiles then
		node_tiles = type(tiles) == "string" and { tiles } or tiles
	else
		node_tiles = { "black.png^fireworks_overlay_1.png^fireworks_overlay_2.png" }
	end
	
	local node_def = {
		description = options.description or ("Firework (" .. shape .. ")"),
		tiles = node_tiles,
		groups = { cracky = 1, oddly_breakable_by_hand = 1 , firework = 1, 
					handy = 1, axey = 1, material_wood = 1,
					building_block = 1
		},
		paramtype = "light",
		paramtype2 = "color",
		palette = "fireworks_reimagined_palette.png",
		light_source = 5,
		_mcl_blast_resistance = 1,
		_mcl_hardness = 1,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local param2 = core.get_node(pos).param2
			
			local c1 = primary_color_hex
			local c2_idx = (param2 % 16) + 1
			local c2 = get_color_by_index(c2_idx)
			
			local meta = core.get_meta(pos)
			meta:set_string("allow_others", "false")
			meta:set_string("owner", placer:get_player_name())
			meta:set_string("c1", c1)
			meta:set_string("c2", c2)
		end,
		on_punch = function(pos, node, clicker)
			local wielded_item = clicker:get_wielded_item():get_name()
			if wielded_item == "" then
				local meta = core.get_meta(pos)
				local owner = meta:get_string("owner")
				local player_name = clicker:get_player_name()
				local privs = core.get_player_privs(player_name)
				local is_owner = player_name == owner or privs.fireworks_master
				local inv = meta:get_inventory()
				if inv:is_empty("fuse") then
					inv:set_size("fuse", 1)
				end
				
				local has_mcl = core.get_modpath("mcl_core") ~= nil
				local has_mcl_formspec = core.get_modpath("mcl_formspec") ~= nil
				
				if is_owner then
					local formspec
					if has_mcl and has_mcl_formspec then
						formspec = fireworks_reimagined.build_mcl_settings_formspec(pos, player_name, is_owner, privs)
					else
						local spos = pos.x .. "," .. pos.y .. "," .. pos.z
						if not privs.fireworks_admin then
							formspec = table.concat({
									"formspec_version[6]",
									"size[11,9]",
									"label[4.5,0.6;Settings]",
									"checkbox[0.7,3;allow_others;Allow others to launch this firework;" .. meta:get_string("allow_others") .. "]",
									"list[nodemeta:" .. spos .. ";fuse;9.45,2.5;1,1]",
									"list[current_player;main;0.7,3.8;8,4]",
									"button_exit[0.7,0.4;2,1;save;<]",
									"listring[nodemeta:" .. spos .. ";fuse]",
							})
						else
							formspec = table.concat({
									"formspec_version[6]",
									"size[8,5]",
									"label[0.4,0.7;Settings]",
									"checkbox[0.4,1.5;allow_others;Allow others to launch this firework;".. meta:get_string("allow_others") .."]",
									"field[0.4,2.5;7,0.5;delay;Launch Delay (seconds);".. meta:get_int("delay") .."]",
									"button_exit[2.9,3.4;2,1;save;Close]"
							})
						end
					end
					core.show_formspec(player_name, "fireworks_reimagined:settings_" .. core.pos_to_string(pos), formspec)
				end
			else
				return false
			end
		end,
		on_rightclick = function(pos, node, clicker)
			local meta = core.get_meta(pos)
			local now = core.get_gametime()
			local owner = meta:get_string("owner")
			local player_name = clicker:get_player_name()
			local privs = core.get_player_privs(player_name)
			local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
			local allow_others = meta:get_string("allow_others") == "true"
			local is_allowed = is_owner or allow_others or privs.fireworks_master or privs.fireworks_admin
			local inv = meta:get_inventory()
			if inv:is_empty("fuse") then
				inv:set_size("fuse", 1)
			end
			local function is_valid_hex(color)
			-- Accepts #RGB or #RRGGBB
			return type(color) == "string"
				and (color:match("^#%x%x%x$") or color:match("^#%x%x%x%x%x%x$")) ~= nil
			end

			local c1_raw = meta:get_string("c1")
			local c2_raw = meta:get_string("c2")

			local c1 = is_valid_hex(c1_raw) and c1_raw or "#FFFFFF"
			local c2 = is_valid_hex(c2_raw) and c2_raw or c1

			if meta:get_string("owner") == "" then
				meta:set_string("owner", player_name)
			end

			local prev_emit_count = meta:get_int("emit_count")
			meta:set_int("emit_count", 0)
			if prev_emit_count >= 10 then
				meta:set_string("infotext", "")
			end

			local fuse_stack = inv:get_stack("fuse", 1)
			local fuse_count = fuse_stack:get_count()
			local delay
			if not privs.fireworks_admin then
				delay = fuse_count
			elseif privs.fireworks_admin then
				delay = meta:get_int("delay")
			end

			if is_allowed and (can_activate(pos)) then
				inv:set_stack("fuse", 1, nil)
				meta:set_int("busy_until", now + delay + 1)
				core.after(delay, function()
					launch_firework(pos, entity, shape, ip, c1, c2)
					if core.get_modpath("mesecons") then
						mesecon.receptor_on(pos, mesecon.rules.pplate)
						core.after(1, function()
							mesecon.receptor_off(pos, mesecon.rules.pplate)
						end)
					end
				if core.get_modpath("mcl_redstone") then
					local current_node = core.get_node(pos)
					if core.get_item_group(current_node.name, "firework") == 1 then
						local color_bits = current_node.param2 % 16
						mcl_redstone.swap_node(pos, {
							name = current_node.name,
							param1 = current_node.param1,
							param2 = color_bits + 16
						})
						core.after(1, function()
							local reset_node = core.get_node(pos)
							if core.get_item_group(reset_node.name, "firework") == 1 then
								local reset_color_bits = reset_node.param2 % 16
								mcl_redstone.swap_node(pos, {
									name = reset_node.name,
									param1 = reset_node.param1,
									param2 = reset_color_bits
								})
							end
						end)
					end
				end
				end)
			elseif not is_allowed then
				core.chat_send_player(player_name, "You don't have permission to launch this firework.")
			elseif privs.fireworks_master or privs.fireworks_admin then
				meta:set_int("busy_until", now + delay + 1)
				core.after(delay, function()
					launch_firework(pos, entity, shape, ip, c1, c2)
					if core.get_modpath("mesecons") then
						mesecon.receptor_on(pos, mesecon.rules.pplate)
						core.after(1, function()
							mesecon.receptor_off(pos, mesecon.rules.pplate)
						end)
					end
				if core.get_modpath("mcl_redstone") then
					local current_node = core.get_node(pos)
					if core.get_item_group(current_node.name, "firework") == 1 then
						local color_bits = current_node.param2 % 16
						mcl_redstone.swap_node(pos, {
							name = current_node.name,
							param1 = current_node.param1,
							param2 = color_bits + 16
						})
						core.after(1, function()
							local reset_node = core.get_node(pos)
							if core.get_item_group(reset_node.name, "firework") == 1 then
								local reset_color_bits = reset_node.param2 % 16
								mcl_redstone.swap_node(pos, {
									name = reset_node.name,
									param1 = reset_node.param1,
									param2 = reset_color_bits
								})
							end
						end)
					end
				end
					inv:set_stack("fuse", 1, nil)
				end)
			else
				core.chat_send_player(player_name, "Please wait before launching another firework!")
			end
		end,
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			if listname == "fuse" and stack:get_name() == "fireworks_reimagined:fuse" then
				local meta = core.get_meta(pos)
				local inv = meta:get_inventory()
				local fuse_stack = inv:get_stack("fuse", 1)
				if fuse_stack:get_count() > 15 then
					fuse_stack:set_count(15)
					inv:set_stack("fuse", 1, fuse_stack)
				end
			end
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			if listname == "fuse" and stack:get_name() == "fireworks_reimagined:fuse" then
				local meta = core.get_meta(pos)
				local inv = meta:get_inventory()
				local current_stack = inv:get_stack("fuse", index)
				local space_left = math.max(0, 15 - current_stack:get_count())
				return math.min(stack:get_count(), space_left)
			end
			return 0
		end,
		on_dig = function(pos, node, digger)
			local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
			if not inv:is_empty("fuse") then
				local fuse_stack = inv:get_stack("fuse", 1)
				local fuse_count = fuse_stack:get_count()
				if fuse_count > 0 then
					core.item_drop(fuse_stack, digger, pos)
				end
			end
			return core.node_dig(pos, node, digger)
		end,
	}
	
	if options.on_punch then node_def.on_punch = options.on_punch end
	if options.on_rightclick then node_def.on_rightclick = options.on_rightclick end
	if options.on_dig then node_def.on_dig = options.on_dig end
	if options.on_place then node_def.on_place = options.on_place end
	if options.overlay_tiles then node_def.overlay_tiles = options.overlay_tiles end
	
	if core.get_modpath("mesecons") then
		node_def.mesecons = {
			effector = {
				rules = mesecon.rules.pplate,

				action_on = function(pos, node)
					local meta = core.get_meta(pos)
					local now = core.get_gametime()

					-- Timestamp lock (1 second)
					if meta:get_int("busy_until") > now then
						return false
					end

					if not can_activate(pos) then
						return false
					end

					local emit_count = meta:get_int("emit_count")
					if emit_count >= 10 then
						meta:set_string("infotext", "Right-click to resume mesecons usage")
						return false
					end

					local inv = meta:get_inventory()
					if inv:is_empty("fuse") then
						inv:set_size("fuse", 1)
					end

					local fuse_stack = inv:get_stack("fuse", 1)
					local fuse_count = fuse_stack:get_count()
					if fuse_count > 0 then
						inv:set_stack("fuse", 1, nil)
					end
					meta:set_int("delay", fuse_count or 0)
					-- Should Never be nil... Theoretically.
					local delay = meta:get_int("delay") or 0
					if core.settings:get_bool("fireworks_manual_refill", true) then
						meta:set_int("emit_count", emit_count + 1)
					end

					local c1 = meta:get_string("c1") or "#FFFFFF"
					local c2 = meta:get_string("c2") or c1
					
					meta:set_int("busy_until", now + delay + 1)

					core.after(delay, function()
						launch_firework(pos, entity, shape, ip, c1, c2)
						if core.settings:get_bool("fireworks_enable_mesecons", true) then
							-- Output a short mesecon pulse
							mesecon.receptor_on(pos, mesecon.rules.pplate)
							core.after(1, function()
								mesecon.receptor_off(pos, mesecon.rules.pplate)
							end)
						end
					end)
				end,
			},
		}
	end

	
	if core.get_modpath("mcl_redstone") then
		node_def._mcl_redstone = {
			connects_to = function(node, dir)
				return true
			end,
			update = function(pos, node)
				local meta = core.get_meta(pos)
				local power = mcl_redstone.get_power(pos)
				local prev_power = meta:get_int("mcl_redstone_power")
				
				if power > 0 and prev_power == 0 and can_activate(pos) then
					--if not core.settings:get_bool("fireworks_enable_mesecons", true) then
					--end
					
					local emit_count = meta:get_int("emit_count")
					if emit_count >= 10 then
						meta:set_string("infotext", "Right-click to resume mesecons usage")
						meta:set_int("mcl_redstone_power", power)
						return
					end
					
					local inv = meta:get_inventory()
					if inv:is_empty("fuse") then
						inv:set_size("fuse", 1)
					end
					
					local fuse_stack = inv:get_stack("fuse", 1)
					local fuse_count = fuse_stack:get_count()
					local delay = fuse_count
					if fuse_count > 0 then
						inv:set_stack("fuse", 1, nil)
					end
					
					local c1 = meta:get_string("c1") or "#FFFFFF"
					local c2 = meta:get_string("c2") or c1
					
					core.after(delay, function()
						launch_firework(pos, entity, shape, ip, c1, c2)
					end)
					
					meta:set_int("powered", 1)
					if core.settings:get_bool("fireworks_manual_refill", true) then
						meta:set_int("emit_count", emit_count + 1)
					end
					
					if core.get_item_group(node.name, "firework") == 1 then
						local color_bits = node.param2 % 16
						mcl_redstone.swap_node(pos, {
							name = node.name,
							param1 = node.param1,
							param2 = color_bits + 16
						})
					
						core.after(1, function()
							local current_node = core.get_node(pos)
							if core.get_item_group(current_node.name, "firework") == 1 then
								local current_color_bits = current_node.param2 % 16
								mcl_redstone.swap_node(pos, {
									name = current_node.name,
									param1 = current_node.param1,
									param2 = current_color_bits
								})
							end
						end)
					end
				end
				
				meta:set_int("mcl_redstone_power", power)
			end,
			get_power = function(node, dir)
				if node.param2 >= 16 then
					return 7
				end
				return 0
			end,
		}
	end
	
	core.register_node(":fireworks_reimagined:firework_" .. shape, node_def)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if not formname:match("fireworks_reimagined:settings_") then return end
	
	local pos_str = formname:match("fireworks_reimagined:settings_(.+)")
	if not pos_str then return true end
	
	local pos = core.string_to_pos(pos_str)
	if not pos then return true end

	local node_name = core.get_node(pos).name
	-- is the firework node still around?
	if core.get_item_group(node_name, "firework") ~= 1 then return true end
	
	local meta = core.get_meta(pos)
	local player_name = player:get_player_name()
	local owner = meta:get_string("owner")
	local privs = core.get_player_privs(player_name)
	local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
	
	if not is_owner then return true end

	-- checkbox values will only be submittet when changed -> not in the save-event
	if fields.allow_others ~= nil then
		meta:set_string("allow_others", fields.allow_others)
	end
	
	if (fields.save or fields.quit or fields.cancel) then
		if privs.fireworks_admin and fields.delay and fields.delay ~= "" then
			local delay = tonumber(fields.delay) or 0
			delay = math.min(300, math.max(0, delay))
			meta:set_int("delay", delay)
		end
	end
	return true
end)

function fireworks_reimagined.register_firework_entity(name, def)
	local entity_def = {
		initial_properties = {
			fireworks    = true,
			textures = {"fireworks_rocket_white.png"},
			glow = 10,
			collisionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
			physical     = true,
			collide_with_objects = false,
			velocity = 0,
			static_save = false,
		},
		yaw = 0,
		acceleration = 5,
		firework_shape = def.firework_shape or "sphere",
		time_remaining = def.time_remaining or 3,
		spiral = def.spiral or false,
		spiral_force = def.spiral_force or 100,
		spiral_radius = def.spiral_radius or 0.1,
		thrust = def.thrust or 15,
		color1 = nil,
		color2 = nil ,
		on_activate = function(self, staticdata, dtime_s)
			if def.on_activate ~= nil then
				def.on_activate(self, staticdata, dtime_s)
			end
			self.object:set_armor_groups({immortal = 1})
			core.sound_play(self.launch_noise, {
				max_hear_distance = 100,
				gain = 10.0,
				object = self.object,
			})
			if self.spiral == true and self.spiral_force > 0 then
				self.velocity = self.spiral_force
				self.spiraling = true
				self.time_remaining = self.time_remaining * 2
			else
				self.velocity = 0
			end	
		end,
		collision = function(self)
			local pos = self.object:get_pos()
			local vel = self.object:get_velocity()
			local x   = 0
			local z   = 0
			for _,object in ipairs(core.get_objects_inside_radius(pos, 1)) do
				if object:is_player() or (object:get_luaentity() and object:get_luaentity().mob == true and object ~= self.object) then
					local pos2 = object:get_pos()
					local vec  = {x=pos.x-pos2.x, z=pos.z-pos2.z}
					local force = (1) - vector.distance({x=pos.x,y=0,z=pos.z}, {x=pos2.x,y=0,z=pos2.z})
					x = x + (vec.x * force) * 20
					z = z + (vec.z * force) * 20
				end
			end
			return({x,z})
		end,
		movement = function(self)
			if self.spiraling == true then
				self.yaw = self.yaw + self.spiral_radius
				if self.yaw > math.pi*2 then
					self.yaw = self.yaw - (math.pi*2)
				end
			end		
			local collide_values = self.collision(self)
			local c_x = collide_values[1]
			local c_z = collide_values[2]
			local vel = self.object:get_velocity()
			local x   = math.sin(self.yaw) * -self.velocity
			local z   = math.cos(self.yaw) *  self.velocity
			local gravity = -10
			if self.thrust > 0 then
				gravity = self.thrust
			end
			if self.spiral == true then
				if gravity == -10 then
					self.object:set_acceleration({x=(x - vel.x + c_x)*self.acceleration,y=-10,z=(z - vel.z + c_z)*self.acceleration})				
				else
					self.object:set_acceleration({x=(x - vel.x + c_x)*self.acceleration,y=(gravity-vel.y)*self.acceleration,z=(z - vel.z + c_z)*self.acceleration})
				end
			else
				self.object:set_velocity({x=0, y=20, z=0})
			end
		end,
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			if not pos then return end
			
			local velocity = self.object:get_velocity()
			
			local entity_type = self.spiral and "spiral" or "default"
			
			self.movement(self)
			pos.y = pos.y + (self.initial_properties.velocity * dtime)
			self.time_remaining = self.time_remaining - dtime
			if self.time_remaining <= 0 then
				local colors = {}
				if self.color1 then table.insert(colors, self.color1) end
				if self.color2 then table.insert(colors, self.color2) end
				
				def.firework_explosion(pos, self.color1, self.color2)
				
				fireworks_reimagined.create_explosion_finale_effects(pos, self.firework_shape, colors)
				fireworks_reimagined.create_explosion_sound_effects(pos, self.firework_shape)
				
				self.object:remove()
			end
		end,
	}
	core.register_entity(":"..name, entity_def)
	registered_fireworks[name] = entity_def
end
