-- CC Ore Automation - Deepslate Ore Processor
-- Automates the complete ore processing chain:
-- Dirt + Water -> Mud -> Packed Mud -> Crush -> Deepslate -> Raw Ores -> Molten -> Ingots

local utils = require("lib.utils")
local config = require("config.ores")

local processor = {}

-- Current inventory counts
local inventoryCounts = {
    iron = 0,
    copper = 0,
    zinc = 0,
    gold = 0,
    brass = 0,
    xp = 0,
}

-- Fluid levels (mB)
local fluidLevels = {
    molten_iron = 0,
    molten_copper = 0,
    molten_zinc = 0,
    molten_gold = 0,
    molten_brass = 0,
}

-- Status flags
local status = {
    running = false,
    paused = {},  -- Which lines are paused due to storage limits
    lastUpdate = 0,
}

-- Find all inventories
local function findInventories()
    local inventories = {}
    local types = {"minecraft:chest", "minecraft:barrel", "create:depot", "minecraft:hopper"}

    for _, invType in ipairs(types) do
        local found = utils.findAllPeripherals(invType)
        for _, inv in ipairs(found) do
            table.insert(inventories, inv)
        end
    end

    return inventories
end

-- Find fluid tanks
local function findTanks()
    local tanks = {}
    local found = utils.findAllPeripherals("create:fluid_tank")
    for _, tank in ipairs(found) do
        table.insert(tanks, tank)
    end
    return tanks
end

-- Count items across all inventories
local function countAllItems(itemName)
    local total = 0
    local inventories = findInventories()

    for _, inv in ipairs(inventories) do
        local count = utils.countItem(inv.peripheral, itemName)
        total = total + count
    end

    return total
end

-- Get fluid amount from tanks
local function getFluidAmount(fluidName)
    local total = 0
    local tanks = findTanks()

    for _, tank in ipairs(tanks) do
        -- Try to get tank info
        if tank.peripheral.tanks then
            local tankInfo = tank.peripheral.tanks()
            for _, fluid in ipairs(tankInfo) do
                if fluid.name == fluidName then
                    total = total + fluid.amount
                end
            end
        end
    end

    return total
end

-- Update all inventory counts
local function updateCounts()
    inventoryCounts.iron = countAllItems("minecraft:iron_ingot")
    inventoryCounts.copper = countAllItems("minecraft:copper_ingot")
    inventoryCounts.zinc = countAllItems("create:zinc_ingot")
    inventoryCounts.gold = countAllItems("minecraft:gold_ingot")
    inventoryCounts.brass = countAllItems("create:brass_ingot")
    inventoryCounts.xp = countAllItems("create:experience_nugget")

    fluidLevels.molten_iron = getFluidAmount("create:molten_iron")
    fluidLevels.molten_copper = getFluidAmount("create:molten_copper")
    fluidLevels.molten_zinc = getFluidAmount("create:molten_zinc")
    fluidLevels.molten_gold = getFluidAmount("create:molten_gold")
    fluidLevels.molten_brass = getFluidAmount("create:molten_brass")

    status.lastUpdate = os.clock()
end

-- Check if any storage is at limit
local function checkStorageLimits()
    local maxItems = config.settings.maxItems
    local paused = {}

    if inventoryCounts.iron >= maxItems then
        paused.iron = true
    end
    if inventoryCounts.copper >= maxItems then
        paused.copper = true
    end
    if inventoryCounts.zinc >= maxItems then
        paused.zinc = true
    end
    if inventoryCounts.gold >= maxItems then
        paused.gold = true
    end
    if inventoryCounts.brass >= maxItems then
        paused.brass = true
    end
    if inventoryCounts.xp >= maxItems then
        paused.xp = true
    end

    status.paused = paused
    return paused
end

-- Check if system should be running (any storage not full)
local function shouldRun()
    local paused = checkStorageLimits()

    -- If ALL storages are full, stop completely
    if paused.iron and paused.copper and paused.zinc and paused.gold and paused.brass then
        return false
    end

    return true
end

-- Set redstone output for a section
local function setRedstone(section, state)
    local sides = config.settings.redstoneOutput
    if sides[section] then
        redstone.setOutput(sides[section], state)
    end
end

-- Control the processing line
local function controlProcessing()
    local paused = status.paused

    -- If everything is at limit, stop the whole system
    if not shouldRun() then
        setRedstone("mudMaker", false)
        setRedstone("crusher", false)
        setRedstone("smelter", false)
        setRedstone("melter", false)
        return false
    end

    -- Otherwise, keep running
    setRedstone("mudMaker", true)
    setRedstone("crusher", true)
    setRedstone("smelter", true)
    setRedstone("melter", true)

    return true
end

-- Main processing function
function processor.process()
    -- Update inventory counts
    updateCounts()

    -- Check storage limits
    checkStorageLimits()

    -- Control machines based on storage
    local running = controlProcessing()
    status.running = running

    return running
end

-- Get current status
function processor.getStatus()
    updateCounts()
    checkStorageLimits()

    return {
        running = status.running,
        paused = status.paused,
        counts = inventoryCounts,
        fluids = fluidLevels,
        maxItems = config.settings.maxItems,
    }
end

-- Get inventory counts
function processor.getCounts()
    return inventoryCounts
end

-- Get fluid levels
function processor.getFluids()
    return fluidLevels
end

-- Check if specific metal is at limit
function processor.isAtLimit(metal)
    return inventoryCounts[metal] >= config.settings.maxItems
end

-- Force update counts
function processor.refresh()
    updateCounts()
    checkStorageLimits()
end

-- Stop all processing
function processor.stop()
    setRedstone("mudMaker", false)
    setRedstone("crusher", false)
    setRedstone("smelter", false)
    setRedstone("melter", false)
    status.running = false
end

-- Start all processing
function processor.start()
    if shouldRun() then
        setRedstone("mudMaker", true)
        setRedstone("crusher", true)
        setRedstone("smelter", true)
        setRedstone("melter", true)
        status.running = true
        return true
    end
    return false
end

return processor
