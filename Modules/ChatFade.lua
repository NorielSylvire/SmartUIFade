------------------------------------------------------------
-- Chat Module
-- Smart fading for ElvUI chat panels and MerathilisUI ChatBar
------------------------------------------------------------

local Module = {}

SmartUIFade:RegisterModule("Chat", Module, {

    Enabled = true,

    FadeDelay = 10,
    FadeTime = 0.5,

    HiddenAlpha = 0,

})

------------------------------------------------------------
-- State
------------------------------------------------------------

local db

local updater

local frames = {}

local elapsedSinceActivity = 0

local mouseOver = false
local typing = false
local fading = false

------------------------------------------------------------
-- Chat Events
------------------------------------------------------------

local chatEvents = {

    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",

    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",

    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",

    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",

    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",

    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",

    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",

    "CHAT_MSG_CHANNEL",

    "CHAT_MSG_EMOTE",
    "CHAT_MSG_TEXT_EMOTE",

    "CHAT_MSG_SYSTEM",

    "CHAT_MSG_LOOT",
    "CHAT_MSG_MONEY",

}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function ForEachFrame(func)
    for _, frame in ipairs(frames) do
        if frame then
            func(frame)
        end
    end
end

------------------------------------------------------------

local function ShowPanels()
    ForEachFrame(function(frame)
        SmartUIFade:ShowFrame(frame)
    end)

    fading = false
    elapsedSinceActivity = 0
end

------------------------------------------------------------

local function HidePanels()
    if fading then
        return
    end

    fading = true

    ForEachFrame(function(frame)
        SmartUIFade:HideFrame(
            frame,
            db.FadeTime,
            db.HiddenAlpha
        )
    end)
end

------------------------------------------------------------

local function Activity()
    ShowPanels()
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------

function Module:Initialize()
    db = SmartUIFade:GetModuleDB("Chat")

    if not db.Enabled then
        return
    end

    --------------------------------------------------------
    -- Frames
    --------------------------------------------------------

    if _G.LeftChatPanel then
        table.insert(frames, _G.LeftChatPanel)
    end

    if _G.RightChatPanel then
        table.insert(frames, _G.RightChatPanel)
    end

    if _G.WTChatBar then
        table.insert(frames, _G.WTChatBar)
    end

    if #frames == 0 then
        SmartUIFade:Print("Chat: No supported frames found.")

        return
    end

    --------------------------------------------------------
    -- Mouseover
    --------------------------------------------------------

    ForEachFrame(function(frame)
        frame:EnableMouse(true)

        frame:HookScript("OnEnter", function()
            mouseOver = true
            Activity()
        end)

        frame:HookScript("OnLeave", function()
            mouseOver = false
            elapsedSinceActivity = 0
        end)
    end)

    --------------------------------------------------------
    -- Chat Edit Boxes
    --------------------------------------------------------

    for i = 1, NUM_CHAT_WINDOWS do
        local editBox = _G["ChatFrame" .. i .. "EditBox"]

        if editBox then
            editBox:HookScript("OnShow", function()
                typing = true
                Activity()
            end)

            editBox:HookScript("OnHide", function()
                typing = false
                elapsedSinceActivity = 0
            end)
        end
    end

    --------------------------------------------------------
    -- Chat Events
    --------------------------------------------------------

    local events = CreateFrame("Frame")

    for _, event in ipairs(chatEvents) do
        events:RegisterEvent(event)
    end

    events:SetScript("OnEvent", Activity)

    --------------------------------------------------------
    -- Update Loop
    --------------------------------------------------------

    updater = SmartUIFade:CreateUpdater(function(_, elapsed)
        if mouseOver then
            return
        end

        if typing then
            return
        end

        elapsedSinceActivity = elapsedSinceActivity + elapsed

        if elapsedSinceActivity >= db.FadeDelay then
            HidePanels()
        end
    end)

    --------------------------------------------------------

    ShowPanels()
end
