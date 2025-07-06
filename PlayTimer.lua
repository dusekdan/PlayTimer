-- Define the addon namespace
local PlayTimerAddon = {}

-- Persistent storage for time values and elapsed time
-- By the way - if saved vars are already found and loaded for the addon
-- wow will overwrite the PTASavedVars with its own values and will not overwrite
-- whatever I am putting here into the saved vars state
PTASavedVars = {
    totalTime = 0,  -- Total play time in seconds
    elapsedTime = 0, -- Elapsed time in seconds
}
-- 79.740 14.20

local PTASavedVarsDefaults = {
    totalTime = 0,  -- Total play time in seconds
    elapsedTime = 0, -- Elapsed time in seconds
}

-- Updates the saved variables for total time and resets elapsed time
function PlayTimerAddon:SetPlayTime(input)
    print("SetPlayTime input", input)
    local totalTime = HelperFunc.parseTimeString(input)
    print("totalTime ".. totalTime)
    if totalTime > 0 then
        PTASavedVars.totalTime = totalTime
        -- PTASavedVars.elapsedTime = 0 -- this line determines whether elapsedTime is reset when new totalTime is added
        print("PlayTimer set to: " .. input)
    else
        print("Invalid time format. Please use 10h30m10s, 10h, or 30m.")
    end
end

-- Create a small timer frame for displaying remaining time
local timerFrame = CreateFrame("Frame", "PlayTimerFrame", UIParent)
timerFrame:SetSize(150, 50)
timerFrame:SetPoint("CENTER", UIParent, "CENTER")
timerFrame:EnableMouse(true) -- Thanks to this Line, WoW will cache the position in its internal layout
timerFrame:SetMovable(true)
timerFrame:RegisterForDrag("LeftButton")
timerFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
timerFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    print("user placed x=" .. x .. ", y=" .. y)
end)
timerFrame:Hide()

local timerText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
timerText:SetPoint("CENTER")

local function updateTimerFrame(remainingTime)
    if remainingTime <= 0 then
        timerFrame:Hide()
    else
        local hours = math.floor(remainingTime / 3600)
        local minutes = math.floor((remainingTime % 3600) / 60)
        local seconds = remainingTime % 60
        timerText:SetText(string.format("%02dh %02dm %02ds", hours, minutes, seconds))
        timerFrame:Show()
    end
end

-- Updates elapsed time and displays the remaining time
function PlayTimerAddon:UpdateAndDisplayTime()
    PTASavedVars.elapsedTime = PTASavedVars.elapsedTime + 1
    local remainingTime = PTASavedVars.totalTime - PTASavedVars.elapsedTime

    if remainingTime <= 0 then
        print("Your playtime is over!")
    else
        updateTimerFrame(remainingTime)
    end
end

-- Command handler for /playtimer 
SLASH_PLAYTIMER1 = "/playtimer"
SlashCmdList["PLAYTIMER"] = function(input)

    local commandVerbs = {"add", "reduce", "reset-completely", "pause",
        "balance", "mode", "alert", "help"}

    local args = {}
    for parameter in string.gmatch(input, "%S+") do
        table.insert(args, parameter)
    end


    -- Debug outputs
    if args[1] ~= nil then
        print(args[1])
    else 
        print("arg1 was nil")
    end

    if args[2] ~= nil then
        print(args[2])
    else 
        print("arg2 was nil")
    end
    -- /Debug outputs

    local commandVerb = args[1]
    if not commandVerb then
        print("Usage: /playtimer <time> (e.g., 10h30m10s, 10h, 30m)")
        print("Usage: /playtimer add|reduce <time>")
        print("Use /playtimer help to print a complete list of commands.")
        return
    end

    print("Command verb: ".. commandVerb)

    if not HelperFunc.isInList(commandVerbs, string.lower(commandVerb)) then
        print("Command verb not recognized... pass this straight to SetPlayTime() that does its own check.")
        PlayTimerAddon:SetPlayTime(commandVerb)
        return
    end

    -- Normalize the command verb (or time string, but the output shouldnt be affected)
    commandVerb = string.lower(commandVerb)
    
    if commandVerb == "add" then
        print("ADD ")
        -- use same validation logic as in SetPlayTime() to decide what to do
    elseif commandVerb == "reduce" then
        print("REDUCE")
    elseif commandVerb == "pause" then
        print("PAUSE")
    elseif commandVerb == "balance" then
        print("BALANCE")
    elseif commandVerb == "mode" then
        print("MODE")
    elseif commandVerb == "help" then
        print("HELP")
    elseif commandVerb == "alert" then
        print("ALERT")
    elseif commandVerb == "reset-completely" then
        print("RESET-COMPLETELY")
    end


end

-- Start a ticker to update time every second
local function startTimer()
    if PlayTimerAddon.ticker then
        PlayTimerAddon.ticker:Cancel()
    end

    PlayTimerAddon.ticker = C_Timer.NewTicker(1, function()
        PlayTimerAddon:UpdateAndDisplayTime()
    end)
end


-- Command handler for /playtimerdebug
SLASH_PLAYTIMERDEBUG1 = "/playtimerdebug"
SlashCmdList["PLAYTIMERDEBUG"] = function()
    print(PTASavedVars.totalTime)
    print(PTASavedVars.elapsedTime)
end

-- Erasing some of the PTa
-- in game run
-- /run PTASavedVars.elapsedTime = 0
-- /run PTSavedVars.totalTime = 0

-- Addon initialization
function PlayTimerAddon:OnLoad()

    PTASavedVars.totalTime = PTASavedVars.totalTime or 0
    PTASavedVars.elapsedTime = PTASavedVars.elapsedTime or 0


    print("PlayTimer addon loaded.")
    timerFrame:SetPoint("CENTER", UIParent, "CENTER")
    startTimer()
end


PlayTimerAddon:OnLoad()
