-- CC Ore Automation - Create Mod Ore Processor
-- Handles crushing, washing, and processing of ores using Create mod

local utils = require("lib.utils")
local config = require("config.ores")

local processor = {}

-- Create mod ore processing chains
-- Crushing: Ore -> Crushed Ore (bonus chance for extra)
-- Washing: Crushed Ore -> Nuggets + bonus items
local processingChains = {
    -- Iron processing chain
    iron = {
        input = {"minecraft:raw_iron", "minecraft:iron_ore", "minecraft:deepslate_iron_ore"},
        crushed = "create:crushed_raw_iron",
        washed = "minecraft:iron_nugget",
        bonus = "minecraft:flint"
    },
    -- Gold processing chain
    gold = {
        input = {"minecraft:raw_gold", "minecraft:gold_ore", "minecraft:deepslate_gold_ore", "minecraft:nether_gold_ore"},
        crushed = "create:crushed_raw_gold",
        washed = "minecraft:gold_nugget",
        bonus = "minecraft:quartz"
    },
    -- Copper processing chain
    copper = {
        input = {"minecraft:raw_copper", "minecraft:copper_ore", "minecraft:deepslate_copper_ore"},
        crushed = "create:crushed_raw_copper",
        washed = "create:copper_nugget",
        bonus = "minecraft:clay_ball"
    },
    -- Zinc processing chain
    zinc = {
        input = {"create:raw_zinc", "create:zinc_ore", "create:deepslate_zinc_ore"},
        crushed = "create:crushed_raw_zinc",
        washed = "create:zinc_nugget",
        bonus = nil
    },
    -- Gravel washing
    gravel = {
        input = {"minecraft:gravel"},
        washed = "minecraft:flint",
        bonus = "minecraft:iron_nugget"
    },
    -- Sand washing (soul sand)
    soul_sand = {
        input = {"minecraft:soul_sand"},
        washed = "minecraft:quartz",
        bonus = "minecraft:gold_nugget"
    },
}

-- Find Create mod peripherals
local function findCrushingWheel()
    -- Create crushing wheels are usually controlled via depot/belt
    return utils.findPeripheral("create:depot")
end

local function findMechanicalPress()
    return utils.findPeripheral("create:mechanical_press")
end

local function findBasin()
    return utils.findPeripheral("create:basin")
end

local function findDepots()
    return utils.findAllPeripherals("create:depot")
end

local function findFunnels()
    return utils.findAllPeripherals("create:brass_funnel")
end

-- Check if item is processable by Create
local function getProcessingChain(itemName)
    for chainName, chain in pairs(processingChains) do
        if chain.input then
            for _, input in ipairs(chain.input) do
                if input == itemName then
                    return chainName, chain
                end
            end
        end
    end
    return nil, nil
end

-- Process ores using Create mod machinery
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

    -- Find depots for processing
    local depots = findDepots()
    if #depots == 0 then
        utils.log("No Create depots found!", "WARN")
        return false
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

    -- Process items from input chest
    for slot = 1, inputChest.size() do
        local item = inputChest.getItemDetail(slot)
        if item then
            local chainName, chain = getProcessingChain(item.name)

            if chainName then
                -- Find available depot
                for _, depot in ipairs(depots) do
                    local depotItem = depot.peripheral.getItemDetail(1)

                    -- If depot is empty, push item for processing
                    if not depotItem then
                        local moved = inputChest.pushItems(depot.name, slot, 1)
                        if moved > 0 then
                            utils.log("Sent " .. item.name .. " to depot for " .. chainName .. " processing")
                            break
                        end
                    end
                end
            else
                -- Move non-processable items to output
                if outputChest then
                    inputChest.pushItems(peripheral.getName(outputChest), slot)
                end
            end
        end
    end

    -- Collect processed items from depots
    for _, depot in ipairs(depots) do
        local depotItem = depot.peripheral.getItemDetail(1)
        if depotItem then
            -- Check if this is a processed result
            local isResult = false
            for _, chain in pairs(processingChains) do
                if chain.crushed == depotItem.name or
                   chain.washed == depotItem.name or
                   chain.bonus == depotItem.name then
                    isResult = true
                    break
                end
            end

            -- Move results to output
            if isResult and outputChest then
                depot.peripheral.pushItems(peripheral.getName(outputChest), 1)
                utils.log("Collected " .. depotItem.count .. " " .. depotItem.name)
            end
        end
    end

    return true
end

-- Get status of Create processing
function processor.status()
    local depots = findDepots()
    local basin = findBasin()

    return {
        depotCount = #depots,
        hasBasin = basin ~= nil,
        type = "create"
    }
end

-- Get all processable ore types
function processor.getProcessableOres()
    local ores = {}
    for chainName, chain in pairs(processingChains) do
        if chain.input then
            for _, input in ipairs(chain.input) do
                table.insert(ores, {
                    name = input,
                    chain = chainName,
                    result = chain.crushed or chain.washed
                })
            end
        end
    end
    return ores
end

return processor
