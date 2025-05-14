local AimbotModule = {}

local AimbotEnabled = false
local TeamCheckEnabled = true
local AimRadiusValue = 150
local ShowFOV_Value = true
local FOVSize_Value = 300
local AimSmoothnessValue = 5
local AimPartName = "Head"
local TargetPriorityValue = "Distance"
local PredictionEnabled_Value = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local FOVCircleDrawing = nil
local CurrentTargetPlayer = nil

local function GetTeamColor(player)
    if player and player.Team then
        return player.Team.TeamColor.Color
    end
    return nil
end

local function GetAimPartPositionFromCharacter(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    local partNameToUse = AimPartName
    if humanoid.RigType == Enum.HumanoidRigType.R15 and AimPartName == "Torso" then
        partNameToUse = "UpperTorso"
    end
    
    local targetPartInstance = character:FindFirstChild(partNameToUse)
    if not targetPartInstance and AimPartName == "Torso" and humanoid.RigType == Enum.HumanoidRigType.R15 then
        targetPartInstance = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
    elseif not targetPartInstance and AimPartName == "Torso" and humanoid.RigType == Enum.HumanoidRigType.R6 then
        targetPartInstance = character:FindFirstChild("Torso")
    elseif not targetPartInstance then
        targetPartInstance = character:FindFirstChild("Head") or character.HumanoidRootPart
    end

    if targetPartInstance and targetPartInstance:IsA("BasePart") then
        if PredictionEnabled_Value and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            local velocity = targetPartInstance.AssemblyLinearVelocity
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 
            local gravity = workspace.Gravity
            local projectileSpeed = 200 
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

local function IsPositionInFOV(position)
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    if not onScreen then return false end
    local fovCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(screenPos.X, screenPos.Y) - fovCenter).Magnitude <= (FOVSize_Value / 2)
end

local function FindBestTarget()
    local bestTarget = nil
    local minIndicator = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if TeamCheckEnabled then
                local localPlayerTeamColor = GetTeamColor(LocalPlayer)
                local targetPlayerTeamColor = GetTeamColor(player)
                if localPlayerTeamColor and targetPlayerTeamColor and localPlayerTeamColor == targetPlayerTeamColor then
                    goto continue_loop
                elseif not localPlayerTeamColor or not targetPlayerTeamColor then 
                    goto continue_loop
                end
            end

            local aimPos = GetAimPartPositionFromCharacter(player.Character)
            if aimPos and IsPositionInFOV(aimPos) then
                local screenPos, onScreen = Camera:WorldToScreenPoint(aimPos)
                if onScreen then
                    local indicator
                    if TargetPriorityValue == "Distance" then
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
        ::continue_loop::
    end
    return bestTarget
end

local function UpdateFOVCircleDrawing()
    if not FOVCircleDrawing then
        FOVCircleDrawing = Drawing.new("Circle")
        FOVCircleDrawing.Thickness = 1
        FOVCircleDrawing.Filled = false
        FOVCircleDrawing.NumSides = 64
        FOVCircleDrawing.Transparency = 0.5
    end
    FOVCircleDrawing.Visible = ShowFOV_Value and AimbotEnabled
    FOVCircleDrawing.Radius = FOVSize_Value / 2
    FOVCircleDrawing.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if CurrentTargetPlayer and CurrentTargetPlayer.Character and CurrentTargetPlayer.Character:FindFirstChildOfClass("Humanoid") and CurrentTargetPlayer.Character.Humanoid.Health > 0 then
        FOVCircleDrawing.Color = Color3.new(0,1,0)
    else
        FOVCircleDrawing.Color = Color3.new(1,1,1)
    end
end

function AimbotModule.SetEnabled(value)
    AimbotEnabled = value
    if not value then CurrentTargetPlayer = nil end
    UpdateFOVCircleDrawing()
end

function AimbotModule.SetTeamCheck(value) TeamCheckEnabled = value; CurrentTargetPlayer = nil; end
function AimbotModule.SetShowFOV(value) ShowFOV_Value = value; UpdateFOVCircleDrawing(); end
function AimbotModule.SetFieldOfView(value) FOVSize_Value = value; UpdateFOVCircleDrawing(); end
function AimbotModule.SetLockRadius(value) AimRadiusValue = value; end
function AimbotModule.SetSmoothness(value) AimSmoothnessValue = value; end
function AimbotModule.SetAimPart(value) AimPartName = value; end
function AimbotModule.SetTargetPriority(value) TargetPriorityValue = value; end
function AimbotModule.SetPrediction(value) PredictionEnabled_Value = value; end

RunService:BindToRenderStep("AimbotUpdate_EntoHUB", Enum.RenderPriority.Camera.Value + 10, function(deltaTime)
    UpdateFOVCircleDrawing()
    if not AimbotEnabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        CurrentTargetPlayer = nil
        return
    end

    if not CurrentTargetPlayer or not CurrentTargetPlayer.Character or not CurrentTargetPlayer.Character:FindFirstChild("Humanoid") or CurrentTargetPlayer.Character.Humanoid.Health <= 0 then
        CurrentTargetPlayer = FindBestTarget()
    end

    if CurrentTargetPlayer then
        local targetPos = GetAimPartPositionFromCharacter(CurrentTargetPlayer.Character)
        if targetPos and IsPositionInFOV(targetPos) then
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude <= AimRadiusValue then                
                local newCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, deltaTime * AimSmoothnessValue * 5) 
            else
                CurrentTargetPlayer = nil 
            end
        else
            CurrentTargetPlayer = nil 
        end
    end
end)

LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Started then
        CurrentTargetPlayer = nil
        if FOVCircleDrawing then
            FOVCircleDrawing:Remove()
            FOVCircleDrawing = nil
        end
    elseif teleportState == Enum.TeleportState.Ended then
        UpdateFOVCircleDrawing()
    end
end)

return AimbotModule
