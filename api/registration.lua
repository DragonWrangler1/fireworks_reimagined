local registered_fireworks = {}
local default_max_fireworks = tonumber(core.settings:get("fireworks_max_rockets")) or 2
local default_scan_radius = tonumber(core.settings:get("fireworks_scan_radius")) or 12

local rightclick_guard_time = 0.4
local last_rightclick = {}

local function is_repeated_rightclick(player_name, pos, now)
	local entries = last_rightclick[player_name]
	if not entries then
		entries = {}
		last_rightclick[player_name] = entries
	end

	-- Drop stale entries so the table only holds clicks inside the guard window.
	for key, stamp in pairs(entries) do
		if now - stamp >= rightclick_guard_time then
			entries[key] = nil
		end
	end

	local key = core.pos_to_string(pos)
	local repeated = entries[key] ~= nil
	entries[key] = now
	return repeated
end

core.register_on_leaveplayer(function(player)
	last_rightclick[player:get_player_name()] = nil
end)

local function mesecons_enabled()
	return core.settings:get_bool("fireworks_enable_mesecons", true)
end

local function ensure_fuse_inventory(meta)
	local inv = meta:get_inventory()
	if not inv:get_list("fuse") then
		inv:set_size("fuse", 1)
	end
	return inv
end

local function get_admin_delay(meta)
	-- Read the raw string so a deliberate admin_delay of 0 is not mistaken for
	-- "unset" (older versions stored the fuse count in the "delay" key).
	local value = meta:get_string("admin_delay")
	if value == "" then
		value = meta:get_string("delay")
	end
	local delay = tonumber(value) or 0
	return math.max(0, math.min(300, math.floor(delay)))
end

local function refund_fuse(pos, count)
	if count and count > 0 then
		core.item_drop(ItemStack("fireworks_reimagined:fuse " .. count), nil, pos)
	end
end

local function swap_powered_node(pos, powered)
	-- Callbacks may hand us a plain {x,y,z} table, while mcl_redstone uses
	-- vector methods such as pos:subtract(). Normalise to a real vector.
	pos = vector.copy(pos)
	local node = core.get_node(pos)
	if core.get_item_group(node.name, "firework") ~= 1 then
		return
	end

	local color_bits = node.param2 % 16
	mcl_redstone.swap_node(pos, {
		name = node.name,
		param1 = node.param1,
		param2 = color_bits + (powered and 16 or 0),
	})
end

local function pulse_redstone_output(pos)
	if not (mesecons_enabled() and core.get_modpath("mesecons")) then
		return
	end

	pos = vector.copy(pos)
	mesecon.receptor_on(pos, mesecon.rules.pplate)
	core.after(1, function()
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	end)
end

local function pulse_redstone_node(pos)
	if not (mesecons_enabled() and core.get_modpath("mcl_redstone")) then
		return
	end

	swap_powered_node(pos, true)
	core.after(1, function()
		swap_powered_node(pos, false)
	end)
end

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

