local ESPModule = {}

local ESPEnabled = false
local ShowHP_Value = true
local ShowWeapon_Value = true
local ShowDistance_Value = true
local ShowName_Value = true
local ShowBoundingBox_Value = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local espElementsCache = {}

local function CreateESPGuiForPlayer(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "PlayerESP_EntoHUB_" .. player.Name
    billboardGui.Adornee = character:FindFirstChild("HumanoidRootPart")
    billboardGui.Size = UDim2.new(0, 200, 0, 100) 
    billboardGui.AlwaysOnTop = true
    billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
    billboardGui.Parent = character 

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = billboardGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = mainFrame

    local hpBarBackground = Instance.new("Frame")
    hpBarBackground.Name = "HPBarBackground"
    hpBarBackground.Size = UDim2.new(1, 0, 0, 10)
    hpBarBackground.Position = UDim2.new(0, 0, 0, 25)
    hpBarBackground.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    hpBarBackground.BorderSizePixel = 1
    hpBarBackground.BorderColor3 = Color3.new(0,0,0)
    hpBarBackground.Parent = mainFrame

    local hpBar = Instance.new("Frame")
    hpBar.Name = "HPBar"
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.new(0, 1, 0)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpBarBackground

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0, 15)
    distanceLabel.Position = UDim2.new(0, 0, 0, 40)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.Parent = mainFrame

    local weaponLabel = Instance.new("TextLabel")
    weaponLabel.Name = "WeaponLabel"
    weaponLabel.Size = UDim2.new(1, 0, 0, 15)
    weaponLabel.Position = UDim2.new(0, 0, 0, 60)
    weaponLabel.BackgroundTransparency = 1
    weaponLabel.TextScaled = true
    weaponLabel.Font = Enum.Font.SourceSans
    weaponLabel.TextColor3 = Color3.new(1, 1, 1)
    weaponLabel.TextStrokeTransparency = 0.5
    weaponLabel.Parent = mainFrame
    
    local boundingBoxAdornment = Instance.new("BoxHandleAdornment")
    boundingBoxAdornment.Name = "BoundingBoxAdornment"
    boundingBoxAdornment.Adornee = character
    boundingBoxAdornment.Size = character:GetExtentsSize()
    boundingBoxAdornment.Color3 = Color3.new(1,1,1)
    boundingBoxAdornment.Transparency = 0.6
    boundingBoxAdornment.AlwaysOnTop = true
    boundingBoxAdornment.ZIndex = 0 
    boundingBoxAdornment.Parent = billboardGui

    return billboardGui
end

local function UpdateESPForPlayer(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        if espElementsCache[player] then
            espElementsCache[player]:Destroy()
            espElementsCache[player] = nil
        end
        return
    end

    if player == LocalPlayer then
         if espElementsCache[player] then
            espElementsCache[player]:Destroy()
            espElementsCache[player] = nil
        end
        return
    end

    local billboardGui = espElementsCache[player]
    if not billboardGui or not billboardGui.Parent then
        billboardGui = CreateESPGuiForPlayer(player)
        if not billboardGui then return end
        espElementsCache[player] = billboardGui
    end

    billboardGui.Enabled = ESPEnabled
    if not ESPEnabled then return end

    local humanoid = character.Humanoid
    local mainFrame = billboardGui:FindFirstChild("MainFrame")
    if not mainFrame then return end

    local nameLabel = mainFrame:FindFirstChild("NameLabel")
    if nameLabel then
        nameLabel.Visible = ShowName_Value
        if ShowName_Value then nameLabel.Text = player.DisplayName end
    end

    local hpBarBackground = mainFrame:FindFirstChild("HPBarBackground")
    local hpBar = hpBarBackground and hpBarBackground:FindFirstChild("HPBar")
    if hpBar then
        hpBarBackground.Visible = ShowHP_Value
        if ShowHP_Value then
            local hpPercent = humanoid.Health / humanoid.MaxHealth
            hpBar.Size = UDim2.new(hpPercent, 0, 1, 0)
            if hpPercent > 0.6 then hpBar.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            elseif hpPercent > 0.3 then hpBar.BackgroundColor3 = Color3.fromRGB(255, 255, 85)
            else hpBar.BackgroundColor3 = Color3.fromRGB(255, 85, 85) end
        end
    end

    local distanceLabel = mainFrame:FindFirstChild("DistanceLabel")
    if distanceLabel then
        distanceLabel.Visible = ShowDistance_Value
        if ShowDistance_Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            distanceLabel.Text = string.format("%.0fm", distance)
        end
    end

    local weaponLabel = mainFrame:FindFirstChild("WeaponLabel")
    if weaponLabel then
        weaponLabel.Visible = ShowWeapon_Value
        if ShowWeapon_Value then
            local tool = character:FindFirstChildOfClass("Tool")
            weaponLabel.Text = tool and tool.Name or "-"
        end
    end
    
    local boundingBoxAdornment = billboardGui:FindFirstChild("BoundingBoxAdornment")
    if boundingBoxAdornment then
        boundingBoxAdornment.Visible = ShowBoundingBox_Value
        if ShowBoundingBox_Value then
            boundingBoxAdornment.Size = character:GetExtentsSize() * Vector3.new(1.1, 1.05, 1.1)
            local teamColor = player.Team and player.Team.TeamColor.Color or Color3.new(0.8,0.8,0.8)
            boundingBoxAdornment.Color3 = teamColor
        end
    end
end

local function ClearAllESPElements()
    for player, gui in pairs(espElementsCache) do
        if gui and gui.Parent then gui:Destroy() end
    end
    espElementsCache = {}
end

function ESPModule.SetEnabled(value)
    ESPEnabled = value
    if not value then
        ClearAllESPElements()
    else
        for _, p in ipairs(Players:GetPlayers()) do
            UpdateESPForPlayer(p)
        end
    end
end

function ESPModule.SetShowName(value) ShowName_Value = value end
function ESPModule.SetShowHP(value) ShowHP_Value = value end
function ESPModule.SetShowWeapon(value) ShowWeapon_Value = value end
function ESPModule.SetShowDistance(value) ShowDistance_Value = value end
function ESPModule.SetShowBoundingBox(value) ShowBoundingBox_Value = value end

local function OnCharacterAdded(character)
    local player = Players:GetPlayerFromCharacter(character)
    if player and ESPEnabled then UpdateESPForPlayer(player) end
end

local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(OnCharacterAdded)
    if player.Character and ESPEnabled then UpdateESPForPlayer(player) end
end

local function OnPlayerRemoving(player)
    if espElementsCache[player] then
        espElementsCache[player]:Destroy()
        espElementsCache[player] = nil
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
   OnPlayerAdded(player)
end
Players.PlayerRemoving:Connect(OnPlayerRemoving)

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            UpdateESPForPlayer(player)
        end
    else
        if next(espElementsCache) then ClearAllESPElements() end
    end
end)

return ESPModule
