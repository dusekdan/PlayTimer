PTASavedVars = PTASavedVars or {}

HelperFunc = HelperFunc or {}

-- Parses the input string to convert it into total seconds
function HelperFunc.parseTimeString(input)
    local hours = string.match(input, "(%d+)h") or 0
    local minutes = string.match(input, "(%d+)m") or 0
    local seconds = string.match(input, "(%d+)s") or 0

    return (tonumber(hours) * 3600) + (tonumber(minutes) * 60) + tonumber(seconds)
end


function HelperFunc.isInList(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end

    return false
end

function HelperFunc.NormalizeString(param)
    if param == nil then
        return ""
    end

    return string.lower(param)
end

function HelperFunc.ShowUsageForVerb(verb)
    if verb == "mode" then
        print("Usage /playtimer mode account OR /playtimer mode character")
        return
    end

    print("Usage: /playtimer <time> (e.g., 10h30m10s, 10h, 30m)")
    print("Usage: /playtimer add||reduce <time>")
    print("Use /playtimer help to print a complete list of commands.")
end

function HelperFunc.ShowHelp()
    print("Usage: /playtimer <time> (e.g., 10h30m10s, 10h, 30m)")
    print(" /playtimer add <time> - add amount of <time> to your allowance")
    print(" /playtimer reduce <time> - reduce the amount of <time> allowance")
    print(" /playtimer pause - Pauses play timer")
    print(" /playtimer mode account||character - switches between time allowance per account/character")

end