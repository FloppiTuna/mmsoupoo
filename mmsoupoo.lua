-- Add working directory to global
_G.WORKING_DIR = "/" .. fs.getDir(shell.getRunningProgram())
print("Working directory set to: " .. _G.WORKING_DIR)

-- make common object yay
local common = {
    periphMap = {},
    createLogger = function(moduleName)
        return {
            debug = function(message)
                term.setTextColor(colors.gray)
                print("[" .. moduleName .. "] dbg: " .. message)
                term.setTextColor(colors.white)
            end,
            log = function(message)
                print("[" .. moduleName .. "] info: " .. message)
            end,
            warn = function(message)
                term.setTextColor(colors.yellow)
                print("[" .. moduleName .. "] warning: " .. message)
                term.setTextColor(colors.white)
            end,
            error = function(message)
                term.setTextColor(colors.red)
                print("[" .. moduleName .. "] ERROR: " .. message)
                term.setTextColor(colors.white)
            end
        }
    end,
}
local rootLogger = common.createLogger("mmsoupoo")

print(require(_G.WORKING_DIR .. "/data/splash"))
rootLogger.log("MMSoUPoO -- Micro Managing Supervisor of Universal Provisioning of Operations")
rootLogger.log("Running out of directory: " .. _G.WORKING_DIR)

-- Load the peripheral map (periph.map).
rootLogger.log("Loading peripheral map...")
if fs.exists(_G.WORKING_DIR .. "/data/periph.map") then
    local mapFile = fs.open(_G.WORKING_DIR .. "/data/periph.map", "r")
    local mapContent = mapFile.readAll()

    -- Parse the file as JSON.
    local map = textutils.unserializeJSON(mapContent)
    if map then
        rootLogger.log("Peripheral map loaded successfully.")
        common.periphMap = map
    else
        error(
        "Failed to parse peripheral map. It may be corrupt. Manually inspect it for erroneous characters, or use \"pwiz.lua\".")
    end

    mapFile.close()
else
    error("Peripheral map not found. Run \"pwiz.lua\".")
end

-- Validate the peripheral map by checking that every defined peripheral is actually connected.
for name in pairs(common.periphMap) do
    if not peripheral.isPresent(name) then
        rootLogger.warn("Peripheral '" .. name .. "' defined in peripheral map but not connected. Check your connections or run the Peripheral Wizard.")
    end
end

-- Load and run modules in parallel
local modules = {
    -- "modules/franky",
    "modules/overwatch",
    "modules/clock",
    "modules/ambience",
    "modules/remote",
    "modules/chat",
    "modules/me"
}

rootLogger.log("Modules to load: " .. textutils.serialize(modules))

local moduleRunners = {}
for _, modulePath in ipairs(modules) do
    local module = require(_G.WORKING_DIR .. "/" .. modulePath)
    if type(module) == "function" then
        table.insert(moduleRunners, function()
            local moduleCommon = {}
            for k, v in pairs(common) do moduleCommon[k] = v end
            local success, err = pcall(module, moduleCommon)
            if success then
                rootLogger.warn("Module " ..
                modulePath .. " has exited. If this is intended, ensure it is classified as a Oneshot.")
            else
                error("Failed to run module '" .. modulePath .. "': " .. err)
            end
        end)
    else
        error("Module '" .. modulePath .. "' does not export a function.")
    end
end

parallel.waitForAll(table.unpack(moduleRunners))
