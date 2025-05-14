return function(tab)
    local Hitbox = {}

    local HitboxEnabled = false
    local TeamCheckEnabled = true
    local HitboxTargetPart = "Head"
    local HitboxScale = 5
    local HitboxColor = Color3.fromRGB(255, 0, 0)
    local HitboxTransparency = 0.7

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local Debris = game:GetService("Debris")

    local originalProperties = {}

    local function GetTeamColor(player)
        if player and player.Team then
            return player.Team.TeamColor.Color
        end
        return nil
    end

    local function GetTargetPart(character)
        if not character then return nil end
        if character:FindFirstChild("Humanoid") then
            if character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
                if HitboxTargetPart == "Head" then
                    return character:FindFirstChild("Head")
                elseif HitboxTargetPart == "Torso" then
                    return character:FindFirstChild("UpperTorso")
                end
            elseif character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
                 if HitboxTargetPart == "Head" then
                    return character:FindFirstChild("Head")
                elseif HitboxTargetPart == "Torso" then
                    return character:FindFirstChild("Torso")
                end
            end
        end
        return nil
    end

    local function ApplyHitbox(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player or player == LocalPlayer then return end

        local targetPart = GetTargetPart(character)
        if not targetPart then return end

        local originalKey = player.UserId .. "_" .. targetPart.Name

        if not HitboxEnabled then
            if originalProperties[originalKey] then
                targetPart.Size = originalProperties[originalKey].Size
                targetPart.Material = originalProperties[originalKey].Material
                targetPart.Transparency = originalProperties[originalKey].Transparency
                targetPart.Color = originalProperties[originalKey].Color
                targetPart.CanCollide = originalProperties[originalKey].CanCollide
                originalProperties[originalKey] = nil
            end
            return
        end

        if TeamCheckEnabled then
            local localPlayerTeamColor = GetTeamColor(LocalPlayer)
            local targetPlayerTeamColor = GetTeamColor(player)
            if localPlayerTeamColor and targetPlayerTeamColor and localPlayerTeamColor == targetPlayerTeamColor then
                if originalProperties[originalKey] then
                    targetPart.Size = originalProperties[originalKey].Size
                    targetPart.Material = originalProperties[originalKey].Material
                    targetPart.Transparency = originalProperties[originalKey].Transparency
                    targetPart.Color = originalProperties[originalKey].Color
                    targetPart.CanCollide = originalProperties[originalKey].CanCollide
                    originalProperties[originalKey] = nil
                end
                return
            elseif not localPlayerTeamColor or not targetPlayerTeamColor then
                 if originalProperties[originalKey] then
                    targetPart.Size = originalProperties[originalKey].Size
                    targetPart.Material = originalProperties[originalKey].Material
                    targetPart.Transparency = originalProperties[originalKey].Transparency
                    targetPart.Color = originalProperties[originalKey].Color
                    targetPart.CanCollide = originalProperties[originalKey].CanCollide
                    originalProperties[originalKey] = nil
                end
                return
            end
        end

        if not originalProperties[originalKey] then
            originalProperties[originalKey] = {
                Size = targetPart.Size,
                Material = targetPart.Material,
                Transparency = targetPart.Transparency,
                Color = targetPart.Color,
                CanCollide = targetPart.CanCollide
            }
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
            if HitboxTargetPart == "Head" then
                 targetPart.Size = Vector3.new(HitboxScale, HitboxScale, HitboxScale)
            elseif HitboxTargetPart == "Torso" then 
                 targetPart.Size = Vector3.new(humanoid.RootPart.Size.X * (HitboxScale/2), humanoid.RootPart.Size.Y * (HitboxScale/2), humanoid.RootPart.Size.Z * (HitboxScale/2)) 
            end
        elseif humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
            if HitboxTargetPart == "Head" then
                targetPart.Size = Vector3.new(HitboxScale, HitboxScale, HitboxScale)
            elseif HitboxTargetPart == "Torso" then
                targetPart.Size = Vector3.new(2 * (HitboxScale/2.5), 2 * (HitboxScale/2.5), 1 * (HitboxScale/2.5))
            end
        else
             targetPart.Size = Vector3.new(HitboxScale, HitboxScale, HitboxScale)
        end
        
        targetPart.Material = Enum.Material.SmoothPlastic
        targetPart.Color = HitboxColor
        targetPart.Transparency = HitboxTransparency
        targetPart.CanCollide = false
    end

    local function RevertAllHitboxes()
        for key, props in pairs(originalProperties) do
            local userId, partName = string.match(key, "(%d+)_(.+)")
            local player = Players:GetPlayerByUserId(tonumber(userId))
            if player and player.Character then
                local targetPartInstance = player.Character:FindFirstChild(partName, true)
                if targetPartInstance then
                    targetPartInstance.Size = props.Size
                    targetPartInstance.Material = props.Material
                    targetPartInstance.Transparency = props.Transparency
                    targetPartInstance.Color = props.Color
                    targetPartInstance.CanCollide = props.CanCollide
                end
            end
        end
        originalProperties = {}
    end

    tab:CreateToggle({
        Name = "Enabled",
        CurrentValue = HitboxEnabled,
        Flag = "HitboxEnabled",
        Callback = function(value)
            HitboxEnabled = value
            if not value then
                RevertAllHitboxes()
            else
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        ApplyHitbox(player.Character)
                    end
                end
            end
        end
    })

    tab:CreateToggle({
        Name = "TeamCheck",
        CurrentValue = TeamCheckEnabled,
        Flag = "HitboxTeamCheck",
        Callback = function(value)
            TeamCheckEnabled = value
            RevertAllHitboxes()
             if HitboxEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        ApplyHitbox(player.Character)
                    end
                end
            end
        end
    })

    tab:CreateDropdown({
        Name = "Hitbox Part",
        Options = {"Head", "Torso"},
        CurrentValue = HitboxTargetPart,
        Flag = "HitboxTargetPart",
        Callback = function(value)
            RevertAllHitboxes()
            HitboxTargetPart = value
            if HitboxEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        ApplyHitbox(player.Character)
                    end
                end
            end
        end
    })

    tab:CreateSlider({
        Name = "Scale",
        Range = {1, 50},
        Increment = 0.5,
        Suffix = "x",
        CurrentValue = HitboxScale,
        Flag = "HitboxScale",
        Callback = function(value)
            HitboxScale = value
        end
    })

    tab:CreateColorPicker({
        Name = "Hitbox Color",
        Color = HitboxColor,
        Flag = "HitboxColor",
        Callback = function(color)
            HitboxColor = color
        end
    })

    tab:CreateSlider({
        Name = "Transparency",
        Range = {0, 1},
        Increment = 0.05,
        Suffix = "",
        CurrentValue = HitboxTransparency,
        Flag = "HitboxTransparency",
        Callback = function(value)
            HitboxTransparency = value
        end
    })

    local function CharacterAdded(character)
        if HitboxEnabled then
            ApplyHitbox(character)
        end
        character.Humanoid.Died:Connect(function()
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                 local targetPart = GetTargetPart(character)
                 if targetPart then
                    local originalKey = player.UserId .. "_" .. targetPart.Name
                    if originalProperties[originalKey] then
                        originalProperties[originalKey] = nil
                    end
                 end
            end
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(CharacterAdded)
        if player.Character then
            CharacterAdded(player.Character)
        end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            CharacterAdded(player.Character)
        end
    end

    RunService.RenderStepped:Connect(function()
        if HitboxEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    ApplyHitbox(player.Character)
                end
            end
        end
    end)

    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(teleportState)
        if teleportState == Enum.TeleportState.InProgress then
            RevertAllHitboxes()
        end
    end)

end
