local aukit = require "aukit"

local function runFranky(common)
    -- You should do this at the start of your module to make writing logger calls easier.
    local logger = common.createLogger("franky")

    local x = 0
    while x <= 10 do
        local randomNumber = math.random(1, 100) -- Generate a random number between 1 and 100
        logger.warn("Random number #" .. x .. ": " .. randomNumber)
        sleep(1) -- Wait for 10 seconds
        x = x + 1
    end

end

return runFranky