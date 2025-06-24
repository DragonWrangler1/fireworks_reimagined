--================================================================--
--=== ADAPTIVE PERFORMANCE MONITORING SYSTEM ===--
--================================================================--

fireworks_reimagined.performance = {}

-- Performance quality levels
local QUALITY_LEVELS = {
	ultra = {
		particles_multiplier = 1.5,  -- Reduced from 2.0 to fix "too large" particles
		max_particles = 1800,        -- Reduced from 2000
		effects = "all",
		render_distance = 200,
		sound_distance = 180,
		environmental_effects = true,
		particle_trails = true,
		ground_illumination = true,
		particle_size_modifier = 0.8,  -- New setting to reduce particle size
		description = "Ultra Quality - Maximum Spectacle (Optimized)"
	},
	high = {
		particles_multiplier = 1.2,
		max_particles = 1200,
		effects = "most",
		render_distance = 150,
		sound_distance = 120,
		environmental_effects = true,
		particle_trails = true,
		ground_illumination = true,
		particle_size_modifier = 0.9,
		description = "High Quality - Great Balance"
	},
	medium = {
		particles_multiplier = 1.0,
		max_particles = 600,
		effects = "essential",
		render_distance = 100,
		sound_distance = 80,
		environmental_effects = false,
		particle_trails = true,
		ground_illumination = false,
		particle_size_modifier = 1.0,
		description = "Medium Quality - Balanced Performance"
	},
	low = {
		particles_multiplier = 0.6,
		max_particles = 300,
		effects = "basic",
		render_distance = 60,
		sound_distance = 50,
		environmental_effects = false,
		particle_trails = false,
		ground_illumination = false,
		particle_size_modifier = 1.0,
		description = "Low Quality - Performance First"
	},
	minimal = {
		particles_multiplier = 0.3,
		max_particles = 100,
		effects = "minimal",
		render_distance = 30,
		sound_distance = 25,
		environmental_effects = false,
		particle_trails = false,
		ground_illumination = false,
		particle_size_modifier = 1.0,
		description = "Minimal Quality - Potato Mode"
	}
}

-- Global performance state
local performance_data = {
	current_quality = minetest.settings:get("fireworks_default_quality") or "high",
	auto_adjust = minetest.settings:get_bool("fireworks_auto_performance_adjust", true),
	fps_samples = {},
	lag_samples = {},
	player_count = 0,
	active_fireworks = 0,
	last_adjustment = 0,
	adjustment_cooldown = tonumber(minetest.settings:get("fireworks_adjustment_cooldown")) or 5.0,
}

-- Player-specific settings
local player_settings = {}

-- Performance monitoring functions
function fireworks_reimagined.performance.get_server_lag()
	local start_time = minetest.get_us_time()
	-- Simple lag measurement
	minetest.after(0, function()
		local end_time = minetest.get_us_time()
		local lag = (end_time - start_time) / 1000 -- Convert to milliseconds
		
		-- Keep rolling average of last 10 samples
		table.insert(performance_data.lag_samples, lag)
		if #performance_data.lag_samples > 10 then
			table.remove(performance_data.lag_samples, 1)
		end
	end)
end

function fireworks_reimagined.performance.get_average_lag()
	if #performance_data.lag_samples == 0 then return 0 end
	
	local total = 0
	for _, lag in ipairs(performance_data.lag_samples) do
		total = total + lag
	end
	return total / #performance_data.lag_samples
end

function fireworks_reimagined.performance.get_player_count()
	return #minetest.get_connected_players()
end

function fireworks_reimagined.performance.should_reduce_quality()
	local avg_lag = fireworks_reimagined.performance.get_average_lag()
	local player_count = fireworks_reimagined.performance.get_player_count()
	
	-- Criteria for reducing quality
	local high_lag = avg_lag > 100 -- More than 100ms lag
	local many_players = player_count > 20
	local many_fireworks = performance_data.active_fireworks > 5
	
	return high_lag or (many_players and many_fireworks)
end

function fireworks_reimagined.performance.should_increase_quality()
	local avg_lag = fireworks_reimagined.performance.get_average_lag()
	local player_count = fireworks_reimagined.performance.get_player_count()
	
	-- Criteria for increasing quality
	local low_lag = avg_lag < 50 -- Less than 50ms lag
	local few_players = player_count < 10
	local few_fireworks = performance_data.active_fireworks < 2
	
	return low_lag and few_players and few_fireworks
end

