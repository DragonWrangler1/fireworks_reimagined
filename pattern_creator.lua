--================================================================--
--=== CUSTOM PATTERN CREATOR - VISUAL PROGRAMMING SYSTEM ===--
--================================================================--

fireworks_reimagined.pattern_creator = {}

-- Pattern node types for visual programming
local PATTERN_NODES = {
	-- Source nodes
	ORIGIN = "origin",
	SPHERE = "sphere", 
	CYLINDER = "cylinder",
	CONE = "cone",
	
	-- Transform nodes
	ROTATE = "rotate",
	SCALE = "scale",
	TRANSLATE = "translate",
	MIRROR = "mirror",
	
	-- Effect nodes
	PARTICLE = "particle",
	TRAIL = "trail",
	EXPLOSION = "explosion",
	DELAY = "delay",
	
	-- Modifier nodes
	COLOR = "color",
	PHYSICS = "physics",
	LIFETIME = "lifetime",
	RANDOM = "random",
	
	-- Control nodes
	SEQUENCE = "sequence",
	PARALLEL = "parallel",
	REPEAT = "repeat",
	CONDITION = "condition"
}

-- Pattern node definitions
local NODE_DEFINITIONS = {
	[PATTERN_NODES.ORIGIN] = {
		name = "Origin Point",
		description = "Starting point for particle generation",
		inputs = {},
		outputs = {"position"},
		params = {
			{name = "x", type = "number", default = 0, min = -10, max = 10},
			{name = "y", type = "number", default = 0, min = -10, max = 10},
			{name = "z", type = "number", default = 0, min = -10, max = 10}
		},
		color = "#4CAF50"
	},
	
	[PATTERN_NODES.SPHERE] = {
		name = "Sphere Generator",
		description = "Generate particles in a spherical pattern",
		inputs = {"position"},
		outputs = {"particles"},
		params = {
			{name = "radius", type = "number", default = 5, min = 1, max = 20},
			{name = "density", type = "number", default = 50, min = 10, max = 200},
			{name = "hollow", type = "boolean", default = false}
		},
		color = "#2196F3"
	},
	
	[PATTERN_NODES.ROTATE] = {
		name = "Rotation Transform",
		description = "Rotate particles around an axis",
		inputs = {"particles"},
		outputs = {"particles"},
		params = {
			{name = "axis_x", type = "number", default = 0, min = -1, max = 1},
			{name = "axis_y", type = "number", default = 1, min = -1, max = 1},
			{name = "axis_z", type = "number", default = 0, min = -1, max = 1},
			{name = "angle", type = "number", default = 0, min = -360, max = 360},
			{name = "continuous", type = "boolean", default = false}
		},
		color = "#FF9800"
	},
	
	[PATTERN_NODES.COLOR] = {
		name = "Color Modifier",
		description = "Apply colors to particles",
		inputs = {"particles"},
		outputs = {"particles"},
		params = {
			{name = "color1", type = "color", default = "#FFD700"},
			{name = "color2", type = "color", default = "#FF4500"},
			{name = "blend_mode", type = "select", options = {"lerp", "random", "gradient"}, default = "lerp"},
			{name = "alpha", type = "number", default = 255, min = 0, max = 255}
		},
		color = "#E91E63"
	},
	
	[PATTERN_NODES.EXPLOSION] = {
		name = "Explosion Effect",
		description = "Create explosion with particles",
		inputs = {"particles"},
		outputs = {"effect"},
		params = {
			{name = "force", type = "number", default = 1.0, min = 0.1, max = 5.0},
			{name = "spread", type = "number", default = 1.0, min = 0.1, max = 3.0},
			{name = "duration", type = "number", default = 2.0, min = 0.5, max = 10.0}
		},
		color = "#F44336"
	},
	
	[PATTERN_NODES.DELAY] = {
		name = "Delay",
		description = "Add timing delay",
		inputs = {"effect"},
		outputs = {"effect"},
		params = {
			{name = "time", type = "number", default = 1.0, min = 0.1, max = 10.0},
			{name = "random_offset", type = "number", default = 0, min = 0, max = 2.0}
		},
		color = "#9C27B0"
	}
}

-- Pattern graph class
local PatternGraph = {}
PatternGraph.__index = PatternGraph

function PatternGraph:new(name, creator)
	local graph = {
		name = name or "Custom Pattern",
		creator = creator or "Unknown",
		nodes = {},
		connections = {},
		next_node_id = 1,
		parameters = {},
		compiled = false,
		compiled_function = nil
	}
	setmetatable(graph, PatternGraph)
	return graph
end

