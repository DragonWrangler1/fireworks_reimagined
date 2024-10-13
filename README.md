This is the guide to the FIREWORKS REIMAGINED api

This guide is here to help you registering your new fireworks.

### FIREWORK SHAPES
* fireworks_reimagined.register_firework_shape(shape_name, description) 
```
register_firework_shape: allows you to add a new shape name to the list. By doing this. You can define a function for your mod, that acts depending on the shape name.
```

#### EXAMPLE USAGE
* **fireworks_reimagined.register_firework_shape** can be used for an item in your mod that randomly shoots Different fireworks based on shape for example. _square_ shoots square(ish) fireworks. While _sphere_ shoots spherical fireworks. When registering an item to do that, you can call both the default function: **fireworks_reimagined.spawn_firework_explosion** and your **custom_function** and depending on the results of the picked shape. You will get different fireworks.



### FIREWORK NORMAL EXPLOSIONS
* fireworks_reimagined.spawn_firework_explosion(pos, shape, double, color_def, color_def_2, alpha)
```
spawn_firework_explosion: allows you to spawn various different types of firework explosions based on shape. double. color_def. And color_def_2.
```

* **shape** controls the shape of the firework that occurs.
* **double** controls whether or not the firework "explodes" twice making a more epic effect.
* **color_def** When defined the fireworks will be this color. If **color_def_2** is defined then the fireworks will mix the two.
If this is not defined. Then a random color will be picked.
* **color_def_2** depends on **color_def** if color_def is not defined then it will pick a random color.
* **alpha** if defined then it will set the alpha to the specified value. Otherwise it defaults to 128.



* **fireworks_reimagined.spawn_firework_explosion** is used to spawn normal firework explosions. This can result in some impressive firework displays.



### FIREWORK IMAGE EXPLOSIONS
* fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers)
```
register_firework_explosion: allows you to take an image, and turn it into a lua table, which will then be displayed as fireworks when exploding.
```

* **delay** This is the delay at which the "image" starts to fall apart. For example the full creeper image is visible for 0.2 seconds. Then it starts falling apart.
Any value greater than 1 is discouraged as the entire explosion is only visible for up to 2.5 seconds.
* **color_grid** This is the lua table that makes the image it is reversed from the actual image. So when getting the colors you will need either need to do one of the following:
#1
Manually get each color out of the image from gimp.
#2
Run _image.py_ giving it the image name and output file. This will almost completely automate the process, and you shouldn't need to swap the Y vector of the image.
You merely have to open the output file. Copy the subtables, and insert them into your main lua table.

with **color_grid** You can make just about any image into fireworks as long as it's small enough (I recommend not getting bigger than 32x32, the bigger the image, the less precise the fireworks are.) and as long as you have the image.

* **depth_layers** This value can be as large as you want as long as it's within reason. This will allow you to create a more 3d image through the fireworks.

```
When viewing these. If not symetrical. You must look North ingame (+Z) otherwise it'll be reverse.
```

#### EXAMPLE USAGE
see file **2025.lua** or **creeper.lua**



### FIREWORK BLOCKS
* fireworks_reimagined.register_firework_node(shape, entity, delay)
```
register_firework_node: allows you to register blocks that shoot off fireworks after being right-clicked or activated with mesecons. They have a three second cooldown for player usage and two second for mesecon usage. To avoid player abuse.
```

* **shape** anything from a defined list(determines the naming and description, but also in some occasions the shape of the firework spawned.)
* **entity** this is the name of the firework entity to spawn (more on this later) if **nil** then the default will spawn.
* **delay** this is the delay at which the firework will be shot off at. This is here so that if the shooter is a normal player shooting off an image, they have a chance at seeing the firework.

#### EXAMPLE USAGE
see any of the lua files.



### FIREWORK ENTITY
* fireworks_reimagined.register_firework_entity(name, def)
```
register_firework_entity: allows you to register custom firework entities to be shot off by firework_nodes that will have custom effects.
```

```
Here's how they would be defined:
```
**fireworks_reimagined.register_firework_entity("fireworks_reimagined:test_3_firework_entity", {**
   **firework_shape = "chaotic",**
   **firework_explosion = function(pos, shape)**
       **fireworks_reimagined.spawn_firework_explosion(pos, "chaotic", false, "#FF0000", nil, "255")**
   **end**
**})**
