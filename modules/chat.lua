local overwatchInterface = require(_G.WORKING_DIR .. "/utils/overwatchInterface")

function init(common)
    local cb = peripheral.find("chatBox")
    local logger = common.createLogger("chat")

    while true do
        local event, username, message, uuid, isHidden, messageUtf8 = os.pullEvent("chat")
        local wakeword = string.find(message, "mmsoup")
        if wakeword == 1 then
            logger.log("WakeWord detected, parsing message: ".. message)

            local words = {}
            for str in string.gmatch(message, "([^".." ".."]+)") do
                table.insert(words,str)
            end
        end
    end
end

return init