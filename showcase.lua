--================================================================--
--=== FIREWORKS ENHANCED FEATURES SHOWCASE ===--
--================================================================--

fireworks_reimagined.showcase = {}

-- Showcase demonstrations
function fireworks_reimagined.showcase.demo_timeline(player_name)
	local player = minetest.get_player_by_name(player_name)
	if not player then return false end
	
	local pos = player:get_pos()
	
	-- Create showcase timeline
	local timeline = fireworks_reimagined.timeline.create("showcase_demo", player_name)
	
	-- Set up launch point
	timeline:add_launch_point("center", {x = pos.x, y = pos.y + 30, z = pos.z}, "standard")
	timeline:add_launch_point("left", {x = pos.x - 10, y = pos.y + 30, z = pos.z}, "standard")
	timeline:add_launch_point("right", {x = pos.x + 10, y = pos.y + 30, z = pos.z}, "standard")
	
	-- Add spectacular sequence of events
	timeline:add_event(1.0, "marker", {message = "🎆 Enhanced Fireworks Showcase Beginning!"})
	
	-- Demonstrate new patterns
	timeline:add_event(2.0, "firework", {
		shape = "willow", color1 = "#FFD700", color2 = "#FF4500", 
		launch_point = "center", pattern = "ip"
	})
	
	timeline:add_event(4.0, "firework", {
		shape = "chrysanthemum", color1 = "#FF69B4", color2 = "#DA70D6",
		launch_point = "left", pattern = "ip"
	})
	
	timeline:add_event(6.0, "firework", {
		shape = "peony", color1 = "#00FF00", color2 = "#32CD32",
		launch_point = "right", pattern = "ip"
	})
	
	-- Synchronized burst
	timeline:add_event(8.0, "firework", {
		shape = "sphere", color1 = "#FF0000", color2 = "#FFFF00",
		launch_point = "center", pattern = "ip"
	})
	timeline:add_event(8.2, "firework", {
		shape = "star", color1 = "#1E90FF", color2 = "#87CEEB",
		launch_point = "left", pattern = "ip"
	})
	timeline:add_event(8.4, "firework", {
		shape = "burst", color1 = "#FF6347", color2 = "#FFD700",
		launch_point = "right", pattern = "ip"
	})
	
	-- Grand finale
	timeline:add_event(10.0, "marker", {message = "🎆 GRAND FINALE!"})
	timeline:add_event(11.0, "firework", {
		shape = "chaotic", color1 = "#FF1493", color2 = "#00FFFF",
		launch_point = "center", pattern = "ip", size = 3.0
	})
	
	timeline:add_event(12.0, "marker", {message = "🎆 Showcase Complete! Use /fireworks_gui to create your own!"})
	
	-- Start the show
	timeline:play()
	
	return true
end


function fireworks_reimagined.showcase.demo_custom_pattern(player_name)
	local player = minetest.get_player_by_name(player_name)
	if not player then return false end
	
	local pos = player:get_pos()
	pos.y = pos.y + 25
	
	-- Load and execute example patterns
	local pattern1 = fireworks_reimagined.pattern_creator.load_pattern("simple_burst")
	local pattern2 = fireworks_reimagined.pattern_creator.load_pattern("rotating_star")
	
	if pattern1 then
		pattern1:execute(pos)
		minetest.chat_send_player(player_name, "🎨 Executed custom pattern: Simple Burst")
	end
	
	minetest.after(3, function()
		if pattern2 then
			local offset_pos = {x = pos.x + 8, y = pos.y, z = pos.z}
			pattern2:execute(offset_pos)
			minetest.chat_send_player(player_name, "🎨 Executed custom pattern: Rotating Star")
		end
	end)
	
	minetest.after(6, function()
		minetest.chat_send_player(player_name, "🎨 Custom pattern demo complete!")
		minetest.chat_send_player(player_name, "🎨 Use /fireworks_gui designer to create your own patterns!")
	end)
	
	return true
end

function fireworks_reimagined.showcase.demo_performance_system(player_name)
	local stats = fireworks_reimagined.performance.get_stats()
	
	local message = string.format(
		"PERFORMANCE SYSTEM DEMO:\n" ..
		"Current Quality: %s\n" ..
		"Average Lag: %.1fms\n" ..
		"Players Online: %d\n" ..
		"Active Fireworks: %d\n" ..
		"Auto Adjust: %s\n\n" ..
		"The system automatically adjusts firework quality based on server performance!\n" ..
		"Try /fireworks_quality to manually control your personal settings.",
		stats.current_quality,
		stats.average_lag,
		stats.player_count,
		stats.active_fireworks,
		stats.auto_adjust and "ON" or "OFF"
	)
	
	minetest.chat_send_player(player_name, message)
	
	-- Demonstrate quality scaling with a burst
	local player = minetest.get_player_by_name(player_name)
	if player then
		local pos = player:get_pos()
		pos.y = pos.y + 20
		
		fireworks_reimagined.spawn_firework_explosion(pos, "#00FF00", "#FFFF00", nil, nil, nil)
		minetest.chat_send_player(player_name, "💫 Firework quality automatically adapted to current performance level!")
	end
	
	return true
end

function fireworks_reimagined.showcase.demo_all_features(player_name)
	minetest.chat_send_player(player_name, "This demo shows ALL enhanced features working together!")
	
	-- Timeline demo
	minetest.after(2, function()
		minetest.chat_send_player(player_name, "Phase 1: Timeline System")
		fireworks_reimagined.showcase.demo_timeline(player_name)
	end)
	
	-- Performance demo  
	minetest.after(15, function()
		minetest.chat_send_player(player_name, "Phase 2: Performance Monitoring")
		fireworks_reimagined.showcase.demo_performance_system(player_name)
	end)
	
	-- Custom patterns demo
	minetest.after(20, function()
		minetest.chat_send_player(player_name, "Phase 3: Custom Pattern Creator")
		fireworks_reimagined.showcase.demo_custom_pattern(player_name)
	end)
	
	return true
end

-- Chat commands for showcase
minetest.register_chatcommand("fireworks_showcase", {
	params = "[timeline|patterns|performance|all]",
	privs = {"server"},
	description = "Demonstrate enhanced fireworks features",
	func = function(name, param)
		local demo_type = param:trim()
		
		if demo_type == "timeline" or demo_type == "" then
			if fireworks_reimagined.showcase.demo_timeline(name) then
				return true, "Timeline showcase started!"
			end
			
		elseif demo_type == "patterns" then
			if fireworks_reimagined.showcase.demo_custom_pattern(name) then
				return true, "Custom patterns showcase started!"
			end
			
		elseif demo_type == "performance" then
			if fireworks_reimagined.showcase.demo_performance_system(name) then
				return true, "Performance system demonstrated!"
			end
			
		elseif demo_type == "all" then
			if fireworks_reimagined.showcase.demo_all_features(name) then
				return true, "Get ready for the display!"
			end
			
		else
			return false, "Usage: /fireworks_showcase [timeline|patterns|performance|all]"
		end
		
		return false, "Failed to start showcase"
	end
})
minetest.log("info", "[Fireworks] Showcase system loaded")
