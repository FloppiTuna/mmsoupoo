local aukit = require "aukit"

print(require("data/splash"))

-- Load the peripheral map (periph.map).
local periphMap

if fs.exists("mmsoupoo/periph.map") then
    local mapFile = fs.open("mmsoupoo/periph.map", "r")
    local mapContent = mapFile.readAll()

    -- Parse the file as JSON.
    local map = textutils.unserializeJSON(mapContent)
    if map then
        periphMap = map
    else
        error("Failed to parse peripheral map. It may be corrupt. Manually inspect it for erroneous characters, or use \"pwiz.lua\".")
    end

    mapFile.close()
else 
    error("Peripheral map not found. Run \"pwiz.lua\".")
end

-- Validate the peripheral map by checking that every defined peripheral is actually connected.
for name, periph in pairs(periphMap) do
    if not peripheral.isPresent(name) then
        error("Peripheral '" .. name .. "' is defined in the map but not connected.")
    end
end

local function createLogger(moduleName)
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
end

-- Build the common object. This contains information and functions that will be shared across modules.
local common = {
    periphMap = periphMap,
    createLogger = createLogger,
}

local rootLogger = common.createLogger("mmsoupoo")


function common:signalAmbience(signalData)
    common.ambienceSignal = signalData
end

-- Load and run modules in parallel
local modules = {
    -- "modules/franky",
    "modules/ambience",
    "modules/remote",
    "modules/overwatch"
}

local moduleRunners = {}
for _, modulePath in ipairs(modules) do
    local module = require(modulePath)
    if type(module) == "function" then
        table.insert(moduleRunners, function()
            local moduleCommon = {}
            for k, v in pairs(common) do moduleCommon[k] = v end
            local success, err = pcall(module, moduleCommon)
            if success then
                rootLogger.warn("Module " .. modulePath .. " has exited. If this is intended, ensure it is classified as a Oneshot.")
            else 
                error("Failed to run module '" .. modulePath .. "': " .. err)
            end
        end)
    else
        error("Module '" .. modulePath .. "' does not export a function.")
    end
end

parallel.waitForAll(table.unpack(moduleRunners))
