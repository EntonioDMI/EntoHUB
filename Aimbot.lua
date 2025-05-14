return function(tab)
    local Aimbot = {}

    local AimbotEnabled = false
    local TeamCheckEnabled = true
    local AimRadius = 150
    local ShowFOV = true
    local FOVSize = 300 -- FOVSize is diameter, so radius is FOVSize / 2
    local AimSmoothness = 5
    local AimPart = "Head"
    local TargetPriority = "Distance" -- Can be "Distance" or "Crosshair"
    local PredictionEnabled = true

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    local Debris = game:GetService("Debris")

    local FOVCircle = nil
    local CurrentTarget = nil

    local function GetTeamColor(player)
        if player and player.Team then
            return player.Team.TeamColor.Color
        end
        return nil
    end

    local function GetAimPartPosition(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return nil end

        local partName = AimPart
        if humanoid.RigType == Enum.HumanoidRigType.R15 and AimPart == "Torso" then
            partName = "UpperTorso"
        end
        
        local targetPart = character:FindFirstChild(partName)
        if targetPart and targetPart:IsA("BasePart") then
            if PredictionEnabled and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                local velocity = targetPart.AssemblyLinearVelocity
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 -- Ping in seconds
                local gravity = workspace.Gravity
                local projectileSpeed = 100 -- Placeholder, ideally get from active weapon
                local timeToTarget = (targetPart.Position - Camera.CFrame.Position).Magnitude / projectileSpeed
                timeToTarget = timeToTarget + ping

                local predictedPosition = targetPart.Position + (velocity * timeToTarget)
                if humanoid.FloorMaterial ~= Enum.Material.Air then -- Basic ground check
                     predictedPosition = predictedPosition - Vector3.new(0, 0.5 * gravity * timeToTarget^2, 0)
                end
                return predictedPosition
            end
            return targetPart.Position
        end
        return character.HumanoidRootPart.Position
    end

    local function IsInFOV(position)
        local screenPos, onScreen = Camera:WorldToScreenPoint(position)
        if not onScreen then return false end
        local fovCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        return (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude <= (FOVSize / 2)
    end

    local function GetBestTarget()
        local bestTarget = nil
        local minIndicator = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if TeamCheckEnabled then
                    local localPlayerTeamColor = GetTeamColor(LocalPlayer)
                    local targetPlayerTeamColor = GetTeamColor(player)
                    if localPlayerTeamColor and targetPlayerTeamColor and localPlayerTeamColor == targetPlayerTeamColor then
                        continue
                    elseif not localPlayerTeamColor or not targetPlayerTeamColor then -- FFA or no teams
                        continue
                    end
                end

                local aimPos = GetAimPartPosition(player.Character)
                if aimPos and IsInFOV(aimPos) then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(aimPos)
                    if onScreen then
                        local indicator
                        if TargetPriority == "Distance" then
                            indicator = (aimPos - Camera.CFrame.Position).Magnitude
                        else -- Crosshair
                            indicator = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                        end

                        if indicator < minIndicator then
                            minIndicator = indicator
                            bestTarget = player
                        end
                    end
                end
            end
        end
        return bestTarget
    end

    local function CreateFOVCircle()
        if FOVCircle and FOVCircle.Parent then FOVCircle:Destroy() end
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = ShowFOV and AimbotEnabled
        FOVCircle.Radius = FOVSize / 2
        FOVCircle.Color = Color3.new(1,1,1)
        FOVCircle.Thickness = 1
        FOVCircle.Filled = false
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Transparency = 0.5
        FOVCircle.NumSides = 64
    end
    CreateFOVCircle() -- Initial creation

    tab:CreateToggle({
        Name = "Enabled",
        CurrentValue = AimbotEnabled,
        Flag = "AimbotEnabled",
        Callback = function(value)
            AimbotEnabled = value
            if FOVCircle then FOVCircle.Visible = ShowFOV and AimbotEnabled end
            CurrentTarget = nil
        end
    })

    tab:CreateToggle({
        Name = "TeamCheck",
        CurrentValue = TeamCheckEnabled,
        Flag = "AimbotTeamCheck",
        Callback = function(value)
            TeamCheckEnabled = value
            CurrentTarget = nil
        end
    })

    tab:CreateToggle({
        Name = "Show FOV",
        CurrentValue = ShowFOV,
        Flag = "AimbotShowFOV",
        Callback = function(value)
            ShowFOV = value
            if FOVCircle then FOVCircle.Visible = ShowFOV and AimbotEnabled end
        end
    })

    tab:CreateSlider({
        Name = "FOV Size",
        Range = {50, 1000},
        Increment = 10,
        Suffix = "px",
        CurrentValue = FOVSize,
        Flag = "AimbotFOVSize",
        Callback = function(value)
            FOVSize = value
            if FOVCircle then FOVCircle.Radius = FOVSize / 2 end
        end
    })
    
    tab:CreateSlider({
        Name = "Radius (Lock-on)",
        Range = {50, 500},
        Increment = 10,
        Suffix = "px",
        CurrentValue = AimRadius,
        Flag = "AimbotAimRadius",
        Callback = function(value)
            AimRadius = value
        end
    })

    tab:CreateSlider({
        Name = "Smoothness",
        Range = {1, 20},
        Increment = 1,
        Suffix = "",
        CurrentValue = AimSmoothness,
        Flag = "AimbotSmoothness",
        Callback = function(value)
            AimSmoothness = value
        end
    })

    tab:CreateDropdown({
        Name = "Aim Part",
        Options = {"Head", "Torso"},
        CurrentValue = AimPart,
        Flag = "AimbotAimPart",
        Callback = function(value)
            AimPart = value
        end
    })

    tab:CreateDropdown({
        Name = "Target Priority",
        Options = {"Distance", "Crosshair"},
        CurrentValue = TargetPriority,
        Flag = "AimbotTargetPriority",
        Callback = function(value)
            TargetPriority = value
        end
    })
    
    tab:CreateToggle({
        Name = "Movement Prediction",
        CurrentValue = PredictionEnabled,
        Flag = "AimbotPrediction",
        Callback = function(value)
            PredictionEnabled = value
        end
    })

    RunService:BindToRenderStep("AimbotUpdate", Enum.RenderPriority.Character.Value + 1, function(deltaTime)
        if not AimbotEnabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then -- RMB for aiming
            CurrentTarget = nil
            if FOVCircle then FOVCircle.Color = Color3.new(1,1,1) end
            return
        end

        if not CurrentTarget or not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild("Humanoid") or CurrentTarget.Character.Humanoid.Health <= 0 then
            CurrentTarget = GetBestTarget()
        end

        if CurrentTarget then
            local targetPos = GetAimPartPosition(CurrentTarget.Character)
            if targetPos and IsInFOV(targetPos) then
                if FOVCircle then FOVCircle.Color = Color3.new(0,1,0) end
                local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude <= AimRadius then                
                    local newCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 1 / AimSmoothness)
                else
                    CurrentTarget = nil -- Target out of lock-on radius or off-screen
                    if FOVCircle then FOVCircle.Color = Color3.new(1,1,1) end
                end
            else
                CurrentTarget = nil -- Target out of FOV
                if FOVCircle then FOVCircle.Color = Color3.new(1,1,1) end
            end
        else
            if FOVCircle then FOVCircle.Color = Color3.new(1,1,1) end
        end
        
        if FOVCircle then -- Ensure FOV circle position updates if viewport changes
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Visible = ShowFOV and AimbotEnabled
        end
    end)

    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(teleportState)
        if teleportState == Enum.TeleportState.Started then
            CurrentTarget = nil
            if FOVCircle and FOVCircle.Parent then
                FOVCircle:Destroy()
                FOVCircle = nil
            end
        elseif teleportState == Enum.TeleportState.Ended then
             CreateFOVCircle()
        end
    end)

end
