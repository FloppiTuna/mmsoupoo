-- interfacing library for the overwatch system
local overwatchInterface = {}

overwatchInterface.playClip = function(clipName)
    os.queueEvent("overwatch", nil, clipName)
end

overwatchInterface.playNumber = function(number)
    if type(number) ~= "number" then
        error("playNumber expects a number")
    end

    -- Handle negative
    if number < 0 then
        os.queueEvent("overwatch", nil, "-")
        number = math.abs(number)
    end

    -- Work with an integer part only
    number = math.floor(number)

    -- Support up to 999,999,999,999 (hundreds of billions). Mapping provides up to "1000000000".
    if number > 999999999999 then
        error("Number out of supported range (max 999,999,999,999)")
    end

    -- Zero special-case
    if number == 0 then
        os.queueEvent("overwatch", nil, "0")
        os.sleep(1)
        return
    end

    -- Helper: queue a token
    local function q(tok)
        os.queueEvent("overwatch", nil, tostring(tok))
    end

    -- Helper: play a 1..999 number using "100" for hundreds and existing clips for tens/ones
    local function playThreeDigits(n)
        -- n expected 1..999
        if n >= 100 then
            local hundreds = math.floor(n / 100)
            q(hundreds)   -- e.g. "3"
            q(100)        -- "100" (the word "hundred")
            n = n % 100
        end

        if n > 0 then
            if n <= 20 then
                q(n) -- direct clip for 0..20
            else
                local tens = math.floor(n / 10) * 10
                local ones = n % 10
                q(tens) -- e.g. "30", "40"
                if ones > 0 then
                    q(ones)
                end
            end
        end
    end

    -- Split into 3-digit groups (units, thousands, millions, billions, ...)
    local groups = {}
    local temp = number
    while temp > 0 do
        table.insert(groups, temp % 1000) -- groups[1] = units
        temp = math.floor(temp / 1000)
    end

    -- Iterate from highest group down to units
    for i = #groups, 1, -1 do
        local grp = groups[i]
        if grp and grp > 0 then
            -- play the group's numeric words
            playThreeDigits(grp)

            -- If this is a scale (thousand, million, billion), emit the place token
            local scalePower = i - 1 -- 0 => units, 1 => thousand, 2 => million, 3 => billion
            if scalePower > 0 then
                local placeValue = 1000 ^ scalePower
                q(placeValue) -- e.g. "1000", "1000000", "1000000000"
            end
        end
    end

    os.sleep(1)
end

return overwatchInterface