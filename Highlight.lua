return function(tab)
    local Highlight = {}

    local HighlightEnabled = false
    local TeamCheckEnabled = true
    local RainbowModeEnabled = false
    local RainbowSpeed = 1
    local HighlightTransparency = 0.5
    local HighlightColor = Color3.fromRGB(255, 255, 0)

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")

    local function GetTeamColor(player)
        if player and player.Team then
            return player.Team.TeamColor.Color
        end
        return nil
    end

    local function UpdateHighlight(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local player = Players:GetPlayerFromCharacter(character)
        if not player or player == LocalPlayer then return end

        local existingHighlight = character:FindFirstChild("Highlight")
        if not HighlightEnabled then
            if existingHighlight then existingHighlight:Destroy() end
            return
        end

        if TeamCheckEnabled then
            local localPlayerTeamColor = GetTeamColor(LocalPlayer)
            local targetPlayerTeamColor = GetTeamColor(player)
            if localPlayerTeamColor and targetPlayerTeamColor and localPlayerTeamColor == targetPlayerTeamColor then
                if existingHighlight then existingHighlight:Destroy() end
                return
            elseif not localPlayerTeamColor or not targetPlayerTeamColor then
                if existingHighlight then existingHighlight:Destroy() end
                return
            end
        end

        if not existingHighlight then
            existingHighlight = Instance.new("Highlight")
            existingHighlight.Parent = character
            existingHighlight.Adornee = character
            existingHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end

        existingHighlight.Enabled = true
        existingHighlight.FillTransparency = HighlightTransparency
        existingHighlight.OutlineTransparency = HighlightTransparency - 0.2 > 0 and HighlightTransparency - 0.2 or 0

        if RainbowModeEnabled then
            local hue = (tick() * RainbowSpeed) % 1
            existingHighlight.FillColor = Color3.fromHSV(hue, 1, 1)
            existingHighlight.OutlineColor = Color3.fromHSV(hue, 1, 0.7)
        else
            existingHighlight.FillColor = HighlightColor
            existingHighlight.OutlineColor = Color3.new(HighlightColor.r * 0.7, HighlightColor.g * 0.7, HighlightColor.b * 0.7)
        end
    end

    local function ClearAllHighlights()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
        end
    end

    tab:CreateToggle({
        Name = "Enabled",
        CurrentValue = HighlightEnabled,
        Flag = "HighlightEnabled",
        Callback = function(value)
            HighlightEnabled = value
            if not value then
                ClearAllHighlights()
            end
        end
    })

    tab:CreateToggle({
        Name = "TeamCheck",
        CurrentValue = TeamCheckEnabled,
        Flag = "HighlightTeamCheck",
        Callback = function(value)
            TeamCheckEnabled = value
            ClearAllHighlights()
        end
    })

    tab:CreateToggle({
        Name = "Rainbow Mode",
        CurrentValue = RainbowModeEnabled,
        Flag = "HighlightRainbowMode",
        Callback = function(value)
            RainbowModeEnabled = value
        end
    })

    tab:CreateSlider({
        Name = "Rainbow Speed",
        Range = {0.1, 5},
        Increment = 0.1,
        Suffix = "x",
        CurrentValue = RainbowSpeed,
        Flag = "HighlightRainbowSpeed",
        Callback = function(value)
            RainbowSpeed = value
        end
    })

    tab:CreateSlider({
        Name = "Transparency",
        Range = {0, 1},
        Increment = 0.05,
        Suffix = "",
        CurrentValue = HighlightTransparency,
        Flag = "HighlightTransparency",
        Callback = function(value)
            HighlightTransparency = value
        end
    })

    tab:CreateColorPicker({
        Name = "Highlight Color",
        Color = HighlightColor,
        Flag = "HighlightColor",
        Callback = function(color)
            HighlightColor = color
        end
    })

    RunService.RenderStepped:Connect(function()
        if HighlightEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    UpdateHighlight(player.Character)
                end
            end
        end
    end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if HighlightEnabled then
                UpdateHighlight(character)
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if player.Character and player.Character:FindFirstChild("Highlight") then
            player.Character.Highlight:Destroy()
        end
    end)

end
