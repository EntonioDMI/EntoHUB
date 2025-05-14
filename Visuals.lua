return function(tabInstance, sharedContext)
    local uiLibrary = sharedContext.uiLibrary
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = game.Workspace.CurrentCamera

    local visualSettings = {
        highlightEnabled = false,
        highlightTeamColor = true,
        highlightTransparency = 0.5,
        highlightColor = Color3.fromRGB(255, 255, 0),
        highlightRainbowMode = false,
        highlightRainbowSpeed = 1,
        espEnabled = false,
        espShowHp = true,
        espShowWeapon = true,
        espShowDistance = true,
        espShowName = true,
        espShowBoundingBox = true
    }

    local highlights = {}
    local esps = {}

    local highlightSection = tabInstance:CreateSection({
        Name = "Highlight"
    })

    highlightSection:AddToggle({
        Name = "Enabled",
        Flag = "VisualsHighlight_Enabled",
        Callback = function(value)
            visualSettings.highlightEnabled = value
            if not value then
                for player, highlight in pairs(highlights) do
                    if highlight and highlight.Parent then highlight:Destroy() end
                end
                highlights = {}
            end
        end
    })

    highlightSection:AddToggle({
        Name = "Team Color",
        Flag = "VisualsHighlight_TeamColor",
        Default = true,
        Callback = function(value)
            visualSettings.highlightTeamColor = value
        end
    })

    highlightSection:AddSlider({
        Name = "Transparency",
        Flag = "VisualsHighlight_Transparency",
        Value = 0.5,
        Min = 0,
        Max = 1,
        Precise = 2,
        Callback = function(value)
            visualSettings.highlightTransparency = value
        end
    })

    highlightSection:AddColorpicker({
        Name = "Highlight Color",
        Flag = "VisualsHighlight_Color",
        Default = Color3.fromRGB(255, 255, 0),
        Callback = function(value)
            visualSettings.highlightColor = value
        end
    })

    highlightSection:AddToggle({
        Name = "Rainbow Mode",
        Flag = "VisualsHighlight_RainbowMode",
        Callback = function(value)
            visualSettings.highlightRainbowMode = value
        end
    })

    highlightSection:AddSlider({
        Name = "Rainbow Speed",
        Flag = "VisualsHighlight_RainbowSpeed",
        Value = 1,
        Min = 0.1,
        Max = 5,
        Precise = 1,
        Callback = function(value)
            visualSettings.highlightRainbowSpeed = value
        end
    })

    local espSection = tabInstance:CreateSection({
        Name = "ESP"
    })

    espSection:AddToggle({
        Name = "Enabled",
        Flag = "VisualsEsp_Enabled",
        Callback = function(value)
            visualSettings.espEnabled = value
            if not value then
                for player, espElements in pairs(esps) do
                    for _, element in pairs(espElements) do
                        if element and element.Parent then element:Destroy() end
                    end
                end
                esps = {}
            end
        end
    })

    espSection:AddToggle({ Name = "Show HP", Flag = "VisualsEsp_ShowHp", Default = true, Callback = function(v) visualSettings.espShowHp = v end })
    espSection:AddToggle({ Name = "Show Weapon", Flag = "VisualsEsp_ShowWeapon", Default = true, Callback = function(v) visualSettings.espShowWeapon = v end })
    espSection:AddToggle({ Name = "Show Distance", Flag = "VisualsEsp_ShowDistance", Default = true, Callback = function(v) visualSettings.espShowDistance = v end })
    espSection:AddToggle({ Name = "Show Name", Flag = "VisualsEsp_ShowName", Default = true, Callback = function(v) visualSettings.espShowName = v end })
    espSection:AddToggle({ Name = "Show Bounding Box", Flag = "VisualsEsp_ShowBoundingBox", Default = true, Callback = function(v) visualSettings.espShowBoundingBox = v end })

    local function createOrUpdateHighlight(player)
        if not player or not player.Character then return end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            if highlights[player] then
                highlights[player]:Destroy()
                highlights[player] = nil
            end
            return
        end

        if not highlights[player] or not highlights[player].Parent then
            local highlight = Instance.new("Highlight", player.Character)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 1 
            highlights[player] = highlight
        end

        local currentHighlight = highlights[player]
        currentHighlight.Enabled = true
        currentHighlight.OutlineTransparency = visualSettings.highlightTransparency

        if sharedContext:isFriend(player.UserId) then
            local timeVal = tick()
            local pulse = (math.sin(timeVal * 5) + 1) / 2 
            currentHighlight.OutlineColor = Color3.new(0, 0.8 + pulse * 0.2, 0) 
            currentHighlight.FillColor = Color3.new(0, 1, 0)
            currentHighlight.FillTransparency = 0.8 - (pulse * 0.3)
        elseif visualSettings.highlightRainbowMode then
            currentHighlight.OutlineColor = Color3.fromHSV(tick() * visualSettings.highlightRainbowSpeed % 1, 1, 1)
            currentHighlight.FillTransparency = 1
        elseif visualSettings.highlightTeamColor and player.TeamColor then
            currentHighlight.OutlineColor = player.TeamColor.Color
            currentHighlight.FillTransparency = 1
        else
            currentHighlight.OutlineColor = visualSettings.highlightColor
            currentHighlight.FillTransparency = 1
        end
    end

    local function createOrUpdateEsp(player)
        if not player or not player.Character then return end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")

        if not humanoid or humanoid.Health <= 0 or not hrp then
            if esps[player] then
                for _, element in pairs(esps[player]) do element:Destroy() end
                esps[player] = nil
            end
            return
        end

        if not esps[player] then esps[player] = {} end
        local playerEsp = esps[player]

        local isFriend = sharedContext:isFriend(player.UserId)
        local espColor = isFriend and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255,255,0)

        local headPosition = hrp.Position + Vector3.new(0, 2.5, 0)
        local screenPos, onScreen = Camera:WorldToScreenPoint(headPosition)

        if onScreen then
            local yOffset = 0

            if visualSettings.espShowName then
                if not playerEsp.nameLabel then
                    playerEsp.nameLabel = Drawing.new("Text")
                end
                playerEsp.nameLabel.Visible = true
                playerEsp.nameLabel.Text = player.Name
                playerEsp.nameLabel.Color = espColor
                playerEsp.nameLabel.Size = 14
                playerEsp.nameLabel.Center = true
                playerEsp.nameLabel.Outline = true
                playerEsp.nameLabel.Position = Vector2.new(screenPos.X, screenPos.Y + yOffset)
                yOffset = yOffset + 15
            elseif playerEsp.nameLabel then playerEsp.nameLabel.Visible = false end

            if visualSettings.espShowHp and not isFriend then
                if not playerEsp.hpLabel then
                    playerEsp.hpLabel = Drawing.new("Text")
                end
                playerEsp.hpLabel.Visible = true
                playerEsp.hpLabel.Text = "HP: " .. math.floor(humanoid.Health)
                playerEsp.hpLabel.Color = Color3.fromHSV(humanoid.Health / humanoid.MaxHealth * 0.33, 1, 1)
                playerEsp.hpLabel.Size = 12
                playerEsp.hpLabel.Center = true
                playerEsp.hpLabel.Outline = true
                playerEsp.hpLabel.Position = Vector2.new(screenPos.X, screenPos.Y + yOffset)
                yOffset = yOffset + 15
            elseif playerEsp.hpLabel then playerEsp.hpLabel.Visible = false end

            if visualSettings.espShowWeapon and not isFriend then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    if not playerEsp.weaponLabel then
                        playerEsp.weaponLabel = Drawing.new("Text")
                    end
                    playerEsp.weaponLabel.Visible = true
                    playerEsp.weaponLabel.Text = tool.Name
                    playerEsp.weaponLabel.Color = espColor
                    playerEsp.weaponLabel.Size = 12
                    playerEsp.weaponLabel.Center = true
                    playerEsp.weaponLabel.Outline = true
                    playerEsp.weaponLabel.Position = Vector2.new(screenPos.X, screenPos.Y + yOffset)
                    yOffset = yOffset + 15
                elseif playerEsp.weaponLabel then playerEsp.weaponLabel.Visible = false end
            elseif playerEsp.weaponLabel then playerEsp.weaponLabel.Visible = false end

            if visualSettings.espShowDistance then
                local localPlayer = Players.LocalPlayer
                if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (localPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if not playerEsp.distanceLabel then
                        playerEsp.distanceLabel = Drawing.new("Text")
                    end
                    playerEsp.distanceLabel.Visible = true
                    playerEsp.distanceLabel.Text = math.floor(distance) .. "m"
                    playerEsp.distanceLabel.Color = espColor
                    playerEsp.distanceLabel.Size = 12
                    playerEsp.distanceLabel.Center = true
                    playerEsp.distanceLabel.Outline = true
                    playerEsp.distanceLabel.Position = Vector2.new(screenPos.X, screenPos.Y + yOffset)
                    yOffset = yOffset + 15
                elseif playerEsp.distanceLabel then playerEsp.distanceLabel.Visible = false end
            elseif playerEsp.distanceLabel then playerEsp.distanceLabel.Visible = false end

            if visualSettings.espShowBoundingBox then
                local cframe = hrp.CFrame
                local size = player.Character:GetExtentsSize()
                local points = {
                    cframe * Vector3.new(size.X/2, size.Y/2, size.Z/2),
                    cframe * Vector3.new(size.X/2, size.Y/2, -size.Z/2),
                    cframe * Vector3.new(size.X/2, -size.Y/2, size.Z/2),
                    cframe * Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
                    cframe * Vector3.new(-size.X/2, size.Y/2, size.Z/2),
                    cframe * Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
                    cframe * Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
                    cframe * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2)
                }
                local screenPoints = {}
                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                local allOnScreen = true
                for _, point in ipairs(points) do
                    local sp, sop = Camera:WorldToScreenPoint(point)
                    if not sop then allOnScreen = false; break end
                    table.insert(screenPoints, Vector2.new(sp.X, sp.Y))
                    minX = math.min(minX, sp.X)
                    minY = math.min(minY, sp.Y)
                    maxX = math.max(maxX, sp.X)
                    maxY = math.max(maxY, sp.Y)
                end

                if allOnScreen then
                    if not playerEsp.boundingBox then playerEsp.boundingBox = {} end
                    local boxLines = {
                        {Vector2.new(minX, minY), Vector2.new(maxX, minY)}, 
                        {Vector2.new(minX, maxY), Vector2.new(maxX, maxY)}, 
                        {Vector2.new(minX, minY), Vector2.new(minX, maxY)}, 
                        {Vector2.new(maxX, minY), Vector2.new(maxX, maxY)}  
                    }
                    for i, linePoints in ipairs(boxLines) do
                        if not playerEsp.boundingBox[i] then
                            playerEsp.boundingBox[i] = Drawing.new("Line")
                        end
                        playerEsp.boundingBox[i].Visible = true
                        playerEsp.boundingBox[i].From = linePoints[1]
                        playerEsp.boundingBox[i].To = linePoints[2]
                        playerEsp.boundingBox[i].Color = espColor
                        playerEsp.boundingBox[i].Thickness = 1
                    end
                elseif playerEsp.boundingBox then
                    for _, line in pairs(playerEsp.boundingBox) do line.Visible = false end
                end
            elseif playerEsp.boundingBox then
                 for _, line in pairs(playerEsp.boundingBox) do line.Visible = false end
            end

        else 
            if esps[player] then
                for _, element in pairs(esps[player]) do element.Visible = false end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        local localPlayer = Players.LocalPlayer
        if not localPlayer then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                if visualSettings.highlightEnabled then
                    createOrUpdateHighlight(player)
                elseif highlights[player] then
                    highlights[player]:Destroy()
                    highlights[player] = nil
                end

                if visualSettings.espEnabled then
                    createOrUpdateEsp(player)
                elseif esps[player] then
                    for _, element in pairs(esps[player]) do element:Destroy() end
                    esps[player] = nil
                end
            else 
                if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
                if esps[player] then for _, e in pairs(esps[player]) do e:Destroy() end; esps[player] = nil end
            end
        end
    end)
end

