local overwatchInterface = require(_G.WORKING_DIR .. "/utils/overwatchInterface")
-- AE2 Matter Energy Module.

local function init(common)
    local logger = common.createLogger("me")
    local meBridge = peripheral.wrap("meBridge_0")

    if not meBridge then
        logger.error("ME Bridge peripheral not found. Ensure it is connected and named correctly.")
        return
    end

    parallel.waitForAny(
        function()
            while true do
                local count = #meBridge.listItems()
                logger.debug("itemcount: " .. tostring(count))
                overwatchInterface.playClip("there")
                overwatchInterface.playClip("are")
                overwatchInterface.playClip("currently")
                overwatchInterface.playNumber(count)
                overwatchInterface.playClip("items")
                overwatchInterface.playClip("in")
                overwatchInterface.playClip("matter_energy")
                overwatchInterface.playClip("system")
                os.sleep(10) -- Announce every 10 seconds
            end
        end
    )

end

return init