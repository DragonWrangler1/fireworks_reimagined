--================================================================--
--=== PROFESSIONAL FIREWORKS TIMELINE SYSTEM ===--
--================================================================--

fireworks_reimagined.timeline = {}

-- Timeline data structure
local active_timelines = {}
local timeline_templates = {}

-- Timeline event types
local EVENT_TYPES = {
	FIREWORK = "firework",
	SOUND = "sound", 
	LIGHTING = "lighting",
	PAUSE = "pause",
	MARKER = "marker",
	SYNC_POINT = "sync_point"
}

-- Timeline class
local Timeline = {}
Timeline.__index = Timeline

function Timeline:new(name, creator)
	local timeline = {
		name = name or "Untitled Show",
		creator = creator or "Unknown",
		created_time = minetest.get_gametime(),
		duration = 60.0, -- seconds
		events = {},
		launch_points = {},
		settings = {
			loop = false,
			auto_cleanup = true,
			volume = 1.0,
			particle_multiplier = 1.0
		},
		state = {
			playing = false,
			paused = false,
			current_time = 0.0,
			start_time = 0.0,
			event_index = 1
		}
	}
	setmetatable(timeline, Timeline)
	return timeline
end

function Timeline:add_event(time, event_type, data)
	local event = {
		time = time,
		type = event_type,
		data = data or {},
		id = #self.events + 1,
		executed = false
	}
	
	table.insert(self.events, event)
	
	-- Sort events by time
	table.sort(self.events, function(a, b) return a.time < b.time end)
	
	return event.id
end

function Timeline:remove_event(event_id)
	for i, event in ipairs(self.events) do
		if event.id == event_id then
			table.remove(self.events, i)
			return true
		end
	end
	return false
end

function Timeline:add_launch_point(name, pos, type)
	self.launch_points[name] = {
		position = pos,
		type = type or "standard", -- standard, multi, fountain
		active = true,
		angle_offset = 0,
		power_multiplier = 1.0
	}
end

function Timeline:play()
	if self.state.playing then return false end
	
	self.state.playing = true
	self.state.paused = false
	self.state.start_time = minetest.get_gametime()
	self.state.current_time = 0.0
	self.state.event_index = 1
	
	-- Reset all events
	for _, event in ipairs(self.events) do
		event.executed = false
	end
	
	minetest.log("info", "[Fireworks Timeline] Started: " .. self.name)
	return true
end

function Timeline:pause()
	if not self.state.playing or self.state.paused then return false end
	
	self.state.paused = true
	minetest.log("info", "[Fireworks Timeline] Paused: " .. self.name)
	return true
end

function Timeline:resume()
	if not self.state.playing or not self.state.paused then return false end
	
	self.state.paused = false
	self.state.start_time = minetest.get_gametime() - self.state.current_time
	minetest.log("info", "[Fireworks Timeline] Resumed: " .. self.name)
	return true
end

function Timeline:stop()
	if not self.state.playing then return false end
	
	self.state.playing = false
	self.state.paused = false
	self.state.current_time = 0.0
	self.state.event_index = 1
	
	minetest.log("info", "[Fireworks Timeline] Stopped: " .. self.name)
	return true
end

function Timeline:update(dtime)
	if not self.state.playing or self.state.paused then return end
	
	-- Update current time
	self.state.current_time = minetest.get_gametime() - self.state.start_time
	
	-- Check if timeline is finished
	if self.state.current_time >= self.duration then
		if self.settings.loop then
			self:play() -- Restart
		else
			self:stop()
		end
		return
	end
	
	-- Execute events that should trigger now
	while self.state.event_index <= #self.events do
		local event = self.events[self.state.event_index]
		
		if event.time <= self.state.current_time and not event.executed then
			self:execute_event(event)
			event.executed = true
		elseif event.time > self.state.current_time then
			break
		end
		
		self.state.event_index = self.state.event_index + 1
	end
end

function Timeline:execute_event(event)
	if event.type == EVENT_TYPES.FIREWORK then
		self:execute_firework_event(event)
	elseif event.type == EVENT_TYPES.SOUND then
		self:execute_sound_event(event)
	elseif event.type == EVENT_TYPES.LIGHTING then
		self:execute_lighting_event(event)
	elseif event.type == EVENT_TYPES.MARKER then
		self:execute_marker_event(event)
	end
end

