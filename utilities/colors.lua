local function random_color()
    local r, g, b
    repeat
        r = math.random(0, 255)
        g = math.random(0, 255)
        b = math.random(0, 255)
    until r > 200 or g > 200 or b > 200
    return string.format("#%02X%02X%02X", r, g, b)
end

local function get_vibrant_color()
	local vibrant_colors = {
		"#FF1493",
		"#00FFFF",
		"#FFD700",
		"#FF4500",
		"#32CD32",
		"#8A2BE2",
		"#FF69B4",
		"#00FA9A",
		"#FF6347",
		"#1E90FF",
		"#FFFF00",
		"#FF0000",
		"#00FF00",
		"#0000FF",
		"#FF00FF",
		"#FFFFFF",
	}
	return vibrant_colors[math.random(#vibrant_colors)]
end

local function get_color_transition(color1, color2, progress)
	local r1, g1, b1 = tonumber(color1:sub(2,3), 16), tonumber(color1:sub(4,5), 16), tonumber(color1:sub(6,7), 16)
	local r2, g2, b2 = tonumber(color2:sub(2,3), 16), tonumber(color2:sub(4,5), 16), tonumber(color2:sub(6,7), 16)
	
	local r = math.floor(r1 + (r2 - r1) * progress)
	local g = math.floor(g1 + (g2 - g1) * progress)
	local b = math.floor(b1 + (b2 - b1) * progress)
	
	return string.format("#%02X%02X%02X", r, g, b)
end

local function random_explosion_colors()
    local color1, color2
    if math.random() < 0.7 then
        color1 = get_vibrant_color()
        color2 = get_vibrant_color()
    else
        color1 = random_color()
        color2 = random_color()
    end
    
    if math.random(2) == 1 then
        return {color1}
    else
        return {color1, color2}
    end
end

fireworks_reimagined.random_color = random_color
fireworks_reimagined.get_vibrant_color = get_vibrant_color
fireworks_reimagined.get_color_transition = get_color_transition
fireworks_reimagined.random_explosion_colors = random_explosion_colors
