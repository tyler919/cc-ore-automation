-- CC Ore Automation Installer
-- Run: wget run https://raw.githubusercontent.com/tyler919/cc-ore-automation/main/install.lua

local REPO_BASE = "https://raw.githubusercontent.com/tyler919/cc-ore-automation/main/"

-- Files to download
local files = {
    -- Core files
    {remote = "version.txt", local_path = "version.txt"},
    {remote = "src/main.lua", local_path = "main.lua"},
    {remote = "src/update.lua", local_path = "update.lua"},

    -- Libraries
    {remote = "src/lib/utils.lua", local_path = "lib/utils.lua"},

    -- Processors
    {remote = "src/vanilla/processor.lua", local_path = "vanilla/processor.lua"},
    {remote = "src/create/processor.lua", local_path = "create/processor.lua"},

    -- Config
    {remote = "config/ores.lua", local_path = "config/ores.lua"},
}

-- Colors for terminal
local function setColor(color)
    if term.isColor() then
        term.setTextColor(color)
    end
end

-- Print with color
local function cprint(text, color)
    setColor(color or colors.white)
    print(text)
    setColor(colors.white)
end

-- Clear screen and show banner
local function showBanner()
    term.clear()
    term.setCursorPos(1, 1)
    cprint("================================", colors.cyan)
    cprint("  CC Ore Automation Installer", colors.cyan)
    cprint("================================", colors.cyan)
    print("")
end

-- Create directory if it doesn't exist
local function ensureDir(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
end

-- Download a file
local function downloadFile(url, path)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()

        -- Ensure parent directory exists
        local dir = fs.getDir(path)
        if dir ~= "" then
            ensureDir(dir)
        end

        -- Write file
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
        return true
    end
    return false
end

-- Main installation
local function install()
    showBanner()

    -- Check for existing installation
    if fs.exists("version.txt") then
        cprint("Existing installation detected!", colors.yellow)
        print("This will overwrite your current installation.")
        print("Config files will be preserved.")
        print("")
        write("Continue? (y/n): ")
        local input = read()
        if input:lower() ~= "y" then
            cprint("Installation cancelled.", colors.red)
            return
        end
        print("")
    end

    cprint("Installing CC Ore Automation...", colors.lime)
    print("")

    local success = 0
    local failed = 0

    for _, file in ipairs(files) do
        -- Skip config if it exists (preserve user settings)
        if file.local_path == "config/ores.lua" and fs.exists("config/ores.lua") then
            write("[SKIP] " .. file.local_path)
            cprint(" (preserving config)", colors.yellow)
        else
            write("[....] " .. file.local_path)

            local url = REPO_BASE .. file.remote
            if downloadFile(url, file.local_path) then
                term.setCursorPos(2, select(2, term.getCursorPos()))
                cprint(" OK ", colors.lime)
                success = success + 1
            else
                term.setCursorPos(2, select(2, term.getCursorPos()))
                cprint("FAIL", colors.red)
                failed = failed + 1
            end
        end
    end

    print("")
    cprint("================================", colors.cyan)

    if failed == 0 then
        cprint("Installation complete!", colors.lime)
        print("")
        print("Files installed: " .. success)
        print("")
        cprint("To start, run: main", colors.yellow)
        cprint("To update later: update", colors.yellow)
    else
        cprint("Installation completed with errors!", colors.orange)
        print("")
        print("Successful: " .. success)
        print("Failed: " .. failed)
        print("")
        cprint("Try running the installer again.", colors.yellow)
    end

    print("")
end

-- Run installer
install()
