local modpath = core.get_modpath("fireworks_reimagined")

fireworks_reimagined = {}

dofile(modpath .. "/utilities/colors.lua")
dofile(modpath .. "/utilities/particles.lua")
dofile(modpath .. "/effects/explosions.lua")
dofile(modpath .. "/api/particles.lua")
dofile(modpath .. "/api/shapes.lua")
dofile(modpath .. "/api/mcl_formspec.lua")
dofile(modpath .. "/api/registration.lua")
dofile(modpath .. "/misc.lua")

dofile(modpath .. "/colored.lua")
dofile(modpath .. "/images.lua")

minetest.register_alias("fireworks_reimagined:firework_2025", "fireworks_reimagined:firework_year")
