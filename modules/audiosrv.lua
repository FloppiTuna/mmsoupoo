local function init(common)
    local logger = common.createLogger("audiosrv")

    -- Get all allocated audio peripherals
    local audioPeripherals = {}
    for _, periph in pairs(common.periphMap) do
        if periph.service == "audiosrv" then
            table.insert(audioPeripherals, peripheral.wrap(periph.type .. "_" .. periph.id))
        end
    end
    logger.log("Total output devices: " .. #audioPeripherals .. ".")

    if #audioPeripherals == 0 then
        logger.error("No audio output peripherals allocated; I am useless in this configuration!")
        return
    end

    -- initialize channel crap
    local channels = {}

    parallel.waitForAny(
        -- channel handler
        function()
            while true do
                local event, data = os.pullEvent("audiosrv")

                if data and type(data) == "table" then
                    if data.action == "register_channel" then
                        table.insert(channels, {
                            name = data.name,
                            volume = data.volume or 1.0
                        })
                        logger.debug("Registered audio channel: " .. data.name .. " at volume " .. tostring(data.volume or 1.0))
                    end
                end
            end
        end
    )



end

return init