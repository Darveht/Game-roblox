-- GUI indicador de nivel para todos los jugadores
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local event = ReplicatedStorage:WaitForChild("LevelIndicatorEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "LevelIndicatorGui"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 60)
frame.Position = UDim2.new(0.5, -160, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(30,30,60)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,1,0)
label.BackgroundTransparency = 1
label.Text = "Nivel 1"
label.TextColor3 = Color3.fromRGB(255,255,80)
label.Font = Enum.Font.Fantasy
label.TextScaled = true
label.Parent = frame

event.OnClientEvent:Connect(function(level, desc)
    label.Text = "Nivel "..level.." - "..desc
end)

