-- MainScript.lua

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))() -- Updated URL

local Window = Rayfield:CreateWindow({
    Name = "EntoHUB - Item Asylum",
    LoadingTitle = "EntoHUB Loading Sequence",
    LoadingSubtitle = "by EntonioDMI & Manus",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EntoHUB_IA_Config", -- Custom folder name
        FileName = "EntoHUB_Settings" -- Custom file name
    },
    Discord = {
        Enabled = false,
        Invite = "", -- Discord invite code (no https://discord.gg/)
        RememberJoins = true
    },
    KeySystem = false, -- Set to true to use the KeySystem
    KeySettings = {
        Title = "EntoHUB Key System",
        Subtitle = "Key System by EntonioDMI",
        Note = "Join the discord for the key!", -- Shown when the key is invalid
        FileName = "EntoKey", -- Name of the file to save the key to
        SaveKey = true, -- Whether to save the key
        Key = "" -- The key to use
    }
})

-- Tab Creation
-- Using placeholder rbxassetid://0 for icons as no specific icons were requested.
-- Rayfield also supports Lucide icons by string name e.g. "home", "settings"
local AimAssistantTab = Window:CreateTab("AIM ASSISTANT", "rbxassetid://0") 
local HitboxExpanderTab = Window:CreateTab("HITBOX EXPANDER", "rbxassetid://0")
local PlayerChamsTab = Window:CreateTab("PLAYER CHAMS", "rbxassetid://0") -- Corresponds to Highlight.lua
local ESPTab = Window:CreateTab("ESP", "rbxassetid://0")
local MiscTab = Window:CreateTab("MISC", "rbxassetid://0")

-- Module Loading Section
local baseURL = "https://raw.githubusercontent.com/EntonioDMI/EntoHUB/refs/heads/main/"

local function LoadModule(moduleName, tabObject)
    local url = baseURL .. moduleName .. ".lua"
    local success, moduleScript = pcall(function()
        return game:HttpGet(url, true) -- Using true for caching policy as per original script
    end)

    if success and moduleScript and type(moduleScript) == "string" then
        local successLoad, moduleFunction = pcall(loadstring(moduleScript))
        if successLoad and type(moduleFunction) == "function" then
            local successInit, err = pcall(function()
                moduleFunction(tabObject) -- Pass the tab to the module to populate its UI
            end)
            if not successInit then
                Rayfield:Notify("Module Init Error", "Failed to initialize " .. moduleName .. ": " .. tostring(err), 7, "rbxassetid://4483361413")
            else
                Rayfield:Notify("Module Loaded", moduleName .. " loaded and initialized.", 5, "rbxassetid://4483361413")
            end
        elseif not successLoad then
             Rayfield:Notify("Loadstring Error", "Error in loadstring for " .. moduleName .. ": " .. tostring(moduleFunction), 7, "rbxassetid://4483361413")
        else
            Rayfield:Notify("Module Load Error", "Script for " .. moduleName .. " did not return a function.", 7, "rbxassetid://4483361413")
        end
    elseif not success then
        Rayfield:Notify("HTTP Get Error", "Failed to fetch " .. moduleName .. " from " .. url .. ": " .. tostring(moduleScript), 7, "rbxassetid://4483361413")
    elseif type(moduleScript) ~= "string" then
        Rayfield:Notify("HTTP Get Error", "Unexpected content received for " .. moduleName .. ". Expected string, got " .. type(moduleScript), 7, "rbxassetid://4483361413")
    end
end

-- Load modules into their respective tabs
LoadModule("Aimbot", AimAssistantTab)
LoadModule("Hitbox", HitboxExpanderTab)
LoadModule("Highlight", PlayerChamsTab)
LoadModule("ESP", ESPTab)
LoadModule("Misc", MiscTab)

Rayfield:Notify(
    "EntoHUB Initialized",
    "Main UI created. Attempting to load modules.",
    5,
    "rbxassetid://4483361413"
)

-- Load saved configuration for UI elements (must be at the bottom)
Rayfield:LoadConfiguration()
