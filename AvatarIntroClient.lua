-- Intro animada Avatar con personaje 3D haciendo poderes de elementos (cinemática)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local showEvent = ReplicatedStorage:WaitForChild("ShowAvatarIntro")

-- Nombre del modelo 3D del personaje para el intro
local CHARACTER_MODEL_NAME = "Sketchfab_Scene"

-- Utilidad: Buscar parte relevante del modelo para cada poder
local function findRelevantPart(model, element)
    -- Buscar por nombre
    local candidates = {}
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local n = part.Name:lower()
            if element == "Agua" or element == "Fuego" or element == "Aire" or element == "Azula" then
                if n:find("hand") or n:find("mano") or n:find("arm") or n:find("brazo") then
                    table.insert(candidates, part)
                end
            elseif element == "Tierra" then
                if n:find("foot") or n:find("pie") or n:find("leg") or n:find("pierna") then
                    table.insert(candidates, part)
                end
            end
        end
    end
    -- Si hay candidatos, usar el primero
    if #candidates > 0 then
        return candidates[1]
    end
    -- Si no, usar la parte más alta (para agua/fuego/aire/azula) o más baja (tierra)
    local bestPart = nil
    if element == "Tierra" then
        local minY = math.huge
        for _, part in model:GetDescendants() do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                if part.Position.Y < minY then
                    minY = part.Position.Y
                    bestPart = part
                end
            end
        end
    else
        local maxY = -math.huge
        for _, part in model:GetDescendants() do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                if part.Position.Y > maxY then
                    maxY = part.Position.Y
                    bestPart = part
                end
            end
        end
    end
    return bestPart
end

-- Utilidad: Centrar y escalar el modelo para el intro
local function centerAndScaleModel(model)
    -- Calcular bounding box
    local min, max = nil, nil
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local pos = part.Position
            if not min then min = pos end
            if not max then max = pos end
            min = Vector3.new(math.min(min.X, pos.X), math.min(min.Y, pos.Y), math.min(min.Z, pos.Z))
            max = Vector3.new(math.max(max.X, pos.X), math.max(max.Y, pos.Y), math.max(max.Z, pos.Z))
        end
    end
    if not min or not max then return end
    local center = (min + max) / 2
    local size = max - min
    -- Escalar para que la altura sea ~8 studs
    local scale = 8 / math.max(size.Y, 0.1)
    model:ScaleTo(scale)
    -- Recalcular centro tras escalar
    min, max = nil, nil
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local pos = part.Position
            if not min then min = pos end
            if not max then max = pos end
            min = Vector3.new(math.min(min.X, pos.X), math.min(min.Y, pos.Y), math.min(min.Z, pos.Z))
            max = Vector3.new(math.max(max.X, pos.X), math.max(max.Y, pos.Y), math.max(max.Z, pos.Z))
        end
    end
    center = (min + max) / 2
    -- Mover modelo al centro del intro
    model:PivotTo(CFrame.new(0, 8, 0) * CFrame.new(0, -(min.Y), 0))
end

