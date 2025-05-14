local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local FriendsManager = require(script.Parent:WaitForChild("FriendsManager"))
local VisualsModule = require(script.Parent:WaitForChild("Visuals"))()
local CombatModule = require(script.Parent:WaitForChild("Combat"))()
local MiscModule = require(script.Parent:WaitForChild("Misc"))()

local Window = library:CreateWindow({
    Name = "EntoHUB (Pepsi)",
    Themeable = {
        Info = "EntoHUB by Manus for User"
    }
})

local VisualsTab = Window:CreateTab({ Name = "Visuals" })
local CombatTab = Window:CreateTab({ Name = "Combat" })
local MiscTab = Window:CreateTab({ Name = "Misc" })
local FriendsTab = Window:CreateTab({ Name = "Friends" })


local ESPSection = VisualsTab:CreateSection({ Name = "ESP" })
ESPSection:AddToggle({ Name = "Enable ESP", Flag = "ESP_Enabled", Callback = function(value) VisualsModule.SetESPEnabled(value) end })
ESPSection:AddToggle({ Name = "Team Check", Value = true, Flag = "ESP_TeamCheck", Callback = function(value) VisualsModule.SetESPTeamCheck(value) end })
ESPSection:AddToggle({ Name = "Show Name", Value = true, Flag = "ESP_ShowName", Callback = function(value) VisualsModule.SetESPShowName(value) end })
ESPSection:AddToggle({ Name = "Show HP", Value = true, Flag = "ESP_ShowHP", Callback = function(value) VisualsModule.SetESPShowHP(value) end })
ESPSection:AddToggle({ Name = "Show Weapon", Value = true, Flag = "ESP_ShowWeapon", Callback = function(value) VisualsModule.SetESPShowWeapon(value) end })
ESPSection:AddToggle({ Name = "Show Distance", Value = true, Flag = "ESP_ShowDistance", Callback = function(value) VisualsModule.SetESPShowDistance(value) end })
ESPSection:AddToggle({ Name = "Show Bounding Box", Value = true, Flag = "ESP_ShowBoundingBox", Callback = function(value) VisualsModule.SetESPShowBoundingBox(value) end })

local ChamsSection = VisualsTab:CreateSection({ Name = "Chams (Highlight)" })
ChamsSection:AddToggle({ Name = "Enable Chams", Flag = "Chams_Enabled", Callback = function(value) VisualsModule.SetChamsEnabled(value) end })
ChamsSection:AddToggle({ Name = "Team Check", Value = true, Flag = "Chams_TeamCheck", Callback = function(value) VisualsModule.SetChamsTeamCheck(value) end })
ChamsSection:AddToggle({ Name = "Rainbow Mode", Flag = "Chams_RainbowMode", Callback = function(value) VisualsModule.SetChamsRainbowMode(value) end })
ChamsSection:AddSlider({ Name = "Rainbow Speed", Value = 1, Min = 1, Max = 10, Precise = 0, Flag = "Chams_RainbowSpeed", Callback = function(value) VisualsModule.SetChamsRainbowSpeed(value) end })

local chamsColorR, chamsColorG, chamsColorB = 255, 255, 0
local function updateChamsColor() VisualsModule.SetChamsColor(Color3.fromRGB(chamsColorR, chamsColorG, chamsColorB)) end
ChamsSection:AddSlider({ Name = "Chams Color R", Value = chamsColorR, Min = 0, Max = 255, Precise = 0, Flag = "Chams_ColorR", Callback = function(v) chamsColorR = v; updateChamsColor() end })
ChamsSection:AddSlider({ Name = "Chams Color G", Value = chamsColorG, Min = 0, Max = 255, Precise = 0, Flag = "Chams_ColorG", Callback = function(v) chamsColorG = v; updateChamsColor() end })
ChamsSection:AddSlider({ Name = "Chams Color B", Value = chamsColorB, Min = 0, Max = 255, Precise = 0, Flag = "Chams_ColorB", Callback = function(v) chamsColorB = v; updateChamsColor() end })
updateChamsColor()


