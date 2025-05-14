local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "EntoHUB - Item Asylum",
    LoadingTitle = "EntoHUB Loading Sequence",
    LoadingSubtitle = "by EntonioDMI & Manus",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EntoHUB_IA_Config",
        FileName = "EntoHUB_Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "EntoHUB Key System",
        Subtitle = "Key System by EntonioDMI",
        Note = "Join the discord for the key!",
        FileName = "EntoKey",
        SaveKey = true,
        Key = ""
    }
})

local LoadedModules = {}
local baseURL = "https://raw.githubusercontent.com/EntonioDMI/EntoHUB/refs/heads/main/"

local function LoadModuleFile(moduleName)
    local url = baseURL .. moduleName .. ".lua"
    local success, moduleScript = pcall(function()
        return game:HttpGet(url, true)
    end)

    if success and moduleScript and type(moduleScript) == "string" then
        local successLoad, moduleContent = pcall(loadstring(moduleScript))
        if successLoad then
            if type(moduleContent) == "function" then
                local successExec, returnedTable = pcall(moduleContent)
                if successExec and type(returnedTable) == "table" then
                    LoadedModules[moduleName] = returnedTable
                    Rayfield:Notify("Module Loaded", moduleName .. " logic loaded.", 3, "rbxassetid://4483361413")
                elseif not successExec then
                     Rayfield:Notify("Module Exec Error", "Error executing " .. moduleName .. ": " .. tostring(returnedTable), 7, "rbxassetid://4483361413")
                else
                    Rayfield:Notify("Module Error", moduleName .. " did not return a table of functions.", 7, "rbxassetid://4483361413")
                end
            else
                 Rayfield:Notify("Module Error", moduleName .. " did not return a function from loadstring.", 7, "rbxassetid://4483361413")
            end
        elseif not successLoad then
            Rayfield:Notify("Loadstring Error", "Error in loadstring for " .. moduleName .. ": " .. tostring(moduleContent), 7, "rbxassetid://4483361413")
        end
    elseif not success then
        Rayfield:Notify("HTTP Get Error", "Failed to fetch " .. moduleName .. ": " .. tostring(moduleScript), 7, "rbxassetid://4483361413")
    else
        Rayfield:Notify("HTTP Get Error", "Unexpected content for " .. moduleName .. ", type: " .. type(moduleScript), 7, "rbxassetid://4483361413")
    end
end

LoadModuleFile("Highlight")
LoadModuleFile("Aimbot")
LoadModuleFile("Hitbox")
LoadModuleFile("ESP")
LoadModuleFile("Misc")

local AimAssistantTab = Window:CreateTab("AIM ASSISTANT", "target")
if LoadedModules.Aimbot then
    AimAssistantTab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "AimbotEnabled_Main", Callback = function(v) LoadedModules.Aimbot.SetEnabled(v) end })
    AimAssistantTab:CreateToggle({ Name = "TeamCheck", CurrentValue = true, Flag = "AimbotTeamCheck_Main", Callback = function(v) LoadedModules.Aimbot.SetTeamCheck(v) end })
    AimAssistantTab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = true, Flag = "AimbotShowFOV_Main", Callback = function(v) LoadedModules.Aimbot.SetShowFOV(v) end })
    AimAssistantTab:CreateSlider({ Name = "FOV Circle Size", Range = {50, 1000}, Increment = 10, Suffix = "px", CurrentValue = 300, Flag = "AimbotFieldOfView_Main", Callback = function(v) LoadedModules.Aimbot.SetFieldOfView(v) end })
    AimAssistantTab:CreateSlider({ Name = "Lock-on Radius", Range = {10, 500}, Increment = 5, Suffix = "px", CurrentValue = 150, Flag = "AimbotLockRadius_Main", Callback = function(v) LoadedModules.Aimbot.SetLockRadius(v) end })
    AimAssistantTab:CreateSlider({ Name = "Smoothness", Range = {1, 20}, Increment = 1, Suffix = "", CurrentValue = 5, Flag = "AimbotSmoothness_Main", Callback = function(v) LoadedModules.Aimbot.SetSmoothness(v) end })
    AimAssistantTab:CreateDropdown({ Name = "Aim Part", Options = {"Head", "Torso"}, CurrentValue = "Head", Flag = "AimbotAimPart_Main", Callback = function(v) LoadedModules.Aimbot.SetAimPart(v) end })
    AimAssistantTab:CreateDropdown({ Name = "Target Priority", Options = {"Distance", "Crosshair"}, CurrentValue = "Distance", Flag = "AimbotTargetPriority_Main", Callback = function(v) LoadedModules.Aimbot.SetTargetPriority(v) end })
    AimAssistantTab:CreateToggle({ Name = "Movement Prediction", CurrentValue = true, Flag = "AimbotPrediction_Main", Callback = function(v) LoadedModules.Aimbot.SetPrediction(v) end })
end

