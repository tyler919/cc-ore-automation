-- CC Ore Automation - Update Manager
-- Check for updates and apply them

local REPO_BASE = "https://raw.githubusercontent.com/tyler919/cc-ore-automation/main/"

-- Files to update (same as installer, minus config)
local files = {
    {remote = "version.txt", local_path = "version.txt"},
    {remote = "src/main.lua", local_path = "main.lua"},
    {remote = "src/update.lua", local_path = "update.lua"},
    {remote = "src/lib/utils.lua", local_path = "lib/utils.lua"},
    {remote = "src/create/processor.lua", local_path = "create/processor.lua"},
}

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

-- Get local version
local function getLocalVersion()
    if fs.exists("version.txt") then
        local file = fs.open("version.txt", "r")
        local version = file.readAll():gsub("%s+", "")
        file.close()
        return version
    end
    return "0.0.0"
end

-- Get remote version
local function getRemoteVersion()
    local response = http.get(REPO_BASE .. "version.txt")
    if response then
        local version = response.readAll():gsub("%s+", "")
        response.close()
        return version
    end
    return nil
end

-- Compare versions (returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal)
local function compareVersions(v1, v2)
    local function parseVersion(v)
        local parts = {}
        for num in v:gmatch("(%d+)") do
            table.insert(parts, tonumber(num))
        end
        return parts
    end

    local p1 = parseVersion(v1)
    local p2 = parseVersion(v2)

    for i = 1, math.max(#p1, #p2) do
        local n1 = p1[i] or 0
        local n2 = p2[i] or 0
        if n1 > n2 then return 1 end
        if n1 < n2 then return -1 end
    end
    return 0
end

-- Check for updates (can be called from other programs)
function checkForUpdate()
    local local_ver = getLocalVersion()
    local remote_ver = getRemoteVersion()

    if not remote_ver then
        return false, nil, nil, "Could not connect to update server"
    end

    local hasUpdate = compareVersions(remote_ver, local_ver) > 0
    return hasUpdate, local_ver, remote_ver, nil
end

-- Ensure directory exists
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

        local dir = fs.getDir(path)
        if dir ~= "" then
            ensureDir(dir)
        end

        local file = fs.open(path, "w")
        file.write(content)
        file.close()
        return true
    end
    return false
end

-- Apply update
local function applyUpdate()
    cprint("Downloading updates...", colors.lime)
    print("")

    local success = 0
    local failed = 0

    for _, file in ipairs(files) do
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

    print("")
    return failed == 0, success, failed
end

-- Main update check
local function main()
    term.clear()
    term.setCursorPos(1, 1)
    cprint("================================", colors.cyan)
    cprint("  CC Ore Automation Updater", colors.cyan)
    cprint("================================", colors.cyan)
    print("")

    cprint("Checking for updates...", colors.yellow)
    print("")

    local hasUpdate, localVer, remoteVer, err = checkForUpdate()

    if err then
        cprint("Error: " .. err, colors.red)
        return
    end

    print("Current version: " .. localVer)
    print("Latest version:  " .. remoteVer)
    print("")

    if not hasUpdate then
        cprint("You're up to date!", colors.lime)
        return
    end

    cprint("Update available!", colors.yellow)
    print("")
    write("Download and install update? (y/n): ")
    local input = read()

    if input:lower() ~= "y" then
        cprint("Update cancelled.", colors.red)
        return
    end

    print("")
    local ok, success, failed = applyUpdate()

    cprint("================================", colors.cyan)

    if ok then
        cprint("Update complete!", colors.lime)
        print("")
        print("Updated " .. success .. " files")
        print("New version: " .. remoteVer)
        print("")
        cprint("Please restart the program.", colors.yellow)
    else
        cprint("Update completed with errors!", colors.orange)
        print("")
        print("Successful: " .. success)
        print("Failed: " .. failed)
    end
end

-- If run directly, execute main
if not ... then
    main()
end

-- Export functions for use by other programs
return {
    checkForUpdate = checkForUpdate,
    getLocalVersion = getLocalVersion,
    getRemoteVersion = getRemoteVersion,
    applyUpdate = applyUpdate
}
