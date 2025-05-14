local CombatModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local FriendsManager = require(script.Parent:WaitForChild("FriendsManager"))

local aimbotSettings = {
    Enabled = false,
    TeamCheck = true,
    Radius = 150,
    ShowFOV = true,
    FOVSize = 300,
    Smoothness = 5,
    AimPart = "Head",
    TargetPriority = "Distance",
    Prediction = true
}

local hitboxSettings = {
    Enabled = false,
    TeamCheck = true,
    HitboxPart = "Head",
    Scale = 5, 
    Color = Color3.fromRGB(255, 0, 0),
    Transparency = 0.5,
    Material = Enum.Material.SmoothPlastic
}

local activeHitboxes = {}
local hitboxConnections = {}
local aimbotFOVCircle = nil
local currentAimbotTarget = nil


local function GetTeam(player)
    return player and player.Team
end


local function GetAimPartPosition(character, partName, usePrediction)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    local actualPartName = partName
    if humanoid.RigType == Enum.HumanoidRigType.R15 and partName == "Torso" then
        actualPartName = "UpperTorso"
    end
    
    local targetPartInstance = character:FindFirstChild(actualPartName)
    if not targetPartInstance and partName == "Torso" and humanoid.RigType == Enum.HumanoidRigType.R15 then
        targetPartInstance = character:FindFirstChild("LowerTorso") or character:FindFirstChild("HumanoidRootPart")
    elseif not targetPartInstance then 
        targetPartInstance = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    end

    if targetPartInstance and targetPartInstance:IsA("BasePart") then
        if usePrediction and aimbotSettings.Prediction and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            local velocity = targetPartInstance.AssemblyLinearVelocity
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 
            local gravity = workspace.Gravity
            local projectileSpeed = 300 
            local timeToTarget = (targetPartInstance.Position - Camera.CFrame.Position).Magnitude / projectileSpeed
            timeToTarget = timeToTarget + ping

            local predictedPosition = targetPartInstance.Position + (velocity * timeToTarget)
            if humanoid.FloorMaterial ~= Enum.Material.Air then 
                 predictedPosition = predictedPosition - Vector3.new(0, 0.5 * gravity * timeToTarget^2, 0)
            end
            return predictedPosition
        end
        return targetPartInstance.Position
    end
    return character.HumanoidRootPart.Position
end

local function IsInFOV(position, fovSize)
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    if not onScreen then return false end
    local fovCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude <= (fovSize / 2)
end

local function FindBestAimbotTarget()
    local bestTarget = nil
    local minIndicator = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and not FriendsManager.IsFriend(player.UserId) then
            if aimbotSettings.TeamCheck then
                local localPlayerTeam = GetTeam(LocalPlayer)
                local targetPlayerTeam = GetTeam(player)
                if localPlayerTeam and targetPlayerTeam and localPlayerTeam == targetPlayerTeam then
                    goto continue_aim_loop
                end
            end

            local aimPos = GetAimPartPosition(player.Character, aimbotSettings.AimPart, true)
            if aimPos and IsInFOV(aimPos, aimbotSettings.FOVSize) then
                local screenPos, onScreen = Camera:WorldToScreenPoint(aimPos)
                if onScreen then
                    local indicator
                    if aimbotSettings.TargetPriority == "Distance" then
                        indicator = (aimPos - Camera.CFrame.Position).Magnitude
                    else 
                        indicator = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    end

                    if indicator < minIndicator then
                        minIndicator = indicator
                        bestTarget = player
                    end
                end
            end
        end
        ::continue_aim_loop::
    end
    return bestTarget
end

local function UpdateAimbotFOVCircle()
    if not aimbotFOVCircle then
        aimbotFOVCircle = Drawing.new("Circle")
        aimbotFOVCircle.Thickness = 1
        aimbotFOVCircle.Filled = false
        aimbotFOVCircle.NumSides = 64
        aimbotFOVCircle.Transparency = 0.5
    end
    aimbotFOVCircle.Visible = aimbotSettings.ShowFOV and aimbotSettings.Enabled
    aimbotFOVCircle.Radius = aimbotSettings.FOVSize / 2
    aimbotFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if currentAimbotTarget and currentAimbotTarget.Character and currentAimbotTarget.Character:FindFirstChildOfClass("Humanoid") and currentAimbotTarget.Character.Humanoid.Health > 0 then
        aimbotFOVCircle.Color = Color3.new(0,1,0)
    else
        aimbotFOVCircle.Color = Color3.new(1,1,1)
    end
end

local function RemovePlayerHitbox(player)
    if activeHitboxes[player] then
        for _, part in pairs(activeHitboxes[player]) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        activeHitboxes[player] = nil
    end
end

local function CreateHitboxPartFor(name, parentPart, size)
    local part = Instance.new("Part")
    part.Name = name .. "_CombatHitbox"
    part.Anchored = false
    part.CanCollide = false
    part.Massless = true
    part.Size = size
    part.Color = hitboxSettings.Color
    part.Transparency = hitboxSettings.Transparency
    part.Material = hitboxSettings.Material
    
    local weld = Instance.new("WeldConstraint") 
    weld.Part0 = part
    weld.Part1 = parentPart
    weld.Parent = part
    
    part.Parent = character 
    return part
end