local HitboxExpanderTab = Window:CreateTab("HITBOX EXPANDER", "box-select")
if LoadedModules.Hitbox then
    HitboxExpanderTab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "HitboxEnabled_Main", Callback = function(v) LoadedModules.Hitbox.SetEnabled(v) end })
    HitboxExpanderTab:CreateToggle({ Name = "TeamCheck", CurrentValue = true, Flag = "HitboxTeamCheck_Main", Callback = function(v) LoadedModules.Hitbox.SetTeamCheck(v) end })
    HitboxExpanderTab:CreateDropdown({ Name = "Hitbox Part", Options = {"Head", "Torso"}, CurrentValue = "Head", Flag = "HitboxTargetPart_Main", Callback = function(v) LoadedModules.Hitbox.SetTargetPart(v) end })
    HitboxExpanderTab:CreateSlider({ Name = "Scale", Range = {1, 50}, Increment = 0.5, Suffix = "x", CurrentValue = 5, Flag = "HitboxScale_Main", Callback = function(v) LoadedModules.Hitbox.SetScale(v) end })
    HitboxExpanderTab:CreateColorPicker({ Name = "Color", Color = Color3.fromRGB(255,0,0), Flag = "HitboxColor_Main", Callback = function(v) LoadedModules.Hitbox.SetColor(v) end })
    HitboxExpanderTab:CreateSlider({ Name = "Transparency", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = 0.7, Flag = "HitboxTransparency_Main", Callback = function(v) LoadedModules.Hitbox.SetTransparency(v) end })
end

local PlayerChamsTab = Window:CreateTab("PLAYER CHAMS", "user-round-search")
if LoadedModules.Highlight then
    PlayerChamsTab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "HighlightEnabled_Main", Callback = function(v) LoadedModules.Highlight.SetEnabled(v) end })
    PlayerChamsTab:CreateToggle({ Name = "TeamCheck", CurrentValue = true, Flag = "HighlightTeamCheck_Main", Callback = function(v) LoadedModules.Highlight.SetTeamCheck(v) end })
    PlayerChamsTab:CreateToggle({ Name = "Rainbow Mode", CurrentValue = false, Flag = "HighlightRainbowMode_Main", Callback = function(v) LoadedModules.Highlight.SetRainbowMode(v) end })
    PlayerChamsTab:CreateSlider({ Name = "Rainbow Speed", Range = {0.1, 5}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Flag = "HighlightRainbowSpeed_Main", Callback = function(v) LoadedModules.Highlight.SetRainbowSpeed(v) end })
    PlayerChamsTab:CreateSlider({ Name = "Transparency", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = 0.5, Flag = "HighlightTransparency_Main", Callback = function(v) LoadedModules.Highlight.SetTransparency(v) end })
    PlayerChamsTab:CreateColorPicker({ Name = "Highlight Color", Color = Color3.fromRGB(255,255,0), Flag = "HighlightColor_Main", Callback = function(v) LoadedModules.Highlight.SetColor(v) end })
end

local ESPTab = Window:CreateTab("ESP", "eye")
if LoadedModules.ESP then
    ESPTab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "ESPEnabled_Main", Callback = function(v) LoadedModules.ESP.SetEnabled(v) end })
    ESPTab:CreateToggle({ Name = "Show Name", CurrentValue = true, Flag = "ESPShowName_Main", Callback = function(v) LoadedModules.ESP.SetShowName(v) end })
    ESPTab:CreateToggle({ Name = "Show HP", CurrentValue = true, Flag = "ESPShowHP_Main", Callback = function(v) LoadedModules.ESP.SetShowHP(v) end })
    ESPTab:CreateToggle({ Name = "Show Weapon", CurrentValue = true, Flag = "ESPShowWeapon_Main", Callback = function(v) LoadedModules.ESP.SetShowWeapon(v) end })
    ESPTab:CreateToggle({ Name = "Show Distance", CurrentValue = true, Flag = "ESPShowDistance_Main", Callback = function(v) LoadedModules.ESP.SetShowDistance(v) end })
    ESPTab:CreateToggle({ Name = "Show Bounding Box", CurrentValue = true, Flag = "ESPShowBoundingBox_Main", Callback = function(v) LoadedModules.ESP.SetShowBoundingBox(v) end })
end

local MiscTab = Window:CreateTab("MISC", "toy-brick")
if LoadedModules.Misc then
    MiscTab:CreateToggle({ Name = "Emulate Gravity", CurrentValue = false, Flag = "MiscGravityEnabled_Main", Callback = function(v) LoadedModules.Misc.SetGravityEnabled(v) end })
    MiscTab:CreateSlider({ Name = "Gravity Multiplier", Range = {0.1, 3}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Flag = "MiscGravityMultiplier_Main", Callback = function(v) LoadedModules.Misc.SetGravityMultiplier(v) end })
    MiscTab:CreateToggle({ Name = "Emulate Speed", CurrentValue = false, Flag = "MiscSpeedEnabled_Main", Callback = function(v) LoadedModules.Misc.SetSpeedEnabled(v) end })
    MiscTab:CreateSlider({ Name = "Speed Multiplier", Range = {0.5, 5}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Flag = "MiscSpeedMultiplier_Main", Callback = function(v) LoadedModules.Misc.SetSpeedMultiplier(v) end })
    MiscTab:CreateToggle({ Name = "Emulate Jump", CurrentValue = false, Flag = "MiscJumpEnabled_Main", Callback = function(v) LoadedModules.Misc.SetJumpEnabled(v) end })
    MiscTab:CreateSlider({ Name = "Jump Multiplier", Range = {0.5, 5}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Flag = "MiscJumpMultiplier_Main", Callback = function(v) LoadedModules.Misc.SetJumpMultiplier(v) end })
end

Rayfield:Notify(
    "EntoHUB Initialized",
    "UI created. Attempting to load module logic.",
    5,
    "rbxassetid://4483361413"
)

Rayfield:LoadConfiguration()
