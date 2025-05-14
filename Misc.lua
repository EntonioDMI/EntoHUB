return function(tabInstance, sharedContext)
    local uiLibrary = sharedContext.uiLibrary
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local miscSettings = {
        emulatedGravityEnabled = false,
        emulatedGravityStrength = 1,
        emulatedSpeedEnabled = false,
        emulatedSpeedMultiplier = 1,
        emulatedJumpEnabled = false,
        emulatedJumpMultiplier = 1
    }

    local localPlayer = Players.LocalPlayer
    local originalWalkSpeed = 16
    local originalJumpPower = 50
    local originalGravity = workspace.Gravity

    if localPlayer and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalWalkSpeed = humanoid.WalkSpeed
            originalJumpPower = humanoid.JumpPower
        end
    end

    local gravitySection = tabInstance:CreateSection({
        Name = "Emulated Gravity"
    })

    gravitySection:AddToggle({
        Name = "Enabled",
        Flag = "MiscGravity_Enabled",
        Callback = function(value)
            miscSettings.emulatedGravityEnabled = value
            if not value and localPlayer and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Attempt to reset, though direct gravity change is not the goal
                end
            end
        end
    })

    gravitySection:AddSlider({
        Name = "Strength Multiplier",
        Flag = "MiscGravity_Strength",
        Value = 1,
        Min = 0.1,
        Max = 5,
        Precise = 1,
        Callback = function(value)
            miscSettings.emulatedGravityStrength = value
        end
    })

    local speedSection = tabInstance:CreateSection({
        Name = "Emulated Speed"
    })

    speedSection:AddToggle({
        Name = "Enabled",
        Flag = "MiscSpeed_Enabled",
        Callback = function(value)
            miscSettings.emulatedSpeedEnabled = value
            if not value and localPlayer and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = originalWalkSpeed
                end
            end
        end
    })

    speedSection:AddSlider({
        Name = "Speed Multiplier",
        Flag = "MiscSpeed_Multiplier",
        Value = 1,
        Min = 0.1,
        Max = 5,
        Precise = 1,
        Callback = function(value)
            miscSettings.emulatedSpeedMultiplier = value
        end
    })

    local jumpSection = tabInstance:CreateSection({
        Name = "Emulated Jump"
    })

    jumpSection:AddToggle({
        Name = "Enabled",
        Flag = "MiscJump_Enabled",
        Callback = function(value)
            miscSettings.emulatedJumpEnabled = value
            if not value and localPlayer and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = originalJumpPower
                end
            end
        end
    })

    jumpSection:AddSlider({
        Name = "Jump Multiplier",
        Flag = "MiscJump_Multiplier",
        Value = 1,
        Min = 0.1,
        Max = 5,
        Precise = 1,
        Callback = function(value)
            miscSettings.emulatedJumpMultiplier = value
        end
    })

    RunService.Heartbeat:Connect(function(deltaTime)
        if not localPlayer or not localPlayer.Character then 
            localPlayer = Players.LocalPlayer 
            if localPlayer and localPlayer.Character then
                 local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                 if humanoid then
                    originalWalkSpeed = humanoid.WalkSpeed
                    originalJumpPower = humanoid.JumpPower
                 end
            else
                return
            end
        end
        
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not hrp then return end

        if miscSettings.emulatedGravityEnabled then
            local downForce = Vector3.new(0, -workspace.Gravity * miscSettings.emulatedGravityStrength * deltaTime * 50, 0) 
            if hrp:IsA("BasePart") then
                 hrp.Velocity = hrp.Velocity + downForce
            end
        end

        if miscSettings.emulatedSpeedEnabled then
            humanoid.WalkSpeed = originalWalkSpeed * miscSettings.emulatedSpeedMultiplier
        else
            humanoid.WalkSpeed = originalWalkSpeed
        end

        if miscSettings.emulatedJumpEnabled then
            humanoid.JumpPower = originalJumpPower * miscSettings.emulatedJumpMultiplier
        else
            humanoid.JumpPower = originalJumpPower
        end
    end)
end

