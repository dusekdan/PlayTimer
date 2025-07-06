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