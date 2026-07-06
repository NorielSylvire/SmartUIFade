------------------------------------------------------------
-- Details! Meter Fade Module
-- Fades the damage meter unless:
--   • Player is in combat
--   • The hide delay has not yet passed since combat ended
--   • Mouse is over the frame
------------------------------------------------------------

local Module = {}

SmartUIFade:RegisterModule("DetailsMeter", Module, {
    Enabled = true,
    FadeTime = 0.5,
    HiddenAlpha = 0,
    HideDelay = 20,
})

------------------------------------------------------------
-- State
------------------------------------------------------------

local db
local updater
local eventTracker

local hideTime = 0
local isShown = true
local inCombat = false

-- We will store all the decoupled frames here
local framesToFade = {}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function ShowFrames()
    if not framesToFade[1] or isShown then return end
    isShown = true

    for _, f in ipairs(framesToFade) do
        SmartUIFade:ShowFrame(f)
    end
end

------------------------------------------------------------

local function HideFrames()
    if not framesToFade[1] or not isShown then return end
    isShown = false

    for _, f in ipairs(framesToFade) do
        SmartUIFade:HideFrame(
            f,
            db.FadeTime,
            db.HiddenAlpha
        )
    end
end

------------------------------------------------------------

local function IsAnyFrameMouseOver()
    for _, f in ipairs(framesToFade) do
        if f:IsMouseOver() then return true end
    end
    return false
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------

function Module:Initialize()
    db = SmartUIFade:GetModuleDB("DetailsMeter")

    if not db.Enabled then
        return
    end

    --------------------------------------------------------
    -- Find Frames (With Retry Logic)
    --------------------------------------------------------
    local Details = _G._detalhes

    if not Details then
        C_Timer.After(1, function() Module:Initialize() end)
        return
    end

    local instance = Details:GetInstance(1)

    if not instance or not instance.baseframe then
        C_Timer.After(1, function() Module:Initialize() end)
        return
    end

    -- Bundle all the decoupled containers that make up Details Window #1
    -- By animating rowframe directly, the bars and text will naturally fade.
    if instance.baseframe then table.insert(framesToFade, instance.baseframe) end
    if instance.rowframe then table.insert(framesToFade, instance.rowframe) end
    if instance.windowframe then table.insert(framesToFade, instance.windowframe) end

    --------------------------------------------------------
    -- Combat Event Tracking
    --------------------------------------------------------
    eventTracker = CreateFrame("Frame")
    eventTracker:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventTracker:RegisterEvent("PLAYER_REGEN_ENABLED")

    eventTracker:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            inCombat = true
            ShowFrames()
        elseif event == "PLAYER_REGEN_ENABLED" then
            inCombat = false
            hideTime = GetTime() + db.HideDelay
        end
    end)

    --------------------------------------------------------
    -- Update Loop
    --------------------------------------------------------
    updater = SmartUIFade:CreateUpdater(function()
        if inCombat then
            ShowFrames()
            return
        end

        if IsAnyFrameMouseOver() then
            ShowFrames()
            hideTime = GetTime() + 0.5
            return
        end

        if GetTime() < hideTime then
            ShowFrames()
            return
        end

        HideFrames()
    end)

    --------------------------------------------------------
    -- Initial State
    --------------------------------------------------------
    C_Timer.After(0.5, HideFrames)
end
