# Fireworks Reimagined API Documentation

## Overview

The Fireworks Reimagined mod provides a comprehensive API for creating spectacular firework displays with realistic physics, enhanced visual effects, and advanced control systems. This API supports everything from simple particle explosions to complex grid-based image fireworks.

## Table of Contents

1. [Core Firework Functions](#core-firework-functions)
2. [Node Registration](#node-registration)
3. [Entity Registration](#entity-registration)
4. [Color System](#color-system)
5. [Particle System](#particle-system)
6. [Shape System](#shape-system)
7. [Effects System](#effects-system)
8. [Available Shapes](#available-shapes)
9. [Color Functions](#color-functions)
10. [Examples](#examples)

---

## Core Firework Functions

### `fireworks_reimagined.spawn_firework_explosion(pos, shape, double, color_def, color_def_2, alpha, texture, psize)`

Creates an enhanced particle explosion with realistic physics and multi-layered effects.

**Parameters:**
- `pos` (table): Position vector `{x, y, z}` where the explosion occurs
- `shape` (string): Firework shape (see [Available Shapes](#available-shapes))
- `double` (boolean): Whether to create a double explosion effect
- `color_def` (string): Primary color in hex format (e.g., "#FF0000")
- `color_def_2` (string, optional): Secondary color for multi-color effects
- `alpha` (number, optional): Transparency value (0-255, default: 128)
- `texture` (string, optional): Custom particle texture
- `psize` (number, optional): Particle size multiplier

**Features:**
- Enhanced particle physics with realistic acceleration and drag
- Multi-layered particle systems with trails and breaking effects
- Wind simulation and environmental effects
- Scale and alpha tweening animations
- Dynamic glow effects based on particle type

**Example:**
```lua
-- Create a golden sphere firework
fireworks_reimagined.spawn_firework_explosion(
    {x = 0, y = 50, z = 0},
    "sphere",
    false,
    "#FFD700",
    "#FF4500",
    150,
    nil,
    3.0
)
```

### `fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers, texture, batch_size, log)`

Creates complex firework patterns from color grids (for image-based fireworks).

**Parameters:**
- `pos` (table): Center position
- `delay` (number): Explosion delay in seconds
- `color_grid` (table): 2D array of hex colors
- `depth_layers` (number): Number of 3D depth layers
- `texture` (string, optional): Base texture
- `batch_size` (number, optional): Particles per batch (default: 10)
- `log` (boolean, optional): Enable performance logging

---

## Node Registration

### `fireworks_reimagined.register_firework_node(tiles, shape, entity, cooldown, mese_cooldown, ip, options)`

Registers a firework launcher node with advanced configuration options.

**Parameters:**
- `tiles` (string or table): Node texture filename(s)
- `shape` (string): Firework shape
- `entity` (string): Associated entity name
- `cooldown` (number): Cooldown time in seconds
- `mese_cooldown` (number): Mesecon activation cooldown
- `ip` (boolean): Use individual particle system
- `options` (table, optional): Additional configuration options

**Options Table:**
- `description` (string): Custom node description
- `primary_color` (number): Primary color index (1-8)
- `tiles` (table): Override tiles array
- `on_construct` (function): Custom on_construct callback
- `on_punch` (function): Custom on_punch callback
- `on_rightclick` (function): Custom on_rightclick callback
- `on_dig` (function): Custom on_dig callback
- `on_place` (function): Custom on_place callback
- `overlay_tiles` (table): Additional overlay textures

**Features:**
- Owner-based protection system
- Configurable delays via formspec
- Multi-colored firework support via node param2
- Inventory management for fuses
- Admin bypass with `fireworks_master` privilege
- Mesecon support for automated triggering

**Example:**
```lua
fireworks_reimagined.register_firework_node(
    "fireworks_sphere.png",
    "sphere",
    "fireworks_reimagined:firework_entity",
    5.0,
    2.0,
    true,
    {
        description = "Sphere Firework Launcher",
        primary_color = 1
    }
)
```

---

## Entity Registration

### `fireworks_reimagined.register_firework_entity(name, def)`

Registers a firework rocket entity with realistic flight physics and trail systems.

**Parameters:**
- `name` (string): Entity name (e.g., "mymod:rocket")
- `def` (table): Entity definition with the following fields:
  - `firework_shape` (string): Shape for explosion (see [Available Shapes](#available-shapes))
  - `time_remaining` (number): Flight time in seconds
  - `spiral` (boolean): Enable spiral flight pattern
  - `spiral_force` (number): Spiral intensity (default: 100)
  - `spiral_radius` (number): Spiral radius (default: 0.1)
  - `thrust` (number): Upward thrust force (default: 15)
  - `firework_explosion` (function): Explosion callback function(pos, color1, color2)
  - `on_activate` (function, optional): Activation callback

**Features:**
- Realistic thrust physics with customizable acceleration
- Enhanced trail systems with particle effects
- Spiral or straight flight patterns
- Collision detection with players and mobs
- Static save disabled for performance

**Example:**
```lua
fireworks_reimagined.register_firework_entity("mymod:custom_rocket", {
    firework_shape = "sphere",
    time_remaining = 3.0,
    spiral = false,
    spiral_force = 100,
    spiral_radius = 0.1,
    thrust = 15,
    firework_explosion = function(pos, color1, color2)
        fireworks_reimagined.spawn_firework_explosion(
            pos, "sphere", false, color1, color2
        )
    end
})
```

---

## Color System

### `fireworks_reimagined.color_palette`

A table containing the available color definitions:

```lua
{
    {name = "Red", hex = "#FF0000"},
    {name = "Yellow", hex = "#FFFF00"},
    {name = "Blue", hex = "#0404B4"},
    {name = "White", hex = "#FFFFFF"},
    {name = "Orange", hex = "#FF903F"},
    {name = "Green", hex = "#008000"},
    {name = "Violet", hex = "#6600CC"},
    {name = "Cyan", hex = "#00C0C0"},
}
```

### `fireworks_reimagined.encode_colors(color1_idx, color2_idx)`

Encodes two color indices into a single param2 value for node storage.

**Parameters:**
- `color1_idx` (number): Primary color index (1-8)
- `color2_idx` (number): Secondary color index (1-8)

**Returns:** Encoded param2 value

### `fireworks_reimagined.decode_colors(param2)`

Decodes a param2 value back into color indices.

**Parameters:**
- `param2` (number): Encoded param2 value

**Returns:** color1_idx, color2_idx

### `fireworks_reimagined.get_color_by_index(idx)`

Gets hex color string from index.

**Parameters:**
- `idx` (number): Color index (1-8)

**Returns:** Hex color string (e.g., "#FF0000")

---

## Particle System

### `fireworks_reimagined.spawn_firework_explosion(pos, shape, double, color_def, color_def_2, alpha, texture, psize)`

See [Core Firework Functions](#core-firework-functions) for details.

### `fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers, texture, batch_size, log)`

Creates complex firework patterns from color grids (for image-based fireworks).

**Parameters:**
- `pos` (table): Center position `{x, y, z}`
- `delay` (number): Explosion delay in seconds
- `color_grid` (table): 2D array of hex colors
- `depth_layers` (number): Number of 3D depth layers
- `texture` (string, optional): Base texture
- `batch_size` (number, optional): Particles per batch (default: 1)
- `log` (boolean, optional): Enable performance logging

**Features:**
- Multi-stage explosion with initial flash and core ignition
- Primary grid explosion with color-based particles
- Atmospheric pressure waves with expanding rings

### `fireworks_reimagined.get_enhanced_particle_texture(color, alpha, particle_type)`

Returns an enhanced texture string for particles with colorization and effects.

**Parameters:**
- `color` (string): Hex color string
- `alpha` (number): Transparency value (0-255)
- `particle_type` (string): Particle type ("default", "sparkle", "smoke", "flame", "trail")

**Returns:** Texture string with colorization and effects applied

### `fireworks_reimagined.get_particle_variations(color_def, color_def_2, alpha)`

Returns particle property variations for burst-type fireworks.

**Parameters:**
- `color_def` (string): Primary color hex
- `color_def_2` (string): Secondary color hex
- `alpha` (number): Transparency value

**Returns:** Table with spark_props, break_props, and break_props1

### `fireworks_reimagined.scale_particle_count(base_count)`

Scales particle count for performance optimization.

**Parameters:**
- `base_count` (number): Base particle count

**Returns:** Scaled particle count

---

## Shape System

### `fireworks_reimagined.shape_functions`

A table containing registered shape functions. Shape functions define particle behavior and distribution patterns.

**Available Shapes:**
- sphere, star, ring, snowflake, spiral, hour_glass, burst, chaotic, flame

### `fireworks_reimagined.register_shape_function(name, func)`

Registers a custom shape function.

**Parameters:**
- `name` (string): Shape name
- `func` (function): Shape function with signature: `func(pos, radius, size, glow, eligible_players, color_def, color_def_2, explosion_colors, alpha, texture, spawn_colored_particle_func)`

**Example:**
```lua
fireworks_reimagined.register_shape_function("custom_shape", function(
    pos, radius, size, glow, eligible_players, color_def, color_def_2, 
    explosion_colors, alpha, texture, spawn_colored_particle_func)
    -- Custom particle spawning logic here
end)
```

---

## Effects System

### `fireworks_reimagined.create_explosion_finale_effects(pos, firework_shape, colors)`

Creates additional finale effects after an explosion.

**Parameters:**
- `pos` (table): Explosion position
- `firework_shape` (string): The firework shape that exploded
- `colors` (table): Array of hex color strings

**Features:**
- Shape-specific finale effects
- Secondary explosions and cascades

### `fireworks_reimagined.create_explosion_sound_effects(pos, firework_shape)`

Plays shape-appropriate sound effects for an explosion.

**Parameters:**
- `pos` (table): Explosion position
- `firework_shape` (string): The firework shape that exploded

**Features:**
- Shape-specific pitch and gain settings
- Echo/reverb effects based on shape
- Maximum hear distance of 180 blocks

---

## Available Shapes

The mod includes 9 different firework shapes with unique particle distribution patterns:

| Shape | Description | Special Features |
|-------|-------------|------------------|
| `sphere` | Classic spherical burst | Golden angle distribution, perfect symmetry |
| `star` | Star-shaped explosion | 3D rays with sparkle tips and tips bursts |
| `ring` | Ring-shaped pattern | Multi-layer expanding rings |
| `burst` | Chaotic burst pattern | Multi-property particle variations |
| `spiral` | Spiral pattern | Rotating upward motion with wobble |
| `chaotic` | Random chaotic pattern | Five different chaos algorithms |
| `flame` | Flame-like effect | Realistic fire physics with flicker |
| `snowflake` | Snowflake pattern | Six-armed crystalline structure |
| `hour_glass` | Hourglass shape | Dual-cone spiral formation |

---

## Color Functions

### `fireworks_reimagined.random_color()`

Generates a random bright color.

**Returns:** Hex color string

**Features:**
- Ensures at least one RGB channel is > 200 for bright colors
- Random selection from infinite color space

### `fireworks_reimagined.get_vibrant_color()`

Selects a random color from the vibrant color palette.

**Returns:** Hex color string from the palette

**Vibrant Palette:**
- Deep Pink (`#FF1493`)
- Cyan (`#00FFFF`)
- Gold (`#FFD700`)
- Orange Red (`#FF4500`)
- Lime Green (`#32CD32`)
- Blue Violet (`#8A2BE2`)
- Hot Pink (`#FF69B4`)
- Medium Spring Green (`#00FA9A`)
- Tomato (`#FF6347`)
- Dodger Blue (`#1E90FF`)
- Yellow (`#FFFF00`)
- Red (`#FF0000`)
- Lime (`#00FF00`)
- Blue (`#0000FF`)
- Magenta (`#FF00FF`)
- White (`#FFFFFF`)

### `fireworks_reimagined.get_color_transition(color1, color2, progress)`

Blends between two colors smoothly.

**Parameters:**
- `color1` (string): Starting hex color
- `color2` (string): Ending hex color
- `progress` (number): Blend progress (0.0 to 1.0)

**Returns:** Interpolated hex color string

**Example:**
```lua
local color = fireworks_reimagined.get_color_transition("#FF0000", "#0000FF", 0.5)
-- Returns a blend of red and blue
```

### `fireworks_reimagined.random_explosion_colors()`

Generates random colors for an explosion.

**Returns:** Table with 1-2 random colors

**Features:**
- 70% chance of vibrant colors
- 30% chance of completely random colors
- 50/50 chance of single or dual color selection

---

## Examples

### Basic Sphere Firework
```lua
-- Simple red sphere firework
fireworks_reimagined.spawn_firework_explosion(
    {x = 0, y = 50, z = 0},
    "sphere",
    false,
    "#FF0000",
    "#FFFF00",
    128
)
```

### Multi-Color Explosion
```lua
-- Golden ring with orange secondary color
fireworks_reimagined.spawn_firework_explosion(
    {x = 0, y = 60, z = 0},
    "ring",
    false,
    "#FFD700",
    "#FF4500",
    180,
    nil,
    4.0
)
```

### Custom Firework Node
```lua
-- Register a custom sphere launcher
fireworks_reimagined.register_firework_node(
    "default_cobble.png",
    "sphere",
    "fireworks_reimagined:firework_entity",
    3.0,    -- 3 second cooldown
    1.5,    -- 1.5 second mesecon cooldown
    true,   -- Use particle effects
    {
        description = "Sphere Firework Launcher",
        primary_color = 1
    }
)
```

### Custom Firework Entity
```lua
-- Register a custom rocket entity
fireworks_reimagined.register_firework_entity("mymod:custom_rocket", {
    firework_shape = "star",
    time_remaining = 3.5,
    spiral = true,
    spiral_force = 100,
    spiral_radius = 0.15,
    thrust = 15,
    firework_explosion = function(pos, color1, color2)
        fireworks_reimagined.spawn_firework_explosion(
            pos, "star", false, color1, color2
        )
    end
})
```

### Image-Based Firework Grid
```lua
-- Create a firework display from a color grid
local color_grid = {
    {"#FF0000", "#FF0000", "#FF0000"},
    {"#FF0000", "#FFFF00", "#FF0000"},
    {"#FF0000", "#FF0000", "#FF0000"}
}

fireworks_reimagined.register_firework_explosion(
    {x = 0, y = 50, z = 0},
    0.5,           -- delay
    color_grid,    -- color grid
    3,             -- depth layers
    nil,           -- texture
    5,             -- batch size
    false          -- logging
)
```

### Custom Shape Registration
```lua
-- Register a custom firework shape
fireworks_reimagined.register_shape_function("my_shape", function(
    pos, radius, size, glow, eligible_players, color_def, color_def_2, 
    explosion_colors, alpha, texture, spawn_colored_particle_func)
    
    -- Create a simple burst with 50 particles
    for i = 1, 50 do
        local angle = (i / 50) * math.pi * 2
        local velocity = {
            x = math.cos(angle) * radius * 2,
            y = math.random(2, 6),
            z = math.sin(angle) * radius * 2
        }
        spawn_colored_particle_func(velocity)
    end
end)
```

### Using Color Functions
```lua
-- Get a random vibrant color
local color = fireworks_reimagined.get_vibrant_color()
print("Selected color: " .. color)

-- Create a color transition
local blend = fireworks_reimagined.get_color_transition("#FF0000", "#0000FF", 0.5)

-- Get explosion colors
local colors = fireworks_reimagined.random_explosion_colors()
for _, color_value in ipairs(colors) do
    print("Explosion color: " .. color_value)
end
```

---

## Privileges

- **`fireworks_master`**: Bypass cooldowns and access protected fireworks
- **`fireworks_admin`**: Administrator privileges for fireworks configuration
- Standard players can only trigger their own fireworks unless `allow_others` is enabled

---

## Performance Notes

- Particle counts are dynamically calculated based on shape complexity
- Wind simulation adds realism without significant performance cost
- Eligible player system ensures only visible clients render particles
- Trail effects are applied during particle lifetime for smooth animations
- Shape functions determine particle density and behavior

---

## Items and Crafting

### Fuse
Used to trigger firework nodes. Can be placed in the fuse inventory slot of firework nodes.

**Crafting Recipe:**
```
S S S
S C S
S S S
```
Where S = farming:string, C = default:coal_lump
Yields 9 fuses

### Firework Item
A random firework craftitem that can be used directly by players. Limited to 3 uses per 4 seconds for normal players.

---

## Compatibility Notes

This API is designed for Minetest 5.14+ to support the enhanced particle tween system. The mod uses player-specific particle spawning for optimized network traffic and supports both spiral and straight flight paths for rocket entities.

For best visual results, use a shape that suits your color palette and adjust particle size (`psize`) based on distance from viewer.