local function CreateActualHitbox(player)
    RemovePlayerHitbox(player)
    if player == LocalPlayer or not player.Character or FriendsManager.IsFriend(player.UserId) then return end

    if hitboxSettings.TeamCheck then
        local localPlayerTeam = GetTeam(LocalPlayer)
        local targetPlayerTeam = GetTeam(player)
        if localPlayerTeam and targetPlayerTeam and localPlayerTeam == targetPlayerTeam then
            return
        end
    end

    local character = player.Character
    local playerHitboxParts = {}
    local targetPartName = hitboxSettings.HitboxPart
    local scale = hitboxSettings.Scale

    local function processPart(partType, referencePart)
        if referencePart then
            local size = referencePart.Size * scale
            if partType == "Head" then size = Vector3.new(scale,scale,scale) end 
            playerHitboxParts[partType] = CreateHitboxPartFor(partType, referencePart, size)
        end
    end

    if targetPartName == "Head" then
        processPart("Head", character:FindFirstChild("Head"))
    elseif targetPartName == "Body" then
        if character:FindFirstChild("UpperTorso") and character:FindFirstChild("LowerTorso") then 
            processPart("UpperTorso", character.UpperTorso)
            processPart("LowerTorso", character.LowerTorso)
            processPart("Head", character.Head) 
        elseif character:FindFirstChild("Torso") then 
            processPart("Torso", character.Torso)
            processPart("Head", character.Head) 
        end
    end
    activeHitboxes[player] = playerHitboxParts
end

local function UpdateAllHitboxes()
    if not hitboxSettings.Enabled then
        for player, _ in pairs(activeHitboxes) do RemovePlayerHitbox(player) end
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateActualHitbox(player)
        end
    end
end

local function UpdateHitboxVisuals()
    for _, playerBoxTable in pairs(activeHitboxes) do
        for _, part in pairs(playerBoxTable) do
            if part and part:IsA("BasePart") then
                part.Color = hitboxSettings.Color
                part.Transparency = hitboxSettings.Transparency
                part.Material = hitboxSettings.Material
            end
        end
    end
end

local function CleanupHitboxConnections()
    for _, conn in ipairs(hitboxConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    hitboxConnections = {}
end

function CombatModule.SetAimbotEnabled(value)
    aimbotSettings.Enabled = value
    if not value then currentAimbotTarget = nil end
    UpdateAimbotFOVCircle()
end

function CombatModule.SetAimbotTeamCheck(value) aimbotSettings.TeamCheck = value; currentAimbotTarget = nil; end
function CombatModule.SetAimbotShowFOV(value) aimbotSettings.ShowFOV = value; UpdateAimbotFOVCircle(); end
function CombatModule.SetAimbotFOVSize(value) aimbotSettings.FOVSize = value; UpdateAimbotFOVCircle(); end
function CombatModule.SetAimbotRadius(value) aimbotSettings.Radius = value; end
function CombatModule.SetAimbotSmoothness(value) aimbotSettings.Smoothness = value; end
function CombatModule.SetAimbotAimPart(value) aimbotSettings.AimPart = value; end
function CombatModule.SetAimbotTargetPriority(value) aimbotSettings.TargetPriority = value; end
function CombatModule.SetAimbotPrediction(value) aimbotSettings.Prediction = value; end

function CombatModule.SetHitboxEnabled(value)
    hitboxSettings.Enabled = value
    CleanupHitboxConnections()
    if value then
        table.insert(hitboxConnections, Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then p.CharacterAdded:Connect(function() task.wait(0.5); CreateActualHitbox(p) end); if p.Character then CreateActualHitbox(p) end end end))
        table.insert(hitboxConnections, Players.PlayerRemoving:Connect(RemovePlayerHitbox))
        UpdateAllHitboxes()
    else
        for p, _ in pairs(activeHitboxes) do RemovePlayerHitbox(p) end
    end
end

function CombatModule.SetHitboxTeamCheck(value) hitboxSettings.TeamCheck = value; UpdateAllHitboxes(); end
function CombatModule.SetHitboxPart(value) hitboxSettings.HitboxPart = value; UpdateAllHitboxes(); end 
function CombatModule.SetHitboxScale(value) hitboxSettings.Scale = value; UpdateAllHitboxes(); end
function CombatModule.SetHitboxColor(value) hitboxSettings.Color = value; UpdateHitboxVisuals(); end
function CombatModule.SetHitboxTransparency(value) hitboxSettings.Transparency = value; UpdateHitboxVisuals(); end
function CombatModule.SetHitboxMaterial(value) hitboxSettings.Material = value; UpdateHitboxVisuals(); end

RunService:BindToRenderStep("CombatUpdate_EntoHUB", Enum.RenderPriority.Camera.Value + 5, function(deltaTime)
    if aimbotSettings.Enabled then
        UpdateAimbotFOVCircle()
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if not currentAimbotTarget or not currentAimbotTarget.Character or not currentAimbotTarget.Character:FindFirstChild("Humanoid") or currentAimbotTarget.Character.Humanoid.Health <= 0 then
                currentAimbotTarget = FindBestAimbotTarget()
            end
            if currentAimbotTarget then
                local targetPos = GetAimPartPosition(currentAimbotTarget.Character, aimbotSettings.AimPart, true)
                if targetPos and IsInFOV(targetPos, aimbotSettings.Radius) then 
                    local newCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, deltaTime * aimbotSettings.Smoothness * 5) 
                else
                    currentAimbotTarget = nil 
                end
            end
        else
            currentAimbotTarget = nil
        end
    end
    if hitboxSettings.Enabled then
        UpdateAllHitboxes() 
    end
end)

LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Started then
        currentAimbotTarget = nil
        if aimbotFOVCircle then aimbotFOVCircle:Remove(); aimbotFOVCircle = nil; end
        for p, _ in pairs(activeHitboxes) do RemovePlayerHitbox(p) end
    elseif teleportState == Enum.TeleportState.Ended then
        UpdateAimbotFOVCircle()
        UpdateAllHitboxes()
    end
end)

return CombatModule

