return function(tabInstance, sharedContext)
    local uiLibrary = sharedContext.uiLibrary
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = game.Workspace.CurrentCamera

    local combatSettings = {
        aimbotEnabled = false,
        aimbotTeamCheck = true,
        aimbotRadius = 100,
        aimbotShowFov = true,
        aimbotFov = 90,
        aimbotSmoothness = 0.5,
        aimbotPart = "Head",
        hitboxEnabled = false,
        hitboxPart = "Head",
        hitboxScale = 1.5,
        hitboxColor = Color3.fromRGB(255, 0, 0),
        hitboxTransparency = 0.5
    }

    local originalHitboxData = {}

    local aimbotSection = tabInstance:CreateSection({
        Name = "Aimbot"
    })

    aimbotSection:AddToggle({
        Name = "Enabled",
        Flag = "CombatAimbot_Enabled",
        Callback = function(value)
            combatSettings.aimbotEnabled = value
        end
    })

    aimbotSection:AddToggle({
        Name = "Team Check",
        Flag = "CombatAimbot_TeamCheck",
        Callback = function(value)
            combatSettings.aimbotTeamCheck = value
        end,
        Default = true
    })

    aimbotSection:AddSlider({
        Name = "Radius",
        Flag = "CombatAimbot_Radius",
        Value = 100,
        Min = 10,
        Max = 500,
        Precise = 0,
        Callback = function(value)
            combatSettings.aimbotRadius = value
        end
    })

    aimbotSection:AddToggle({
        Name = "Show FOV",
        Flag = "CombatAimbot_ShowFOV",
        Callback = function(value)
            combatSettings.aimbotShowFov = value
        end,
        Default = true
    })

    aimbotSection:AddSlider({
        Name = "FOV",
        Flag = "CombatAimbot_FOV",
        Value = 90,
        Min = 10,
        Max = 360,
        Precise = 0,
        Callback = function(value)
            combatSettings.aimbotFov = value
        end
    })

    aimbotSection:AddSlider({
        Name = "Smoothness",
        Flag = "CombatAimbot_Smoothness",
        Value = 0.5,
        Min = 0.1,
        Max = 1.0,
        Precise = 2,
        Callback = function(value)
            combatSettings.aimbotSmoothness = value
        end
    })

    aimbotSection:AddDropdown({
        Name = "Target Part",
        Flag = "CombatAimbot_Part",
        Options = {"Head", "Torso"},
        Callback = function(value)
            combatSettings.aimbotPart = value
        end,
        Default = "Head"
    })

    local hitboxSection = tabInstance:CreateSection({
        Name = "Hitbox Extender"
    })

    hitboxSection:AddToggle({
        Name = "Enabled",
        Flag = "CombatHitbox_Enabled",
        Callback = function(value)
            combatSettings.hitboxEnabled = value
            if not value then
                for player, data in pairs(originalHitboxData) do
                    revertHitboxes(player)
                end
                originalHitboxData = {}
            end
        end
    })

    hitboxSection:AddDropdown({
        Name = "Hitbox Part",
        Flag = "CombatHitbox_Part",
        Options = {"Head", "Torso"},
        Callback = function(value)
            combatSettings.hitboxPart = value
        end,
        Default = "Head"
    })

    hitboxSection:AddSlider({
        Name = "Scale",
        Flag = "CombatHitbox_Scale",
        Value = 1.5,
        Min = 1.0,
        Max = 50.0,
        Precise = 1,
        Callback = function(value)
            combatSettings.hitboxScale = value
        end
    })

    hitboxSection:AddColorpicker({
        Name = "Color",
        Flag = "CombatHitbox_Color",
        Default = Color3.fromRGB(255,0,0),
        Callback = function(value)
            combatSettings.hitboxColor = value
        end
    })

    hitboxSection:AddSlider({
        Name = "Transparency",
        Flag = "CombatHitbox_Transparency",
        Value = 0.5,
        Min = 0.0,
        Max = 1.0,
        Precise = 2,
        Callback = function(value)
            combatSettings.hitboxTransparency = value
        end
    })

    local function getPlayers()
        return Players:GetPlayers()
    end

    local function getLocalPlayer()
        return Players.LocalPlayer
    end

    local function isTeamMate(player1, player2)
        if not player1 or not player2 or not player1.Team or not player2.Team then
            return false
        end
        if player1.Team == player2.Team and player1.TeamColor == player2.TeamColor and player1.TeamColor.Color ~= BrickColor.Neutral().Color then
             return true
        end
        return false
    end

    local function isValidTarget(player)
        local localPlayer = getLocalPlayer()
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChildOfClass("Humanoid") then return false end
        if player == localPlayer or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            return false
        end

        if sharedContext:isFriend(player.UserId) then
            return false
        end

        if combatSettings.aimbotTeamCheck then
            if isTeamMate(localPlayer, player) then
                return false
            end
            if localPlayer.Team == nil or localPlayer.Team.Name == "Neutral" then 
                return false
            end
        end
        return true
    end

    local function getTargetPart(character, partName)
        if not character then return nil end
        local targetPart = character:FindFirstChild(partName, true)
        if not targetPart and partName == "Torso" then 
            targetPart = character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso")
        end
        return targetPart
    end

    local function aimAtTarget(targetPlayer)
        if not targetPlayer or not targetPlayer.Character then return end
        local targetPart = getTargetPart(targetPlayer.Character, combatSettings.aimbotPart)
        if not targetPart or not targetPart:IsA("BasePart") then return end

        local targetPosition = targetPart.Position
        local newCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, combatSettings.aimbotSmoothness)
    end

    local function updateHitboxes(player)
        if not player or not player.Character then return end
        local targetPartName = combatSettings.hitboxPart
        local actualPart = getTargetPart(player.Character, targetPartName)

        if not actualPart or not actualPart:IsA("BasePart") then return end

        if not originalHitboxData[player] or not originalHitboxData[player][actualPart.Name] then
            originalHitboxData[player] = originalHitboxData[player] or {}
            originalHitboxData[player][actualPart.Name] = {
                size = actualPart.Size,
                transparency = actualPart.Transparency,
                color = actualPart.Color,
                material = actualPart.Material,
                cframe = actualPart.CFrame
            }
        end
        
        actualPart.Size = originalHitboxData[player][actualPart.Name].size * combatSettings.hitboxScale
        actualPart.Transparency = combatSettings.hitboxTransparency
        actualPart.Color = combatSettings.hitboxColor
        actualPart.Material = Enum.Material.SmoothPlastic
        actualPart.CanCollide = false
    end

    local function revertHitboxes(player)
        if not player or not player.Character then return end
        if originalHitboxData[player] then
            for partName, data in pairs(originalHitboxData[player]) do
                local actualPart = getTargetPart(player.Character, partName)
                if actualPart and actualPart:IsA("BasePart") then
                    actualPart.Size = data.size
                    actualPart.Transparency = data.transparency
                    actualPart.Color = data.color
                    actualPart.Material = data.material
                    actualPart.CanCollide = true 
                end
            end
            originalHitboxData[player] = nil
        end
    end
    
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(255,255,255)
    fovCircle.Transparency = 0.5

    RunService.RenderStepped:Connect(function()
        local localPlayer = getLocalPlayer()
        if not localPlayer or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

        if combatSettings.aimbotEnabled then
            local bestTarget = nil
            local closestAngle = combatSettings.aimbotFov / 2

            for _, player in ipairs(getPlayers()) do
                if isValidTarget(player) then
                    local targetPart = getTargetPart(player.Character, combatSettings.aimbotPart)
                    if targetPart and targetPart:IsA("BasePart") then
                        local vector, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                        if onScreen then
                            local distance = (localPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                            if distance <= combatSettings.aimbotRadius then
                                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                                local angle = math.deg(math.atan2(vector.Y - screenCenter.Y, vector.X - screenCenter.X) - math.atan2(0,0)) -- Simplified angle check
                                local mouseLocation = UserInputService:GetMouseLocation()
                                local diff = (Vector2.new(vector.X, vector.Y) - mouseLocation).Magnitude
                                local fovRadiusPixels = (combatSettings.aimbotFov / Camera.FieldOfView) * (Camera.ViewportSize.Y / 2) -- Approximate FOV in pixels
                                
                                if diff < fovRadiusPixels and diff < closestAngle * 10 then -- Heuristic for closest to center within FOV
                                    closestAngle = diff / 10 
                                    bestTarget = player
                                end
                            end
                        end
                    end
                end
            end

            if bestTarget then
                aimAtTarget(bestTarget)
            end
        end
        
        if combatSettings.aimbotShowFov and combatSettings.aimbotEnabled then
            fovCircle.Visible = true
            fovCircle.Radius = (combatSettings.aimbotFov / Camera.FieldOfView) * (Camera.ViewportSize.Y / 2) -- Approximate
            fovCircle.Position = UserInputService:GetMouseLocation()
        else
            fovCircle.Visible = false
        end

        for _, player in ipairs(getPlayers()) do
            if player == localPlayer or not player.Character then goto continue_loop end
            local shouldHaveHitbox = combatSettings.hitboxEnabled and not sharedContext:isFriend(player.UserId)
            if shouldHaveHitbox and combatSettings.aimbotTeamCheck then
                if isTeamMate(localPlayer, player) or (localPlayer.Team == nil or localPlayer.Team.Name == "Neutral") then
                    shouldHaveHitbox = false
                end
            end

            if shouldHaveHitbox then
                updateHitboxes(player)
            else
                revertHitboxes(player)
            end
            ::continue_loop::
        end
    end)
end

