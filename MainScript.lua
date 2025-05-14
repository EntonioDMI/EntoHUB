local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()
local Window = Library:CreateWindow("EntoHUB - Item Asylum", Vector2.new(492, 598), Enum.KeyCode.RightControl)

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
                    print("Module Loaded: " .. moduleName)
                elseif not successExec then
                    print("Module Exec Error: Error executing " .. moduleName .. ": " .. tostring(returnedTable))
                else
                    print("Module Error: " .. moduleName .. " did not return a table of functions.")
                end
            else
                print("Module Error: " .. moduleName .. " did not return a function from loadstring.")
            end
        elseif not successLoad then
            print("Loadstring Error: Error in loadstring for " .. moduleName .. ": " .. tostring(moduleContent))
        end
    elseif not success then
        print("HTTP Get Error: Failed to fetch " .. moduleName .. ": " .. tostring(moduleScript))
    else
        print("HTTP Get Error: Unexpected content for " .. moduleName .. ", type: " .. type(moduleScript))
    end
end

LoadModuleFile("Highlight")
LoadModuleFile("Aimbot")
LoadModuleFile("Hitbox")
LoadModuleFile("ESP")
LoadModuleFile("Misc")

local AimAssistantTab = Window:CreateTab("AIM ASSISTANT")
local AimAssistantSection = AimAssistantTab:CreateSector("Aim Assistant Controls", "left")
if LoadedModules.Aimbot then
    AimAssistantSection:AddToggle("Enabled", false, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetEnabled(v) end end)
    AimAssistantSection:AddToggle("TeamCheck", true, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetTeamCheck(v) end end)
    AimAssistantSection:AddToggle("Show FOV Circle", true, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetShowFOV(v) end end)
    AimAssistantSection:AddSlider("FOV Circle Size (px)", 50, 1000, 300, 10, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetFieldOfView(v) end end)
    AimAssistantSection:AddSlider("Lock-on Radius (px)", 10, 500, 150, 5, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetLockRadius(v) end end)
    AimAssistantSection:AddSlider("Smoothness", 1, 20, 5, 1, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetSmoothness(v) end end)
    AimAssistantSection:AddDropdown("Aim Part", {"Head", "Torso"}, "Head", true, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetAimPart(v) end end)
    AimAssistantSection:AddDropdown("Target Priority", {"Distance", "Crosshair"}, "Distance", true, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetTargetPriority(v) end end)
    AimAssistantSection:AddToggle("Movement Prediction", true, function(v) if LoadedModules.Aimbot then LoadedModules.Aimbot.SetPrediction(v) end end)
end

local HitboxExpanderTab = Window:CreateTab("HITBOX EXPANDER")
local HitboxExpanderSection = HitboxExpanderTab:CreateSector("Hitbox Controls", "left")
if LoadedModules.Hitbox then
    HitboxExpanderSection:AddToggle("Enabled", false, function(v) if LoadedModules.Hitbox then LoadedModules.Hitbox.SetEnabled(v) end end)
    HitboxExpanderSection:AddToggle("TeamCheck", true, function(v) if LoadedModules.Hitbox then LoadedModules.Hitbox.SetTeamCheck(v) end end)
    HitboxExpanderSection:AddDropdown("Hitbox Part", {"Head", "Torso"}, "Head", true, function(v) if LoadedModules.Hitbox then LoadedModules.Hitbox.SetTargetPart(v) end end)
    HitboxExpanderSection:AddSlider("Scale (x)", 1, 50, 5, 0.5, function(v) if LoadedModules.Hitbox then LoadedModules.Hitbox.SetScale(v) end end)
    local HitboxColorToggle = HitboxExpanderSection:AddToggle("Color (Hitbox)", true, function(isEnabled) end)
    HitboxColorToggle:AddColorpicker(Color3.fromRGB(255,0,0), function(v) if LoadedModules.Hitbox then LoadedModules.Hitbox.SetColor(v) end end)
    HitboxExpanderSection:AddSlider("Transparency", 0, 1, 0.7, 0.05, function(v) if LoadedModules.Hitbox then LoadedModules.Hitbox.SetTransparency(v) end end)
