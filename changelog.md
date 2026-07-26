This includes useful changes only. Oldest at the top, Newest at the bottom.

## OCT. 2024
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

## NOV. 2024
#### V3

* [Commit b6e1d23 - V3 fireworks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/b6e1d231e67415788bd5fbfff6ff37f69f9f558f)
* **Updated docs, Moved existing fireworks spawning functions under legacy, added new changelog file, cleaned up the code sorting it better, split api and most registries into separate files, added new fireworks api functions to replace the legacy functions, and allowed admins to now bypass fireworks cooldown.**

#### V4

* [Commit ? - V4 fireworks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/????)
* **Updated fireworks to use scale tweening to give a more accurate explosion effect, updated delay to allow for the blocks to instead have configurable delays (using a formspec), updated fireworks to have smoother spirals, removed legacy features as they are obsolete and have no benefits, allows for protected fireworks meaning if configured then only the owner can shoot them off (unless the user has the fireworks_master priv), Adds "multi-colored" fireworks (allows the user to configure the fireworks' colors), adds configurable shapes with the multi-colored fireworks block, improved spiral shape (no unfolds), improved default explosions. Now more visible, and updated docs**

## Aug. 2025
#### V5

* [Commit ? - V5 fireworks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/????)
* **MINOR VISUAL OVERHAUL:**

## Dec. 2025
#### V6

* [Commit ? - V6 fireworks](https://github.com/DragonWrangler1/fireworks_reimagined/commit/????)
* **MAJOR SYSTEM AND VISUAL OVERHAUL:** 
* **Reduced init.lua from 2837 lines to 16 lines through separation of contents.**
* **Removed complex V5 features (pattern creator, performance monitor, showcase, test blocks, timeline system) to simplify the mod.**
* **Implemented dynamic color and shape combinations creating 576+ unique fireworks types (9 shapes × 8 primary colors means it registers 72 individual blocks (comparable to registering 2 or 3 new blocks with full moreblocks support), then each individual block has 8 options for secondary colors)**
* **Added new effects system with shape-specific explosion sounds and finale effects.**
* **Added dye-based secondary color selection through shapeless crafting.**
* **Enhanced node registration with customizable tiles and overlay textures.** 
* **Improved entity handling and particle system architecture for better performance and maintainability. Namely. Greatly utilizing Luatic's new packet batch for particles as well as yl_whosit's baseline for the burst firework**
