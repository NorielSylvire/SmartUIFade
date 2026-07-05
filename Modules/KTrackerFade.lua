------------------------------------------------------------
-- Kaliel's Tracker Module
------------------------------------------------------------

local Module = {}

SmartUIFade:RegisterModule("KalielsTracker", Module, {

    Enabled = true,

    FadeDelay = 5,
    FadeTime = 0.5,
    HiddenAlpha = 0,

})

------------------------------------------------------------
-- State
------------------------------------------------------------

local db

local frames = {}
local updater

local mouseOver = false
local inCombat = false
local elapsedSinceVisible = 0

-- Variables for custom alpha fading
local currentAlpha = 1
local targetAlpha = 1

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function ShowTracker()
    targetAlpha = 1
    elapsedSinceVisible = 0
end

------------------------------------------------------------

local function HideTracker()
    targetAlpha = db.HiddenAlpha
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------

function Module:Initialize()
    db = SmartUIFade:GetModuleDB("KalielsTracker")

    if not db.Enabled then
        return
    end

    --------------------------------------------------------
    -- Tracker Frames
    --------------------------------------------------------

    local frameNames = {
        "!KalielsTrackerFrame",
        "!KalielsTrackerBackground",
        "KT_QuestObjectiveTracker",
        "KT_AchievementObjectiveTracker",
        "KT_CampaignQuestObjectiveTracker",
        "KT_WorldQuestObjectiveTracker",
        "KT_MonthlyActivitiesObjectiveTracker",
        "KT_ProfessionsRecipeTracker",
        "KT_BonusRollObjectiveTracker",
        "KT_UIWidgetObjectiveTracker",
        "KT_BonusObjectiveTracker",    -- Covers Events / Bonus Objectives
        "KT_ScenarioObjectiveTracker", -- Covers Scenarios / World Assaults
        "KT_EventObjectiveTracker"     -- Fallback for customized events
    }

    for _, name in ipairs(frameNames) do
        local f = _G[name]
        if f then
            table.insert(frames, f)

            -- Catch ElvUI backdrops
            if f.backdrop then
                table.insert(frames, f.backdrop)
            end
        end
    end

    if #frames == 0 then
        SmartUIFade:Print("Kaliel's Tracker frames not found.")
        return
    end

    --------------------------------------------------------
    -- Mouse
    --------------------------------------------------------

    for _, frame in ipairs(frames) do
        local frameName = frame:GetName() or ""

        if not string.match(frameName, "Background") and not frame.IsBackdrop then
            frame:EnableMouse(true)
        end

        frame:HookScript("OnEnter", function()
            mouseOver = true
            ShowTracker()
        end)

        frame:HookScript("OnLeave", function()
            mouseOver = false
            elapsedSinceVisible = 0
        end)
    end

    --------------------------------------------------------
    -- Combat
    --------------------------------------------------------

    local events = CreateFrame("Frame")

    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")

    events:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            inCombat = true
            ShowTracker()
        else
            inCombat = false
            elapsedSinceVisible = 0
        end
    end)

    --------------------------------------------------------
    -- Update Loop with Custom Alpha Fading
    --------------------------------------------------------

    updater = SmartUIFade:CreateUpdater(function(_, elapsed)
        -- Smoothly transition alpha without calling Show()/Hide()
        if currentAlpha ~= targetAlpha then
            local step = (1 / db.FadeTime) * elapsed

            if currentAlpha < targetAlpha then
                currentAlpha = math.min(currentAlpha + step, targetAlpha)
            else
                currentAlpha = math.max(currentAlpha - step, targetAlpha)
            end

            for _, frame in ipairs(frames) do
                frame:SetAlpha(currentAlpha)
            end
        end

        if InCombatLockdown() then
            ShowTracker()
            return
        end

        if mouseOver then
            ShowTracker()
            return
        end

        elapsedSinceVisible = elapsedSinceVisible + elapsed

        if elapsedSinceVisible >= db.FadeDelay then
            HideTracker()
        end
    end)

    --------------------------------------------------------
    -- Initial State
    --------------------------------------------------------

    if InCombatLockdown() then
        ShowTracker()
    else
        elapsedSinceVisible = 0
        ShowTracker()
    end
end
