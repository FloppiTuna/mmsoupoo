local aukit = require "aukit"
local loop = require "/taskmaster"()

local seekTarg = -1
local player
local function runAmbienceMusic(common, logger, ambiencePeripherals, ambiencePath)
    local function shuffle(tbl)
        for i = #tbl, 2, -1 do
            local j = math.random(i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
    end

    local function get_dfpwm_files(path)
        local files = {}
        for _, file in ipairs(fs.list(path)) do
            if file:match("%.dfpwm$") then
                table.insert(files, fs.combine(path, file))
            end
        end
        return files
    end

    math.randomseed(os.epoch("utc"))

    while true do
        local files = get_dfpwm_files(ambiencePath)
        if #files == 0 then
            logger.error("No .dfpwm files found in " .. ambiencePath)
        end

        shuffle(files)
        for _, filename in ipairs(files) do
            -- Read the data
            local file = fs.open(filename, "rb") -- Read binary mode is important.
            if not file then
                logger.error("Music file doesn't exist.", 0)
            end
            local data = file.readAll() -- Actually read data
            file.close() -- Important to close file handles.

            -- Play audio using AUKit
            logger.debug("Playing " .. filename)
            local iterator, length = aukit.stream.dfpwm(data)
            -- local player
            player = aukit.player(
                loop,
                iterator,
                .35, -- Audio volume
                table.unpack(ambiencePeripherals) -- Speakers to play the audio on
            )

            -- loop:addTimer(.25, function()
            --         print(seekTarg)
            --         if seekTarg >= 0 then

            --             logger.log("Seeking to " .. seekTarg .. " seconds.")
            --             player:seek(seekTarg)
            --             seekTarg = -1
            --         end
            --     end,
            --     0.5 -- Check every 0.5 seconds for seeking
            -- )
            loop:run(2)
        end
    end
end

local function eventLoop(common, logger)
    rednet.open("left")
    while true do
        local event, id, data = os.pullEvent("ambience")
        print(event .. " " .. tostring(id) .. " " .. tostring(data))
        if data == "play" then
            player.isPaused = false -- for some reason the actual play/pause methods dont work lol
            rednet.send(id, {
                status = "ok",
                message = "Playing at " .. player:livePosition() .. " seconds"
            })
        else if data == "pause" then
            player.isPaused = true
            rednet.send(id, {
                status = "ok",
                message = "Paused at " .. player:livePosition() .. " seconds"
            })
        else if data == "info" then
            rednet.send(id, {
                status = "ok",
                message = "Playing: " .. player:livePosition() .. " seconds, " ..
                          "Volume: " .. player.volume .. ", " ..
                          "Paused: " .. tostring(player.isPaused)
            })
        else if data == "vol" then
            player.volume = 1
            rednet.send(id, {
                status = "ok",
                message = "Volume set to " .. player.volume
            })
        else 
            rednet.send(id, {
                status = "error",
                message = "Unknown command: " .. tostring(data)
            })
        end
        end
        end
        end
    end
end

local function init(common)
    local logger = common.createLogger("ambience")
    local ambiencePath = "mmsoupoo/data/ambience"

    local ambiencePeripherals = {}
    for _, periph in pairs(common.periphMap) do
        if periph.service == "ambience" then
            table.insert(ambiencePeripherals, peripheral.wrap(periph.type .. "_" .. periph.id))
        end
    end
    logger.log("Found " .. #ambiencePeripherals .. " ambience peripherals.")

    parallel.waitForAny(
        function() runAmbienceMusic(common, logger, ambiencePeripherals, ambiencePath) end,
        function() eventLoop(common, logger) end
    )
end

return init