function Timeline:execute_firework_event(event)
	local data = event.data
	local launch_point_name = data.launch_point or "default"
	local launch_point = self.launch_points[launch_point_name]
	
	if not launch_point then
		minetest.log("error", "[Fireworks Timeline] Launch point not found: " .. launch_point_name)
		return
	end
	
	-- Adjust for performance
	local quality = fireworks_reimagined.performance.get_quality_settings()
	
	-- Ensure size field exists (fallback to intensity or default value)
	local size = data.size or data.intensity or 2.0
	
	-- Create firework with timeline data
	if data.pattern == "ip" then
		fireworks_reimagined.spawn_firework_explosion_ip(
			launch_point.position,
			data.shape or "sphere",
			false,
			data.color1,
			data.color2,
			data.alpha,
			data.texture,
			size * quality.particles_multiplier
		)
	else
		fireworks_reimagined.spawn_firework_explosion(
			launch_point.position,
			data.color1,
			data.color2,
			data.alpha,
			data.texture,
			size * quality.particles_multiplier
		)
	end
	
	-- Performance tracking
	fireworks_reimagined.performance.register_firework_start()
	minetest.after(5.0, function()
		fireworks_reimagined.performance.register_firework_end()
	end)
end

function Timeline:execute_sound_event(event)
	local data = event.data
	minetest.sound_play(data.sound, {
		pos = data.pos,
		max_hear_distance = data.distance or 100,
		gain = data.volume or 1.0,
		pitch = data.pitch or 1.0
	})
end

function Timeline:execute_lighting_event(event)
	-- Future: Environmental lighting effects
	minetest.log("info", "[Fireworks Timeline] Lighting event executed")
end

function Timeline:execute_marker_event(event)
	local data = event.data
	if data.message then
		minetest.chat_send_all("🎆 " .. data.message)
	end
end

function Timeline:get_progress()
	if not self.state.playing then return 0 end
	return math.min(1.0, self.state.current_time / self.duration)
end

function Timeline:export_data()
	return {
		name = self.name,
		creator = self.creator,
		duration = self.duration,
		events = self.events,
		launch_points = self.launch_points,
		settings = self.settings
	}
end

function Timeline:import_data(data)
	self.name = data.name or self.name
	self.duration = data.duration or self.duration
	self.events = data.events or {}
	self.launch_points = data.launch_points or {}
	self.settings = data.settings or self.settings
end

-- Timeline management functions
function fireworks_reimagined.timeline.create(name, creator)
	local timeline = Timeline:new(name, creator)
	active_timelines[name] = timeline
	return timeline
end

function fireworks_reimagined.timeline.get(name)
	return active_timelines[name]
end

function fireworks_reimagined.timeline.delete(name)
	if active_timelines[name] then
		active_timelines[name]:stop()
		active_timelines[name] = nil
		return true
	end
	return false
end

function fireworks_reimagined.timeline.list()
	local names = {}
	for name, _ in pairs(active_timelines) do
		table.insert(names, name)
	end
	return names
end

-- Template system
function fireworks_reimagined.timeline.create_template(name, template_data)
	timeline_templates[name] = template_data
end

function fireworks_reimagined.timeline.get_template(name)
	return timeline_templates[name]
end

function fireworks_reimagined.timeline.list_templates()
	local names = {}
	for name, _ in pairs(timeline_templates) do
		table.insert(names, name)
	end
	return names
end

-- Built-in templates
fireworks_reimagined.timeline.create_template("grand_finale", {
	name = "Grand Finale",
	duration = 30.0,
	events = {
		{time = 0.0, type = EVENT_TYPES.MARKER, data = {message = "Grand Finale Beginning!"}},
		{time = 2.0, type = EVENT_TYPES.FIREWORK, data = {shape = "sphere", color1 = "#FFD700", color2 = "#FF4500", size = 2.0}},
		{time = 4.0, type = EVENT_TYPES.FIREWORK, data = {shape = "star", color1 = "#FF0000", color2 = "#FFFFFF", size = 2.5}},
		{time = 6.0, type = EVENT_TYPES.FIREWORK, data = {shape = "chrysanthemum", color1 = "#00FF00", color2 = "#FFFF00", size = 2.0}},
		{time = 10.0, type = EVENT_TYPES.FIREWORK, data = {shape = "willow", color1 = "#FF69B4", color2 = "#DA70D6", size = 3.0}},
		{time = 15.0, type = EVENT_TYPES.FIREWORK, data = {shape = "peony", color1 = "#1E90FF", color2 = "#87CEEB", size = 2.5}},
		{time = 20.0, type = EVENT_TYPES.FIREWORK, data = {shape = "chaotic", color1 = "#FFD700", color2 = "#FF6347", size = 4.0}},
		{time = 25.0, type = EVENT_TYPES.MARKER, data = {message = "Final Burst!"}}
	}
})

