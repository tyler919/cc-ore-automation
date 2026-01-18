-- CC Ore Automation - Vanilla Ore Processor
-- Handles smelting and processing of vanilla Minecraft ores

local utils = require("lib.utils")
local config = require("config.ores")

local processor = {}

-- Ore to ingot/result mappings
local oreResults = {
    ["minecraft:iron_ore"] = "minecraft:iron_ingot",
    ["minecraft:deepslate_iron_ore"] = "minecraft:iron_ingot",
    ["minecraft:gold_ore"] = "minecraft:gold_ingot",
    ["minecraft:deepslate_gold_ore"] = "minecraft:gold_ingot",
    ["minecraft:copper_ore"] = "minecraft:copper_ingot",
    ["minecraft:deepslate_copper_ore"] = "minecraft:copper_ingot",
    ["minecraft:coal_ore"] = "minecraft:coal",
    ["minecraft:deepslate_coal_ore"] = "minecraft:coal",
    ["minecraft:diamond_ore"] = "minecraft:diamond",
    ["minecraft:deepslate_diamond_ore"] = "minecraft:diamond",
    ["minecraft:emerald_ore"] = "minecraft:emerald",
    ["minecraft:deepslate_emerald_ore"] = "minecraft:emerald",
    ["minecraft:lapis_ore"] = "minecraft:lapis_lazuli",
    ["minecraft:deepslate_lapis_ore"] = "minecraft:lapis_lazuli",
    ["minecraft:redstone_ore"] = "minecraft:redstone",
    ["minecraft:deepslate_redstone_ore"] = "minecraft:redstone",
    ["minecraft:nether_gold_ore"] = "minecraft:gold_ingot",
    ["minecraft:nether_quartz_ore"] = "minecraft:quartz",
    ["minecraft:ancient_debris"] = "minecraft:netherite_scrap",
    -- Raw ores
    ["minecraft:raw_iron"] = "minecraft:iron_ingot",
    ["minecraft:raw_gold"] = "minecraft:gold_ingot",
    ["minecraft:raw_copper"] = "minecraft:copper_ingot",
}

-- Ores that need smelting
local smeltableOres = {
    "minecraft:iron_ore",
    "minecraft:deepslate_iron_ore",
    "minecraft:gold_ore",
    "minecraft:deepslate_gold_ore",
    "minecraft:copper_ore",
    "minecraft:deepslate_copper_ore",
    "minecraft:ancient_debris",
    "minecraft:raw_iron",
    "minecraft:raw_gold",
    "minecraft:raw_copper",
    "minecraft:nether_gold_ore",
}

-- Ores that just need fortune/silk touch (drop items directly)
local fortuneOres = {
    "minecraft:coal_ore",
    "minecraft:deepslate_coal_ore",
    "minecraft:diamond_ore",
    "minecraft:deepslate_diamond_ore",
    "minecraft:emerald_ore",
    "minecraft:deepslate_emerald_ore",
    "minecraft:lapis_ore",
    "minecraft:deepslate_lapis_ore",
    "minecraft:redstone_ore",
    "minecraft:deepslate_redstone_ore",
    "minecraft:nether_quartz_ore",
}

-- Find furnaces
local function findFurnaces()
    local furnaces = {}
    local types = {"minecraft:furnace", "minecraft:blast_furnace", "minecraft:smoker"}

    for _, furnaceType in ipairs(types) do
        local found = utils.findAllPeripherals(furnaceType)
        for _, f in ipairs(found) do
            table.insert(furnaces, f)
        end
    end

    return furnaces
end

-- Check if item is a smeltable ore
local function isSmeltableOre(itemName)
    return utils.contains(smeltableOres, itemName)
end

-- Process ores in input chest
function processor.process()
    -- Find input chest
    local inputChest, inputName = utils.findPeripheral("minecraft:chest")
    if not inputChest then
        inputChest, inputName = utils.findPeripheral("minecraft:barrel")
    end

    if not inputChest then
        utils.log("No input chest found!", "ERROR")
        return false
    end

    -- Find furnaces
    local furnaces = findFurnaces()
    if #furnaces == 0 then
        utils.log("No furnaces found!", "WARN")
    end

    -- Find output chest (second chest)
    local allChests = utils.findAllPeripherals("minecraft:chest")
    local outputChest = nil
    for _, chest in ipairs(allChests) do
        if chest.name ~= inputName then
            outputChest = chest.peripheral
            break
        end
    end

    -- Process each item in input
    for slot = 1, inputChest.size() do
        local item = inputChest.getItemDetail(slot)
        if item then
            local itemName = item.name

            -- Check if it's a smeltable ore
            if isSmeltableOre(itemName) then
                -- Find available furnace
                for _, furnace in ipairs(furnaces) do
                    local fuelSlot = furnace.peripheral.getItemDetail(2)
                    local inputSlot = furnace.peripheral.getItemDetail(1)

                    -- Check if furnace has fuel and input slot is empty or same item
                    if fuelSlot and (not inputSlot or inputSlot.name == itemName) then
                        local moved = inputChest.pushItems(furnace.name, slot, item.count, 1)
                        if moved > 0 then
                            utils.log("Moved " .. moved .. " " .. itemName .. " to furnace")
                            break
                        end
                    end
                end
            else
                -- Move non-ore items to output
                if outputChest then
                    inputChest.pushItems(peripheral.getName(outputChest), slot)
                end
            end
        end
    end

    -- Collect smelted items from furnaces
    for _, furnace in ipairs(furnaces) do
        local outputSlot = furnace.peripheral.getItemDetail(3)
        if outputSlot and outputChest then
            furnace.peripheral.pushItems(peripheral.getName(outputChest), 3)
            utils.log("Collected " .. outputSlot.count .. " " .. outputSlot.name)
        end
    end

    return true
end

-- Get status
function processor.status()
    local furnaces = findFurnaces()
    return {
        furnaceCount = #furnaces,
        type = "vanilla"
    }
end

return processor
