-- CC Ore Automation - Main Program
-- Automates vanilla and Create mod ore processing

local lib = require("lib.utils")
local config = require("config.ores")

-- Program state
local running = true
local currentMode = "auto"  -- auto, vanilla, create
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
    cprint("    CC Ore Automation v" .. version, colors.cyan)
    cprint("================================", colors.cyan)
    print("")

    -- Show update notification if available
    if updateAvailable then
        cprint("  UPDATE AVAILABLE: v" .. latestVersion, colors.yellow)
        cprint("  Press [U] to update", colors.yellow)
        print("")
    end
end

-- Display menu
local function displayMenu()
    print("Commands:")
    print("  [1] Start Auto Processing")
    print("  [2] Vanilla Ores Only")
    print("  [3] Create Ores Only")
    print("  [4] View Status")
    print("  [5] Configure")
    if updateAvailable then
        cprint("  [U] Update Now", colors.yellow)
    else
        print("  [U] Check for Updates")
    end
    print("  [Q] Quit")
    print("")
    write("Select option: ")
end

-- Process vanilla ores
local function processVanilla()
    local vanilla = require("vanilla.processor")
    return vanilla.process()
end

-- Process Create mod ores
local function processCreate()
    local create = require("create.processor")
    return create.process()
end

-- Auto processing loop
local function autoProcess()
    print("Starting auto processing...")
    print("Press any key to stop")

    local localRunning = true

    while localRunning do
        -- Check for redstone signal to pause
        if redstone.getInput("back") then
            print("Paused by redstone signal")
            sleep(1)
        else
            -- Process ores based on mode
            if currentMode == "auto" or currentMode == "vanilla" then
                processVanilla()
            end

            if currentMode == "auto" or currentMode == "create" then
                processCreate()
            end

            sleep(config.settings.processInterval or 1)
        end

        -- Check for key press to stop
        if lib.checkKeyPress() then
            localRunning = false
        end
    end
end

-- View current status
local function viewStatus()
    term.clear()
    term.setCursorPos(1, 1)
    cprint("=== System Status ===", colors.cyan)
    print("")

    print("Version: " .. getVersion())
    print("Mode: " .. currentMode)

    if updateAvailable then
        cprint("Update: v" .. latestVersion .. " available", colors.yellow)
    else
        cprint("Update: Up to date", colors.lime)
    end

    print("")

    -- Check peripherals
    cprint("Peripherals:", colors.cyan)
    local peripherals = peripheral.getNames()
    if #peripherals == 0 then
        print("  (none detected)")
    else
        for _, name in ipairs(peripherals) do
            local pType = peripheral.getType(name)
            print("  - " .. name .. " (" .. pType .. ")")
        end
    end

    print("")
    print("Press any key to continue...")
    os.pullEvent("key")
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
            cprint("You're already on the latest version!", colors.lime)
            print("Current: v" .. localVer)
        end

        sleep(2)
    end
end

-- Main program loop
local function main()
    -- Check for updates on startup (silent)
    parallel.waitForAny(
        function()
            pcall(checkUpdateAsync)
        end,
        function()
            sleep(3)  -- Timeout after 3 seconds
        end
    )

    displayBanner()

    while running do
        displayMenu()

        local event, key = os.pullEvent("key")

        if key == keys.one then
            currentMode = "auto"
            autoProcess()
            displayBanner()
        elseif key == keys.two then
            currentMode = "vanilla"
            autoProcess()
            displayBanner()
        elseif key == keys.three then
            currentMode = "create"
            autoProcess()
            displayBanner()
        elseif key == keys.four then
            viewStatus()
            displayBanner()
        elseif key == keys.five then
            print("\nConfiguration not yet implemented")
            sleep(1)
            displayBanner()
        elseif key == keys.u then
            runUpdate()
            displayBanner()
        elseif key == keys.q then
            running = false
            print("\nGoodbye!")
        end
    end
end

-- Run main program
main()
