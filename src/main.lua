-- CC Ore Automation - Main Program
-- Deepslate Ore Processing System
-- Dirt -> Mud -> Packed Mud -> Deepslate -> Ores -> Ingots

local lib = require("lib.utils")
local config = require("config.ores")

-- Program state
local running = true
local processing = false
local updateAvailable = false
local latestVersion = nil

-- Colors
local function setColor(color)
    if term.isColor() then
        term.setTextColor(color)
    end
end

local function cprint(text, color)
    setColor(color or colors.white)
    print(text)
    setColor(colors.white)
end

local function cwrite(text, color)
    setColor(color or colors.white)
    write(text)
    setColor(colors.white)
end

-- Get current version
local function getVersion()
    if fs.exists("version.txt") then
        local file = fs.open("version.txt", "r")
        local version = file.readAll():gsub("%s+", "")
        file.close()
        return version
    end
    return "1.0.0"
end

-- Check for updates in background
local function checkUpdateAsync()
    local updater = require("update")
    local hasUpdate, localVer, remoteVer, err = updater.checkForUpdate()
    if hasUpdate then
        updateAvailable = true
        latestVersion = remoteVer
    end
end

-- Display banner
local function displayBanner()
    term.clear()
    term.setCursorPos(1, 1)

    local version = getVersion()

    cprint("================================", colors.cyan)
    cprint("  CC Ore Automation v" .. version, colors.cyan)
    cprint("  Deepslate Processing System", colors.lightGray)
    cprint("================================", colors.cyan)
    print("")

    if updateAvailable then
        cprint("  UPDATE: v" .. latestVersion .. " [U]", colors.yellow)
        print("")
    end
end

-- Display main menu
local function displayMenu()
    print("Commands:")
    print("  [1] Start Processing")
    print("  [2] Stop Processing")
    print("  [3] View Status")
    print("  [4] View Inventory")
    print("  [U] Check for Updates")
    print("  [Q] Quit")
    print("")
    write("Select option: ")
end

-- Format number with commas
local function formatNumber(n)
    local formatted = tostring(n)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Display a progress bar
local function progressBar(current, max, width)
    width = width or 20
    local percent = math.min(current / max, 1)
    local filled = math.floor(percent * width)
    local empty = width - filled

    local bar = "[" .. string.rep("=", filled) .. string.rep(" ", empty) .. "]"
    return bar
end

-- View inventory status
local function viewInventory()
    term.clear()
    term.setCursorPos(1, 1)
    cprint("=== Inventory Status ===", colors.cyan)
    print("")

    local processor = require("create.processor")
    processor.refresh()
    local counts = processor.getCounts()
    local fluids = processor.getFluids()
    local maxItems = config.settings.maxItems

    cprint("Ingots:", colors.yellow)
    print("")

    -- Iron
    local ironColor = counts.iron >= maxItems and colors.red or colors.white
    cwrite("  Iron:   ", colors.lightGray)
    cwrite(progressBar(counts.iron, maxItems, 15) .. " ", ironColor)
    cprint(formatNumber(counts.iron) .. "/" .. formatNumber(maxItems), ironColor)

    -- Copper
    local copperColor = counts.copper >= maxItems and colors.red or colors.orange
    cwrite("  Copper: ", colors.lightGray)
    cwrite(progressBar(counts.copper, maxItems, 15) .. " ", copperColor)
    cprint(formatNumber(counts.copper) .. "/" .. formatNumber(maxItems), copperColor)

    -- Zinc
    local zincColor = counts.zinc >= maxItems and colors.red or colors.lightBlue
    cwrite("  Zinc:   ", colors.lightGray)
    cwrite(progressBar(counts.zinc, maxItems, 15) .. " ", zincColor)
    cprint(formatNumber(counts.zinc) .. "/" .. formatNumber(maxItems), zincColor)

    -- Gold
    local goldColor = counts.gold >= maxItems and colors.red or colors.yellow
    cwrite("  Gold:   ", colors.lightGray)
    cwrite(progressBar(counts.gold, maxItems, 15) .. " ", goldColor)
    cprint(formatNumber(counts.gold) .. "/" .. formatNumber(maxItems), goldColor)

    -- Brass
    local brassColor = counts.brass >= maxItems and colors.red or colors.yellow
    cwrite("  Brass:  ", colors.lightGray)
    cwrite(progressBar(counts.brass, maxItems, 15) .. " ", brassColor)
    cprint(formatNumber(counts.brass) .. "/" .. formatNumber(maxItems), brassColor)

    print("")
    cprint("Other:", colors.yellow)
    print("")

    -- XP Nuggets
    local xpColor = counts.xp >= maxItems and colors.red or colors.lime
    cwrite("  XP:     ", colors.lightGray)
    cwrite(progressBar(counts.xp, maxItems, 15) .. " ", xpColor)
    cprint(formatNumber(counts.xp) .. "/" .. formatNumber(maxItems), xpColor)

    print("")
    cprint("Molten Metals (mB):", colors.yellow)
    print("")

    cwrite("  Iron:   ", colors.lightGray)
    cprint(formatNumber(fluids.molten_iron) .. " mB", colors.white)

    cwrite("  Copper: ", colors.lightGray)
    cprint(formatNumber(fluids.molten_copper) .. " mB", colors.orange)

    cwrite("  Zinc:   ", colors.lightGray)
    cprint(formatNumber(fluids.molten_zinc) .. " mB", colors.lightBlue)

    cwrite("  Gold:   ", colors.lightGray)
    cprint(formatNumber(fluids.molten_gold) .. " mB", colors.yellow)

    cwrite("  Brass:  ", colors.lightGray)
    cprint(formatNumber(fluids.molten_brass) .. " mB", colors.yellow)

    print("")
    print("Press any key to continue...")
    os.pullEvent("key")
