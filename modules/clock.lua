-- Sample overwatch test module.
-- Announces the time every minute

local overwatchInterface = require(_G.WORKING_DIR .. "/utils/overwatchInterface")

local function init(common)
    local logger = common.createLogger("clock")

    parallel.waitForAny(
        -- test: every minute, announce the time
        function()
            while true do
                local time = os.date("*t")
                local hour = time.hour
                local min = time.min

                logger.log(string.format("Announcing time: %02d:%02d", hour, min))

                overwatchInterface.playClip("the_time_is")

                -- Announce hour
                overwatchInterface.playNumber(hour)

                -- Announce minute
                overwatchInterface.playNumber(min)

                -- Wait until the start of the next minute
                local sleepTime = 60 - time.sec
                os.sleep(sleepTime)
            end
        end
    )

end

return init