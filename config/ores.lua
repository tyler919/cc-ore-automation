-- CC Ore Automation - Ore Configuration
-- Define ores, processing methods, and settings

local config = {}

-- General settings
config.settings = {
    -- Time between processing cycles (seconds)
    processInterval = 1,

    -- Enable/disable ore types
    enableVanilla = true,
    enableCreate = true,

    -- Logging
    logLevel = "INFO",  -- DEBUG, INFO, WARN, ERROR

    -- Redstone control
    redstoneSide = "back",  -- Side to check for redstone signal
    redstoneInverted = false,  -- If true, redstone ON = paused
}

-- Vanilla ore definitions
config.vanillaOres = {
    -- Overworld ores
    {
        name = "minecraft:iron_ore",
        displayName = "Iron Ore",
        result = "minecraft:iron_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:deepslate_iron_ore",
        displayName = "Deepslate Iron Ore",
        result = "minecraft:iron_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:gold_ore",
        displayName = "Gold Ore",
        result = "minecraft:gold_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:deepslate_gold_ore",
        displayName = "Deepslate Gold Ore",
        result = "minecraft:gold_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:copper_ore",
        displayName = "Copper Ore",
        result = "minecraft:copper_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:deepslate_copper_ore",
        displayName = "Deepslate Copper Ore",
        result = "minecraft:copper_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:coal_ore",
        displayName = "Coal Ore",
        result = "minecraft:coal",
        method = "drop",
        fortuneMultiplier = 1.5
    },
    {
        name = "minecraft:diamond_ore",
        displayName = "Diamond Ore",
        result = "minecraft:diamond",
        method = "drop",
        fortuneMultiplier = 1.5
    },
    {
        name = "minecraft:emerald_ore",
        displayName = "Emerald Ore",
        result = "minecraft:emerald",
        method = "drop",
        fortuneMultiplier = 1.5
    },
    {
        name = "minecraft:lapis_ore",
        displayName = "Lapis Lazuli Ore",
        result = "minecraft:lapis_lazuli",
        method = "drop",
        fortuneMultiplier = 2.0
    },
    {
        name = "minecraft:redstone_ore",
        displayName = "Redstone Ore",
        result = "minecraft:redstone",
        method = "drop",
        fortuneMultiplier = 2.0
    },
    -- Nether ores
    {
        name = "minecraft:nether_gold_ore",
        displayName = "Nether Gold Ore",
        result = "minecraft:gold_nugget",
        method = "drop",
        fortuneMultiplier = 1.5
    },
    {
        name = "minecraft:nether_quartz_ore",
        displayName = "Nether Quartz Ore",
        result = "minecraft:quartz",
        method = "drop",
        fortuneMultiplier = 1.5
    },
    {
        name = "minecraft:ancient_debris",
        displayName = "Ancient Debris",
        result = "minecraft:netherite_scrap",
        method = "smelt",
        fuelCost = 2
    },
    -- Raw ores (from silk touch or mining)
    {
        name = "minecraft:raw_iron",
        displayName = "Raw Iron",
        result = "minecraft:iron_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:raw_gold",
        displayName = "Raw Gold",
        result = "minecraft:gold_ingot",
        method = "smelt",
        fuelCost = 1
    },
    {
        name = "minecraft:raw_copper",
        displayName = "Raw Copper",
        result = "minecraft:copper_ingot",
        method = "smelt",
        fuelCost = 1
    },
}

-- Create mod ore definitions
config.createOres = {
    -- Zinc
    {
        name = "create:zinc_ore",
        displayName = "Zinc Ore",
        crushed = "create:crushed_raw_zinc",
        ingot = "create:zinc_ingot",
        method = "crush_smelt"
    },
    {
        name = "create:deepslate_zinc_ore",
        displayName = "Deepslate Zinc Ore",
        crushed = "create:crushed_raw_zinc",
        ingot = "create:zinc_ingot",
        method = "crush_smelt"
    },
    {
        name = "create:raw_zinc",
        displayName = "Raw Zinc",
        crushed = "create:crushed_raw_zinc",
        ingot = "create:zinc_ingot",
        method = "crush_smelt"
    },
    -- Crushed ores for washing
    {
        name = "create:crushed_raw_iron",
        displayName = "Crushed Raw Iron",
        washed = {"minecraft:iron_nugget", 10},
        bonus = {"minecraft:flint", 0.5},
        method = "wash"
    },
    {
        name = "create:crushed_raw_gold",
        displayName = "Crushed Raw Gold",
        washed = {"minecraft:gold_nugget", 18},
        bonus = {"minecraft:quartz", 0.5},
        method = "wash"
    },
    {
        name = "create:crushed_raw_copper",
        displayName = "Crushed Raw Copper",
        washed = {"create:copper_nugget", 10},
        bonus = {"minecraft:clay_ball", 0.5},
        method = "wash"
    },
    {
        name = "create:crushed_raw_zinc",
        displayName = "Crushed Raw Zinc",
        washed = {"create:zinc_nugget", 10},
        method = "wash"
    },
}

-- Fuel priorities for smelting
config.fuels = {
    {name = "minecraft:coal", burnTime = 8},
    {name = "minecraft:charcoal", burnTime = 8},
    {name = "minecraft:coal_block", burnTime = 80},
    {name = "minecraft:lava_bucket", burnTime = 100},
    {name = "minecraft:blaze_rod", burnTime = 12},
}

-- Peripheral names (can be customized)
config.peripherals = {
    inputChest = nil,  -- Auto-detect if nil
    outputChest = nil,  -- Auto-detect if nil
    furnaces = {},  -- Auto-detect if empty
    depots = {},  -- Auto-detect if empty
}

return config
