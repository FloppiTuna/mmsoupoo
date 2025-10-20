-- Sample overwatch test module.
-- Announces the time every minute

local overwatchInterface = require(_G.WORKING_DIR .. "/utils/overwatchInterface")

local function init(common)
    local logger = common.createLogger("clock")

    parallel.waitForAny(
        -- Every five real life minutes:
        --   * Announce the time
        function()
            while true do
                local time = os.date("*t")
                local hour = time.hour
                local minute = time.min

                logger.debug(string.format("Announcing time: %02d:%02d", hour, minute))

                os.queueEvent("ambience", "pause")

                overwatchInterface.playClip("chime1")
                overwatchInterface.playClip("the_time_is")

                -- Announce hour
                if hour == 0 then
                    overwatchInterface.playClip("midnight")
                elseif hour == 12 then
                    overwatchInterface.playClip("noon")
                else
                    if hour > 12 then
                        hour = hour - 12
                    end
                    overwatchInterface.playNumber(hour)
                end

                -- Announce minute
                if minute == 0 then
                    overwatchInterface.playClip("oclock")
                else
                    overwatchInterface.playNumber(minute)
                end

                -- Announce am/pm
                if time.hour < 12 then
                    overwatchInterface.playClip("am")
                else
                    overwatchInterface.playClip("pm")
                end

                overwatchInterface.playClip("chime1")
                
                os.queueEvent("ambience", "play")

                -- Wait for five minutes
                os.sleep(300)
            end
        end
    )

end

return init