function fireworks_reimagined.performance.adjust_quality()
	if not performance_data.auto_adjust then return end
	
	local current_time = minetest.get_gametime()
	if current_time - performance_data.last_adjustment < performance_data.adjustment_cooldown then
		return -- Too soon to adjust again
	end
	
	local current_quality = performance_data.current_quality
	local quality_levels = {"minimal", "low", "medium", "high", "ultra"}
	local current_index = 1
	
	-- Find current quality index
	for i, level in ipairs(quality_levels) do
		if level == current_quality then
			current_index = i
			break
		end
	end
	
	-- Determine if we should adjust
	if fireworks_reimagined.performance.should_reduce_quality() and current_index > 1 then
		performance_data.current_quality = quality_levels[current_index - 1]
		performance_data.last_adjustment = current_time
		minetest.log("info", "[Fireworks] Reducing quality to " .. performance_data.current_quality .. " due to performance")
		
		-- Notify players
		minetest.chat_send_all("🎆 Fireworks quality automatically reduced to maintain performance")
		
	elseif fireworks_reimagined.performance.should_increase_quality() and current_index < #quality_levels then
		performance_data.current_quality = quality_levels[current_index + 1]
		performance_data.last_adjustment = current_time
		minetest.log("info", "[Fireworks] Increasing quality to " .. performance_data.current_quality .. " - performance improved")
		
		-- Notify players
		minetest.chat_send_all("🎆 Fireworks quality automatically increased - better performance detected")
	end
end

-- Get current quality settings
function fireworks_reimagined.performance.get_quality_settings()
	return QUALITY_LEVELS[performance_data.current_quality] or QUALITY_LEVELS.medium
end

-- Track active fireworks
function fireworks_reimagined.performance.register_firework_start()
	performance_data.active_fireworks = performance_data.active_fireworks + 1
end

function fireworks_reimagined.performance.register_firework_end()
	performance_data.active_fireworks = math.max(0, performance_data.active_fireworks - 1)
end

-- Set auto-adjust setting
function fireworks_reimagined.performance.set_auto_adjust(enabled)
	performance_data.auto_adjust = enabled
	if enabled then
		minetest.log("info", "[Fireworks] Automatic performance adjustment enabled")
	else
		minetest.log("info", "[Fireworks] Automatic performance adjustment disabled")
	end
end

-- Get auto-adjust setting
function fireworks_reimagined.performance.get_auto_adjust()
	return performance_data.auto_adjust
end

-- Performance statistics for debugging
function fireworks_reimagined.performance.get_stats()
	return {
		current_quality = performance_data.current_quality,
		average_lag = fireworks_reimagined.performance.get_average_lag(),
		player_count = fireworks_reimagined.performance.get_player_count(),
		active_fireworks = performance_data.active_fireworks,
		auto_adjust = performance_data.auto_adjust,
		adjustment_cooldown = performance_data.adjustment_cooldown,
		quality_settings = fireworks_reimagined.performance.get_quality_settings()
	}
end

-- Admin command for server-wide quality control
minetest.register_chatcommand("fireworks_server_quality", {
	params = "[ultra|high|medium|low|minimal] [auto_on|auto_off] | [auto_on|auto_off]",
	description = "Control server-wide fireworks quality (admin only)",
	privs = {server = true},
	func = function(name, param)
		local args = param:split(" ")
		local updated = false
		
		if args[1] and QUALITY_LEVELS[args[1]] then
			performance_data.current_quality = args[1]
			minetest.chat_send_all("🎆 Server fireworks quality set to: " .. QUALITY_LEVELS[args[1]].description)
			updated = true
		end
		
		-- Check both args[1] and args[2] for auto commands
		for _, arg in ipairs(args) do
			if arg == "auto_on" then
				fireworks_reimagined.performance.set_auto_adjust(true)
				minetest.chat_send_all("🎆 Automatic quality adjustment enabled server-wide")
				updated = true
			elseif arg == "auto_off" then
				fireworks_reimagined.performance.set_auto_adjust(false)
				minetest.chat_send_all("🎆 Automatic quality adjustment disabled server-wide")
				updated = true
			end
		end
		
		if updated then
			return true, "Server fireworks settings updated"
		else
			local stats = fireworks_reimagined.performance.get_stats()
			return true, string.format(
				"🎆 Current Server Settings:\n" ..
				"Quality: %s\n" ..
				"Auto Adjust: %s\n" ..
				"Usage: /fireworks_server_quality [quality] [auto_on|auto_off]",
				stats.current_quality,
				stats.auto_adjust and "ON" or "OFF"
			)
		end
	end
})

-- Periodic performance monitoring
--[[local monitor_timer = 0
minetest.register_globalstep(function(dtime)
	monitor_timer = monitor_timer + dtime
	
	if monitor_timer >= 2.0 then -- Check every 2 seconds
		fireworks_reimagined.performance.get_server_lag()
		fireworks_reimagined.performance.adjust_quality()
		monitor_timer = 0
	end
end)]]

minetest.log("info", "[Fireworks] Performance monitoring system loaded")
minetest.log("info", "[Fireworks] Default quality: " .. performance_data.current_quality)
minetest.log("info", "[Fireworks] Auto-adjust: " .. (performance_data.auto_adjust and "enabled" or "disabled"))
minetest.log("info", "[Fireworks] Adjustment cooldown: " .. performance_data.adjustment_cooldown .. "s")
