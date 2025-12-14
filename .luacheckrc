std = "lua51"

globals = {
    "fireworks_reimagined"
}

read_globals = {
    -- engine
    "core",
    "vector",
    "ItemStack",
    "dump",
    "VoxelArea",
    -- engine adds addition fields, we need to override the defaults
    "string",
    "table",

    -- mods
    "mesecon",
    "mcl_formspec",
}

ignore = {
    "212", -- unused argument
    "213", -- unused loop var
    "611", -- line contains only whitespace
    "612", -- line contains trailing whitespace
    "631", -- line too long

}