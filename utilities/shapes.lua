-- Canonical order of the built-in firework shapes.
local known_shapes = {
	"sphere",
	"star",
	"ring",
	"burst",
	"spiral",
	"chaotic",
	"flame",
	"snowflake",
	"hour_glass",
}

local known_lookup = {}
for _, name in ipairs(known_shapes) do
	known_lookup[name] = true
end

local function parse_enabled_shapes(raw)
	local enabled = {}
	local saw_entry = false
	local invalid = {}

	-- Accept commas, semicolons, and whitespace as separators so the setting
	-- is forgiving when edited by hand.
	for token in tostring(raw or ""):gmatch("[^,%s;]+") do
		saw_entry = true
		local name = token:lower()
		if known_lookup[name] then
			enabled[name] = true
		else
			invalid[#invalid + 1] = token
		end
	end

	if #invalid > 0 then
		core.log("warning", "[fireworks_reimagined] Ignoring unknown shape(s) in " ..
			"fireworks_enabled_shapes: " .. table.concat(invalid, ", "))
	end

	-- An empty list means "all shapes". A list containing only invalid names
	-- also falls back to all shapes so a typo cannot silently remove content.
	if not saw_entry or next(enabled) == nil then
		if saw_entry then
			core.log("warning", "[fireworks_reimagined] No valid shapes in " ..
				"fireworks_enabled_shapes; enabling all shapes.")
		end
		for _, name in ipairs(known_shapes) do
			enabled[name] = true
		end
	end

	return enabled
end

local enabled_lookup = parse_enabled_shapes(core.settings:get("fireworks_enabled_shapes"))

local enabled_shapes = {}
for _, name in ipairs(known_shapes) do
	if enabled_lookup[name] then
		enabled_shapes[#enabled_shapes + 1] = name
	end
end

fireworks_reimagined.known_shapes = known_shapes
fireworks_reimagined.enabled_shapes = enabled_shapes

function fireworks_reimagined.is_shape_enabled(name)
	return enabled_lookup[tostring(name or ""):lower()] == true
end

function fireworks_reimagined.get_enabled_shapes()
	local copy = {}
	for i, name in ipairs(enabled_shapes) do
		copy[i] = name
	end
	return copy
end