-- Configuración de escenas de elementos
local elementScenes = {
    {
        name = "Agua",
        bg = Color3.fromRGB(40,80,180),
        txt = "El agua fluye y da vida. El Avatar domina el agua.",
        effect = function(model, camera)
            local hand = findRelevantPart(model, "Agua")
            if hand then
                local water = Instance.new("ParticleEmitter")
                water.Texture = "rbxassetid://484436622"
                water.Color = ColorSequence.new(Color3.fromRGB(80,180,255))
                water.Size = NumberSequence.new(2)
                water.Lifetime = NumberRange.new(0.5, 1)
                water.Rate = 120
                water.Speed = NumberRange.new(12, 18)
                water.Parent = hand
                task.wait(1.2)
                water.Enabled = false
                water:Destroy()
            else
                task.wait(1.2)
            end
        end
    },
    {
        name = "Fuego",
        bg = Color3.fromRGB(180,40,40),
        txt = "El fuego es poder y destrucción. El Avatar controla el fuego.",
        effect = function(model, camera)
            local hand = findRelevantPart(model, "Fuego")
            if hand then
                local fire = Instance.new("ParticleEmitter")
                fire.Texture = "rbxassetid://241594419"
                fire.Color = ColorSequence.new(Color3.fromRGB(255,120,40))
                fire.Size = NumberSequence.new(2)
                fire.Lifetime = NumberRange.new(0.3, 0.7)
                fire.Rate = 180
                fire.Speed = NumberRange.new(18, 28)
                fire.Parent = hand
                task.wait(1.2)
                fire.Enabled = false
                fire:Destroy()
            else
                task.wait(1.2)
            end
        end
    },
    {
        name = "Tierra",
        bg = Color3.fromRGB(80,60,30),
        txt = "La tierra es fuerza y resistencia. El Avatar domina la tierra.",
        effect = function(model, camera)
            local foot = findRelevantPart(model, "Tierra")
            if foot then
                -- Simular levantar tierra
                local rock = Instance.new("Part")
                rock.Name = "IntroRock"
                rock.Size = Vector3.new(5,2,5)
                rock.Position = foot.Position + Vector3.new(0,-3,0)
                rock.Anchored = true
                rock.Color = Color3.fromRGB(80,60,30)
                rock.Material = Enum.Material.Slate
                rock.Parent = Workspace
                TweenService:Create(rock, TweenInfo.new(0.7), {Position = foot.Position + Vector3.new(0,2,0)}):Play()
                task.wait(1.2)
                rock:Destroy()
            else
                task.wait(1.2)
            end
        end
    },
    {
        name = "Aire",
        bg = Color3.fromRGB(200,200,255),
        txt = "El aire es libertad y movimiento. El Avatar controla el aire.",
        effect = function(model, camera)
            local hand = findRelevantPart(model, "Aire")
            if hand then
                local air = Instance.new("ParticleEmitter")
                air.Texture = "rbxassetid://130207098"
                air.Color = ColorSequence.new(Color3.fromRGB(200,200,255))
                air.Size = NumberSequence.new(2)
                air.Lifetime = NumberRange.new(0.3, 0.7)
                air.Rate = 120
                air.Speed = NumberRange.new(18, 28)
                air.Parent = hand
                task.wait(1.2)
                air.Enabled = false
                air:Destroy()
            else
                task.wait(1.2)
            end
        end
    },
    {
        name = "Azula",
        bg = Color3.fromRGB(80,180,255),
        txt = "El rayo azul de Azula: poder letal y precisión.",
        effect = function(model, camera)
            local hand = findRelevantPart(model, "Azula")
            if hand then
                -- Efecto rayo azul: haz visible y partículas
                local beam = Instance.new("Part")
                beam.Name = "IntroBeam"
                beam.Size = Vector3.new(0.5,0.5,12)
                beam.CFrame = hand.CFrame * CFrame.new(0,0,-6)
                beam.Anchored = true
                beam.CanCollide = false
                beam.Transparency = 0.2
                beam.Color = Color3.fromRGB(80,180,255)
                beam.Material = Enum.Material.Neon
                beam.Parent = Workspace

                local emitter = Instance.new("ParticleEmitter")
                emitter.Texture = "rbxassetid://259403370"
                emitter.Color = ColorSequence.new(Color3.fromRGB(80,180,255), Color3.fromRGB(0,80,255))
                emitter.Size = NumberSequence.new(1.5)
                emitter.Lifetime = NumberRange.new(0.12, 0.22)
                emitter.Rate = 200
                emitter.Speed = NumberRange.new(30, 60)
                emitter.Parent = beam

                -- Efecto de luz
                local light = Instance.new("PointLight")
                light.Color = Color3.fromRGB(80,180,255)
                light.Brightness = 6
                light.Range = 18
                light.Parent = beam

                -- Pequeño sonido de rayo (opcional)
                --[[
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://9118828562"
                sound.Volume = 0.7
                sound.Parent = beam
                sound:Play()
                ]]

                task.wait(1.2)
                emitter.Enabled = false
                beam:Destroy()
            else
                task.wait(1.2)
            end
        end
    }
}

local historia = {
    "En un mundo dividido por los elementos, solo el Avatar puede unirlos.",
    "Tu misión: dominar los poderes, sobrevivir a los desafíos y restaurar el equilibrio.",
    "¿Estás listo para comenzar tu aventura como Avatar?"
}