local function launch_firework(pos, entity, shape, c1, c2)
	local firework_entity = core.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
	if firework_entity then
		local lua_entity = firework_entity:get_luaentity()
		lua_entity.firework_shape = shape
		lua_entity.color1 = c1
		lua_entity.color2 = c2
		core.sound_play("fireworks_launch", {
			pos = pos,
			max_hear_distance = 40,
			gain = 0.6
		})
		local flight_time = lua_entity.time_remaining or math.random(2.5,3)
		core.add_particlespawner({
			amount = math.max(1, math.floor(75 * flight_time)),
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
	if not color_grid or not color_grid[1] then
		return
	end

	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	local size_multiplier = 2.2
	local radius = math.max(grid_width, grid_height) * size_multiplier * 0.8
	local b_size = math.max(1, math.floor(tonumber(batch_size) or 1))
	local layers = math.max(1, math.floor(tonumber(depth_layers) or 1))
	local color_particles = {}

	local pixel_offset = size_multiplier * 0.5
	local offsets = {
		{-pixel_offset * 0.5, -pixel_offset * 0.5, 0},
		{pixel_offset * 0.5, -pixel_offset * 0.5, 0},
		{-pixel_offset * 0.5, pixel_offset * 0.5, 0},
		{pixel_offset * 0.5, pixel_offset * 0.5, 0},
	}

	local center_x = (grid_width + 1) / 2
	local center_y = (grid_height + 1) / 2
	local center_z = (layers - 1) / 2

	for z = 0, layers - 1 do
		for y = 1, grid_height do
			for x = 1, grid_width do
				local color = color_grid[y][x]
				if color and color ~= "#000000" then
					color_particles[color] = color_particles[color] or {}

					for _, offset in ipairs(offsets) do
						local particle_pos = vector.add(pos, vector.new(
							(x - center_x) * size_multiplier + offset[1],
							(y - center_y) * size_multiplier + offset[2],
							(z - center_z) * size_multiplier + offset[3]
						))
						table.insert(color_particles[color], particle_pos)
					end
				end
			end
		end
	end

	local total_spawners = 0

	for color, positions in pairs(color_particles) do
		local colored_texture = texture
			and (texture .. "^[colorize:" .. color)
			or ("fireworks_white.png^[colorize:" .. color)
		for i = 1, #positions, b_size do
			local last = math.min(i + b_size - 1, #positions)
			local world_minpos = vector.new(1e10, 1e10, 1e10)
			local world_maxpos = vector.new(-1e10, -1e10, -1e10)
			for j = i, last do
				local pos_item = positions[j]
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

			core.add_particlespawner({
				amount = last - i + 1,
				time = 0.01,
				minpos = world_minpos,
				maxpos = world_maxpos,
				minvel = {x = -8, y = 3, z = -9},
				maxvel = {x = 8, y = 3, z = 9},
				minacc = {x = 0, y = -9.81, z = 0},
				maxacc = {x = 0, y = -9.81, z = 0},
				minexptime = 2,
				maxexptime = 4,
				minsize = 1.5,
				maxsize = 3,
				glow = math.random(12, 14),
				drag = vector.new(0.04, 0.02, 0.04),
				texpool = {
					{
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
							1.0,
							0.8,
							0.0,
							start = 0.0,
							finish = 1.0
						}
					}
				},
				blend = "add",
				collisiondetection = false,
				collision_removal = false,
			})
			total_spawners = total_spawners + 1
		end
	end

	local wave_rings = 4
	for ring = 1, wave_rings do
		core.after(delay + 0.05 + (ring * 0.12), function()
			local wave_radius = math.min(radius * (1.5 + ring * 1.2), 120)
			local wave_particles = math.max(1, math.floor(60 - ring * 10))
			local wave_alpha = math.max(0, 60 - ring * 10)
			local wave_size = math.max(0.1, 1.5 - ring * 0.2)

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
					size = wave_size,
					texture = {
						name = "fireworks_white.png^[colorize:#DDDDDD:" .. wave_alpha,
						scale_tween = {
							style = "fwd",
							reps = 1,
							0.3,
							2.0,
							0.0
						},
					},
					glow = math.max(0, 4 - ring),
					blend = "add",
					collisiondetection = false,
				})
				total_spawners = total_spawners + 1
			end
		end)
	end

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

local function get_color_by_index(idx)
	if idx < 1 or idx > #color_palette then
		return color_palette[1].hex
	end
	return color_palette[idx].hex
end

fireworks_reimagined.get_color_by_index = get_color_by_index

local known_shapes = fireworks_reimagined.known_shapes

