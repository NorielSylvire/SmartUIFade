------------------------------------------------------------
-- SmartUIFade
-- Core API
------------------------------------------------------------

local ADDON_NAME = ...

local SmartUIFade = {}
_G.SmartUIFade = SmartUIFade

SmartUIFade.Version = "1.0.0"

SmartUIFade.Modules = {}
SmartUIFade.Defaults = {}

SmartUIFade.Events = CreateFrame("Frame")

------------------------------------------------------------
-- Utility
------------------------------------------------------------

local function CopyDefaults(src, dst)
    if type(src) ~= "table" then
        return src
    end

    if type(dst) ~= "table" then
        dst = {}
    end

    for key, value in pairs(src) do
        if type(value) == "table" then
            dst[key] = CopyDefaults(value, dst[key])
        elseif dst[key] == nil then
            dst[key] = value
        end
    end

    return dst
end

------------------------------------------------------------
-- Database API
------------------------------------------------------------

function SmartUIFade:GetDB()
    return SmartUIFadeDB
end

function SmartUIFade:GetModuleDB(moduleName)
    return SmartUIFadeDB[moduleName]
end

------------------------------------------------------------
-- Module Registration
------------------------------------------------------------

function SmartUIFade:RegisterModule(name, module, defaults)
    module.Name = name

    self.Modules[name] = module
    self.Defaults[name] = defaults or {}
end

function SmartUIFade:GetModule(name)
    return self.Modules[name]
end

------------------------------------------------------------
-- Frame Helpers
------------------------------------------------------------

function SmartUIFade:ShowFrame(frame)
    if not frame then
        return
    end

    UIFrameFadeRemoveFrame(frame)
    frame:SetAlpha(1)
end

function SmartUIFade:HideFrame(frame, fadeTime, alpha)
    if not frame then
        return
    end

    UIFrameFadeRemoveFrame(frame)

    UIFrameFadeOut(
        frame,
        fadeTime or 0.5,
        frame:GetAlpha(),
        alpha or 0
    )
end

------------------------------------------------------------
-- Updater Helper
------------------------------------------------------------

function SmartUIFade:CreateUpdater(onUpdate)
    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", onUpdate)

    return frame
end

------------------------------------------------------------
-- Event Helper
------------------------------------------------------------

function SmartUIFade:RegisterEvent(event)
    self.Events:RegisterEvent(event)
end

------------------------------------------------------------
-- Debug
------------------------------------------------------------

function SmartUIFade:Print(...)
    print("|cff66ccffSmartUIFade:|r", ...)
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------

SmartUIFade.Events:RegisterEvent("PLAYER_LOGIN")

SmartUIFade.Events:SetScript("OnEvent", function(_, event)
    if event ~= "PLAYER_LOGIN" then
        return
    end

    --------------------------------------------------------
    -- Saved Variables
    --------------------------------------------------------

    SmartUIFadeDB = SmartUIFadeDB or {}

    for moduleName, defaults in pairs(SmartUIFade.Defaults) do
        SmartUIFadeDB[moduleName] =
            CopyDefaults(defaults, SmartUIFadeDB[moduleName])
    end

    --------------------------------------------------------
    -- Initialize Modules
    --------------------------------------------------------

    for _, module in pairs(SmartUIFade.Modules) do
        if module.Initialize then
            module:Initialize()
        end
    end

    SmartUIFade:Print("Loaded v" .. SmartUIFade.Version)
end)

function SmartUIFade:GetModules()
    return self.Modules
end

function SmartUIFade:GetDefaults()
    return self.Defaults
end
