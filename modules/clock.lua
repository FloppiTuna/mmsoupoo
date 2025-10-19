-- Sample overwatch test module.
-- Announces the time every minute

local overwatchInterface = require("../utils/overwatchInterface")

local function init(common)
    local logger = common.createLogger("clock")

    parallel.waitForAny(
        -- test: prompt for a number to announce
        function()
            while true do
                term.write("Enter a number to announce (0-100): ")
                local input = read()
                local number = tonumber(input)
                if number then
                    overwatchInterface.playClip("sodium_mfg")  -- test facility clip
                else
                    print("Invalid input. Please enter a number.")
                end
            end
        end
    )

end

return init