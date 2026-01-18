-- CC Ore Automation - Main Program
-- Automates vanilla and Create mod ore processing

local lib = require("lib.utils")
local config = require("config.ores")

-- Program state
local running = true
local currentMode = "auto"  -- auto, vanilla, create

-- Display banner
local function displayBanner()
    term.clear()
    term.setCursorPos(1, 1)
    print("================================")
    print("    CC Ore Automation v1.0")
    print("================================")
    print("")
end

-- Display menu
local function displayMenu()
    print("Commands:")
    print("  [1] Start Auto Processing")
    print("  [2] Vanilla Ores Only")
    print("  [3] Create Ores Only")
    print("  [4] View Status")
    print("  [5] Configure")
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

    while running do
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
            running = false
        end
    end
end

-- View current status
local function viewStatus()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== System Status ===")
    print("")
    print("Mode: " .. currentMode)
    print("Running: " .. tostring(running))
    print("")

    -- Check peripherals
    print("Peripherals:")
    local peripherals = peripheral.getNames()
    for _, name in ipairs(peripherals) do
        local pType = peripheral.getType(name)
        print("  - " .. name .. " (" .. pType .. ")")
    end

    print("")
    print("Press any key to continue...")
    os.pullEvent("key")
end

-- Main program loop
local function main()
    displayBanner()

    while running do
        displayMenu()

        local event, key = os.pullEvent("key")

        if key == keys.one then
            currentMode = "auto"
            autoProcess()
        elseif key == keys.two then
            currentMode = "vanilla"
            autoProcess()
        elseif key == keys.three then
            currentMode = "create"
            autoProcess()
        elseif key == keys.four then
            viewStatus()
            displayBanner()
        elseif key == keys.five then
            print("\nConfiguration not yet implemented")
            sleep(1)
            displayBanner()
        elseif key == keys.q then
            running = false
            print("\nGoodbye!")
        end
    end
end

-- Run main program
main()
