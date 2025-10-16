local function init(common)
    local logger = common.createLogger("remote")

    local whitelistedIds = {
        [36] = true
    }

    rednet.open("left")
    logger.log("Listening on rednet... I am: " .. os.getComputerID())
    while true do
        local id, message = rednet.receive()

        -- Discard messages from non-whitelisted IDs
        if not whitelistedIds[id] then
            -- logger.log("Discarding message from non-whitelisted ID: " .. id)
        else
            logger.debug("Received message from " .. id .. ": " .. textutils.serialize(message))

            -- Parse the message
            -- Format: "namespace:function(args)"
            local parts = {}
            for part in string.gmatch(message, "([^:]+)") do
                table.insert(parts, part)
            end
            print("Parts: " .. textutils.serialize(parts))

            -- Does the message have a namespace?
            if #parts < 2 then
                logger.debug("Invalid message format from " .. id .. ": " .. message)
                rednet.send(id, "NACK:ERRFORMAT")
            else 
                os.queueEvent(parts[1], id, parts[2])
            end
        end
    end

end

return init