PTASavedVars = PTASavedVars or {}

HelperFunc = HelperFunc or {}

local HFLog = PrintHelper:New("PlayTimer", {255, 0, 255})
HFLog:EnableTag(false)

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
        print(
            HFLog:ColorText("Usage"),
            HFLog:ColorText("/playtimer mode account", "#ff0000"),
            HFLog:ColorText("OR"),
            HFLog:ColorText("/playtimer mode character", "#ff0000")
        )
        return
    elseif verb == "add" then
        print(
            HFLog:ColorText("Usage:"),
            HFLog:ColorText("/playtimer add <time>", "#ff0000"),
            HFLog:ColorText("(e.g., 10h30m10s, 10h, 30m)")
        )
        return
    end

    print("Usage: /playtimer <time> (e.g., 10h30m10s, 10h, 30m)")
    print("Usage: /playtimer add||reduce <time>")
    print("Use /playtimer help to print a complete list of commands.")
end

function HelperFunc.ShowHelp()

    print(
        HFLog:GetFormattedTag(),
        HFLog:ColorText("Slash commands")
    )

    print(
        HFLog:ColorText(" /playtimer <time>", "#ff0000"),
        HFLog:ColorText("(e.g., 10h30m10s, 10h, 30m) - sets total play time allowance.")
    )

    print(
        HFLog:ColorText(" /playtimer add <time>", "#ff0000"),
        HFLog:ColorText("- add amount of <time> to your allowance")
    )

    print(
        HFLog:ColorText(" /playtimer reduce <time>", "#ff0000"),
        HFLog:ColorText("- reduce the amount of <time> allowance")
    )

    print(
        HFLog:ColorText(" /playtimer pause", "#ff0000"),
        HFLog:ColorText("- Pauses play timer")
    )

    print(
        HFLog:ColorText(" /playtimer mode account||character", "#ff0000"),
        HFLog:ColorText("- switches between time allowance per account/character")
    )
end