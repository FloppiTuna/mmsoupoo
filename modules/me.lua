local overwatchInterface = require "overwatchInterface"
-- AE2 Matter Energy Module.

local function init(common)
    local logger = common.createLogger("me")
    local meBridge = peripheral.wrap("meBridge")

    if not meBridge then
        logger.error("ME Bridge peripheral not found. Ensure it is connected and named correctly.")
        return
    end

    parallel.waitForAny(
        function()
            while true do
                overwatchInterface.playNumber(#meBridge.listItems())
                os.sleep(60) -- Announce every 60 seconds
            end
        end
    )

end

return init