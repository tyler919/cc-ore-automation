-- CC Ore Automation - Deepslate Ore Processor
-- Controls item and fluid movement through the processing chain

local utils = require("lib.utils")
local config = require("config.ores")

local processor = {}

-- Peripheral references (discovered at runtime)
local peripherals = {
    storage = nil,       -- Storage drawers controller or main chest
    waterTank = nil,     -- Water source tank
    basins = {},         -- All basins (for mixing/pressing)
    tanks = {},          -- All fluid tanks
    furnaces = {},       -- Furnaces for smelting
}

-- Item name mappings
local items = {
    dirt = "minecraft:dirt",
    water = "minecraft:water",
    mud = "minecraft:mud",
    wheat = "minecraft:wheat",
    packed_mud = "minecraft:packed_mud",
    cobbled_deepslate = "minecraft:cobbled_deepslate",
    deepslate = "minecraft:deepslate",
    deepslate_chunk = "create:deepslate_chunk",
    raw_iron = "create:raw_iron_chunk",
    raw_copper = "create:raw_copper_chunk",
    raw_zinc = "create:raw_zinc_chunk",
    raw_gold = "create:raw_gold_chunk",
    xp_nugget = "create:experience_nugget",
    iron_ingot = "minecraft:iron_ingot",
    copper_ingot = "minecraft:copper_ingot",
    zinc_ingot = "create:zinc_ingot",
    gold_ingot = "minecraft:gold_ingot",
    brass_ingot = "create:brass_ingot",
}

-- Fluid name mappings
local fluids = {
    water = "minecraft:water",
    molten_iron = "create:molten_iron",
    molten_copper = "create:molten_copper",
    molten_zinc = "create:molten_zinc",
    molten_gold = "create:molten_gold",
    molten_brass = "create:molten_brass",
}

-- Status tracking
local status = {
    running = false,
    lastError = nil,
    counts = {},
}

-- Discover and map all peripherals
function processor.discoverPeripherals()
    peripherals.basins = {}
    peripherals.tanks = {}
    peripherals.furnaces = {}
    peripherals.storage = nil
    peripherals.waterTank = nil

    local names = peripheral.getNames()

    for _, name in ipairs(names) do
        local types = {peripheral.getType(name)}
        local typesStr = table.concat(types, ", ")

        -- Check for storage drawers controller
        for _, t in ipairs(types) do
            if t == "storagedrawers:controller" or t:find("drawer") then
                peripherals.storage = peripheral.wrap(name)
                print("Found storage: " .. name .. " (" .. typesStr .. ")")
                break
            end
        end

        -- Check for inventory (chest/barrel) as fallback storage
        if not peripherals.storage then
            for _, t in ipairs(types) do
                if t == "inventory" and (name:find("chest") or name:find("barrel")) then
                    peripherals.storage = peripheral.wrap(name)
                    print("Found storage: " .. name .. " (" .. typesStr .. ")")
                    break
                end
            end
        end

        -- Check for basins
        if name:find("basin") then
            table.insert(peripherals.basins, {
                name = name,
                peripheral = peripheral.wrap(name)
            })
            print("Found basin: " .. name .. " (" .. typesStr .. ")")
        end

        -- Check for fluid tanks
        if name:find("fluidTank") or name:find("fluid_tank") or name:find("tank") then
            local tank = peripheral.wrap(name)
            table.insert(peripherals.tanks, {
                name = name,
                peripheral = tank
            })
            print("Found tank: " .. name .. " (" .. typesStr .. ")")

            -- Check if it has water
            if tank.tanks then
                local tankInfo = tank.tanks()
                if tankInfo and tankInfo[1] then
                    print("  Contains: " .. tankInfo[1].name .. " (" .. tankInfo[1].amount .. "mB)")
                    if tankInfo[1].name == fluids.water then
                        peripherals.waterTank = tank
                    end
                end
            end
        end

        -- Check for furnaces
        if name:find("furnace") or name:find("blast_furnace") then
            table.insert(peripherals.furnaces, {
                name = name,
                peripheral = peripheral.wrap(name)
            })
            print("Found furnace: " .. name)
        end
    end

    -- Fallback: use first tank as water if not specifically found
    if not peripherals.waterTank and #peripherals.tanks > 0 then
        peripherals.waterTank = peripherals.tanks[1].peripheral
    end

    return peripherals
end

-- Get item count from storage
function processor.getItemCount(itemName)
    if not peripherals.storage then return 0 end

    local count = 0
    local list = peripherals.storage.list()

    for slot, item in pairs(list) do
        if item.name == itemName then
            count = count + item.count
        end
    end

    return count
end

-- Get fluid amount from a tank
function processor.getFluidAmount(tank, fluidName)
    if not tank or not tank.tanks then return 0 end

    local tankInfo = tank.tanks()
    if not tankInfo then return 0 end

    for _, fluid in ipairs(tankInfo) do
        if fluid.name == fluidName then
            return fluid.amount
        end
    end

    return 0
end

-- Push items from storage to a target peripheral
function processor.pushItem(targetName, itemName, count)
    if not peripherals.storage then
        return 0, "No storage connected"
    end

    count = count or 1
    local pushed = 0
    local list = peripherals.storage.list()

    for slot, item in pairs(list) do
        if item.name == itemName then
            local toPush = math.min(item.count, count - pushed)
            local result = peripherals.storage.pushItems(targetName, slot, toPush)
            pushed = pushed + result
            if pushed >= count then break end
        end
    end

    return pushed
