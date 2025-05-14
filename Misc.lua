local MiscModule = {}

local GravityEmulationEnabled = false
local SpeedEmulationEnabled = false
local JumpEmulationEnabled = false

local GravityMultiplierValue = 1
local SpeedMultiplierValue = 1
local JumpMultiplierValue = 1

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local originalWalkSpeed = 16
local originalJumpPower = 50
local originalGravity = workspace.Gravity

local characterBodyForce = nil

local function UpdateCharacterMovementProperties()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    local humanoid = character.Humanoid

    if SpeedEmulationEnabled then
        humanoid.WalkSpeed = originalWalkSpeed * SpeedMultiplierValue
    else
        humanoid.WalkSpeed = originalWalkSpeed
    end

    if JumpEmulationEnabled then
        humanoid.JumpPower = originalJumpPower * JumpMultiplierValue
    else
        humanoid.JumpPower = originalJumpPower
    end
end

local function ApplyGravityEmulationEffect()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        if characterBodyForce then characterBodyForce:Destroy(); characterBodyForce = nil; end
        return
    end
    local hrp = character.HumanoidRootPart
    local humanoid = character.Humanoid

    if GravityEmulationEnabled and humanoid:GetState() ~= Enum.HumanoidStateType.Seated and humanoid.Health > 0 then
        if not characterBodyForce or characterBodyForce.Parent ~= hrp then
            if characterBodyForce then characterBodyForce:Destroy() end
            characterBodyForce = Instance.new("BodyForce")
            characterBodyForce.Name = "GravityEmulationForce_EntoHUB"
            characterBodyForce.Parent = hrp
        end
        local totalMass = 0
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                totalMass = totalMass + part:GetMass()
            end
        end
        if totalMass == 0 then totalMass = humanoid:GetMass() end 
        if totalMass == 0 then totalMass = 10 end 

        local effectiveGravity = originalGravity * GravityMultiplierValue
        local forceMagnitude = (effectiveGravity - originalGravity) * totalMass 
        characterBodyForce.Force = Vector3.new(0, forceMagnitude, 0)
    else
        if characterBodyForce then
            characterBodyForce:Destroy()
            characterBodyForce = nil
        end
    end
end

function MiscModule.SetGravityEnabled(value)
    GravityEmulationEnabled = value
    if not value and characterBodyForce then
        characterBodyForce:Destroy()
        characterBodyForce = nil
    end
    ApplyGravityEmulationEffect() 
end

function MiscModule.SetGravityMultiplier(value)
    GravityMultiplierValue = value
    if GravityEmulationEnabled then ApplyGravityEmulationEffect() end
end

function MiscModule.SetSpeedEnabled(value)
    SpeedEmulationEnabled = value
    UpdateCharacterMovementProperties()
end

function MiscModule.SetSpeedMultiplier(value)
    SpeedMultiplierValue = value
    if SpeedEmulationEnabled then UpdateCharacterMovementProperties() end
end

function MiscModule.SetJumpEnabled(value)
    JumpEmulationEnabled = value
    UpdateCharacterMovementProperties()
end

function MiscModule.SetJumpMultiplier(value)
    JumpMultiplierValue = value
    if JumpEmulationEnabled then UpdateCharacterMovementProperties() end
end

local function OnCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    originalGravity = workspace.Gravity 
    
    UpdateCharacterMovementProperties()
    ApplyGravityEmulationEffect()

    humanoid.Died:Connect(function()
        if characterBodyForce and characterBodyForce.Parent == character:FindFirstChild("HumanoidRootPart") then
            characterBodyForce:Destroy()
            characterBodyForce = nil
        end
    end)
end

if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

RunService.Heartbeat:Connect(function(deltaTime)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if GravityEmulationEnabled then
            ApplyGravityEmulationEffect()
        end
        UpdateCharacterMovementProperties()
    else
        if characterBodyForce then characterBodyForce:Destroy(); characterBodyForce = nil; end
    end
end)

return MiscModule

