local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Players = game:GetService("Players")

local mainWindow = library:CreateWindow({
    Name = "EntoHUB"
})

local combatTab = mainWindow:CreateTab({
    Name = "COMBAT"
})

local visualsTab = mainWindow:CreateTab({
    Name = "VISUALS"
})

local miscTab = mainWindow:CreateTab({
    Name = "MISC"
})

local sharedContext = {
    friends = {},
    uiLibrary = library
}

function sharedContext:addFriend(userId)
    if not self:isFriend(userId) then
        table.insert(self.friends, userId)
        print("Added friend: " .. tostring(userId))
    end
end

function sharedContext:removeFriend(userId)
    for i, id in ipairs(self.friends) do
        if id == userId then
            table.remove(self.friends, i)
            print("Removed friend: " .. tostring(userId))
            return
        end
    end
end

function sharedContext:isFriend(userId)
    for _, id in ipairs(self.friends) do
        if id == userId then
            return true
        end
    end
    return false
end

local friendsSection = miscTab:CreateSection({
    Name = "Friends Management"
})

friendsSection:AddToggle({
    Name = "Enable Add Friend by Click",
    Flag = "MiscFriends_AddByClickEnabled"
})

local playerListContainer = friendsSection:CreateSection({ Name = "Player List" }) 

local function refreshPlayerListDisplay()
    for _, child in ipairs(playerListContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name == "PlayerEntry" then 
            child:Destroy()
        end
    end

    local yOffset = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player and player.UserId then
            local playerEntry = library.CreateFrame(playerListContainer) 
            playerEntry.Name = "PlayerEntry"
            playerEntry.Size = UDim2.new(1, 0, 0, 30) 
            playerEntry.Position = UDim2.new(0, 0, 0, yOffset)
            yOffset = yOffset + 35 

            local playerNameLabel = library.CreateLabel(playerEntry) 
            playerNameLabel.Text = player.Name
            playerNameLabel.Size = UDim2.new(0.6, 0, 1, 0)
            playerNameLabel.Position = UDim2.new(0, 5, 0, 0)

            local actionButton = library.CreateButton(playerEntry) 
            actionButton.Size = UDim2.new(0.35, 0, 1, 0)
            actionButton.Position = UDim2.new(0.65, -5, 0, 0)
            
            if sharedContext:isFriend(player.UserId) then
                actionButton.Text = "Remove"
                actionButton.OnClick = function()
                    sharedContext:removeFriend(player.UserId)
                    refreshPlayerListDisplay()
                end
            else
                actionButton.Text = "Add"
                actionButton.OnClick = function()
                    sharedContext:addFriend(player.UserId)
                    refreshPlayerListDisplay()
                end
            end
        end
    end
end

friendsSection:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        refreshPlayerListDisplay()
    end
})

refreshPlayerListDisplay() 
Players.PlayerAdded:Connect(refreshPlayerListDisplay)
Players.PlayerRemoving:Connect(refreshPlayerListDisplay)


local baseUrl = "https://raw.githubusercontent.com/EntonioDMI/EntoHUB/refs/heads/main/"
local modules = {}

local function loadModule(moduleName, tabInstance)
    local moduleUrl = baseUrl .. moduleName
    local success, response = pcall(game.HttpGet, game, moduleUrl)

    if not success then
        warn("ERROR in MAIN.lua: Failed to fetch module " .. moduleName .. " from " .. moduleUrl .. " - " .. tostring(response))
        warn("Stack Traceback:\n" .. debug.traceback())
        return nil
    end

    if response == "404: Not Found" then
        warn("ERROR in MAIN.lua: Module " .. moduleName .. " not found at " .. moduleUrl .. " (404)")
        warn("Stack Traceback:\n" .. debug.traceback())
        return nil
    end

    local moduleFunction, loadError = loadstring(response)

    if not moduleFunction then
        warn("ERROR in MAIN.lua: Failed to loadstring module " .. moduleName .. " - " .. tostring(loadError))
        warn("Stack Traceback:\n" .. debug.traceback())
        return nil
    end

    local successCall, moduleContent = pcall(moduleFunction)
    if not successCall then
        warn("ERROR in MAIN.lua: Failed to execute loaded module " .. moduleName .. " - " .. tostring(moduleContent))
        warn("Stack Traceback:\n" .. debug.traceback())
        return nil
    end
    
    if typeof(moduleContent) == "function" then
        local successInit, errorInit = pcall(moduleContent, tabInstance, sharedContext)
        if not successInit then
            warn("ERROR in MAIN.lua: Failed to initialize module " .. moduleName .. " - " .. tostring(errorInit))
            warn("Stack Traceback:\n" .. debug.traceback())
            return nil
        end
    else
        warn("WARNING in MAIN.lua: Module " .. moduleName .. " did not return a function for initialization.")
    end
    
    modules[moduleName] = moduleContent
    return moduleContent
end

loadModule("Combat.lua", combatTab)
loadModule("Visuals.lua", visualsTab)
loadModule("Misc.lua", miscTab)

