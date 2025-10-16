local clips = {
    -- Numbers (single digit)
    ["1"] = "numbers/digits/one.dfpwm",
    ["2"] = "numbers/digits/two.dfpwm",
    ["3"] = "numbers/digits/three.dfpwm",
    ["4"] = "numbers/digits/four.dfpwm",
    ["5"] = "numbers/digits/five.dfpwm",
    ["6"] = "numbers/digits/six.dfpwm",
    ["7"] = "numbers/digits/seven.dfpwm",
    ["8"] = "numbers/digits/eight.dfpwm",
    ["9"] = "numbers/digits/nine.dfpwm",
    ["0"] = "numbers/digits/zero.dfpwm",

    -- Numbers (multi digit)
    ["10"] = "numbers/digits/ten.dfpwm",
    ["11"] = "numbers/digits/eleven.dfpwm",
    ["12"] = "numbers/digits/twelve.dfpwm",
    ["13"] = "numbers/digits/thirteen.dfpwm",
    ["14"] = "numbers/digits/fourteen.dfpwm",
    ["15"] = "numbers/digits/fifteen.dfpwm",
    ["16"] = "numbers/digits/sixteen.dfpwm",
    ["17"] = "numbers/digits/seventeen.dfpwm",
    ["18"] = "numbers/digits/eighteen.dfpwm",
    ["19"] = "numbers/digits/nineteen.dfpwm",
    ["20"] = "numbers/digits/twenty.dfpwm",
    ["30"] = "numbers/digits/thirty.dfpwm",
    ["40"] = "numbers/digits/forty.dfpwm",
    ["50"] = "numbers/digits/fifty.dfpwm",
    ["60"] = "numbers/digits/sixty.dfpwm",
    ["70"] = "numbers/digits/seventy.dfpwm",
    ["80"] = "numbers/digits/eighty.dfpwm",
    ["90"] = "numbers/digits/ninety.dfpwm",

    -- Numbers (places)
    ["100"] = "numbers/places/hundred.dfpwm",
    ["1000"] = "numbers/places/thousand.dfpwm",
    ["1000000"] = "numbers/places/million.dfpwm",
    ["1000000000"] = "numbers/places/billion.dfpwm",

    ["-"] = "numbers/places/negative.dfpwm",
    ["."] = "numbers/places/point.dfpwm",
}

local aliases = {
    -- If no clip is found for a given phrase/word, you may define aliases here.
    -- For example, "one" will play the same clip as "1".
    ["one"] = "1",
    ["two"] = "2",
    ["three"] = "3",
    ["four"] = "4",
    ["five"] = "5",
    ["six"] = "6",
    ["seven"] = "7",
    ["eight"] = "8",
    ["nine"] = "9",
    ["zero"] = "0",

    ["ten"] = "10",
    ["eleven"] = "11",
    ["twelve"] = "12",
    ["thirteen"] = "13",
    ["fourteen"] = "14",
    ["fifteen"] = "15",
    ["sixteen"] = "16",
    ["seventeen"] = "17",
    ["eighteen"] = "18",
    ["nineteen"] = "19",
    ["twenty"] = "20",
    ["thirty"] = "30",
    ["forty"] = "40",
    ["fifty"] = "50",
    ["sixty"] = "60",
    ["seventy"] = "70",
    ["eighty"] = "80",
    ["ninety"] = "90",

    ["hundred"] = "100",
    ["thousand"] = "1000",
    ["million"] = "1000000",
    ["billion"] = "1000000000",

    ["negative"] = "-",
    ["point"] = ".",
}

return {
    clips = clips,
    aliases = aliases,
}