end

local PlayerChamsTab = Window:CreateTab("PLAYER CHAMS")
local PlayerChamsSection = PlayerChamsTab:CreateSector("Player Chams Controls", "left")
if LoadedModules.Highlight then
    PlayerChamsSection:AddToggle("Enabled", false, function(v) if LoadedModules.Highlight then LoadedModules.Highlight.SetEnabled(v) end end)
    PlayerChamsSection:AddToggle("TeamCheck", true, function(v) if LoadedModules.Highlight then LoadedModules.Highlight.SetTeamCheck(v) end end)
    PlayerChamsSection:AddToggle("Rainbow Mode", false, function(v) if LoadedModules.Highlight then LoadedModules.Highlight.SetRainbowMode(v) end end)
    PlayerChamsSection:AddSlider("Rainbow Speed (x)", 0.1, 5, 1, 0.1, function(v) if LoadedModules.Highlight then LoadedModules.Highlight.SetRainbowSpeed(v) end end)
    PlayerChamsSection:AddSlider("Transparency", 0, 1, 0.5, 0.05, function(v) if LoadedModules.Highlight then LoadedModules.Highlight.SetTransparency(v) end end)
    local HighlightColorToggle = PlayerChamsSection:AddToggle("Highlight Color", true, function(isEnabled) end)
    HighlightColorToggle:AddColorpicker(Color3.fromRGB(255,255,0), function(v) if LoadedModules.Highlight then LoadedModules.Highlight.SetColor(v) end end)
end

local ESPTab = Window:CreateTab("ESP")
local ESPSection = ESPTab:CreateSector("ESP Controls", "left")
if LoadedModules.ESP then
    ESPSection:AddToggle("Enabled", false, function(v) if LoadedModules.ESP then LoadedModules.ESP.SetEnabled(v) end end)
    ESPSection:AddToggle("Show Name", true, function(v) if LoadedModules.ESP then LoadedModules.ESP.SetShowName(v) end end)
    ESPSection:AddToggle("Show HP", true, function(v) if LoadedModules.ESP then LoadedModules.ESP.SetShowHP(v) end end)
    ESPSection:AddToggle("Show Weapon", true, function(v) if LoadedModules.ESP then LoadedModules.ESP.SetShowWeapon(v) end end)
    ESPSection:AddToggle("Show Distance", true, function(v) if LoadedModules.ESP then LoadedModules.ESP.SetShowDistance(v) end end)
    ESPSection:AddToggle("Show Bounding Box", true, function(v) if LoadedModules.ESP then LoadedModules.ESP.SetShowBoundingBox(v) end end)
end

local MiscTab = Window:CreateTab("MISC")
local MiscSection = MiscTab:CreateSector("Misc Controls", "left")
if LoadedModules.Misc then
    MiscSection:AddToggle("Emulate Gravity", false, function(v) if LoadedModules.Misc then LoadedModules.Misc.SetGravityEnabled(v) end end)
    MiscSection:AddSlider("Gravity Multiplier (x)", 0.1, 3, 1, 0.1, function(v) if LoadedModules.Misc then LoadedModules.Misc.SetGravityMultiplier(v) end end)
    MiscSection:AddToggle("Emulate Speed", false, function(v) if LoadedModules.Misc then LoadedModules.Misc.SetSpeedEnabled(v) end end)
    MiscSection:AddSlider("Speed Multiplier (x)", 0.5, 5, 1, 0.1, function(v) if LoadedModules.Misc then LoadedModules.Misc.SetSpeedMultiplier(v) end end)
    MiscSection:AddToggle("Emulate Jump", false, function(v) if LoadedModules.Misc then LoadedModules.Misc.SetJumpEnabled(v) end end)
    MiscSection:AddSlider("Jump Multiplier (x)", 0.5, 5, 1, 0.1, function(v) if LoadedModules.Misc then LoadedModules.Misc.SetJumpMultiplier(v) end end)
end

AimAssistantTab:CreateConfigSystem("right")

print("EntoHUB Initialized with new library")
