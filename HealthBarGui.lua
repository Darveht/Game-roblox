-- Barra de vida visible para todos los jugadores
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local head = character:WaitForChild("Head")
        -- Evitar duplicados
        if head:FindFirstChild("HealthBillboard") then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HealthBillboard"
        billboard.Size = UDim2.new(4,0,0.6,0)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1,0,1,0)
        barBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
        barBg.BorderSizePixel = 0
        barBg.Parent = billboard

        local bar = Instance.new("Frame")
        bar.Name = "HealthBar"
        bar.Size = UDim2.new(1,0,1,0)
        bar.BackgroundColor3 = Color3.fromRGB(80,255,80)
        bar.BorderSizePixel = 0
        bar.Parent = barBg

        local function update()
            bar.Size = UDim2.new(humanoid.Health/humanoid.MaxHealth,0,1,0)
            if humanoid.Health/humanoid.MaxHealth < 0.3 then
                bar.BackgroundColor3 = Color3.fromRGB(255,80,80)
            else
                bar.BackgroundColor3 = Color3.fromRGB(80,255,80)
            end
        end
        humanoid.HealthChanged:Connect(update)
        update()
    end)
end)
for _, player in Players:GetPlayers() do
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        if humanoid and head and not head:FindFirstChild("HealthBillboard") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "HealthBillboard"
            billboard.Size = UDim2.new(4,0,0.6,0)
            billboard.StudsOffset = Vector3.new(0,3,0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            local barBg = Instance.new("Frame")
            barBg.Size = UDim2.new(1,0,1,0)
            barBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
            barBg.BorderSizePixel = 0
            barBg.Parent = billboard

            local bar = Instance.new("Frame")
            bar.Name = "HealthBar"
            bar.Size = UDim2.new(1,0,1,0)
            bar.BackgroundColor3 = Color3.fromRGB(80,255,80)
            bar.BorderSizePixel = 0
            bar.Parent = barBg

            local function update()
                bar.Size = UDim2.new(humanoid.Health/humanoid.MaxHealth,0,1,0)
                if humanoid.Health/humanoid.MaxHealth < 0.3 then
                    bar.BackgroundColor3 = Color3.fromRGB(255,80,80)
                else
                    bar.BackgroundColor3 = Color3.fromRGB(80,255,80)
                end
            end
            humanoid.HealthChanged:Connect(update)
            update()
        end
    end
end

