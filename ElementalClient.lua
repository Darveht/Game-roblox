local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ElementSelected = ReplicatedStorage:WaitForChild("ElementSelected")
local UseElementPower = ReplicatedStorage:WaitForChild("UseElementPower")

local element = nil
local moveState = "Idle" -- Puede ser "Idle", "Left", "Right", "Jump"

-- Crear GUI de selección
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ElementSelectionGui"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 120)
frame.Position = UDim2.new(0.5, -250, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = screenGui

local elements = {"Agua", "Fuego", "Aire", "Tierra", "Azula"}
for i = 1, #elements do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 80)
	btn.Position = UDim2.new(0, 10 + (i-1)*100, 0, 20)
	btn.Text = elements[i]
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 28
	btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		element = elements[i]
		ElementSelected:FireServer(element)
		screenGui.Enabled = false
	end)
end

screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Instrucciones
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,0,0,60)
info.Position = UDim2.new(0,0,1,-60)
info.BackgroundTransparency = 1
info.Text = "Pulsa 'Q' para poder básico. Usa flechas para poderes especiales:\n← = Poder defensivo/especial | → = Poder de ataque múltiple\n↑ (Salto) = Poder explosivo masivo\nCada elemento tiene diferentes técnicas con las flechas!"
info.TextColor3 = Color3.fromRGB(255,255,255)
info.Font = Enum.Font.SourceSans
info.TextSize = 16
info.Parent = frame

-- Botones móviles
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "ElementalMobileGui"
mobileGui.ResetOnSpawn = false
mobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function createMobileButton(name, pos, text)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 70, 0, 70)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(50,50,100)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 28
	btn.Parent = mobileGui
	return btn
end

local btnLeft = createMobileButton("LeftBtn", UDim2.new(0, 30, 1, -180), "←")
local btnRight = createMobileButton("RightBtn", UDim2.new(0, 120, 1, -180), "→")
local btnJump = createMobileButton("JumpBtn", UDim2.new(0, 75, 1, -260), "⤒")
local btnPower = createMobileButton("PowerBtn", UDim2.new(1, -110, 1, -260), "Poder")

-- Estado de movimiento
btnLeft.MouseButton1Down:Connect(function() moveState = "Left" end)
btnLeft.MouseButton1Up:Connect(function() moveState = "Idle" end)
btnRight.MouseButton1Down:Connect(function() moveState = "Right" end)
btnRight.MouseButton1Up:Connect(function() moveState = "Idle" end)
btnJump.MouseButton1Click:Connect(function()
	moveState = "Jump"
	task.wait(0.3)
	moveState = "Idle"
end)

-- Función para usar poder
local function tryUsePower()
	if element then
		UseElementPower:FireServer(element, moveState)
	end
end

btnPower.MouseButton1Click:Connect(function()
	tryUsePower()
end)

-- Teclado para PC
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Q and element then
		tryUsePower()
	elseif input.KeyCode == Enum.KeyCode.A then
		moveState = "Left"
	elseif input.KeyCode == Enum.KeyCode.D then
		moveState = "Right"
	elseif input.KeyCode == Enum.KeyCode.Space then
		moveState = "Jump"
		-- Lanzar bomba de fuego si el elemento es fuego
		if element == "Fuego" then
			UseElementPower:FireServer("Fuego", "Jump")
		end
	end
end)
UserInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space then
		moveState = "Idle"
	end
end)

