-- Overwatch announcement system.

local map = require(_G.WORKING_DIR .. "/data/overwatch/map")
local aukit = require(_G.WORKING_DIR .. "/libs/aukit")

local function playClip(name)
    -- fetch path from map
    local clipPath = _G.WORKING_DIR .. "/data/overwatch/" .. map.clips[name]
    -- play with cc.audio.dfpwm using a reader function so AUKit streams from
    -- the file handle (this prevents issues caused by passing a single
    -- readAll string to the dfpwm streamer which could cause duplicated
    -- playback)
    local file = fs.open(clipPath, "rb")
    if not file then
        error("Clip file not found: " .. clipPath)
    end

    -- Create a reader function that returns chunks from the file. AUKit's
    -- stream functions accept either a string or a function; using a
    -- function keeps the file handle open while decoding/playback occurs.
    local function reader()
        return file.read(48000)
    end

    local iterator, length = aukit.stream.dfpwm(reader)
    aukit.play(iterator, function() end, 0.5, peripheral.find("speaker")) -- Play at 50% volume

    -- Close the file after playback completes
    file.close()

end


local function init(common)
    local logger = common.createLogger("overwatch")
    local clipPath = _G.WORKING_DIR .. "/data/overwatch"

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

    parallel.waitForAny(
        -- event loop
        function()
            while true do
                local event, id, data = os.pullEvent("overwatch")
                logger.log("Received overwatch event: " .. tostring(data))
                if data and type(data) == "string" then
                    playClip(data)
                else
                    logger.warn("Invalid overwatch event data: " .. tostring(data))
                end
            end
        end
    )
end

return init