local AimbotSection = CombatTab:CreateSection({ Name = "Aimbot" })
AimbotSection:AddToggle({ Name = "Enable Aimbot", Flag = "Aimbot_Enabled", Callback = function(value) CombatModule.SetAimbotEnabled(value) end })
AimbotSection:AddToggle({ Name = "Team Check", Value = true, Flag = "Aimbot_TeamCheck", Callback = function(value) CombatModule.SetAimbotTeamCheck(value) end })
AimbotSection:AddToggle({ Name = "Show FOV", Value = true, Flag = "Aimbot_ShowFOV", Callback = function(value) CombatModule.SetAimbotShowFOV(value) end })
AimbotSection:AddSlider({ Name = "FOV Size", Value = 300, Min = 50, Max = 500, Precise = 0, Flag = "Aimbot_FOVSize", Callback = function(value) CombatModule.SetAimbotFOVSize(value) end })
AimbotSection:AddSlider({ Name = "Aim Radius", Value = 150, Min = 10, Max = 300, Precise = 0, Flag = "Aimbot_Radius", Callback = function(value) CombatModule.SetAimbotRadius(value) end })
AimbotSection:AddSlider({ Name = "Smoothness", Value = 5, Min = 1, Max = 20, Precise = 0, Flag = "Aimbot_Smoothness", Callback = function(value) CombatModule.SetAimbotSmoothness(value) end })
AimbotSection:AddDropdown({ Name = "Aim Part", List = {"Head", "Torso"}, Value = "Head", Flag = "Aimbot_AimPart", Callback = function(value) CombatModule.SetAimbotAimPart(value) end })
AimbotSection:AddDropdown({ Name = "Target Priority", List = {"Distance", "Crosshair"}, Value = "Distance", Flag = "Aimbot_TargetPriority", Callback = function(value) CombatModule.SetAimbotTargetPriority(value) end })
AimbotSection:AddToggle({ Name = "Prediction", Value = true, Flag = "Aimbot_Prediction", Callback = function(value) CombatModule.SetAimbotPrediction(value) end })

local HitboxSection = CombatTab:CreateSection({ Name = "Hitbox" })
HitboxSection:AddToggle({ Name = "Enable Hitbox", Flag = "Hitbox_Enabled", Callback = function(value) CombatModule.SetHitboxEnabled(value) end })
HitboxSection:AddToggle({ Name = "Team Check", Value = true, Flag = "Hitbox_TeamCheck", Callback = function(value) CombatModule.SetHitboxTeamCheck(value) end })
HitboxSection:AddDropdown({ Name = "Hitbox Part", List = {"Head", "Body"}, Value = "Head", Flag = "Hitbox_Part", Callback = function(value) CombatModule.SetHitboxPart(value) end })
HitboxSection:AddSlider({ Name = "Scale", Value = 5, Min = 1, Max = 50, Precise = 0, Flag = "Hitbox_Scale", Callback = function(value) CombatModule.SetHitboxScale(value) end })

local hitboxColorR, hitboxColorG, hitboxColorB = 255, 0, 0
local function updateHitboxColor() CombatModule.SetHitboxColor(Color3.fromRGB(hitboxColorR, hitboxColorG, hitboxColorB)) end
HitboxSection:AddSlider({ Name = "Hitbox Color R", Value = hitboxColorR, Min = 0, Max = 255, Precise = 0, Flag = "Hitbox_ColorR", Callback = function(v) hitboxColorR = v; updateHitboxColor() end })
HitboxSection:AddSlider({ Name = "Hitbox Color G", Value = hitboxColorG, Min = 0, Max = 255, Precise = 0, Flag = "Hitbox_ColorG", Callback = function(v) hitboxColorG = v; updateHitboxColor() end })
HitboxSection:AddSlider({ Name = "Hitbox Color B", Value = hitboxColorB, Min = 0, Max = 255, Precise = 0, Flag = "Hitbox_ColorB", Callback = function(v) hitboxColorB = v; updateHitboxColor() end })
updateHitboxColor()

HitboxSection:AddSlider({ Name = "Transparency", Value = 0.5, Min = 0, Max = 1, Precise = 2, Flag = "Hitbox_Transparency", Callback = function(value) CombatModule.SetHitboxTransparency(value) end })


