return function(tab)
    local ESP = {}

    local ESPEnabled = false
    local ShowHP = true
    local ShowWeapon = true
    local ShowDistance = true
    local ShowName = true
    local ShowBoundingBox = true

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local Debris = game:GetService("Debris")

    local espElements = {}

    local function CreateBillboardGui(player)
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "PlayerESP_" .. player.Name
        billboardGui.Adornee = character:FindFirstChild("HumanoidRootPart")
        billboardGui.Size = UDim2.new(0, 200, 0, 100)
        billboardGui.AlwaysOnTop = true
        billboardGui.StudsOffset = Vector3.new(0, 2, 0)
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
        hpBarBackground.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        hpBarBackground.BorderSizePixel = 0
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
        
        local boundingBox = Instance.new("BoxHandleAdornment")
        boundingBox.Name = "BoundingBox"
        boundingBox.Adornee = character
        boundingBox.Size = character:GetExtentsSize()
        boundingBox.Color3 = Color3.new(1,1,1)
        boundingBox.Transparency = 0.5
        boundingBox.AlwaysOnTop = true
        boundingBox.ZIndex = 0
        boundingBox.Parent = billboardGui

        return billboardGui
    end

    local function UpdateESP(player)
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
            if espElements[player] then
                espElements[player]:Destroy()
                espElements[player] = nil
            end
            return
        end

        if player == LocalPlayer then
             if espElements[player] then
                espElements[player]:Destroy()
                espElements[player] = nil
            end
            return
        end

        local billboardGui = espElements[player]
        if not billboardGui or not billboardGui.Parent then
            billboardGui = CreateBillboardGui(player)
            if not billboardGui then return end
            espElements[player] = billboardGui
        end

        billboardGui.Enabled = ESPEnabled
        if not ESPEnabled then return end

        local humanoid = character.Humanoid
        local mainFrame = billboardGui:FindFirstChild("MainFrame")
        if not mainFrame then return end

        local nameLabel = mainFrame:FindFirstChild("NameLabel")
        if nameLabel then
            nameLabel.Visible = ShowName
            if ShowName then nameLabel.Text = player.DisplayName end
        end

        local hpBarBackground = mainFrame:FindFirstChild("HPBarBackground")
        local hpBar = hpBarBackground and hpBarBackground:FindFirstChild("HPBar")
        if hpBar then
            hpBarBackground.Visible = ShowHP
            if ShowHP then
                local hpPercent = humanoid.Health / humanoid.MaxHealth
                hpBar.Size = UDim2.new(hpPercent, 0, 1, 0)
                if hpPercent > 0.6 then hpBar.BackgroundColor3 = Color3.new(0,1,0)
                elseif hpPercent > 0.3 then hpBar.BackgroundColor3 = Color3.new(1,1,0)
                else hpBar.BackgroundColor3 = Color3.new(1,0,0) end
            end
        end

        local distanceLabel = mainFrame:FindFirstChild("DistanceLabel")
        if distanceLabel then
            distanceLabel.Visible = ShowDistance
            if ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                distanceLabel.Text = string.format("%.1fm", distance)
            end
        end

        local weaponLabel = mainFrame:FindFirstChild("WeaponLabel")
        if weaponLabel then
            weaponLabel.Visible = ShowWeapon
            if ShowWeapon then
                local tool = character:FindFirstChildOfClass("Tool")
                weaponLabel.Text = tool and tool.Name or "Unarmed"
            end
        end
        
        local boundingBox = billboardGui:FindFirstChild("BoundingBox")
        if boundingBox then
            boundingBox.Visible = ShowBoundingBox
            if ShowBoundingBox then
                boundingBox.Size = character:GetExtentsSize() * Vector3.new(1.1, 1.05, 1.1) -- Slightly larger for visibility
                local teamColor = player.Team and player.Team.TeamColor.Color or Color3.new(1,1,1)
                boundingBox.Color3 = teamColor
            end
        end
    end

    local function ClearAllESP()
        for player, gui in pairs(espElements) do
            if gui then gui:Destroy() end
        end
        espElements = {}
    end

    tab:CreateToggle({
        Name = "Enabled",
        CurrentValue = ESPEnabled,
        Flag = "ESPEnabled",
        Callback = function(value)
            ESPEnabled = value
            if not value then
                ClearAllESP()
            else
                for _, p in ipairs(Players:GetPlayers()) do
                    UpdateESP(p)
                end
            end
        end
    })

    tab:CreateToggle({ Name = "Show Name", CurrentValue = ShowName, Flag = "ESPShowName", Callback = function(v) ShowName = v end })
    tab:CreateToggle({ Name = "Show HP", CurrentValue = ShowHP, Flag = "ESPShowHP", Callback = function(v) ShowHP = v end })
    tab:CreateToggle({ Name = "Show Weapon", CurrentValue = ShowWeapon, Flag = "ESPShowWeapon", Callback = function(v) ShowWeapon = v end })
    tab:CreateToggle({ Name = "Show Distance", CurrentValue = ShowDistance, Flag = "ESPShowDistance", Callback = function(v) ShowDistance = v end })
    tab:CreateToggle({ Name = "Show Bounding Box", CurrentValue = ShowBoundingBox, Flag = "ESPShowBoundingBox", Callback = function(v) ShowBoundingBox = v end })

    RunService.RenderStepped:Connect(function()
        if ESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                UpdateESP(player)
            end
        end
    end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if ESPEnabled then UpdateESP(player) end
        end)
        if player.Character and ESPEnabled then UpdateESP(player) end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if espElements[player] then
            espElements[player]:Destroy()
            espElements[player] = nil
        end
    end)

end