end

-- View system status
local function viewStatus()
    term.clear()
    term.setCursorPos(1, 1)
    cprint("=== System Status ===", colors.cyan)
    print("")

    local processor = require("create.processor")
    local status = processor.getStatus()

    -- Processing status
    cwrite("Processing: ", colors.lightGray)
    if status.running then
        cprint("RUNNING", colors.lime)
    else
        cprint("STOPPED", colors.red)
    end

    print("")

    -- Paused lines
    cprint("Storage Limits:", colors.yellow)
    local anyPaused = false
    for metal, isPaused in pairs(status.paused) do
        if isPaused then
            cprint("  " .. metal:upper() .. " at limit!", colors.red)
            anyPaused = true
        end
    end
    if not anyPaused then
        cprint("  All within limits", colors.lime)
    end

    print("")

    -- Peripherals
    cprint("Peripherals:", colors.yellow)
    local peripherals = peripheral.getNames()
    if #peripherals == 0 then
        cprint("  (none detected)", colors.gray)
    else
        for _, name in ipairs(peripherals) do
            local pType = peripheral.getType(name)
            print("  " .. name .. " (" .. pType .. ")")
        end
    end

    print("")

    -- Redstone outputs
    cprint("Redstone Outputs:", colors.yellow)
    local outputs = config.settings.redstoneOutput
    for name, side in pairs(outputs) do
        local state = redstone.getOutput(side)
        cwrite("  " .. name .. " (" .. side .. "): ", colors.lightGray)
        if state then
            cprint("ON", colors.lime)
        else
            cprint("OFF", colors.red)
        end
    end

    print("")
    print("Press any key to continue...")
    os.pullEvent("key")
end

-- Processing loop
local function processLoop()
    local processor = require("create.processor")

    displayBanner()
    cprint("Processing started!", colors.lime)
    cprint("Press any key to stop...", colors.yellow)
    print("")

    processing = true
    processor.start()

    while processing do
        -- Process
        local ok = processor.process()

        -- Get status for display
        local status = processor.getStatus()
        local counts = status.counts

        -- Update display
        term.setCursorPos(1, 8)
        term.clearLine()

        if ok then
            cwrite("Status: ", colors.lightGray)
            cprint("Running", colors.lime)
        else
            cwrite("Status: ", colors.lightGray)
            cprint("Paused (storage full)", colors.yellow)
        end

        term.clearLine()
        cwrite("Iron: " .. counts.iron, colors.white)
        cwrite(" | Copper: " .. counts.copper, colors.orange)
        cwrite(" | Zinc: " .. counts.zinc, colors.lightBlue)
        print("")

        term.clearLine()
        cwrite("Gold: " .. counts.gold, colors.yellow)
        cwrite(" | Brass: " .. counts.brass, colors.yellow)
        cwrite(" | XP: " .. counts.xp, colors.lime)
        print("")

        -- Check for key press
        local timer = os.startTimer(config.settings.processInterval or 1)
        while true do
            local event, param = os.pullEvent()
            if event == "key" then
                processing = false
                break
            elseif event == "timer" and param == timer then
                break
            end
        end
    end

    processor.stop()
    cprint("\nProcessing stopped.", colors.yellow)
    sleep(1)
end

-- Run update
local function runUpdate()
    if updateAvailable then
        shell.run("update")
    else
        term.clear()
        term.setCursorPos(1, 1)
        cprint("Checking for updates...", colors.yellow)
        print("")

        local updater = require("update")
        local hasUpdate, localVer, remoteVer, err = updater.checkForUpdate()

        if err then
            cprint("Error: " .. err, colors.red)
        elseif hasUpdate then
            updateAvailable = true
            latestVersion = remoteVer
            cprint("Update available: v" .. remoteVer, colors.yellow)
            print("")
            write("Install now? (y/n): ")
            local input = read()
            if input:lower() == "y" then
                shell.run("update")
            end
        else
            cprint("You're on the latest version!", colors.lime)
            print("Current: v" .. localVer)
        end

        sleep(2)
    end
end

-- Main program loop
local function main()
    -- Initialize processor and discover peripherals
    term.clear()
    term.setCursorPos(1, 1)
    cprint("================================", colors.cyan)
    cprint("  CC Ore Automation", colors.cyan)
    cprint("================================", colors.cyan)
    print("")

    local processor = require("create.processor")
    local ok = processor.init()

    if not ok then
        cprint("WARNING: No storage found!", colors.red)
        cprint("Connect a storage drawer controller", colors.yellow)
        cprint("or chest via wired modem.", colors.yellow)
        print("")
    end

    print("Press any key to continue...")
    os.pullEvent("key")

    -- Check for updates on startup (silent, with timeout)
    parallel.waitForAny(
        function()
            pcall(checkUpdateAsync)
        end,
        function()
            sleep(3)
        end
    )

    displayBanner()

    while running do
        displayMenu()

        local event, key = os.pullEvent("key")

        if key == keys.one then
            processLoop()
            displayBanner()
        elseif key == keys.two then
            local processor = require("create.processor")
            processor.stop()
            cprint("\nProcessing stopped.", colors.yellow)
            sleep(1)
            displayBanner()
        elseif key == keys.three then
            viewStatus()
            displayBanner()
        elseif key == keys.four then
            viewInventory()
            displayBanner()
        elseif key == keys.u then
            runUpdate()
            displayBanner()
        elseif key == keys.q then
            local processor = require("create.processor")
            processor.stop()
            running = false
            print("\nGoodbye!")
        end
    end
end

-- Run main program
main()