local MovementSection = MiscTab:CreateSection({ Name = "Movement" })
MovementSection:AddToggle({ Name = "Enable Gravity", Flag = "Misc_GravityEnabled", Callback = function(value) MiscModule.SetGravityEnabled(value) end })
MovementSection:AddSlider({ Name = "Gravity Multiplier", Value = 1, Min = 0.1, Max = 5, Precise = 1, Flag = "Misc_GravityMultiplier", Callback = function(value) MiscModule.SetGravityMultiplier(value) end })
MovementSection:AddToggle({ Name = "Enable Speed", Flag = "Misc_SpeedEnabled", Callback = function(value) MiscModule.SetSpeedEnabled(value) end })
MovementSection:AddSlider({ Name = "Speed Multiplier", Value = 1, Min = 1, Max = 10, Precise = 1, Flag = "Misc_SpeedMultiplier", Callback = function(value) MiscModule.SetSpeedMultiplier(value) end })
MovementSection:AddToggle({ Name = "Enable Jump", Flag = "Misc_JumpEnabled", Callback = function(value) MiscModule.SetJumpEnabled(value) end })
MovementSection:AddSlider({ Name = "Jump Multiplier", Value = 1, Min = 1, Max = 10, Precise = 1, Flag = "Misc_JumpMultiplier", Callback = function(value) MiscModule.SetJumpMultiplier(value) end })


local FriendsManageSection = FriendsTab:CreateSection({ Name = "Manage Friends" })
local PlayerNameCache = {}
local PlayerObjectCache = {}
local SelectedFriendTarget = nil

local function UpdatePlayerLists()
    PlayerNameCache = {}
    PlayerObjectCache = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(PlayerNameCache, player.Name .. " (" .. player.UserId .. ")")
            table.insert(PlayerObjectCache, player)
        end
    end
end

local CurrentFriendsLabel = FriendsManageSection:AddLabel({ Text = "Current Friends: None" })

local FriendsPlayerDropdown = FriendsManageSection:AddDropdown({
    Name = "Select Player",
    List = PlayerNameCache,
    Value = PlayerNameCache[1] or "No other players",
    Flag = "Friends_SelectedPlayer",
    Callback = function(selectedNameWithId)
        for i, nameWithId in ipairs(PlayerNameCache) do
            if nameWithId == selectedNameWithId then
                SelectedFriendTarget = PlayerObjectCache[i]
                return
            end
        end
        SelectedFriendTarget = nil
    end,
})

local function RefreshFriendsDisplayAndDropdown()
    UpdatePlayerLists()
    FriendsPlayerDropdown:UpdateList(PlayerNameCache)
    if #PlayerNameCache > 0 then
        if not table.find(PlayerNameCache, FriendsPlayerDropdown:Get()) then
             FriendsPlayerDropdown:Set(PlayerNameCache[1])
             SelectedFriendTarget = PlayerObjectCache[1]
        end
    else
        FriendsPlayerDropdown:Set("No other players")
        SelectedFriendTarget = nil
    end

    local friendIds = FriendsManager.GetFriends()
    local names = {}
    for _, idStr in ipairs(friendIds) do
        local p = Players:GetPlayerByUserId(tonumber(idStr))
        if p then table.insert(names, p.Name) end
    end
    CurrentFriendsLabel:Set("Current Friends: " .. (#names > 0 and table.concat(names, ", ") or "None"))
end

FriendsManageSection:AddButton({
    Name = "Add Selected as Friend",
    Callback = function()
        if SelectedFriendTarget and SelectedFriendTarget.UserId then
            FriendsManager.AddFriend(SelectedFriendTarget.UserId)
            RefreshFriendsDisplayAndDropdown()
        end
    end,
})

FriendsManageSection:AddButton({
    Name = "Remove Selected from Friends",
    Callback = function()
        if SelectedFriendTarget and SelectedFriendTarget.UserId then
            FriendsManager.RemoveFriend(SelectedFriendTarget.UserId)
            RefreshFriendsDisplayAndDropdown()
        end
    end,
})

FriendsManageSection:AddButton({ Name = "Clear All Friends", Callback = function() FriendsManager.ClearFriends(); RefreshFriendsDisplayAndDropdown() end })
FriendsManageSection:AddButton({ Name = "Refresh Lists", Callback = RefreshFriendsDisplayAndDropdown })

Players.PlayerAdded:Connect(RefreshFriendsDisplayAndDropdown)
Players.PlayerRemoving:Connect(RefreshFriendsDisplayAndDropdown)
RefreshFriendsDisplayAndDropdown()

Window:AddKeybind({ Name = "Toggle UI", Value = Enum.KeyCode.RightControl, Callback = function() Window:Toggle() end})

