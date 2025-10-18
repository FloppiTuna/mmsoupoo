-- Overwatch announcement system.

local map = require("../data/overwatch/map")
local aukit = require("../libs/aukit")

local function playClip(name)
    -- fetch path from map
    local clipPath = "data/overwatch/" .. map.clips[name]

    -- play with cc.audio.dfpwm
    local file = fs.open(clipPath, "rb")
    if not file then
        error("Clip file not found: " .. clipPath)
    end
    local data = file.readAll()
    file.close()

    local iterator, length = aukit.stream.dfpwm(data)
    aukit.play(iterator, function() end, 0.5, peripheral.find("speaker")) -- Play at 50% volume

end


local function init(common)
    local logger = common.createLogger("overwatch")
    local clipPath = "data/overwatch"
    
    -- Make sure all defined files exist, warn if any do not
    for key, file in pairs(map.clips) do
        if not fs.exists(clipPath .. "/" .. file) then
            logger.warn("Overwatch definition file not found: " .. file)
        end
    end

    -- Now, let's test aliases.
    for alias, target in pairs(map.aliases) do
        if not map.clips[target] then
            logger.warn("Overwatch alias '" .. alias .. "' points to undefined clip key '" .. target .. "'.")
        end
    end

    logger.log("Total defined clips: " .. tostring(#map.clips) .. ".")
    logger.log("Total defined aliases: " .. tostring(#map.aliases) .. ".")

    -- Test: play every single clip once
    for key, _ in pairs(map.clips) do
        logger.log("Playing clip: " .. key)
        playClip(key)
    end
end

return init