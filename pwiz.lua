-- Testing peripheral mapping.
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

term.clear()
term.setCursorPos(1, 1)

-- Fetch all peripherals connected to the computer.
local pNames = peripheral.getNames()
local peripherals = {}
for _, name in ipairs(pNames) do
    print(name)
    sleep(0.1)
    if peripheral.getType(name) ~= "monitor" then  -- Exclude monitors from the list.
        table.insert(peripherals, name)
    end
end

-- Initialize a table to hold the mapping of peripherals.
-- Schema: { "TYPE_ID": { type = "TYPE", id = "ID", service = "SERVICE_NAME" } }
local peripheralMap = {}

-- Load existing mapping from file if it exists.
local mapContent = ""
if fs.exists("data/periph.map") then
    local mapFile = fs.open("data/periph.map", "r")
    mapContent = mapFile.readAll()
    mapFile.close()
end
-- If the file is not empty, deserialize the JSON content into the peripheralMap.
if mapContent ~= "" then
    local success, loadedMap = pcall(textutils.unserializeJSON, mapContent)
    if success and type(loadedMap) == "table" then
        peripheralMap = loadedMap
    else
        print("Error loading peripheral map from file. Starting with an empty map.")
    end
else
    print("No existing peripheral map found. Starting with an empty map.")
end


-- Merge currently attached peripherals with the peripheralMap
for _, name in ipairs(peripherals) do
    local type, id = name:match("^(.-)_(.-)$")
    if type and id then
        -- If the peripheral is not already mapped, add it with an empty service.
        if not peripheralMap[name] then
            peripheralMap[name] = {type = type, id = id, service = nil}
        end
    end
end

-- Start the command loop to modify the mapping.
while true do
    term.clear()
    term.setCursorPos(1, 1)
    print(#peripherals .. " peripherals detected.")
    print("")
    print(string.format("%-3s %-12s %-16s %-16s", "ID", "TYPE", "MAPPED?", "SERVICE(S)"))
    local w, h = term.getSize()
    print(string.rep("-", w))

    for name, info in pairs(peripheralMap) do
        local service = info.service or "-"
        local exists = peripheral.isPresent(name)

        if not exists then
            term.setTextColor(colors.gray)
        elseif info.service then
            term.setTextColor(colors.green)
        else
            term.setTextColor(colors.orange)
        end

        print(string.format("%-3s %-12s %-16s %-16s", info.id .. (exists and "" or "\x06"), info.type, info.service and "YES" or "NO", service))
        term.setTextColor(colors.white)
    end

    print(string.rep("-", w))
    print("(I)dentify, (A)ssign, (U)nassign, (F)inish")

    -- Wait for a keypress event
    local event, key = os.pullEvent("key")
    os.pullEvent("char") -- if you dont do this the command key will be input to the terminal...

    -- Map key codes to actions
    if key == keys.i then
        write("Enter ID to identify: ")
        local targetId = read()
        -- Find the peripheral name by ID
        local targetName, targetInfo
        for name, info in pairs(peripheralMap) do
            if info.id == targetId then
                targetName = name
                targetInfo = info
                break
            end
        end

        if targetName and targetInfo then
            print("Identifying peripheral: " .. targetName)
            print("Type: " .. targetInfo.type)

            local peripheral = peripheral.wrap(targetName)

            -- Switch-case style for peripheral type
            if targetInfo.type == "speaker" then
                if peripheral.playSound then
                    print("Press any key to stop identification...")
                    local running = true
                    local function playLoop()
                        while running do
                            -- Play "identify.dfpwm" sound file
                            for chunk in io.lines("data/identify.dfpwm", 16 * 1024) do
                                local buffer = decoder(chunk)

                                while not peripheral.playAudio(buffer) do
                                    os.pullEvent("speaker_audio_empty")
                                end
                            end
                            sleep(0.5)
                        end
                    end
                    parallel.waitForAny(playLoop, function()
                        os.pullEvent("key")
                        running = false
                    end)
                end
            else
                print("Can't identify a peripheral of type " .. targetInfo.type)
            end
        else
            term.setTextColor(colors.red)
            print("ID " .. targetId .. " not found on bus!")
            term.setTextColor(colors.white)
        end

    elseif key == keys.a then
        write("Enter ID to assign: ")
        local targetId = read()
        -- Find the peripheral name by ID
        local targetName, targetInfo
        for name, info in pairs(peripheralMap) do
            if info.id == targetId then
                targetName = name
                targetInfo = info
                break
            end
        end

        if targetName and targetInfo then
            write("Enter service name to assign: ")
            local service = read()
            targetInfo.service = service

            -- Save only entries with a service to file
            local filteredMap = {}
            for name, info in pairs(peripheralMap) do
                if info.service then
                    filteredMap[name] = info
                end
            end
            local outFile = fs.open("data/periph.map", "w")
            outFile.write(textutils.serializeJSON(filteredMap))
            outFile.close()

            -- Repopulate mapContent
            local mapFile = fs.open("data/periph.map", "r")
            mapContent = mapFile.readAll()
            mapFile.close()

            print("Assigned service '" .. service .. "' to peripheral ID " .. targetId)
        else
            term.setTextColor(colors.red)
            print("ID " .. targetId .. " not found on bus!")
            term.setTextColor(colors.white)
        end

    elseif key == keys.u then
        write("Enter ID to unassign: ")
        local targetId = read()
        -- Find the peripheral name by ID
        local targetName, targetInfo
        for name, info in pairs(peripheralMap) do
            if info.id == targetId then
                targetName = name
                targetInfo = info
                break
            end
        end

        if targetName and targetInfo then
            targetInfo.service = nil

            -- Save only entries with a service to file
            local filteredMap = {}
            for name, info in pairs(peripheralMap) do
                if info.service then
                    filteredMap[name] = info
                end
            end
            local outFile = fs.open("data/periph.map", "w")
            outFile.write(textutils.serializeJSON(filteredMap))
            outFile.close()

            -- Repopulate mapContent
            local mapFile = fs.open("data/periph.map", "r")
            mapContent = mapFile.readAll()
            mapFile.close()

            print("Unassigned service from peripheral ID " .. targetId)
        else
            term.setTextColor(colors.red)
            print("ID " .. targetId .. " not found on bus!")
            term.setTextColor(colors.white)
        end
    elseif key == keys.f then
        print("Finishing...")
        break
    end
end

