------------------------------------------------------------
-- SmartUIFade
-- Configuration
------------------------------------------------------------

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local options = {
    type = "group",
    name = "SmartUIFade",
    childGroups = "tree",
    args = {}
}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function CreateModuleOptions(moduleName, defaults)
    local args = {}

    --------------------------------------------------------
    -- Enabled
    --------------------------------------------------------

    args.Enabled = {

        order = 1,

        type = "toggle",

        name = "Enable",

        get = function()
            local db = SmartUIFade:GetModuleDB(moduleName)
            return db.Enabled
        end,

        set = function(_, value)
            local db = SmartUIFade:GetModuleDB(moduleName)
            db.Enabled = value
        end,

    }

    --------------------------------------------------------
    -- Sliders
    --------------------------------------------------------

    local order = 10

    for key, value in pairs(defaults) do
        if key ~= "Enabled" and type(value) == "number" then
            args[key] = {

                order = order,

                type = "range",

                name = key,

                min = 0,

                max = (key == "FadeDelay" or key == "AlertDuration") and 30 or 1,

                step = 0.05,

                get = function()
                    local db = SmartUIFade:GetModuleDB(moduleName)
                    return db[key]
                end,

                set = function(_, value)
                    local db = SmartUIFade:GetModuleDB(moduleName)
                    db[key] = value
                end,

            }

            order = order + 1
        end
    end

    return {

        type = "group",

        name = moduleName,

        args = args,

    }
end

------------------------------------------------------------
-- Build Menu
------------------------------------------------------------

for moduleName, defaults in pairs(SmartUIFade:GetDefaults()) do
    options.args[moduleName] = CreateModuleOptions(
        moduleName,
        defaults
    )
end

------------------------------------------------------------
-- Register
------------------------------------------------------------

AceConfig:RegisterOptionsTable("SmartUIFade", options)

AceConfigDialog:AddToBlizOptions(
    "SmartUIFade",
    "SmartUIFade"
)
