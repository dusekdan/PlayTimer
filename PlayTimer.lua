-- Define the addon namespace
local PlayTimerAddon = {}
local Logger = PrintHelper:New("PlayTimer", {255, 255, 0})


-- Create a small timer frame for displaying remaining time
function PlayTimerAddon:InitAddonFrame()
    self.addonName = "PlayTimer"
    self.timerFrame = CreateFrame("Frame", "PlayTimerFrame", UIParent)
    self.timerFrame:RegisterEvent("ADDON_LOADED")
    self.timerFrame:SetScript("OnEvent", function(self, event, name)
        if name == PlayTimerAddon.addonName and event == "ADDON_LOADED" then
            PlayTimerAddon:OnLoad();
            print(
                Logger:GetFormattedTag(),
                Logger:ColorText("Addon loaded.")
            )
        end
        self:UnregisterEvent("ADDON_LOADED")
    end)

    self.timerFrame:SetSize(150, 50)
    self.timerFrame:SetPoint("CENTER", UIParent, "CENTER")

    self.timerFrame:EnableMouse(true) -- Thanks to this Line, WoW will cache the position in its internal layout
    self.timerFrame:SetMovable(true)

    self.timerFrame:RegisterForDrag("LeftButton")
    self.timerFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    self.timerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
    end)

    self.timerText = self.timerFrame:CreateFontString(nil,
        "OVERLAY", 
        "GameFontNormalLarge"
    )
    self.timerText:SetPoint("CENTER")
end

PlayTimerAddon:InitAddonFrame()


-- Returns number of seconds remining on the timer
function PlayTimerAddon:GetRemainingBalance()
    local isCharacterMode = (PTACharSavedVars.mode == "character")

    if isCharacterMode then
        return PTACharSavedVars.totalTime - PTACharSavedVars.elapsedTime
    end

    return PTASavedVars.totalTime - PTASavedVars.elapsedTime
end


-- Returns number of seconds elapsed on the timer
function PlayTimerAddon:GetElapsedBalance()
    local isCharacterMode = (PTACharSavedVars.mode == "character")

    if isCharacterMode then
        return PTACharSavedVars.elapsedTime
    end

    return PTASavedVars.elapsedTime
end


function PlayTimerAddon:DisplayRemainingTime()
    local remainingTime = PlayTimerAddon:GetRemainingBalance()
    local timeString = HelperFunc.SecondToTimeString(remainingTime, " ")

    self.timerText:SetText(timeString)
    self.timerFrame:Show()
end


function PlayTimerAddon:DecrementTimerBalance()
    local isCharacterMode = (PTACharSavedVars.mode == "character")

    local remainingTime = 0
    if isCharacterMode then
        PTACharSavedVars.elapsedTime = PTACharSavedVars.elapsedTime + 1
        remainingTime = PTACharSavedVars.totalTime - PTACharSavedVars.elapsedTime
    else
        PTASavedVars.elapsedTime = PTASavedVars.elapsedTime + 1
        remainingTime = PTASavedVars.totalTime - PTASavedVars.elapsedTime
    end

    return remainingTime
end

function PlayTimerAddon:UpdateTimerFrame(remainingTime)
    if remainingTime <= 0 then
        self.timerFrame:Hide()
    else
        local remainingTimeString = HelperFunc.SecondToTimeString(remainingTime, " ")

        self.timerText:SetText(remainingTimeString)
        self.timerFrame:Show()
    end
end


-- Returns Timer Paused status based on current account/character mode
function PlayTimerAddon:IsTimerPaused()
    if (PTACharSavedVars.mode == "character") then
        return PTACharSavedVars.isPaused
    end

    return PTASavedVars.isPaused
end


-- Updates the saved variables for total time and resets elapsed time
function PlayTimerAddon:SetPlayTime(input)

    local isCharacterMode = (PTACharSavedVars.mode == "character")

    local totalTime = HelperFunc.parseTimeString(input)
    if totalTime > 0 then

        if isCharacterMode then
            PTACharSavedVars.totalTime = totalTime
        else
            PTASavedVars.totalTime = totalTime
        end

        print(
            Logger:GetFormattedTag(),
            Logger:ColorText("Timer allowance set to"),
            Logger:ColorText(input, "green")
        )
    else
        print(
            Logger:GetFormattedTag(),
            Logger:ColorText("Invalid time format. Use format such as"),
            Logger:ColorText("10h30m10s, 10h,", "green"),
            Logger:ColorText("or"),
            Logger:ColorText("30m", "green")
        )
    end
end


-- Updates elapsed time and displays the remaining time
function PlayTimerAddon:UpdateAndDisplayTime()
    if self:IsTimerPaused() then
        PlayTimerAddon:DisplayRemainingTime()
        return
    end

    local remainingTime = PlayTimerAddon:GetRemainingBalance()
    if remainingTime <= 0 then
        print(
            Logger:GetFormattedTag(),
            Logger:ColorText("Your playtime is over!", "red")
        )
        -- TODO: This is where notification channels will be handled.
    else
        PlayTimerAddon:DecrementTimerBalance()
        self:UpdateTimerFrame(remainingTime)
    end
