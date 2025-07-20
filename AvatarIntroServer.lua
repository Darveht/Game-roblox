-- Llama al RemoteEvent para mostrar la intro al entrar al juego
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local showEvent = ReplicatedStorage:WaitForChild("ShowAvatarIntro")

Players.PlayerAdded:Connect(function(player)
    -- Esperar a que PlayerGui esté listo
    task.wait(1)
    showEvent:FireClient(player)
end)



