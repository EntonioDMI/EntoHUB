local FriendsManager = {}

local FriendsList = {}

function FriendsManager.AddFriend(userId)
    if not userId then return false end
    local userIdStr = tostring(userId)
    if not FriendsList[userIdStr] then
        FriendsList[userIdStr] = true
        print("Friend added: " .. userIdStr)
        return true
    end
    return false
end

function FriendsManager.RemoveFriend(userId)
    if not userId then return false end
    local userIdStr = tostring(userId)
    if FriendsList[userIdStr] then
        FriendsList[userIdStr] = nil
        print("Friend removed: " .. userIdStr)
        return true
    end
    return false
end

function FriendsManager.IsFriend(userId)
    if not userId then return false end
    local userIdStr = tostring(userId)
    return FriendsList[userIdStr] == true
end

function FriendsManager.GetFriends()
    local list = {}
    for id, _ in pairs(FriendsList) do
        table.insert(list, id)
    end
    return list
end

function FriendsManager.ClearFriends()
    FriendsList = {}
    print("All friends cleared.")
end

return FriendsManager