function PatternGraph:add_node(node_type, x, y, params)
	if not NODE_DEFINITIONS[node_type] then
		return nil, "Invalid node type: " .. node_type
	end
	
	local node_def = NODE_DEFINITIONS[node_type]
	local node = {
		id = self.next_node_id,
		type = node_type,
		x = x or 0,
		y = y or 0,
		params = {},
		inputs = {},
		outputs = {}
	}
	
	-- Initialize parameters with defaults
	for _, param_def in ipairs(node_def.params) do
		node.params[param_def.name] = params and params[param_def.name] or param_def.default
	end
	
	-- Initialize input/output connections
	for _, input_name in ipairs(node_def.inputs) do
		node.inputs[input_name] = nil
	end
	
	for _, output_name in ipairs(node_def.outputs) do
		node.outputs[output_name] = {}
	end
	
	self.nodes[node.id] = node
	self.next_node_id = self.next_node_id + 1
	
	return node.id
end

function PatternGraph:remove_node(node_id)
	local node = self.nodes[node_id]
	if not node then return false end
	
	-- Remove all connections to/from this node
	for _, connection in ipairs(self.connections) do
		if connection.from_node == node_id or connection.to_node == node_id then
			self:remove_connection(connection.id)
		end
	end
	
	self.nodes[node_id] = nil
	self.compiled = false
	return true
end

function PatternGraph:connect_nodes(from_node_id, from_output, to_node_id, to_input)
	local from_node = self.nodes[from_node_id]
	local to_node = self.nodes[to_node_id]
	
	if not from_node or not to_node then
		return false, "Node not found"
	end
	
	-- Validate connection compatibility
	local from_def = NODE_DEFINITIONS[from_node.type]
	local to_def = NODE_DEFINITIONS[to_node.type]
	
	local from_valid = false
	for _, output in ipairs(from_def.outputs) do
		if output == from_output then
			from_valid = true
			break
		end
	end
	
	local to_valid = false
	for _, input in ipairs(to_def.inputs) do
		if input == to_input then
			to_valid = true
			break
		end
	end
	
	if not from_valid or not to_valid then
		return false, "Invalid connection ports"
	end
	
	-- Create connection
	local connection = {
		id = #self.connections + 1,
		from_node = from_node_id,
		from_output = from_output,
		to_node = to_node_id,
		to_input = to_input
	}
	
	table.insert(self.connections, connection)
	
	-- Update node connections
	table.insert(from_node.outputs[from_output], connection)
	to_node.inputs[to_input] = connection
	
	self.compiled = false
	return connection.id
end

function PatternGraph:remove_connection(connection_id)
	for i, connection in ipairs(self.connections) do
		if connection.id == connection_id then
			-- Remove from node references
			local from_node = self.nodes[connection.from_node]
			local to_node = self.nodes[connection.to_node]
			
			if from_node then
				local outputs = from_node.outputs[connection.from_output]
				for j, conn in ipairs(outputs) do
					if conn.id == connection_id then
						table.remove(outputs, j)
						break
					end
				end
			end
			
			if to_node then
				to_node.inputs[connection.to_input] = nil
			end
			
			table.remove(self.connections, i)
			self.compiled = false
			return true
		end
	end
	return false
end

function PatternGraph:compile()
	-- Topological sort to determine execution order
	local execution_order = self:topological_sort()
	if not execution_order then
		return false, "Circular dependency detected"
	end
	
	-- Generate execution function
	local function execute_pattern(pos, params)
		local node_values = {}
		local performance_quality = fireworks_reimagined.performance.get_quality_settings()
		
		-- Execute nodes in order
		for _, node_id in ipairs(execution_order) do
			local node = self.nodes[node_id]
			local node_def = NODE_DEFINITIONS[node.type]
			
			-- Get input values
			local input_values = {}
			for input_name, connection in pairs(node.inputs) do
				if connection then
					local from_node = self.nodes[connection.from_node]
					input_values[input_name] = node_values[from_node.id] and node_values[from_node.id][connection.from_output]
				end
			end
			
			-- Execute node
			local output_values = self:execute_node(node, input_values, pos, params, performance_quality)
			node_values[node_id] = output_values
		end
		
		return node_values
	end
	
	self.compiled_function = execute_pattern
	self.compiled = true
	return true
end

