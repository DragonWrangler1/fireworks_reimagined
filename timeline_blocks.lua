--================================================================--
--=== TIMELINE FIREWORKS BLOCKS ===--
--================================================================--

fireworks_reimagined.timeline_blocks = {}

-- Timeline block data storage
local timeline_block_data = {}

-- Helper function to get block data
local function get_block_data(pos)
    local pos_str = minetest.pos_to_string(pos)
    if not timeline_block_data[pos_str] then
        timeline_block_data[pos_str] = {
            timeline_name = nil,
            custom_events = {},
            settings = {
                auto_start = false,
                loop = false,
                trigger_mode = "manual" -- manual, redstone, timer
            }
        }
    end
    return timeline_block_data[pos_str]
end

-- Timeline Fireworks Block
minetest.register_node("fireworks_reimagined:timeline_block", {
    description = "Timeline Fireworks Block",
    tiles = {
        "fireworks_timeline_block_top.png",
        "fireworks_timeline_block_bottom.png", 
        "fireworks_timeline_block_side.png",
        "fireworks_timeline_block_side.png",
        "fireworks_timeline_block_side.png",
        "fireworks_timeline_block_front.png"
    },
    groups = {cracky = 1, oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = 8,
    
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("owner", "")
        meta:set_string("timeline_name", "")
        meta:set_string("trigger_mode", "manual")
        meta:set_string("infotext", "Timeline Fireworks Block (Not Configured)")
        
        -- Initialize block data
        get_block_data(pos)
    end,
    
    after_place_node = function(pos, placer)
        local meta = minetest.get_meta(pos)
        local placer_name = placer:get_player_name()
        meta:set_string("owner", placer_name)
        meta:set_string("infotext", "Timeline Fireworks Block (Owner: " .. placer_name .. ")")
    end,
    
    on_rightclick = function(pos, node, clicker)
        local meta = minetest.get_meta(pos)
        local owner = meta:get_string("owner")
        local player_name = clicker:get_player_name()
        local privs = minetest.get_player_privs(player_name)
        local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
        
        if not is_owner then
            minetest.chat_send_player(player_name, "You don't have permission to configure this timeline block.")
            return
        end
        
        fireworks_reimagined.timeline_blocks.show_config_form(pos, player_name)
    end,
    
    on_punch = function(pos, node, clicker)
        -- Manual trigger
        local meta = minetest.get_meta(pos)
        local timeline_name = meta:get_string("timeline_name")
        
        if timeline_name == "" then
            minetest.chat_send_player(clicker:get_player_name(), "Timeline block not configured!")
            return
        end
        
        fireworks_reimagined.timeline_blocks.trigger_timeline(pos, clicker:get_player_name())
    end,
    
    mesecons = {
        effector = {
            action_on = function(pos, node)
                local meta = minetest.get_meta(pos)
                local trigger_mode = meta:get_string("trigger_mode")
                
                if trigger_mode == "redstone" or trigger_mode == "both" then
                    fireworks_reimagined.timeline_blocks.trigger_timeline(pos, "redstone")
                end
            end
        }
    },
    
    on_destruct = function(pos)
        local pos_str = minetest.pos_to_string(pos)
        timeline_block_data[pos_str] = nil
    end
})

-- Configuration form
function fireworks_reimagined.timeline_blocks.show_config_form(pos, player_name)
    local meta = minetest.get_meta(pos)
    local timeline_name = meta:get_string("timeline_name")
    local trigger_mode = meta:get_string("trigger_mode")
    local block_data = get_block_data(pos)
    
    -- Get available timelines and templates
    local timelines = fireworks_reimagined.timeline.list()
    local templates = fireworks_reimagined.timeline.list_templates()
    
    local timeline_options = "none"
    for _, name in ipairs(timelines) do
        timeline_options = timeline_options .. "," .. name
    end
    
    local template_options = "none"
    for _, name in ipairs(templates) do
        template_options = template_options .. "," .. name
    end
    
    local formspec = "size[12,10]" ..
        "label[0.5,0.5;Timeline Fireworks Block Configuration]" ..
        "label[0.5,1.5;Select Timeline:]" ..
        "dropdown[0.5,2;5,1;timeline_select;" .. timeline_options .. ";" .. 
        (timeline_name ~= "" and timeline_name or "none") .. "]" ..
        
        "label[6,1.5;Or Create from Template:]" ..
        "dropdown[6,2;5,1;template_select;" .. template_options .. ";none]" ..
        "field[6,3.5;3,1;new_timeline_name;;New Timeline Name]" ..
        "button[9,3;2,1;create_from_template;Create]" ..
        
        "label[0.5,4;Trigger Mode:]" ..
        "dropdown[0.5,4.5;4,1;trigger_mode;manual,redstone,both;" .. 
        (trigger_mode ~= "" and trigger_mode or "manual") .. "]" ..
        
        "label[0.5,5.5;Custom Events (Advanced):]" ..
        "button[0.5,6;3,1;edit_events;Edit Events]" ..
        "button[4,6;3,1;test_timeline;Test Timeline]" ..
        
        "button[0.5,8;2,1;save;Save]" ..
        "button[3,8;2,1;cancel;Cancel]" ..
        "button[9,8;2,1;clear;Clear Config]"
    
    minetest.show_formspec(player_name, "fireworks_reimagined:timeline_block_" .. minetest.pos_to_string(pos), formspec)
end

-- Handle form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname:match("^fireworks_reimagined:timeline_block_") then
        return
    end
    
    local pos = minetest.string_to_pos(formname:match("fireworks_reimagined:timeline_block_(.*)"))
    if not pos then return end
    
    local meta = minetest.get_meta(pos)
    local player_name = player:get_player_name()
    local owner = meta:get_string("owner")
    local privs = minetest.get_player_privs(player_name)
    local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
    
    if not is_owner then
        return
    end
    
    if fields.save then
        if fields.timeline_select and fields.timeline_select ~= "none" then
            meta:set_string("timeline_name", fields.timeline_select)
            meta:set_string("infotext", "Timeline Block: " .. fields.timeline_select)
        end
        
        if fields.trigger_mode then
            meta:set_string("trigger_mode", fields.trigger_mode)
        end
        
        minetest.chat_send_player(player_name, "Timeline block configuration saved!")
        
    elseif fields.create_from_template then
        if fields.template_select and fields.template_select ~= "none" and fields.new_timeline_name and fields.new_timeline_name ~= "" then
            local template = fireworks_reimagined.timeline.get_template(fields.template_select)
            if template then
                local new_timeline = fireworks_reimagined.timeline.create(fields.new_timeline_name, player_name)
                new_timeline:import_data(template)
                
                -- Add launch point at block position
                new_timeline:add_launch_point("default", pos, "standard")
                
                meta:set_string("timeline_name", fields.new_timeline_name)
                meta:set_string("infotext", "Timeline Block: " .. fields.new_timeline_name)
                
                minetest.chat_send_player(player_name, "Timeline created from template: " .. fields.new_timeline_name)
            end
        else
            minetest.chat_send_player(player_name, "Please select a template and enter a timeline name!")
        end
        
    elseif fields.test_timeline then
        fireworks_reimagined.timeline_blocks.trigger_timeline(pos, player_name)
        
    elseif fields.clear then
        meta:set_string("timeline_name", "")
        meta:set_string("infotext", "Timeline Fireworks Block (Not Configured)")
        minetest.chat_send_player(player_name, "Timeline block configuration cleared!")
        
    elseif fields.edit_events then
        fireworks_reimagined.timeline_blocks.show_events_form(pos, player_name)
    end
end)