function fireworks_reimagined.register_firework_node(tiles, node_name, shape, entity, cooldown, mese_cooldown, ip, options)
	options = options or {}
	core.register_alias("fireworks_reimagined:firework_" .. node_name .. "_0", "fireworks_reimagined:firework_" .. node_name)
	core.register_alias("fireworks_reimagined:firework_" .. node_name .. "_10", "fireworks_reimagined:firework_" .. node_name)

	local primary_color_idx = options.primary_color or 1
	local primary_color_hex = get_color_by_index(primary_color_idx)

	local node_tiles
	if options.tiles then
		node_tiles = options.tiles
	elseif tiles then
		node_tiles = type(tiles) == "string" and { tiles, tiles, tiles, tiles, tiles, tiles } or tiles
	else
		node_tiles = { "black.png", "black.png", "black.png^fireworks_overlay_1.png^fireworks_overlay_2.png", "black.png^fireworks_overlay_1.png^fireworks_overlay_2.png", "black.png^fireworks_overlay_1.png^fireworks_overlay_2.png", "black.png^fireworks_overlay_1.png^fireworks_overlay_2.png" }
	end

	local icon_overlay
	if options.icon_overlay == false then
		icon_overlay = nil
	elseif options.icon_overlay then
		icon_overlay = options.icon_overlay
	else
		for _, s in ipairs(known_shapes) do
			if shape:find(s) then
				icon_overlay = s
				break
			end
		end
	end

	for i = 1, #node_tiles do
		local tile = node_tiles[i]
		local tile_name = type(tile) == "string" and tile or tile.name

		if type(tile) == "string" then
			if not tile:find("%[resize:64x64") then
				node_tiles[i] = tile .. "^[resize:64x64"
			end
		elseif type(tile) == "table" and tile.name then
			if not tile.name:find("%[resize:64x64") then
				tile.name = tile.name .. "^[resize:64x64"
			end
		end

		if icon_overlay then
			local icon = "fireworks_overlay_" .. icon_overlay .. ".png"
			if not tile_name:find(icon) then
				if i >= 3 then
					if type(tile) == "string" then
						node_tiles[i] = node_tiles[i] .. "^(" .. icon .. "^[resize:64x64^[colorize:" .. primary_color_hex .. ":100)"
					elseif type(tile) == "table" and tile.name then
						tile.name = tile.name .. "^(" .. icon .. "^[resize:64x64^[colorize:" .. primary_color_hex .. ":100)"
					end
				end
			end
		end
	end

	local node_def = {
		description = options.description or (node_name:gsub("(%a)([%w]*)", function(a,b) return a:upper() .. b end):gsub("_", " ") .. " Fireworks"),
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
		on_construct = function(pos)
			ensure_fuse_inventory(core.get_meta(pos))
			if options.on_construct then
				options.on_construct(pos)
			end
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local param2 = core.get_node(pos).param2

			local c1 = primary_color_hex
			local c2_idx = (param2 % 16) + 1
			local c2 = get_color_by_index(c2_idx)

			local meta = core.get_meta(pos)
			meta:set_string("allow_others", "false")
			meta:set_string("owner", placer and placer:get_player_name() or "")
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
				local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
				ensure_fuse_inventory(meta)

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
									"listring[current_player;main]",
							})
						else
							formspec = table.concat({
									"formspec_version[6]",
									"size[8,5]",
									"label[0.4,0.7;Settings]",
									"checkbox[0.4,1.5;allow_others;Allow others to launch this firework;".. meta:get_string("allow_others") .."]",
									"field[0.4,2.5;7,0.5;admin_delay;Launch Delay (seconds);".. get_admin_delay(meta) .."]",
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
			local has_launch_priv = privs.fireworks_admin or privs.fireworks_master
			local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
			local allow_others = meta:get_string("allow_others") == "true"
			-- Legacy nodes may have no owner; let the first player to use one
			-- claim it instead of leaving it permanently locked.
			local is_unowned = owner == ""
			local is_allowed = is_unowned or is_owner or allow_others

			if not is_allowed then
				core.chat_send_player(player_name, "You don't have permission to launch this firework.")
				return
			end

			-- Used to regulate launches and hopefully fix the infamous double launch issue.
			if is_repeated_rightclick(player_name, pos, now) then
				return
			end

			-- Fireworks masters and admins intentionally bypass launch cooldowns
			-- and the nearby-rocket limit.
			if not has_launch_priv and meta:get_int("busy_until") > now then
				core.chat_send_player(player_name, "Please wait before launching another firework!")
				return
			end

			if not has_launch_priv and not can_activate(pos) then
				core.chat_send_player(player_name, "Please wait before launching another firework!")
				return
			end

			local inv = ensure_fuse_inventory(meta)
			local fuse_stack = inv:get_stack("fuse", 1)
			local fuse_count = fuse_stack:get_count()

			local function is_valid_hex(color)
				-- Accepts #RGB or #RRGGBB
				return type(color) == "string"
					and (color:match("^#%x%x%x$") or color:match("^#%x%x%x%x%x%x$")) ~= nil
			end

			local c1_raw = meta:get_string("c1")
			local c2_raw = meta:get_string("c2")
			local c1 = is_valid_hex(c1_raw) and c1_raw or "#FFFFFF"
			local c2 = is_valid_hex(c2_raw) and c2_raw or c1

			-- Only claim an unowned node after authorization has succeeded.
			if owner == "" then
				meta:set_string("owner", player_name)
			end

			local prev_emit_count = meta:get_int("emit_count")
			meta:set_int("emit_count", 0)
			if prev_emit_count >= 10 then
				meta:set_string("infotext", "")
			end

			local delay = privs.fireworks_admin and get_admin_delay(meta) or fuse_count
			if fuse_count > 0 then
				inv:set_stack("fuse", 1, nil)
			end
			meta:set_int("busy_until", now + delay + 1)

			local expected_owner = meta:get_string("owner")
			local expected_node = node.name
			core.after(delay, function()
				local current_node = core.get_node(pos)
				if current_node.name ~= expected_node then
					refund_fuse(pos, fuse_count)
					return
				end

				local current_meta = core.get_meta(pos)
				if expected_owner ~= "" and current_meta:get_string("owner") ~= expected_owner then
					refund_fuse(pos, fuse_count)
					return
				end

				launch_firework(pos, entity, shape, c1, c2)
				pulse_redstone_output(pos)
				pulse_redstone_node(pos)
			end)
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
			local fuse_stack
			if inv:get_list("fuse") then
				fuse_stack = inv:get_stack("fuse", 1)
			end

			-- Dig first: protection is checked inside core.node_dig, so the stored
			-- fuse must not be dropped when digging is denied.
			if not core.node_dig(pos, node, digger) then
				return false
			end

			if fuse_stack and not fuse_stack:is_empty() then
				core.item_drop(fuse_stack, nil, pos)
			end
			return true
		end,
	}

	if options.on_punch then node_def.on_punch = options.on_punch end
	if options.on_rightclick then node_def.on_rightclick = options.on_rightclick end
	if options.on_dig then node_def.on_dig = options.on_dig end
	if options.on_place then node_def.on_place = options.on_place end
	if options.overlay_tiles then node_def.overlay_tiles = options.overlay_tiles end

	local wood_name = core.get_modpath("mcl_core") and "mcl_core:wood" or "default:wood"
	local wood_def = core.registered_nodes[wood_name]
	if wood_def and wood_def.sounds then
		node_def.sounds = wood_def.sounds
	elseif core.get_modpath("mcl_sounds") then
		node_def.sounds = mcl_sounds.node_sound_wood_defaults()
	end

	if core.get_modpath("mesecons") then
		node_def.mesecons = {
			effector = {
				rules = mesecon.rules.pplate,

				action_on = function(pos, node)
					local meta = core.get_meta(pos)
					local now = core.get_gametime()

					if meta:get_int("busy_until") > now then
						return false
					end
					-- Can activate has to be checked before launch and after.
					if not can_activate(pos) then
						return false
					end

					local emit_count = meta:get_int("emit_count")
					if emit_count >= 10 then
						meta:set_string("infotext", "Right-click to resume mesecons usage")
						return false
					end

					local inv = ensure_fuse_inventory(meta)
					local fuse_stack = inv:get_stack("fuse", 1)
					local fuse_count = fuse_stack:get_count()
					if fuse_count > 0 then
						inv:set_stack("fuse", 1, nil)
					end

					-- Keep the transient fuse delay separate from the admin delay.
					meta:set_int("fuse_delay", fuse_count)
					local delay = fuse_count

					if core.settings:get_bool("fireworks_manual_refill", true) then
						meta:set_int("emit_count", emit_count + 1)
					end

					local c1 = meta:get_string("c1")
					local c2 = meta:get_string("c2")
					if c1 == "" then c1 = "#FFFFFF" end
					if c2 == "" then c2 = c1 end

					meta:set_int("busy_until", now + delay + 1)

					local expected_node = node.name
					core.after(delay, function()
						if core.get_node(pos).name ~= expected_node then
							refund_fuse(pos, fuse_count)
							return
						end
						if can_activate(pos) then
							launch_firework(pos, entity, shape, c1, c2)
							pulse_redstone_output(pos)
							pulse_redstone_node(pos)
						end
					end)

					return true
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
				local now = core.get_gametime()

				if not mesecons_enabled() then
					meta:set_int("mcl_redstone_power", power)
					return
				end

				if power > 0 and prev_power == 0 and can_activate(pos)
						and meta:get_int("busy_until") <= now then
					local emit_count = meta:get_int("emit_count")
					if emit_count >= 10 then
						meta:set_string("infotext", "Right-click to resume mesecons usage")
						meta:set_int("mcl_redstone_power", power)
						return
					end

					local inv = ensure_fuse_inventory(meta)
					local fuse_count = inv:get_stack("fuse", 1):get_count()
					if fuse_count > 0 then
						inv:set_stack("fuse", 1, nil)
					end

					meta:set_int("fuse_delay", fuse_count)
					local delay = fuse_count

					if core.settings:get_bool("fireworks_manual_refill", true) then
						meta:set_int("emit_count", emit_count + 1)
					end

					local c1 = meta:get_string("c1")
					local c2 = meta:get_string("c2")
					if c1 == "" then c1 = "#FFFFFF" end
					if c2 == "" then c2 = c1 end

					meta:set_int("busy_until", now + delay + 1)

					local expected_node = node.name
					core.after(delay, function()
						if core.get_node(pos).name ~= expected_node then
							refund_fuse(pos, fuse_count)
							return
						end

						launch_firework(pos, entity, shape, c1, c2)
						pulse_redstone_node(pos)
					end)
				end

				meta:set_int("mcl_redstone_power", power)
			end,
			get_power = function(node, dir)
				if mesecons_enabled() and node.param2 >= 16 then
					return 7
				end
				return 0
			end,
		}
	end

	core.register_node(":fireworks_reimagined:firework_" .. node_name, node_def)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if not formname:match("fireworks_reimagined:settings_") then return end

	local pos_str = formname:match("fireworks_reimagined:settings_(.+)")
	if not pos_str then return true end

	local pos = core.string_to_pos(pos_str)
	if not pos then return true end

	local current_node_name = core.get_node(pos).name
	if core.get_item_group(current_node_name, "firework") ~= 1 then return true end

	local meta = core.get_meta(pos)
	local player_name = player:get_player_name()
	local owner = meta:get_string("owner")
	local privs = core.get_player_privs(player_name)
	local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin

	if not is_owner then return true end

	if fields.allow_others ~= nil then
		meta:set_string("allow_others", fields.allow_others)
	end

	if (fields.save or fields.quit or fields.cancel) then
		if privs.fireworks_admin and fields.admin_delay and fields.admin_delay ~= "" then
			local delay = tonumber(fields.admin_delay) or 0
			delay = math.min(300, math.max(0, delay))
			meta:set_int("admin_delay", delay)
		end
	end
	return true
end)

function fireworks_reimagined.register_firework_entity(name, def)
	def = def or {}
	local explosion_callback = def.firework_explosion
	if type(explosion_callback) ~= "function" then
		core.log("warning", "[fireworks_reimagined] Entity '" .. name .. "' has no firework_explosion callback; using a sphere explosion.")
		explosion_callback = function(pos, color1, color2)
			fireworks_reimagined.spawn_firework_explosion(
				pos,
				def.firework_shape or "sphere",
				nil,
				color1 or "#FFFFFF",
				color2 or color1 or "#FFFFFF",
				"255",
				nil,
				nil
			)
		end
	end

	local entity_def = {
		initial_properties = {
			fireworks    = true,
			textures = {"fireworks_rocket_white.png"},
			glow = 10,
			collisionbox = {-0.2,-0.2,-0.2,0.2,0.2,0.2},
			physical     = true,
			collide_with_objects = false,
			velocity = 0,
			static_save = false,
		},
		yaw = 0,
		acceleration = 5,
		firework_shape = def.firework_shape or "sphere",
		firework_explosion = explosion_callback,
		time_remaining = def.time_remaining,
		launch_noise = def.launch_noise,
		spiral = def.spiral or false,
		spiral_force = def.spiral_force or 100,
		spiral_radius = def.spiral_radius or 0.1,
		thrust = def.thrust or 15,
		color1 = nil,
		color2 = nil ,
		on_activate = function(self, staticdata, dtime_s)
			-- Set defaults before the callback runs so it can override them.
			self.time_remaining = def.time_remaining or math.random(2.3, 2.7)
			self.drift_accel_x = (math.random() - 0.5) * 15
			self.drift_accel_z = (math.random() - 0.5) * 15
			self.object:set_armor_groups({immortal = 1})
			self.object:set_velocity({x=0, y=20, z=0})

			if def.on_activate ~= nil then
				def.on_activate(self, staticdata, dtime_s)
			end

			if self.launch_noise then
				core.sound_play(self.launch_noise, {
					max_hear_distance = 100,
					gain = 0.7,
					object = self.object,
				})
			end

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
				local acc_y = self.thrust > 0 and self.thrust or -10
				self.object:set_acceleration({
					x = self.drift_accel_x or 0,
					y = acc_y,
					z = self.drift_accel_z or 0
				})
			end
		end,
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			if not pos then return end

			self.movement(self)
			self.time_remaining = (self.time_remaining or 0) - dtime
			if self.time_remaining <= 0 then
				explosion_callback(pos, self.color1, self.color2)
				fireworks_reimagined.create_explosion_sound_effects(pos, self.firework_shape or "sphere")
				self.object:remove()
			end
		end,
	}
	core.register_entity(":"..name, entity_def)
	registered_fireworks[name] = entity_def
end
