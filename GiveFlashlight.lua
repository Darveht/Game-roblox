-- Da una linterna al jugador cuando recibe el evento
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local event = ReplicatedStorage:WaitForChild("GiveFlashlight")

event.OnClientEvent:Connect(function()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    -- Evitar duplicados
    if character:FindFirstChild("Linterna") then return end
    local flashlight = Instance.new("Tool")
    flashlight.Name = "Linterna"
    flashlight.RequiresHandle = true
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.5,0.5,2)
    handle.BrickColor = BrickColor.new("Black")
    handle.Parent = flashlight
    flashlight.Parent = character

    local light = Instance.new("SpotLight")
    light.Name = "Spot"
    light.Angle = 80
    light.Brightness = 4
    light.Range = 30
    light.Face = Enum.NormalId.Front
    light.Parent = handle

    -- Encender/apagar con click
    flashlight.Activated:Connect(function()
        light.Enabled = not light.Enabled
    end)
    light.Enabled = true
end)

