This includes useful changes only. Oldest at the top, Newest at the bottom.

## OCT 2024
#### V1
* [Commit 58b560b - Initial Commit](https://github.com/DragonWrangler1/fireworks_reimagined/commit/58b560bef3d0b60589850109c388a23145ce6345)
* **Initial API Upload.**

* [Commit 6abe4f0 - update api, docs, and add new fireworks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/6abe4f06f532108fe9a762db66d21d22c940d800)
* **Updated the api simplifying it, updated docs to account for the api change, and added colored fireworks, to resemble fireworks_redo fireworks for colors**

* [Commit 76f6428 - add compat for fireworks and other minor updates](https://github.com/DragonWrangler1/fireworks_reimagined/commit/76f6428464ac341ce46429efb0b3af4896763aa6)
* **Added compat for the fireworks mod's fireworks. Added hour glass firework shape**

* [Commit b119c15 - update creeper fireworks, add new python script and update docs](https://github.com/DragonWrangler1/fireworks_reimagined/commit/b119c15b304b23e57250b8260633597902987ba0)
* **Updated creeper fireworks to be more visible, added a new python script to turn the lua color tables into images, updated docs.**

#### V2
* [Commit b11f539 - Update](https://github.com/DragonWrangler1/fireworks_reimagined/commit/b11f5399b7d4f126bd908c35135ad895f478499b)
* **Updated the api to allow for particle textures to be set. Added new function to allow for images to go up to 64px, and updated docs**

* [Commit 92ca38f - make fireworks no longer go through blocks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/92ca38f061874e620038e5e4555457977a16e692)
* **Updated Particles and entities to ensure they no longer clip through blocks**

* [Commit 21dbf5e - allow for adjustable cooldown](https://github.com/DragonWrangler1/fireworks_reimagined/commit/21dbf5e87bca7bc0a2bbe96a900766a8524956cb)
* **updated node registry function to allow for adjustable cooldown**

## NOV 2024
#### V3

* [Commit b6e1d23 - V3 fireworks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/b6e1d231e67415788bd5fbfff6ff37f69f9f558f)
* **Updated docs, Moved existing fireworks spawning functions under legacy, added new changelog file, cleaned up the code sorting it better, split api and most registries into separate files, added new fireworks api functions to replace the legacy functions, and allowed admins to now bypass fireworks cooldown.**

#### V4

* [Commit ? - V4 fireworks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/????)
* **Updated fireworks to use scale tweening to give a more accurate explosion effect, updated delay to allow for the blocks to instead have configurable delays (using a formspec), updated fireworks to have smoother spirals, removed legacy features as they are obsolete and have no benefits, allows for protected fireworks meaning if configured then only the owner can shoot them off (unless the user has the fireworks_master priv), Adds "multi-colored" fireworks (allows the user to configure the fireworks' colors), adds configurable shapes with the multi-colored fireworks block, improved spiral shape (no unfolds), improved default explosions. Now more visible, and updated docs**

#### V5

* [Commit ? - V5 Enhanced Realistic Edition](https://github.com/DragonWrangler1/fireworks_reimagined/commit/????)
* **MAJOR VISUAL OVERHAUL:**

**NEW FIREWORK PATTERNS:**
* Added **Weeping Willow** - particles shoot up then droop down realistically
* Added **Chrysanthemum** - expanding rings with delayed bursts  
* Added **Peony** - main burst followed by secondary breaking effects
* Enhanced **Christmas Tree** with star and ornament effects
* Improved **Flame** pattern with realistic fire physics
* Enhanced **Star** pattern with 3D rays and sparkle tips

**VISUAL ENHANCEMENTS:**
* **Enhanced particle physics** with realistic acceleration and drag
* **Multi-layered particle systems** with trails and breaking effects (7 layers vs 5)
* **Improved particle scaling** and fading animations with scale/alpha tweening
* **Ground illumination** and environmental lighting effects
* **Atmospheric pressure wave** effects with expanding ring particles
* **Realistic smoke and debris** systems with settling effects
* **Enhanced color blending** and alpha effects with 16 vibrant colors
* **New enhanced particle textures** (fireworks_enhanced_spark.png, fireworks_sparkle_enhanced.png)
* **Smart texture selection system** with particle-type specific textures

**ROCKET ENHANCEMENTS:**
* **Realistic thrust physics** with decreasing power over time
* **Enhanced trail system** with multiple particle types and layers
* **Wobble effects** and wind simulation using time-based calculations
* **Falling sparks** and smoke trails with realistic physics
* **Whistle sound effects** during flight

**EXPLOSION IMPROVEMENTS:**
* **Initial flash effects** for all explosions with bright scaling effects
* **Multi-stage particle spawning** (primary, secondary, glitter)
* **Enhanced particle breaking** with multiple stages (3-6 particles vs 2-4)
* **Realistic debris** and settling smoke with collision detection
* **Shape-specific sound variations** with echo effects
* **Finale effects** for spectacular patterns with sparkle bursts

**AUDIO ENHANCEMENTS:**
* **Shape-specific explosion sounds** with different pitch/gain variations
* **Echo and reverb effects** for larger explosions (burst, star, chrysanthemum)
* **Crackling sounds** for chaotic patterns
* **Rocket whistle sounds** during flight
* **Distance-based audio effects** with max hearing distance scaling

**ENVIRONMENTAL EFFECTS:**
* **Ground illumination** that lights up terrain around explosions
* **Atmospheric disturbance** particles for pressure wave effects
* **Pressure wave visual effects** with expanding particles
* **Wind interaction simulation** with time-based wind patterns
* **Realistic falling debris physics** with collision and removal

**ADVANCED GUI FRAMEWORK:**
* **Complete GUI overhaul** with tabbed interface (Basic, Advanced, Preview)
* **Live preview functionality** with Small, Full, and Finale Burst options
* **Pattern designer** with visual representation of colors and shapes
* **Quality presets** - One-click Ultra, High, Medium, Low settings
* **Advanced controls** with sliders for size, height, density, spread, duration
* **Save/Load system** for persistent pattern storage in player profiles
* **Help system** with built-in usage instructions

**ADAPTIVE PERFORMANCE SYSTEM:**
* **Quality-based particle scaling** for different performance levels
* **Smart particle count adjustment** based on system capabilities
* **Particle size modifiers** (Ultra: 0.8x, High: 0.9x, Medium/Low: 1.0x)
* **Efficient texture loading** with enhanced variety and cleanup systems
* **Performance monitoring** with automatic quality adaptation

**PROFESSIONAL TIMELINE SYSTEM:**
* **Timeline-based fireworks shows** with precise timing control
* **Multiple launch points** coordination for synchronized displays
* **Event types** - Firework, Sound, Lighting, Pause, Marker, Sync Point
* **Template system** for reusable show configurations
* **Loop and auto-cleanup** functionality

**SHOWCASE AND DEMO SYSTEM:**
* **Interactive demonstrations** of all enhanced features
* **Multiple demo types** - Timeline, Patterns, Performance, All
* **Help command system** with comprehensive feature documentation
* **Startup announcements** for enhanced features

**TECHNICAL IMPROVEMENTS:**
* **Enhanced particle properties** with scale/alpha tweening
* **Dynamic glow values** (12-20 range with variations)
* **Collision detection** with smart removal systems
* **Color transition functions** for smooth color blending
* **Wind simulation** with sine/cosine wave calculations
* **Breaking effect system** with initial flash and multiple stages
* **Trail system** with 7 layers and secondary shimmer particles (60% chance)

**PERFORMANCE OPTIMIZATIONS:**
* **Scalable quality system** adapts to different performance levels
* **Smart particle count management** prevents lag
* **Memory cleanup systems** ensure no performance degradation
* **Backward compatibility** maintained while enhancing visual experience

**NEW COMMANDS:**
* `/fireworks_showcase [timeline|patterns|performance|all]` - Demonstrate features
* `/fireworks_help` - Show comprehensive help for enhanced features
