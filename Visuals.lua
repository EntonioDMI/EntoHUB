local VisualsModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local FriendsManager = require(script.Parent:WaitForChild("FriendsManager"))

local espSettings = {
    Enabled = false,
    ShowName = true,
    ShowHP = true,
    ShowWeapon = true,
    ShowDistance = true,
    ShowBoundingBox = true,
    TeamCheck = true 
}

local chamsSettings = {
    Enabled = false,
    TeamCheck = true,
    RainbowMode = false,
    RainbowSpeed = 1,
    HighlightColor = Color3.fromRGB(255, 255, 0),
    FriendHighlightColor = Color3.fromRGB(0, 255, 0) 
}

local espElementsCache = {}
local chamsHighlightCache = {}

local function GetTeam(player)
    return player and player.Team
end


local function CreateESPGuiForPlayer(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "PlayerESP_Visuals_" .. player.Name
    billboardGui.Adornee = character:FindFirstChild("HumanoidRootPart")
    billboardGui.Size = UDim2.new(0, 200, 0, 120) 
    billboardGui.AlwaysOnTop = true
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.LightInfluence = 0
    billboardGui.Parent = character

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = billboardGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Parent = mainFrame

    local hpBarBackground = Instance.new("Frame")
    hpBarBackground.Name = "HPBarBackground"
    hpBarBackground.Size = UDim2.new(0.8, 0, 0, 8)
    hpBarBackground.Position = UDim2.new(0.1, 0, 0, 30)
    hpBarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hpBarBackground.BorderSizePixel = 1
    hpBarBackground.BorderColor3 = Color3.fromRGB(10,10,10)
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
    distanceLabel.Position = UDim2.new(0, 0, 0, 45)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    distanceLabel.TextStrokeTransparency = 0.4
    distanceLabel.Parent = mainFrame

    local weaponLabel = Instance.new("TextLabel")
    weaponLabel.Name = "WeaponLabel"
    weaponLabel.Size = UDim2.new(1, 0, 0, 15)
    weaponLabel.Position = UDim2.new(0, 0, 0, 65)
    weaponLabel.BackgroundTransparency = 1
    weaponLabel.TextScaled = true
    weaponLabel.Font = Enum.Font.Gotham
    weaponLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    weaponLabel.TextStrokeTransparency = 0.4
    weaponLabel.Parent = mainFrame
    
    local boundingBoxAdornment = Instance.new("BoxHandleAdornment")
    boundingBoxAdornment.Name = "BoundingBoxAdornment"
    boundingBoxAdornment.Adornee = character
    boundingBoxAdornment.Size = character:GetExtentsSize()
    boundingBoxAdornment.Color3 = Color3.new(1,1,1)
    boundingBoxAdornment.Transparency = 0.7 
    boundingBoxAdornment.AlwaysOnTop = true
    boundingBoxAdornment.ZIndex = 0 
    boundingBoxAdornment.Parent = billboardGui 

    return billboardGui
end

local function UpdateESPForPlayer(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        if espElementsCache[player] then espElementsCache[player]:Destroy(); espElementsCache[player] = nil; end
        return
    end

    if player == LocalPlayer or (espSettings.TeamCheck and GetTeam(player) == GetTeam(LocalPlayer) and not FriendsManager.IsFriend(player.UserId)) or (FriendsManager.IsFriend(player.UserId) and not chamsSettings.Enabled) then 
        if espElementsCache[player] then espElementsCache[player]:Destroy(); espElementsCache[player] = nil; end
        return
    end

    local billboardGui = espElementsCache[player]
    if not billboardGui or not billboardGui.Parent then
        billboardGui = CreateESPGuiForPlayer(player)
        if not billboardGui then return end
        espElementsCache[player] = billboardGui
    end

    billboardGui.Enabled = espSettings.Enabled and not FriendsManager.IsFriend(player.UserId)
    if not espSettings.Enabled and not (chamsSettings.Enabled and FriendsManager.IsFriend(player.UserId)) then 
        if billboardGui then billboardGui:Destroy(); espElementsCache[player] = nil; end
        return 
    end

    local humanoid = character.Humanoid
    local mainFrame = billboardGui:FindFirstChild("MainFrame")
    if not mainFrame then return end

    mainFrame.Visible = espSettings.Enabled and not FriendsManager.IsFriend(player.UserId)

    local nameLabel = mainFrame:FindFirstChild("NameLabel")
    if nameLabel then
        nameLabel.Visible = espSettings.ShowName
        if espSettings.ShowName then nameLabel.Text = player.DisplayName end
    end

    local hpBarBackground = mainFrame:FindFirstChild("HPBarBackground")
    local hpBar = hpBarBackground and hpBarBackground:FindFirstChild("HPBar")
    if hpBar then
        hpBarBackground.Visible = espSettings.ShowHP
        if espSettings.ShowHP then
            local hpPercent = humanoid.Health / humanoid.MaxHealth
            hpBar.Size = UDim2.new(hpPercent, 0, 1, 0)
            if hpPercent > 0.6 then hpBar.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            elseif hpPercent > 0.3 then hpBar.BackgroundColor3 = Color3.fromRGB(255, 255, 85)
            else hpBar.BackgroundColor3 = Color3.fromRGB(255, 85, 85) end
        end
    end

    local distanceLabel = mainFrame:FindFirstChild("DistanceLabel")
    if distanceLabel then
        distanceLabel.Visible = espSettings.ShowDistance
        if espSettings.ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            distanceLabel.Text = string.format("%.0fm", distance)
        end
    end

    local weaponLabel = mainFrame:FindFirstChild("WeaponLabel")
    if weaponLabel then
        weaponLabel.Visible = espSettings.ShowWeapon
        if espSettings.ShowWeapon then
            local tool = character:FindFirstChildOfClass("Tool")
            weaponLabel.Text = tool and tool.Name or "-"
        end
    end
    
    local boundingBoxAdornment = billboardGui:FindFirstChild("BoundingBoxAdornment")
    if boundingBoxAdornment then
        boundingBoxAdornment.Visible = espSettings.ShowBoundingBox and not FriendsManager.IsFriend(player.UserId)
        if boundingBoxAdornment.Visible then
            boundingBoxAdornment.Size = character:GetExtentsSize() * Vector3.new(1.1, 1.05, 1.1)
            local teamColor = player.Team and player.Team.TeamColor.Color or Color3.new(0.8,0.8,0.8)
            boundingBoxAdornment.Color3 = teamColor
        end
    end
end

local function UpdateChamsForPlayer(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        if chamsHighlightCache[player] then chamsHighlightCache[player]:Destroy(); chamsHighlightCache[player] = nil; end
        return
    end

    if player == LocalPlayer then
        if chamsHighlightCache[player] then chamsHighlightCache[player]:Destroy(); chamsHighlightCache[player] = nil; end
        return
    end

    local isFriend = FriendsManager.IsFriend(player.UserId)
    local isTeamMate = GetTeam(player) == GetTeam(LocalPlayer)

    if not chamsSettings.Enabled or (chamsSettings.TeamCheck and isTeamMate and not isFriend) then
        if chamsHighlightCache[player] then chamsHighlightCache[player]:Destroy(); chamsHighlightCache[player] = nil; end
        return
    end

    local highlight = chamsHighlightCache[player]
    if not highlight or not highlight.Parent then
        highlight = Instance.new("Highlight")
        highlight.Name = "PlayerChams_Visuals_" .. player.Name
        highlight.Parent = character
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        chamsHighlightCache[player] = highlight
    end

    highlight.Enabled = true
    highlight.FillTransparency = 0.6 
    highlight.OutlineTransparency = 0 

    if isFriend then
        local pulse = (math.sin(tick() * 5) + 1) / 2 
        highlight.FillColor = chamsSettings.FriendHighlightColor:Lerp(Color3.new(0.2,0.8,0.2), pulse) 
        highlight.OutlineColor = chamsSettings.FriendHighlightColor * 0.7
    elseif chamsSettings.RainbowMode then
        local hue = (tick() * chamsSettings.RainbowSpeed) % 1
        highlight.FillColor = Color3.fromHSV(hue, 1, 1)
        highlight.OutlineColor = Color3.fromHSV(hue, 1, 0.7)
    else
        highlight.FillColor = chamsSettings.HighlightColor
        highlight.OutlineColor = chamsSettings.HighlightColor * 0.7 
    end
end

local function ClearAllVisuals()
    for player, gui in pairs(espElementsCache) do if gui and gui.Parent then gui:Destroy() end end
    espElementsCache = {}
    for player, h in pairs(chamsHighlightCache) do if h and h.Parent then h:Destroy() end end
    chamsHighlightCache = {}
end

function VisualsModule.SetESPEnabled(value) espSettings.Enabled = value; if not value then ClearAllVisuals() end end
function VisualsModule.SetESPShowName(value) espSettings.ShowName = value end
function VisualsModule.SetESPShowHP(value) espSettings.ShowHP = value end
function VisualsModule.SetESPShowWeapon(value) espSettings.ShowWeapon = value end
function VisualsModule.SetESPShowDistance(value) espSettings.ShowDistance = value end
function VisualsModule.SetESPShowBoundingBox(value) espSettings.ShowBoundingBox = value end
function VisualsModule.SetESPTeamCheck(value) espSettings.TeamCheck = value end

function VisualsModule.SetChamsEnabled(value) chamsSettings.Enabled = value; if not value then ClearAllVisuals() end end
function VisualsModule.SetChamsTeamCheck(value) chamsSettings.TeamCheck = value end
function VisualsModule.SetChamsRainbowMode(value) chamsSettings.RainbowMode = value end
function VisualsModule.SetChamsRainbowSpeed(value) chamsSettings.RainbowSpeed = value end
function VisualsModule.SetChamsColor(value) chamsSettings.HighlightColor = value end

local function OnCharacterAdded(character)
    local player = Players:GetPlayerFromCharacter(character)
    if player then 
        if espSettings.Enabled then UpdateESPForPlayer(player) end
        if chamsSettings.Enabled then UpdateChamsForPlayer(player) end
    end
end

local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(OnCharacterAdded)
    if player.Character then OnCharacterAdded(player.Character) end
end

local function OnPlayerRemoving(player)
    if espElementsCache[player] then espElementsCache[player]:Destroy(); espElementsCache[player] = nil; end
    if chamsHighlightCache[player] then chamsHighlightCache[player]:Destroy(); chamsHighlightCache[player] = nil; end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do OnPlayerAdded(player) end
Players.PlayerRemoving:Connect(OnPlayerRemoving)

RunService.RenderStepped:Connect(function()
    if espSettings.Enabled or chamsSettings.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if espSettings.Enabled then UpdateESPForPlayer(player) end
            if chamsSettings.Enabled then UpdateChamsForPlayer(player) end
        end
    else
        if next(espElementsCache) or next(chamsHighlightCache) then ClearAllVisuals() end
    end
end)

return VisualsModule

