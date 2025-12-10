14 months of coding mess led me to seek Ai assistance in the new V6 update. Here is a comprehensive list of everything that did and didn't have ai involvement, and why. Should you have any issues with understanding the code or with any bugs please visit my [Github Issues Page](https://github.com/DragonWrangler1/fireworks_reimagined/issues)

api/particles.lua:

 - **local function get_eligible_players:**
 
 * This function was a rather last minute one, I realized that <5.14 players and servers would have problems performantly running the fireworks. I wrote this function, but like many, it turned out to be a mess of code duplication. I utilized ChatGPT to organize this. The end LOC remained the same, but code output was cleaner. 4 LOC were removed by ChatGPT with a few other pieces modified.

 - **local function get_particle_variations:**
 
 * Written by me, minorly based on code from yl_whosit.
 
 - **local function spawn_colored_particle**
 
 * Written by me.
 
 - **fireworks_reimagined.spawn_firework_explosion**
 
 * Written by me initially, with a Lot of if/then statements, organized by Gemini Which leads us to:
 
api/shapes.lua:

 - **local function all**

 * Was written by me as a bunch of if/then statements, Gemini organized this into modular functions.
 
api/registration.lua:

 - **local function get_nearest_activation_time**
 
 * Couldn't get a working version. Written by ChatGPT.
 
 - **local function launch_firework**
 
 * Written by me.
 
 - **fireworks_reimagined.register_firework_explosion**
 
 * Written by me.
 
 - **fireworks_reimagined.register_firework_node**
 
 * Mix of myself, Gemini, and ChatGPT
 
 - **fireworks_reimagined.register_firework_entity**
 
 * Written by me, some inspiration from niwla23's code
 
effects/explosions.lua:

 * Written by me.
 
utilities dir:

 * Written by me.
 
colored.lua:

 * Written by me initially, updated by ChatGPT and Gemini a bit when updating register_firework_node function
 
images.lua:

 * Written by me.
 
init.lua:

 * Written by me.

misc.lua:

 * Written by me.
 
 
Code cleanup still has yet to be completed so please, don't be too judgemental ;)