end

-- Pull items from a peripheral to storage
function processor.pullItem(sourceName, itemName, count)
    if not peripherals.storage then
        return 0, "No storage connected"
    end

    count = count or 64
    local source = peripheral.wrap(sourceName)
    if not source or not source.list then
        return 0, "Invalid source"
    end

    local pulled = 0
    local list = source.list()

    for slot, item in pairs(list) do
        if itemName == nil or item.name == itemName then
            local toPull = math.min(item.count, count - pulled)
            local result = source.pushItems(peripheral.getName(peripherals.storage), slot, toPull)
            pulled = pulled + result
            if pulled >= count then break end
        end
    end

    return pulled
end

-- Check what's in a basin
function processor.getBasinContents(basin)
    local contents = {
        items = {},
        fluids = {}
    }

    if basin.list then
        contents.items = basin.list()
    end

    if basin.tanks then
        contents.fluids = basin.tanks()
    end

    return contents
end

-- Step 1: Make mud (dirt + water in basin with mixer)
function processor.makeMud()
    if #peripherals.basins == 0 then
        return false, "No basin connected"
    end

    local basin = peripherals.basins[1]
    local basinName = basin.name
    local basinPeriph = basin.peripheral

    -- Check if basin already has mud
    local contents = processor.getBasinContents(basinPeriph)
    for _, item in pairs(contents.items) do
        if item.name == items.mud then
            -- Pull mud to storage
            local pulled = processor.pullItem(basinName, items.mud, 64)
            if pulled > 0 then
                print("Collected " .. pulled .. " mud")
            end
            return true
        end
    end

    -- Check basin for dirt
    local hasDirt = false
    for _, item in pairs(contents.items) do
        if item.name == items.dirt then
            hasDirt = true
            break
        end
    end

    -- Push dirt if needed
    if not hasDirt then
        local dirtCount = processor.getItemCount(items.dirt)
        if dirtCount > 0 then
            local pushed = processor.pushItem(basinName, items.dirt, 1)
            if pushed > 0 then
                print("Pushed dirt to basin")
            end
        else
            return false, "No dirt in storage"
        end
    end

    -- Check water level in basin
    local waterInBasin = 0
    for _, fluid in ipairs(contents.fluids or {}) do
        if fluid.name == fluids.water then
            waterInBasin = fluid.amount
        end
    end

    if waterInBasin < 200 then
        print("Basin needs water (has " .. waterInBasin .. "mB, needs 200mB)")
        -- Water needs to be piped in via Create pipes/pumps
        -- The computer can't directly move fluids
    end

    return true
end

-- Update all inventory counts
function processor.updateCounts()
    status.counts = {
        dirt = processor.getItemCount(items.dirt),
        wheat = processor.getItemCount(items.wheat),
        mud = processor.getItemCount(items.mud),
        packed_mud = processor.getItemCount(items.packed_mud),
        cobbled_deepslate = processor.getItemCount(items.cobbled_deepslate),
        deepslate = processor.getItemCount(items.deepslate),
        deepslate_chunk = processor.getItemCount(items.deepslate_chunk),
        iron = processor.getItemCount(items.iron_ingot),
        copper = processor.getItemCount(items.copper_ingot),
        zinc = processor.getItemCount(items.zinc_ingot),
        gold = processor.getItemCount(items.gold_ingot),
        brass = processor.getItemCount(items.brass_ingot),
        xp = processor.getItemCount(items.xp_nugget),
    }
    return status.counts
end

-- Main process loop iteration
function processor.process()
    -- Update counts first
    processor.updateCounts()

    -- Check storage limits
    local maxItems = config.settings.maxItems
    local atLimit = status.counts.iron >= maxItems and
                    status.counts.copper >= maxItems and
                    status.counts.zinc >= maxItems and
                    status.counts.gold >= maxItems and
                    status.counts.brass >= maxItems

    if atLimit then
        status.running = false
        return false, "All storage at limit"
    end

    -- Step 1: Make mud
    local ok, err = processor.makeMud()
    if not ok and err then
        status.lastError = err
    end

    -- Collect any finished items from basins
    for _, basin in ipairs(peripherals.basins) do
        processor.pullItem(basin.name, nil, 64)
    end

    status.running = true
    return true
end

-- Get current status
function processor.getStatus()
    return {
        running = status.running,
        lastError = status.lastError,
        counts = status.counts,
        peripherals = {
            hasStorage = peripherals.storage ~= nil,
            hasWaterTank = peripherals.waterTank ~= nil,
            basinCount = #peripherals.basins,
            tankCount = #peripherals.tanks,
            furnaceCount = #peripherals.furnaces,
        }
    }
end

-- Get counts
function processor.getCounts()
    return status.counts
end

-- Initialize
function processor.init()
    print("Discovering peripherals...")
    processor.discoverPeripherals()
    print("")
    print("Storage: " .. (peripherals.storage and "Connected" or "NOT FOUND"))
    print("Water Tank: " .. (peripherals.waterTank and "Connected" or "NOT FOUND"))
    print("Basins: " .. #peripherals.basins)
    print("Tanks: " .. #peripherals.tanks)
    print("Furnaces: " .. #peripherals.furnaces)
    print("")

    processor.updateCounts()
    return peripherals.storage ~= nil
end

-- Stop processing
function processor.stop()
    status.running = false
end

-- Start processing
function processor.start()
    status.running = true
    return true
end

return processor
