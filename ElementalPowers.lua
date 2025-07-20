local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UseElementPower = ReplicatedStorage:WaitForChild("UseElementPower")
local DrawnWaterPower = ReplicatedStorage:WaitForChild("DrawnWaterPower")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local ElementalPowers = {}

-- Función auxiliar para obtener la mano (derecha o izquierda)
local function getHand(character, preferRight)
    local right = character:FindFirstChild("RightHand")
    local left = character:FindFirstChild("LeftHand")
    if preferRight and right then return right end
    if not preferRight and left then return left end
    return right or left or character:FindFirstChild("HumanoidRootPart")
end

-- Función para encontrar el jugador más cercano (que no sea el propio)
local function getClosestPlayer(fromPlayer)
    local minDist = math.huge
    local closest = nil
    local fromChar = fromPlayer.Character
    if not fromChar or not fromChar:FindFirstChild("HumanoidRootPart") then return nil end
    local fromPos = fromChar.HumanoidRootPart.Position
    for _, p in Players:GetPlayers() do
        if p ~= fromPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (p.Character.HumanoidRootPart.Position - fromPos).Magnitude
            if dist < minDist then
                minDist = dist
                closest = p
            end
        end
    end
    return closest
end

-- Poder de fuego: bola de fuego (mano)
function ElementalPowers.FirePower(player, moveState)
    local character = player.Character
    if not character then return end
    local hand = getHand(character, true)
    if not hand then return end

    local fireball = Instance.new("Part")
    fireball.Shape = Enum.PartType.Ball
    fireball.Size = Vector3.new(2,2,2)
    fireball.Position = hand.Position + hand.CFrame.LookVector * 2
    fireball.Anchored = false
    fireball.CanCollide = false
    fireball.BrickColor = BrickColor.new("Bright orange")
    fireball.Material = Enum.Material.Neon
    fireball.Parent = workspace

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = hand.CFrame.LookVector * 80
    bv.MaxForce = Vector3.new(1,1,1) * 1e5
    bv.Parent = fireball

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://241594419"
    emitter.Color = ColorSequence.new(Color3.fromRGB(255,120,40))
    emitter.Size = NumberSequence.new(2)
    emitter.Lifetime = NumberRange.new(0.2, 0.5)
    emitter.Rate = 80
    emitter.Speed = NumberRange.new(10, 20)
    emitter.Parent = fireball

    fireball.Touched:Connect(function(hit)
        local hum = hit.Parent:FindFirstChild("Humanoid")
        if hum and hum ~= character:FindFirstChild("Humanoid") then
            hum:TakeDamage(30)
            fireball:Destroy()
        end
    end)
    Debris:AddItem(fireball, 3)
end

-- NUEVO: Poder de fuego - Bomba de explosión masiva (sale de la boca)
function ElementalPowers.FireExplosionPower(player, moveState)
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Efecto visual de fuego saliendo de la boca
    local firePart = Instance.new("Part")
    firePart.Size = Vector3.new(2,2,2)
    firePart.CFrame = head.CFrame * CFrame.new(0,0,-1)
    firePart.Anchored = true
    firePart.CanCollide = false
    firePart.Transparency = 1
    firePart.Parent = workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://241594419"
    emitter.Color = ColorSequence.new(Color3.fromRGB(255,120,40), Color3.fromRGB(255,40,10))
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,2), NumberSequenceKeypoint.new(1,6)})
    emitter.Lifetime = NumberRange.new(0.3, 0.7)
    emitter.Rate = 200
    emitter.Speed = NumberRange.new(30, 60)
    emitter.VelocitySpread = 40
    emitter.Parent = firePart

    -- Explosión masiva de fuego
    local explosion = Instance.new("Explosion")
    explosion.Position = head.Position + head.CFrame.LookVector * 6
    explosion.BlastRadius = 18
    explosion.BlastPressure = 900000
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.Parent = workspace

    -- Daño extra a jugadores cercanos
    explosion.Hit:Connect(function(part, dist)
        local hum = part.Parent:FindFirstChild("Humanoid")
        if hum and hum ~= character:FindFirstChild("Humanoid") then
            hum:TakeDamage(60)
        end
    end)

    Debris:AddItem(firePart, 1.2)
end

