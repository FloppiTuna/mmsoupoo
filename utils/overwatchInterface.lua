-- interfacing library for the overwatch system
local map = require("../data/overwatch/map")

local overwatchInterface = {}

overwatchInterface.playClip = function(clipName)
    os.queueEvent("overwatch", nil, clipName)
end

overwatchInterface.playNumber = function(number)
    -- It's important to keep in mind that there are clips for 0-20, and then clips for tens (30, 40, ..., 90).
    -- There are also clips for "hundred" and "thousand", and "million".
    -- We will need to break down larger numbers into their individual components.
    print("Playing number: " .. tostring(number))

    if number < 0 or number > 100 then
        error("Number out of range")
    elseif number <= 20 then
        os.queueEvent("overwatch", nil, tostring(number))
    else
        local tens = math.floor(number / 10) * 10
        local ones = number % 10
        os.queueEvent("overwatch", nil, tostring(tens))
        if ones > 0 then
            os.queueEvent("overwatch", nil, tostring(ones))
        end
    end

    os.sleep(1)
end

return overwatchInterface