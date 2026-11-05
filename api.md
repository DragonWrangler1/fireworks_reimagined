This is the guide to the FIREWORKS REIMAGINED api.

This guide is here to help you registering your new fireworks. It describes the public API exposed by fireworks_reimagined. The mod targets Luanti 5.14+ (particle texture tweens and modern particle spawners).

The global table fireworks_reimagined is created by init.lua.

### QUICK START
```
-- Launch a single particle firework.
fireworks_reimagined.spawn_firework_explosion(
    pos,            -- vector
    "sphere",       -- shape name
    nil,            -- double (deprecated, ignored)
    "#FF0000",      -- primary color
    "#FFFF00",      -- secondary color (optional, defaults to primary)
    "255",          -- colorize alpha, 0-255
    nil,            -- base texture (optional)
    nil             -- particle size (optional, absolute)
)

-- Register a node that launches a registered firework entity.
fireworks_reimagined.register_firework_node(
    nil, "red_ring", "ring", "fireworks_reimagined:red_ring_firework_entity"
)
```


### FIREWORK SHAPES
* fireworks_reimagined.register_shape_function(name, func)
```
register_shape_function: allows you to register a custom shape function.
```

The built-in shape names are sphere, star, ring, burst, spiral, chaotic, flame, snowflake, and hour_glass.

Unknown shape names fall back to sphere and log a warning. Custom shapes can be added with register_shape_function.

A shape function receives the particle spawning helper as its final argument. Call it with a velocity vector and an optional options table. Supported options:

* **pos_offset** offsets the spawn position from the explosion center.
* **size_mult** multiplies the base particle size.
* **glow_mult** multiplies the base glow (clamped to 14).
* **lifetime_mult** multiplies the particle lifetime.
* **accel_mult** multiplies the computed acceleration.
* **custom_accel** uses a fixed acceleration vector.
* **no_wind** disables the ambient wind drift.

Registered shapes are stored in fireworks_reimagined.shape_functions.

The standard shape blocks are filtered by the fireworks_enabled_shapes setting. Shape functions remain registered regardless of that setting, so custom nodes can still use any built-in shape. Use fireworks_reimagined.is_shape_enabled(name) or fireworks_reimagined.get_enabled_shapes() to inspect the selection. The special year and creeper fireworks are not part of this list. Disabled shapes are unregistered; set fireworks_alias_disabled_shapes to true to alias their old names to the preferred legacy shape (burst when enabled, otherwise the first enabled shape).

#### EXAMPLE USAGE
* **fireworks_reimagined.register_shape_function** can be used to add a custom shape to your mod. In this example a heart shape is registered, and it receives the particle spawning helper as its final argument. Call that helper with a velocity vector and an optional options table to spawn each particle.
```
fireworks_reimagined.register_shape_function("heart", function(
    pos, radius, size, glow, eligible_players, color_def, color_def_2,
    explosion_colors, alpha, texture, spawn_particle
)
    -- spawn_particle(velocity, opts)
end)
```

* **fireworks_reimagined.register_shape_function** is used to register custom shape functions.


### FIREWORK NORMAL EXPLOSIONS
* fireworks_reimagined.spawn_firework_explosion(pos, shape, double, color_def, color_def_2, alpha, texture, psize)
```
spawn_firework_explosion: allows you to spawn the full visual explosion at pos.
```

* **pos** is the explosion center.
* **shape** controls the shape of the firework that occurs. Unknown names fall back to sphere.
* **double** is deprecated and ignored. It is kept for source compatibility.
* **color_def** when defined the fireworks will be this #RRGGBB color. Otherwise it defaults to #FFFFFF.
* **color_def_2** is the secondary color and defaults to color_def.
* **alpha** if defined sets the colorize alpha in the 0 to 255 range. Otherwise it defaults to 128.
* **texture** is the base texture used for particles.
* **psize** is the absolute base particle size.

The explosion consists of:

1. An initial soft cloud.
2. The shape-specific particle pattern.
3. Old-client particlespawner fallbacks (clients below 5.14).


* **fireworks_reimagined.spawn_firework_explosion** is used to spawn normal firework explosions. This can result in some impressive firework displays.


### FIREWORK GRID EXPLOSIONS
* fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers, texture, batch_size, log)
```
register_firework_explosion: schedules a grid/image firework explosion.
```

* **pos** is the explosion center.
* **delay** is the number of seconds before the grid appears.
* **color_grid** is a 2D array of #RRGGBB strings. #000000 is transparent.
* **depth_layers** is the number of Z layers. Defaults to 1.
* **texture** is the base texture. Defaults to fireworks_white.png.
* **batch_size** is the number of positions per particle spawner. Defaults to 1; values below 1 are clamped to 1.
* **log** logs the number of particle spawners used.


* **fireworks_reimagined.register_firework_explosion** is used to turn a color grid into a firework image.


### FIREWORK NODES
* fireworks_reimagined.register_firework_node(tiles, node_name, shape, entity, cooldown, mese_cooldown, ip, options)
```
register_firework_node: registers a firework spawner node as fireworks_reimagined:firework_<node_name>.
```