-- Advanced events editor
function fireworks_reimagined.timeline_blocks.show_events_form(pos, player_name)
    local formspec = "size[14,12]" ..
        "label[0.5,0.5;Custom Timeline Events Editor]" ..
        "label[0.5,1.5;Time (seconds):]" ..
        "field[3,1.5;2,1;event_time;;0.0]" ..
        
        "label[5.5,1.5;Event Type:]" ..
        "dropdown[5.5,2;3,1;event_type;firework,sound,marker;firework]" ..
        
        "label[0.5,3;Firework Shape:]" ..
        "dropdown[0.5,3.5;3,1;firework_shape;sphere,star,ring,burst,cube,chaotic,flame,snowflake,christmas_tree,present,hour_glass,willow,chrysanthemum,peony;sphere]" ..
        
        "label[4,3;Color 1:]" ..
        "field[4,3.5;2.5,1;color1;;#FF0000]" ..
        
        "label[7,3;Color 2:]" ..
        "field[7,3.5;2.5,1;color2;;#FFFFFF]" ..
        
        "label[10,3;Size:]" ..
        "field[10,3.5;1.5,1;size;;2.0]" ..
        
        "button[0.5,5;2,1;add_event;Add Event]" ..
        "button[3,5;2,1;clear_events;Clear All]" ..
        
        "label[0.5,6.5;Current Events:]" ..
        "textlist[0.5,7;13,4;events_list;;0;false]" ..
        
        "button[11,11;2,1;done;Done]"
    
    minetest.show_formspec(player_name, "fireworks_reimagined:timeline_events_" .. minetest.pos_to_string(pos), formspec)
