-- CC Ore Automation - Utility Library
-- Common functions used across the ore automation system

local utils = {}

-- Find peripheral by type
function utils.findPeripheral(peripheralType)
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        if peripheral.getType(name) == peripheralType then
            return peripheral.wrap(name), name
        end
    end
    return nil, nil
end

-- Find all peripherals of a type
function utils.findAllPeripherals(peripheralType)
    local found = {}
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        if peripheral.getType(name) == peripheralType then
            table.insert(found, {
                peripheral = peripheral.wrap(name),
                name = name
            })
        end
    end
    return found
end

-- Check if inventory has item
function utils.hasItem(inventory, itemName)
    for slot = 1, inventory.size() do
        local item = inventory.getItemDetail(slot)
        if item and item.name == itemName then
            return true, slot, item.count
        end
    end
    return false, nil, 0
end

-- Count items in inventory
function utils.countItem(inventory, itemName)
    local total = 0
    for slot = 1, inventory.size() do
        local item = inventory.getItemDetail(slot)
        if item and item.name == itemName then
            total = total + item.count
        end
    end
    return total
end

-- Transfer items between inventories
function utils.transferItem(fromInv, toInv, itemName, amount)
    local transferred = 0
    for slot = 1, fromInv.size() do
        local item = fromInv.getItemDetail(slot)
        if item and item.name == itemName then
            local toTransfer = math.min(item.count, amount - transferred)
            local moved = fromInv.pushItems(peripheral.getName(toInv), slot, toTransfer)
            transferred = transferred + moved
            if transferred >= amount then
                break
            end
        end
    end
    return transferred
end

-- Check for key press (non-blocking)
function utils.checkKeyPress()
    local timer = os.startTimer(0.05)
    while true do
        local event, param = os.pullEvent()
        if event == "key" then
            return true, param
        elseif event == "timer" and param == timer then
            return false, nil
        end
    end
end

-- Log message with timestamp
function utils.log(message, level)
    level = level or "INFO"
    local time = textutils.formatTime(os.time(), true)
    print("[" .. time .. "] [" .. level .. "] " .. message)
end

-- Wait for item in inventory
function utils.waitForItem(inventory, itemName, timeout)
    local startTime = os.clock()
    while true do
        local hasIt, slot, count = utils.hasItem(inventory, itemName)
        if hasIt then
            return true, slot, count
        end
        if timeout and (os.clock() - startTime) > timeout then
            return false, nil, 0
        end
        sleep(0.5)
    end
end

-- Get empty slot in inventory
function utils.getEmptySlot(inventory)
    for slot = 1, inventory.size() do
        local item = inventory.getItemDetail(slot)
        if not item then
            return slot
        end
    end
    return nil
end

-- Check if inventory is full
function utils.isInventoryFull(inventory)
    return utils.getEmptySlot(inventory) == nil
end

-- String starts with
function utils.startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- String ends with
function utils.endsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

-- Split string by delimiter
function utils.split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Table contains value
function utils.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Deep copy table
function utils.deepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in next, original, nil do
            copy[utils.deepCopy(key)] = utils.deepCopy(value)
        end
        setmetatable(copy, utils.deepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

return utils
