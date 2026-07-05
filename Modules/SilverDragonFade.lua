------------------------------------------------------------
-- SilverDragon History Module
-- Fades the history window unless:
--   • Mouse is over it
--   • A new rare/treasure is discovered
------------------------------------------------------------

local Module = {}

SmartUIFade:RegisterModule("SilverDragonHistory", Module, {

    Enabled = true,

    FadeTime = 0.5,
    HiddenAlpha = 0,

    AlertDuration = 15,

})

------------------------------------------------------------
-- State
------------------------------------------------------------

local db

local frame
local updater

local mouseOver = false
local visibleUntil = 0
local fading = false

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function ShowFrame()
    if not frame then
        return
    end

    SmartUIFade:ShowFrame(frame)

    fading = false
end

------------------------------------------------------------

local function HideFrame()
    if not frame then
        return
    end

    if fading then
        return
    end

    fading = true

    SmartUIFade:HideFrame(
        frame,
        db.FadeTime,
        db.HiddenAlpha
    )
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------

function Module:Initialize()
    db = SmartUIFade:GetModuleDB("SilverDragonHistory")

    if not db.Enabled then
        return
    end

    --------------------------------------------------------
    -- Find Frame
    --------------------------------------------------------

    frame = _G.SilverDragonHistoryFrame

    if not frame then
        SmartUIFade:Print("SilverDragonHistoryFrame not found.")

        return
    end

    --------------------------------------------------------
    -- Mouseover
    --------------------------------------------------------

    frame:HookScript("OnEnter", function()
        frame:EnableMouse(true)

        mouseOver = true
        ShowFrame()
    end)

    frame:HookScript("OnLeave", function()
        mouseOver = false
    end)

    --------------------------------------------------------
    -- Hook SilverDragon History
    --------------------------------------------------------

    local ok, history = pcall(function()
        return LibStub("AceAddon-3.0")
            :GetAddon("SilverDragon")
            :GetModule("History")
    end)

    if ok and history then
        hooksecurefunc(history, "AddData", function()
            visibleUntil = GetTime() + db.AlertDuration

            ShowFrame()
        end)
    else
        SmartUIFade:Print("Unable to hook SilverDragon History module.")
    end

    --------------------------------------------------------
    -- Update Loop
    --------------------------------------------------------

    updater = SmartUIFade:CreateUpdater(function()
        if mouseOver then
            ShowFrame()
            return
        end

        if GetTime() < visibleUntil then
            ShowFrame()
            return
        end

        HideFrame()
    end)

    --------------------------------------------------------
    -- Initial State
    --------------------------------------------------------

    HideFrame()
end