end

-- Trigger timeline function
function fireworks_reimagined.timeline_blocks.trigger_timeline(pos, trigger_source)
    local meta = minetest.get_meta(pos)
    local timeline_name = meta:get_string("timeline_name")
    
    if timeline_name == "" then
        if trigger_source ~= "redstone" then
            minetest.chat_send_player(trigger_source, "Timeline block not configured!")
        end
        return false
    end
    
    local timeline = fireworks_reimagined.timeline.get(timeline_name)
    if not timeline then
        if trigger_source ~= "redstone" then
            minetest.chat_send_player(trigger_source, "Timeline not found: " .. timeline_name)
        end
        return false
    end
    
    -- Ensure the timeline has a launch point at this block's position
    if not timeline.launch_points["block_" .. minetest.pos_to_string(pos)] then
        timeline:add_launch_point("block_" .. minetest.pos_to_string(pos), pos, "standard")
    end
    
    -- Update all firework events to use this block's launch point
    for _, event in ipairs(timeline.events) do
        if event.type == "firework" and not event.data.launch_point then
            event.data.launch_point = "block_" .. minetest.pos_to_string(pos)
        end
    end
    
    -- Start the timeline
    if timeline:play() then
        if trigger_source ~= "redstone" then
            minetest.chat_send_player(trigger_source, "🎆 Timeline started: " .. timeline_name)
        end
        
        -- Visual feedback
        minetest.add_particle({
            pos = {x = pos.x, y = pos.y + 1, z = pos.z},
            velocity = {x = 0, y = 2, z = 0},
            acceleration = {x = 0, y = -1, z = 0},
            expirationtime = 2.0,
            size = 4,
            texture = "fireworks_spark_white.png^[colorize:#00FF00:200",
            glow = 14,
            collisiondetection = false,
        })
        
        return true
    else
        if trigger_source ~= "redstone" then
            minetest.chat_send_player(trigger_source, "Timeline is already playing!")
        end
        return false
    end
end