* **tiles** are the node tiles. A single string is repeated on all six faces.
* **node_name** is the suffix used in the registered node name.
* **shape** is used to pick the overlay icon and the entity launch sound.
* **entity** is an entity registered by register_firework_entity.
* **cooldown** is deprecated and ignored.
* **mese_cooldown** is deprecated and ignored.
* **ip** is deprecated and ignored.
* **options** are described below.

#### OPTIONS
* **tiles** overrides the tiles argument.
* **primary_color** is a palette index (1 to 11). It is used for the overlay tint and default c1.
* **icon_overlay** is the shape icon name. It is inferred from shape when omitted. Set it to false to disable it.
* **description** is the node description.
* **on_punch**, **on_rightclick**, **on_dig**, **on_place**, and **on_construct** override or extend the corresponding node callbacks. on_construct is called after the fuse inventory is created.

Each node gets:

* A fuse inventory list (size 1, max 15 items).
* Owner metadata (owner), allow_others, c1, and c2.
* An admin_delay setting controlled by administrators.
* Optional mesecons input/output and MCL redstone support.
* Wood placement/dig sounds when a wood node is available.

* **fireworks_reimagined.register_firework_node** is used to register blocks that shoot off fireworks after being right-clicked or activated with mesecons.


### FIREWORK ENTITIES
* fireworks_reimagined.register_firework_entity(name, def)
```
register_firework_entity: registers the flying rocket entity used by firework nodes.
```

* **firework_shape** is the shape name used for the explosion sound. Defaults to sphere.
* **firework_explosion** is function(pos, color1, color2). A safe sphere fallback is used when omitted.
* **time_remaining** is the flight time in seconds. Defaults to a random value between 2.3 and 2.7.
* **launch_noise** is the sound played on launch. No sound is played when omitted.
* **spiral** enables spiral flight.
* **spiral_force** is the spiral horizontal force. Defaults to 100.
* **spiral_radius** is the spiral turn rate. Defaults to 0.1.
* **thrust** is the upward thrust. Defaults to 15.
* **on_activate** is an extra activation callback. It is called after the defaults are set, so it may override them.

The entity removes itself after the explosion callback and plays one shape-specific explosion sound. Sound ownership lives in the entity, not in the explosion callback, so custom callbacks should not play their own sound.


* **fireworks_reimagined.register_firework_entity** is used to register custom firework entities to be shot off by firework nodes that will have custom effects.


### COLOR SYSTEM
fireworks_reimagined.color_palette contains 11 entries:

* **1 — White** — #FFFFFF
* **2 — Yellow** — #FFFF00
* **3 — Blue** — #0404B4
* **4 — Red** — #FF0000
* **5 — Orange** — #FF903F
* **6 — Green** — #008000
* **7 — Violet** — #6600CC
* **8 — Cyan** — #00C0C0
* **9 — Magenta** — #FF00FF
* **10 — Pink** — #FF69B4
* **11 — DarkGreen** — #004D00

fireworks_reimagined.get_color_by_index(index) returns the hex string for an index, falling back to white for out-of-range values.

fireworks_reimagined.get_particle_variations(color_def, color_def_2, alpha) returns the texture/spawner presets used by the burst shape and by the old-client fallback path. color_def_2 is normalized to color_def when nil.

#### COLOR UTILITIES
utilities/colors.lua also exposes:

* fireworks_reimagined.random_color()
* fireworks_reimagined.get_vibrant_color()
* fireworks_reimagined.get_color_transition(color1, color2, progress)
* fireworks_reimagined.random_explosion_colors()

These helpers are public conveniences and are not used internally.


### PARTICLE HELPERS
* fireworks_reimagined.get_enhanced_particle_texture(color, alpha, particle_type)
```
get_enhanced_particle_texture: builds a colorized particle texture.
```

particle_type may be default, sparkle, smoke, flame, or trail. Only existing textures are used, and smoke/flame/trail variants adjust opacity.

* **fireworks_reimagined.get_enhanced_particle_texture** is used to build a colorized particle texture.


* fireworks_reimagined.create_explosion_sound_effects(pos, firework_shape)
```
create_explosion_sound_effects: plays the single shape-specific explosion sound.
```

Called automatically by registered firework entities.

* **fireworks_reimagined.create_explosion_sound_effects** is used to play the single shape-specific explosion sound.


### SETTINGS THAT AFFECT THE API
* **fireworks_max_rockets** defaults to 2. Maximum rockets in the scan area.
* **fireworks_scan_radius** defaults to 12. Radius used for the rocket cap.
* **fireworks_enable_crafting** defaults to true. Enables colored firework recipes.
* **fireworks_enabled_shapes** defaults to all nine. Comma-separated standard shapes to register.
* **fireworks_alias_disabled_shapes** defaults to false. Alias removed shape names to the preferred legacy shape (burst when enabled).
* **fireworks_enable_mesecons** defaults to true. Gates mesecons and MCL redstone input and output.
* **fireworks_manual_refill** defaults to true. Requires a right-click after 10 mesecon/redstone activations.


### DEPRECATED API
The following parameters are accepted for compatibility but have no effect:

* double in spawn_firework_explosion.
* cooldown, mese_cooldown, and ip in register_firework_node.

create_explosion_finale_effects no longer exists.