local function createIntroGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AvatarIntroGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1,0,1,0)
    bg.Position = UDim2.new(0,0,0,0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0
    bg.ZIndex = 10
    bg.Parent = gui

    local text = Instance.new("TextLabel")
    text.Name = "IntroText"
    text.Size = UDim2.new(0.8,0,0.18,0)
    text.Position = UDim2.new(0.1,0,0.8,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Font = Enum.Font.Fantasy
    text.TextScaled = true
    text.Text = ""
    text.TextTransparency = 1
    text.ZIndex = 30
    text.Parent = bg

    local skipBtn = Instance.new("TextButton")
    skipBtn.Name = "SkipBtn"
    skipBtn.Size = UDim2.new(0,160,0,60)
    skipBtn.Position = UDim2.new(1,-180,1,-90)
    skipBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    skipBtn.Text = "Omitir Intro"
    skipBtn.TextColor3 = Color3.new(1,1,1)
    skipBtn.Font = Enum.Font.SourceSansBold
    skipBtn.TextSize = 32
    skipBtn.BackgroundTransparency = 0.15
    skipBtn.ZIndex = 40
    skipBtn.Parent = bg

    return gui, text, skipBtn, bg
end

local function playIntro()
    local gui, text, skipBtn, bg = createIntroGui()
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local finished = false

    -- Bloquear otros GUIs
    for _, g in LocalPlayer.PlayerGui:GetChildren() do
        if g:IsA("ScreenGui") and g ~= gui then
            g.Enabled = false
        end
    end

    -- Clonar el modelo del personaje
    local origModel = Workspace:FindFirstChild(CHARACTER_MODEL_NAME)
    local model = nil
    if origModel then
        model = origModel:Clone()
        model.Name = "AvatarIntroCharacter"
        model.Parent = Workspace
        centerAndScaleModel(model)
    end

    -- Guardar cámara original y cambiar a Scriptable
    local camera = Workspace.CurrentCamera
    local origType = camera.CameraType
    local origCFrame = camera.CFrame
    camera.CameraType = Enum.CameraType.Scriptable

    local function focusCameraOnModel(offset)
        if model then
            -- Calcular centro del modelo
            local min, max = nil, nil
            for _, part in model:GetDescendants() do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    local pos = part.Position
                    if not min then min = pos end
                    if not max then max = pos end
                    min = Vector3.new(math.min(min.X, pos.X), math.min(min.Y, pos.Y), math.min(min.Z, pos.Z))
                    max = Vector3.new(math.max(max.X, pos.X), math.max(max.Y, pos.Y), math.max(max.Z, pos.Z))
                end
            end
            local center = (min and max) and ((min + max) / 2) or Vector3.new(0,8,0)
            camera.CFrame = CFrame.new(center) * (offset or CFrame.new(0,2,18) * CFrame.Angles(0,math.rad(180),0))
        end
    end

    local function skip()
        finished = true
        gui:Destroy()
        if model then model:Destroy() end
        -- Limpiar efectos extra en Workspace
        for _, obj in Workspace:GetChildren() do
            if obj.Name == "AvatarIntroCharacter" or obj.Name == "IntroRock" or obj.Name == "IntroBeam" then
                obj:Destroy()
            end
        end
        -- Restaurar cámara
        camera.CameraType = origType
        camera.CFrame = origCFrame
        -- Restaurar GUIs
        for _, g in LocalPlayer.PlayerGui:GetChildren() do
            if g:IsA("ScreenGui") then
                g.Enabled = true
            end
        end
    end
    skipBtn.MouseButton1Click:Connect(skip)

    -- Animar cada elemento
    for i = 1, #elementScenes do
        if finished then return end
        local scene = elementScenes[i]
        text.Text = scene.txt
        text.TextTransparency = 1
        bg.BackgroundColor3 = scene.bg

        -- Cámara cinemática
        focusCameraOnModel(CFrame.new(0,2,18) * CFrame.Angles(0,math.rad(180),0))

        -- Fade in texto
        for t = 0, 1, 0.08 do
            if finished then return end
            text.TextTransparency = 1-t
            task.wait(0.03)
        end
        text.TextTransparency = 0

        -- Efecto especial de elemento (animación)
        if scene.effect then
            scene.effect(model, camera)
        else
            task.wait(1.2)
        end

        -- Limpiar efectos extra en Workspace tras cada escena
        for _, obj in Workspace:GetChildren() do
            if obj.Name == "IntroRock" or obj.Name == "IntroBeam" then
                obj:Destroy()
            end
        end

        -- Fade out texto
        for t = 0, 1, 0.08 do
            if finished then return end
            text.TextTransparency = t
            task.wait(0.03)
        end
        text.TextTransparency = 1
    end

    -- Mostrar historia
    for i = 1, #historia do
        if finished then return end
        text.Text = historia[i]
        text.TextTransparency = 1
        bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
        for t = 0, 1, 0.08 do
            if finished then return end
            text.TextTransparency = 1-t
            task.wait(0.03)
        end
        text.TextTransparency = 0
        task.wait(2)
        for t = 0, 1, 0.08 do
            if finished then return end
            text.TextTransparency = t
            task.wait(0.03)
        end
        text.TextTransparency = 1
    end

    -- Fin
    skip()
end

-- Mostrar intro al entrar al juego (solo una vez por sesión)
local played = false
showEvent.OnClientEvent:Connect(function()
    if not played then
        played = true
        playIntro()
    end
end)