-- NUEVO: Poder de rayo azul (Azula)
function ElementalPowers.AzulaLightningPower(player, moveState)
    local character = player.Character
    if not character then return end
    local hand = getHand(character, true)
    if not hand then return end

    local target = getClosestPlayer(player)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end

    local startPos = hand.Position
    local endPos = target.Character.HumanoidRootPart.Position + Vector3.new(0,2,0)
    local dist = (endPos - startPos).Magnitude

    -- Efecto visual: rayo azul
    local beamPart = Instance.new("Part")
    beamPart.Size = Vector3.new(0.5,0.5,dist)
    beamPart.CFrame = CFrame.new((startPos+endPos)/2, endPos)
    beamPart.Anchored = true
    beamPart.CanCollide = false
    beamPart.Transparency = 0.5
    beamPart.Color = Color3.fromRGB(80,180,255)
    beamPart.Material = Enum.Material.Neon
    beamPart.Parent = workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://259403370" -- textura de rayo
    emitter.Color = ColorSequence.new(Color3.fromRGB(80,180,255), Color3.fromRGB(0,80,255))
    emitter.Size = NumberSequence.new(1.2)
    emitter.Lifetime = NumberRange.new(0.15, 0.3)
    emitter.Rate = 120
    emitter.Speed = NumberRange.new(20, 40)
    emitter.Parent = beamPart

    -- Daño instantáneo y aturdimiento
    local hum = target.Character:FindFirstChild("Humanoid")
    if hum then
        hum:TakeDamage(50)
        -- Aturdir correctamente: guardar velocidad y restaurar
        local oldSpeed = hum.WalkSpeed
        hum.WalkSpeed = 0
        task.delay(1.2, function()
            if hum then hum.WalkSpeed = oldSpeed end
        end)
    end

    Debris:AddItem(beamPart, 0.7)
end

-- Poder de aire (sale de la mano)
function ElementalPowers.AirPower(player, moveState)
    local character = player.Character
    if not character then return end
    local hand = getHand(character, false)
    if not hand then return end

    local gust = Instance.new("Part")
    gust.Size = Vector3.new(1,1,8)
    gust.CFrame = hand.CFrame * CFrame.new(0,0,-4)
    gust.Anchored = false
    gust.CanCollide = false
    gust.Transparency = 0.7
    gust.Color = Color3.fromRGB(220,220,255)
    gust.Material = Enum.Material.Neon
    gust.Parent = workspace

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = hand.CFrame.LookVector * 100
    bv.MaxForce = Vector3.new(1,1,1) * 1e5
    bv.Parent = gust

    gust.Touched:Connect(function(hit)
        local hum = hit.Parent:FindFirstChild("Humanoid")
        if hum and hum ~= character:FindFirstChild("Humanoid") then
            hum:TakeDamage(15)
        end
    end)
    Debris:AddItem(gust, 1.5)
end

-- Poder de tierra (sale de la mano)
function ElementalPowers.EarthPower(player, moveState)
    local character = player.Character
    if not character then return end
    local hand = getHand(character, false)
    if not hand then return end

    local rock = Instance.new("Part")
    rock.Size = Vector3.new(3,3,3)
    rock.Position = hand.Position + hand.CFrame.LookVector * 2
    rock.Anchored = false
    rock.CanCollide = true
    rock.BrickColor = BrickColor.new("Earth green")
    rock.Material = Enum.Material.Slate
    rock.Parent = workspace

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = hand.CFrame.LookVector * 60
    bv.MaxForce = Vector3.new(1,1,1) * 1e5
    bv.Parent = rock

    rock.Touched:Connect(function(hit)
        local hum = hit.Parent:FindFirstChild("Humanoid")
        if hum and hum ~= character:FindFirstChild("Humanoid") then
            hum:TakeDamage(40)
            rock:Destroy()
        end
    end)
    Debris:AddItem(rock, 2)
end

