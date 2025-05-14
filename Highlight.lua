local HighlightModule = {}

local HighlightEnabled = false
local TeamCheckEnabled = true
local RainbowModeEnabled = false
local RainbowSpeed = 1
local HighlightTransparency = 0.5
local HighlightColorValue = Color3.fromRGB(255, 255, 0)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function GetTeamColor(player)
    if player and player.Team then
        return player.Team.TeamColor.Color
    end
    return nil
end

local function UpdateHighlightOnCharacter(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then return end

    local existingHighlight = character:FindFirstChild("Highlight_EntoHUB")
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
        existingHighlight.Name = "Highlight_EntoHUB"
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
        existingHighlight.FillColor = HighlightColorValue
        existingHighlight.OutlineColor = Color3.new(HighlightColorValue.r * 0.7, HighlightColorValue.g * 0.7, HighlightColorValue.b * 0.7)
    end
end

local function ClearAllHighlightsFromSystem()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local h = player.Character:FindFirstChild("Highlight_EntoHUB")
            if h then h:Destroy() end
        end
    end
end

function HighlightModule.SetEnabled(value)
    HighlightEnabled = value
    if not value then
        ClearAllHighlightsFromSystem()
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then UpdateHighlightOnCharacter(player.Character) end
        end
    end
end

function HighlightModule.SetTeamCheck(value)
    TeamCheckEnabled = value
    ClearAllHighlightsFromSystem()
    if HighlightEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then UpdateHighlightOnCharacter(player.Character) end
        end
    end
end

function HighlightModule.SetRainbowMode(value)
    RainbowModeEnabled = value
end

function HighlightModule.SetRainbowSpeed(value)
    RainbowSpeed = value
end

function HighlightModule.SetTransparency(value)
    HighlightTransparency = value
end

function HighlightModule.SetColor(value)
    HighlightColorValue = value
end

local function OnCharacterAdded(character)
    if HighlightEnabled then
        UpdateHighlightOnCharacter(character)
    end
end

local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(OnCharacterAdded)
    if player.Character then OnCharacterAdded(player.Character) end
end

local function OnPlayerRemoving(player)
    if player.Character then
        local h = player.Character:FindFirstChild("Highlight_EntoHUB")
        if h then h:Destroy() end
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end
Players.PlayerRemoving:Connect(OnPlayerRemoving)

RunService.RenderStepped:Connect(function()
    if HighlightEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                UpdateHighlightOnCharacter(player.Character)
            end
        end
    end
end)

return HighlightModule
