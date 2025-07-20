-- GUI de dibujo para poderes de agua personalizados
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local DrawnWaterPower = ReplicatedStorage:WaitForChild("DrawnWaterPower")

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaterDrawGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local drawFrame = Instance.new("Frame")
drawFrame.Size = UDim2.new(0, 400, 0, 400)
drawFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
drawFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
drawFrame.BackgroundTransparency = 0.2
drawFrame.BorderSizePixel = 0
drawFrame.Visible = false
drawFrame.Parent = screenGui

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 24
closeBtn.Parent = drawFrame

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, 120, 0, 40)
sendBtn.Position = UDim2.new(0.5, -60, 1, -50)
sendBtn.Text = "Lanzar Poder"
sendBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
sendBtn.TextColor3 = Color3.new(1,1,1)
sendBtn.Font = Enum.Font.SourceSansBold
sendBtn.TextSize = 22
sendBtn.Parent = drawFrame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,0,0,30)
info.Position = UDim2.new(0,0,0,0)
info.BackgroundTransparency = 1
info.Text = "Dibuja la forma del poder de agua y pulsa 'Lanzar Poder'"
info.TextColor3 = Color3.fromRGB(180,220,255)
info.Font = Enum.Font.SourceSans
info.TextSize = 18
info.Parent = drawFrame

-- Dibujo
local drawing = false
local points = {}
local lines = {}

local function clearDrawing()
    for i = 1, #lines do
        lines[i]:Destroy()
    end
    lines = {}
    points = {}
end

drawFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drawing = true
        local pos = input.Position
        local rel = Vector2.new(
            (pos.X - drawFrame.AbsolutePosition.X) / drawFrame.AbsoluteSize.X,
            (pos.Y - drawFrame.AbsolutePosition.Y) / drawFrame.AbsoluteSize.Y
        )
        table.insert(points, rel)
    end
end)

drawFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drawing = false
    end
end)

drawFrame.InputChanged:Connect(function(input)
    if drawing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = input.Position
        local rel = Vector2.new(
            (pos.X - drawFrame.AbsolutePosition.X) / drawFrame.AbsoluteSize.X,
            (pos.Y - drawFrame.AbsolutePosition.Y) / drawFrame.AbsoluteSize.Y
        )
        if #points > 0 then
            local last = points[#points]
            local line = Instance.new("Frame")
            line.BackgroundColor3 = Color3.fromRGB(80,180,255)
            line.BorderSizePixel = 0
            local x1 = last.X * drawFrame.AbsoluteSize.X
            local y1 = last.Y * drawFrame.AbsoluteSize.Y
            local x2 = rel.X * drawFrame.AbsoluteSize.X
            local y2 = rel.Y * drawFrame.AbsoluteSize.Y
            local len = (Vector2.new(x2, y2) - Vector2.new(x1, y1)).Magnitude
            line.Size = UDim2.new(0, len, 0, 4)
            line.Position = UDim2.new(0, x1, 0, y1 - 2)
            line.Rotation = math.deg(math.atan2(y2 - y1, x2 - x1))
            line.Parent = drawFrame
            table.insert(lines, line)
        end
        table.insert(points, rel)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    drawFrame.Visible = false
    clearDrawing()
    if _G.WaterDrawGuiCallback then
        _G.WaterDrawGuiCallback(nil)
        _G.WaterDrawGuiCallback = nil
    end
end)

sendBtn.MouseButton1Click:Connect(function()
    if #points > 2 then
        DrawnWaterPower:FireServer(points)
        if _G.WaterDrawGuiCallback then
            _G.WaterDrawGuiCallback(points)
            _G.WaterDrawGuiCallback = nil
        end
    else
        if _G.WaterDrawGuiCallback then
            _G.WaterDrawGuiCallback(nil)
            _G.WaterDrawGuiCallback = nil
        end
    end
    drawFrame.Visible = false
    clearDrawing()
end)

-- Permitir mostrar la GUI desde otros scripts y esperar el resultado
_G.ShowWaterDrawGui = function(callback)
    drawFrame.Visible = true
    clearDrawing()
    _G.WaterDrawGuiCallback = callback
end

-- (Opcional) Tecla para abrir la GUI manualmente (para pruebas)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E then
        drawFrame.Visible = not drawFrame.Visible
        clearDrawing()
    end
end)

