return function()

local HitboxModule = {}

local HitboxEnabled = false
local TeamCheckEnabled = true
local HitboxTargetPartName = "Head"
local HitboxScaleValue = 5
local HitboxColorValue = Color3.fromRGB(255, 0, 0)
local HitboxTransparencyValue = 0.7

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local originalPartProperties = {}

local function GetTeamColor(player)
    if player and player.Team then
        return player.Team.TeamColor.Color
    end
    return nil
end

local function GetActualTargetPart(character)
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        if HitboxTargetPartName == "Head" then
            return character:FindFirstChild("Head")
        elseif HitboxTargetPartName == "Torso" then
            return character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
        end
    elseif humanoid.RigType == Enum.HumanoidRigType.R6 then
        if HitboxTargetPartName == "Head" then
            return character:FindFirstChild("Head")
        elseif HitboxTargetPartName == "Torso" then
            return character:FindFirstChild("Torso")
        end
    end
    return character:FindFirstChild(HitboxTargetPartName) 
end

local function RevertPartProperties(player, partInstance)
    if not player or not partInstance then return end
    local originalKey = player.UserId .. "_" .. partInstance.Name
    if originalPartProperties[originalKey] then
        local props = originalPartProperties[originalKey]
        pcall(function()
            partInstance.Size = props.Size
            partInstance.Material = props.Material
            partInstance.Transparency = props.Transparency
            partInstance.Color = props.Color
            partInstance.CanCollide = props.CanCollide
        end)
        originalPartProperties[originalKey] = nil
    end
end

local function ApplyHitboxToCharacter(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then return end

    local targetPart = GetActualTargetPart(character)
    if not targetPart then 
        for _, storedPlayer in pairs(Players:GetPlayers()) do
            if storedPlayer.Character then
                local storedTargetPart = GetActualTargetPart(storedPlayer.Character)
                if storedTargetPart then RevertPartProperties(storedPlayer, storedTargetPart) end
            end
        end
        return 
    end

    local originalKey = player.UserId .. "_" .. targetPart.Name

    if not HitboxEnabled then
        RevertPartProperties(player, targetPart)
        return
    end

    if TeamCheckEnabled then
        local localPlayerTeamColor = GetTeamColor(LocalPlayer)
        local targetPlayerTeamColor = GetTeamColor(player)
        if (localPlayerTeamColor and targetPlayerTeamColor and localPlayerTeamColor == targetPlayerTeamColor) or 
           (not localPlayerTeamColor or not targetPlayerTeamColor) then 
            RevertPartProperties(player, targetPart)
            return
        end
    end

    if not originalPartProperties[originalKey] then
        originalPartProperties[originalKey] = {
            Size = targetPart.Size,
            Material = targetPart.Material,
            Transparency = targetPart.Transparency,
            Color = targetPart.Color,
            CanCollide = targetPart.CanCollide
        }
    end

    local newSize
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.RigType == Enum.HumanoidRigType.R15 then
            if HitboxTargetPartName == "Head" then
                newSize = Vector3.new(HitboxScaleValue, HitboxScaleValue, HitboxScaleValue)
            elseif HitboxTargetPartName == "Torso" then
                local hrpSize = character.HumanoidRootPart.Size
                newSize = Vector3.new(hrpSize.X * (HitboxScaleValue / 2.5), hrpSize.Y * (HitboxScaleValue / 2), hrpSize.Z * (HitboxScaleValue / 2.5))
            else 
                newSize = Vector3.new(HitboxScaleValue, HitboxScaleValue, HitboxScaleValue)
            end
        elseif humanoid.RigType == Enum.HumanoidRigType.R6 then
            if HitboxTargetPartName == "Head" then
                newSize = Vector3.new(HitboxScaleValue, HitboxScaleValue, HitboxScaleValue)
            elseif HitboxTargetPartName == "Torso" then
                newSize = Vector3.new(2 * (HitboxScaleValue / 2.5), 2 * (HitboxScaleValue / 2.5), 1 * (HitboxScaleValue / 2.5))
            else
                 newSize = Vector3.new(HitboxScaleValue, HitboxScaleValue, HitboxScaleValue)
            end
        else
            newSize = Vector3.new(HitboxScaleValue, HitboxScaleValue, HitboxScaleValue)
        end
    else
        newSize = Vector3.new(HitboxScaleValue, HitboxScaleValue, HitboxScaleValue)
    end
    
    pcall(function()
        targetPart.Size = newSize
        targetPart.Material = Enum.Material.SmoothPlastic
        targetPart.Color = HitboxColorValue
        targetPart.Transparency = HitboxTransparencyValue
        targetPart.CanCollide = false
    end)
end

local function RevertAllCharacterHitboxes()
    for userIdStr, props in pairs(originalPartProperties) do
        local userId = tonumber(string.match(userIdStr, "^(%d+)"))
        local partName = string.match(userIdStr, "_(.+)$")
        if userId and partName then
            local player = Players:GetPlayerByUserId(userId)
            if player and player.Character then
                local partInstance = player.Character:FindFirstChild(partName, true)
                if partInstance then
                    RevertPartProperties(player, partInstance)
                end
            end
        end
    end
    originalPartProperties = {}
end

function HitboxModule.SetEnabled(value)
    HitboxEnabled = value
    if not value then
        RevertAllCharacterHitboxes()
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then ApplyHitboxToCharacter(player.Character) end
        end
    end
end

function HitboxModule.SetTeamCheck(value)
    TeamCheckEnabled = value
    RevertAllCharacterHitboxes()
    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then ApplyHitboxToCharacter(player.Character) end
        end
    end
end

function HitboxModule.SetTargetPart(value)
    RevertAllCharacterHitboxes()
    HitboxTargetPartName = value
    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then ApplyHitboxToCharacter(player.Character) end
        end
    end
end

function HitboxModule.SetScale(value)
    HitboxScaleValue = value
end

function HitboxModule.SetColor(value)
    HitboxColorValue = value
end

function HitboxModule.SetTransparency(value)
    HitboxTransparencyValue = value
end

local function OnCharacterAdded(character)
    if HitboxEnabled then
        ApplyHitboxToCharacter(character)
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                local targetPart = GetActualTargetPart(character)
                if targetPart then
                    local originalKey = player.UserId .. "_" .. targetPart.Name
                    if originalPartProperties[originalKey] then
                        originalPartProperties[originalKey] = nil
                    end
                end
            end
        end)
    end
end

local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(OnCharacterAdded)
    if player.Character then OnCharacterAdded(player.Character) end
end

local function OnPlayerRemoving(player)
    if player.Character then
        local targetPart = GetActualTargetPart(player.Character)
        if targetPart then RevertPartProperties(player, targetPart) end
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end
Players.PlayerRemoving:Connect(OnPlayerRemoving)

RunService.RenderStepped:Connect(function()
    if HitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                ApplyHitboxToCharacter(player.Character)
            end
        end
    end
end)

LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Started or teleportState == Enum.TeleportState.InProgress then
        RevertAllCharacterHitboxes()
    end
end)

return HitboxModule
end