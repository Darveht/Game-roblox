local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ElementSelected = ReplicatedStorage:WaitForChild("ElementSelected")
local UseElementPower = ReplicatedStorage:WaitForChild("UseElementPower")
local ElementalPowers = require(script.Parent:WaitForChild("ElementalPowers"))

local playerElements = {}

ElementSelected.OnServerEvent:Connect(function(player, element)
    playerElements[player.UserId] = element
end)

Players.PlayerRemoving:Connect(function(player)
    playerElements[player.UserId] = nil
end)

UseElementPower.OnServerEvent:Connect(function(player, element, moveState)
    -- moveState puede ser nil (por compatibilidad)
    local selectedElement = playerElements[player.UserId]
    if selectedElement and element == selectedElement then
        ElementalPowers.UsePower(player, element, moveState)
    end
end)

