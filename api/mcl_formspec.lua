local has_mcl = core.get_modpath("mcl_core") ~= nil
local has_mcl_formspec = core.get_modpath("mcl_formspec") ~= nil

if not (has_mcl and has_mcl_formspec) then
	return
end

local F = core.formspec_escape
local mcl_formspec_lib = mcl_formspec or {}

function fireworks_reimagined.build_mcl_settings_formspec(pos, player_name, is_owner, privs)
	local meta = core.get_meta(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	
	local allow_others = meta:get_string("allow_others") == "true" and "true" or "false"
	local delay = meta:get_int("delay") or 0
	
	local is_admin = privs.fireworks_admin
	local label_color = mcl_formspec_lib.label_color or "#313131"
	
	local formspec_parts = {}
	
	if not is_admin then
		formspec_parts = {
			"formspec_version[6]",
			"size[11,9]",
			"label[4.5,0.6;" .. F(core.colorize(label_color, "Settings")) .. "]",
			"checkbox[0.7,3;allow_others;" .. F("Allow others to launch this firework") .. ";" .. allow_others .. "]",
		}
		
		if mcl_formspec_lib.get_itemslot_bg_v4 then
			table.insert(formspec_parts, mcl_formspec_lib.get_itemslot_bg_v4(9.45, 2.5, 1, 1))
		end
		
		table.insert(formspec_parts, "list[nodemeta:" .. spos .. ";fuse;9.45,2.5;1,1]")
		
		if mcl_formspec_lib.get_itemslot_bg_v4 then
			table.insert(formspec_parts, mcl_formspec_lib.get_itemslot_bg_v4(0.7, 3.8, 8, 4))
		end
		
		table.insert(formspec_parts, "list[current_player;main;0.7,3.8;8,4]")
		
		table.insert(formspec_parts, "button_exit[0.7,0.4;2,1;save;<]")
		table.insert(formspec_parts, "listring[nodemeta:" .. spos .. ";fuse]")
		table.insert(formspec_parts, "listring[current_player;main]")
	else
		formspec_parts = {
			"formspec_version[6]",
			"size[8,5]",
			"label[0.4,0.7;" .. F(core.colorize(label_color, "Settings")) .. "]",
			
			"checkbox[0.4,1.5;allow_others;" .. F("Allow others to launch this firework") .. ";" .. allow_others .. "]",
			
			"field[0.4,2.5;7,0.5;delay;" .. F("Launch Delay (seconds):") .. ";" .. delay .. "]",
			
			"button_exit[2.9,3.4;2,1;save;Close]",
		}
	end
	
	return table.concat(formspec_parts)
end