-- Poder de agua personalizado según dibujo (sale de la mano)
function ElementalPowers.DrawnWaterPower(player, points)
    local character = player.Character
    if not character then return end

    -- Si no hay puntos, lanzar agua directo al jugador más cercano
    if not points or #points < 2 then
        -- Buscar objetivo más cercano
        local target = getClosestPlayer(player)
        local hand = getHand(character, true)
        if not hand or not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
        local startPos = hand.Position
        local endPos = target.Character.HumanoidRootPart.Position + Vector3.new(0,2,0)
        local dir = (endPos - startPos).Unit
        local dist = (endPos - startPos).Magnitude

        local part = Instance.new("Part")
        part.Size = Vector3.new(0.8,0.8,dist)
        part.CFrame = CFrame.new((startPos+endPos)/2, endPos)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.7
        part.Color = Color3.fromRGB(80,180,255)
        part.Material = Enum.Material.Neon
        part.Parent = workspace
        Debris:AddItem(part, 1.5)

        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = "rbxassetid://484436622"
        emitter.Color = ColorSequence.new(Color3.fromRGB(180,220,255))
        emitter.Size = NumberSequence.new(0.7)
        emitter.Lifetime = NumberRange.new(0.2, 0.5)
        emitter.Rate = 80
        emitter.Speed = NumberRange.new(6, 12)
        emitter.VelocitySpread = 60
        emitter.Parent = part

        -- Solo hacer daño al objetivo más cercano
        local hitDone = false
        part.Touched:Connect(function(hit)
            if hitDone then return end
            local hum = hit.Parent:FindFirstChild("Humanoid")
            if hum and target.Character and hum == target.Character:FindFirstChild("Humanoid") then
                hum:TakeDamage(30)
                hitDone = true
            end
        end)
        return
    end

    -- Si hay puntos, lanzar agua siguiendo el dibujo (como antes)
    local root = character:FindFirstChild("HumanoidRootPart")
    local hand = getHand(character, true)
    if not root or not hand then return end

    -- Convertir puntos 2D (relativos a la GUI) a puntos 3D en el mundo, frente a la mano
    local basePos = hand.Position + hand.CFrame.LookVector * 2
    local scale = 12 -- Escala del dibujo en el mundo
    local up = hand.CFrame.UpVector
    local right = hand.CFrame.RightVector
    local look = hand.CFrame.LookVector

    local worldPoints = {}
    for i = 1, #points do
        local p = points[i]
        -- p.X, p.Y están en [0,1], centramos en (0,0)
        local offset = (p.X - 0.5) * scale * right + (p.Y - 0.5) * scale * up
        local worldPos = basePos + offset + look * (i * 0.5)
        table.insert(worldPoints, worldPos)
    end

    -- Crear partes/beam a lo largo de la trayectoria
    local lastPart = nil
    for i = 1, #worldPoints-1 do
        local p0 = worldPoints[i]
        local p1 = worldPoints[i+1]
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.6,0.6,(p1-p0).Magnitude)
        part.CFrame = CFrame.new((p0+p1)/2, p1)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.7
        part.Color = Color3.fromRGB(80,180,255)
        part.Material = Enum.Material.Neon
        part.Parent = workspace
        Debris:AddItem(part, 1.5)

        -- Efecto de partículas de agua
        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = "rbxassetid://484436622"
        emitter.Color = ColorSequence.new(Color3.fromRGB(180,220,255))
        emitter.Size = NumberSequence.new(0.7)
        emitter.Lifetime = NumberRange.new(0.2, 0.5)
        emitter.Rate = 80
        emitter.Speed = NumberRange.new(6, 12)
        emitter.VelocitySpread = 60
        emitter.Parent = part

        -- Daño a otros jugadores
        part.Touched:Connect(function(hit)
            local hum = hit.Parent:FindFirstChild("Humanoid")
            if hum and hum ~= character:FindFirstChild("Humanoid") then
                hum:TakeDamage(25)
            end
        end)

        -- Opcional: conectar con Beam visual
        if lastPart then
            local att0 = Instance.new("Attachment")
            att0.Parent = lastPart
            local att1 = Instance.new("Attachment")
            att1.Parent = part
            local beam = Instance.new("Beam")
            beam.Attachment0 = att0
            beam.Attachment1 = att1
            beam.Texture = "rbxassetid://130207098"
            beam.TextureLength = 2
            beam.TextureSpeed = 2
            beam.Width0 = 0.7
            beam.Width1 = 0.7
            beam.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(1, 0.7)
            }
            beam.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(80,180,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180,220,255))
            }
            beam.LightEmission = 0.8
            beam.Parent = att0
            Debris:AddItem(beam, 1.5)
        end
        lastPart = part
    end
end

-- Lógica para usar el poder correcto
function ElementalPowers.UsePower(player, element, moveState)
    if element == "Fuego" then
        if moveState == "Jump" then
            ElementalPowers.FireExplosionPower(player, moveState)
        else
            ElementalPowers.FirePower(player, moveState)
        end
    elseif element == "Azula" then
        ElementalPowers.AzulaLightningPower(player, moveState)
    elseif element == "Aire" then
        ElementalPowers.AirPower(player, moveState)
    elseif element == "Tierra" then
        ElementalPowers.EarthPower(player, moveState)
    elseif element == "Agua" then
        -- Si el poder de agua se lanza sin dibujo, irá directo al jugador más cercano
        ElementalPowers.DrawnWaterPower(player, nil)
    end
    -- El poder de agua también puede ejecutarse desde DrawnWaterPower (con GUI)
end

UseElementPower.OnServerEvent:Connect(function(player, element, moveState)
    ElementalPowers.UsePower(player, element, moveState)
end)

DrawnWaterPower.OnServerEvent:Connect(function(player, points)
    ElementalPowers.DrawnWaterPower(player, points)
end)

return ElementalPowers

