-- Sample overwatch test module.
-- Announces the time every minute

local overwatchInterface = require("../utils/overwatchInterface")

local function init(common)
    local logger = common.createLogger("clock")

    parallel.waitForAny(
        -- event loop
        function()
            while true do
                -- Wait for the minute to change
                local currentTime = os.date("*t")
                local currentMinute = currentTime.min
                repeat
                    os.sleep(1)
                    currentTime = os.date("*t")

                until currentTime.min ~= currentMinute
                print(currentTime.hour .. ":" .. currentTime.min)
                -- Announce the time
                overwatchInterface.playNumber(currentTime.hour)
                overwatchInterface.playNumber(currentTime.min)
            end
        end
    )

end

return init