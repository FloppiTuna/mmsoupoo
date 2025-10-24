-- Overwatch announcement system.

local map = require(_G.WORKING_DIR .. "/data/overwatch/map")
local aukit = require(_G.WORKING_DIR .. "/libs/aukit")

local function playClip(name)
    -- fetch path from map
    local clipPath = _G.WORKING_DIR .. "/data/overwatch/" .. map.clips[name]

    local dfpwm = require("cc.audio.dfpwm")
    local speaker = peripheral.find("speaker")

    -- for some reason (god knows why) AUKit has this bug where it just plays the file twice.
    -- why?? who motherfuckin knows!!! as a workaround im just using the manual dfpwm decoder/playback
    -- aukit pls fix ur stuff..unless im a dumb idiot which i will not be putting out of the question
    
    local decoder = dfpwm.make_decoder()
    for chunk in io.lines(clipPath, 16 * 1024) do
        local buffer = decoder(chunk)

        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
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

    -- Use a simple in-memory queue and two parallel tasks:
    -- 1) producer: pulls "overwatch" events, logs them and enqueues clip names
    -- 2) consumer: waits for items in the queue and runs playClip on them
    local playQueue = {}

    parallel.waitForAny(
        function() -- producer: consumes os.pullEvent("overwatch") and enqueues
            while true do
                local event, id, data = os.pullEvent("overwatch")
                logger.debug("Received overwatch event: " .. tostring(data))
                if data and type(data) == "string" then
                    table.insert(playQueue, data)
                    -- wake consumer
                    os.queueEvent("overwatch_play")
                else
                    logger.warn("Invalid overwatch event data: " .. tostring(data))
                end
            end
        end,

        function() -- consumer: processes queue and plays clips sequentially
            while true do
                if #playQueue == 0 then
                    -- wait until producer signals there's work
                    os.pullEvent("overwatch_play")
                end

                local name = table.remove(playQueue, 1)
                if name then
                    playClip(name)
                end
            end
        end
    )
end

return init