function PatternGraph:execute_node(node, inputs, pos, params, quality)
	local node_def = NODE_DEFINITIONS[node.type]
	local outputs = {}
	
	if node.type == PATTERN_NODES.ORIGIN then
		outputs.position = {
			x = pos.x + node.params.x,
			y = pos.y + node.params.y,
			z = pos.z + node.params.z
		}
		
	elseif node.type == PATTERN_NODES.SPHERE then
		local center = inputs.position or pos
		local particles = {}
		local density = math.floor(node.params.density * quality.particles_multiplier)
		
		for i = 1, density do
			local theta = math.random() * math.pi * 2
			local phi = math.acos(math.random() * 2 - 1)
			local r = node.params.hollow and node.params.radius or math.random() * node.params.radius
			
			table.insert(particles, {
				x = center.x + r * math.sin(phi) * math.cos(theta),
				y = center.y + r * math.cos(phi),
				z = center.z + r * math.sin(phi) * math.sin(theta)
			})
		end
		
		outputs.particles = particles
		
	elseif node.type == PATTERN_NODES.ROTATE then
		local particles = inputs.particles or {}
		local rotated_particles = {}
		
		local axis = vector.normalize({
			x = node.params.axis_x,
			y = node.params.axis_y,
			z = node.params.axis_z
		})
		local angle = math.rad(node.params.angle)
		
		for _, particle in ipairs(particles) do
			local rotated = self:rotate_point(particle, axis, angle)
			table.insert(rotated_particles, rotated)
		end
		
		outputs.particles = rotated_particles
		
	elseif node.type == PATTERN_NODES.COLOR then
		local particles = inputs.particles or {}
		local colored_particles = {}
		
		for _, particle in ipairs(particles) do
			local colored_particle = {
				x = particle.x,
				y = particle.y,
				z = particle.z,
				color1 = node.params.color1,
				color2 = node.params.color2,
				alpha = node.params.alpha
			}
			table.insert(colored_particles, colored_particle)
		end
		
		outputs.particles = colored_particles
		
	elseif node.type == PATTERN_NODES.EXPLOSION then
		local particles = inputs.particles or {}
		
		-- Create explosion effect
		for _, particle in ipairs(particles) do
			minetest.add_particle({
				pos = particle,
				velocity = {
					x = (math.random() - 0.5) * node.params.spread * node.params.force,
					y = (math.random() - 0.5) * node.params.spread * node.params.force,
					z = (math.random() - 0.5) * node.params.spread * node.params.force
				},
				acceleration = {x = 0, y = -9.81, z = 0},
				expirationtime = node.params.duration,
				size = math.random(15, 30) / 10,
				texture = {
					name = "fireworks_spark_white.png^[colorize:" .. (particle.color1 or "#FFD700") .. ":200",
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.0,
						-0.02
					}
				},
				glow = 12,
				collisiondetection = false
			})
		end
		
		outputs.effect = {created = true, particle_count = #particles}
		
	elseif node.type == PATTERN_NODES.DELAY then
		local effect = inputs.effect
		local delay_time = node.params.time + math.random() * node.params.random_offset
		
		minetest.after(delay_time, function()
			-- Effect will be delayed
		end)
		
		outputs.effect = effect
	end
	
	return outputs
end

function PatternGraph:rotate_point(point, axis, angle)
	-- Rodrigues' rotation formula
	local cos_angle = math.cos(angle)
	local sin_angle = math.sin(angle)
	
	local dot = point.x * axis.x + point.y * axis.y + point.z * axis.z
	local cross = {
		x = axis.y * point.z - axis.z * point.y,
		y = axis.z * point.x - axis.x * point.z,
		z = axis.x * point.y - axis.y * point.x
	}
	
	return {
		x = point.x * cos_angle + cross.x * sin_angle + axis.x * dot * (1 - cos_angle),
		y = point.y * cos_angle + cross.y * sin_angle + axis.y * dot * (1 - cos_angle),
		z = point.z * cos_angle + cross.z * sin_angle + axis.z * dot * (1 - cos_angle)
	}
end

function PatternGraph:topological_sort()
	local in_degree = {}
	local queue = {}
	local result = {}
	
	-- Initialize in-degrees
	for node_id, _ in pairs(self.nodes) do
		in_degree[node_id] = 0
	end
	
	-- Calculate in-degrees
	for _, connection in ipairs(self.connections) do
		in_degree[connection.to_node] = in_degree[connection.to_node] + 1
	end
	
	-- Find nodes with no incoming edges
	for node_id, degree in pairs(in_degree) do
		if degree == 0 then
			table.insert(queue, node_id)
		end
	end
	
	-- Process queue
	while #queue > 0 do
		local node_id = table.remove(queue, 1)
		table.insert(result, node_id)
		
		-- Update neighbors
		for _, connection in ipairs(self.connections) do
			if connection.from_node == node_id then
				in_degree[connection.to_node] = in_degree[connection.to_node] - 1
				if in_degree[connection.to_node] == 0 then
					table.insert(queue, connection.to_node)
				end
			end
		end
	end
	
	-- Check for cycles
	if #result ~= self:node_count() then
		return nil -- Circular dependency
	end
	
	return result
end

function PatternGraph:node_count()
	local count = 0
	for _ in pairs(self.nodes) do
		count = count + 1
	end
	return count
end

function PatternGraph:execute(pos, params)
	if not self.compiled then
		local success, error = self:compile()
		if not success then
			return false, error
		end
	end
	
	return self.compiled_function(pos, params or {})
end

function PatternGraph:export()
	return {
		name = self.name,
		creator = self.creator,
		nodes = self.nodes,
		connections = self.connections,
		parameters = self.parameters
	}
end

function PatternGraph:import(data)
	self.name = data.name or self.name
	self.creator = data.creator or self.creator
	self.nodes = data.nodes or {}
	self.connections = data.connections or {}
	self.parameters = data.parameters or {}
	self.compiled = false
	
	-- Update next_node_id
	local max_id = 0
	for node_id, _ in pairs(self.nodes) do
		max_id = math.max(max_id, node_id)
	end
	self.next_node_id = max_id + 1
end

-- Pattern library management
local pattern_library = {}

function fireworks_reimagined.pattern_creator.create_pattern(name, creator)
	return PatternGraph:new(name, creator)
end

function fireworks_reimagined.pattern_creator.save_pattern(pattern, name)
	name = name or pattern.name
	pattern_library[name] = pattern:export()
	return true
end

function fireworks_reimagined.pattern_creator.load_pattern(name)
	local data = pattern_library[name]
	if not data then return nil end
	
	local pattern = PatternGraph:new()
	pattern:import(data)
	return pattern
end

function fireworks_reimagined.pattern_creator.list_patterns()
	local names = {}
	for name, _ in pairs(pattern_library) do
		table.insert(names, name)
	end
	return names
end

function fireworks_reimagined.pattern_creator.get_node_definitions()
	return NODE_DEFINITIONS
end

-- Example pattern creation
local function create_example_patterns()
	-- Simple burst pattern
	local burst_pattern = fireworks_reimagined.pattern_creator.create_pattern("Simple Burst", "System")
	local origin_id = burst_pattern:add_node(PATTERN_NODES.ORIGIN, 0, 0)
	local sphere_id = burst_pattern:add_node(PATTERN_NODES.SPHERE, 1, 0, {radius = 8, density = 100})
	local color_id = burst_pattern:add_node(PATTERN_NODES.COLOR, 2, 0, {color1 = "#FFD700", color2 = "#FF4500"})
	local explosion_id = burst_pattern:add_node(PATTERN_NODES.EXPLOSION, 3, 0, {force = 1.5, spread = 2.0})
	
	burst_pattern:connect_nodes(origin_id, "position", sphere_id, "position")
	burst_pattern:connect_nodes(sphere_id, "particles", color_id, "particles")
	burst_pattern:connect_nodes(color_id, "particles", explosion_id, "particles")
	
	fireworks_reimagined.pattern_creator.save_pattern(burst_pattern, "simple_burst")
	
	-- Rotating star pattern
	local star_pattern = fireworks_reimagined.pattern_creator.create_pattern("Rotating Star", "System")
	local origin_id2 = star_pattern:add_node(PATTERN_NODES.ORIGIN, 0, 0)
	local sphere_id2 = star_pattern:add_node(PATTERN_NODES.SPHERE, 1, 0, {radius = 10, density = 80, hollow = true})
	local rotate_id = star_pattern:add_node(PATTERN_NODES.ROTATE, 2, 0, {axis_y = 1, angle = 45})
	local color_id2 = star_pattern:add_node(PATTERN_NODES.COLOR, 3, 0, {color1 = "#00FF00", color2 = "#FFFF00"})
	local explosion_id2 = star_pattern:add_node(PATTERN_NODES.EXPLOSION, 4, 0, {force = 1.0, spread = 1.5})
	
	star_pattern:connect_nodes(origin_id2, "position", sphere_id2, "position")
	star_pattern:connect_nodes(sphere_id2, "particles", rotate_id, "particles")
	star_pattern:connect_nodes(rotate_id, "particles", color_id2, "particles")
	star_pattern:connect_nodes(color_id2, "particles", explosion_id2, "particles")
	
	fireworks_reimagined.pattern_creator.save_pattern(star_pattern, "rotating_star")
end

-- Initialize example patterns
create_example_patterns()

-- Chat command for pattern testing
minetest.register_chatcommand("test_pattern", {
	params = "<pattern_name>",
	description = "Test a custom firework pattern",
	func = function(name, param)
		local pattern_name = param:trim()
		if pattern_name == "" then
			local patterns = fireworks_reimagined.pattern_creator.list_patterns()
			return true, "Available patterns: " .. table.concat(patterns, ", ")
		end
		
		local pattern = fireworks_reimagined.pattern_creator.load_pattern(pattern_name)
		if not pattern then
			return false, "Pattern not found: " .. pattern_name
		end
		
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		
		local pos = player:get_pos()
		pos.y = pos.y + 20
		
		local success, result = pattern:execute(pos)
		if success then
			return true, "🎆 Pattern executed: " .. pattern_name
		else
			return false, "Pattern execution failed: " .. tostring(result)
		end
	end
})

minetest.log("info", "[Fireworks] Custom pattern creator loaded")