end


-- Command handler for /playtimer 
SLASH_PLAYTIMER1 = "/playtimer"
SlashCmdList["PLAYTIMER"] = function(input)

    local isCharacterMode = (PTACharSavedVars.mode == "character")

    local commandVerbs = {"add", "reduce", "reset-timer", "pause",
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
        HelperFunc.ShowHelpForNoCommandVerbProvided()
        return
    end

    -- When command verb is not in the list of allowed command verbs, assume 
    -- user passed in time directly and try to set it. It validates internally.
    if not HelperFunc.isInList(commandVerbs, string.lower(commandVerb)) then
        PlayTimerAddon:SetPlayTime(commandVerb)
        return
    end

    -- Normalize the command verb (or time string, but the output shouldnt be affected)
    commandVerb = string.lower(commandVerb)
    local commandVerbParam = HelperFunc.NormalizeString(args[2])

    if commandVerb == "add" then
        local timeToAdd = HelperFunc.parseTimeString(commandVerbParam)
        if commandVerbParam == "" or timeToAdd <= 0 then
            HelperFunc.ShowUsageForVerb(commandVerb)
            return
        end

        if isCharacterMode then
            PTACharSavedVars.totalTime = PTACharSavedVars.totalTime + timeToAdd
        else
            PTASavedVars.totalTime = PTASavedVars.totalTime + timeToAdd
        end

        print(
            Logger:GetFormattedTag(),
            Logger:ColorText(
                "Play time added. Enjoy it, while it lasts!"
            )
        )

        -- use same validation logic as in SetPlayTime() to decide what to do
    elseif commandVerb == "reduce" then
        local timeToReduce = HelperFunc.parseTimeString(commandVerbParam)

        if timeToReduce <= 0 then
            print(
                Logger:GetFormattedTag(),
                Logger:ColorText(
                    "Provide a reasonable amount of time (e.g. 10m, 1h, 1h30m, etc.)"
                )
            )
            return
        end

        local remainingTime = PlayTimerAddon:GetRemainingBalance()

        if remainingTime - timeToReduce < 0 then
            print(
                Logger:GetFormattedTag(),
                Logger:ColorText(
                    "Cannot reduce the time. You do not have enough time remining."
                )
            )
            return
        end

        if isCharacterMode then
            PTACharSavedVars.totalTime = PTACharSavedVars.totalTime - timeToReduce
        else
            PTASavedVars.totalTime = PTASavedVars.totalTime - timeToReduce
        end

        print(
            Logger:GetFormattedTag(),
            Logger:ColorText("Play time allowance reduced.")
        )


    elseif commandVerb == "pause" then
        if isCharacterMode then
            PTACharSavedVars.isPaused = not PTACharSavedVars.isPaused
        else
            PTASavedVars.isPaused = not PTASavedVars.isPaused
        end

        -- Let user know what's the sitrep
        if PlayTimerAddon:IsTimerPaused() then
            print(Logger:GetFormattedTag(), Logger:ColorText("Timer paused"))
        else
            print(Logger:GetFormattedTag(), Logger:ColorText("Timer un-paused. The clock is ticking!"))
        end

    elseif commandVerb == "balance" then
        local timeStringRemaining = HelperFunc.SecondToTimeString(
            PlayTimerAddon:GetRemainingBalance(), " "
        )

        local timeStringElapsed = HelperFunc.SecondToTimeString(
            PlayTimerAddon:GetElapsedBalance(), " "
        )

        print(
            Logger:GetFormattedTag(),
            Logger:ColorText("You still have"),
            Logger:ColorText(timeStringRemaining, "green"),
            Logger:ColorText("to play. You have played for"),
            Logger:ColorText(timeStringElapsed, "green"),
            Logger:ColorText("already.")
        )

    elseif commandVerb == "mode" then
        if commandVerbParam ~= "account" and commandVerbParam ~= "character" then
            HelperFunc.ShowUsageForVerb(commandVerb)

            if commandVerbParam == "" then
                print(
                    Logger:GetFormattedTag(),
                    Logger:ColorText("Mode: ".. PTACharSavedVars.mode)
                )
            end

            return
        end

        local currentValue = PTACharSavedVars.mode
        if currentValue == commandVerbParam then
            print(
                Logger:GetFormattedTag(),
                Logger:ColorText("Timer mode is already set this way.")
            )
            return
        end

        if commandVerbParam == "character" then
            -- If there isn't time saved under PTACharSavedVars, inherit allocation
            -- from the account SavedVar
            if PTACharSavedVars.totalTime == 0 then
                PTACharSavedVars.totalTime = PTASavedVars.totalTime
                print(
                    Logger:GetFormattedTag(),
                    Logger:ColorText(
                        "Total time allowed copied from account-wide settings, as character time is not set yet."
                    )
                )
            end

            PTACharSavedVars.mode = "character" -- Flip the mode PTACharSavedVars
            print(
                Logger:GetFormattedTag(),
                Logger:ColorText(
                    "This character now has its own separate timer. Your other character timers remain unchanged."
                )
            )
        end

        if commandVerbParam == "account" then
            -- Flip the mode in Character SavedVars
            PTACharSavedVars.mode = "account"

            -- If account-wide allocation is exhausted, copy character-level allowance & tell the user
            if PTASavedVars.elapsedTime >= PTASavedVars.totalTime then
                print(
                    Logger:GetFormattedTag(),
                    Logger:ColorText(
                        "Account-level time allowance is already exhausted. Copying current allowance to account allowance and switching the mode to account tracking."
                    )
                )
                PTASavedVars.elapsedTime = PTACharSavedVars.elapsedTime
                PTASavedVars.totalTime = PTACharSavedVars.totalTime
            end

            print(
                Logger:GetFormattedTag(),
                Logger:ColorText("Switching back to account-level timer.")
            )
        end
    elseif commandVerb == "help" then
        HelperFunc.ShowHelp()
    elseif commandVerb == "alert" then
        print("ALERT")
    elseif commandVerb == "reset-timer" then
        if isCharacterMode then
            PTACharSavedVars.totalTime = 36000
            PTACharSavedVars.elapsedTime = 0
            print(
                Logger:GetFormattedTag(),
                Logger:ColorText("Character", "green"),
                Logger:ColorText("timer set to 10h, time spent playing reset back to 0.", "red")
            )
        else
            PTASavedVars.totalTime = 36000
            PTASavedVars.elapsedTime = 0
            print(
                Logger:GetFormattedTag(),
                Logger:ColorText("Account", "green"),
                Logger:ColorText("timer set to 10h, time spent playing reset back to 0.", "red")
            )
        end
    end

end


-- Addon initialization
function PlayTimerAddon:OnLoad()
    -- TL;DR: If some SavedVar/CharacterSavedVar doesn't have a value
    -- default is loaded.
    self:SafelyInitializeSavedVars()
    self.timerFrame:SetPoint("CENTER", UIParent, "CENTER")
    self:RegisterTimer()

    -- Initialize general color chat logger
    --self.Logger = PrintHelper:New("PlayTimer", {255, 255, 0})
end


-- Start a ticker to update time every second
function PlayTimerAddon:RegisterTimer()
    if self.ticker then
        self.ticker:Cancel()
    end

    self.ticker = C_Timer.NewTicker(1, function()
        PlayTimerAddon:UpdateAndDisplayTime()
    end)
end


-- Every saved var that is not recognized, is `nil`.
-- Since this was gradual development, I ended up with having SavedVars
-- but not having all the keys in them. Normally, the procedure would be
-- to check if the SavedVar is nil, then create empty table, and insert
-- defaults in the table. From that point onwards, it would never be 
-- overwritten by the client. But it's all over the place now, so I need a safe
-- way to make sure everything is there. 
function PlayTimerAddon:SafelyInitializeSavedVars()
    local PTASavedVarsDefaults = {
        totalTime = 36000,      -- Total play time in seconds
        elapsedTime = 0,        -- Elapsed time in seconds
        isPaused = false,       -- Timer will be running
        mode = "account",       -- Account-wide mode 
    }

    -- Account-wide SavedVars
    if PTASavedVars == nil then
        PTASavedVars = {}
    end

    if PTASavedVars.elapsedTime == nil then
        PTASavedVars.elapsedTime = PTASavedVarsDefaults.elapsedTime
    end

    if PTASavedVars.totalTime == nil then
        PTASavedVars.totalTime = PTASavedVarsDefaults.totalTime
    end

    if PTASavedVars.isPaused == nil then
        PTASavedVars.isPaused = PTASavedVarsDefaults.isPaused
    end

    if PTASavedVars.mode == nil then
        PTASavedVars.mode = PTASavedVarsDefaults.mode
    end

    -- Character-tied Savedvars
    if PTACharSavedVars == nil then
        PTACharSavedVars = {}
    end

    if PTACharSavedVars.elapsedTime == nil then
        PTACharSavedVars.elapsedTime = PTASavedVarsDefaults.elapsedTime
    end

    if PTACharSavedVars.totalTime == nil then
        PTACharSavedVars.totalTime = PTASavedVarsDefaults.totalTime
    end

    if PTACharSavedVars.isPaused == nil then
        PTACharSavedVars.isPaused = PTASavedVarsDefaults.isPaused
    end

    if PTACharSavedVars.mode == nil then
        PTACharSavedVars.mode = PTASavedVarsDefaults.mode
    end
end