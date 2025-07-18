PrintHelper = {}
PrintHelper.__index = PrintHelper

local predefinedColors = {
    red = {255, 0, 0},
    green = {0, 255, 0},
    blue = {0, 0, 255},
    yellow = {255, 255, 0},
    orange = {255, 128, 0},
    white = {255, 255, 255},
    gray = {128, 128, 128}
}

local resetColorTag = "|r"

function PrintHelper:New(tag, defaultColor)
    local obj = {
        tag = tag or "PlayTimer",
        useTagByDefault = true,
        defaultColor = defaultColor or {255, 255, 255},
    }
    setmetatable(obj, PrintHelper)

    return obj
end

function PrintHelper:SetTag(tag)
    self.tag = tag
end

function PrintHelper:EnableTag(value)
    self.useTagByDefault = value
end

function PrintHelper:SetDefaultColor(r, g, b)
    self.defaultColor = {r, g, b}
end

function PrintHelper:GetFormattedTag()
    return self:ColorText(
        "[" .. self.tag ..  "]",
        "#00B7FF"
    )
end

function PrintHelper:ColorText(text, color)
    local safeColor = self:_ParseColor(
        color or self.defaultColor or {255, 255, 255}
    )
    local r, g, b = unpack(safeColor)
    local colorCodePrefix = self:_ColorCode(r, g, b)

    return colorCodePrefix .. text .. resetColorTag
end

function PrintHelper:_ParseColor(color)
    -- Predefined color or HEX color
    if type(color) == "string" then
        color = color:lower()

        -- Case 1: Predefined color available
        if predefinedColors[color] then
            return predefinedColors[color]
        end

        -- Case 2: Hex color
        local hex = color:match("^#?(%x%x%x%x%x%x)$")
        if hex then
            local r = tonumber(hex:sub(1,2), 16)
            local g = tonumber(hex:sub(3,4), 16)
            local b = tonumber(hex:sub(5,6), 16)

            return {r,g,b}
        end
    end

    -- Case 3: Color provided as rgb table (e.g. {255, 0, 255})
    if type(color) == "table" then
        local r, g, b = unpack(color)

        -- Ensure value for each channel is between 0 and 255
        r = math.max(0, math.min(255, r))
        g = math.max(0, math.min(255, g))
        b = math.max(0, math.min(255, b))

        return {r, g, b}
    end

    -- If provided color doesn't match any of the cases supported, use
    -- default text color. If default color is not available, make it white.
    return self.defaultColor or {255, 255, 255}
end

function PrintHelper:_ColorCode(r, g, b)
    -- WoW Color code is always "|cAARRGGBB"
    -- Where:
    --  A => Alpha channel (chat colors forced to max (255 = FF))
    --  R, G, B => Red, Green and Blue channel respectively
    return string.format("|cff%02x%02x%02x", r, g, b)
end

--function PrintHelper:_FormatMessage(text, showTag)
--    if showTag == nil then
--        showTag = self.useTagByDefault
--    end
--
--    return showTag 
--end