fireworks_reimagined.timeline.create_template("romantic_evening", {
	name = "Romantic Evening",
	duration = 60.0,
	events = {
		{time = 0.0, type = EVENT_TYPES.MARKER, data = {message = "A Romantic Evening..."}},
		{time = 5.0, type = EVENT_TYPES.FIREWORK, data = {shape = "star", color1 = "#FFB6C1", color2 = "#FFFFFF", size = 1.5}},
		{time = 15.0, type = EVENT_TYPES.FIREWORK, data = {shape = "sphere", color1 = "#FF69B4", color2 = "#FFC0CB", size = 1.8}},
		{time = 30.0, type = EVENT_TYPES.FIREWORK, data = {shape = "willow", color1 = "#DA70D6", color2 = "#DDA0DD", size = 2.0}},
		{time = 45.0, type = EVENT_TYPES.FIREWORK, data = {shape = "chrysanthemum", color1 = "#FF1493", color2 = "#FFB6C1", size = 2.2}},
		{time = 55.0, type = EVENT_TYPES.MARKER, data = {message = "💕 Perfect Evening 💕"}}
	}
})

-- Global update loop
local timeline_update_timer = 0
minetest.register_globalstep(function(dtime)
	timeline_update_timer = timeline_update_timer + dtime
	
	if timeline_update_timer >= 0.1 then -- Update 10 times per second
		for _, timeline in pairs(active_timelines) do
			timeline:update(dtime)
		end
		timeline_update_timer = 0
	end
end)

-- Chat commands for timeline control
minetest.register_chatcommand("fireworks_timeline", {
	params = "<create|play|pause|resume|stop|list> [name] [template]",
	description = "Manage fireworks timelines",
	func = function(name, param)
		local args = param:split(" ")
		local cmd = args[1]
		local timeline_name = args[2]
		
		if cmd == "create" then
			if not timeline_name then
				return false, "Usage: /fireworks_timeline create <name> [template]"
			end
			
			local template_name = args[3]
			local timeline = fireworks_reimagined.timeline.create(timeline_name, name)
			
			if template_name and timeline_templates[template_name] then
				timeline:import_data(timeline_templates[template_name])
			end
			
			return true, "Timeline created: " .. timeline_name
			
		elseif cmd == "play" then
			if not timeline_name then
				return false, "Usage: /fireworks_timeline play <name>"
			end
			
			local timeline = fireworks_reimagined.timeline.get(timeline_name)
			if not timeline then
				return false, "Timeline not found: " .. timeline_name
			end
			
			if timeline:play() then
				return true, "Timeline started: " .. timeline_name
			else
				return false, "Timeline already playing: " .. timeline_name
			end
			
		elseif cmd == "pause" then
			if not timeline_name then
				return false, "Usage: /fireworks_timeline pause <name>"
			end
			
			local timeline = fireworks_reimagined.timeline.get(timeline_name)
			if not timeline then
				return false, "Timeline not found: " .. timeline_name
			end
			
			if timeline:pause() then
				return true, "Timeline paused: " .. timeline_name
			else
				return false, "Timeline not playing or already paused"
			end
			
		elseif cmd == "resume" then
			if not timeline_name then
				return false, "Usage: /fireworks_timeline resume <name>"
			end
			
			local timeline = fireworks_reimagined.timeline.get(timeline_name)
			if not timeline then
				return false, "Timeline not found: " .. timeline_name
			end
			
			if timeline:resume() then
				return true, "Timeline resumed: " .. timeline_name
			else
				return false, "Timeline not paused"
			end
			
		elseif cmd == "stop" then
			if not timeline_name then
				return false, "Usage: /fireworks_timeline stop <name>"
			end
			
			local timeline = fireworks_reimagined.timeline.get(timeline_name)
			if not timeline then
				return false, "Timeline not found: " .. timeline_name
			end
			
			if timeline:stop() then
				return true, "Timeline stopped: " .. timeline_name
			else
				return false, "Timeline not playing"
			end
			
		elseif cmd == "list" then
			local timelines = fireworks_reimagined.timeline.list()
			local templates = fireworks_reimagined.timeline.list_templates()
			
			local msg = "🎆 Active Timelines: " .. table.concat(timelines, ", ") .. "\n"
			msg = msg .. "📋 Templates: " .. table.concat(templates, ", ")
			
			return true, msg
			
		else
			return false, "Usage: /fireworks_timeline <create|play|pause|resume|stop|list> [name] [template]"
		end
	end
})

minetest.log("info", "[Fireworks] Timeline system loaded")