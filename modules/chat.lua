local overwatchInterface = require(_G.WORKING_DIR .. "/utils/overwatchInterface")

function init(common)
    local cb = peripheral.find("chatBox")
    local logger = common.createLogger("chat")

    while true do
        local event, username, message, uuid, isHidden, messageUtf8 = os.pullEvent("chat")
        local wakeword = string.find(message, "mmsoup")
        if wakeword == 1 then
            logger.debug("WakeWord detected, parsing message: ".. message)

            local words = {}
            for str in string.gmatch(message, "([^".." ".."]+)") do
                table.insert(words,str)
            end

            if words[2] == "test_announce" then
                logger.debug("Test announce command received from chat by " .. username)
                cb.sendMessage("Alright I'm going don't hit me", "MMSoUPoO")
                overwatchInterface.playClip("chime1")
                overwatchInterface.playClip("chime2")
                overwatchInterface.playClip("chime3")
                overwatchInterface.playClip("chime4")
                overwatchInterface.playClip("chime5")
                overwatchInterface.playClip("chime7")
            end

        end
    end
end

return init