-- Programmable Timeline Block (Advanced version)
minetest.register_node("fireworks_reimagined:programmable_timeline_block", {
    description = "Programmable Timeline Fireworks Block",
    tiles = {
        "fireworks_programmable_block_top.png",
        "fireworks_programmable_block_bottom.png",
        "fireworks_programmable_block_side.png",
        "fireworks_programmable_block_side.png", 
        "fireworks_programmable_block_side.png",
        "fireworks_programmable_block_front.png"
    },
    groups = {cracky = 1, oddly_breakable_by_hand = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = 10,
    
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("owner", "")
        meta:set_string("program", "")
        meta:set_string("infotext", "Programmable Timeline Block (Not Programmed)")
        
        -- Create a unique timeline for this block
        local block_timeline_name = "block_" .. minetest.pos_to_string(pos)
        local timeline = fireworks_reimagined.timeline.create(block_timeline_name, "system")
        timeline:add_launch_point("default", pos, "standard")
        
        meta:set_string("timeline_name", block_timeline_name)
    end,
    
    after_place_node = function(pos, placer)
        local meta = minetest.get_meta(pos)
        local placer_name = placer:get_player_name()
        meta:set_string("owner", placer_name)
        meta:set_string("infotext", "Programmable Timeline Block (Owner: " .. placer_name .. ")")
    end,
    
    on_rightclick = function(pos, node, clicker)
        local meta = minetest.get_meta(pos)
        local owner = meta:get_string("owner")
        local player_name = clicker:get_player_name()
        local privs = minetest.get_player_privs(player_name)
        local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
        
        if not is_owner then
            minetest.chat_send_player(player_name, "You don't have permission to program this block.")
            return
        end
        
        fireworks_reimagined.timeline_blocks.show_programming_form(pos, player_name)
    end,
    
    on_punch = function(pos, node, clicker)
        -- Execute the programmed timeline
        local meta = minetest.get_meta(pos)
        local timeline_name = meta:get_string("timeline_name")
        
        if timeline_name then
            local timeline = fireworks_reimagined.timeline.get(timeline_name)
            if timeline and #timeline.events > 0 then
                timeline:play()
                minetest.chat_send_player(clicker:get_player_name(), "🎆 Executing programmed timeline!")
            else
                minetest.chat_send_player(clicker:get_player_name(), "Block not programmed!")
            end
        end
    end,
    
    mesecons = {
        effector = {
            action_on = function(pos, node)
                local meta = minetest.get_meta(pos)
                local timeline_name = meta:get_string("timeline_name")
                
                if timeline_name then
                    local timeline = fireworks_reimagined.timeline.get(timeline_name)
                    if timeline and #timeline.events > 0 then
                        timeline:play()
                    end
                end
            end
        }
    },
    
    on_destruct = function(pos)
        local pos_str = minetest.pos_to_string(pos)
        local timeline_name = "block_" .. pos_str
        fireworks_reimagined.timeline.delete(timeline_name)
        timeline_block_data[pos_str] = nil
    end
})

-- Programming interface
function fireworks_reimagined.timeline_blocks.show_programming_form(pos, player_name)
    local formspec = "size[16,14]" ..
        "label[0.5,0.5;Programmable Timeline Block - Visual Programming]" ..
        
        "label[0.5,1.5;Quick Programs:]" ..
        "button[0.5,2;2.5,1;prog_simple;Simple Show]" ..
        "button[3.5,2;2.5,1;prog_finale;Grand Finale]" ..
        "button[6.5,2;2.5,1;prog_romantic;Romantic]" ..
        "button[9.5,2;2.5,1;prog_custom;Custom Show]" ..
        
        "label[0.5,3.5;Manual Event Programming:]" ..
        "label[0.5,4;Time:]" .. "field[1.5,4;1.5,1;time;;0]" ..
        "label[3.5,4;Shape:]" .. "dropdown[4.5,4;2.5,1;shape;sphere,star,ring,burst,cube,chaotic,flame,snowflake,christmas_tree,present,hour_glass,willow,chrysanthemum,peony;sphere]" ..
        "label[7.5,4;Color1:]" .. "field[8.5,4;2,1;color1;;#FF0000]" ..
        "label[11,4;Color2:]" .. "field[12,4;2,1;color2;;#FFFFFF]" ..
        "label[14.5,4;Size:]" .. "field[15,4;1,1;fsize;;2]" ..
        
        "button[0.5,5;2,1;add_firework;Add Firework]" ..
        "button[3,5;2,1;add_pause;Add Pause]" ..
        "button[5.5,5;2,1;add_message;Add Message]" ..
        "button[8,5;2,1;clear_program;Clear All]" ..
        
        "label[0.5,6.5;Current Program:]" ..
        "textlist[0.5,7;15,5;program_list;;0;false]" ..
        
        "button[0.5,12.5;2,1;test_program;Test]" ..
        "button[3,12.5;2,1;save_program;Save]" ..
        "button[13,12.5;2,1;close;Close]"
    
    minetest.show_formspec(player_name, "fireworks_reimagined:programming_" .. minetest.pos_to_string(pos), formspec)
end

-- Handle programming form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname:match("^fireworks_reimagined:programming_") then
        return
    end
    
    local pos = minetest.string_to_pos(formname:match("fireworks_reimagined:programming_(.*)"))
    if not pos then return end
    
    local meta = minetest.get_meta(pos)
    local player_name = player:get_player_name()
    local owner = meta:get_string("owner")
    local privs = minetest.get_player_privs(player_name)
    local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
    
    if not is_owner then
        return
    end
    
    local timeline_name = meta:get_string("timeline_name")
    local timeline = fireworks_reimagined.timeline.get(timeline_name)
    
    if not timeline then
        return
    end
    
    if fields.prog_simple then
        -- Clear existing events and add simple show
        timeline.events = {}
        timeline.duration = 15.0
        timeline:add_event(0.0, "marker", {message = "Simple Fireworks Show"})
        timeline:add_event(2.0, "firework", {shape = "sphere", color1 = "#FF0000", color2 = "#FFFFFF", size = 2.0})
        timeline:add_event(5.0, "firework", {shape = "star", color1 = "#00FF00", color2 = "#FFFF00", size = 2.5})
        timeline:add_event(8.0, "firework", {shape = "burst", color1 = "#0000FF", color2 = "#FF00FF", size = 3.0})
        timeline:add_event(12.0, "firework", {shape = "chaotic", color1 = "#FFD700", color2 = "#FF4500", size = 2.0})
        minetest.chat_send_player(player_name, "Simple show programmed!")
        
    elseif fields.prog_finale then
        -- Grand finale program
        timeline.events = {}
        timeline.duration = 25.0
        timeline:add_event(0.0, "marker", {message = "Grand Finale!"})
        timeline:add_event(1.0, "firework", {shape = "sphere", color1 = "#FFD700", color2 = "#FF4500", size = 2.0})
        timeline:add_event(3.0, "firework", {shape = "star", color1 = "#FF0000", color2 = "#FFFFFF", size = 2.5})
        timeline:add_event(5.0, "firework", {shape = "chrysanthemum", color1 = "#00FF00", color2 = "#FFFF00", size = 2.0})
        timeline:add_event(8.0, "firework", {shape = "willow", color1 = "#FF69B4", color2 = "#DA70D6", size = 3.0})
        timeline:add_event(12.0, "firework", {shape = "peony", color1 = "#1E90FF", color2 = "#87CEEB", size = 2.5})
        timeline:add_event(16.0, "firework", {shape = "burst", color1 = "#FF6347", color2 = "#FFD700", size = 3.5})
        timeline:add_event(20.0, "firework", {shape = "chaotic", color1 = "#FF1493", color2 = "#00FFFF", size = 4.0})
        timeline:add_event(22.0, "marker", {message = "FINALE!"})
        minetest.chat_send_player(player_name, "Grand finale programmed!")
        
    elseif fields.prog_romantic then
        -- Romantic show program
        timeline.events = {}
        timeline.duration = 30.0
        timeline:add_event(0.0, "marker", {message = "💕 Romantic Evening 💕"})
        timeline:add_event(3.0, "firework", {shape = "star", color1 = "#FFB6C1", color2 = "#FFFFFF", size = 1.5})
        timeline:add_event(8.0, "firework", {shape = "sphere", color1 = "#FF69B4", color2 = "#FFC0CB", size = 1.8})
        timeline:add_event(15.0, "firework", {shape = "willow", color1 = "#DA70D6", color2 = "#DDA0DD", size = 2.0})
        timeline:add_event(22.0, "firework", {shape = "chrysanthemum", color1 = "#FF1493", color2 = "#FFB6C1", size = 2.2})
        timeline:add_event(28.0, "marker", {message = "💖 Perfect Evening 💖"})
        minetest.chat_send_player(player_name, "Romantic show programmed!")
        
    elseif fields.add_firework then
        if fields.time and fields.shape and fields.color1 and fields.color2 and fields.fsize then
            local time = tonumber(fields.time) or 0
            local size = tonumber(fields.fsize) or 2.0
            
            timeline:add_event(time, "firework", {
                shape = fields.shape,
                color1 = fields.color1,
                color2 = fields.color2,
                size = size
            })
            
            -- Update duration if needed
            if time + 5 > timeline.duration then
                timeline.duration = time + 5
            end
            
            minetest.chat_send_player(player_name, "Firework event added at " .. time .. "s")
        else
            minetest.chat_send_player(player_name, "Please fill all firework fields!")
        end
        
    elseif fields.add_pause then
        if fields.time then
            local time = tonumber(fields.time) or 0
            timeline:add_event(time, "pause", {duration = 2.0})
            minetest.chat_send_player(player_name, "Pause added at " .. time .. "s")
        end
        
    elseif fields.add_message then
        if fields.time then
            local time = tonumber(fields.time) or 0
            timeline:add_event(time, "marker", {message = "Custom Message"})
            minetest.chat_send_player(player_name, "Message event added at " .. time .. "s")
        end
        
    elseif fields.clear_program then
        timeline.events = {}
        timeline.duration = 10.0
        minetest.chat_send_player(player_name, "Program cleared!")
        
    elseif fields.test_program then
        if #timeline.events > 0 then
            timeline:play()
            minetest.chat_send_player(player_name, "🎆 Testing programmed timeline!")
        else
            minetest.chat_send_player(player_name, "No program to test!")
        end
        
    elseif fields.save_program then
        minetest.chat_send_player(player_name, "Program saved! (" .. #timeline.events .. " events)")
    end
end)

-- Crafting recipes
minetest.register_craft({
    output = "fireworks_reimagined:timeline_block",
    recipe = {
        {"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
        {"fireworks_reimagined:firework_sphere", "default:diamondblock", "fireworks_reimagined:firework_star"},
        {"default:steel_ingot", "mesecons:wire_00000000_off", "default:steel_ingot"}
    }
})

minetest.register_craft({
    output = "fireworks_reimagined:programmable_timeline_block",
    recipe = {
        {"default:diamond", "default:mese_crystal", "default:diamond"},
        {"fireworks_reimagined:timeline_block", "default:mese", "fireworks_reimagined:timeline_block"},
        {"default:diamond", "mesecons_luacontroller:luacontroller0000", "default:diamond"}
    }
})

minetest.log("info", "[Fireworks] Timeline blocks loaded")