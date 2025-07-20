-- Poder de correr rápido con botón en pantalla
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Crear botón
local gui = Instance.new("ScreenGui")
gui.Name = "SuperRunGui"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Name = "SuperRunBtn"
btn.Size = UDim2.new(0, 70, 0, 70)
btn.Position = UDim2.new(1, -110, 1, -340)
btn.BackgroundColor3 = Color3.fromRGB(80,180,80)
btn.Text = "Correr"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 28
btn.Parent = gui

local running = false
local speedBoost = 60
local normalSpeed = 16
local duration = 5

btn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedBoost
        btn.Text = "¡Rápido!"
        btn.BackgroundColor3 = Color3.fromRGB(255, 220, 80)
        task.wait(duration)
        humanoid.WalkSpeed = normalSpeed
        btn.Text = "Correr"
        btn.BackgroundColor3 = Color3.fromRGB(80,180,80)
    end
    running = false
end)

-- Restaurar velocidad al respawnear
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = normalSpeed
end)

