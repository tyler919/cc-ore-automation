-- CC Ore Automation - Configuration
-- Deepslate Ore Processing Chain

local config = {}

-- General settings
config.settings = {
    -- Time between processing cycles (seconds)
    processInterval = 1,

    -- Maximum items before stopping (10 stacks)
    maxItems = 640,

    -- Molten metal per ingot (mB)
    mbPerIngot = 45,

    -- Logging level: DEBUG, INFO, WARN, ERROR
    logLevel = "INFO",

    -- Redstone sides for control
    redstoneOutput = {
        mudMaker = "left",      -- Controls dirt/water input
        crusher = "right",      -- Controls crushing wheels
        smelter = "back",       -- Controls furnaces
        melter = "top",         -- Controls heated mixer
    },
}

-- Processing Chain Steps
-- Step 1: Mud Making
config.mudMaking = {
    input = {
        dirt = "minecraft:dirt",
        water = 200,  -- mB of water needed
    },
    output = "minecraft:mud",
    machine = "basin_mixer",  -- Basin with Mechanical Mixer
}

-- Step 2: Packed Mud (crafting)
config.packedMud = {
    input = {
        mud = "minecraft:mud",
        wheat = "minecraft:wheat",
    },
    output = "minecraft:packed_mud",
    machine = "crafter",  -- Mechanical Crafter or manual
}

-- Step 3: Crushing Packed Mud
config.crushPackedMud = {
    input = "minecraft:packed_mud",
    outputs = {
        {item = "minecraft:cobbled_deepslate", chance = 100},
        {item = "create:deepslate_chunk", chance = 100},
        {item = "create:deepslate_chunk", chance = 50},  -- Bonus
    },
    machine = "crushing_wheel",
}

-- Step 4: Smelting Cobbled Deepslate
config.smeltDeepslate = {
    input = "minecraft:cobbled_deepslate",
    output = "minecraft:deepslate",
    machine = "furnace",  -- Any furnace type
}

-- Step 5: Compacting Deepslate Chunks
config.compactChunks = {
    input = "create:deepslate_chunk",
    inputCount = 4,
    output = "minecraft:cobbled_deepslate",
    machine = "basin_press",  -- Basin with Mechanical Press
}

-- Step 6: Crushing Deepslate -> Raw Ores
config.crushDeepslate = {
    input = "minecraft:deepslate",
    outputs = {
        {item = "create:raw_iron_chunk", chance = 30},
        {item = "create:raw_copper_chunk", chance = 25},
        {item = "create:raw_zinc_chunk", chance = 20},
        {item = "create:raw_gold_chunk", chance = 15},
        {item = "create:experience_nugget", chance = 5},
    },
    machine = "crushing_wheel",
}

-- Step 7: Melting Raw Ores
config.melting = {
    mbPerOre = 5,  -- Each raw ore chunk produces 5mB
    machine = "heated_mixer",  -- Heated Basin with Mixer
    ores = {
        {
            input = "create:raw_iron_chunk",
            output = "create:molten_iron",
        },
        {
            input = "create:raw_copper_chunk",
            output = "create:molten_copper",
        },
        {
            input = "create:raw_zinc_chunk",
            output = "create:molten_zinc",
        },
        {
            input = "create:raw_gold_chunk",
            output = "create:molten_gold",
        },
    },
}

-- Step 8: Brass Alloying
config.brassAlloying = {
    inputs = {
        {fluid = "create:molten_copper", amount = 2},
        {fluid = "create:molten_zinc", amount = 1},
    },
    output = {fluid = "create:molten_brass", amount = 3},
    machine = "heated_mixer",
}

-- Step 9: Casting Ingots
config.casting = {
    mbPerIngot = 45,
    machine = "basin_press",  -- Basin with Mechanical Press
    metals = {
        {
            fluid = "create:molten_iron",
            ingot = "minecraft:iron_ingot",
        },
        {
            fluid = "create:molten_copper",
            ingot = "minecraft:copper_ingot",
        },
        {
            fluid = "create:molten_zinc",
            ingot = "create:zinc_ingot",
        },
        {
            fluid = "create:molten_gold",
            ingot = "minecraft:gold_ingot",
        },
        {
            fluid = "create:molten_brass",
            ingot = "create:brass_ingot",
        },
    },
}

-- Storage limits (stop when reaching this amount)
config.storageLimits = {
    ["minecraft:iron_ingot"] = 640,
    ["minecraft:copper_ingot"] = 640,
    ["create:zinc_ingot"] = 640,
    ["minecraft:gold_ingot"] = 640,
    ["create:brass_ingot"] = 640,
    ["create:experience_nugget"] = 640,
}

-- Peripheral names (nil = auto-detect)
config.peripherals = {
    inputChest = nil,
    outputChest = nil,
    fluidTanks = {},
}

return config
