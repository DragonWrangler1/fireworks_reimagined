# Fireworks Reimagined API Documentation

## Overview

The Fireworks Reimagined mod provides a comprehensive API for creating spectacular firework displays with realistic physics, enhanced visual effects, and advanced control systems. This API supports everything from simple particle explosions to complex timeline-based shows.

## Table of Contents

1. [Core Firework Functions](#core-firework-functions)
2. [Node Registration](#node-registration)
3. [Entity Registration](#entity-registration)
4. [Performance System](#performance-system)
5. [GUI System](#gui-system)
6. [Timeline System](#timeline-system)
7. [Showcase System](#showcase-system)
8. [Available Shapes](#available-shapes)
9. [Color System](#color-system)
10. [Examples](#examples)

---

## Core Firework Functions

### `fireworks_reimagined.spawn_firework_explosion_ip(pos, shape, double, color_def, color_def_2, alpha, texture, psize)`

Creates an enhanced individual particle explosion with realistic physics and multi-layered effects.

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
- Multi-layered particle systems (7 layers with trails and breaking effects)
- Wind simulation and environmental effects
- Scale and alpha tweening animations
- Collision detection and removal
- Ground illumination effects

**Example:**
```lua
-- Create a golden willow firework
fireworks_reimagined.spawn_firework_explosion_ip(
    {x = 0, y = 50, z = 0},
    "willow",
    false,
    "#FFD700",
    "#FF4500",
    150,
    nil,
    3.0
)
```

### `fireworks_reimagined.spawn_firework_explosion(pos, color_def, color_def_2, alpha, texture, psize)`

Creates a standard firework explosion with enhanced visual effects.

**Parameters:**
- `pos` (table): Position vector `{x, y, z}`
- `color_def` (string, optional): Primary color
- `color_def_2` (string, optional): Secondary color
- `alpha` (number, optional): Transparency (default: 150)
- `texture` (string, optional): Custom texture
- `psize` (number, optional): Size multiplier

**Features:**
- Initial flash effects
- Multi-stage particle spawning (primary, secondary, glitter)
- Performance-adaptive particle counts
- Enhanced color blending
- Realistic debris and smoke effects

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

### `fireworks_reimagined.register_firework_node(tiles, shape, entity, cooldown, mese_cooldown, ip)`

Registers a firework launcher node with advanced configuration options.

**Parameters:**
- `tiles` (string): Node texture filename
- `shape` (string): Firework shape
- `entity` (string): Associated entity name
- `cooldown` (number): Cooldown time in seconds
- `mese_cooldown` (number): Mesecon activation cooldown
- `ip` (boolean): Use individual particle system

**Features:**
- Owner-based protection system
- Configurable delays via formspec
- Multi-colored firework support
- Inventory management for fuses and rockets
- Admin bypass with `fireworks_master` privilege

**Example:**
```lua
fireworks_reimagined.register_firework_node(
    "fireworks_willow.png",
    "willow",
    "fireworks_reimagined:firework_entity",
    5.0,
    2.0,
    true
)
```

---

## Entity Registration

### `fireworks_reimagined.register_firework_entity(name, def)`

Registers a firework rocket entity with realistic flight physics.

**Parameters:**
- `name` (string): Entity name
- `def` (table): Entity definition with the following fields:
  - `firework_shape` (string): Shape for explosion
  - `time_remaining` (number): Flight time in seconds
  - `spiral` (boolean): Enable spiral flight pattern
  - `spiral_force` (number): Spiral intensity
  - `spiral_radius` (number): Spiral radius
  - `thrust` (number): Upward thrust force
  - `firework_explosion` (function): Explosion callback
  - `on_activate` (function, optional): Activation callback

**Features:**
- Realistic thrust physics with decreasing power
- Enhanced trail systems with multiple particle types
- Wobble effects and wind simulation
- Whistle sound effects during flight
- Collision detection with players and mobs

**Example:**
```lua
fireworks_reimagined.register_firework_entity("my_mod:custom_rocket", {
    firework_shape = "chrysanthemum",
    time_remaining = 4.0,
    spiral = false,
    thrust = 15,
    firework_explosion = function(pos, color1, color2)
        fireworks_reimagined.spawn_firework_explosion_ip(
            pos, "chrysanthemum", false, color1, color2
        )
    end
})
```

---

## Performance System

The performance system automatically adapts firework quality based on server performance and player count.

### Quality Levels

- **Ultra**: Maximum spectacle with 1.5x particles, all effects enabled
- **High**: Great balance with 1.2x particles, most effects
- **Medium**: Balanced performance with standard particle counts
- **Low**: Performance-first with 0.6x particles, basic effects
- **Minimal**: Potato mode with 0.3x particles, minimal effects

### API Functions

#### `fireworks_reimagined.performance.get_quality_settings()`
Returns current quality settings table.

#### `fireworks_reimagined.performance.set_player_quality(player_name, quality_level, use_auto)`
Sets quality level for a specific player.

#### `fireworks_reimagined.performance.get_stats()`
Returns performance statistics.

#### `fireworks_reimagined.performance.set_auto_adjust(enabled)`
Enables or disables automatic performance adjustment.

#### `fireworks_reimagined.performance.get_auto_adjust()`
Returns whether automatic performance adjustment is enabled.

---

## GUI System

### `fireworks_reimagined.gui.show_pattern_designer(player_name)`
Opens the advanced pattern designer interface with:
- Live preview functionality
- Quality presets (Ultra, High, Medium, Low)
- Advanced controls with sliders
- Save/Load system for patterns
- Built-in help system

### `fireworks_reimagined.gui.show_timeline_editor(player_name)`
Opens the timeline editor for creating firework shows.

### `fireworks_reimagined.gui.show_launcher_control(player_name)`
Opens the launcher control interface.

---

## Timeline System

Create synchronized firework shows with precise timing control.

### `fireworks_reimagined.timeline.create(name, creator)`
Creates a new timeline.

### `fireworks_reimagined.timeline.get(name)`
Retrieves an existing timeline.

### Timeline Methods

#### `timeline:add_launch_point(name, pos, type)`
Adds a launch point for fireworks.

#### `timeline:add_event(time, type, data)`
Adds an event to the timeline.

**Event Types:**
- `"firework"`: Launch a firework
- `"sound"`: Play a sound effect
- `"lighting"`: Environmental lighting
- `"pause"`: Pause execution
- `"marker"`: Display message
- `"sync"`: Synchronization point

#### `timeline:start()`
Starts timeline execution.

**Example:**
```lua
local timeline = fireworks_reimagined.timeline.create("my_show", "player_name")
timeline:add_launch_point("center", {x=0, y=50, z=0}, "standard")
timeline:add_event(1.0, "firework", {
    shape = "willow",
    color1 = "#FFD700",
    color2 = "#FF4500",
    launch_point = "center"
})
timeline:start()
```

---

## Showcase System

### `fireworks_reimagined.showcase.demo_timeline(player_name)`
Demonstrates timeline-based firework shows.

### `fireworks_reimagined.showcase.demo_patterns(player_name)`
Showcases all available firework patterns.

### `fireworks_reimagined.showcase.demo_performance(player_name)`
Demonstrates performance adaptation features.

---

## Available Shapes

The mod includes 15 different firework shapes:

| Shape | Description | Special Features |
|-------|-------------|------------------|
| `sphere` | Classic spherical burst | Uniform particle distribution |
| `star` | Star-shaped explosion | 3D rays with sparkle tips |
| `ring` | Ring-shaped pattern | Expanding circular formation |
| `burst` | Chaotic burst pattern | Random particle directions |
| `cube` | Cubic formation | Geometric particle arrangement |
| `spiral` | Spiral pattern | Smooth spiral motion |
| `chaotic` | Random chaotic pattern | Unpredictable particle behavior |
| `flame` | Flame-like effect | Realistic fire physics |
| `snowflake` | Snowflake pattern | Crystalline structure |
| `present` | Gift box shape | Festive rectangular pattern |
| `christmas_tree` | Christmas tree | Tree shape with star and ornaments |
| `hour_glass` | Hourglass shape | Dual-cone formation |
| `willow` | Weeping willow | Particles droop down realistically |
| `chrysanthemum` | Chrysanthemum flower | Expanding rings with delayed bursts |
| `peony` | Peony flower | Main burst with secondary breaking |

---

## Color System

### Vibrant Color Palette

The mod includes 16 vibrant colors for enhanced visual appeal:
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

### Color Functions

Colors can be specified as:
- Hex strings: `"#FF0000"`
- Random colors: Use `nil` for automatic color selection
- Color transitions: Automatic blending between two colors

---

## Examples

### Basic Firework
```lua
-- Simple red sphere firework
fireworks_reimagined.spawn_firework_explosion_ip(
    {x = 0, y = 50, z = 0},
    "sphere",
    false,
    "#FF0000"
)
```

### Multi-Color Willow
```lua
-- Golden willow with orange tips
fireworks_reimagined.spawn_firework_explosion_ip(
    {x = 0, y = 60, z = 0},
    "willow",
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
-- Register a custom chrysanthemum launcher
fireworks_reimagined.register_firework_node(
    "my_texture.png",
    "chrysanthemum",
    "my_mod:chrysanthemum_entity",
    3.0,  -- 3 second cooldown
    1.5,  -- 1.5 second mesecon cooldown
    true  -- Use individual particle system
)
```

### Timeline Show
```lua
-- Create a grand finale show
local show = fireworks_reimagined.timeline.create("grand_finale", player_name)

-- Add multiple launch points
show:add_launch_point("center", {x=0, y=50, z=0}, "standard")
show:add_launch_point("left", {x=-20, y=50, z=0}, "standard")
show:add_launch_point("right", {x=20, y=50, z=0}, "standard")

-- Synchronized finale
for i = 0, 10 do
    show:add_event(i * 0.2, "firework", {
        shape = math.random() > 0.5 and "chrysanthemum" or "peony",
        color1 = "#FFD700",
        color2 = "#FF4500",
        launch_point = i % 2 == 0 and "left" or "right"
    })
end

-- Final spectacular burst
show:add_event(3.0, "firework", {
    shape = "willow",
    color1 = "#FFFFFF",
    color2 = "#FFD700",
    launch_point = "center"
})

show:start()
```

---

## Chat Commands

- `/fireworks_showcase [timeline|patterns|performance|all]` - Demonstrate features
- `/fireworks_help` - Show comprehensive help
- `/fireworks_quality [ultra|high|medium|low|minimal|auto|auto_on|auto_off|stats|test]` - Set quality level
- `/fireworks_server_quality [quality] [auto_on|auto_off]` - Server-wide quality control (admin only)

---

## Settings

The mod supports several Minetest settings for server configuration:

### `fireworks_auto_performance_adjust` (boolean, default: true)
Enables automatic performance adjustment based on server load and player count. When enabled, the mod will automatically reduce firework quality during high server load to maintain smooth gameplay.

### `fireworks_default_quality` (enum, default: "high")
Sets the default quality level for fireworks. Options: ultra, high, medium, low, minimal.

### `fireworks_adjustment_cooldown` (float, default: 5.0)
Time in seconds between automatic performance adjustments. Higher values make the system less reactive to performance changes.

These settings can be configured in `minetest.conf` or through the server's settings interface.

---

## Privileges

- `fireworks_master` - Bypass cooldowns and access protected fireworks
- Standard players can only trigger their own fireworks unless `allow_others` is enabled

---

## Performance Notes

- The mod automatically adapts particle counts based on server performance
- Quality settings can be adjusted per-player or globally
- Distance-based quality reduction helps maintain performance
- Collision detection prevents particles from clipping through blocks
- Memory cleanup systems prevent performance degradation over time

---

## Compatibility

This API maintains backward compatibility while providing enhanced features. Legacy functions continue to work, but new features require the enhanced API calls.

For the most spectacular results, use the individual particle system (`ip = true`) with the new enhanced shapes like `willow`, `chrysanthemum`, and `peony`.
